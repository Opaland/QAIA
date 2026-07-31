// @ts-check
const { defineConfig } = require('@playwright/test');

module.exports = defineConfig({
  testDir: './tests',
  timeout: 90_000,
  fullyParallel: false,
  retries: 0,
  reporter: [['list'], ['json', { outputFile: 'reports/results.json' }]],
  use: {
    headless: true,
    ignoreHTTPSErrors: true,
  },
});
