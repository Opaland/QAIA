// automate SKILL.md step 2 (testability precheck), second pass: resolve which DOM node actually
// carries data-test="open-menu" / "close-menu", and whether the drawer container itself exposes
// any role/data-test at all (it must, for getByTestId-first selectors; if it does not, that is a
// testability GAP to report, not to route around).
const { chromium, devices } = require('@playwright/test');

(async () => {
  const browser = await chromium.launch();
  const page = await (await browser.newContext({ ...devices['Pixel 7'] })).newPage();
  await page.goto('https://www.saucedemo.com/');
  await page.getByPlaceholder('Username').fill('standard_user');
  await page.getByPlaceholder('Password').fill('secret_sauce');
  await page.getByRole('button', { name: 'Login' }).click();
  await page.waitForURL('**/inventory.html');

  const describeByTest = (name) => page.evaluate((n) => {
    return [...document.querySelectorAll(`[data-test="${n}"]`)].map((e) => ({
      tag: e.tagName, id: e.id, cls: e.className, text: (e.textContent || '').trim().slice(0, 25),
      role: e.getAttribute('role'), ariaLabel: e.getAttribute('aria-label'),
    }));
  }, name);

  const out = {};
  out.openMenuClosed = await describeByTest('open-menu');
  out.closeMenuClosed = await describeByTest('close-menu');
  out.drawerContainer = await page.evaluate(() => {
    const e = document.querySelector('.bm-menu-wrap');
    return e ? { tag: e.tagName, cls: e.className, dataTest: e.getAttribute('data-test'),
                 role: e.getAttribute('role'), ariaHidden: e.getAttribute('aria-hidden'),
                 hasIdOrTestId: !!(e.id || e.getAttribute('data-testid')) } : null;
  });
  // login page controls
  const p2 = await (await browser.newContext({ ...devices['Pixel 7'] })).newPage();
  await p2.goto('https://www.saucedemo.com/');
  out.loginControls = await p2.evaluate(() =>
    [...document.querySelectorAll('[data-test]')].map((e) => ({ dt: e.getAttribute('data-test'), tag: e.tagName })));
  console.log(JSON.stringify(out, null, 2));
  await browser.close();
})();
