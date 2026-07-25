// Accessibility — axe-core via Playwright (project decision D33/T7, standard de fait).
const { test, expect } = require('./fixtures');
const AxeBuilder = require('@axe-core/playwright').default;

test.describe('MediBook accessibility (WCAG 2 A/AA)', () => {
  test('@QAIA-A11Y-001 login screen has no serious/critical violations', async ({ page }) => {
    await page.goto('/');
    const results = await new AxeBuilder({ page }).withTags(['wcag2a', 'wcag2aa']).analyze();
    const serious = results.violations.filter(v => ['serious', 'critical'].includes(v.impact));
    expect(serious, JSON.stringify(serious.map(v => v.id))).toEqual([]);
  });

  test('@QAIA-A11Y-002 booking screen has no serious/critical violations', async ({ patient, page }) => {
    const results = await new AxeBuilder({ page }).withTags(['wcag2a', 'wcag2aa']).analyze();
    const serious = results.violations.filter(v => ['serious', 'critical'].includes(v.impact));
    expect(serious, JSON.stringify(serious.map(v => v.id))).toEqual([]);
  });
});
