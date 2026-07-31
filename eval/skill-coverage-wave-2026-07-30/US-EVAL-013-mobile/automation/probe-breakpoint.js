// Exploration probe (us-ingest step 1 / istqb-design step 2 boundary derivation).
// Black-box: measures the RENDERED column count of the SauceDemo inventory grid
// across a sweep of viewport widths. No stylesheet reading, no source reading.
const { chromium } = require('@playwright/test');

(async () => {
  const browser = await chromium.launch();
  const ctx = await browser.newContext({ viewport: { width: 1280, height: 800 } });
  const page = await ctx.newPage();
  await page.goto('https://www.saucedemo.com/');
  await page.getByPlaceholder('Username').fill('standard_user');
  await page.getByPlaceholder('Password').fill('secret_sauce');
  await page.getByRole('button', { name: 'Login' }).click();
  await page.waitForURL('**/inventory.html');

  const widths = [320, 375, 390, 479, 480, 481, 500, 639, 640, 641, 700, 899, 900, 901, 960, 1024, 1060, 1280];
  const rows = [];
  for (const w of widths) {
    await page.setViewportSize({ width: w, height: 844 });
    await page.waitForTimeout(120);
    const m = await page.evaluate(() => {
      const items = [...document.querySelectorAll('.inventory_item')];
      const xs = [...new Set(items.map((e) => Math.round(e.getBoundingClientRect().x)))];
      const de = document.documentElement;
      const sort = document.querySelector('[data-test="product-sort-container"]').getBoundingClientRect();
      const burger = document.getElementById('react-burger-menu-btn').getBoundingClientRect();
      const cart = document.querySelector('.shopping_cart_link').getBoundingClientRect();
      return {
        columns: xs.length,
        itemW: Math.round(items[0].getBoundingClientRect().width),
        hOverflow: de.scrollWidth > de.clientWidth,
        sortW: Math.round(sort.width),
        burgerW: Math.round(burger.width), burgerH: Math.round(burger.height),
        cartW: Math.round(cart.width), cartH: Math.round(cart.height),
      };
    });
    rows.push({ width: w, ...m });
  }

  // Drawer width sweep (mobile-vs-desktop drawer footprint)
  const drawer = [];
  for (const w of [320, 390, 480, 640, 900, 1280]) {
    await page.setViewportSize({ width: w, height: 844 });
    await page.locator('#react-burger-menu-btn').click();
    await page.waitForTimeout(700);
    const d = await page.evaluate(() => {
      const el = document.querySelector('.bm-menu-wrap');
      const b = el.getBoundingClientRect();
      return { drawerW: Math.round(b.width), pct: Math.round((b.width / window.innerWidth) * 100), aria: el.getAttribute('aria-hidden') };
    });
    drawer.push({ width: w, ...d });
    await page.locator('#react-burger-cross-btn').click();
    await page.waitForTimeout(700);
  }

  console.log(JSON.stringify({ grid: rows, drawer }, null, 2));
  await browser.close();
})();
