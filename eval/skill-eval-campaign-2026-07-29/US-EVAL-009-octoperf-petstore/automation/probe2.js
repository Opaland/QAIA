const { chromium } = require('@playwright/test');
(async () => {
  const browser = await chromium.launch();
  const context = await browser.newContext();
  const page = await context.newPage();
  await page.goto('https://petstore.octoperf.com/actions/Catalog.action?viewProduct=&productId=FI-SW-01');
  const links = await page.locator('a').evaluateAll(as => as.map(a => a.href + ' | ' + a.textContent.trim()).filter(s=>s.includes('EST')));
  console.log(links.join('\n'));
  await browser.close();
})();
