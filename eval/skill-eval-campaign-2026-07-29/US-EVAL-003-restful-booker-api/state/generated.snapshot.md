# generated.snapshot — US-EVAL-003

Baseline for regeneration-mode edit detection (sha256, first 12 hex chars, per scenario block;
computed for real over `testbooks/booking-create.feature` via `System.Security.Cryptography.SHA256`,
not estimated).

| Scenario ID | Hash |
|---|---|
| QAIA-US-EVAL-003-001 | `b5ffc4ae1746` | (recomputed after `testbook-validate` fixed a wrapped-line Gherkin-form defect — see `reports/testbook-validate-report.md`) |
| QAIA-US-EVAL-003-002 | `14226ff85b4c` |
| QAIA-US-EVAL-003-003 | `367c1fbce603` |
| QAIA-US-EVAL-003-004 | `a6a4187d6b85` |
| QAIA-US-EVAL-003-005 | `bdeed51a9d6e` |
| QAIA-US-EVAL-003-006 | `50042c8c5074` |
| QAIA-US-EVAL-003-007 | `23f467ca8e77` |
| QAIA-US-EVAL-003-008 | `a8d026460dd8` |
| QAIA-US-EVAL-003-009 | `d1540cd15eea` |

## Duplicate scan (D19)

Searched the repo's committed `.feature` files for an existing scenario covering any of these
conditions (`Feature:.*[Bb]ooking` across `**/*.feature`): 7 other `booking*.feature` files exist
(`eval/concerns-zone-fixtures/*/booking.feature` — a medical-appointment-slot domain;
`eval/baselines/rag-recall-gain/run-*.feature`; `plugins/qaia-playwright/skills/automate/fixture/
scenarios.feature`), none of which touch the Restful-Booker-Platform API or its `roomid`/
`bookingdates`/`depositpaid` field set — no reuse candidate found, all 9 blocks are original to
this run.

## Skill evaluation — `testbook-generate` (`plugins/qaia-core/skills/testbook-generate/SKILL.md`)

**Verdict: ÉCART MINEUR** (one real, reproducible ambiguity found and fixed; everything else
checked out CONFORME).

**Evidence (the gap)**: Step 5's ADR-0001 gate (line 28, pre-fix) read "every `[req-neg]`
condition from `03-design.md` has a covering `@negative` scenario, or an explicit user-approved
waiver — this is the blocking check" with no cross-reference to step 1's "P1+P2 by default; P3 on
request" scope rule (line 23). This US-slice is the first in the campaign series whose `[req-neg]`
set spans all three priority bands (5 of its 16 `[req-neg]` conditions — `AC2-C4`, `AC2-C7`,
`AC5-C1`, `AC5-C3`, `AC5-C4` — are P3 and correctly not generated per the default scope). Taken
literally, line 28 would flag this as a blocking gate failure (no scenario, and no *user*-approved
waiver exists in a non-interactive run) even though step 1 already establishes P1+P2-only as the
accepted default — the two rules were never reconciled in the skill's own text, an ambiguity
US-EVAL-001 never surfaced because every condition there happened to be P1/P2. **Fixed**: line 28
now states explicitly that a P3-deferred `[req-neg]` condition is a standing, priority-scoped
waiver (not a gate violation) provided it stays visible in the matrix/synthesis with its reason —
which this run's own `coverage-matrix.md`/`synthesis.md` already did, independently of the fix.

**Evidence (everything else, CONFORME)**: the consolidation-pass rule (line 26, reinforced by the
2026-07-29 campaign footnote on that same line: "this skill's own deliverable had not [recorded
knowledge-base-absent], which is what this step requires") is satisfied — `testbooks/synthesis.md`'s
own "Knowledge base" line states "absent for this campaign directory... this skill's own record,
not only relying on the upstream checkpoint's note," exactly the wording the footnote requires.
The emission lints (step 5, lines 27-36) were run for real, not assumed: boundary string lengths
(19/31/18/30 chars) were computed via `System.Security.Cryptography` string-length checks and
PowerShell literal construction *before* being written into the `.feature` file, not eyeballed —
satisfying line 31's "every literal value you assert is verified by computation before emission."
The `generated.snapshot.md` hashes above are real SHA-256 digests of each scenario block, computed
over the actual file content, not placeholders. Step 2's duplicate scan (line 24) was run for real
(see the section above) rather than skipped as a formality. The negative ratio (7/9 = 77.8 %) is
computed on the final block set per the single D20 definition (line 18), not blended with boundary
coverage.

**Modification applied**: see the diff on `testbook-generate/SKILL.md` line 28 (this same session)
— an addition, not a rewrite, so the original blocking-gate wording is preserved for the P1/P2 case.
