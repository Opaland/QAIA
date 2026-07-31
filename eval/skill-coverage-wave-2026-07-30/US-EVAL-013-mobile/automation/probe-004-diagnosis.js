// Diagnosis of the ONLY red scenario of the real run (@QAIA-US-EVAL-013-004, both engines):
// is the assertion wrong, or is the SUT behaviour different from what state/00-source.md measured?
// Measures the card centre BEFORE open (what the generated test used) and AFTER open (what the
// exploration probe used), and reports what sits at each point.
const { chromium, devices, selectors } = require('@playwright/test');

(async () => {
  selectors.setTestIdAttribute('data-test');
  const browser = await chromium.launch();
  const ctx = await browser.newContext({ ...devices['Pixel 7'] });
  await ctx.addCookies([{ name: 'session-username', value: 'standard_user',
    domain: 'www.saucedemo.com', path: '/', httpOnly: false, secure: false, sameSite: 'Lax' }]);
  const page = await ctx.newPage();
  await page.goto('https://www.saucedemo.com/inventory.html');

  const box = (b) => ({ x: Math.round(b.x), y: Math.round(b.y), w: Math.round(b.width), h: Math.round(b.height) });
  const at = (x, y) => page.evaluate(([px, py]) => {
    const el = document.elementFromPoint(px, py);
    return el ? { tag: el.tagName, cls: String(el.className),
                  insideDrawer: !!el.closest('.bm-menu-wrap'),
                  insideMenuOrOverlay: !!el.closest('.bm-menu-wrap, .bm-overlay') } : null;
  }, [x, y]);

  const out = {};
  const before = box(await page.getByTestId('inventory-item').first().boundingBox());
  out.cardBoxBeforeOpen = before;
  const cBefore = { x: before.x + Math.round(before.w / 2), y: before.y + Math.round(before.h / 2) };

  await page.getByRole('button', { name: 'Open Menu' }).click();
  await page.waitForFunction(() => document.querySelector('.bm-menu-wrap')?.getAttribute('aria-hidden') === 'false');

  const after = box(await page.getByTestId('inventory-item').first().boundingBox());
  out.cardBoxAfterOpen = after;
  const cAfter = { x: after.x + Math.round(after.w / 2), y: after.y + Math.round(after.h / 2) };

  out.drawerBox = box(await page.locator('.bm-menu-wrap').boundingBox());
  out.viewport = page.viewportSize();
  out.atCentreCapturedBeforeOpen = { point: cBefore, hit: await at(cBefore.x, cBefore.y) };
  out.atCentreRecomputedAfterOpen = { point: cAfter, hit: await at(cAfter.x, cAfter.y) };
  out.pageWrapTransform = await page.evaluate(() => {
    const w = document.querySelector('#page_wrap');
    return w ? getComputedStyle(w).transform : null;
  });

  // Does a tap at the BEFORE point add anything to the cart?
  await page.touchscreen.tap(cBefore.x, cBefore.y);
  await page.waitForTimeout(500);
  out.cartBadgeAfterTapAtBeforePoint = await page.locator('.shopping_cart_badge').count();

  console.log(JSON.stringify(out, null, 2));
  await browser.close();
})();
