// Grounding probe for the istqb-design step-3c recall conditions.
// Every condition derived by the "list view / authorization / enumerate-every-list" reflexes
// is measured here BEFORE it is written into 03-design.md — no condition is asserted unmeasured.
// Black-box: rendered state + navigation only, no stylesheet or source reading.
const { chromium, devices } = require('@playwright/test');

const login = async (page) => {
  await page.goto('https://www.saucedemo.com/');
  await page.getByPlaceholder('Username').fill('standard_user');
  await page.getByPlaceholder('Password').fill('secret_sauce');
  await page.getByRole('button', { name: 'Login' }).click();
  await page.waitForURL('**/inventory.html');
};

(async () => {
  const browser = await chromium.launch();
  const out = {};

  // --- 1. Drawer item list (enumerate-every-list reflex) + cart badge occlusion (decision table)
  {
    const page = await (await browser.newContext({ ...devices['Pixel 7'] })).newPage();
    await login(page);
    await page.locator('#react-burger-menu-btn').click();
    await page.waitForTimeout(700);
    out.drawerItems = await page.evaluate(() =>
      [...document.querySelectorAll('.bm-menu-wrap .bm-item-list a')].map((a) => ({
        id: a.id, dataTest: a.getAttribute('data-test'), text: (a.textContent || '').trim(),
      })));

    // Card centre while the drawer is OPEN: what a tap would hit, and does the cart change?
    const cardBox = await page.locator('.inventory_item').first().boundingBox();
    const cx = Math.round(cardBox.x + cardBox.width / 2);
    const cy = Math.round(cardBox.y + cardBox.height / 2);
    out.openDrawer = await page.evaluate(([x, y]) => {
      const el = document.elementFromPoint(x, y);
      return { topmost: el ? el.tagName + '.' + el.className : null, insideDrawer: !!(el && el.closest('.bm-menu-wrap')) };
    }, [cx, cy]);
    await page.mouse.click(cx, cy);
    await page.waitForTimeout(400);
    out.cartBadgeAfterTapThroughDrawer = await page.locator('.shopping_cart_badge').count();

    // Close the drawer, tap the same point again: control cell of the decision table.
    await page.locator('#react-burger-cross-btn').click();
    await page.waitForTimeout(700);
    const addBtn = await page.locator('.inventory_item').first().getByRole('button').first();
    out.closedDrawerAddButtonName = (await addBtn.textContent()).trim();
    await addBtn.click();
    await page.waitForTimeout(300);
    out.cartBadgeAfterRealAdd = await page.locator('.shopping_cart_badge').textContent().catch(() => null);

    // --- Sort persistence across a drawer open/close (list-view persistence reflex)
    await page.locator('[data-test="product-sort-container"]').selectOption('za');
    const before = await page.locator('[data-test="product-sort-container"]').inputValue();
    await page.locator('#react-burger-menu-btn').click();
    await page.waitForTimeout(600);
    await page.locator('#react-burger-cross-btn').click();
    await page.waitForTimeout(600);
    out.sortPersistence = { before, after: await page.locator('[data-test="product-sort-container"]').inputValue() };
    await page.close();
  }

  // --- 2. Authorization reflex: never-logged-in access to guarded routes
  {
    const ctx = await browser.newContext({ ...devices['Pixel 7'] });
    const page = await ctx.newPage();
    out.unauth = {};
    for (const path of ['inventory.html', 'cart.html', 'checkout-step-one.html']) {
      await page.goto('https://www.saucedemo.com/' + path);
      await page.waitForTimeout(300);
      out.unauth[path] = {
        url: page.url(),
        error: await page.locator('[data-test="error"]').textContent().catch(() => null),
      };
    }
    await page.close();
  }

  // --- 3. Recovery-path reflex: is there any forgot-password affordance on the login page?
  {
    const page = await (await browser.newContext({ ...devices['Pixel 7'] })).newPage();
    await page.goto('https://www.saucedemo.com/');
    out.recoveryAffordances = await page.evaluate(() =>
      [...document.querySelectorAll('a,button')]
        .filter((e) => /forgot|reset|recover|help/i.test(e.textContent || ''))
        .map((e) => (e.textContent || '').trim()));
    await page.close();
  }

  console.log(JSON.stringify(out, null, 2));
  await browser.close();
})();
