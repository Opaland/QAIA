---
stepsCompleted: [00-ingest]
lastStep: 00-ingest
lastSaved: 2026-07-30
---

# 00-source — US-EVAL-013 (mobile / responsive angle)

- **Source type**: live public application, explored under **browser emulation only** (device
  descriptors + explicit viewport sizes). Not a written ticket — no spec document exists for this
  target, so the acceptance criteria in `01-extraction.md` are **`[reconstructed]` from observed
  behaviour**, and every one of them cites the measurement that produced it.
- **Designated target**: `SauceDemo` (`https://www.saucedemo.com/`) — `docs/DEMO-TARGETS.md`
  line 18: `| SauceDemo | ❌ | ✅ | ❌ | +native demo app | ❌ | ❌ | ⚠ | ✅ |`.
- **Capture date**: 2026-07-30.
- **Credentials used**: the demo's own publicly published credentials, printed on its login page
  (`standard_user` / `secret_sauce`). Not a secret; not persisted anywhere but here, where the
  target itself publishes them. No `.env`, no real user account.

## Scope guard read BEFORE ingesting (D100)

`docs/DECISIONS.md` D100: *"mobile = émulation navigateur (device descriptors Playwright), natif
iOS/Android explicitement hors scope v1"*. This run therefore:

- exercises **only** Playwright device descriptors and viewport sizes — never Appium, never a real
  device, never the SauceLabs *My Demo App* React-Native target that `docs/DEMO-TARGETS.md`
  line 24 names as the native option;
- runs **no `perf-check` and no `security-surface`** against `www.saucedemo.com` — it is a shared
  third-party demo, not self-hosted (`docs/DEMO-TARGETS.md` golden rule; the SauceDemo row marks
  both ❌ anyway). Recorded here at ingestion, not discovered at step 8.

## What was actually observed (real runs, raw output in `automation/probe-*.js` + this run's log)

All figures below are **rendered measurements** (`getBoundingClientRect`) from real headless runs,
not guesses.

### Drawer footprint vs viewport width (`probe-breakpoint.js`, `probe-drawer-boundary.js`)

| viewport width | `.bm-menu-wrap` width when open | % of viewport | catalogue still visible beside it |
|---|---|---|---|
| 320 | 320 | 100 % | no |
| 390 | 390 | 100 % | no |
| 479 | 479 | 100 % | no |
| 480 | 480 | 100 % | no |
| 481 | 300 | 62 % | yes |
| 520 | 300 | 58 % | yes |
| 560 | 300 | 54 % | yes |
| 600 | 300 | 50 % | yes |
| 639 | 300 | 47 % | yes |
| 640 | 300 | 47 % | yes |
| 641 | 300 | 47 % | yes |
| 900 | 300 | 33 % | yes |
| 1280 | 300 | 23 % | yes |

→ **Observed breakpoint: 480 / 481.**

### Product-sort control width (`probe-breakpoint.js`)

| viewport width | `[data-test="product-sort-container"]` rendered width |
|---|---|
| 320 … 899 | 40 px (height 30 px) |
| 900 … 1280 | 223 px (height 30 px) |

→ **Observed breakpoint: 899 / 900.**

### Grid columns and overflow (`probe-breakpoint.js`)

| viewport width | distinct card `x` positions (= columns) | `scrollWidth > clientWidth` |
|---|---|---|
| 320, 375, 390, 479, 480, 481, 500, 639, 640, 641, 700, 899, 900, 901, 960, 1024, 1060 | 1 | false |
| 1280 | 2 | false |

→ The grid stays **single-column all the way up to 1060 px** and only becomes 2 columns by 1280 —
i.e. "the grid collapses to one column on mobile" is **not** a phone-specific behaviour here. It is
the *tablet and small-desktop* behaviour too. Recorded because it contradicts the intuitive
responsive story and would have produced a wrong AC if assumed rather than measured.

### Touch-target dimensions (`probe-breakpoint.js`, all widths 320 → 1280)

| control | width × height, every viewport measured |
|---|---|
| burger (`#react-burger-menu-btn`, text "Open Menu") | 20 × 20 CSS px |
| cart (`[data-test="shopping-cart-link"]`) | 40 × 40 CSS px |

→ **No viewport-adaptive enlargement.** The 20 × 20 burger is the primary (and only) navigation
control on a phone.

### Drawer occlusion (`probe-occlusion.js`)

With the drawer open, `document.elementFromPoint` at the first product card's centre returns:

