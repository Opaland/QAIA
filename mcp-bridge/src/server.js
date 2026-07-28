#!/usr/bin/env node
// QAIA MCP bridge -- OPT-IN, NEVER auto-installed by any qaia-* plugin (ADR 0002, ADR 0003).
//
// What this process does, so you can decide whether to run it (ADR 0002's own disclosure
// requirement for anything in the opt-in tier):
//   - Reads QAIA skill Markdown files from this repo checkout and serves them as MCP
//     resources/tools ("Option A" of ADR 0003) -- read-only, no writes anywhere.
//   - Runs two of QAIA's existing, no-network, stdlib-only Python maintainer scripts
//     (structural_score.py, validate_manifest.py) against CONTENT you pass in, never against
//     a path you supply ("Option B" of ADR 0003) -- see src/tools.js for the exact guardrails.
//   - Opens NO network connections of its own, reads NO credentials, writes ONLY to a
//     short-lived temp directory it creates and deletes per call.
//
// This process is a persistent running MCP server -- by definition, something the "zero
// auto-executed" core philosophy (D29/ADR 0002) does not describe. It is intentionally
// packaged outside plugins/ and the marketplace, installed and run only if YOU choose to.
//
// Install/run: see README.md in this directory.
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { z } from 'zod';
import { listSkills, getSkillContent, getOutputContract } from './skills.js';
import { scoreFeature, validateManifest } from './tools.js';

const server = new McpServer({
  name: 'qaia-mcp-bridge',
  version: '0.1.0',
});

// --- Option A: read-only skill/content resources ---------------------------------------

server.registerTool(
  'list_skills',
  {
    title: 'List QAIA skills',
    description:
      'Lists every QAIA skill across all installed plugins (id, plugin, name, description). ' +
      'Read-only; use get_skill_content with the returned id to read a skill in full.',
    inputSchema: {},
  },
  async () => {
    const skills = await listSkills();
    return { content: [{ type: 'text', text: JSON.stringify(skills, null, 2) }] };
  }
);

server.registerTool(
  'get_skill_content',
  {
    title: 'Read a QAIA skill',
    description:
      'Returns the full Markdown content of one QAIA skill (SKILL.md), given the "id" ' +
      '(format "plugin/skill-dir") returned by list_skills. Follow it the same way you would ' +
      'follow any instruction file -- QAIA skills are plain Markdown, not an API.',
    inputSchema: { id: z.string().describe('Skill id as returned by list_skills, e.g. "qaia-core/istqb-design"') },
  },
  async ({ id }) => {
    const content = await getSkillContent(id);
    return { content: [{ type: 'text', text: content }] };
  }
);

server.registerTool(
  'get_output_contract',
  {
    title: 'Read the QAIA output contract',
    description:
      'Returns docs/OUTPUT-CONTRACT.md -- the shared manifest schema every QAIA plugin writes ' +
      'to. Read this before producing or validating a manifest.json.',
    inputSchema: {},
  },
  async () => {
    const content = await getOutputContract();
    return { content: [{ type: 'text', text: content }] };
  }
);

// --- Option B: thin wrappers around QAIA's existing deterministic scripts --------------

server.registerTool(
  'score_feature',
  {
    title: 'Score a Gherkin feature file (deterministic, no LLM)',
    description:
      'Runs QAIA\'s deterministic structural scorer (eval/tools/structural_score.py) against ' +
      'Gherkin feature CONTENT you provide (not a path). Returns readability/completeness/' +
      'coherence/traceability sub-scores, redundancy/fabrication findings, and a PASS/CONCERNS/' +
      'FAIL gate. No LLM judgment involved -- same tool the QAIA product itself uses.',
    inputSchema: { featureContent: z.string().describe('Full text content of a .feature file') },
  },
  async ({ featureContent }) => {
    const result = await scoreFeature(featureContent);
    return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
  }
);

server.registerTool(
  'validate_manifest',
  {
    title: 'Validate a QAIA run manifest against the output contract',
    description:
      'Runs QAIA\'s manifest validator (eval/tools/validate_manifest.py) against manifest.json ' +
      'CONTENT you provide (not a path), checking it against the output contract v1 schema ' +
      '(docs/OUTPUT-CONTRACT.md). Returns pass/fail plus a list of concrete field errors.',
    inputSchema: { manifestJsonContent: z.string().describe('Full text content of a manifest.json file') },
  },
  async ({ manifestJsonContent }) => {
    const result = await validateManifest(manifestJsonContent);
    return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
  }
);

const transport = new StdioServerTransport();
await server.connect(transport);
