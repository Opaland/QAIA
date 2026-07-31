// Real HTTP probe harness for security-surface eval (wave B, K-security).
// Runs passive checks against the live ExpenseFlow SUT (node app/server.js on :4500).
// Captures verbatim request line + response status + body for each check. No exploitation
// beyond passive surface. Writes evidence to ./evidence/*.json and prints a summary.
const http = require('http');
const fs = require('fs');
const path = require('path');
const BASE = { host: 'localhost', port: 4500 };
const EVDIR = path.join(__dirname, 'evidence');
fs.mkdirSync(EVDIR, { recursive: true });

function req(method, p, { token, body } = {}) {
  return new Promise((resolve, reject) => {
    const data = body ? JSON.stringify(body) : null;
    const headers = { 'Content-Type': 'application/json' };
    if (token) headers.Authorization = 'Bearer ' + token;
    if (data) headers['Content-Length'] = Buffer.byteLength(data);
    const r = http.request({ ...BASE, method, path: p, headers }, res => {
      let d = '';
      res.on('data', c => (d += c));
      res.on('end', () => resolve({ reqLine: `${method} ${p}`, sentBody: body || null, status: res.statusCode, headers: res.headers, body: safeParse(d), rawBody: d }));
    });
    r.on('error', reject);
    if (data) r.write(data);
    r.end();
  });
}
const safeParse = s => { try { return JSON.parse(s); } catch { return s; } };
const log = [];
function record(label, r) { log.push({ label, ...r }); console.log(`[${label}] ${r.reqLine} -> ${r.status} ${JSON.stringify(r.body).slice(0, 200)}`); return r; }

(async () => {
  // ---- setup: reset + login all four roles
  await req('POST', '/api/reset');
  const tok = {};
  for (const email of ['employee@demo', 'manager@demo', 'finance@demo', 'director@demo']) {
    const r = await req('POST', '/api/login', { body: { email, password: 'demo1234' } });
    tok[email] = r.body.token;
  }
  console.log('tokens:', tok);

  // employee creates + submits a report (financial asset: a real report owned by employee)
  let c = await req('POST', '/api/reports', { token: tok['employee@demo'] });
  const rid = c.body.report.id;
  await req('PUT', `/api/reports/${rid}`, { token: tok['employee@demo'], body: { currency: 'EUR', lines: [{ category: 'travel', amount: 300, date: '2026-07-24', receipt: 'r1.png' }] } });
  await req('POST', `/api/reports/${rid}/submit`, { token: tok['employee@demo'] });
  console.log('seeded report', rid, 'owned by employee, submitted (awaits manager)');

  // ===== CHECK 1: IDOR / cross-tenant read (D96 non-regression) =====
  // finance@demo is neither owner nor current approver (chain awaits manager). Must NOT read.
  record('IDOR-finance-reads-employee-report', await req('GET', `/api/reports/${rid}`, { token: tok['finance@demo'] }));
  // director likewise not current approver
  record('IDOR-director-reads-employee-report', await req('GET', `/api/reports/${rid}`, { token: tok['director@demo'] }));
  // owner CAN read (control)
  record('CONTROL-owner-reads-own', await req('GET', `/api/reports/${rid}`, { token: tok['employee@demo'] }));
  // manager IS current approver -> allowed
  record('CONTROL-current-approver-reads', await req('GET', `/api/reports/${rid}`, { token: tok['manager@demo'] }));

  // ===== CHECK 2: Auth boundaries (401 on missing/forged token) =====
  record('AUTH-no-token-get-report', await req('GET', `/api/reports/${rid}`));
  record('AUTH-forged-token-get-report', await req('GET', `/api/reports/${rid}`, { token: 'tok-forged-999' }));
  record('AUTH-no-token-list', await req('GET', '/api/reports?scope=mine'));
  record('AUTH-no-token-audit', await req('GET', '/api/audit'));

  // ===== CHECK 3: IDOR / cross-tenant MUTATE (privileged approval boundary) =====
  // finance tries to approve a report that currently awaits manager -> must be 403
  record('MUTATE-finance-approves-out-of-turn', await req('POST', `/api/reports/${rid}/decide`, { token: tok['finance@demo'], body: { decision: 'approve' } }));
  // employee (submitter) tries to approve own report -> 403 (AC3)
  record('MUTATE-self-approval', await req('POST', `/api/reports/${rid}/decide`, { token: tok['employee@demo'], body: { decision: 'approve' } }));
  // director tries to edit employee's report via PUT -> 404 (not owner)
  record('MUTATE-nonowner-edit', await req('PUT', `/api/reports/${rid}`, { token: tok['director@demo'], body: { lines: [] } }));

  // ===== CHECK 4: User enumeration on login =====
  record('ENUM-unknown-user', await req('POST', '/api/login', { body: { email: 'nobody@demo', password: 'whatever' } }));
  record('ENUM-known-user-wrong-pw', await req('POST', '/api/login', { body: { email: 'employee@demo', password: 'wrongpw' } }));

  // ===== CHECK 5: Robust error handling (malformed body/params -> clean 4xx, never 5xx) =====
  record('ERR-malformed-json-login', await new Promise((resolve, reject) => {
    const bad = '{not json';
    const r = http.request({ ...BASE, method: 'POST', path: '/api/login', headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(bad) } }, res => { let d=''; res.on('data',c=>d+=c); res.on('end',()=>resolve({reqLine:'POST /api/login (malformed json)', sentBody: bad, status:res.statusCode, headers:res.headers, body:safeParse(d), rawBody:d})); });
    r.on('error', reject); r.write(bad); r.end();
  }));
  record('ERR-unknown-scope', await req('GET', '/api/reports?scope=../etc', { token: tok['employee@demo'] }));
  record('ERR-decide-no-body', await req('POST', `/api/reports/${rid}/decide`, { token: tok['manager@demo'] }));
  record('ERR-suggest-empty', await req('POST', '/api/suggest-category', { token: tok['employee@demo'], body: {} }));

  // ===== CHECK 6: Headers / cookies / TLS =====
  record('HEADERS-root', await req('GET', '/'));
  record('HEADERS-api-report', await req('GET', `/api/reports/${rid}`, { token: tok['employee@demo'] }));

  // ===== CHECK 7: static path traversal (passive probe of the static handler) =====
  record('TRAVERSAL-dotdot', await req('GET', '/../server.js'));
  record('TRAVERSAL-encoded', await req('GET', '/..%2fserver.js'));

  fs.writeFileSync(path.join(EVDIR, 'probe-log.json'), JSON.stringify(log, null, 2));
  console.log('\nWROTE evidence/probe-log.json with', log.length, 'records');
})();
