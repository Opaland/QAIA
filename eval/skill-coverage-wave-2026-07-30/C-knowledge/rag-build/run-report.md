# rag-build — step 3 "Report"

Skill: `plugins/qaia-core/skills/rag-build/SKILL.md`
Run: 2026-07-30, skill-coverage wave, non-interactive (no human in session).
Input: `eval/skill-eval-campaign-2026-07-29/US-EVAL-009-octoperf-petstore/state/01-extraction.md`,
section "Business rules / constraints found outside the AC list" (3 bullets).

## What changed

| File | Change |
|---|---|
| `knowledge/index.md` | created (master index, 1 row) |
| `knowledge/business-rules.md` | created, 2 entries: `BR-KB-001`, `BR-KB-002` |

3 candidate constraints examined → 2 promoted, 1 rejected (the "no Update Cart button observed"
bullet: an absence of observation, not a declarative testable rule — rejection recorded inside
`business-rules.md` so the decision is auditable rather than silent).

## Step-by-step trace against the SKILL.md

- **Step 1 Initialize** — `knowledge/` did not exist → created with `index.md`. The four starter
  files were *offered*; three recorded `simulated: declined` (shared contract rule 3,
  non-interactive), `business-rules.md` created because a real payload existed. Empty stubs were
  deliberately not created: an index row pointing at an empty file satisfies the letter of the
  index rule while making the base look richer than it is.
- **Step 2 Enrich** — index checked for the right target file (base empty → `business-rules.md`);
  duplicate/contradiction check run and found nothing to contradict, so **no ⚠ VALIDATION
  arbitration was triggered and none was simulated**; entries written with provenance; index
  updated; size budget re-checked after writing (983 approx. tokens, under the ~2k budget, no
  split needed).
- **Step 3 Report** — this file.

## Suggested commit message (not executed — SKILL.md L23 "Do not run git commands yourself")

```
knowledge: seed cart stock-gating and USD display rules from US-EVAL-009
```

## Format verification (actually executed, not asserted)

```
python eval/skill-coverage-wave-2026-07-30/C-knowledge/evidence/verify_knowledge_format.py
```

Output: `evidence/verify_knowledge_format.out.txt`. This run's base → **PASS** on all five
checks (index present; every file indexed; every index row resolves; both files under the ~2k
token budget; provenance line count equals rule-entry count). The identical checks were run
against `examples/rag-demo/knowledge/` and `examples/carpool-demo/knowledge/` and also pass, so
the checks are not calibrated to only accept this run's output.

## Pending human review

- 3 × `simulated: declined` starter-file offers (glossary, application-map, anomaly-history).
- `BR-KB-001`'s `[open]` extension to checkout gating — must **not** be resolved by an agent;
  the test book already carries the "allow" branch as an explicitly-labelled proposed default.
- The `decided-by` field of both entries is `[open]`: these are observed live-UI behaviours, not
  decisions taken by a named role. See the skill-defect note in the wave report.
