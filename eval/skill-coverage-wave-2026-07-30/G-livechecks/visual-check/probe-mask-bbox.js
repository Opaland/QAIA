// Why does the MASKED footer still differ by 20 px after the year rollover?
// Hypothesis: Playwright's mask paints the element's bounding box; the bbox of a text node
// changes width when its text changes -> the pink rectangle itself moves.
const { chromium } = require('@playwright/test');
(async () => {
  const b = await chromium.launch();
  const p = await b.newPage({ viewport: { width: 1280, height: 800 } });
  await p.goto('https://www.saucedemo.com/');
  await p.locator('#user-name').fill('standard_user');
  await p.locator('#password').fill('secret_sauce');
  await p.locator('#login-button').click();
  await p.locator('.title').waitFor();
  const sel = '[data-test="footer-copy"]';
  const measure = () => p.$eval(sel, (el) => {
    const r = el.getBoundingClientRect();
    // inline text width, not the block box
    const range = document.createRange();
    range.selectNodeContents(el);
    const tr = range.getBoundingClientRect();
    return { text: el.textContent.trim(), blockW: r.width, blockH: r.height, textW: tr.width, textH: tr.height };
  });
  const before = await measure();
  await p.$eval(sel, (el) => { el.textContent = el.textContent.replace('2026', '2027'); });
  const after = await measure();
  console.log(JSON.stringify({ before, after, textWidthDelta: after.textW - before.textW }, null, 2));
  await b.close();
})();
