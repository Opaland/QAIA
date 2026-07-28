// Option B (ADR 0003): the ONLY "active" tools this bridge exposes are thin wrappers around
// QAIA's existing, already-audited, no-network, stdlib-only Python maintainer tools
// (eval/tools/structural_score.py, eval/tools/validate_manifest.py -- see their own headers).
// Deliberately the smallest possible instantiation of "Option B" from ADR 0003: no new
// business logic is introduced here, only a safe transport for content the calling MCP client
// already has, into a script the QAIA project already trusts and has fixtures for.
//
// Security posture (this file, not the wrapped scripts, is the new attack surface):
// - Content in, content out. Callers pass file CONTENT as a string, never a filesystem path --
//   this process never reads a path supplied by the MCP client, so a malicious/compromised
//   client cannot use these tools to read arbitrary files on the host.
// - Every run writes to a fresh temp file under a dedicated scratch directory (never the repo,
//   never a client-chosen path) and deletes it in a `finally`, success or failure.
// - No network access is opened by this file; the wrapped scripts are already documented as
//   network-free.
// - The Python interpreter is resolved once from a fixed candidate list (or QAIA_PYTHON env
//   override) -- never a caller-supplied executable path.
import { spawn } from 'node:child_process';
import { writeFile, unlink, mkdtemp, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { REPO_ROOT } from './skills.js';

const STRUCTURAL_SCORE = path.join(REPO_ROOT, 'eval', 'tools', 'structural_score.py');
const VALIDATE_MANIFEST = path.join(REPO_ROOT, 'eval', 'tools', 'validate_manifest.py');

let cachedPython = null;
async function resolvePython() {
  if (cachedPython) return cachedPython;
  const candidates = process.env.QAIA_PYTHON ? [process.env.QAIA_PYTHON] : ['python3', 'python'];
  for (const candidate of candidates) {
    const ok = await new Promise((resolve) => {
      const p = spawn(candidate, ['--version']);
      p.on('error', () => resolve(false));
      p.on('exit', (code) => resolve(code === 0));
    });
    if (ok) {
      cachedPython = candidate;
      return candidate;
    }
  }
  throw new Error('no working Python interpreter found (tried: ' + candidates.join(', ') + '); set QAIA_PYTHON to override');
}

function run(python, args) {
  return new Promise((resolve, reject) => {
    const p = spawn(python, args, { env: { ...process.env, PYTHONIOENCODING: 'utf-8' } });
    let stdout = '';
    let stderr = '';
    p.stdout.on('data', (d) => (stdout += d));
    p.stderr.on('data', (d) => (stderr += d));
    p.on('error', reject);
    p.on('exit', (code) => resolve({ code, stdout, stderr }));
  });
}

async function withScratchFile(content, extension, fn) {
  const python = await resolvePython();
  const dir = await mkdtemp(path.join(tmpdir(), 'qaia-mcp-bridge-'));
  const file = path.join(dir, `input${extension}`);
  try {
    await writeFile(file, content, 'utf8');
    return await fn(python, file);
  } finally {
    await unlink(file).catch(() => {});
    await rm(dir, { recursive: true, force: true }).catch(() => {});
  }
}

// Scores Gherkin feature CONTENT deterministically (structural_score.py) -- readability,
// completeness, coherence, traceability, redundancy/fabrication findings, PASS/CONCERNS/FAIL
// gate. No LLM involved on the QAIA side; this is the same scorer the QAIA product itself uses.
export async function scoreFeature(featureContent) {
  return withScratchFile(featureContent, '.feature', async (python, file) => {
    const { code, stdout, stderr } = await run(python, [STRUCTURAL_SCORE, file]);
    if (code !== 0 && !stdout.trim()) {
      throw new Error(`structural_score.py failed (exit ${code}): ${stderr || 'no output'}`);
    }
    try {
      return JSON.parse(stdout);
    } catch {
      return { raw: stdout, stderr };
    }
  });
}

// Validates a QAIA run-manifest CONTENT (JSON string) against the output contract v1 schema
// (docs/OUTPUT-CONTRACT.md, docs/schemas/output-contract-v1.schema.json) -- same validator the
// QAIA product itself uses (D104), no separate/duplicated validation logic.
export async function validateManifest(manifestJsonContent) {
  return withScratchFile(manifestJsonContent, '.json', async (python, file) => {
    const { stdout, stderr } = await run(python, [VALIDATE_MANIFEST, file]);
    const errors = [];
    for (const line of stdout.split('\n')) {
      if (line.startsWith('  - ')) errors.push(line.slice(4));
    }
    const pass = stdout.startsWith('PASS');
    return { pass, errors, raw: stdout, stderr };
  });
}
