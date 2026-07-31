// Exploration reelle de https://www.saucedemo.com/ — inventaire d'ecrans + dumps DOM + etats d'erreur reels.
// Sert de preuve brute pour usability-heuristic-review (etape 1 "Screen inventory") et
// fournit les selecteurs reels pour le spec visual-check (pas de selecteurs de memoire).
const { chromium } = require('@playwright/test');
const fs = require('fs');
const path = require('path');

const OUT = path.resolve(__dirname, '..', 'usability-heuristic-review');
fs.mkdirSync(OUT, { recursive: true });

function save(name, content) {
  fs.writeFileSync(path.join(OUT, name), content, 'utf8');
  console.log('WROTE', name, content.length, 'bytes');
}

async function dumpScreen(page, tag) {
  const html = await page.content();
  save(`dom-${tag}.html`, html);
  await page.screenshot({ path: path.join(OUT, `screen-${tag}.png`), fullPage: true });
  console.log('SHOT', `screen-${tag}.png`);
  // Inventaire des elements interactifs reels (selecteur utile + texte reel)
  const inventory = await page.evaluate(() => {
    const rows = [];
    document.querySelectorAll('a, button, input, select, [role="button"]').forEach((el) => {
      rows.push({
        tag: el.tagName.toLowerCase(),
        id: el.id || null,
        dataTest: el.getAttribute('data-test') || null,
        cls: (el.className && String(el.className).slice(0, 80)) || null,
        type: el.getAttribute('type') || null,
        placeholder: el.getAttribute('placeholder') || null,
        text: (el.textContent || '').trim().slice(0, 80) || null,
        ariaLabel: el.getAttribute('aria-label') || null,
        title: el.getAttribute('title') || null,
      });
    });
    return rows;
  });
  save(`elements-${tag}.json`, JSON.stringify(inventory, null, 2));
}

(async () => {
  const browser = await chromium.launch();
  const ctx = await browser.newContext({ viewport: { width: 1280, height: 900 } });
  const page = await ctx.newPage();
  const log = [];
  const step = (m) => { log.push(m); console.log('STEP', m); };

  // --- Ecran 1 : login ---
  await page.goto('https://www.saucedemo.com/');
  await page.waitForLoadState('networkidle');
  step('loaded login page, title=' + (await page.title()));
  await dumpScreen(page, 'login');

  // Etat d'erreur reel 1 : soumission vide
  await page.locator('#login-button, input[type="submit"], button[type="submit"]').first().click();
  await page.waitForTimeout(500);
  const err1 = await page.evaluate(() => {
    const e = document.querySelector('[data-test="error"], .error-message-container, h3[data-test="error"]');
    return e ? e.textContent.trim() : '(no error element found)';
  });
  step('empty submit error: ' + err1);
  await dumpScreen(page, 'login-error-empty');

  // Etat d'erreur reel 2 : locked_out_user
  await page.reload();
  await page.waitForLoadState('networkidle');
  await page.fill('#user-name', 'locked_out_user');
  await page.fill('#password', 'secret_sauce');
  await page.locator('#login-button').click();
  await page.waitForTimeout(500);
  const err2 = await page.evaluate(() => {
    const e = document.querySelector('[data-test="error"]');
    return e ? e.textContent.trim() : '(no error element found)';
  });
  step('locked_out_user error: ' + err2);
  await dumpScreen(page, 'login-error-locked');

  // --- Ecran 2 : inventory (standard_user) ---
  await page.reload();
  await page.waitForLoadState('networkidle');
  await page.fill('#user-name', 'standard_user');
  await page.fill('#password', 'secret_sauce');
  await page.locator('#login-button').click();
  await page.waitForSelector('.inventory_list, [data-test="inventory-list"]');
  step('logged in, url=' + page.url());
  await dumpScreen(page, 'inventory');

  // Ajout panier reel : premier produit
  const firstAdd = page.locator('button[data-test^="add-to-cart"]').first();
  const addBtnTextBefore = await firstAdd.textContent();
  await firstAdd.click();
  const cartBadge = await page.evaluate(() => {
    const b = document.querySelector('[data-test="shopping-cart-badge"], .shopping_cart_badge');
    return b ? b.textContent.trim() : '(no badge)';
  });
  const removeBtnText = await page.locator('button[data-test^="remove"]').first().textContent();
  step(`added to cart: button "${addBtnTextBefore}" -> "${removeBtnText}", badge=${cartBadge}`);
  await dumpScreen(page, 'inventory-after-add');

  // --- Ecran 3 : cart ---
  await page.locator('[data-test="shopping-cart-link"], .shopping_cart_link').first().click();
  await page.waitForLoadState('networkidle');
  step('cart url=' + page.url());
  await dumpScreen(page, 'cart');

  // --- Ecran 4 : checkout step one + etat d'erreur reel 3 (champs vides) ---
  await page.locator('[data-test="checkout"]').click();
  await page.waitForLoadState('networkidle');
  step('checkout-step-one url=' + page.url());
  await dumpScreen(page, 'checkout-step-one');
  await page.locator('[data-test="continue"]').click();
  await page.waitForTimeout(500);
  const err3 = await page.evaluate(() => {
    const e = document.querySelector('[data-test="error"]');
    return e ? e.textContent.trim() : '(no error element found)';
  });
  step('checkout empty-fields error: ' + err3);
  await dumpScreen(page, 'checkout-error-empty');

  // Remplir et continuer
  await page.fill('[data-test="firstName"]', 'Ada');
  await page.fill('[data-test="lastName"]', 'Lovelace');
  await page.fill('[data-test="postalCode"]', '75001');
  await page.locator('[data-test="continue"]').click();
  await page.waitForLoadState('networkidle');
  step('checkout-step-two url=' + page.url());
  await dumpScreen(page, 'checkout-step-two');

  // Totaux reels affiches
  const totals = await page.evaluate(() => {
    const g = (s) => { const e = document.querySelector(s); return e ? e.textContent.trim() : null; };
    return {
      itemTotal: g('[data-test="subtotal-label"], .summary_subtotal_label'),
      tax: g('[data-test="tax-label"], .summary_tax_label'),
      total: g('[data-test="total-label"], .summary_total_label'),
      paymentInfo: g('[data-test="payment-info-value"]'),
      shippingInfo: g('[data-test="shipping-info-value"]'),
    };
  });
  step('overview totals: ' + JSON.stringify(totals));

  // --- Ecran 5 : finish ---
  await page.locator('[data-test="finish"]').click();
  await page.waitForLoadState('networkidle');
  step('checkout-complete url=' + page.url());
  await dumpScreen(page, 'checkout-complete');

  // Menu burger reel (pour heuristiques 3/6/10)
  await page.locator('#react-burger-menu-btn, button[aria-label*="menu" i]').first().click();
  await page.waitForTimeout(600);
  const menuItems = await page.evaluate(() => {
    return Array.from(document.querySelectorAll('.bm-item-list a, nav a')).map((a) => ({
      id: a.id || null, text: (a.textContent || '').trim(),
    }));
  });
  step('burger menu items: ' + JSON.stringify(menuItems));
  await dumpScreen(page, 'burger-menu');

  save('exploration-log.txt', log.join('\n'));
  await browser.close();
  console.log('DONE');
})().catch((e) => { console.error('EXPLORE FAILED:', e.message); process.exit(1); });
