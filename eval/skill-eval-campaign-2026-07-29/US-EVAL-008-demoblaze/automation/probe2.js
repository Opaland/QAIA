const { chromium } = require('@playwright/test');
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.route('**/addtocart', route => {
    console.log('INTERCEPTED', route.request().url());
    route.fulfill({ status: 200, contentType: 'application/json', body: JSON.stringify({ errorMessage: 'Token has expired' }) });
  });
  await page.goto('https://www.demoblaze.com/prod.html?idp_=1');
  page.once('dialog', async d => { console.log('ALERT:', d.message()); await d.accept(); });
  await page.locator('a[onclick^="addToCart"]').first().click();
  await page.waitForTimeout(2000);
  await browser.close();
})();
