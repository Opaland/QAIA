// POM-as-fixtures (automate SKILL.md line 19 / D34). Every test receives fresh page objects, and
// the signed-in precondition is seeded DECLARATIVELY — never by replaying the login form as a
// UI-chained setup (the atomic-preconditions rule, SKILL.md line 21).
//
// How the declarative seed was established (measured, not assumed — `probe-seed.js`):
// SauceDemo has no API or seed endpoint, but a real sign-in stores exactly one cookie,
// `session-username=standard_user`. Injecting that cookie into a fresh context and requesting
// /inventory.html directly yields `{ url: ".../inventory.html", inventoryVisible: true, error: null }`.
// So the precondition IS controllable declaratively on this SUT; the `signedIn` fixture below does
// that, and only the sign-in journey scenario (017) and the sign-out ones drive the real form,
// because the form *is* the behaviour under test there.
const base = require('@playwright/test');
const { LoginPage } = require('./pages/LoginPage');
const { InventoryPage } = require('./pages/InventoryPage');
const { NavigationDrawer } = require('./pages/NavigationDrawer');

const SESSION_COOKIE = {
  name: 'session-username',
  value: 'standard_user',
  domain: 'www.saucedemo.com',
  path: '/',
  httpOnly: false,
  secure: false,
  sameSite: 'Lax',
};

exports.test = base.test.extend({
  loginPage: async ({ page }, use) => { await use(new LoginPage(page)); },
  inventoryPage: async ({ page }, use) => { await use(new InventoryPage(page)); },
  drawer: async ({ page }, use) => { await use(new NavigationDrawer(page)); },

  /** Signed-in shopper on the catalogue, seeded by cookie injection (no UI chain). */
  signedIn: async ({ context, page, inventoryPage, drawer }, use) => {
    await context.addCookies([SESSION_COOKIE]);
    await inventoryPage.goto();
    await use({ page, inventoryPage, drawer });
  },
});

exports.expect = base.expect;
exports.SESSION_COOKIE = SESSION_COOKIE;
