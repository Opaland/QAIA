// Accessibility — axe-core via Playwright (same pattern as examples/medibook, D33/T7).
const { test, expect } = require('./fixtures');
const AxeBuilder = require('@axe-core/playwright').default;

test.describe('ExpenseFlow accessibility (WCAG 2 A/AA)', () => {
  test('@QAIA-A11Y-US004-001 login screen has no serious/critical violations', async ({ page }) => {
    await page.goto('/');
    const results = await new AxeBuilder({ page }).withTags(['wcag2a', 'wcag2aa']).analyze();
    const serious = results.violations.filter(v => ['serious', 'critical'].includes(v.impact));
    expect(serious, JSON.stringify(serious.map(v => v.id))).toEqual([]);
  });

  test('@QAIA-A11Y-US004-002 reports screen has no serious/critical violations', async ({ employee }) => {
    const { page } = employee;
    const results = await new AxeBuilder({ page }).withTags(['wcag2a', 'wcag2aa']).analyze();
    const serious = results.violations.filter(v => ['serious', 'critical'].includes(v.impact));
    expect(serious, JSON.stringify(serious.map(v => v.id))).toEqual([]);
  });
});
