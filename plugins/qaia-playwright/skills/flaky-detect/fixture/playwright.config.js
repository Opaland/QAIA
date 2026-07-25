const { defineConfig } = require('@playwright/test');

module.exports = defineConfig({
  testDir: '.',
  timeout: 10000,
  // Deliberately the INVERSE of the workers:1 fix documented in
  // examples/medibook/tests/playwright.config.js -- this fixture exists to
  // demonstrate the failure mode flaky-detect must catch, not to be a
  // well-behaved suite. Do not copy this workers:3/fullyParallel setting into
  // a real suite against shared state.
  workers: 3,
  fullyParallel: true,
  retries: 0,
  reporter: [['list'], ['junit', { outputFile: 'results.xml' }]],
  webServer: {
    command: 'node server.js',
    port: 4601,
    reuseExistingServer: false,
    timeout: 5000,
  },
});
