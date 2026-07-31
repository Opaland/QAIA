// Refines the drawer full-width boundary found by probe-breakpoint.js (between 481 and 639).
const { chromium } = require('@playwright/test');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1280, height: 800 } });
  await page.goto('https://www.saucedemo.com/');
  await page.getByPlaceholder('Username').fill('standard_user');
  await page.getByPlaceholder('Password').fill('secret_sauce');
  await page.getByRole('button', { name: 'Login' }).click();
  await page.waitForURL('**/inventory.html');

  const out = [];
  for (const w of [479, 480, 481, 520, 560, 600, 639, 640, 641]) {
    await page.setViewportSize({ width: w, height: 844 });
    await page.locator('#react-burger-menu-btn').click();
    await page.waitForTimeout(700);
    const d = await page.evaluate(() => {
      const b = document.querySelector('.bm-menu-wrap').getBoundingClientRect();
      const item = document.querySelector('.inventory_item').getBoundingClientRect();
      return {
        drawerW: Math.round(b.width),
        pct: Math.round((b.width / window.innerWidth) * 100),
        // does any product card remain uncovered horizontally by the drawer?
        productStillUncovered: Math.round(item.right) > Math.round(b.right),
      };
    });
    out.push({ width: w, ...d });
    await page.locator('#react-burger-cross-btn').click();
    await page.waitForTimeout(700);
  }
  console.log(JSON.stringify(out, null, 2));
  await browser.close();
})();
