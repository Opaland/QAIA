// Visual design regression — Playwright screenshot snapshots (first run creates baselines).
const { test, expect } = require('./fixtures');

test.describe('MediBook visual', () => {
  test('@QAIA-VIS-001 login screen matches baseline', async ({ page }) => {
    await page.goto('/');
    await expect(page.locator('#login-section')).toHaveScreenshot('login.png', { maxDiffPixelRatio: 0.02 });
  });
  test('@QAIA-VIS-002 booking screen matches baseline', async ({ patient, page }) => {
    await expect(page.locator('#app-section')).toHaveScreenshot('booking.png', { maxDiffPixelRatio: 0.02 });
  });
});
