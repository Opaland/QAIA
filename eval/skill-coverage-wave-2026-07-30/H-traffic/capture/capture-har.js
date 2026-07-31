// Capture a REAL HAR on demoblaze.com (public demo, UI exploration authorized by
// docs/DEMO-TARGETS.md). This capture is deliberately performed OUTSIDE the
// traffic-replay skill: that skill forbids capturing live traffic itself
// ("Never capture live traffic", SKILL.md Guardrails). Here the agent acts as the
// *user* who produces the HAR export; the skill is only applied afterwards.
const { chromium } = require('playwright');

// Credentials are NOT hardcoded here: this file is delivered as evidence and a HAR
// of a login carries the credential in clear text. Supply them at run time, e.g.
//   QAIA_EVAL_USER=... QAIA_EVAL_PASS=... node capture-har.js
const USER = process.env.QAIA_EVAL_USER;
const PASS = process.env.QAIA_EVAL_PASS;
if (!USER || !PASS) throw new Error('set QAIA_EVAL_USER and QAIA_EVAL_PASS');

(async () => {
  const browser = await chromium.launch();
  const context = await browser.newContext({
    recordHar: { path: 'demoblaze-login.har', content: 'embed' },
  });
  const page = await context.newPage();

  await page.goto('https://www.demoblaze.com/', { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(2000);

  // Sign up (throwaway synthetic account)
  await page.click('#signin2');
  await page.waitForSelector('#signInModal', { state: 'visible' });
  await page.fill('#sign-username', USER);
  await page.fill('#sign-password', PASS);
  page.once('dialog', async (d) => { console.log('SIGNUP DIALOG:', d.message()); await d.accept(); });
  await page.click('button[onclick="register()"]');
  await page.waitForTimeout(3000);

  // Log in
  await page.click('#login2');
  await page.waitForSelector('#logInModal', { state: 'visible' });
  await page.fill('#loginusername', USER);
  await page.fill('#loginpassword', PASS);
  page.once('dialog', async (d) => { console.log('LOGIN DIALOG:', d.message()); await d.accept(); });
  await page.click('button[onclick="logIn()"]');
  await page.waitForTimeout(3000);

  const welcome = await page.textContent('#nameofuser').catch(() => null);
  console.log('LOGGED IN AS:', JSON.stringify(welcome));

  // A couple of authenticated-ish browsing calls so the HAR has more signatures
  await page.click('a.hrefch >> nth=0').catch(() => {});
  await page.waitForTimeout(2500);
  await page.goto('https://www.demoblaze.com/cart.html', { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(2500);

  await context.close();
  await browser.close();
  console.log('HAR written to demoblaze-login.har');
})();
