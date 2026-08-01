# Synthesis — US-EVAL-001 (SauceDemo login gate)

**Scope**: login-gating behavior only (7 conditions, all P1/P2 — default scope, nothing waived).
**Scenarios**: 7 atomic blocks (`005` is a `Scenario Outline` with 2 examples, counted as 1 block
per the single block definition) + 0 smoke journey (skipped — out of proportion for a 3-AC slice).
**Negative ratio**: 6/7 blocks tagged `@negative` = 85.7 % — reported, never a target; every
negative here traces to a real refusal condition, none invented to move the figure.
**Coverage**: AC1 1/1, AC2 2/2, AC3 4/4 — 7/7 conditions covered, 0 waived.

> **Updated 2026-08-01.** Condition AC3-C4 and scenario `007` were added after the first
> automation-rubric pass (#63): the "generic message" requirement is an *equality between two
> refusals*, and no scenario stated it. Counts above reflect that addition.

## Open / assumption / low-confidence list (full, per shared contract)

- **Q1** ~~`[assumption]`~~ → **resolved 2026-08-01**. The assumption was that the refusal is
  generic/non-enumerating, with the exact wording left unasserted for want of a source. The same
  live probe that answered Q2 and Q3 answered this one too: unknown user, wrong password and
  locked-user-with-wrong-password all return the identical string. Scenarios `003`/`004` now
  assert it, and **new scenario `007` asserts the two refusals are identical to each other** —
  which is the actual requirement, and which no per-scenario assertion could express.

  Found by the first pass of the automation rubric (issue #63): with only "a message is shown"
  asserted, `003` and `004` both passed against an application answering "No such user" to one
  and "Wrong password" to the other — precisely the user-enumeration defect the word "generic"
  exists to forbid. The weakness was in this test book first; the generated code inherited it.
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
