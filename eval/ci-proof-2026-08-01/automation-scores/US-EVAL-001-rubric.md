# Automation rubric applied — US-EVAL-001 (SauceDemo login gate), 2026-08-01

First application of `eval/AUTOMATION-RUBRIC.md` by an agent (issue #63, first checkbox). Until
today it was written and never exercised, which — as the issue itself put it — made it worth no
more than an intention.

---

## Declare the conflict first

**I am not a valid judge of this suite, and this result must be read with that fact attached.**

The rubric requires a judge in a **fresh session**, given the artifacts and explicitly *not* the
generation session's context. Two things disqualify this pass:

1. **I edited this suite earlier today** (#60/D132 — scenarios `005` and `006`). For those two
   tests I am the producer, and rule 3 says a producer never grades its own output.
2. **I have the full generation context** — the oracle probe, the reasoning behind each
   correction. The rubric withholds that on purpose, because a judge who watched the code being
   written scores the intention instead of the artifact.

What this pass therefore establishes is narrow: **the rubric is applicable — its dimensions
discriminate on a real suite and it produced a finding nobody had made.** It does **not**
establish that this suite scores 10/12 in any trustworthy sense. #63's first checkbox stays
**open** until an independent judge runs it cold.

I am recording it rather than discarding it because the finding below is real and checkable by
anyone, regardless of who found it.

---

## Deterministic tracks (facts taken as given, not re-scored)

**Static**: `100.0/100` — assertions 30/30, selectors 25/25, POM-as-fixtures 20/20,
traceability 25/25. Raw JSON: `US-EVAL-001-static.json`.
One non-blocking finding: `a11y.login.spec.js:1` does not import the fixtures (it uses
`@playwright/test` directly). Legitimate — it needs no page object — but the tool is right to
flag it.

**Mutation**: `total 8, killed 8, survived 0`, status `ok`. Raw JSON:
`US-EVAL-001-mutation.json`.

Every assertion in the suite is **load-bearing**: inverting any one of them turns its test red.
Note what this does and does not say — it proves each assertion is sensitive to its own expected
value, **not** that it asserts the right thing. That is what the rubric below is for, and the two
numbers are never summed.

---

## Rubric

| # | Dimension | Score | Justification |
|---|---|---:|---|
| 1 | Then-fidelity | **2** | Each test asserts its scenario's `Then`. Where the book is deliberately vague it stays vague: `003`/`004` assert error visibility (`e2e.login.spec.js:30`, `:38`) because the book's `Then` names "a generic message" without committing to wording (Q1, `synthesis.md`). Inventing the text would have been the defect. |
| 2 | No invented expectation | **1** | Message literals now trace to a cited oracle (`e2e.login.spec.js:48`, `:56`, `:76`). But `'not_the_real_password'` (`:38`) has no provenance comment, unlike the sibling invented username which does (`:26`). Plausible and harmless — the "1" band exactly. Scored down per the rubric's default-to-lower rule. |
| 3 | Negative tests really refuse | **2** | Every negative asserts the refusal *and* the unchanged state — error present plus `inventoryPage.container` not visible (`:31-32`, `:39-40`, `:49-50`). None would pass against an app that silently does nothing. |
| 4 | Ambiguity preserved, not resolved | **2** | `005`/`006` carry comments stating what was unconfirmed, what resolved it, and where the raw evidence lives (`:44-47`, `:69-75`). The `006` comment records that its earlier failure *was* the answer to the open question rather than a bug. |
| 5 | Assertion strength matches the claim | **1** | See the finding below. `003`/`004` assert only that *an* error is visible where the scenario's word is "**generic**". |
| 6 | Honest handling of the un-automatable | **2** | `traceability.md` names the controllability gap (no reset/seed endpoint on a public demo) against the scenarios it would block, and states no UI-chained workaround was used. `fixtures.js:2-5` repeats it at the point it matters. |

**Total: 10 / 12.** No dimension at 0. No blocking finding open in either deterministic track.

---

## The finding this pass produced

**`003` and `004` cannot catch the defect the word "generic" exists to prevent.**

Both scenarios assert only `expect(loginPage.error).toBeVisible()`. The book's `Then` is "refused
with a **generic** message" — and "generic" is not decoration. It is the anti-enumeration
requirement: an unknown username and a wrong password must be indistinguishable, or the login
form becomes an oracle telling an attacker which accounts exist.

As written, both tests pass against an application that returns `"No such user"` for `003` and
`"Wrong password"` for `004` — precisely the failure the requirement forbids. That matches the
rubric's dimension-5 zero band ("compatible with the failure mode the scenario exists to catch")
more than its one band; I scored **1** rather than 0 because the assertion is still directional
and the book itself never committed to the wording, so the code is faithful to a weak `Then`
rather than unfaithful to a strong one. **The weakness is in the test book first, and the code
inherited it.**

**And it is now fixable, which it was not yesterday.** The oracle probe run for D132
(`../oracle-probe-saucedemo.txt`) answered Q1 along with Q2 and Q3: unknown user, wrong password
and locked-user-with-wrong-password all return the *same* string. That shared string is the
evidence of genericness. Q1 was left marked `[assumption]` in `synthesis.md` only because #60
scoped itself to Q2 and Q3 — an inconsistency introduced today, by me, and found by running this
rubric.

**Recommended fix** — assert the shared text in `003` and `004`, and add a scenario asserting the
two messages are *identical to each other*, which is the actual requirement and which no
per-scenario assertion can express.

---

## Top-3 fixes

1. **Close Q1 and strengthen `003`/`004`** to assert the generic message text, per the finding
   above. Highest value: it converts two tests that cannot fail on the requirement into two that
   can.
2. **Add the enumeration-equivalence scenario** — unknown user and wrong password produce
   byte-identical refusals. Currently no scenario states the requirement that makes "generic"
   meaningful.
3. **Comment the provenance of `'not_the_real_password'`** (`:38`), as its sibling invented
   username already does. Cheap, and it is the habit that keeps dimension 2 honest.

---

## Outcome — fixes 1 and 2 applied and verified the same day

Applied **as producer, not as judge** (the rubric forbids the judge editing code; it proposes,
someone else applies):

- **Q1 closed.** `synthesis.md` and the coverage matrix record it as resolved by the 2026-08-01
  probe, alongside Q2 and Q3.
- **`003` and `004` now assert the message text**, via a shared `GENERIC_REFUSAL` constant —
  which is itself the point: the same literal in both tests is what "generic" means.
- **New scenario `007`** — `AC3-C4`, the anti-enumeration requirement. It compares the two
  refusals **to each other**, not to a constant, because the requirement is that the application
  does not distinguish the two cases *whatever wording it chooses*. It is the only test in the
  suite that can fail on user enumeration.
- **Fix 3 applied** — provenance comment on `'not_the_real_password'`.

**Verification, re-run after the change:**

| | Before | After |
|---|---|---|
| Suite | 8 passed | **9 passed** |
| Static | 100/100 | **100/100** |
| Mutation | 8 total, 8 killed, 0 survived | **12 total, 12 killed, 0 survived** |

Raw: `US-EVAL-001-mutation-after-rubric.json`. The four new mutable assertions are load-bearing
like the rest — including `007`'s comparison of two runtime values, which was the one most likely
to be decorative.

Book counts re-derived from the emitted file rather than edited by hand (the tag-versus-ratio
audit): **7 blocks, 6 `@negative`, ratio 0.857, P1 5 / P2 2** — matching the manifest exactly.

**Dimensions 2 and 5 would now score 2**, taking the total to 12/12 — which is precisely why that
re-score must not be recorded as a result. I applied the fixes; I cannot then grade them. The
next independent judge scores the current state.

## What I could not verify

- **Whether the suite still passes after the recommended fix** — not run; the fix is proposed,
  not applied (the rubric forbids the judge editing code).
- **Timing-based enumeration.** Identical text does not rule out a timing oracle; nothing here
  measured response times, and no scenario covers it.
- **The a11y spec's real coverage.** `a11y.login.spec.js` was scored for form only. Whether axe's
  0 serious/critical on this screen reflects the screen or a thin scan was not checked — it needs
  the `results.incomplete` list, which the stored artifacts do not contain.
- **Anything about the other seven campaign suites.** Their static scores are in this directory;
  no rubric pass was run on them, and their scores must not be read as if one had been.
