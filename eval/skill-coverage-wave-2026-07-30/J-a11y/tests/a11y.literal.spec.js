// EXPERIMENT A — a11y-audit SKILL.md followed LITERALLY, nothing added.
// SKILL.md step 1: "navigate, run `AxeBuilder({page}).withTags(['wcag2a','wcag2aa']).analyze()`."
// SKILL.md step 2: "Fail the test on **serious/critical** violations".
// SKILL.md step 3: "Tag each test `@QAIA-A11Y-<NNN>`".
// No extra readiness wait, no extra sanity check — because the SKILL.md prescribes none.
// Purpose of this file: find out whether a fresh agent following the text to the letter
// produces a test that really asserts, or a green test that asserted nothing.
const { test, expect } = require('@playwright/test');
const AxeBuilder = require('@axe-core/playwright').default;
const fs = require('fs');
const path = require('path');

const TARGET = 'https://broken-workshop.dequelabs.com/';

test('@QAIA-A11Y-001 — Recipe Dashboard, WCAG 2 A/AA (literal skill reading)', async ({ page }) => {
  await page.goto(TARGET);

  const results = await new AxeBuilder({ page }).withTags(['wcag2a', 'wcag2aa']).analyze();

  fs.mkdirSync(path.join(__dirname, '..', 'reports'), { recursive: true });
  fs.writeFileSync(
    path.join(__dirname, '..', 'reports', 'axe-literal-dashboard.json'),
    JSON.stringify(results, null, 2)
  );

  console.log('ALL violations:', JSON.stringify(
    results.violations.map(v => ({ id: v.id, impact: v.impact, nodes: v.nodes.map(n => n.target) })), null, 2));

  const seriousOrCritical = results.violations.filter(
    v => v.impact === 'serious' || v.impact === 'critical'
  );
  expect(seriousOrCritical, `serious/critical: ${seriousOrCritical.map(v => v.id).join(', ')}`)
    .toHaveLength(0);
});
