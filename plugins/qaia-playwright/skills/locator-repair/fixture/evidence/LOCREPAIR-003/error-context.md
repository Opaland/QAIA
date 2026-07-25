# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: app.spec.js >> @QAIA-LOCREPAIR-003 log out from the nav
- Location: app.spec.js:34:1

# Error details

```
Test timeout of 10000ms exceeded.
```

```
Error: locator.click: Test timeout of 10000ms exceeded.
Call log:
  - waiting for getByRole('link', { name: 'Log out' })

```

# Page snapshot

```yaml
- generic [active] [ref=e1]:
  - navigation [ref=e2]:
    - button "Settings" [ref=e3]: ⚙
  - main [ref=e4]:
    - generic [ref=e5]:
      - heading "Sign in" [level=1] [ref=e6]
      - generic [ref=e7]:
        - text: Email
        - textbox "Email" [ref=e8]
        - text: Password
        - textbox "Password" [ref=e9]
        - button "Log in" [ref=e10]
    - generic [ref=e11]:
      - heading "Cart" [level=2] [ref=e12]
      - list [ref=e13]:
        - listitem [ref=e14]:
          - text: Widget A
          - button "Delete" [ref=e15]: x
        - listitem [ref=e16]:
          - text: Widget B
          - button "Delete" [ref=e17]: x
```

# Test source

```ts
  1  | const { test, expect } = require('@playwright/test');
  2  | const fs = require('fs');
  3  | const path = require('path');
  4  | 
  5  | // On any failure, dump the live DOM next to Playwright's own artifacts --
  6  | // this is the "current DOM, if available" input locator-repair's method
  7  | // relies on. Not part of the skill itself: a recommended capture pattern a
  8  | // project's playwright.config.js / afterEach can wire up once.
  9  | test.afterEach(async ({ page }, testInfo) => {
  10 |   if (testInfo.status !== testInfo.expectedStatus) {
  11 |     try {
  12 |       const html = await page.content();
  13 |       fs.mkdirSync(testInfo.outputDir, { recursive: true });
  14 |       fs.writeFileSync(path.join(testInfo.outputDir, 'dom-snapshot.html'), html);
  15 |     } catch {
  16 |       // page already closed/crashed -- no DOM to capture, nothing to do
  17 |     }
  18 |   }
  19 | });
  20 | 
  21 | test('@QAIA-LOCREPAIR-001 sign in submits the login form', async ({ page }) => {
  22 |   await page.goto('/app.html');
  23 |   await page.getByTestId('email-input').fill('user@example.com');
  24 |   await page.getByTestId('password-input').fill('secret123');
  25 |   await page.getByTestId('login-btn').click();
  26 |   await expect(page.getByText('Welcome back!')).toBeVisible();
  27 | });
  28 | 
  29 | test('@QAIA-LOCREPAIR-002 remove an item from the cart', async ({ page }) => {
  30 |   await page.goto('/app.html');
  31 |   await page.getByRole('button', { name: 'Remove item' }).first().click();
  32 | });
  33 | 
  34 | test('@QAIA-LOCREPAIR-003 log out from the nav', async ({ page }) => {
  35 |   await page.goto('/app.html');
> 36 |   await page.getByRole('link', { name: 'Log out' }).click();
     |                                                     ^ Error: locator.click: Test timeout of 10000ms exceeded.
  37 | });
  38 | 
```