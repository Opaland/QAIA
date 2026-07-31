// EXPERIMENT C — is the SKILL.md's literal recipe ("navigate, run AxeBuilder... fail on
// serious/critical") safe against the vacuous-green failure mode?
// The target is a client-rendered SPA: the served HTML is
//   <body class="dqpl-no-sidebar"> <div id="app"></div> <script src="/src.*.js"></script> </body>
// (see ../raw/target-index.html). If axe runs before the SPA paints, it finds 0 violations and
// the SKILL.md-prescribed assertion PASSES on a page famous for being deliberately inaccessible.
// The SKILL.md prescribes no readiness guard and no "did the audit actually see anything?" check.
const { test, expect } = require('@playwright/test');
const AxeBuilder = require('@axe-core/playwright').default;

const TARGET = 'https://broken-workshop.dequelabs.com/';

test('FALSE-GREEN — literal skill recipe, audit before the SPA renders, PASSES vacuously', async ({ page }) => {
  // 'commit' = navigation committed, document not yet loaded. This models a slow bundle /
  // slow network — nothing in the SKILL.md tells the agent to wait for anything more.
  await page.goto(TARGET, { waitUntil: 'commit' });

  const results = await new AxeBuilder({ page }).withTags(['wcag2a', 'wcag2aa']).analyze();

  console.log('FALSE-GREEN: violations =', results.violations.length,
    '| passes =', results.passes.length,
    '| DOM elements under #app =',
    await page.evaluate(() => document.querySelectorAll('#app *').length));

  const seriousOrCritical = results.violations.filter(
    v => v.impact === 'serious' || v.impact === 'critical'
  );
  // The exact assertion SKILL.md step 2 prescribes. It passes. Nothing was verified.
  expect(seriousOrCritical).toHaveLength(0);
});
