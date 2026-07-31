// MUTATION PROOF for tests/a11y.recipes.spec.js @QAIA-A11Y-001.
// A green a11y test that asserts nothing is a false positive. To prove the assertion in
// a11y.recipes.spec.js is load-bearing, we run the SAME assertion against two deliberately
// mutated versions of the SUT state:
//   MUT-1 "defect removed"  -> the two axe rules are repaired in-page; assertion must go GREEN.
//   MUT-2 "defect worsened" -> an extra critical violation is injected; assertion must stay RED
//                              AND its message must name the new rule id.
// If the assertion were vacuous, MUT-1 and MUT-2 would be indistinguishable.
const { test, expect } = require('@playwright/test');
const AxeBuilder = require('@axe-core/playwright').default;

const TARGET = 'https://broken-workshop.dequelabs.com/';

async function seriousOrCritical(page) {
  const r = await new AxeBuilder({ page }).withTags(['wcag2a', 'wcag2aa']).analyze();
  return r.violations
    .filter(v => v.impact === 'serious' || v.impact === 'critical')
    .map(v => `${v.id}(${v.impact})`);
}

test('MUT-1 — repair the two real defects in-page: the SAME assertion must go GREEN', async ({ page }) => {
  await page.goto(TARGET);
  await expect(page.locator('[data-testid="chocolate-cake"]')).toBeVisible();

  // Confirm the assertion is RED before the repair (baseline inside the same test).
  const before = await seriousOrCritical(page);
  expect(before).toEqual(['color-contrast(serious)', 'image-alt(critical)']);

  await page.evaluate(() => {
    // repair image-alt: the 8 recipe photos are decorative next to the recipe name
    document.querySelectorAll('img.Recipe__image').forEach(i => i.setAttribute('alt', ''));
    // repair color-contrast: #76bf98 on white -> a 4.5:1-passing green
    const s = document.createElement('style');
    s.textContent = 'td.Beginner { color: #1d6b44 !important; }';
    document.head.appendChild(s);
  });

  const after = await seriousOrCritical(page);
  console.log('MUT-1 before:', JSON.stringify(before), '-> after:', JSON.stringify(after));
  // THE ASSERTION UNDER PROOF, verbatim from a11y.recipes.spec.js:
  expect(after, 'serious/critical axe violations on the dashboard').toEqual([]);
});

test('MUT-2 — inject an extra critical defect: the SAME assertion must name it', async ({ page }) => {
  await page.goto(TARGET);
  await expect(page.locator('[data-testid="chocolate-cake"]')).toBeVisible();

  await page.evaluate(() => {
    // inject a violation of a rule NOT currently failing: an <a> with no accessible name
    const a = document.createElement('a');
    a.setAttribute('href', '#nowhere');
    a.style.cssText = 'display:block;width:40px;height:20px;background:#000';
    document.querySelector('#main-content').appendChild(a);
  });

  const after = await seriousOrCritical(page);
  console.log('MUT-2 after:', JSON.stringify(after));
  expect(after).toContain('link-name(serious)');            // the injected defect is detected
  expect(after).toContain('image-alt(critical)');           // the pre-existing ones are still there
  expect(after.length).toBeGreaterThan(2);                  // strictly worse than the baseline
});
