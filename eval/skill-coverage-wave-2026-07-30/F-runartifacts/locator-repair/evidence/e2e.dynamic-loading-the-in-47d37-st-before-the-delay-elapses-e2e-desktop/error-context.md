# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: e2e.dynamic-loading.spec.js >> the-internet — Dynamically Loaded Page Elements (US-EVAL-006) >> @QAIA-US-EVAL-006-003 @AC6 @P1 Example 2 Hello World element still does not exist before the delay elapses
- Location: e2e.dynamic-loading.spec.js:33:3

# Error details

```
Test timeout of 15000ms exceeded.
```

```
Error: locator.click: Test timeout of 15000ms exceeded.
Call log:
  - waiting for getByRole('button', { name: 'Start loading' })

```

# Page snapshot

```yaml
- generic [active] [ref=e1]:
  - generic [ref=e4]:
    - link "Fork me on GitHub":
      - /url: https://github.com/tourdedave/the-internet
      - img "Fork me on GitHub" [ref=e5] [cursor=pointer]
    - generic [ref=e7]:
      - heading "Dynamically Loaded Page Elements" [level=3] [ref=e8]
      - 'heading "Example 2: Element rendered after the fact" [level=4] [ref=e9]'
      - button "Start" [ref=e11] [cursor=pointer]
  - generic [ref=e13]:
    - separator [ref=e14]
    - generic [ref=e15]:
      - text: Powered by
      - link "Elemental Selenium" [ref=e16] [cursor=pointer]:
        - /url: http://elementalselenium.com/
```

# Test source

```ts
  1  | // Page Object — "Dynamically Loaded Page Elements" (Examples 1 & 2, the-internet.herokuapp.com).
  2  | // Selectors only, no assertions (assertions live in tests) — automate skill rule (T2/POM-as-fixtures).
  3  | exports.DynamicLoadingPage = class DynamicLoadingPage {
  4  |   constructor(page) {
  5  |     this.page = page;
  6  |     // Both examples share the same fragment structure: #start > button, #loading (inserted on
  7  |     // click), #finish (Example 1: pre-existing, display:none; Example 2: does not exist until
  8  |     // the setTimeout callback inserts it into the DOM).
  9  |     // DELIBERATELY BROKEN (locator-repair evaluation, 2026-07-30): the accessible name of the
  10 |     // real control is "Start", not "Start loading". Kept role-based (T2) so the failure is a
  11 |     // genuine getByRole locator-not-found/timeout, not a CSS typo.
  12 |     this.startButton = page.getByRole('button', { name: 'Start loading' });
  13 |     this.loadingIndicator = page.locator('#loading');
  14 |     this.finish = page.locator('#finish');
  15 |   }
  16 | 
  17 |   async goto(exampleNumber) {
  18 |     await this.page.goto(`/dynamic_loading/${exampleNumber}`);
  19 |   }
  20 | 
  21 |   async clickStart() {
> 22 |     await this.startButton.click();
     |                            ^ Error: locator.click: Test timeout of 15000ms exceeded.
  23 |   }
  24 | };
  25 | 
```