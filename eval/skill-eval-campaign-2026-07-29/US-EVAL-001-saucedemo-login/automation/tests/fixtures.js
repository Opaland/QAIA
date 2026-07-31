// POM-as-fixtures (modern Playwright pattern) — each test gets fresh page objects.
// No resetDb fixture here: SauceDemo is a public, credential-fixed demo with no
// reset/seed endpoint (testability gap, see traceability.md step-2 note) — login
// state is reset per test simply by a fresh goto('/') in each Page Object call,
// which is sufficient because this US only exercises the login gate itself.
const base = require('@playwright/test');
const { LoginPage } = require('./pages/LoginPage');
const { InventoryPage } = require('./pages/InventoryPage');

exports.test = base.test.extend({
  loginPage: async ({ page }, use) => { await use(new LoginPage(page)); },
  inventoryPage: async ({ page }, use) => { await use(new InventoryPage(page)); },
});
exports.expect = base.expect;
