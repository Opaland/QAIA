# CONCERNS-zone calibration (issue #21, follow-up to #17)

`eval/baselines/score-calibration.md` (#17) proved `qaia-score` discriminates cleanly on n=3
with no mid-zone book (good=18/PASS, bad=2/FAIL) and flagged two open gaps: no CONCERNS-band
book (~11-14/20) tested, and near-threshold (~15-16) stability not demonstrated. This session
builds 4 deliberately medium-quality test books derived from the same gold-set US (US-001,
`eval/gold-set/US-001-appointment-booking.md`) and scores each **3 times independently** to
measure whether the verdict (PASS/CONCERNS/FAIL) is stable under LLM-judge noise, or flips.

## Method

- **Fixtures**: `eval/concerns-zone-fixtures/{m1,m2,m3,m4}-*/` — each a `booking.feature` +
  `synthesis.md` + `coverage-matrix.md` built by hand against the shared
  `eval/concerns-zone-fixtures/00-source.md` (US-001, judge-reference planted-ambiguities
  section stripped, exactly as the real skill would receive it). Defects are **deliberately
  planted and listed below**, not organic — these are fixtures for this calibration, same
  status as `eval/goldset-hardened/`.
- **Independence**: per the project's release ritual (`eval/README.md`, D6 — "3 independent
  runs... fresh session, no context from the generation session"), each of the 12 scoring runs
  is a **separate subagent invocation** (`general-purpose`, no shared memory), given only the 4
  artifact files and the rubric text inline, explicitly told not to read any other repository
  file (no peeking at intended scores, other fixtures, or baseline docs). This is the closest
  reachable approximation of "3 independent judges" inside one Claude Code session.
- **Deviation from the full `testbook-score` procedure**: step 0 (deterministic structural pass)
  was **skipped on purpose** — it is scripted/reproducible by construction
  (`eval/baselines/structural-score.md` already proved it deterministic) and not where judge
  *noise* lives. This experiment isolates the LLM-rubric steps (1-4) and the `aptitude-gate`
  verdict rules, which is where #17 identified the open question. No manifest/report step was
  run either (no `.qaia/` scaffolding in this worktree) — each judge was hand-fed the rubric
  text and verdict rules inline instead of loading the skill files, to guarantee every run saw
  byte-identical instructions.

## Fixtures and their deliberate defects

All derived from US-001 (8 AC: specialty filter, ≥2h booking window, ≤3 upcoming appointments,
race-condition handling, confirmation content, ≥4h cancellation window, minors/guardian,
audit trail).

| Fixture | Intent | Deliberate defects |
|---|---|---|
| **M1** — `m1-partial-coverage` | mid-CONCERNS (~11-14 target) | AC7 (minors) entirely absent; AC3's "4th appointment refused" negative missing; 2/10 scenarios untagged; 1/10 scenario chains 2 `When`s; generic "important" rationale on every matrix row; no confidence marking; silently-resolved timezone assumption |
| **M2** — `m2-borderline-pass` | near PASS/CONCERNS boundary (~15-16 target) | full AC list present but AC8's cancellation-audit case missing (matrix-documented gap); AC7's guardian-missing edge case silently assumed away, not flagged; one scenario ID mismatch between `.feature` (`@QAIA-US-001-100`) and matrix (`@QAIA-US-001-010`); generic "standard case"/"important case" rationale; no confidence marking |
| **M3** — `m3-negative-gap` | CONCERNS/FAIL boundary stress test | AC3's **and** AC6's required-negative conditions both missing (2 of 5); AC5's connection-link field never asserted; 3/10 scenarios untagged; 1/10 scenario chains 2 `When`s; generic rationale; no confidence marking |
| **M4** — `m4-near-threshold` | PASS/CONCERNS boundary, added mid-session after M1-M3 all missed it (see below) | full AC coverage, full negative coverage, all IDs clean/sequential/matrix-consistent, atomic scenarios — only the "soft" dimensions degraded: generic "standard case" rationale everywhere, no confidence marking, silently-resolved timezone-conversion detail in AC5, invented (unspecified) refusal-message wording in 3 scenarios |

**Design note, reported honestly**: M1 and M3 were meant to test the CONCERNS/FAIL boundary via
an *ambiguous* count of missing required negatives (1 vs "several"). They did not land there —
dropping AC7 entirely (M1) turns out to also remove AC7's implicit required negative
(unauthorized-practitioner refusal), so M1 actually had **2** missing negatives, not 1 as
intended; M3's 2 missing negatives were read unanimously as "several" (score 0) by every judge,
not treated as a boundary case. M2 also undershot its ~15-16 target, landing at 13-14, because
judges independently found a legitimate AC8 half-coverage gap and (once) an unflagged-message
issue I had not accounted for. **M4 was added specifically to recover the untested PASS/16
boundary** after M1-M3 all missed it — see results.

## Results — 3 independent runs per fixture

| Fixture | Run 1 | Run 2 | Run 3 | Total spread | Verdict across runs |
|---|---|---|---|---|---|
| M1 | 11/20, dim3=0, **FAIL** | 12/20, dim3=0, **FAIL** | 10/20, dim3=0, **FAIL** | 10-12 (Δ2) | **FAIL / FAIL / FAIL** — stable |
| M2 | 13/20, no 0-dim, **CONCERNS** | 14/20, no 0-dim, **CONCERNS** | 14/20, no 0-dim, **CONCERNS** | 13-14 (Δ1) | **CONCERNS / CONCERNS / CONCERNS** — stable |
| M3 | 10/20, dim3=0, **FAIL** | 10/20, dim3=0, **FAIL** | 12/20, dim3=0, **FAIL** | 10-12 (Δ2) | **FAIL / FAIL / FAIL** — stable |
| M4 | 16/20, no 0-dim, **PASS** | 16/20 *(stated)*, no 0-dim, **PASS** | 16/20, no 0-dim, **PASS** | 16 (stated) | **PASS / PASS / PASS** — stable *(but see finding below)* |

All 3 judges agreed on every dimension for M1 and M3 (dim3=0, unanimous — "several required
negatives uncovered" was applied consistently, not treated as ambiguous in practice). All 3
agreed on the verdict for M2 despite a 1-point total spread (13 vs 14) because that spread
never crosses the 16-point line. M4's raw dimension tables from the three runs:

| Dim | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | **Sum (recomputed)** | **Stated total** |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| M4 run 1 | 2 | 2 | 2 | 1 | 2 | 1 | 2 | 2 | 1 | 1 | **16** | 16 ✅ |
| M4 run 2 | 2 | 2 | 2 | 1 | **1** | 1 | 2 | 2 | 1 | 1 | **15** | **16 ❌ (arithmetic error)** |
| M4 run 3 | 2 | 2 | 2 | 1 | 2 | 1 | 2 | 2 | 1 | 1 | **16** | 16 ✅ |

## Key finding — the boundary is fragile, and for two compounding reasons

1. **Real rubric-application noise exists exactly at the dimension level that determines the
   boundary.** Runs 1 and 3 scored dimension 5 (business correctness) at 2 ("no scenario
   contradicts the US"); run 2 scored it 1 ("`002`/`005`/`011` assert specific refusal message
   text the AC never specifies — an unflagged extrapolation"). This is a legitimate, defensible
   reading each time — the fixture genuinely sits on that line — and it alone moves the
   **correct** total between 15 and 16, i.e. across the PASS/CONCERNS threshold.
2. **A judge made an arithmetic error, and it landed exactly on the boundary.** Run 2's own
   listed dimension scores sum to 15, not the 16 it reported and used for its verdict. Recomputed
   correctly, run 2 is **CONCERNS (15/20)**, not PASS. So the *true* verdict spread across the 3
   independent runs at this boundary is **PASS / CONCERNS / PASS — an actual flip**, masked in
   the raw output only because the judge's summation happened to be wrong in the direction that
   hid it.

Point 2 is the more actionable finding: **the project's own manifest contract makes this error
unrecoverable downstream.** `testbook-score`'s step 5 writes only `score` (the total) and
`dimensions` **"listing only the dimensions scored below 2"** into the manifest `gate` block —
the seven dimensions scored 2 are not recorded. `aptitude-gate` then reads that `score` field
directly (`aptitude-gate/SKILL.md` step 1: "Read the manifest — ... `gate.score`/`dimensions`")
and applies the `total >= 16` rule to it. **Nothing downstream can recompute or audit the total
independently, because the inputs to that sum are not all preserved.** This is the same failure
mode `testbook-score`'s own guardrails warn against elsewhere ("Verify literals independently...
recompute, do not trust the book's own assertion" — rubric.md step 3) applied to the rubric's
own arithmetic, which this experiment shows is not immune to LLM error even in a simple 10-term
sum.

## Honest caveats

- **n=3 per fixture, n=4 fixtures** — still a small sample; this narrows but does not close the
  gap #17 left open. A larger sweep (more fixtures at exactly 15/16, other gold-set US, other
  models) would strengthen this further.
- **Fixture construction is imperfect evidence of its own target.** M1/M3 missed their intended
  "ambiguous negative count" test (see design note above) — real LLM judges are more thorough
  than my hand-authored defect list anticipated (e.g., independently catching AC8's half-coverage
  gap in M2, or the unflagged message-text extrapolation in M4 run 2), which is itself a mildly
  reassuring signal about judge diligence, but it means the CONCERNS/FAIL boundary was tested
  less precisely than planned (M1/M3 landed as clear FAILs via dim3=0, not close calls).
- **The arithmetic-error finding is n=1** (1 error in 12 runs = 4 dimension-tables × 3 runs each,
  40 individual dimension scores checked, 1 total-sum mismatch). It is not a claim that LLM
  judges routinely miscompute sums — only that it happened once, here, and that once was enough
  to flip a boundary verdict, which is exactly the kind of low-probability-but-consequential
  failure a threshold-sensitive gate should be hardened against regardless of its rate.
- **This session used one model family (the harness's own judge) for all 12 runs** — no
  cross-model comparison was attempted here (see `eval/baselines/second-judge.md` /
  `multimodel-skill-sweep.md` for that separate axis); this calibration is about **repeat-run**
  noise within one judge, not **cross-model** noise.

## Verdict: **partially stable**

- **Away from the 16-point boundary, the verdict is stable.** Solid-CONCERNS (M2, 13-14/20) and
  clear-FAIL-via-hard-gate (M1, M3, dim3=0) both reproduced the same verdict across all 3
  independent runs, with total-score spread of only 1-2 points that never crossed a decision
  boundary. This is good news and extends #17's finding into the mid-quality zone.
- **At the 16-point PASS/CONCERNS boundary specifically, the verdict is not demonstrated
  stable.** The three raw judge outputs all *reported* PASS, but one run's own dimension table
  sums to 15 (CONCERNS) — its reported PASS was a transcription/arithmetic error, not a genuine
  third independent PASS judgment. Correcting for that, the real result at this boundary is
  **PASS/CONCERNS/PASS**, i.e. an observed flip. Compounding this, dimension 5 alone showed
  legitimate 2-vs-1 disagreement across runs, which independently would have been enough to
  produce the same flip even with correct arithmetic.
- **Recommendation** (advice only — no skill file changed here, per this session's scope): before
  treating a `testbook-score` total as reliable input to a `total >= 16` gate decision,
  `aptitude-gate` (or `testbook-score` itself, before writing the manifest) should **recompute
  the total by summing all 10 individual dimension scores rather than trust the self-reported
  sum** — which requires the manifest to retain all 10 scores, not only those below 2. This is a
  direct extension of the project's existing "recompute, don't trust the book's own assertion"
  guardrail to the rubric's own total.
