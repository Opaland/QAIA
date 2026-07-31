// Probe 2: (a) dump verbatim response headers for the Headers/TLS scope item;
// (b) test whether /api/audit over-exposes cross-user data to a low-privilege authenticated user.
const http = require('http');
const fs = require('fs');
const path = require('path');
const BASE = { host: 'localhost', port: 4500 };
const EVDIR = path.join(__dirname, 'evidence');
function req(method, p, { token, body } = {}) {
  return new Promise((resolve, reject) => {
    const data = body ? JSON.stringify(body) : null;
    const headers = { 'Content-Type': 'application/json' };
    if (token) headers.Authorization = 'Bearer ' + token;
    if (data) headers['Content-Length'] = Buffer.byteLength(data);
    const r = http.request({ ...BASE, method, path: p, headers }, res => {
      let d = ''; res.on('data', c => (d += c));
      res.on('end', () => resolve({ reqLine: `${method} ${p}`, status: res.statusCode, headers: res.headers, body: safeParse(d) }));
    });
    r.on('error', reject); if (data) r.write(data); r.end();
  });
}
const safeParse = s => { try { return JSON.parse(s); } catch { return s; } };

(async () => {
  await req('POST', '/api/reset');
  const tok = {};
  for (const email of ['employee@demo', 'manager@demo', 'finance@demo', 'director@demo'])
    tok[email] = (await req('POST', '/api/login', { body: { email, password: 'demo1234' } })).body.token;

  // director submits a big report (>5000 -> chain manager,finance,director; director is submitter
  // so their slot handled by nextApproverRole). Simpler: employee submits a >5000 report.
  let c = await req('POST', '/api/reports', { token: tok['employee@demo'] });
  const rid = c.body.report.id;
  await req('PUT', `/api/reports/${rid}`, { token: tok['employee@demo'], body: { currency: 'EUR', lines: [{ category: 'travel', amount: 6000, date: '2026-07-24', receipt: 'big.png' }] } });
  await req('POST', `/api/reports/${rid}/submit`, { token: tok['employee@demo'] });
  // manager approves, finance approves, director REJECTS with a sensitive comment
  await req('POST', `/api/reports/${rid}/decide`, { token: tok['manager@demo'], body: { decision: 'approve' } });
  await req('POST', `/api/reports/${rid}/decide`, { token: tok['finance@demo'], body: { decision: 'approve' } });
  await req('POST', `/api/reports/${rid}/decide`, { token: tok['director@demo'], body: { decision: 'reject', comment: 'CONFIDENTIAL: suspected fraud, escalate to HR' } });

  // Now the PLAIN EMPLOYEE (lowest privilege) reads the full audit trail.
  const audit = await req('GET', '/api/audit', { token: tok['employee@demo'] });
  console.log('=== /api/audit read by plain employee (tok-1) ===');
  console.log('status', audit.status);
  console.log(JSON.stringify(audit.body, null, 2));

  // Header dump for Headers/TLS scope item
  const rootH = await req('GET', '/');
  const apiH = await req('GET', `/api/reports/${rid}`, { token: tok['employee@demo'] });
  const secHeaders = ['content-security-policy','x-frame-options','x-content-type-options','strict-transport-security','referrer-policy','set-cookie','permissions-policy'];
  const summarize = h => Object.fromEntries(secHeaders.map(k => [k, h[k] || '(absent)']));
  console.log('\n=== response headers (root GET /) ===');
  console.log('ALL:', JSON.stringify(rootH.headers, null, 2));
  console.log('SECURITY-RELEVANT:', JSON.stringify(summarize(rootH.headers), null, 2));
  console.log('\n=== response headers (GET /api/reports/:id) ===');
  console.log('SECURITY-RELEVANT:', JSON.stringify(summarize(apiH.headers), null, 2));

  fs.writeFileSync(path.join(EVDIR, 'audit-exposure.json'), JSON.stringify({ readerToken: tok['employee@demo'], readerRole: 'employee', request: 'GET /api/audit', status: audit.status, body: audit.body }, null, 2));
  fs.writeFileSync(path.join(EVDIR, 'headers.json'), JSON.stringify({ root: rootH.headers, api: apiH.headers, securityRelevant: { root: summarize(rootH.headers), api: summarize(apiH.headers) } }, null, 2));
  console.log('\nWROTE evidence/audit-exposure.json and evidence/headers.json');
})();
