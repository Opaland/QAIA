// Standalone Playwright config for the visual-check audit (issue #40).
// No app server needed: tests navigate directly to the local fixture.html via file://.
const { defineConfig, devices } = require('@playwright/test');

module.exports = defineConfig({
  testDir: './tests',
  timeout: 15000,
  workers: 1,
  fullyParallel: false,
  reporter: [['list'], ['json', { outputFile: 'results.json' }]],
  use: { trace: 'off', screenshot: 'off' },
  projects: [
    { name: 'visual', use: { ...devices['Desktop Chrome'] } },
  ],
});
