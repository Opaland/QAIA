const { defineConfig, devices } = require('@playwright/test');
// Preinstalled Chromium (build 1194) — pin executablePath to avoid the version
// mismatch with the freshly installed @playwright/test browser expectation.
const CHROME = '/opt/pw-browsers/chromium-1194/chrome-linux/chrome';
module.exports = defineConfig({
  testDir: '.',
  timeout: 15000,
  // The SUT holds global in-memory state and each test resets it via /api/reset.
  // Parallel workers would stomp each other's resets against the single shared
  // server → serialize with one worker (real finding from Sprint 5 flake hunt).
  workers: 1,
  fullyParallel: false,
  reporter: [['list'], ['json', { outputFile: 'results.json' }]],
  use: { baseURL: 'http://localhost:4400', trace: 'off', screenshot: 'off', launchOptions: { executablePath: CHROME } },
  projects: [
    { name: 'e2e-desktop', testMatch: /e2e\..*\.spec\.js/, use: { ...devices['Desktop Chrome'], launchOptions: { executablePath: CHROME } } },
    { name: 'e2e-mobile', testMatch: /e2e\.booking\.spec\.js/, use: { ...devices['Pixel 7'], launchOptions: { executablePath: CHROME } } },
    { name: 'api', testMatch: /api\..*\.spec\.js/ },
    { name: 'security', testMatch: /security\..*\.spec\.js/ },
    { name: 'perf', testMatch: /perf\..*\.spec\.js/ },
    { name: 'a11y', testMatch: /a11y\..*\.spec\.js/, use: { ...devices['Desktop Chrome'], launchOptions: { executablePath: CHROME } } },
    { name: 'visual', testMatch: /visual\..*\.spec\.js/, use: { ...devices['Desktop Chrome'], launchOptions: { executablePath: CHROME } } },
  ],
});
