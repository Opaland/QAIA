# Traceability — US-EVAL-006 → scenarios → automated tests (the-internet: Dynamic Loading)

Continuous chain: requirement (AC) → QAIA Gherkin scenario (stable ID, from
`testbooks/dynamic-loading.feature`) → executable Playwright test. All tests run **real** against
the live public SUT `https://the-internet.herokuapp.com` (no mock, no stub, no simulated timer).

**Correction (post independent-evaluator review):** `npx playwright test` was invoked twice in
this session, both times 4/4 green, observed live in the terminal (1st run: 60ms/49ms/5516ms;
2nd run: 60ms/52ms/5508ms for scenarios 001/003/004 respectively). However `playwright.config.js`
writes `results.json` unconditionally on every run, so the 2nd invocation **overwrote** the 1st
run's JSON output before it was preserved as a standalone artifact — only the 2nd run's numbers
survive on disk, in both `tests/run-log.txt` and `tests/results.json`. The 1st run's numbers above
are accurately reported from live terminal output at the time, but are not independently
re-verifiable from a saved artifact. Both delivered files (`run-log.txt`, `results.json`) are the
same (2nd) run — not two independent pieces of evidence, as an earlier draft of this report
incorrectly implied.

| AC | Requirement | Scenario ID | Automated test | Type | Result | Real timing evidence (from `run-log.txt` / `results.json`, the preserved run) |
|---|---|---|---|---|---|---|
| AC3 | Example 1: pre-existing hidden element not visible before delay | `@QAIA-US-EVAL-006-001` | e2e "hidden element not visible before the delay elapses" | E2E (desktop) | PASS | assertions completed 60ms after click — well under 5000ms |
| AC4 | Example 2: no `#finish` element in DOM before any click | `@QAIA-US-EVAL-006-002` | e2e "no Hello World element in the DOM before any click" | E2E (desktop) | PASS | n/a (no timing assertion — initial-state check) |
| AC6 | Example 2: `#finish` still absent from DOM before delay | `@QAIA-US-EVAL-006-003` | e2e "still does not exist before the delay elapses" | E2E (desktop) | PASS | assertions completed 52ms after click — well under 5000ms |
| AC6 | Example 2: `#finish` created + shown after delay | `@QAIA-US-EVAL-006-004` | e2e "created and shown after the delay elapses" | E2E (desktop) | PASS | element revealed 5508ms after click — >= 5000ms confirmed empirically |

**Result: 4/4 P1+P2 scenarios executed, 4/4 passed (100%), 0 blocked, confirmed on 2 separate live
invocations against the real target (1 fully preserved on disk).**

## Testability precheck (step 2, CTAL-TAE, D95)

- **Observability**: sufficient without gaps. `#finish` visibility/presence and `#loading`
  visibility are both directly observable DOM state (Playwright `toBeVisible`/`toBeHidden`/
  `toHaveCount`) — no guessing required. Text content (`Hello World!`) is directly readable.
- **Controllability**: sufficient. Each scenario's precondition is a single `page.goto()` (atomic,
  declarative — no UI-chained multi-step setup, no server-side reset endpoint needed because the
  target is stateless per page load).
- **Selectors**: `#start button`, `#loading`, `#finish` are the only selectors the served HTML
  exposes (see raw HTML fetched directly from `/dynamic_loading/1` and `/dynamic_loading/2` during
  this run — no `data-testid`/ARIA role attributes on this legacy demo page). Rule T2 prefers
  `getByRole`/`getByTestId`; this target offers neither, so the page object falls back to the
  target's own stable `id` selectors — the only non-positional, non-fragile option actually
  available. This is a testability gap on the target side (flagged here per step 2), not a
  workaround using positional XPath (which remains forbidden and was not used).

## Self-review (step 5, trivial-assertion lint)

Every `expect(...)` in `tests/e2e.dynamic-loading.spec.js` checks real, freshly-read SUT state
(visibility, DOM element count, text content, or a real `Date.now()` timing delta) — no
tautological/contentless/weak-by-construction assertions were generated. No `TODO(automate)`
markers were needed; every `Then` in the source testbook maps to a concrete, assertable value.

## Golden rule / scope (docs/DEMO-TARGETS.md, "the-internet" row)

`security-surface` and `perf-check` are **explicitly out of scope** for this target (matrix marks
Security ❌ and Perf ❌ — shared public demo, no self-hosted instance for this campaign) and were
**not run** — not simulated, not substituted, not silently skipped without mention.

## CI pipeline (step 6, T4)

Not emitted for this evaluation run — this is a skill-evaluation exercise against an isolated
worktree's `eval/` sandbox, not a shipping project requesting CI autonomy. The `automate` skill's
`templates/` CI generation was not exercised; noted so the evaluator does not read its absence as
a defect in the generated test suite itself.

## Exit criterion (T17)

4/4 P1 scenario is `@QAIA-US-EVAL-006-003` (the only P1 in this book) — 1/1 P1 executable and
passed = 100 % P1 executable, exceeding the 80 % T17 bar on this pilot slice. Reported as the
ratio actually achieved on this run; T17 itself remains a human/pilot-level gate per the skill's
own exit-criterion text, not self-certified here.
