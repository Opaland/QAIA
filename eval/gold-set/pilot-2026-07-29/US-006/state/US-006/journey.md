---
stepsCompleted: [00-ingest, 01-review, 02-understanding, 03-design, 04-priorities, 05-generate, 06-report, 07-export, 08-validate, 09-feedback]
lastStep: 09-feedback
lastSaved: 2026-07-29
---

# Journey ledger — US-006

Mode: **non-interactive pilot run** (validation campaign). Every `⚠ VALIDATION` checkpoint below
is recorded as `simulated: accepted-as-is` per the project's documented convention for unattended
runs (shared contract rule 3). `base` for this run is
`eval/gold-set/pilot-2026-07-29/US-006/` (rule 9) — not the default `.qaia/` — because the
harness designated this working directory explicitly.

| Step | Status | Notes |
|---|---|---|
| 00-ingest | done | Source: `eval/gold-set/US-006-post-visibility-acl.md` (local file, read in full — 43 lines, well under the ~20k-token split threshold). No PII/sensitive data found (no real names, IDs, cards, health data) — redaction step ran, 0 items masked. No abuse/illegality framing. Not a non-spec (clear US + 6 numbered AC). US-ID set to `US-006` (tracker-style key already present in filename/heading). ⚠ VALIDATION (US-ID confirm): `simulated: accepted-as-is`. ⚠ VALIDATION (capture confirm): `simulated: accepted-as-is`. |
| 01-review | done | Extraction structured into story + 6 AC + notes on referenced-but-undefined terms. ⚠ VALIDATION (extraction confirm): `simulated: accepted-as-is`. |
| 02-understanding | done | Reformulation + 10 numbered questions (Q1-Q10), classified per the decision tree: 2 `[open]` (Q1, Q9), 8 `[assumption]`. ⚠ VALIDATION (per-question disposition): `simulated: accepted-as-is` for all 10 — each assumption's proposed safe default applied, opens left open. |
| 03-design | done | AC1-AC6 mapped to ISTQB techniques (black-box palette). 31 conditions derived (`AC<n>-C<m>`), 16 tagged `[req-neg]`. Knowledge base: **absent** (fresh pilot, no `.qaia/knowledge/` in the repo) — recorded per degraded-mode rule 8, proceeded on the source alone; `design.knowledgeApplied` will be empty. `oracle-generate` was invoked (see below) and found no applicable standardized domain. ⚠ VALIDATION (technique map): `simulated: accepted-as-is`. |
| oracle-generate (ad hoc, folded into 03-design) | done | Detected candidate domains: email address (AC4) and HTTP-style access outcomes (AC2/AC5). Conclusion: AC4's email is an **exposure** field, not a **format-validation** field — RFC 5322 oracle does not apply (US never asks "is this email syntactically valid"). No API/OpenAPI contract was designated by the user, so no project oracle. No card/date/IBAN/currency domain present. Recorded: **no oracle applied** — `design.oracles = []`. This is a documented "not applicable" outcome, not a skipped step. |
| 04-priorities | done | 31 conditions scored impact x probability, consolidated into 25 rationale rows (some rows merge same-priority/same-confidence conditions); 22 rows -> P1/P2 (generation scope), 3 rows -> P3 (impact/probability low, out of default scope), rest folded into merged Outline rows. Rationale table in `04-priorities.md`, copied into the coverage matrix per the deliverable rule (rubric dim. 9). ⚠ VALIDATION (score adjustment): `simulated: accepted-as-is` — no human override recorded (no arbitration this pilot pass); every `[assumption]`/`[open]`-driven score is flagged in the table as the rule requires. |
| 05-generate (testbook-generate) | done | Scope confirmed P1+P2 (default), P3 waived and listed (3 conditions: AC2-C1 "anonymous views a published post", AC2-C7 "anonymous creates a draft in public mode", AC6-C1 "user deletes own uploaded media" — all low risk/low complexity baselines). ⚠ VALIDATION (scope): `simulated: accepted-as-is` (P1+P2 default). Duplicate scan: no prior `.feature` files existed anywhere in this fresh pilot tree — nothing to reuse. 23 scenario blocks written (22 atomic + 1 `@smoke` journey), all self-checks (atomicity, one-`When`, negative-path gate, Background invariants, ID continuity, literal verification) passed — see `testbooks/US-006/synthesis.md`. `state/US-006/generated.snapshot.md` written. ⚠ VALIDATION (synthesis review): `simulated: accepted-as-is`. |
| 06-report | done | `.qaia`-shaped `reports/US-006/manifest.json` projected from the artifacts above (counts computed from the actual `.feature` file, not estimated). |
| 07-export (testbook-export) | done | Deliverables: `.feature` (source of truth, already written), `synthesis.md` (already the review aid), CSV export in `testbooks/US-006/export/` (scenarios.csv, decisions.csv) as the file-tooling fallback for the XLSX deliverable — this environment has no spreadsheet library available, so CSV blocks were produced instead and the user is told so plainly, per the skill's own fallback clause. No Xray/TestRail export requested (opt-in, not applicable). |
| 08-validate (testbook-validate) | done | Self-audit of the generated book: ran `eval/tools/structural_score.py` for real (not estimated). First run forced a structural FAIL (one genuinely vague `Then` on scenario 005); fixed in the source `.feature` (and two related "absent"->"not present" rewordings on 007/009), re-ran, now `CONCERNS` (score 75, no forced stop). 8-dimension manual checklist: 15/16, no dimension < 1. Combined verdict **CONCERNS** (structural pass is the stricter gate). Full report: `testbooks/US-006/validation-report.md`. This is QAIA auditing its own output, so it is read as a self-check, not an independent gate — `gate.verdict` in the manifest is intentionally left unset (rule: no producer self-scores; that requires a separate `qaia-score` plugin not exercised in this pilot). |
| 09-feedback | done, nothing to process | No human review loop occurred in this non-interactive pilot (no corrections were made against the generated book — this is a first, unedited pass). Feedback skill's prerequisite (a generated book) was met, but step 1 ("collect what the user changed") had nothing to diff: no `.qaia/feedback/examples/` entries were written, no promotions proposed. Recorded here rather than silently skipped. |

## Deviations from the book (see also final report to the requester)

1. **Output root.** All paths are re-based under `eval/gold-set/pilot-2026-07-29/US-006/`
   instead of the default `.qaia/`, per rule 9 (the harness designated this directory). The
   internal structure (`state/<US-ID>/`, `testbooks/<US-ID>/`, `reports/<US-ID>/`) is preserved
   as-is under that root.
2. **rag-build skipped.** No `.qaia/knowledge/` exists anywhere in this repo checkout for this
   pilot context, and rag-build's knowledge base is explicitly a **team-shared, git-versioned**
   artifact (`../README.md`), not a per-US scratch file. Seeding one nested inside a single-US
   pilot folder would misrepresent it as project-wide knowledge when it is really one run's
   candidate rules. Candidate reusable rules surfaced during design (e.g. "media with no
   identified owner can only be deleted by an admin") are listed in `03-design.md` /
   `04-priorities.md` as `[assumption]`s with a note that they would be good `rag-build`
   candidates on a real project, but no `knowledge/*.md` file was created.
3. **feedback ran with nothing to collect** — see table row above.
4. **No `execution` or `gate` section in the manifest** — no automated run (`qaia-playwright`)
   and no scoring plugin (`qaia-score`) were exercised; both are correctly absent per the
   contract's degraded-mode rule, not an error.
