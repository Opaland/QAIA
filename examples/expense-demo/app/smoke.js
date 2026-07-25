// Manual smoke script (not part of the test suite) to sanity-check the SUT before automating.
const B = 'http://localhost:4500';
async function api(path, opts = {}) {
  const r = await fetch(B + path, opts);
  const d = await r.json().catch(() => ({}));
  return { status: r.status, data: d };
}
async function login(email) {
  const r = await api('/api/login', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ email, password: 'demo1234' }) });
  return r.data.token;
}
(async () => {
  await api('/api/reset', { method: 'POST' });
  const empTok = await login('employee@demo');
  const mgrTok = await login('manager@demo');
  const finTok = await login('finance@demo');
  const dirTok = await login('director@demo');

  // Band A: small report < 500 -> manager only
  let r = await api('/api/reports', { method: 'POST', headers: { Authorization: 'Bearer ' + empTok } });
  const id1 = r.data.report.id;
  await api('/api/reports/' + id1, { method: 'PUT', headers: { Authorization: 'Bearer ' + empTok, 'Content-Type': 'application/json' },
    body: JSON.stringify({ currency: 'EUR', lines: [{ category: 'meal', amount: 40, date: '2026-07-24', receipt: true }] }) });
  r = await api('/api/reports/' + id1 + '/submit', { method: 'POST', headers: { Authorization: 'Bearer ' + empTok } });
  console.log('submit band A ->', r.status, r.data.report.totalEur);
  r = await api('/api/reports/' + id1 + '/decide', { method: 'POST', headers: { Authorization: 'Bearer ' + mgrTok, 'Content-Type': 'application/json' }, body: JSON.stringify({ decision: 'approve' }) });
  console.log('manager approve band A ->', r.status, r.data.report.status);

  // Band C: large report > 5000 -> manager, finance, director
  r = await api('/api/reports', { method: 'POST', headers: { Authorization: 'Bearer ' + empTok } });
  const id2 = r.data.report.id;
  await api('/api/reports/' + id2, { method: 'PUT', headers: { Authorization: 'Bearer ' + empTok, 'Content-Type': 'application/json' },
    body: JSON.stringify({ currency: 'EUR', lines: [{ category: 'conference', amount: 6000, date: '2026-07-24', receipt: true }] }) });
  r = await api('/api/reports/' + id2 + '/submit', { method: 'POST', headers: { Authorization: 'Bearer ' + empTok } });
  console.log('submit band C ->', r.status, r.data.report.totalEur);
  r = await api('/api/reports/' + id2 + '/decide', { method: 'POST', headers: { Authorization: 'Bearer ' + mgrTok, 'Content-Type': 'application/json' }, body: JSON.stringify({ decision: 'approve' }) });
  console.log('manager approve band C ->', r.status, r.data.report.status);
  r = await api('/api/reports/' + id2 + '/decide', { method: 'POST', headers: { Authorization: 'Bearer ' + finTok, 'Content-Type': 'application/json' }, body: JSON.stringify({ decision: 'approve' }) });
  console.log('finance approve band C ->', r.status, r.data.report.status);
  r = await api('/api/reports/' + id2 + '/decide', { method: 'POST', headers: { Authorization: 'Bearer ' + dirTok, 'Content-Type': 'application/json' }, body: JSON.stringify({ decision: 'approve' }) });
  console.log('director approve band C ->', r.status, r.data.report.status);

  // manager submits own small report -> should escalate to finance (Q2)
  r = await api('/api/reports', { method: 'POST', headers: { Authorization: 'Bearer ' + mgrTok } });
  const id3 = r.data.report.id;
  await api('/api/reports/' + id3, { method: 'PUT', headers: { Authorization: 'Bearer ' + mgrTok, 'Content-Type': 'application/json' },
    body: JSON.stringify({ currency: 'EUR', lines: [{ category: 'taxi', amount: 30, date: '2026-07-24', receipt: true }] }) });
  r = await api('/api/reports/' + id3 + '/submit', { method: 'POST', headers: { Authorization: 'Bearer ' + mgrTok } });
  console.log('submit manager-owned band A ->', r.status);
  r = await api('/api/reports?scope=inbox', { headers: { Authorization: 'Bearer ' + finTok } });
  console.log('finance inbox after manager self-submit (expect id3) ->', r.data.reports.map(x => x.id));

  // reject path
  r = await api('/api/reports/' + id3 + '/decide', { method: 'POST', headers: { Authorization: 'Bearer ' + finTok, 'Content-Type': 'application/json' }, body: JSON.stringify({ decision: 'reject', comment: 'not a business expense' }) });
  console.log('finance reject ->', r.status, r.data.report.status);
  r = await api('/api/reports/' + id3, { method: 'PUT', headers: { Authorization: 'Bearer ' + mgrTok, 'Content-Type': 'application/json' }, body: JSON.stringify({ currency: 'EUR', lines: [] }) });
  console.log('edit after reject (expect 409 terminal) ->', r.status, r.data.error);

  // 90-day / receipt / fx errors
  r = await api('/api/reports', { method: 'POST', headers: { Authorization: 'Bearer ' + empTok } });
  const id4 = r.data.report.id;
  await api('/api/reports/' + id4, { method: 'PUT', headers: { Authorization: 'Bearer ' + empTok, 'Content-Type': 'application/json' },
    body: JSON.stringify({ currency: 'EUR', lines: [{ category: 'old', amount: 10, date: '2026-01-01', receipt: false }] }) });
  r = await api('/api/reports/' + id4 + '/submit', { method: 'POST', headers: { Authorization: 'Bearer ' + empTok } });
  console.log('submit >90 day line ->', r.status, r.data.error);

  r = await api('/api/reports', { method: 'POST', headers: { Authorization: 'Bearer ' + empTok } });
  const id5 = r.data.report.id;
  await api('/api/reports/' + id5, { method: 'PUT', headers: { Authorization: 'Bearer ' + empTok, 'Content-Type': 'application/json' },
    body: JSON.stringify({ currency: 'EUR', lines: [{ category: 'gear', amount: 30, date: '2026-07-24', receipt: false }] }) });
  r = await api('/api/reports/' + id5 + '/submit', { method: 'POST', headers: { Authorization: 'Bearer ' + empTok } });
  console.log('submit >=25 no receipt ->', r.status, r.data.error);

  r = await api('/api/reports', { method: 'POST', headers: { Authorization: 'Bearer ' + empTok } });
  const id6 = r.data.report.id;
  await api('/api/reports/' + id6, { method: 'PUT', headers: { Authorization: 'Bearer ' + empTok, 'Content-Type': 'application/json' },
    body: JSON.stringify({ currency: 'USD', lines: [{ category: 'hotel', amount: 100, date: '2026-07-25', receipt: true }] }) });
  r = await api('/api/reports/' + id6 + '/submit', { method: 'POST', headers: { Authorization: 'Bearer ' + empTok } });
  console.log('submit USD on weekend gap (stale fallback) ->', r.status, r.data.report.totalEur, r.data.report.rateStale);
})();
