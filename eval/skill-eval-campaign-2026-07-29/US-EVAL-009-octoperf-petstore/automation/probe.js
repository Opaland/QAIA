const { chromium } = require('@playwright/test');
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.goto('https://petstore.octoperf.com/actions/Catalog.action');
  console.log('title:', await page.title());
  const links = await page.locator('a').evaluateAll(as => as.slice(0,30).map(a => a.href + ' | ' + a.textContent.trim()));
  console.log(links.join('\n'));
  await browser.close();
})();
