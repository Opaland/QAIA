// Testability precheck (automate SKILL.md step 2): are the elements the mobile scenarios touch
// reachable by role / data-test, or only by id/class (a gap to report, never routed around)?
const { chromium, devices } = require('@playwright/test');

(async () => {
  const browser = await chromium.launch();
  const page = await (await browser.newContext({ ...devices['Pixel 7'] })).newPage();
  await page.goto('https://www.saucedemo.com/');
  await page.getByPlaceholder('Username').fill('standard_user');
  await page.getByPlaceholder('Password').fill('secret_sauce');
  await page.getByRole('button', { name: 'Login' }).click();
  await page.waitForURL('**/inventory.html');
  await page.locator('#react-burger-menu-btn').click();
  await page.waitForTimeout(700);

  const info = await page.evaluate(() => {
    const describe = (sel) => {
      const e = document.querySelector(sel);
      if (!e) return { sel, found: false };
      return {
        sel, found: true, tag: e.tagName, id: e.id,
        dataTest: e.getAttribute('data-test'), dataTestId: e.getAttribute('data-testid'),
        role: e.getAttribute('role'), ariaLabel: e.getAttribute('aria-label'),
        text: (e.textContent || '').trim().slice(0, 30),
      };
    };
    const allDataTest = [...new Set([...document.querySelectorAll('[data-test]')].map((e) => e.getAttribute('data-test')))];
    return {
      burger: describe('#react-burger-menu-btn'),
      close: describe('#react-burger-cross-btn'),
      drawer: describe('.bm-menu-wrap'),
      logout: describe('#logout_sidebar_link'),
      cart: describe('.shopping_cart_link'),
      sort: describe('[data-test="product-sort-container"]'),
      dataTestAttributesOnPage: allDataTest,
    };
  });
  console.log(JSON.stringify(info, null, 2));
  await browser.close();
})();
