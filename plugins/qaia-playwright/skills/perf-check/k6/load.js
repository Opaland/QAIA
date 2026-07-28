// k6 load-test shape (CT-PT, D95) -- perf-check step 3, "load" type.
// Realistic expected concurrency, steady stage; asserts the latency budget holds under normal
// traffic. This is a TEMPLATE: BASE_URL, LOGIN body, and the target endpoint/budget are the
// only parts a generated test should need to change to point at a different self-hosted SUT
// (D35 -- self-hosted targets only, never a shared public demo).
//
// Usage: k6 run -e BASE_URL=http://localhost:4599 load.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend } from 'k6/metrics';

const BASE_URL = __ENV.BASE_URL || 'http://localhost:4500';
const LATENCY_BUDGET_MS = Number(__ENV.LATENCY_BUDGET_MS || 200); // p95 budget, asserted below

const inboxLatency = new Trend('inbox_read_latency', true);

export const options = {
  scenarios: {
    load: {
      executor: 'constant-vus',
      vus: Number(__ENV.VUS || 10),
      duration: __ENV.DURATION || '20s',
    },
  },
  thresholds: {
    // The real assertion: p95 must stay under budget. k6 fails the run (exit code 99) if not.
    inbox_read_latency: [`p(95)<${LATENCY_BUDGET_MS}`],
    http_req_failed: ['rate<0.01'],
  },
};

export function setup() {
  const res = http.post(
    `${BASE_URL}/api/login`,
    JSON.stringify({ email: 'manager@demo', password: 'demo1234' }),
    { headers: { 'Content-Type': 'application/json' } }
  );
  check(res, { 'login succeeded': (r) => r.status === 200 });
  return { token: res.json('token') };
}

export default function (data) {
  const res = http.get(`${BASE_URL}/api/reports?scope=inbox`, {
    headers: { Authorization: `Bearer ${data.token}` },
  });
  inboxLatency.add(res.timings.duration);
  check(res, { 'status is 200': (r) => r.status === 200 });
  sleep(0.1);
}
