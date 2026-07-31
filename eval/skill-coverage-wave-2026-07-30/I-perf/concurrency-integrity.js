// perf-check STEP 2 (concurrency integrity) applied literally to the self-hosted SUT
// examples/expense-demo/app/server.js (D35: self-hosted only).
// "race N clients on a limited resource (e.g. one bookable slot), assert exactly one succeeds
//  -- no oversell/double-spend."
// Limited resource here: a single `submitted` expense report can be decided exactly once
// (server.js:227 `only a submitted report can be decided`, AC7 terminal state).
// Tag: @QAIA-PERF-002 @perf:load (concurrency-integrity variant, per SKILL.md step 4)
//
// Usage: k6 run -e BASE_URL=http://localhost:4500 concurrency-integrity.js
import http from 'k6/http';
import { check } from 'k6';
import { Counter } from 'k6/metrics';

const BASE_URL = __ENV.BASE_URL || 'http://localhost:4500';
const RACERS = Number(__ENV.RACERS || 20);

const decideAccepted = new Counter('decide_accepted');
const decideRejected = new Counter('decide_conflict');

export const options = {
  scenarios: {
    race: { executor: 'shared-iterations', vus: RACERS, iterations: RACERS, maxDuration: '30s' },
  },
  thresholds: {
    // THE assertion: exactly one racer may win the single decidable report.
    decide_accepted: ['count==1'],
  },
};

function jpost(url, body, token) {
  const headers = { 'Content-Type': 'application/json' };
  if (token) headers.Authorization = `Bearer ${token}`;
  return http.post(url, JSON.stringify(body), { headers });
}

export function setup() {
  http.post(`${BASE_URL}/api/reset`, null);
  const emp = jpost(`${BASE_URL}/api/login`, { email: 'employee@demo', password: 'demo1234' });
  check(emp, { 'employee login 200': (r) => r.status === 200 });
  const empTok = emp.json('token');

  const created = jpost(`${BASE_URL}/api/reports`, {}, empTok);
  check(created, { 'draft created 201': (r) => r.status === 201 });
  const id = created.json('report.id');

  const today = new Date().toISOString().slice(0, 10);
  const put = http.put(
    `${BASE_URL}/api/reports/${id}`,
    JSON.stringify({ currency: 'EUR', lines: [{ category: 'meals', amount: 100, date: today, receipt: 'r.pdf' }] }),
    { headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${empTok}` } }
  );
  check(put, { 'draft edited 200': (r) => r.status === 200 });

  const sub = jpost(`${BASE_URL}/api/reports/${id}/submit`, {}, empTok);
  check(sub, { 'submitted 200': (r) => r.status === 200 });

  const mgr = jpost(`${BASE_URL}/api/login`, { email: 'manager@demo', password: 'demo1234' });
  check(mgr, { 'manager login 200': (r) => r.status === 200 });

  return { id, mgrTok: mgr.json('token') };
}

export default function (data) {
  const res = jpost(
    `${BASE_URL}/api/reports/${data.id}/decide`,
    { decision: 'reject', comment: 'rejected by concurrency race probe' },
    data.mgrTok
  );
  if (res.status === 200) decideAccepted.add(1);
  else if (res.status === 409) decideRejected.add(1);
  check(res, { 'decide answered 200 or 409': (r) => r.status === 200 || r.status === 409 });
  console.log(`racer -> ${res.status} ${res.body}`);
}

export function teardown(data) {
  const r = http.get(`${BASE_URL}/api/reports/${data.id}`, {
    headers: { Authorization: `Bearer ${data.mgrTok}` },
  });
  console.log(`final report state: ${r.status} ${r.body}`);
}
