// One-off exploration script (step 3 of automate SKILL.md: explore the running app
// to build reliable selectors before generating page objects). Not part of the
// delivered suite -- kept here only as evidence of what was inspected.
const { chromium } = require('@playwright/test');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.goto('https://www.saucedemo.com/');

  const loginForm = await page.evaluate(() => {
    const pick = (el) => el ? {
      tag: el.tagName,
      id: el.id,
      testid: el.getAttribute('data-test'),
      name: el.getAttribute('name'),
      placeholder: el.getAttribute('placeholder'),
    } : null;
    return {
      username: pick(document.querySelector('input[name="user-name"], #user-name, [data-test="username"]')),
      password: pick(document.querySelector('input[name="password"], #password, [data-test="password"]')),
      submit: pick(document.querySelector('#login-button, [data-test="login-button"], input[type="submit"]')),
    };
  });
  console.log('LOGIN FORM:', JSON.stringify(loginForm, null, 2));

  await page.fill('[data-test="username"]', 'locked_out_user');
  await page.fill('[data-test="password"]', 'secret_sauce');
  await page.click('[data-test="login-button"]');
  await page.waitForTimeout(500);
  const errorEl = await page.evaluate(() => {
    const el = document.querySelector('[data-test="error"]');
    return el ? { text: el.textContent.trim(), testid: el.getAttribute('data-test') } : null;
  });
  console.log('LOCKED OUT ERROR:', JSON.stringify(errorEl, null, 2));
  console.log('URL AFTER LOCKED LOGIN:', page.url());

  await page.goto('https://www.saucedemo.com/');
  await page.fill('[data-test="username"]', 'standard_user');
  await page.fill('[data-test="password"]', 'wrong_password_xyz');
  await page.click('[data-test="login-button"]');
  await page.waitForTimeout(500);
  const errorEl2 = await page.evaluate(() => {
    const el = document.querySelector('[data-test="error"]');
    return el ? el.textContent.trim() : null;
  });
  console.log('BAD PASSWORD ERROR:', errorEl2);

  await page.goto('https://www.saucedemo.com/');
  await page.fill('[data-test="username"]', 'standard_user');
  await page.fill('[data-test="password"]', 'secret_sauce');
  await page.click('[data-test="login-button"]');
  await page.waitForTimeout(500);
  console.log('URL AFTER VALID LOGIN:', page.url());
  const inv = await page.evaluate(() => !!document.querySelector('.inventory_list, [data-test="inventory-container"], .title'));
  console.log('INVENTORY VISIBLE:', inv);

  await browser.close();
})();
