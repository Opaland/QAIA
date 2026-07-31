const { chromium } = require('@playwright/test');

async function tryLogin(page, username, password) {
  await page.goto('https://www.saucedemo.com/');
  if (username !== null) await page.fill('[data-test="username"]', username);
  if (password !== null) await page.fill('[data-test="password"]', password);
  await page.click('[data-test="login-button"]');
  await page.waitForTimeout(400);
  const err = await page.evaluate(() => {
    const el = document.querySelector('[data-test="error"]');
    return el ? el.textContent.trim() : null;
  });
  return { url: page.url(), err };
}

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();

  console.log('UNKNOWN USERNAME:', JSON.stringify(await tryLogin(page, 'not_a_real_user', 'secret_sauce')));
  console.log('EMPTY USERNAME:', JSON.stringify(await tryLogin(page, '', 'secret_sauce')));
  console.log('EMPTY PASSWORD:', JSON.stringify(await tryLogin(page, 'standard_user', '')));
  console.log('LOCKED + WRONG PASSWORD:', JSON.stringify(await tryLogin(page, 'locked_out_user', 'totally_wrong')));

  await browser.close();
})();
