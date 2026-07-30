// a11y-audit (qaia-playwright:a11y-audit) — axe-core via Playwright, WCAG 2 A/AA.
// Run against the one page confirmed reachable and stable enough to audit without
// mutating shared demo state: the OpenEMR login screen. Per a11y-audit SKILL.md step 1/2:
// navigate, run axe with wcag2a+wcag2aa tags, fail on serious/critical, list all violations.
const { test, expect } = require('@playwright/test');
const AxeBuilder = require('@axe-core/playwright').default;

test.describe('a11y-audit — OpenEMR public demo, live pages', () => {
  test('@QAIA-A11Y-001 — login page (one.openemr.io/openemr/interface/login/login.php)', async ({ page }) => {
    await page.goto('https://one.openemr.io/openemr/interface/login/login.php?site=default', {
      waitUntil: 'networkidle',
    });

    const results = await new AxeBuilder({ page }).withTags(['wcag2a', 'wcag2aa']).analyze();

    const fs = require('fs');
    fs.writeFileSync(
      require('path').join(__dirname, '..', 'reports', 'a11y-login.json'),
      JSON.stringify(results, null, 2)
    );

    const seriousOrCritical = results.violations.filter(v => v.impact === 'serious' || v.impact === 'critical');
    // Real assertion on real SUT state: list every violation id+impact+node for the report,
    // fail on serious/critical per SKILL.md step 2.
    if (seriousOrCritical.length) {
      console.log('Serious/critical a11y violations:', JSON.stringify(seriousOrCritical.map(v => ({
        id: v.id, impact: v.impact, nodes: v.nodes.length,
      })), null, 2));
    }
    expect(seriousOrCritical, `serious/critical axe violations: ${seriousOrCritical.map(v => v.id).join(', ')}`).toHaveLength(0);
  });
});
