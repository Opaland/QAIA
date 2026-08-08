---
name: flaky-detect
description: Detect tests whose pass/fail verdict varies across repeated runs of unchanged code (flaky tests), from the JUnit XML / Cucumber JSON that run-report already produces. Flags with evidence only - never retries, quarantines, or fixes automatically. Use after collecting 3+ runs of the same suite.
---

# flaky-detect — flaky test detection from repeated runs

A test whose verdict flips between runs of unchanged code destroys the signal value of the whole
suite: every red becomes negotiable, and a real regression hides behind "just re-run it". This
skill names those tests with evidence, and stops there — it never retries, quarantines or fixes.

The defect class is not hypothetical: QAIA's own automation has hit it (shared mutable state
raced by parallel workers). For the provenance and the audited evidence trail, see
`references/origin.md` — not needed to run the skill.

Reference fixture: `fixture/` in this skill folder — a minimal, self-contained Playwright
suite against a shared-state server, deliberately timing-dependent (not "always fails"),
whose 5 captured real runs (`fixture/runs/results-run{1..5}.xml`) show genuine pass/fail
variance per test with **zero code changes between runs**. See `fixture/VALIDATION.md` for
the worked example of this skill applied to that data.

## Input

- **N ≥ 3 runs** (recommended) of the **same test code**, same suite, in the formats
  `run-report` already produces: JUnit XML and/or Cucumber JSON. 2 runs is the visible floor —
  enough to see *a* difference, never enough to trust it isn't a one-off. **1 run can never
  show flakiness at all**: a single green run only proves "passed this once," never "is
  stable" — say so rather than implying otherwise.
- The runs must span **no code change to the test or the SUT** between them — that is what
  isolates "verdict varies for the same code" (flaky) from "verdict changed because the code
  changed" (a real regression or a real fix). If the input gives no way to confirm this (e.g.,
  runs pulled from CI history with no commit SHA attached), say so explicitly as an assumption
  rather than silently trusting it.

## Method

1. Parse each run's JUnit XML/Cucumber JSON; key every test by its stable identifier — the
   `@QAIA-*` tag embedded in the test title (the `automate`/`run-report` convention), else the
   JUnit `classname`+`name` pair.
2. For each test key, build the ordered list of verdicts across the N runs (`pass`/`fail`/
   `skipped`/`blocked`).
3. Flag a test **flaky** only if its verdict set contains **both** `pass` and `fail` across the
   runs. A test that fails every run is a real failure, not flaky — report it separately, never
   under `flakiness`. A test that passes every run is (provisionally) stable, not flagged.
4. For each flagged test, record: the full verdict sequence, which run index(es) failed, the
   pass rate (`k of N`), and the failure message/assertion text from a failing run's report
   when the format carries one (JUnit `<failure message>`, Cucumber JSON error text).

## Output

- A findings table (Markdown) plus the same data as JSON: test ID, pass rate, failing run
  indices, a failure excerpt where available.
- **Merge into `.qaia/reports/<US-ID>/manifest.json`** in a dedicated `flakiness` section —
  never touching `execution`, `design`, `gate`, or `status` (shared output contract,
  `../../OUTPUT-CONTRACT.md`, rule 2 — merge, never clobber). Load the
  existing manifest, replace only `flakiness`, append this skill to `producers[]`, add the
  findings file to `artifacts[]`. If no manifest exists yet, create one with just the shared
  header + `flakiness` (mirrors `run-report`'s own bootstrap behavior).

  ```jsonc
  // Real output from fixture/, not a hypothetical - see fixture/output/manifest-after.json
  "flakiness": {
    "runsAnalyzed": 5,
    "codeChangeControlled": true,          // false/"unknown" if not confirmed - see Guardrails
    "flaky": [
      { "testId": "@QAIA-FLAKY-DEMO-001", "verdicts": ["fail","fail","pass","pass","fail"],
        "passRate": "2/5", "failedRuns": [1, 2, 5],
        "failureExcerpt": "Expected: 2, Received: 3 (run 1)" }
    ],
    "allPassNoFlakinessObserved": ["@QAIA-FLAKY-DEMO-004"],  // ran clean 5/5 - not proof of stability, see Guardrails
    "consistentFailures": ["@QAIA-FLAKY-DEMO-005"]           // fails every run - a real bug, not flaky; reported, never merged into `flaky`
  }
  ```

- Never a `gate` verdict — this skill only surfaces evidence, consistent with contract rule 3
  (no producer scores itself); `qaia-score` may later read `flakiness.flaky.length` as a
  signal, but does not get it from here.

## Steps

1. Collect the run artifacts (paths to N JUnit XML and/or Cucumber JSON files) from the user,
   or from a kept run history under `.qaia/reports/<US-ID>/` if the project archives one.
2. Apply the Method above; produce the findings table and JSON.
3. Merge `flakiness` into the manifest as described.
4. Report findings plainly — **no auto-fix, no auto-retry, no auto-quarantine**. The skill's
   entire output is "here is the evidence"; a human (or a separately, explicitly invoked
   change) decides what to do — fix the underlying race/timing issue, quarantine the test, or
   accept the risk. Same "AI proposes, human arbitrates" posture as the rest of the product
   (mirrors `perf-check`'s measured-not-asserted numbers and `automate`'s traceable findings).
   A likely-cause hint (e.g. "shared mutable state + parallel workers — see the `workers: 1`
   pattern in `examples/medibook`") is fine to surface; changing test code or CI config is not
   this skill's job.

## Guardrails

- **Never auto-retry, auto-quarantine, or auto-fix.** Flag-only, with proof.
- **Honesty over false confidence** (honest recall beats fabricated recall): a test with all-pass verdicts across N runs is
  reported as "no flakiness observed in N runs," never as "stable" or "not flaky" — absence of
  evidence is not evidence of absence, especially at low N. Recommend N≥5 before treating a
  clean streak as reassuring, and never claim more than the runs actually show.
- **The no-code-change assumption is a real limitation, not hidden**: if the skill cannot
  confirm the N runs share identical test/SUT code, it says so in the output (`
  codeChangeControlled: false` or `"unknown"`) rather than presenting the flakiness list as
  certain.
- Never fabricate a run that was not provided; N runs in, N runs counted — no interpolation,
  no synthesizing a plausible-looking 4th run to round out a pattern.
- **Distinguish flaky (pass/fail variance, same code) from a fixed bug** (all-fail, then
  all-pass only after a real code change) — conflating the two would misdirect a human away
  from a genuine regression fix and toward chasing a race that was never there.
- Blocked/skipped verdicts are carried in the verdict sequence but never silently folded into
  either `pass` or `fail` — an accurate sequence beats a simplified one.
