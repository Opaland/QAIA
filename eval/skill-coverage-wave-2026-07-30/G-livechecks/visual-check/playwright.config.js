// visual-check exercise — config per SKILL.md guardrail "Set `workers: 1` against a shared mutable SUT."
const { defineConfig, devices } = require('@playwright/test');

module.exports = defineConfig({
  testDir: '.',
  workers: 1,
  reporter: [['list'], ['json', { outputFile: 'report.json' }]],
  use: {
    baseURL: 'https://www.saucedemo.com',
    ...devices['Desktop Chrome'],
    viewport: { width: 1280, height: 800 },
    screenshot: 'only-on-failure',
  },
});
