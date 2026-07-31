// Real HAR capture (operator-side, NOT by the traffic-replay skill).
// Two authorized public demo targets: saucedemo.com and demoblaze.com.
const { chromium } = require('playwright');
const path = require('path');
const OUT = process.argv[2];

(async () => {
  // ---------- 1. saucedemo login (client-side auth) ----------
  {
    const browser = await chromium.launch();
    const ctx = await browser.newContext({
      recordHar: { path: path.join(OUT, 'saucedemo-login.har'), content: 'embed' },
    });
    const page = await ctx.newPage();
    await page.goto('https://www.saucedemo.com/', { waitUntil: 'load' });
    await page.fill('#user-name', 'standard_user');
    await page.fill('#password', 'secret_sauce');
    await page.click('#login-button');
    await page.waitForURL('**/inventory.html', { timeout: 30000 });
    await page.click('#add-to-cart-sauce-labs-backpack');
    await page.click('.shopping_cart_link');
    await page.waitForTimeout(1500);
    console.log('saucedemo final url:', page.url());
    await ctx.close();
    await browser.close();
  }

  // ---------- 2. demoblaze signup + login (server-side auth, real POST) ----------
  {
    const browser = await chromium.launch();
    const ctx = await browser.newContext({
      recordHar: { path: path.join(OUT, 'demoblaze-login.har'), content: 'embed' },
    });
    const page = await ctx.newPage();
    const user = 'qaia_eval_' + Date.now();
    const pwd = 'Ev4l-Tr4ffic!' + Math.floor(Math.random() * 10000);
    await page.goto('https://www.demoblaze.com/', { waitUntil: 'load' });

    page.on('dialog', async (d) => { console.log('dialog:', d.message()); await d.accept(); });

    await page.click('#signin2');
    await page.waitForTimeout(1200);
    await page.fill('#sign-username', user);
    await page.fill('#sign-password', pwd);
    await page.click('button[onclick="register()"]');
    await page.waitForTimeout(2500);

    await page.click('#login2');
    await page.waitForTimeout(1200);
    await page.fill('#loginusername', user);
    await page.fill('#loginpassword', pwd);
    await page.click('button[onclick="logIn()"]');
    await page.waitForTimeout(3000);

    const who = await page.textContent('#nameofuser').catch(() => null);
    console.log('demoblaze logged-in banner:', JSON.stringify(who));
    console.log('demoblaze user:', user);
    await ctx.close();
    await browser.close();
  }
})().catch((e) => { console.error('CAPTURE FAILED:', e); process.exit(1); });
