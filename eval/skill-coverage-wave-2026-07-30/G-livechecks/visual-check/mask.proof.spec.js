// Proof for visual-check guardrail #40 ("mask/freeze, don't rely on tolerance").
// Same footer, same mutation of the genuinely-dynamic copyright line, two snapshots:
//   - unmasked  -> the dynamic text eats real pixels
//   - masked    -> exact, provable 0-pixel diff
// MUTATE=1 rewrites the year, simulating the natural year rollover of `© 2026 Sauce Labs`.
const { test, expect } = require('@playwright/test');

test.beforeEach(async ({ page }) => {
  await page.goto('/');
  await page.locator('#user-name').fill('standard_user');
  await page.locator('#password').fill('secret_sauce');
  await page.locator('#login-button').click();
  await expect(page.locator('.title')).toHaveText('Products');
  if (process.env.MUTATE) {
    await page.locator('[data-test="footer-copy"]').evaluate((el) => {
      el.textContent = el.textContent.replace('2026', '2027');
    });
  }
});

test('@QAIA-VIS-004 footer UNMASKED', async ({ page }) => {
  await expect(page.locator('footer.footer')).toHaveScreenshot('footer-unmasked.png', {
    maxDiffPixelRatio: 0,
  });
});

test('@QAIA-VIS-005 footer MASKED', async ({ page }) => {
  await expect(page.locator('footer.footer')).toHaveScreenshot('footer-masked.png', {
    maxDiffPixelRatio: 0,
    mask: [page.locator('[data-test="footer-copy"]')],
  });
});
