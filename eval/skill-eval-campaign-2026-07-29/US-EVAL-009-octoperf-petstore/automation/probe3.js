const { chromium } = require('@playwright/test');
(async () => {
  const browser = await chromium.launch();
  const context = await browser.newContext();
  const page = await context.newPage();
  await page.goto('https://petstore.octoperf.com/actions/Catalog.action?viewProduct=&productId=FI-SW-01');
  await page.locator('a', { hasText: 'Add to Cart' }).first().click();
  await page.waitForLoadState('networkidle');
  console.log('URL after add:', page.url());
  const body = await page.locator('body').innerText();
  console.log(body.slice(0, 1500));
  await browser.close();
})();
