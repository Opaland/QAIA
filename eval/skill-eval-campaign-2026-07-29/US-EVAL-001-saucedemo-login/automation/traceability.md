# Traceability report — US-EVAL-001 (SauceDemo login gate), automate skill step 8

> **Update 2026-08-01 (issue #60, decision D132).** Everything below describes the original
> 2026-07-30 run and is left as written. Two things have changed since:
>
> 1. **The corrections this report recommended have been made.** Its closing recommendations —
>    replace scenario `006`'s proposed default with the confirmed behaviour, and correct
>    `synthesis.md`'s Q2/Q3 notes — were carried out against a fresh live oracle
>    (`eval/ci-proof-2026-08-01/oracle-probe-saucedemo.txt`). The suite is now **8/8**, and it is
>    green because two wrong expected values were corrected, not because any assertion was
>    softened: both scenarios gained exact-text assertions where they had a weaker check before.
>    The result table below therefore no longer matches the current specs.
> 2. **The suite now runs in a real CI.** `.github/workflows/generated-suite.yml` executes it on
>    a GitHub Actions runner with no QAIA session and no `plugins/` import — see
>    `eval/ci-proof-2026-08-01/`.

Real run, real browser, real target: `https://www.saucedemo.com/` (public shared demo, no
auth/PII risk, per `docs/DEMO-TARGETS.md`). Playwright 1.62.0, Chromium, `workers: 1`,
`retries: 0`. Run artifacts: `tests/results.json`, `tests/junit.xml`,
`tests/test-results/**` (screenshot + trace for the one failure).

## Testability precheck (step 2, CTAL-TAE)

- **Observability**: good. Every interactive element and the error banner expose a
  `data-test="..."` attribute. One nuance found by live exploration (not obvious from the
  test book alone): SauceDemo's attribute is `data-test`, **not** Playwright's `data-testid`
  default — `getByTestId()` silently times out until `testIdAttribute: 'data-test'` is set in
  `playwright.config.js`. Documented in the config; not a blocker once found.
- **Controllability**: gap, reported not routed around. SauceDemo has no reset/seed API and a
  fixed, non-mutable account list (`standard_user`, `locked_out_user`, ...) — there is no way
  to declaratively create a *new* locked or unlocked account for a test. This did not block any
  scenario in this test book (all 6 conditions use the existing fixed accounts), but it would
  block any future scenario needing a fresh/unlocked-then-locked account state. No UI-chained
  workaround was used to route around it (per the guardrail) — none was needed here.

## AC -> scenario -> test -> result

| AC  | Scenario ID | Test | Result |
|-----|-------------|------|--------|
| AC1 | QAIA-US-EVAL-001-001 | `e2e.login.spec.js` "valid non-locked account reaches the product catalog" | **PASS** |
| AC2 | QAIA-US-EVAL-001-002 | `e2e.login.spec.js` "locked-out account is refused with the locked-out message" | **PASS** |
| AC3 | QAIA-US-EVAL-001-003 | `e2e.login.spec.js` "unknown username is refused with a generic message" | **PASS** |
| AC3 | QAIA-US-EVAL-001-004 | `e2e.login.spec.js` "known username with wrong password is refused with a generic message" | **PASS** |
| AC3 | QAIA-US-EVAL-001-005 (example 1) | `e2e.login.spec.js` "empty username is refused" | **PASS** |
| AC3 | QAIA-US-EVAL-001-005 (example 2) | `e2e.login.spec.js` "empty password is refused" | **PASS** |
| AC2 | QAIA-US-EVAL-001-006 | `e2e.login.spec.js` "locked-out account with wrong password still shows locked-out message (proposed default, unconfirmed)" | **FAIL** (real, expected — see below) |
| — (additive, not a login-gate AC) | QAIA-A11Y-001 | `a11y.login.spec.js` axe-core WCAG2 A/AA on login screen | **PASS** (0 serious/critical violations) |

**Totals: 7/8 tests passed, 1 failed. 0 blocked. P1 scenarios: 4/5 executed and passing
(001 is P2; 002/004 are P1-pass; 006 is P1-fail) — P1 executable ratio 5/5 = 100 %, P1 green
ratio 4/5 = 80 % (T17 pilot metric noted, not self-certified — see SKILL.md Exit criterion).**

## The one real failure — and what it means

`QAIA-US-EVAL-001-006` was already flagged `@low-confidence` in the test book itself
(`testbooks/login-gate.feature` lines 53-64, `testbooks/synthesis.md` "Q3"): a **proposed
default**, explicitly marked unconfirmed, for "does a locked account with a wrong password
show the locked-out message or the generic one?"

Automation was not asked to silently fix or soften this assertion — per `automate` SKILL.md
step 7 ("Do not claim green without a real run") and the step-6/006 comment left in the spec
itself, the test encodes the test book's *stated* expectation literally. Run against the real
app it fails, and the failure **is the answer to Q3**:

```
Expected: "Epic sadface: Sorry, this user has been locked out."
Received: "Epic sadface: Username and password do not match any user in this service"
```

SauceDemo checks credentials match *before* it checks lock state — a wrong password on a
locked account gets the generic invalid-credentials message, not the locked-out one. This is
a real, reproducible finding from live exploration (`../probe2.js` output, captured before the
suite was written) and confirmed again by the suite's own run. It should go back to whoever
owns `testbooks/login-gate.feature` as: replace scenario 006's proposed default with the
confirmed behavior (generic message wins), and correct `synthesis.md`'s Q3 note from "open" to
"resolved by live probe + automated run, `YYYY-MM-DD`".

## Also resolved by real exploration (Q2)

The test book's `Q2` assumption (`synthesis.md`) guessed empty-field submissions "fall through
to the same generic refusal path" as other invalid-credential cases. Live probing
(`../probe2.js`) found this is **not quite right either**: SauceDemo shows *distinct* messages
("Username is required" / "Password is required"), not the shared generic one. This did not
cause a test failure only because scenario 005's `Then` in the Gherkin never asserted specific
wording (just "refused" + "catalog not displayed") — had it asserted the generic message like
006 does, it would have failed too, for the same reason. Recommend the same correction to
`synthesis.md`/the test book: Q2's assumption is disconfirmed by real behavior.

## Golden rule compliance (docs/DEMO-TARGETS.md)

- `security-surface` and `perf-check`: **not run — not applicable per golden rule.** SauceDemo's
  matrix row marks both columns ❌ (demo forbids). No security or performance scanning was
  attempted, simulated, or approximated against this shared public target.
- `a11y-audit`: matrix marks a11y ⚠ (warning, not forbidden) — run for real (see QAIA-A11Y-001
  above), reported honestly (0 serious/critical violations found on the login screen; full axe
  violation list, including non-blocking ones, attached to the Playwright HTML report/trace).

## Step-5 self-review (trivial-assertion lint)

Every `expect(...)` in `e2e.login.spec.js` and `a11y.login.spec.js` checks real SUT state read
from the page (URL, error banner text/visibility, inventory container visibility, axe-core
violation list) — none are tautological, contentless, or `.toBeDefined()`-on-a-locator style
weak assertions. No scenario was left with zero assertions. Nothing required a `TODO(automate)`
marker; every `Then` in the test book had a concrete, assertable value.
