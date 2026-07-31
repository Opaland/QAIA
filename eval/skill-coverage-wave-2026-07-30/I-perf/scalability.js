// k6 SCALABILITY / capacity shape (CT-PT, D95) -- perf-check step 3, "scalability" type.
// Extended from plugins/qaia-playwright/skills/perf-check/k6/load.js's structure (as the SKILL
// instructs: "extend from load.js's structure, not from scratch"), NOT written from scratch.
// Repeats the load stage at increasing concurrency levels and reports where the p95 budget first
// breaks -- a capacity curve, not a single gate. Each level gets its own tagged Trend + threshold
// with abortOnFail:false so the run reports EVERY level rather than stopping at the first break.
//
// Target: SELF-HOSTED examples/expense-demo/app/server.js (D35). Never a shared public demo.
// Usage: k6 run -e BASE_URL=http://localhost:4500 scalability.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend } from 'k6/metrics';

const BASE_URL = __ENV.BASE_URL || 'http://localhost:4500';
const LATENCY_BUDGET_MS = Number(__ENV.LATENCY_BUDGET_MS || 200);
const LEVELS = (__ENV.LEVELS || '10,50,100,200,400').split(',').map(Number);
const STAGE = __ENV.STAGE || '15s';
const STAGE_S = Number(STAGE.replace('s', ''));

const trends = {};
const scenarios = {};
const thresholds = { http_req_failed: ['rate<0.05'] };

LEVELS.forEach((vus, i) => {
  const name = `vus_${vus}`;
  trends[name] = new Trend(`inbox_read_latency_${name}`, true);
  scenarios[name] = {
    executor: 'constant-vus',
    vus,
    duration: STAGE,
    startTime: `${i * (STAGE_S + 2)}s`,
    env: { LEVEL: name },
    exec: 'inboxRead',
  };
  // abortOnFail:false -> a broken level does not hide the levels after it (capacity curve)
  thresholds[`inbox_read_latency_${name}`] = [
    { threshold: `p(95)<${LATENCY_BUDGET_MS}`, abortOnFail: false },
  ];
});

export const options = { scenarios, thresholds };

export function setup() {
  const res = http.post(
    `${BASE_URL}/api/login`,
    JSON.stringify({ email: 'manager@demo', password: 'demo1234' }),
    { headers: { 'Content-Type': 'application/json' } }
  );
  check(res, { 'login succeeded': (r) => r.status === 200 });
  return { token: res.json('token') };
}

export function inboxRead(data) {
  const res = http.get(`${BASE_URL}/api/reports?scope=inbox`, {
    headers: { Authorization: `Bearer ${data.token}` },
  });
  trends[__ENV.LEVEL].add(res.timings.duration);
  check(res, { 'status is 200': (r) => r.status === 200 });
  sleep(0.1);
}
