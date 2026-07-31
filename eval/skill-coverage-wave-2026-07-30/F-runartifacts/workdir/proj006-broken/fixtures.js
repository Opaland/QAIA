// POM-as-fixtures (automate skill rule). Each test gets a fresh page object; no shared mutable
// SUT state exists for this target (each page load is independent, no server-side reset needed —
// unlike medibook's /api/reset), so no auto-reset fixture is required here.
const base = require('@playwright/test');
const { DynamicLoadingPage } = require('./pages/DynamicLoadingPage');

exports.test = base.test.extend({
  dynamicLoadingPage: async ({ page }, use) => {
    await use(new DynamicLoadingPage(page));
  },
});
exports.expect = base.expect;
