// US-EVAL-002 -- accessibility pass, axe-core via real Playwright browser (T7/D33 standard,
// examples/medibook/tests/a11y.booking.spec.js pattern). a11y is explicitly ✅ per the coverage
// matrix (docs/DEMO-TARGETS.md) for this target, unlike security-surface/perf-check which the
// golden rule forbids on this shared public instance (not run here, reported as not applicable).
const { test, expect } = require('@playwright/test');
const AxeBuilder = require('@axe-core/playwright').default;

const UI_BASE = process.env.UI_BASE_URL || 'https://practicesoftwaretesting.com';

test.describe('US-EVAL-002 Toolshop accessibility (WCAG 2 A/AA)', () => {
  test('@QAIA-A11Y-EVAL-002-001 home/product-listing page has no serious/critical violations', async ({ page }) => {
    await page.goto(UI_BASE + '/');
    await page.waitForLoadState('networkidle');
    const results = await new AxeBuilder({ page }).withTags(['wcag2a', 'wcag2aa']).analyze();
    const serious = results.violations.filter(v => ['serious', 'critical'].includes(v.impact));
    expect(serious, JSON.stringify(serious.map(v => ({ id: v.id, impact: v.impact, nodes: v.nodes.length })))).toEqual([]);
  });

  test('@QAIA-A11Y-EVAL-002-002 cart page has no serious/critical violations', async ({ page }) => {
    await page.goto(UI_BASE + '/#/cart');
    await page.waitForLoadState('networkidle');
    const results = await new AxeBuilder({ page }).withTags(['wcag2a', 'wcag2aa']).analyze();
    const serious = results.violations.filter(v => ['serious', 'critical'].includes(v.impact));
    expect(serious, JSON.stringify(serious.map(v => ({ id: v.id, impact: v.impact, nodes: v.nodes.length })))).toEqual([]);
  });

  test('@QAIA-A11Y-EVAL-002-003 checkout entry page has no serious/critical violations', async ({ page }) => {
    await page.goto(UI_BASE + '/#/checkout');
    await page.waitForLoadState('networkidle');
    const results = await new AxeBuilder({ page }).withTags(['wcag2a', 'wcag2aa']).analyze();
    const serious = results.violations.filter(v => ['serious', 'critical'].includes(v.impact));
    expect(serious, JSON.stringify(serious.map(v => ({ id: v.id, impact: v.impact, nodes: v.nodes.length })))).toEqual([]);
  });
});
