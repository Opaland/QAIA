// visual-check audit (issue #40) — applies the method documented in
// plugins/qaia-playwright/skills/visual-check/SKILL.md against 3 deliberately
// hard cases, to check whether it holds up against a perceptual-diff engine
// like Applitools (detect real changes, ignore rendering noise / expected
// dynamic content).
//
// Run 1 (baseline creation): AUDIT_VARIANT unset (defaults to 'baseline').
//   -> npx playwright test
// Run 2 (the "next CI run" that must judge correctly):
//   -> AUDIT_VARIANT=broken npx playwright test
//
// Case A and Case B intentionally do NOT depend on AUDIT_VARIANT: their
// content never changes between run 1 and run 2 (case A = static text,
// case B = the label "content never changes" too, only the live clock
// text does) — any diff Playwright reports for them is a false positive.
// Case C DOES depend on AUDIT_VARIANT: run 2 introduces the real regression
// (button color + broken layout) that must be caught.

const { test, expect } = require('@playwright/test');
const path = require('path');

const FIXTURE_URL = 'file://' + path.resolve(__dirname, '../fixture.html');
const variant = process.env.AUDIT_VARIANT || 'baseline';

test.describe('visual-check audit', () => {
  test('@AUDIT-VIS-A static text under rendering noise (must NOT flag)', async ({ page }) => {
    // Case-c variant param intentionally omitted here: case A/B are variant-agnostic.
    await page.goto(FIXTURE_URL);
    await expect(page.locator('#case-a')).toHaveScreenshot('case-a-noise.png', { maxDiffPixelRatio: 0.02 });
  });

  test('@AUDIT-VIS-B1 dynamic clock WITHOUT masking (expected to flake/false-positive)', async ({ page }) => {
    await page.goto(FIXTURE_URL);
    await expect(page.locator('#case-b')).toHaveScreenshot('case-b-unmasked.png', { maxDiffPixelRatio: 0.02 });
  });

  test('@AUDIT-VIS-B2 dynamic clock WITH masking per SKILL.md guardrail (must NOT flag)', async ({ page }) => {
    await page.goto(FIXTURE_URL);
    await expect(page.locator('#case-b')).toHaveScreenshot('case-b-masked.png', {
      maxDiffPixelRatio: 0.02,
      mask: [page.locator('#clock')],
    });
  });

  test('@AUDIT-VIS-C real visual regression: button color + broken layout (must flag)', async ({ page }) => {
    await page.goto(`${FIXTURE_URL}?variant=${variant}`);
    await expect(page.locator('#case-c')).toHaveScreenshot('case-c-real-change.png', { maxDiffPixelRatio: 0.02 });
  });
});
