const { chromium } = require('@playwright/test');
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.route('**/viewcart', route =>
    route.fulfill({ status: 200, contentType: 'application/json', body: JSON.stringify({ Items: [{ id: 'p1', prod_name: 'Item A', price: 360 }, { id: 'p2', prod_name: 'Item B', price: 790 }] }) })
  );
  await page.goto('https://www.demoblaze.com/cart.html');
  await page.waitForTimeout(3000);
  console.log('totalp:', await page.locator('#totalp').innerText().catch(e => 'ERR '+e.message));
  console.log('body snippet:', (await page.content()).includes('viewcart') ? 'has viewcart ref' : 'no ref');
  await browser.close();
})();
