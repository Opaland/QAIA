const { defineConfig, devices } = require('@playwright/test');

module.exports = defineConfig({
  testDir: '.',
  timeout: 15000,
  // Public shared demo (saucedemo.com) with fixed, non-mutating credentials --
  // login attempts do not lock/unlock accounts or otherwise change server state,
  // so parallelism is not itself unsafe here. Kept at 1 worker anyway (T2 policy
  // default for a shared external SUT the project does not control) rather than
  // load-testing someone else's public demo, which is out of scope for this US.
  workers: 1,
  fullyParallel: false,
  retries: 0, // T2: no retry-masking -- flaky-detect (#34) is the tool for that signal, not this config.
  reporter: [['list'], ['json', { outputFile: 'results.json' }], ['junit', { outputFile: 'junit.xml' }]],
  use: {
    baseURL: process.env.BASE_URL || 'https://www.saucedemo.com',
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
    // SauceDemo's real markup uses `data-test="..."` (confirmed by live DOM probe,
    // see ../probe.js output), not Playwright's `data-testid` default -- without
    // this, every getByTestId() lookup times out even though the elements exist
    // (a real automation defect this run caught and fixed; see traceability.md).
    testIdAttribute: 'data-test',
  },
  projects: [
    { name: 'e2e-desktop', testMatch: /e2e\..*\.spec\.js/, use: { ...devices['Desktop Chrome'] } },
    // Optional pass (matrix a11y column = "warning"): axe-core via Playwright, per
    // qaia-playwright:a11y-audit. Not required by the golden rule (only security/perf
    // are forbidden on this shared public demo); a11y scanning a rendered page is
    // read-only and non-destructive, so it's in scope.
    { name: 'a11y', testMatch: /a11y\..*\.spec\.js/, use: { ...devices['Desktop Chrome'] } },
  ],
});
