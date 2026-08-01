# Synthesis — US-EVAL-001 (SauceDemo login gate)

**Scope**: login-gating behavior only (6 conditions, all P1/P2 — default scope, nothing waived).
**Scenarios**: 6 atomic blocks (`005` is a `Scenario Outline` with 2 examples, counted as 1 block
per D20's single definition) + 0 smoke journey (skipped — out of proportion for a 3-AC slice).
**Negative ratio**: 5/6 blocks tagged `@negative` = 83.3 % (target ≥ 40 %, met without padding —
every negative here traces to a real refusal condition, none invented to hit the ratio).
**Coverage**: AC1 1/1, AC2 2/2, AC3 3/3 — 6/6 conditions covered, 0 waived.

## Open / assumption / low-confidence list (full, per shared contract)

- **Q1** `[assumption]` — invalid-credentials refusal is generic/non-enumerating; exact wording
  not asserted (not confirmed by any source).
- **Q2** ~~`[assumption]`, `@low-confidence`~~ → **resolved 2026-08-01, assumption disconfirmed**.
  The guess was that empty-field submission folds into the generic refusal path (scenario
  `QAIA-US-EVAL-001-005`). It does not: the application emits a distinct required-field message
  per empty field (`Username is required` / `Password is required`). Scenario `005` now asserts
  those messages and dropped `@low-confidence`.
- **Q3** ~~`[open]`, `@low-confidence`~~ → **resolved 2026-08-01, proposed default disconfirmed**.
  The question was whether a locked account with a wrong password shows the locked-out message or
  the generic one. Answer: **the generic one** — credentials are validated *before* lock state, so
  the locked-out message appears only with a correct password (scenario `002`). Scenario `006`
  encoded the opposite as a *proposed* default; it has been corrected and dropped
  `@low-confidence`.

Both were resolved by running the generated suite against the live application, not by
arbitration on paper: the failure of `006` **was** the answer. Raw oracle output for every
credential combination is kept in `eval/ci-proof-2026-08-01/oracle-probe-saucedemo.txt`
(rule 4bis). See `docs/DECISIONS.md` D132.

## Out-of-slice (not designed here)

- `problem_user` / `performance_glitch_user` post-login UI defects (broken images/sorting,
  artificial latency) — separate UI-rendering and performance concerns, noted in `00-source.md`.

## Sourcing honesty note

This US was captured from live-application behavior via `WebSearch`-aggregated secondary sources
(SauceDemo publishes no formal spec), not a primary written ticket — see `00-source.md` for the
exact citations. Business-correctness confidence is therefore *good but not primary-source-grade*
for the two literal strings asserted (`"secret_sauce"`, `"Sorry, this user has been locked out."`).
