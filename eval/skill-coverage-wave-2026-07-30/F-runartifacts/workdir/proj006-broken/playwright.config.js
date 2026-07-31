const { defineConfig, devices } = require('@playwright/test');

// the-internet.herokuapp.com is a stateless public demo (no server-side reset endpoint, no
// shared mutable state between page loads) — unlike medibook's single in-memory server, so
// parallel workers are safe here.
module.exports = defineConfig({
  testDir: '.',
  timeout: 15000,
  retries: 0, // T2: masking instability behind retries hides the signal flaky-detect exists to surface.
  // run-report skill, step 1: configure the `junit` and `json` reporters so the run emits the
  // formats real toolchains ingest (JUnit XML for CI/ALM, JSON for the Cucumber transform).
  // Output file names are parameterized so repeated runs (flaky-detect input) do not overwrite
  // each other.
  reporter: [
    ['list'],
    ['json', { outputFile: process.env.QAIA_JSON_OUT || 'results.json' }],
    ['junit', { outputFile: process.env.QAIA_JUNIT_OUT || 'results.junit.xml' }],
  ],
  use: {
    baseURL: process.env.BASE_URL || 'https://the-internet.herokuapp.com',
    trace: 'off',
    screenshot: 'off',
  },
  projects: [
    { name: 'e2e-desktop', testMatch: /e2e\..*\.spec\.js/, use: { ...devices['Desktop Chrome'] } },
  ],
  // Golden rule (docs/DEMO-TARGETS.md the-internet row): security ❌ perf ❌ on this shared
  // public demo — no security/perf projects defined, not run, not simulated.
});
