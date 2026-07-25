# Flaky-test findings — fixture (5 runs, `flaky.spec.js`)

Source: `fixture/runs/results-run1.xml` … `results-run5.xml`, same code across all 5 runs
(no edits to `server.js`, `flaky.spec.js`, or `playwright.config.js` between runs — verified
by re-running the identical fixture directory 5 times in a row).

## Flaky (verdict varies across runs — reported, not fixed)

| Test | Verdict sequence (run 1→5) | Pass rate | Failed on | Failure excerpt |
|---|---|---|---|---|
| `@QAIA-FLAKY-DEMO-001` | fail, fail, pass, pass, fail | 2/5 | runs 1, 2, 5 | `Expected: 2, Received: 3` (run 1) |
| `@QAIA-FLAKY-DEMO-002` | pass, fail, fail, pass, fail | 2/5 | runs 2, 3, 5 | `Expected: 2, Received: 4` (run 2) |
| `@QAIA-FLAKY-DEMO-003` | fail, pass, fail, pass, pass | 3/5 | runs 1, 3 | `Expected: 2, Received: 4` (run 1) |

Likely cause hint (not asserted as certain, this skill does not fix): shared mutable state
(`items` array in `fixture/server.js`) hit by concurrent workers with no per-test isolation —
the same root-cause class documented in `examples/medibook`'s flake hunt and
`examples/expense-demo` (D68), fixed there with `workers: 1`.

## No flakiness observed (all-pass — provisional, not proof of stability)

| Test | Verdict sequence | Note |
|---|---|---|
| `@QAIA-FLAKY-DEMO-004` | pass, pass, pass, pass, pass | 5/5 in this sample. Not timing-dependent by construction, but the skill has no way to know that from the JUnit data alone — reported as "no flakiness observed in 5 runs," not as a stability guarantee. |

## Consistent failures (real bug, never flaky)

| Test | Verdict sequence | Note |
|---|---|---|
| `@QAIA-FLAKY-DEMO-005` | fail, fail, fail, fail, fail | Same assertion fails every run (`Expected: 3, Received: 2`) — deterministic, not flaky. Reported separately; never merged into the `flaky` list. |

## Assumption made explicit

`codeChangeControlled: true` — these 5 runs were captured back-to-back from one unmodified
fixture directory in this session, so "no code change between runs" is a verified fact here,
not an unchecked assumption. In real usage (e.g. runs pulled from CI history) this skill
cannot verify that on its own and must say so (see `SKILL.md` Guardrails) rather than assume it
silently.
