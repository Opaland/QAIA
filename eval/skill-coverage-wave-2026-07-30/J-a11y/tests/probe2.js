// Exploration: what does clicking the pencil (edit-button) actually open?
const { chromium } = require('@playwright/test');
(async () => {
  const b = await chromium.launch();
  const p = await b.newPage();
  await p.goto('https://broken-workshop.dequelabs.com/');
  await p.locator('[data-testid="chocolate-cake"]').waitFor();
  const dump = async (label) => {
    console.log('---', label, '---');
    console.log(await p.evaluate(() => Array.from(document.querySelectorAll('[role="dialog"], .dqpl-modal, dialog'))
      .map(d => ({ cls: d.className, role: d.getAttribute('role'), visible: d.offsetParent !== null,
                   display: getComputedStyle(d).display, heading: (d.textContent||'').slice(0,80) }))));
  };
  await dump('before click');
  await p.locator('[data-testid="chocolate-cake"] [data-testid="edit-button"]').click();
  await p.waitForTimeout(2000);
  await dump('after edit click');
  console.log('--- visible dialog html (first 2500) ---');
  console.log(await p.evaluate(() => {
    const d = Array.from(document.querySelectorAll('[role="dialog"], .dqpl-modal')).find(x => x.offsetParent !== null);
    return d ? d.outerHTML.slice(0, 2500) : 'NONE VISIBLE';
  }));
  await b.close();
})();
