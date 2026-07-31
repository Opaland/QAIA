// Optional a11y pass (qaia-playwright:a11y-audit, referenced by automate's "additive, run
// alongside" guardrail). Not part of the login-gate test book itself -- reported separately,
// tagged @QAIA-A11Y-001, real axe-core run against the live login screen (the one key screen
// this US covers). Fails on serious/critical violations per the skill's own rule.
const { test, expect } = require('@playwright/test');
const AxeBuilder = require('@axe-core/playwright').default;

test('@QAIA-A11Y-001 - SauceDemo login screen has no serious/critical WCAG2 A/AA violations', async ({ page }) => {
  await page.goto('/');
  const results = await new AxeBuilder({ page }).withTags(['wcag2a', 'wcag2aa']).analyze();

  const serious = results.violations.filter(v => v.impact === 'serious' || v.impact === 'critical');

  // Attach the full violation list to the report regardless of outcome (honest reporting,
  // never suppress to make the suite green).
  await test.info().attach('axe-violations.json', {
    body: JSON.stringify(results.violations, null, 2),
    contentType: 'application/json',
  });

  expect(serious, JSON.stringify(serious.map(v => ({ id: v.id, impact: v.impact, nodes: v.nodes.length })), null, 2)).toEqual([]);
});
