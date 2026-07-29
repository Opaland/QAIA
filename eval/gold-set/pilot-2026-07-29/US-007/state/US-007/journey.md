---
stepsCompleted: [00-ingest, 01-review, 02-understanding, rag-build, 03-design, oracle-generate, prioritize, testbook-generate, report, testbook-export, testbook-validate, feedback]
lastStep: feedback
lastSaved: 2026-07-29
---

# journey — US-007 (Paid course enrolment)

**Output root (rebased, shared-contract rule 9):** `eval/gold-set/pilot-2026-07-29/US-007/` replaces `.qaia/` for this pilot run — a validation-campaign harness designated this directory instead of the project default. All paths in this ledger are relative to that base.

**Execution mode:** non-interactive (evaluation harness / pilot run). Every `⚠ VALIDATION` point across every step below was recorded as `simulated: accepted-as-is` — none reflects an actual human decision. This ledger and `manifest.json`'s `openArbitrations` are the authoritative list of what still needs a human pass.

**Source contamination check:** only `eval/gold-set/US-007-course-fee-enrolment.md` was read as requirements input. `eval/gold-set/oracle-2026-07-29/moodle-fee-raw.feature` and its README were never opened at any point in this run.

## Step ledger

| Step | Status | Notes |
|---|---|---|
| `00-ingest` | done | Gates: none fired. Redaction: none needed. US-ID `US-007` confirmed (simulated). See `00-source.md`. |
| `01-review` | done | 5 ACs extracted, 2 business rules found outside the AC list, 6 "not found" items listed. Confirmed (simulated). See `01-extraction.md`. |
| `02-understanding` (need-understanding) | done | 10 questions logged (Q1-Q10): 2 answered, 6 assumptions, 1 open, 1 out-of-slice. All accepted (simulated). See `02-understanding.md`. |
| `rag-build` | done | Knowledge base was absent; initialized under `knowledge/` with `index.md` + `business-rules.md`, seeding `BR-KB-001..003` from this run's answered questions. |
| `03-design` (istqb-design) | done | AC->technique map + 30 conditions derived (11 tagged `[req-neg]`), citing `BR-KB-001..003`. Approved (simulated). See `03-design.md`. |
| `oracle-generate` | done (folded into 03-design/testbook-generate) | ISO 4217 oracle applied to AC1 currency/fee-precision conditions (004, 005); no other standardized domain detected in this US (no card/date/email/HTTP-API/IBAN shape). Accepted (simulated). |
| `prioritize` | done | 30 conditions scored impact x probability -> 11 P1 / 9 P2 / 10 P3. No target-repo path was named, so the optional git-history signal was skipped (not defaulted, not scored). Accepted (simulated). See `04-priorities.md`. |
| `testbook-generate` | done | 31 scenarios (30 atomic + 1 `@smoke`) across 4 `.feature` files. Emission lints applied (including a corrective pass adding a missing mandatory technique tag to 8 scenarios before the snapshot was taken). Negative-path gate 11/11. Presented and accepted (simulated). See `testbooks/US-007/`. |
| `report` | done | `reports/US-007/manifest.json` written, contract 1.0. `gate` left `null` — no producer self-scores (qaia-score was not run in this pilot; scope was the qaia-core journey). |
| `testbook-export` | done | All three default deliverables produced under `testbooks/US-007/export/`: `.feature` files are the same source-of-truth files (not copied, referenced in place per D25 "already the source of truth"), `synthesis.md` re-projection, and CSV projections (`scenarios.csv`, `coverage-matrix.csv`, `decisions-and-assumptions.csv`) in place of an XLSX workbook — no spreadsheet-building tool was available in this session, so CSV blocks were produced and this substitution is stated plainly per the skill's own fallback. Xray/TestRail export not requested (opt-in, no test-management tool named) — skipped, not fabricated. |
| `testbook-validate` | done | Structural pass 98/100, no forced STOP. Checklist 16/16 -> **PASS**. See `reports/US-007/testbook-validate-report.md`. |
| `feedback` | done (no corrections to capture) | This pilot run is fully non-interactive: no human ever edited or rejected a scenario, so there is nothing to diff or classify. No `feedback/examples/` entry was fabricated to simulate a correction that did not happen — the honest outcome of this step is "no corrections available in this run", recorded here rather than invented. The 7 `@low-confidence` scenarios and the 2 open questions (Q3, Q10) remain the natural targets for a first real human feedback pass. |

## Deviations / improvisations from the book (for the human reviewer)

1. **Output root rebase.** Per shared-contract rule 9, the entire `.qaia/` layout (`state/`, `knowledge/`, `testbooks/`, `feedback/`, `reports/`) was rebased under `eval/gold-set/pilot-2026-07-29/US-007/` instead of the project's `.qaia/` default, as instructed for this pilot.
2. **`oracle-generate` folded in rather than run as a separately checkpointed pass.** Only one standardized domain (ISO 4217 currency) applied to this US; its two derived conditions/scenarios are recorded directly in `03-design.md`/the feature file rather than a separate oracle checkpoint file, since the skill has no dedicated checkpoint of its own beyond feeding `03-design.md` and the generated scenarios.
3. **XLSX -> CSV substitution in `testbook-export`,** per that skill's own documented fallback for surfaces without spreadsheet tooling.
4. **A mid-generation emission-lint correction**: the first draft of 8 scenarios (004, 013, 015, 016, 018, 021, 022, 023) was missing the mandatory single closed-list technique tag; caught by the generation rules' own self-check (`testbook-generate` step 5) before the snapshot/synthesis were finalized, and fixed within this same pass.
5. **`qaia-score` (gate scoring) was not run** — it is a separate plugin per the shared contract ("no producer scores itself"); this pilot's scope was the qaia-core journey through `feedback`, so `manifest.json`'s `gate` field is left `null` rather than fabricated.

## Not run

- No Jira/URL connector — the source was a local file, read directly.
- No project-oracle (OpenAPI/JSON Schema) — none was designated and none is implied by this US (no API contract described).
