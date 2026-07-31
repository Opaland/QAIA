# traceability — US-EVAL-013 (`automate`, step 8)

Mobile = **browser emulation only** (Playwright device descriptors), per **D100**. Native
iOS/Android (Appium, real devices) is out of scope for v1 and is **not** faked here. What follows
is what was really executed, on two engines, against the live public target.

## Testability precheck (`automate` SKILL.md step 2 — run BEFORE generating anything)

Measured with `probe-testability.js` and `probe-testids.js` (real runs, output in the session log),
not assumed.

| # | Axis | Finding | Decision |
|---|---|---|---|
| **TG-1** | Observability | The **drawer container itself** (`.bm-menu-wrap`, a third-party `react-burger-menu` wrapper) exposes **no `role`, no `data-test`, no `id`** — measured: `{ dataTest: null, role: null, hasIdOrTestId: false }`. `aria-hidden`, the state AC4 asserts on, lives on that same unaddressable wrapper. | **Reported, not routed around.** The page object uses the stable semantic class `.bm-menu-wrap` — a declared deviation from the "role / `data-testid` only" rule (SKILL.md line 19), *not* positional XPath (which the rules forbid outright). SUT-side fix: `data-test="nav-drawer"` + `role="dialog"`. |
| **TG-2** | Observability | The **cart badge** (`.shopping_cart_badge`) likewise carries no `data-test`; only its parent link (`shopping-cart-link`) does. | Same treatment as TG-1: class locator, declared here. |
| **TG-3** | Controllability | **No API and no seed endpoint** on this SUT. The naive path is a UI-chained login in every test — which the atomic-preconditions rule (SKILL.md line 21) forbids. | **Solved declaratively, measured** (`probe-seed.js`): a real sign-in stores exactly one cookie, `session-username=standard_user`. Injecting it into a fresh context and requesting `/inventory.html` gives `{ inventoryVisible: true, error: null }`. The `signedIn` fixture does that. Only `-017` (the journey, where the form *is* the behaviour under test) and the sign-out scenarios drive the UI. |
| **TG-4** | Observability | `data-test="open-menu"` / `"close-menu"` sit on the **`<img class="bm-icon">` inside** the button, not on the button itself — so `getByTestId` would resolve the icon, while the 20×20 px target AC7 measures is the *button*. | The two controls do expose accessible names ("Open Menu" / "Close Menu"), so the page object is **role-first**: `getByRole('button', { name: 'Open Menu' })`. No gap remains. |

**No testability gap blocked any scenario.** 0 scenarios blocked-for-assertion (step 5), 0 `TODO(automate)` markers written.

## Structure (`automate` SKILL.md line 19 / D34 — POM-as-fixtures, honoured)

```
automation/
  fixtures.js                  # test.extend: loginPage, inventoryPage, drawer, signedIn
  pages/LoginPage.js           # selectors + actions only, ZERO expect()
  pages/InventoryPage.js       #   "
  pages/NavigationDrawer.js    #   "
  tests/e2e.mobile-drawer.spec.js
  tests/e2e.mobile-session.spec.js
  tests/e2e.mobile-sort.spec.js
  playwright.config.js         # retries: 0, testIdAttribute 'data-test', 3 projects
  ci/github-actions.yml        # instantiated from the shipped template
```

`grep -c expect pages/*.js` → **0** in all three page objects. Assertions live only in specs.

## Device descriptors actually used (the point of this run)

| Project | Descriptor | Engine | Viewport | Flags |
|---|---|---|---|---|
| `e2e-mobile-iphone` | `devices['iPhone 13']` | **webkit** | 390×844 @3× | `isMobile`, `hasTouch` |
| `e2e-mobile-pixel` | `devices['Pixel 7']` | **chromium** | 412×915 @2.625× | `isMobile`, `hasTouch` |
| `e2e-desktop` | `devices['Desktop Chrome']` | chromium | 1280×720 | — |

Both mobile projects run on the descriptor's **own** `defaultBrowserType`. Running both on one
engine would only be window-resizing, not mobile emulation (`state/01-extraction.md` BR3).
Touch input uses `locator.tap()` / `page.touchscreen.tap()`, not `click()` — real touch events,
available only because the descriptors set `hasTouch`.

## Real run — final

Command (real subprocess, no simulation):

```
cd eval/skill-coverage-wave-2026-07-30/US-EVAL-013-mobile/automation && npx playwright test
```

Verbatim tail:

```
  42 passed (20.2s)
```

**42 = 21 test blocks × 2 device descriptors.** (17 Gherkin scenarios; the 4 `Scenario Outline`
example rows expand to separate blocks.)

## AC → scenario → test → result

