// perf-check skill, steps 1 & 2 (lightweight Playwright-request version), against the
// SELF-HOSTED SUT examples/expense-demo/app/server.js on http://localhost:4500 (D35).
// @QAIA-PERF-001 @perf:load
const { test, expect, request } = require('@playwright/test');

const BASE = process.env.BASE_URL || 'http://localhost:4500';
const LATENCY_BUDGET_MS = Number(process.env.LATENCY_BUDGET_MS || 200);

async function login(email) {
  const ctx = await request.newContext({ baseURL: BASE });
  const r = await ctx.post('/api/login', { data: { email, password: 'demo1234' } });
  expect(r.status()).toBe(200);
  const { token } = await r.json();
  await ctx.dispose();
  return token;
}

function pct(sorted, p) {
  return sorted[Math.min(sorted.length - 1, Math.ceil((p / 100) * sorted.length) - 1)];
}

test('@QAIA-PERF-001 @perf:load step 1 - latency budget on GET /api/reports?scope=inbox', async () => {
  const token = await login('manager@demo');
  const N = 200;
  const CONCURRENCY = 20;
  const durations = [];
  const ctx = await request.newContext({
    baseURL: BASE,
    extraHTTPHeaders: { Authorization: `Bearer ${token}` },
  });
  for (let batch = 0; batch < N / CONCURRENCY; batch++) {
    await Promise.all(
      Array.from({ length: CONCURRENCY }, async () => {
        const t0 = Date.now();
        const r = await ctx.get('/api/reports?scope=inbox');
        durations.push(Date.now() - t0);
        expect(r.status()).toBe(200);
      })
    );
  }
  await ctx.dispose();
  const sorted = [...durations].sort((a, b) => a - b);
  const p50 = pct(sorted, 50);
  const p95 = pct(sorted, 95);
  const max = sorted[sorted.length - 1];
  console.log(`MEASURED n=${durations.length} p50=${p50}ms p95=${p95}ms max=${max}ms budget=${LATENCY_BUDGET_MS}ms`);
  expect(p95, `p95 ${p95}ms must be under budget ${LATENCY_BUDGET_MS}ms`).toBeLessThan(LATENCY_BUDGET_MS);
});

test('@QAIA-PERF-001 step 2 - concurrency integrity: only one approval wins the race', async () => {
  const empToken = await login('employee@demo');
  const mgrToken = await login('manager@demo');

  const emp = await request.newContext({
    baseURL: BASE,
    extraHTTPHeaders: { Authorization: `Bearer ${empToken}` },
  });
  const created = await emp.post('/api/reports');
  expect(created.status()).toBe(201);
  const id = (await created.json()).report.id;
  // band A (< 500 EUR): exactly ONE approval completes the report -> the limited resource
  const put = await emp.put(`/api/reports/${id}`, {
    data: { currency: 'EUR', lines: [{ category: 'meal', amount: 20, date: '2026-07-24' }] },
  });
  expect(put.status()).toBe(200);
  const sub = await emp.post(`/api/reports/${id}/submit`);
  expect(sub.status(), await sub.text()).toBe(200);
  await emp.dispose();

  const RACERS = 10;
  const results = await Promise.all(
    Array.from({ length: RACERS }, async () => {
      const c = await request.newContext({
        baseURL: BASE,
        extraHTTPHeaders: { Authorization: `Bearer ${mgrToken}` },
      });
      const r = await c.post(`/api/reports/${id}/decide`, { data: { decision: 'approve' } });
      const status = r.status();
      const body = await r.text();
      await c.dispose();
      return { status, body };
    })
  );
  const winners = results.filter((r) => r.status === 200);
  const losers = results.filter((r) => r.status !== 200);
  console.log(`RACE report=${id} racers=${RACERS} winners=${winners.length} losers=${losers.length}`);
  console.log(`LOSER STATUSES ${JSON.stringify(losers.map((l) => l.status))}`);
  console.log(`LOSER SAMPLE ${losers.length ? losers[0].body : '(none)'}`);

  // final state must record exactly one approval - no double-approval / oversell
  // read back as the OWNER: once approved, the manager is no longer the current approver and
  // the D96 IDOR fix makes GET /api/reports/:id return 404 for them.
  const owner = await request.newContext({
    baseURL: BASE,
    extraHTTPHeaders: { Authorization: `Bearer ${empToken}` },
  });
  const final = await owner.get(`/api/reports/${id}`);
  const rpt = (await final.json()).report;
  await owner.dispose();
  console.log(`FINAL status=${rpt.status} approvals=${rpt.approvals.length} ${JSON.stringify(rpt.approvals)}`);

  expect(winners.length, 'exactly one racer may win the approval').toBe(1);
  expect(rpt.approvals.length, 'exactly one approval may be recorded').toBe(1);
});