| viewport | topmost element at the card's centre | inside drawer |
|---|---|---|
| 390 | `NAV.bm-item-list` | yes |
| 480 | `NAV.bm-item-list` | yes |
| 481 | `NAV.bm-item-list` | yes (the card centre falls under the 300 px panel at this width) |
| 1280 | `DIV.inventory_item_desc` | no |

→ At 481 the *card centre* still lands under the 300 px panel, so occlusion at that single point is
**not** a clean discriminator of the breakpoint. The drawer *width* is. Noted so the boundary
scenarios assert on width, not on this weaker signal.

### Device descriptors actually shipped by Playwright 1.62.1 (`probe-occlusion.js`)

| descriptor | viewport | isMobile | hasTouch | DSF | default engine |
|---|---|---|---|---|---|
| `iPhone 13` | 390 × 664 | true | true | 3 | **webkit** |
| `Pixel 7` | 412 × 839 | true | true | 2.625 | chromium |
| `iPad Mini` | 768 × 1024 | true | true | 2 | webkit |
| `Desktop Chrome` | 1280 × 720 | false | false | 1 | chromium |

### Logout route and refusal (`probe-logout.js`, `probe-logout2.js`, iPhone 13 / WebKit)

- Elements in the DOM whose text matches `/logout|sign out/i`: **exactly 1**, `#logout_sidebar_link`
  (`data-test="logout-sidebar-link"`), and `insideDrawer: true`. → On a phone, **the drawer is the
  only route to Logout**.
- After tapping it: URL becomes `https://www.saucedemo.com/`.
- Then requesting `https://www.saucedemo.com/inventory.html` directly: URL stays
  `https://www.saucedemo.com/` and `[data-test="error"]` reads, verbatim:

  > `Epic sadface: You can only access '/inventory.html' when you are logged in.`

- **Automation trap found while probing** (kept, not smoothed over): while the drawer is *closed*
  (`aria-hidden="true"`), `#logout_sidebar_link` still has a real box — `rect [-366, 136, 342, 41]`,
  `display: block`, `visibility: visible` — it is merely translated off-canvas. Playwright's
  `locator.isVisible()` returns **`true`** for it in that state. Any scenario asserting "the menu is
  closed" via `toBeVisible()`/`not.toBeVisible()` on a drawer item is a false oracle on this target.

## Not confirmed by any source found

- Whether the 480/481 and 899/900 breakpoints are **intended** values or incidental — no spec,
  no changelog, no public design doc for SauceDemo. They are observed, not sourced.
- Whether the 20 × 20 burger target is a deliberate product decision or an oversight.
- Landscape/orientation behaviour (`screen.orientation`, `orientationchange`) — **not explored**:
  Playwright device descriptors expose a portrait viewport, and rotating means supplying a second
  descriptor/viewport, which is a different question from "does the app react to an orientation
  event". Left as an explicit gap rather than guessed.
- Real touch gestures (swipe-to-open the drawer, pinch-zoom, `touchstart` handlers) — the
  `hasTouch: true` descriptors were used, but no gesture beyond `tap` was exercised.

## Not fabricated here

Every "not confirmed" point above is carried to `need-understanding` as a numbered question, never
resolved silently.

## Redaction

Nothing to redact. No PII observed; the only credentials involved are the ones the target itself
prints on its own login page as public demo credentials.

## Dependencies (out-of-slice)

- Checkout / payment flow on a phone viewport — a separate US; this slice stops at the catalogue
  and the navigation drawer.
- Per-user variants (`problem_user`, `visual_user`, `performance_glitch_user`) — separate US; this
  slice uses `standard_user` only.
- Sorting *semantics* (does "Price low to high" actually sort?) — a separate, viewport-independent
  US. This slice only covers the sort control's **rendered footprint** on a narrow viewport, which
  is the mobile-specific part.

## Gates

| Gate | Outcome |
|---|---|
| Empty / whitespace | not fired — real, reachable application |
| Not a testable requirement | not fired — a real, observable responsive behaviour |
| Abuse / illegality | not fired — read-only exploration of a demo published for testing, using its own published credentials; no perf/security probing |
| Scale / decomposition | not fired — one story, 7 ACs, all on the same narrow-viewport navigation slice |
| ~20k token limit | not fired |
| Sensitive-data redaction | ran, 0 items masked |

## US-ID

`US-EVAL-013`. ⚠ VALIDATION (step 4) and ⚠ VALIDATION (step 6) — **no human in this session**:
recorded as `pending-validation`, not as an accepted confirmation.

## Journey

| Step | Status |
|---|---|
| 00-ingest | done — gates checked, redaction ran (0 items), US-ID `US-EVAL-013` **pending-validation** |
