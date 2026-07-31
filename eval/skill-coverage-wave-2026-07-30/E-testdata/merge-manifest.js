// merge-manifest.js — SKILL.md step 10 (D39): append-only merge into producers[]/artifacts[]
// of .qaia/reports/<US-ID>/manifest.json, never touching another producer's section.
//
// The real manifest lives in another campaign's directory
// (eval/skill-eval-campaign-2026-07-29/US-EVAL-008-demoblaze/reports/manifest.json). This eval
// run is forbidden to mutate it, so the merge is applied to a COPY written here, and the
// contract rule 2 invariant (design/status/openArbitrations byte-for-byte untouched) is then
// asserted mechanically. Run: node merge-manifest.js
const fs = require('fs');
const path = require('path');

const SRC = path.join(__dirname, '..', '..', 'skill-eval-campaign-2026-07-29', 'US-EVAL-008-demoblaze', 'reports', 'manifest.json');
const OUT = path.join(__dirname, 'manifest.merged.json');

const original = fs.readFileSync(SRC, 'utf8');
const m = JSON.parse(original);

const before = {
  design: JSON.stringify(m.design),
  status: JSON.stringify(m.status),
  openArbitrations: JSON.stringify(m.openArbitrations),
  producers: m.producers.length,
  artifacts: m.artifacts.length,
};

m.producers.push({ plugin: 'qaia-testdata', version: 'unversioned', skill: 'dataset-generate', at: '2026-07-31T00:00:00Z' });
m.artifacts.push({ kind: 'dataset', format: 'json', path: 'eval/skill-coverage-wave-2026-07-30/E-testdata/US-EVAL-008-dataset.json' });
m.artifacts.push({ kind: 'matrix', format: 'markdown', path: 'eval/skill-coverage-wave-2026-07-30/E-testdata/dataset-map.md' });

const after = JSON.parse(JSON.stringify(m));
let bad = 0;
const assert = (label, cond) => { if (!cond) bad++; console.log(`${cond ? 'PASS' : 'FAIL'}  ${label}`); };

assert('design section byte-for-byte untouched', JSON.stringify(after.design) === before.design);
assert('status byte-for-byte untouched', JSON.stringify(after.status) === before.status);
assert('openArbitrations byte-for-byte untouched', JSON.stringify(after.openArbitrations) === before.openArbitrations);
assert('producers[] append-only (no existing entry altered)', JSON.parse(original).producers.every((p, i) => JSON.stringify(after.producers[i]) === JSON.stringify(p)));
assert('artifacts[] append-only (no existing entry altered)', JSON.parse(original).artifacts.every((a, i) => JSON.stringify(after.artifacts[i]) === JSON.stringify(a)));
assert('exactly one producer added', after.producers.length === before.producers + 1);
assert('exactly two artifacts added', after.artifacts.length === before.artifacts + 2);
assert('source manifest on disk is unchanged', fs.readFileSync(SRC, 'utf8') === original);

fs.writeFileSync(OUT, JSON.stringify(m, null, 2) + '\n');
console.log(`\n${bad === 0 ? 'MERGE OK' : bad + ' INVARIANT(S) VIOLATED'} — merged copy written to ${path.basename(OUT)}; ${path.relative(process.cwd(), SRC)} deliberately NOT modified (eval run must not mutate another campaign's artifact).`);
process.exit(bad === 0 ? 0 : 1);
