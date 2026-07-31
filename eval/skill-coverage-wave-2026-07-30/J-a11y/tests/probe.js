// Exploration script (not a test): dump the real DOM shape of a recipe card + the edit dialog.
const { chromium } = require('@playwright/test');
(async () => {
  const b = await chromium.launch();
  const p = await b.newPage();
  await p.goto('https://broken-workshop.dequelabs.com/');
  await p.locator('[data-testid="chocolate-cake"]').waitFor();
  console.log('--- CARD HTML ---');
  console.log(await p.locator('[data-testid="chocolate-cake"]').innerHTML());
  const btns = await p.locator('[data-testid="chocolate-cake"] button').all();
  console.log('--- BUTTONS ---');
  for (const bt of btns) console.log(JSON.stringify(await bt.evaluate(e => e.outerHTML)));
  await btns[0].click();
  await p.waitForTimeout(1500);
  console.log('--- DIALOGS present ---');
  console.log(await p.evaluate(() => Array.from(document.querySelectorAll('[role="dialog"], .dqpl-dialog, dialog'))
    .map(d => d.className + ' | role=' + d.getAttribute('role') + ' | visible=' + (d.offsetParent !== null))));
  console.log('--- BODY snippet ---');
  console.log((await p.evaluate(() => document.body.innerHTML)).slice(0, 3000));
  await b.close();
})();
