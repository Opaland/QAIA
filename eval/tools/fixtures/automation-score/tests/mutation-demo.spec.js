// Fixture for eval/tools/automation_score.py — mutation track discrimination proof.
//
// Two tests, both GREEN, both structurally irreproachable to a static reader. One asserts for
// real; the other swallows its own assertion and can therefore never fail. No static rule
// distinguishes them — only mutation does. That is the whole point of the track.
//
// Expected result when automation_score.py runs its mutation track here:
//   - load-bearing  -> mutant KILLED  (inverting the expected text turns the test red)
//   - swallowed     -> mutant SURVIVED (blocking finding)
const { test, expect } = require('@playwright/test');

const PAGE = '<html><body><h1>Bonjour</h1><p id="count">3</p></body></html>';

test('@QAIA-FIXTURE-001 load-bearing assertion', async ({ page }) => {
  await page.setContent(PAGE);
  await expect(page.locator('h1')).toHaveText('Bonjour');
});

test('@QAIA-FIXTURE-002 swallowed assertion looks identical but cannot fail', async ({ page }) => {
  await page.setContent(PAGE);
  try {
    await expect(page.locator('h1')).toHaveText('Bonjour');
  } catch (err) {
    // Deliberate defect: the assertion result is discarded, so the test is green whatever
    // the page contains. This is the failure mode the mutation track exists to catch.
  }
});
