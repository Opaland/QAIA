const { test, expect } = require('@playwright/test');
const fs = require('fs');
const path = require('path');

// On any failure, dump the live DOM next to Playwright's own artifacts --
// this is the "current DOM, if available" input locator-repair's method
// relies on. Not part of the skill itself: a recommended capture pattern a
// project's playwright.config.js / afterEach can wire up once.
test.afterEach(async ({ page }, testInfo) => {
  if (testInfo.status !== testInfo.expectedStatus) {
    try {
      const html = await page.content();
      fs.mkdirSync(testInfo.outputDir, { recursive: true });
      fs.writeFileSync(path.join(testInfo.outputDir, 'dom-snapshot.html'), html);
    } catch {
      // page already closed/crashed -- no DOM to capture, nothing to do
    }
  }
});

test('@QAIA-LOCREPAIR-001 sign in submits the login form', async ({ page }) => {
  await page.goto('/app.html');
  await page.getByTestId('email-input').fill('user@example.com');
  await page.getByTestId('password-input').fill('secret123');
  await page.getByTestId('login-btn').click();
  await expect(page.getByText('Welcome back!')).toBeVisible();
});

test('@QAIA-LOCREPAIR-002 remove an item from the cart', async ({ page }) => {
  await page.goto('/app.html');
  await page.getByRole('button', { name: 'Remove item' }).first().click();
});

test('@QAIA-LOCREPAIR-003 log out from the nav', async ({ page }) => {
  await page.goto('/app.html');
  await page.getByRole('link', { name: 'Log out' }).click();
});
