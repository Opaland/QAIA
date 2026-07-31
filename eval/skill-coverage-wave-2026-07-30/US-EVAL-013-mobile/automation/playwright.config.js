const { defineConfig, devices } = require('@playwright/test');

// US-EVAL-013 — MOBILE EMULATION ONLY (D100): mobile = Playwright device descriptors in a desktop
// browser engine. Native iOS/Android (Appium, real devices) is explicitly out of scope for v1 and
// is NOT faked here.
//
// The two mobile projects deliberately sit on DIFFERENT engines, because that is what the
// descriptors actually describe (state/01-extraction.md BR3):
//   devices['iPhone 13'] → defaultBrowserType 'webkit'
//   devices['Pixel 7']   → defaultBrowserType 'chromium'
// A suite that ran both descriptors on one engine would only be resizing a window, not exercising
// mobile emulation. `e2e-desktop` is the contrast project for the ≥481 px side of AC2.
module.exports = defineConfig({
  testDir: './tests',
  timeout: 45000,
  // SauceDemo is a SHARED PUBLIC demo. Its per-browser state is context-local (a cookie +
  // localStorage), so contexts do not stomp each other, but the target is third-party
  // infrastructure: 2 workers keeps the request rate civil (docs/DEMO-TARGETS.md golden rule).
  workers: 2,
  fullyParallel: true,
  // Retry/quarantine policy (automate SKILL.md line 23), stated explicitly rather than implied:
  // retries: 0 on purpose. Masking instability behind automatic retries hides exactly the signal
  // qaia-playwright:flaky-detect exists to surface. A scenario is quarantined only by tagging it
  // @quarantine after flaky-detect produced evidence — a human decision, recorded in the tag.
  retries: 0,
  reporter: [['list'], ['json', { outputFile: 'results.json' }], ['junit', { outputFile: 'junit.xml' }]],
  use: {
    baseURL: process.env.BASE_URL || 'https://www.saucedemo.com',
    // SauceDemo publishes `data-test`, not Playwright's default `data-testid` — this is what makes
    // the getByTestId-first selector rule usable on this SUT at all.
    testIdAttribute: 'data-test',
    trace: 'off',
    screenshot: 'off',
  },
  projects: [
    {
      name: 'e2e-mobile-iphone',
      testMatch: /e2e\.mobile-.*\.spec\.js/,
      use: { ...devices['iPhone 13'] }, // webkit, 390x844, dpr 3, isMobile, hasTouch
    },
    {
      name: 'e2e-mobile-pixel',
      testMatch: /e2e\.mobile-.*\.spec\.js/,
      use: { ...devices['Pixel 7'] }, // chromium, 412x915, dpr 2.625, isMobile, hasTouch
    },
    {
      name: 'e2e-desktop',
      testMatch: /e2e\.desktop-.*\.spec\.js/,
      use: { ...devices['Desktop Chrome'] },
    },
  ],
});
