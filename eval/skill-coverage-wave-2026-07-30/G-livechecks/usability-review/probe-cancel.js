// H5 (error prevention) probe: is the destructive "Cancel" on a booked appointment confirmed?
const { chromium } = require('@playwright/test');
const path = require('path');
(async () => {
  const b = await chromium.launch();
  const p = await b.newPage({ viewport: { width: 1280, height: 900 } });
  let dialogSeen = null;
  p.on('dialog', async (d) => { dialogSeen = { type: d.type(), message: d.message() }; await d.dismiss(); });
  await p.goto('http://localhost:4401');
  await p.locator('#email').fill('patient@demo');
  await p.locator('#password').fill('demo1234');
  await p.locator('#login-btn').click();
  await p.locator('#app-section').waitFor({ state: 'visible' });
  await p.waitForTimeout(300);
  const before = await p.locator('#appointments').innerText();
  await p.locator('#appointments button').first().click();
  await p.waitForTimeout(800);
  const after = await p.evaluate(() => ({
    appointments: document.querySelector('#appointments').innerText,
    message: document.querySelector('#message').textContent,
    modalsInDom: [...document.querySelectorAll('dialog,[role=dialog],[role=alertdialog]')].length,
  }));
  await p.screenshot({ path: path.join(__dirname, 'screens', '08-after-cancel.png'), fullPage: true });
  console.log(JSON.stringify({ appointmentsBeforeClick: before, nativeDialogSeen: dialogSeen, after }, null, 2));
  await b.close();
})();