| AC | Scenario | Test block | iPhone 13 (webkit) | Pixel 7 (chromium) |
|---|---|---|---|---|
| AC1 | `-001` (479, 480) | `e2e.mobile-drawer.spec.js:12` | ✅ ✅ | ✅ ✅ |
| AC1 | `-003` (320, 390) | `e2e.mobile-drawer.spec.js:22` | ✅ ✅ | ✅ ✅ |
| AC2 | `-002` (481) | `e2e.mobile-drawer.spec.js:31` | ✅ | ✅ |
| AC3 | `-004` (occlusion, `[req-neg]`) | `e2e.mobile-drawer.spec.js:41` | ✅ | ✅ |
| AC3 | `-005` (control cell) | `e2e.mobile-drawer.spec.js:56` | ✅ | ✅ |
| AC4 | `-006` / `-007` / `-008` | `e2e.mobile-drawer.spec.js:67/75/83` | ✅ ✅ ✅ | ✅ ✅ ✅ |
| AC4 | `-009` (sole route to logout) | `e2e.mobile-drawer.spec.js:92` | ✅ | ✅ |
| AC5 | `-010` | `e2e.mobile-session.spec.js:8` | ✅ | ✅ |
| AC5 | `-011` / `-012` (`[req-neg]`) | `e2e.mobile-session.spec.js:17/29` | ✅ ✅ | ✅ ✅ |
| AC5 | `-013` (cart, checkout-step-one) | `e2e.mobile-session.spec.js:38` | ✅ ✅ | ✅ ✅ |
| AC6 | `-014` (899, 900) | `e2e.mobile-sort.spec.js:7` | ✅ ✅ | ✅ ✅ |
| AC6 | `-015` (sort persistence) | `e2e.mobile-sort.spec.js:16` | ✅ | ✅ |
| AC7 | `-016` (WCAG 2.2 SC 2.5.8) | `e2e.mobile-drawer.spec.js:103` | ✅ | ✅ |
| AC1+4+5 | `-017` (journey, `@smoke`) | `e2e.mobile-session.spec.js:46` | ✅ | ✅ |

**Coverage: 7/7 ACs, 17/17 scenarios automated, 0 blocked.**

## Exit criterion T17 (`automate` SKILL.md line 48 — reported, never self-certified)

- **P1 executable without manual rework: 11/11 = 100 %** (per descriptor; 22/22 across both).
- The suite met that ratio **only after one real code fix** (F-1 below) — the ratio is reported
  post-fix, and the pre-fix run (2 red) is reported alongside it rather than erased.
- **T17 is NOT claimed met.** T17's own wording is "measured on a real pilot application";
  SauceDemo is a public demo, i.e. an intermediate development target. Clearing T17 remains a
  pilot + human gate.

## F-1 — real defect found by the run, in the generated code (not by inspection)

**First run: 40 passed, 2 failed** — `@QAIA-US-EVAL-013-004`, on **both** engines, at
`expect(topmost.insideDrawer).toBe(true)`.

Diagnosis (`probe-004-diagnosis.js`, real output):

```json
"drawerBox":   { "x": -412, "y": 0, "w": 412, "h": 839 },
"viewport":    { "width": 412, "height": 839 },
"atCentreCapturedBeforeOpen": { "hit": { "cls": "inventory_item_description", "insideDrawer": false } }
```

`aria-hidden` on `.bm-menu-wrap` flips to `"false"` **the instant the burger is tapped**, while the
drawer is still **entirely off-screen** (`x = -412` on a 412 px viewport). The first generated
`NavigationDrawer.open()` waited on that attribute, so the test asserted against a drawer that had
been *asked* to open but had not arrived. Fixed by waiting on rendered **geometry**
(`rect.left >= 0`), not on the attribute — and deliberately **not** by a `waitForTimeout`, which is
precisely the flakiness `flaky-detect` exists to surface. Second run: **42 passed**.

### Upstream consequence — the test book's chosen oracle for AC4 is weak

`saucedemo-mobile-navigation.feature` scenarios `-006`/`-007`/`-008` assert *"the drawer reports
`aria-hidden` `false`/`true`"*. F-1 proves that attribute is **true up to ~half a second before the
drawer is actually visible**, so those three scenarios would pass against a drawer that never
finishes opening. The tests are faithful to the Gherkin, so they are green — the weakness is in the
`Then`, one layer upstream. Raised here for arbitration; **the `.feature` was not edited** (the
`ARRÊT` gate has not been crossed, and `testbook-validate` is audit-only).

## Self-review before writing (`automate` SKILL.md step 5) — result

Re-scanned every `expect()` before the specs were written:

- tautological / reflexive comparisons: **0**
- contentless `expect()` on a literal: **0**
- weak-by-construction matchers (`.toBeDefined()` / `.not.toBeNull()` on a locator): **0** — every
  assertion reads SUT state (`toHaveAttribute`, `toHaveText`, `toHaveValue`, `toHaveCount`,
  `toHaveURL`, `toBeVisible`, or a measured `boundingBox()` number)
- zero-assertion blocks: **0** — all 21 blocks assert

**One weak assertion is disclosed rather than hidden**: in `-004`, `expect(cartBadge).toHaveCount(0)`
is a genuine but *low-discrimination* check — `probe-004-diagnosis.js` shows the card centre lands
on `inventory_item_description`, not on the Add-to-cart button, so the badge would stay at 0 even
with the drawer closed. The *discriminating* assertion in that test is `topmost.insideDrawer`, which
is the one that actually failed and then passed. The Gherkin's `Then` names both, so both are kept;
the limitation is recorded here instead of being passed off as strong coverage.
