// Follow-up: probe-logout.js counted 1 "visible" logout control while the drawer was closed.
// Verify honestly whether a logout route exists OUTSIDE the drawer on a phone viewport,
// instead of asserting "the drawer is the only route".
const { webkit, devices } = require('@playwright/test');

(async () => {
  const browser = await webkit.launch();
  const page = await (await browser.newContext({ ...devices['iPhone 13'] })).newPage();
  await page.goto('https://www.saucedemo.com/');
  await page.getByPlaceholder('Username').fill('standard_user');
  await page.getByPlaceholder('Password').fill('secret_sauce');
  await page.getByRole('button', { name: 'Login' }).click();
  await page.waitForURL('**/inventory.html');

  const hits = await page.evaluate(() => {
    return [...document.querySelectorAll('a,button')]
      .filter((e) => /logout|sign\s*out/i.test(e.textContent || ''))
      .map((e) => {
        const b = e.getBoundingClientRect();
        const cs = getComputedStyle(e);
        return {
          tag: e.tagName, id: e.id, text: (e.textContent || '').trim(),
          rect: [Math.round(b.x), Math.round(b.y), Math.round(b.width), Math.round(b.height)],
          display: cs.display, visibility: cs.visibility,
          insideDrawer: !!e.closest('.bm-menu-wrap'),
          drawerAriaHidden: document.querySelector('.bm-menu-wrap').getAttribute('aria-hidden'),
        };
      });
  });
  // Playwright's own visibility oracle, which is what a test would use:
  const pwVisible = await page.locator('#logout_sidebar_link').isVisible();
  console.log(JSON.stringify({ domHits: hits, playwrightIsVisibleWhileDrawerClosed: pwVisible }, null, 2));
  await browser.close();
})();
