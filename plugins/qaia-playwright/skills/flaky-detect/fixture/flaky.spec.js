const { test, expect } = require('@playwright/test');

const BASE = 'http://localhost:4601';

// 3 scenarios, each: reset shared state, push exactly 2 items, assert count === 2.
// Run with workers > 1 and fullyParallel: true against ONE shared server process
// (no per-test isolation) -- the same root cause as the medibook/expense-demo
// findings: concurrent workers stomp each other's reset/push against shared
// global state, so a scenario can transiently observe 0, 1, 3 or 4 instead of 2.
//
// The random start jitter below is what keeps this genuinely flaky (verdict
// varies run to run) instead of saturating to "always collides" (a real bug,
// not flaky) or "never collides" (no signal at all) -- see fixture/VALIDATION.md
// for 5 real captured runs and the actual pass/fail split observed.
for (let i = 1; i <= 3; i++) {
  test(`@QAIA-FLAKY-DEMO-${String(i).padStart(3, '0')} count is exactly 2 after two pushes`, async ({ request }) => {
    await new Promise((r) => setTimeout(r, Math.random() * 400));
    await request.post(`${BASE}/reset`);
    await request.post(`${BASE}/items`);
    await request.post(`${BASE}/items`);
    const res = await request.get(`${BASE}/count`);
    const body = await res.json();
    expect(body.count).toBe(2);
  });
}

// Controls -- not timing-dependent, included to prove flaky-detect distinguishes
// real flakiness (DEMO-001..003 above) from a stable pass and from a
// consistent, deterministic failure (a real bug, never flagged as flaky).
test('@QAIA-FLAKY-DEMO-004 stable control - always passes', async () => {
  expect(1 + 1).toBe(2);
});

test('@QAIA-FLAKY-DEMO-005 broken control - always fails', async () => {
  expect(1 + 1).toBe(3);
});
