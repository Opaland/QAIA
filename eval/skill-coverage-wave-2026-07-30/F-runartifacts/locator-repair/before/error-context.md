# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: e2e.dynamic-loading.spec.js >> the-internet — Dynamically Loaded Page Elements (US-EVAL-006) >> @QAIA-US-EVAL-006-004 @AC6 @P2 Example 2 Hello World element is created and shown after the delay elapses
- Location: e2e.dynamic-loading.spec.js:48:3

# Error details

```
Error: expect(locator).toBeVisible() failed

Locator: getByTestId('finish-message')
Expected: visible
Timeout: 8000ms
Error: element(s) not found

Call log:
  - Expect "toBeVisible" with timeout 8000ms
  - waiting for getByTestId('finish-message')

```

```yaml
- link "Fork me on GitHub":
  - /url: https://github.com/tourdedave/the-internet
  - img "Fork me on GitHub"
- heading "Dynamically Loaded Page Elements" [level=3]
- 'heading "Example 2: Element rendered after the fact" [level=4]'
- heading "Hello World!" [level=4]
- separator
- text: Powered by
- link "Elemental Selenium":
  - /url: http://elementalselenium.com/
```

# Test source

```ts
  1  | // E2E — maps QAIA Gherkin scenarios (US-EVAL-006) to executable Playwright tests.
  2  | // Source testbook: eval/skill-eval-campaign-2026-07-29/US-EVAL-006-the-internet-dynamic-loading/
  3  | //   testbooks/dynamic-loading.feature
  4  | // Each test title cites its stable scenario ID + AC tag for requirement traceability.
  5  | // Real browser automation against the public the-internet.herokuapp.com instance
  6  | // (per docs/DEMO-TARGETS.md: UI only, security/perf explicitly out of scope for this target).
  7  | const { test, expect } = require('./fixtures');
  8  | 
  9  | test.describe('the-internet — Dynamically Loaded Page Elements (US-EVAL-006)', () => {
  10 | 
  11 |   test('@QAIA-US-EVAL-006-001 @AC3 @P2 Example 1 hidden element not visible before the delay elapses', async ({ dynamicLoadingPage, page }) => {
  12 |     await dynamicLoadingPage.goto(1);
  13 |     const clickedAt = Date.now();
  14 |     await dynamicLoadingPage.clickStart();
  15 | 
  16 |     // Assert immediately (well under the 5000ms boundary — Q2's lower-bound reading).
  17 |     await expect(dynamicLoadingPage.finish).toBeHidden();
  18 |     await expect(dynamicLoadingPage.loadingIndicator).toBeVisible();
  19 | 
  20 |     const elapsedMs = Date.now() - clickedAt;
  21 |     console.log(`[timing] scenario 001: assertions completed ${elapsedMs}ms after click (< 5000ms required)`);
  22 |     expect(elapsedMs).toBeLessThan(5000);
  23 |   });
  24 | 
  25 |   test('@QAIA-US-EVAL-006-002 @AC4 @P2 Example 2 has no Hello World element in the DOM before any click', async ({ dynamicLoadingPage }) => {
  26 |     await dynamicLoadingPage.goto(2);
  27 | 
  28 |     // Presence check (not visibility) — the element must not exist in the DOM at all.
  29 |     await expect(dynamicLoadingPage.finish).toHaveCount(0);
  30 |     await expect(dynamicLoadingPage.startButton).toBeVisible();
  31 |   });
  32 | 
  33 |   test('@QAIA-US-EVAL-006-003 @AC6 @P1 Example 2 Hello World element still does not exist before the delay elapses', async ({ dynamicLoadingPage }) => {
  34 |     await dynamicLoadingPage.goto(2);
  35 |     const clickedAt = Date.now();
  36 |     await dynamicLoadingPage.clickStart();
  37 | 
  38 |     // Stricter than scenario 001: absence from the DOM, not merely hidden (Example 2 creates
  39 |     // the #finish node only inside the setTimeout callback — see page's inline JS).
  40 |     await expect(dynamicLoadingPage.finish).toHaveCount(0);
  41 |     await expect(dynamicLoadingPage.loadingIndicator).toBeVisible();
  42 | 
  43 |     const elapsedMs = Date.now() - clickedAt;
  44 |     console.log(`[timing] scenario 003: assertions completed ${elapsedMs}ms after click (< 5000ms required)`);
  45 |     expect(elapsedMs).toBeLessThan(5000);
  46 |   });
  47 | 
  48 |   test('@QAIA-US-EVAL-006-004 @AC6 @P2 Example 2 Hello World element is created and shown after the delay elapses', async ({ dynamicLoadingPage }) => {
  49 |     await dynamicLoadingPage.goto(2);
  50 |     const clickedAt = Date.now();
  51 |     await dynamicLoadingPage.clickStart();
  52 | 
  53 |     // Wait past the 5000ms lower bound (Q2) via Playwright's own auto-retrying assertion —
  54 |     // no fixed sleep, polls until the element exists and is visible or the explicit timeout trips.
> 55 |     await expect(dynamicLoadingPage.finish).toBeVisible({ timeout: 8000 });
     |                                             ^ Error: expect(locator).toBeVisible() failed
  56 |     await expect(dynamicLoadingPage.finish).toHaveText('Hello World!');
  57 |     await expect(dynamicLoadingPage.loadingIndicator).toBeHidden();
  58 | 
  59 |     const elapsedMs = Date.now() - clickedAt;
  60 |     console.log(`[timing] scenario 004: element revealed ${elapsedMs}ms after click (>= 5000ms expected)`);
  61 |     expect(elapsedMs).toBeGreaterThanOrEqual(5000);
  62 |   });
  63 | });
  64 | 
```