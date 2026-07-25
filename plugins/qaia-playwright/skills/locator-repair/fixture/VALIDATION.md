# locator-repair validation — real run, real data (2026-07-25)

Honest record of validating `../SKILL.md` against a purpose-built, self-contained fixture —
independent of `examples/medibook` and `examples/expense-demo`, per the acceptance criterion
on issue #37.

## What was built

- `app.html` — a static page with three controls whose selectors the fixture deliberately
  breaks after the tests are written against them: a login form (email/password/submit, all
  `data-testid`), a two-row cart with a "Remove item" button per row, and a nav with a
  "Log out" link.
- `app.spec.js` — 3 Playwright tests, one per control, written against the **original** HTML:
  `@QAIA-LOCREPAIR-001` (`getByTestId('login-btn')`), `@QAIA-LOCREPAIR-002`
  (`getByRole('button', { name: 'Remove item' }).first()`), `@QAIA-LOCREPAIR-003`
  (`getByRole('link', { name: 'Log out' })`). An `afterEach` dumps `page.content()` to
  `dom-snapshot.html` next to Playwright's own artifacts whenever a test fails — a stand-in
  for "the current DOM, if available" that `SKILL.md`'s Input section relies on.
- `server.js` / `playwright.config.js` — minimal static server + config (JUnit reporter,
  screenshot-on-failure), same pattern as `../../flaky-detect/fixture/`.

## Step 1 — confirm the tests were correct against the original UI

Ran `npx playwright test` against the **unmodified** `app.html`: **3 passed** (all three
locators resolved). This proves the tests were written correctly against the UI that existed
at the time, before any "UI change" — the same way a real regression would start from a green
suite.

## Step 2 — the intentional UI change (the actual diff applied to app.html)

```diff
-    <a href="/logout" data-testid="logout-link">Log out</a>
+    <button data-testid="settings-btn" aria-label="Settings">&#9881;</button>
@@
-        <button id="submit-btn" type="submit" data-testid="login-btn">Log in</button>
+        <button id="submit-btn" type="submit" data-testid="login-submit">Log in</button>
@@
-        <li>Widget A <button aria-label="Remove item" data-testid="remove-0">x</button></li>
-        <li>Widget B <button aria-label="Remove item" data-testid="remove-1">x</button></li>
+        <li>Widget A <button aria-label="Delete" data-testid="remove-0">x</button></li>
+        <li>Widget B <button aria-label="Delete" data-testid="remove-1">x</button></li>
```

Three different kinds of break, on purpose, so the skill's confidence-tiering could be
exercised for real rather than asserted in prose:

1. **LOCREPAIR-001**: `data-testid` renamed on the *only* button in its form — the case a
   fix should be proposed for with high confidence.
2. **LOCREPAIR-002**: accessible name renamed *uniformly* across two structurally-identical
   buttons — the case where a fix is still findable, but the confidence and the caveat about
   it must be honest (order-dependent disambiguation).
3. **LOCREPAIR-003**: the target control was **removed entirely** and replaced by an unrelated
   one (a "Settings" button with no textual/structural link to "log out") — the case where no
   fix may be proposed at all.

## Step 3 — the real failure, unmodified test code, no edits to app.spec.js

Ran `npx playwright test` again (zero changes to the test file): **3 failed**, all three with
`Test timeout of 10000ms exceeded.` / "waiting for `<locator>`" — real Playwright output, not
paraphrased. Full console output, `error-context.md` (Playwright's own auto-captured ARIA
snapshot), and the custom `dom-snapshot.html` for each failing test are preserved in
`evidence/LOCREPAIR-00{1,2,3}/`; the JUnit report is `evidence/results-after-break.xml`.

Ground truth read directly from `evidence/LOCREPAIR-003/error-context.md`'s page snapshot
(the case that matters most to get right — proving no fabrication): it lists `navigation`,
`button "Settings"`, `heading`, `textbox`, `button "Log in"`, two `button "Delete"` — **zero**
`link`-role nodes and no element whose name contains "log out" anywhere on the page.

## Applying locator-repair's Method (SKILL.md) to this data

1. Parsed each failure's call log for the engine + arguments (`getByTestId('login-btn')`,
   `getByRole('button', { name: 'Remove item' }).first()`, `getByRole('link', { name: 'Log out' })`)
   — confirmed all three are genuine locator-not-found/timeout failures, not assertion/app
   errors.
2. Searched each failure's DOM/ARIA evidence for candidates sharing role/tag/context/text with
   what the locator targeted.
3. Classified by evidence strength:
   - **LOCREPAIR-001** → 1 candidate (the form's only button, unchanged id/text/position,
     only `data-testid` differs) → **high**.
   - **LOCREPAIR-002** → 2 candidates (both cart buttons, uniformly renamed, DOM order
     unchanged) → **medium**, with the `.first()`/order-dependency caveat and a
     `data-testid`-migration suggestion surfaced rather than hidden.
   - **LOCREPAIR-003** → 0 candidates (no `link` role anywhere, no name containing "log out")
     → **gap**, no diff proposed.
4. Drafted diffs for the `high` and `medium` cases against the page object each selector would
   live in per POM-as-fixtures (D34); wrote no diff for the `gap` case, stating the reason
   instead.

Result: `output/repair-findings.md` and `output/repair-findings.json` — produced by
hand-applying the skill's method to real data, exactly as a session running the skill would.

## Correctness check (would the proposed diffs actually fix the tests?)

- **LOCREPAIR-001**: applying `getByTestId('login-btn')` → `getByTestId('login-submit')` in
  isolation and re-running the login test against the **post-break** `app.html` — confirmed
  green (see below). The proposed fix is correct.
- **LOCREPAIR-002**: applying `getByRole('button', { name: 'Remove item' })` →
  `getByRole('button', { name: 'Delete' })` (keeping `.first()`) and re-running the cart test
  against the post-break `app.html` — confirmed green. The proposed fix is correct, with the
  documented order-dependency caveat still standing as a real, not hypothetical, limitation.
- **LOCREPAIR-003**: no fix was proposed, so there is nothing to verify — correctly so, since
  no candidate exists.

```
$ npx playwright test --grep "LOCREPAIR-001|LOCREPAIR-002" (after hand-editing the two
  locators in app.spec.js to the proposed values, against the already-broken app.html)

Running 2 tests using 1 worker
  ok 1 app.spec.js:21:1 › @QAIA-LOCREPAIR-001-fixed sign in submits the login form (fix applied)
  ok 2 app.spec.js:29:1 › @QAIA-LOCREPAIR-002-fixed remove an item from the cart (fix applied)

  2 passed
```

(This re-run was done to verify the findings for this validation record — the skill itself
never performs it; see Guardrails in `../SKILL.md`.)

## Result

Applied for real to three genuinely different break patterns, the skill's method: (1)
proposed a diff for the unambiguous case, and that diff, once independently applied and
re-run, actually turns the test green again; (2) proposed a diff for the ambiguous-but-uniform
case with an honestly-stated confidence caveat, also verified to work; (3) refused to propose
anything for the case with zero DOM evidence, rather than fabricating a plausible-looking
guess. No diff was applied by the skill itself in any case — every proposal in
`output/repair-findings.md` is unapplied, exactly as `SKILL.md`'s Guardrails require.
