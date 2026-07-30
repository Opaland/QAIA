const { chromium } = require('@playwright/test');
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.route('**/prod.html', route => route.continue());
  await page.goto('https://www.demoblaze.com/prod.html?idp_=1');
  const html = await page.content();
  const fnMatch = await page.evaluate(() => {
    // find addToCart function source if defined globally
    try { return window.addToCart ? window.addToCart.toString() : 'not found on window'; } catch(e) { return 'err: '+e.message; }
  });
  console.log(fnMatch);
  await browser.close();
})();
