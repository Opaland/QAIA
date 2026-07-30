// @ts-check
const { defineConfig } = require('@playwright/test');

// Shared mutable SUT (public daily-reset demo) -> serialize workers (automate skill rule).
module.exports = defineConfig({
  testDir: './tests',
  globalSetup: require.resolve('./global-setup.js'),
  timeout: 30_000,
  fullyParallel: false,
  workers: 1,
  retries: 0, // explicit: masking instability behind retries hides the signal flaky-detect exists to surface
  reporter: [
    ['list'],
    ['junit', { outputFile: 'reports/junit.xml' }],
    ['html', { outputFolder: 'reports/html', open: 'never' }],
  ],
  use: {
    baseURL: 'https://one.openemr.io',
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
  },
});
