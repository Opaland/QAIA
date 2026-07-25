const { defineConfig, devices } = require('@playwright/test');
module.exports = defineConfig({
  testDir: '.',
  timeout: 15000,
  // The SUT holds global in-memory state and each test resets it via /api/reset.
  // Parallel workers would stomp each other's resets against the single shared server
  // (same real finding as examples/medibook Sprint 5) -> serialize with one worker.
  workers: 1,
  fullyParallel: false,
  reporter: [['list'], ['json', { outputFile: 'results.json' }]],
  use: { baseURL: 'http://localhost:4500', trace: 'off', screenshot: 'off' },
  projects: [
    { name: 'e2e-desktop', testMatch: /e2e\..*\.spec\.js/, use: { ...devices['Desktop Chrome'] } },
    { name: 'api', testMatch: /api\..*\.spec\.js/ },
    { name: 'a11y', testMatch: /a11y\..*\.spec\.js/, use: { ...devices['Desktop Chrome'] } },
  ],
});
