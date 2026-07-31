// automate SKILL.md step 2 (controllability half): the "atomic preconditions" rule forbids a
// UI-chained setup. SauceDemo exposes no API/seed endpoint, so the question is whether the
// signed-in precondition can be seeded DECLARATIVELY (cookie injected into a fresh context)
// instead of replaying the login form in every test. Measured, not assumed.
const { chromium, devices, selectors } = require('@playwright/test');

(async () => {
  // SauceDemo publishes `data-test`, not Playwright's default `data-testid`.
  selectors.setTestIdAttribute('data-test');
  const browser = await chromium.launch();
  const out = {};

  // What does a real login actually store?
  {
    const ctx = await browser.newContext({ ...devices['Pixel 7'] });
    const page = await ctx.newPage();
    await page.goto('https://www.saucedemo.com/');
    await page.getByTestId('username').fill('standard_user');
    await page.getByTestId('password').fill('secret_sauce');
    await page.getByTestId('login-button').click();
    await page.waitForURL('**/inventory.html');
    out.cookiesAfterLogin = await ctx.cookies();
    out.storageAfterLogin = await page.evaluate(() => ({
      local: Object.entries(localStorage), session: Object.entries(sessionStorage),
    }));
    await ctx.close();
  }

  // Can that state be injected declaratively into a fresh context?
  {
    const ctx = await browser.newContext({ ...devices['Pixel 7'] });
    await ctx.addCookies(out.cookiesAfterLogin);
    const page = await ctx.newPage();
    await page.goto('https://www.saucedemo.com/inventory.html');
    await page.waitForTimeout(500);
    out.seeded = {
      url: page.url(),
      inventoryVisible: await page.getByTestId('inventory-list').isVisible().catch(() => false),
      error: await page.getByTestId('error').textContent().catch(() => null),
    };
    await ctx.close();
  }

  console.log(JSON.stringify(out, null, 2));
  await browser.close();
})();
