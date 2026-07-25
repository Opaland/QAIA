# locator-repair findings — fixture run (2026-07-25)

Produced by hand-applying `../../SKILL.md`'s Method to the three real failures captured in
`../evidence/` (see `../VALIDATION.md` for how they were produced). **No diff below has been
applied** — proposals only, for human review.

## @QAIA-LOCREPAIR-001 — sign in submits the login form

- Broken locator: `getByTestId('login-btn')` (timeout)
- Confidence: **high** (1 plausible candidate)
- Evidence: the only `<button>` in `#login-form` keeps its `id="submit-btn"`, its text
  ("Log in"), and its position; only `data-testid` changed, from `login-btn` to `login-submit`.
- Target: `pages/LoginPage.js`

```diff
--- a/pages/LoginPage.js
+++ b/pages/LoginPage.js
@@
-  this.submitButton = page.getByTestId('login-btn');
+  this.submitButton = page.getByTestId('login-submit');
```

## @QAIA-LOCREPAIR-002 — remove an item from the cart

- Broken locator: `getByRole('button', { name: 'Remove item' }).first()` (timeout)
- Confidence: **medium** (2 structurally-identical candidates, disambiguated by DOM order)
- Evidence: both cart-row buttons lost the name "Remove item" and gained the identical new
  name "Delete" — a uniform rename, not two unrelated changes.
- Target: `pages/CartPage.js`

```diff
--- a/pages/CartPage.js
+++ b/pages/CartPage.js
@@
-  this.removeItemButton = page.getByRole('button', { name: 'Remove item' }).first();
+  this.removeItemButton = page.getByRole('button', { name: 'Delete' }).first();
```

**Caveat, not glossed over**: this keeps the test's pre-existing `.first()` (DOM-order)
disambiguation — the correspondence between "old first match" and "new first match" is
inferred from unchanged order, not a stronger identity signal. Both buttons already carry a
stable `data-testid` (`remove-0`/`remove-1`) untouched by this change; migrating to
`getByTestId` would remove the order-dependency and is recommended as a **follow-up**, not
bundled into this diff.

## @QAIA-LOCREPAIR-003 — log out from the nav

- Broken locator: `getByRole('link', { name: 'Log out' })` (timeout)
- Confidence: **gap — no diff proposed**
- Evidence: the current DOM/ARIA snapshot has **zero** `link`-role elements anywhere on the
  page, and no element of any role whose accessible name contains "log out"/"logout". The
  nav's only remaining control is an unrelated "Settings" button.
- Target: `pages/NavPage.js` (unresolved)

No fix is proposed. Proposing the Settings button as a renamed logout link would be a guess,
not evidence — the discipline this skill exists to hold (D38). **A human needs to confirm**
whether logout moved (e.g. behind a menu not visible in this snapshot), was removed, or is
broken upstream.
