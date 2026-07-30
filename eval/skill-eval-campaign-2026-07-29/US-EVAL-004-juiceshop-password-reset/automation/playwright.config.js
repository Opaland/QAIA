const { defineConfig, devices } = require('@playwright/test');

// US-EVAL-004 (Juice Shop password reset) — real Playwright run against the shared
// public demo. workers: 1 because this suite shares one throwaway account's state
// across its own scenarios sequentially (registration -> lookup -> reset -> re-lookup),
// same rationale as the medibook reference's shared-SUT rule.
module.exports = defineConfig({
  testDir: './tests',
  timeout: 30000,
  workers: 1,
  fullyParallel: false,
  retries: 0, // T2: never mask instability behind automatic retries — see automate SKILL.md.
  reporter: [['list'], ['json', { outputFile: 'results.json' }]],
  use: {
    baseURL: process.env.BASE_URL || 'https://demo.owasp-juice.shop',
    trace: 'off',
    screenshot: 'only-on-failure',
  },
  projects: [
    { name: 'e2e-desktop', testMatch: /e2e\..*\.spec\.js/, use: { ...devices['Desktop Chrome'] } },
  ],
});
