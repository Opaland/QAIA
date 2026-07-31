// Why did @QAIA-VIS-003 stay green under INJECT_REGRESSION? Probe the real footer DOM.
const { chromium } = require('@playwright/test');
(async () => {
  const b = await chromium.launch();
  const p = await b.newPage({ viewport: { width: 1280, height: 800 } });
  await p.goto('https://www.saucedemo.com/');
  await p.locator('#user-name').fill('standard_user');
  await p.locator('#password').fill('secret_sauce');
  await p.locator('#login-button').click();
  await p.locator('.title').waitFor();
  const out = await p.evaluate(() => {
    const f = document.querySelector('footer.footer');
    return {
      footerOuterHTML: f ? f.outerHTML : null,
      footerRobotCount: document.querySelectorAll('.footer_robot').length,
      footerCopyText: document.querySelector('.footer_copy')?.textContent?.trim(),
      footerBox: f ? f.getBoundingClientRect().toJSON() : null,
    };
  });
  console.log(JSON.stringify(out, null, 2));
  await b.close();
})();
