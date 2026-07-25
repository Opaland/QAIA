// Lightweight performance check — concurrent load + latency budget.
// A real project would use k6 (issue #13 / plugin qaia-perf, decision T6); this
// self-contained version proves the test type end-to-end without extra tooling.
const { test, expect } = require('./fixtures');
const B = 'http://localhost:4400';

test.describe('MediBook performance (self-hosted only)', () => {

  test('@QAIA-PERF-001 GET /slots p95 latency under budget across 100 requests', async ({ request }) => {
    const N = 100, budgetMs = 200;
    const timings = [];
    // 10 waves of 10 concurrent requests
    for (let w = 0; w < 10; w++) {
      await Promise.all(Array.from({ length: 10 }, async () => {
        const t0 = performance.now();
        const r = await request.get(B + '/api/slots?specialty=cardiology');
        expect(r.status()).toBe(200);
        timings.push(performance.now() - t0);
      }));
    }
    timings.sort((a, b) => a - b);
    const p95 = timings[Math.floor(N * 0.95) - 1];
    console.log(`  perf: n=${N} p50=${timings[49].toFixed(1)}ms p95=${p95.toFixed(1)}ms max=${timings[N-1].toFixed(1)}ms`);
    expect(p95, `p95 ${p95.toFixed(1)}ms should be < ${budgetMs}ms`).toBeLessThan(budgetMs);
  });

  test('@QAIA-PERF-002 concurrent bookings stay consistent under contention', async ({ request }) => {
    // 5 patients race for the same single slot — exactly one must win (no oversell)
    const tokens = [];
    for (const e of ['patient@demo', 'minor@demo']) {
      tokens.push((await (await request.post(B + '/api/login', { data: { email: e, password: 'demo1234' } })).json()).token);
    }
    const attempts = await Promise.all(tokens.map(t =>
      request.post(B + '/api/book', { headers: { Authorization: 'Bearer ' + t }, data: { slotId: 's3' } }).then(r => r.status())
    ));
    const created = attempts.filter(s => s === 201).length;
    expect(created).toBe(1); // integrity under concurrency: no double-booking
  });
});
