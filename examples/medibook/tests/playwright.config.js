const { defineConfig, devices } = require('@playwright/test');
const fs = require('fs');
// Portability fix (external audit finding, 2026-07-26): this used to hardcode a Linux-only
// preinstalled Chromium path (`/opt/pw-browsers/chromium-1194/chrome-linux/chrome`), which
// broke every browser project outside that exact original environment — a real, reproduced
// regression the existing CI never caught. `PLAYWRIGHT_CHROMIUM_PATH` lets an environment that
// genuinely needs a pinned preinstalled build opt in explicitly; everyone else gets Playwright's
// own managed browser (the portable default `@playwright/test` already installs via
// `npx playwright install`). Only honored if the path actually exists on disk, so a stale env
// var left over from a different machine degrades to the default instead of failing hard.
const pinned = process.env.PLAYWRIGHT_CHROMIUM_PATH;
const CHROME = pinned && fs.existsSync(pinned) ? pinned : undefined;
const launchOptions = CHROME ? { launchOptions: { executablePath: CHROME } } : {};
module.exports = defineConfig({
  testDir: '.',
  timeout: 15000,
  // The SUT holds global in-memory state and each test resets it via /api/reset.
  // Parallel workers would stomp each other's resets against the single shared
  // server → serialize with one worker (real finding from Sprint 5 flake hunt).
  workers: 1,
  fullyParallel: false,
  reporter: [['list'], ['json', { outputFile: 'results.json' }]],
  use: { baseURL: process.env.BASE_URL || 'http://localhost:4400', trace: 'off', screenshot: 'off', ...launchOptions },
  projects: [
    { name: 'e2e-desktop', testMatch: /e2e\..*\.spec\.js/, use: { ...devices['Desktop Chrome'], ...launchOptions } },
    { name: 'e2e-mobile', testMatch: /e2e\.booking\.spec\.js/, use: { ...devices['Pixel 7'], ...launchOptions } },
    { name: 'api', testMatch: /api\..*\.spec\.js/ },
    { name: 'security', testMatch: /security\..*\.spec\.js/ },
    { name: 'perf', testMatch: /perf\..*\.spec\.js/ },
    { name: 'a11y', testMatch: /a11y\..*\.spec\.js/, use: { ...devices['Desktop Chrome'], ...launchOptions } },
    { name: 'visual', testMatch: /visual\..*\.spec\.js/, use: { ...devices['Desktop Chrome'], ...launchOptions } },
  ],
});
