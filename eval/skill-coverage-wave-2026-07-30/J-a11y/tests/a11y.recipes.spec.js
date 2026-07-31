// a11y-audit (qaia-playwright:a11y-audit) — axe-core via Playwright, WCAG 2 A/AA.
// Target: Deque Broken Workshop "Awesome Recipes" (docs/DEMO-TARGETS.md, a11y column
// "purpose-built"). Same target/scope as eval/skill-eval-campaign-2026-07-29/US-EVAL-007.
// Screens audited (SKILL.md step 1, "each key screen"):
//   @QAIA-A11Y-001 Recipe Dashboard (landing)
//   @QAIA-A11Y-002 Edit-recipe modal dialog (the form US-EVAL-007 is anchored on)
// SKILL.md step 2: fail on serious/critical; list all violations (id + impact + node).
const { test, expect } = require('@playwright/test');
const AxeBuilder = require('@axe-core/playwright').default;
const fs = require('fs');
const path = require('path');

const TARGET = 'https://broken-workshop.dequelabs.com/';
const REPORTS = path.join(__dirname, '..', 'reports');

function summarise(results) {
  return results.violations.map(v => ({
    id: v.id,
    impact: v.impact,
    wcag: v.tags.filter(t => t.startsWith('wcag')),
    nodes: v.nodes.map(n => ({ target: n.target, html: n.html })),
  }));
}

async function audit(page, name) {
  const results = await new AxeBuilder({ page }).withTags(['wcag2a', 'wcag2aa']).analyze();
  fs.mkdirSync(REPORTS, { recursive: true });
  fs.writeFileSync(path.join(REPORTS, `axe-${name}.json`), JSON.stringify(results, null, 2));
  console.log(`[${name}] ALL violations (id|impact|nodes):`);
  for (const v of summarise(results)) {
    console.log(`  ${v.id} | ${v.impact} | ${v.wcag.join(',')} | ${v.nodes.length} node(s)`);
    for (const n of v.nodes) console.log(`      -> ${JSON.stringify(n.target)}  ${n.html}`);
  }
  return results;
}

test.describe('a11y-audit — Deque Broken Workshop, live', () => {
  test('@QAIA-A11Y-001 — Recipe Dashboard, WCAG 2 A/AA', async ({ page }) => {
    await page.goto(TARGET);
    // Readiness guard: this is a client-rendered SPA (`<div id="app"></div>` in the served
    // HTML). Auditing before render yields 0 violations and a FALSE GREEN. Not prescribed by
    // the SKILL.md — see the defect note in the report.
    await expect(page.locator('[data-testid="chocolate-cake"]')).toBeVisible();

    const results = await audit(page, 'dashboard');

    // Assertion 1 (SKILL.md step 2): fail on serious/critical.
    const seriousOrCritical = results.violations.filter(
      v => v.impact === 'serious' || v.impact === 'critical'
    );
    expect(
      seriousOrCritical.map(v => `${v.id}(${v.impact})`),
      'serious/critical axe violations on the dashboard'
    ).toEqual([]);
  });

  test('@QAIA-A11Y-002 — Edit-recipe modal dialog, WCAG 2 A/AA', async ({ page }) => {
    await page.goto(TARGET);
    await expect(page.locator('[data-testid="chocolate-cake"]')).toBeVisible();

    // Open the edit dialog on the first recipe card.
    // Real DOM (see ../raw/probe-dom.txt): the edit affordance is
    // <img class="edit" alt="Edit" data-testid="edit-button"> inside a bare <div tabindex="0">.
    await page.locator('[data-testid="chocolate-cake"] [data-testid="edit-button"]').click();
    // Readiness guard for the dialog itself. NB: the [role="dialog"] element itself has a
    // 0x0 bounding box (its children are absolutely positioned), so Playwright considers it
    // hidden — see ../raw/probe-dialog-visibility.txt. Guard on the dialog heading instead.
    await expect(page.getByRole('heading', { name: 'Edit Chocolate Cake' })).toBeVisible();
    await expect(page.locator('[data-testid="ingredients"]')).toBeVisible();

    const results = await audit(page, 'edit-dialog');

    const seriousOrCritical = results.violations.filter(
      v => v.impact === 'serious' || v.impact === 'critical'
    );
    expect(
      seriousOrCritical.map(v => `${v.id}(${v.impact})`),
      'serious/critical axe violations with the edit-recipe dialog open'
    ).toEqual([]);
  });
});
