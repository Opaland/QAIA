# flaky-detect validation — real run, real data (2026-07-25)

Honest record of validating `../SKILL.md` against a purpose-built, self-contained fixture
(no dependency on `examples/medibook` or `examples/expense-demo` beyond reusing their
documented bug class: shared mutable server state raced by parallel test workers).

## What was built

- `server.js` — a Node `http` server holding one shared in-memory array (`items`), with
  `/reset`, `/items` (push, with a small random delay), `/count`.
- `flaky.spec.js` — 5 Playwright tests:
  - `@QAIA-FLAKY-DEMO-001..003`: reset, push twice, assert count is 2 — each preceded by a
    random 0-400ms start jitter, run with `workers: 3` / `fullyParallel: true` against the
    **same** server process (no isolation) — the inverse of the `workers: 1` fix documented in
    `examples/medibook/tests/playwright.config.js`.
  - `@QAIA-FLAKY-DEMO-004`: a trivial, non-timing-dependent assertion that always passes —
    a **stable control**.
  - `@QAIA-FLAKY-DEMO-005`: a trivial, non-timing-dependent assertion that always fails — a
    **consistent-failure control** (a real bug, the thing flaky-detect must NOT call flaky).
- `playwright.config.js` — `workers: 3`, `fullyParallel: true`, JUnit reporter to
  `results.xml`, `webServer` auto-starting `server.js`.

## What was actually run

The exact same fixture directory (zero edits) was executed **5 times in a row** with
`npx playwright test`, saving each run's `results.xml` to `runs/results-run{1..5}.xml`. Tuning
note, reported honestly: the first attempt (8 tests, `workers: 6`, small delay, no start
jitter) **saturated to "all fail every run"** — that is a real bug demonstration, not flakiness
(a verdict that never varies carries no flaky signal). It took two rounds of tuning (fewer
concurrent tests, then a wide 0-400ms start jitter) to reach a regime where the **same
unmodified code produces a genuinely different pass/fail pattern each run** — the actual
target signature for this skill. That tuning difficulty is itself informative: real flaky
tests likely sit in a similarly narrow "sometimes collides" band, which is exactly why a
single run (or even 2) is not enough to trust — see `SKILL.md`'s N≥3 recommendation.

## Ground truth (read directly from the 5 captured JUnit files, not summarized secondhand)

| Test | Run1 | Run2 | Run3 | Run4 | Run5 | Verdict |
|---|---|---|---|---|---|---|
| DEMO-001 | fail (Recv 3) | fail (Recv 4) | pass | pass | fail (Recv 3) | **flaky**, 2/5 pass |
| DEMO-002 | pass | fail (Recv 4) | fail (Recv 4) | pass | fail (Recv 1) | **flaky**, 2/5 pass |
| DEMO-003 | fail (Recv 4) | pass | fail (Recv 4) | pass | pass | **flaky**, 3/5 pass |
| DEMO-004 | pass | pass | pass | pass | pass | stable in this sample (5/5) |
| DEMO-005 | fail | fail | fail | fail | fail | consistent failure (0/5), not flaky |

## Applying flaky-detect's Method (SKILL.md) to this data

1. Parsed each `results-runN.xml` by `<testcase name>` (the `@QAIA-FLAKY-DEMO-*` id is embedded
   in the JUnit test name, same convention `run-report` uses for `@QAIA-*` tags).
2. Built the verdict sequence per test across the 5 runs (table above).
3. Flagged **DEMO-001, DEMO-002, DEMO-003** as flaky (verdict set contains both `pass` and
   `fail`). **DEMO-004** was not flagged (all pass — reported as "no flakiness observed," not
   as "stable"). **DEMO-005** was not flagged as flaky either, and was **not** merged into the
   `flaky` list despite failing every run — it is a consistent, deterministic failure (a real
   bug), which the skill must keep separate per its Guardrails.
4. Recorded failing-run indices and a failure excerpt per flaky test.

Result: `output/flaky-findings.json` and `output/flaky-findings.md` — produced by hand-applying
the skill's method to real data, exactly as a session running the skill would. All three
buckets (`flaky`, `allPassNoFlakinessObserved`, `consistentFailures`) are populated correctly
and match the ground-truth table above field for field.

## Manifest merge (contract D39, rule 2)

`output/manifest-before.json` is a plausible manifest as `run-report` would have already
written it (with `execution`, `design`, `gate` populated — `gate` here is a fabricated
illustrative example, not really scored by `qaia-score`, since this fixture is not a real
QAIA user story). `output/manifest-after.json` is the same file with **only** `flakiness`
added, `producers[]` appended, and `artifacts[]` extended — `design`, `execution`, `gate`, and
`status` are byte-for-byte unchanged. Diffing the two confirms the merge rule is followed.

**Honest limitation surfaced by this exercise, not smoothed over**: because `gate` is never
touched by this skill (correctly, per contract rule 3 — no producer scores itself), the
`gate.reasons` in `manifest-after.json` ("3 of 5 tests failed in the last run") reads as stale
once `flakiness` is known — a human or `qaia-score` re-scoring would now want to say "3 tests
flaky, not a stable regression" instead. This is not a bug in `flaky-detect` (it must not
touch `gate`), but it is a real hand-off gap: nothing in the current contract *prompts*
`qaia-score` to re-run after a `flakiness` section appears. Left as an explicit limitation
for follow-up, not fixed in this session.

## Result

The skill's method, applied to real (not fabricated) data, correctly identified the 3 tests
with genuine pass/fail variance, correctly withheld the always-pass control from the flaky
list, and correctly kept the always-fail control out of the flaky list too (real bug, reported
separately). This matches the intended behavior in `SKILL.md` exactly.
