// Fourth exploration probe: on a real iPhone 13 device descriptor (WebKit), the drawer is the
// ONLY route to Logout. Capture (a) that the drawer link logs out, (b) the verbatim refusal text
// when the protected inventory URL is requested afterwards.
const { webkit, devices } = require('@playwright/test');

(async () => {
  const browser = await webkit.launch();
  const ctx = await browser.newContext({ ...devices['iPhone 13'] });
  const page = await ctx.newPage();
  await page.goto('https://www.saucedemo.com/');
  await page.getByPlaceholder('Username').fill('standard_user');
  await page.getByPlaceholder('Password').fill('secret_sauce');
  await page.getByRole('button', { name: 'Login' }).click();
  await page.waitForURL('**/inventory.html');

  const noOtherLogout = await page.evaluate(() => {
    const visibleLogout = [...document.querySelectorAll('a,button')].filter((e) => {
      const b = e.getBoundingClientRect();
      return /logout|sign\s*out/i.test(e.innerText || '') && b.width > 0 && b.height > 0;
    }).length;
    return visibleLogout;
  });

  await page.locator('#react-burger-menu-btn').click();
  await page.waitForTimeout(700);
  await page.locator('#logout_sidebar_link').click();
  await page.waitForURL('https://www.saucedemo.com/');
  const afterLogoutUrl = page.url();

  await page.goto('https://www.saucedemo.com/inventory.html');
  const err = await page.locator('[data-test="error"]').textContent().catch(() => null);
  const urlAfterDirect = page.url();

  console.log(JSON.stringify({
    visibleLogoutControlsOutsideDrawer: noOtherLogout,
    afterLogoutUrl,
    urlAfterDirectAccess: urlAfterDirect,
    refusalText: err,
  }, null, 2));
  await browser.close();
})();
