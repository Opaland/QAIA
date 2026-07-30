// E2E — maps QAIA Gherkin scenarios (US-EVAL-006) to executable Playwright tests.
// Source testbook: eval/skill-eval-campaign-2026-07-29/US-EVAL-006-the-internet-dynamic-loading/
//   testbooks/dynamic-loading.feature
// Each test title cites its stable scenario ID + AC tag for requirement traceability.
// Real browser automation against the public the-internet.herokuapp.com instance
// (per docs/DEMO-TARGETS.md: UI only, security/perf explicitly out of scope for this target).
const { test, expect } = require('./fixtures');

test.describe('the-internet — Dynamically Loaded Page Elements (US-EVAL-006)', () => {

  test('@QAIA-US-EVAL-006-001 @AC3 @P2 Example 1 hidden element not visible before the delay elapses', async ({ dynamicLoadingPage, page }) => {
    await dynamicLoadingPage.goto(1);
    const clickedAt = Date.now();
    await dynamicLoadingPage.clickStart();

    // Assert immediately (well under the 5000ms boundary — Q2's lower-bound reading).
    await expect(dynamicLoadingPage.finish).toBeHidden();
    await expect(dynamicLoadingPage.loadingIndicator).toBeVisible();

    const elapsedMs = Date.now() - clickedAt;
    console.log(`[timing] scenario 001: assertions completed ${elapsedMs}ms after click (< 5000ms required)`);
    expect(elapsedMs).toBeLessThan(5000);
  });

  test('@QAIA-US-EVAL-006-002 @AC4 @P2 Example 2 has no Hello World element in the DOM before any click', async ({ dynamicLoadingPage }) => {
    await dynamicLoadingPage.goto(2);

    // Presence check (not visibility) — the element must not exist in the DOM at all.
    await expect(dynamicLoadingPage.finish).toHaveCount(0);
    await expect(dynamicLoadingPage.startButton).toBeVisible();
  });

  test('@QAIA-US-EVAL-006-003 @AC6 @P1 Example 2 Hello World element still does not exist before the delay elapses', async ({ dynamicLoadingPage }) => {
    await dynamicLoadingPage.goto(2);
    const clickedAt = Date.now();
    await dynamicLoadingPage.clickStart();

    // Stricter than scenario 001: absence from the DOM, not merely hidden (Example 2 creates
    // the #finish node only inside the setTimeout callback — see page's inline JS).
    await expect(dynamicLoadingPage.finish).toHaveCount(0);
    await expect(dynamicLoadingPage.loadingIndicator).toBeVisible();

    const elapsedMs = Date.now() - clickedAt;
    console.log(`[timing] scenario 003: assertions completed ${elapsedMs}ms after click (< 5000ms required)`);
    expect(elapsedMs).toBeLessThan(5000);
  });

  test('@QAIA-US-EVAL-006-004 @AC6 @P2 Example 2 Hello World element is created and shown after the delay elapses', async ({ dynamicLoadingPage }) => {
    await dynamicLoadingPage.goto(2);
    const clickedAt = Date.now();
    await dynamicLoadingPage.clickStart();

    // Wait past the 5000ms lower bound (Q2) via Playwright's own auto-retrying assertion —
    // no fixed sleep, polls until the element exists and is visible or the explicit timeout trips.
    await expect(dynamicLoadingPage.finish).toBeVisible({ timeout: 8000 });
    await expect(dynamicLoadingPage.finish).toHaveText('Hello World!');
    await expect(dynamicLoadingPage.loadingIndicator).toBeHidden();

    const elapsedMs = Date.now() - clickedAt;
    console.log(`[timing] scenario 004: element revealed ${elapsedMs}ms after click (>= 5000ms expected)`);
    expect(elapsedMs).toBeGreaterThanOrEqual(5000);
  });
});
