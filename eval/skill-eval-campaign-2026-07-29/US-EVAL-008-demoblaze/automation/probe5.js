const { chromium } = require('@playwright/test');
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  const reqs = [];
  page.on('request', r => reqs.push(r.method() + ' ' + r.url()));
  await page.goto('https://www.demoblaze.com/cart.html');
  await page.waitForTimeout(3000);
  console.log(reqs.filter(r => r.includes('api.demoblaze')).join('\n'));
  console.log('---totalp:', await page.locator('#totalp').innerText().catch(e => 'ERR'));
  await browser.close();
})();
