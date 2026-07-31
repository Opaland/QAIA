// Third exploration probe: does the open drawer OCCLUDE the product list on a phone
// viewport (<=480) while leaving it reachable on a wider one? Plus the real device-descriptor
// metrics Playwright ships for iPhone 13 / Pixel 7 / iPad Mini / Desktop Chrome.
const { chromium, webkit, devices } = require('@playwright/test');

(async () => {
  const report = { descriptors: {}, occlusion: [] };
  for (const name of ['iPhone 13', 'Pixel 7', 'iPad Mini', 'Desktop Chrome']) {
    const d = devices[name];
    report.descriptors[name] = { viewport: d.viewport, isMobile: !!d.isMobile, hasTouch: !!d.hasTouch, dsf: d.deviceScaleFactor, engine: d.defaultBrowserType };
  }

  const browser = await chromium.launch();
  for (const w of [390, 480, 481, 1280]) {
    const page = await browser.newPage({ viewport: { width: w, height: 844 } });
    await page.goto('https://www.saucedemo.com/');
    await page.getByPlaceholder('Username').fill('standard_user');
    await page.getByPlaceholder('Password').fill('secret_sauce');
    await page.getByRole('button', { name: 'Login' }).click();
    await page.waitForURL('**/inventory.html');
    await page.locator('#react-burger-menu-btn').click();
    await page.waitForTimeout(700);
    const r = await page.evaluate(() => {
      const card = document.querySelector('.inventory_item');
      const b = card.getBoundingClientRect();
      const cx = Math.min(window.innerWidth - 2, Math.max(2, Math.round(b.x + b.width / 2)));
      const cy = Math.min(window.innerHeight - 2, Math.max(2, Math.round(b.y + b.height / 2)));
      const top = document.elementFromPoint(cx, cy);
      const inDrawer = !!(top && top.closest('.bm-menu-wrap'));
      return { point: [cx, cy], topTag: top ? top.tagName + '.' + (top.className || '') : null, topIsDrawer: inDrawer };
    });
    report.occlusion.push({ width: w, ...r });
    await page.close();
  }
  await browser.close();
  console.log(JSON.stringify(report, null, 2));
})();
