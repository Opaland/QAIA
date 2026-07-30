const { chromium } = require('@playwright/test');
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  const reqs = [];
  page.on('request', r => { if (r.url().includes('cart') || r.url().includes('token')) reqs.push(r.method() + ' ' + r.url()); });
  await page.goto('https://www.demoblaze.com/prod.html?idp_=1');
  page.once('dialog', async d => { console.log('ALERT:', d.message()); await d.accept(); });
  await page.locator('a[onclick^="addToCart"]').first().click();
  await page.waitForTimeout(2000);
  console.log(reqs.join('\n'));
  await browser.close();
})();
