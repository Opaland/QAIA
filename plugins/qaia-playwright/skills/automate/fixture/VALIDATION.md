# automate self-review lint — validation (issue #41, 2026-07-25)

Honest record of validating the step 4 self-review added to `../SKILL.md` against a
purpose-built case, following the same fixture discipline as
`../../flaky-detect/fixture/VALIDATION.md`.

## What was built

- `scenarios.feature` — 3 minimal scenarios (not a real product US), each with a
  concrete, assertable `Then`, chosen so the "naive" generation below can be made to
  violate exactly one of step 4's three flagged classes per scenario.
- `generated-before.spec.js` — a **deliberately naive** generation output: syntactically
  valid Playwright (`node --check` passes), each test built to demonstrate one violation:
  - `@QAIA-FIXTURE-041-001`: **tautological/reflexive comparison** —
    `expect(true).toBe(true)` in place of the concrete refusal message the `Then` names.
  - `@QAIA-FIXTURE-041-002`: **weak-by-construction matcher** —
    `expect(cancelBtn).toBeDefined()` on a `getByRole()` locator handle, which is always
    a defined object regardless of whether the button is actually visible/enabled
    (Playwright locators are lazy) — proves nothing about the `Then`.
  - `@QAIA-FIXTURE-041-003`: **silent zero-assertion block** — the action runs
    (`filterBy('dermatology')`) but no `expect(...)` follows, dropping the coverage the
    scenario's `Then` promised.
- `generated-after.spec.js` — the same three tests with step 4's self-review applied:
  each trivial/missing assertion replaced by one derived from its scenario's `Then`,
  reusing the page-object API already established in `examples/medibook/tests/e2e.booking.spec.js`
  (`bookingPage.message`, `bookingPage.slots`, `bookingPage.appointments`) rather than
  inventing a new one.

## What was actually checked (mechanical, not narrated)

1. **Syntax**: `node --check` on both files — both parse cleanly (real command run,
   output captured, not asserted from memory).
2. **The violations are real code, not just described in comments** — grepped
   `generated-before.spec.js` for `expect(true).toBe(true)` and `toBeDefined()`: both
   hits land on live statement lines (17 and 28), not inside a comment.
3. **The fixes are real code, not just described in comments** — the same grep against
   `generated-after.spec.js` returns **zero** live-code hits for either pattern; the only
   occurrences are inside `// Was: ...` explanatory comments.
4. **The zero-assertion violation and its fix, counted precisely** — a small Node script
   isolated the `@QAIA-FIXTURE-041-003` test body in each file, stripped `//` comments
   (the first pass without stripping comments false-positived on the word "expect(...)"
   inside the explanatory comment itself — a real miss worth recording, not smoothed
   over), then counted real `expect(` call sites:
   - `generated-before.spec.js`: **0** real assertions in that test body.
   - `generated-after.spec.js`: **2** real assertions in that test body
     (`toHaveCount(1)` for dermatology present, `toHaveCount(0)` for cardiology absent —
     both halves of "only dermatology slots are displayed").

## Applying step 4's method (SKILL.md) to this data

| Scenario | Violation class (step 4 bullet) | Before | After | Derived from |
|---|---|---|---|---|
| FIXTURE-041-001 | tautological comparison (bullet 1) | `expect(true).toBe(true)` | `expect(bookingPage.message).toContainText('less than 4 hours')` | `Then` names the exact string |
| FIXTURE-041-002 | weak-by-construction matcher (bullet 3) | `expect(cancelBtn).toBeDefined()` | `expect(cancelBtn).toBeVisible()` + `.toBeEnabled()` | `Then`: "visible and enabled" |
| FIXTURE-041-003 | silent zero-assertion block (bullet 4) | *(no expect)* | `toHaveCount(1)` dermatology / `toHaveCount(0)` cardiology | `Then`: "only dermatology slots are displayed" |

Each fix reuses a value or state the `Then` text names explicitly — none of the three
corrections required inventing a plausible-looking check the scenario didn't already
specify, which is the honesty condition step 4 sets for when a fix is safe to make
automatically (vs. leaving a `// TODO(automate): ...` marker and reporting the scenario
blocked-for-assertion, for a `Then` that names nothing concrete).

## Honest limitation

`../SKILL.md` step 4 is a **behavioral instruction for the generating agent**, not a
standalone executable linter shipped with the plugin — there is no `lint.py` this
validation ran against, unlike `eval/tools/structural_score.py` for the Gherkin layer.
This validation therefore hand-applies the three bullet patterns to a constructed case
(same posture flaky-detect's fixture used: hand-apply the documented method to real,
inspectable data) and verifies mechanically (grep + a counting script, not narration)
that the violating code is genuinely present in `generated-before.spec.js` and genuinely
absent from `generated-after.spec.js`. It demonstrates the method is well-specified and
discriminates correctly on a case built to exercise it; it is not a claim that every
future `automate` run will catch every trivial assertion a model could produce — the
same caveat any instruction-only (non-code) gate carries.

## Result

All three deliberately injected violations (tautological comparison, weak-by-construction
matcher, silent zero-assertion block) are distinguishable from their corrected form by
mechanical inspection (grep, syntax check, assertion count), and each correction is
traceable to concrete text in the scenario's `Then` rather than fabricated. This matches
the intended behavior of `SKILL.md` step 4.
