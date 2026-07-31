# Validation — `automation_score.py` mutation track

Date: 2026-07-31. Playwright 1.62.1. Fully offline: the tests build their own DOM with
`page.setContent()`, so this proof needs no network and no target app.

## What this fixture proves

Two tests that a static reader cannot tell apart. Both green. Both use a real locator, a real
matcher and a real expected value — neither trips any static rule in `automation_score.py`
(no hollow assertion, no fragile selector, no forbidden wait, both tagged).

One of them swallows its assertion in a `try/catch` and therefore **cannot fail**. Only the
mutation track sees the difference.

## Real run

Baseline, before anything:

```
$ npx playwright test
  2 passed (500ms)
```

Mutation track:

```
$ python eval/tools/automation_score.py \
    --tests-dir eval/tools/fixtures/automation-score/tests \
    --run-cwd eval/tools/fixtures/automation-score

MUTATION status=ok | total=2 | killed=1 | survived=1
  SURVIVANT: mutation-demo.spec.js:22 | toHaveText('Bonjour') -> '...__QAIA_MUT__'
             @QAIA-FIXTURE-002 swallowed assertion looks identical but cannot fail
BLOQUANT: True
  - mutation-survivor: await expect(page.locator('h1')).toHaveText('Bonjour');
    (mutation-demo.spec.js:22) — toHaveText('Bonjour') -> '...__QAIA_MUT__'
```

- `@QAIA-FIXTURE-001` (load-bearing): mutant **killed** — inverting the expected text turned
  the test red, so the assertion is doing work.
- `@QAIA-FIXTURE-002` (swallowed): mutant **survived** — the test stayed green with a
  deliberately wrong expectation. Blocking finding raised.

Source file restored after the run (`grep -c QAIA_MUT` → `0`), suite re-run green (2 passed):
the tool leaves no mutation behind.

## Bugs this fixture and the first real runs found in the tool itself

Found by **running** it against real in-repo suites, not by reading it — same lesson as D104/D116.

1. `test.describe(...)` was parsed as a test, so every suite reported a phantom
   "test without assertion" **blocking** finding. Fixed: `TEST_DECL` now excludes `describe`.
2. Selector quality was scored on spec files only, so a fully POM-based suite (US-EVAL-001)
   reported 0 role selectors and 0 raw selectors — the selectors live in `pages/`. Fixed:
   page objects and fixtures are scanned too.
3. `toBeTruthy()` was classified as a hollow (blocking) assertion. **This was wrong and it
   wrongly failed US-EVAL-002**: `expect(cart.cart_items.some(i => i.product_id === productId
   && i.quantity === 1)).toBeTruthy()` is a real check on real data — it *can* fail. Weak is
   not hollow. Split into a non-blocking `weak-assertion` class; only assertions that
   physically cannot fail (`toBeDefined()` on a locator handle, `expect(true).toBe(true)`)
   stay blocking.
4. `waitForLoadState('networkidle')` matched two patterns and was reported twice. Fixed:
   first matching rule wins.

## Honest limits

- Mutating the **test** proves an assertion is sensitive to its own expected value. It does
  **not** prove the assertion checks the right thing — that is the LLM judge's question
  (`eval/AUTOMATION-RUBRIC.md`), and the two results are never merged.
- Parsing is regex-based, not a JS parser: unusual formatting can hide an assertion from the
  mutator. A missed defect is possible; a fabricated one is not (every finding carries
  `file:line` and the exact mutation applied).
- Assertions the mutator has no operator for are simply not mutated. They are counted in
  `total` only when a mutation was actually applied, so `killed + survived = total` always
  refers to mutations really run — never an inflated denominator.
- The track needs a **green baseline**. If the suite is already red the tool refuses to run it
  and says why, rather than reporting meaningless survivors.
