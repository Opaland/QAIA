// Shared API helpers for declarative precondition seeding (T3/T4) — used by both the API
// spec and the E2E spec, which sets up state via the API and only exercises the SUT's UI
// for the actual step under test (atomic scenarios, no UI-chained setup).
async function apiLogin(request, baseURL, email, password = 'demo1234') {
  const r = await request.post(baseURL + '/api/login', { data: { email, password } });
  if (!r.ok()) return null;
  return (await r.json()).token;
}

async function apiCreateDraft(request, baseURL, token, { currency = 'EUR', lines }) {
  const created = await request.post(baseURL + '/api/reports', { headers: { Authorization: 'Bearer ' + token } });
  const { report } = await created.json();
  await request.put(baseURL + '/api/reports/' + report.id, { headers: { Authorization: 'Bearer ' + token }, data: { currency, lines } });
  return report.id;
}

async function apiSubmit(request, baseURL, token, id) {
  return request.post(baseURL + '/api/reports/' + id + '/submit', { headers: { Authorization: 'Bearer ' + token } });
}

async function apiCreateSubmittedReport(request, baseURL, token, opts) {
  const id = await apiCreateDraft(request, baseURL, token, opts);
  const r = await apiSubmit(request, baseURL, token, id);
  return { id, submitResponse: r };
}

async function apiDecide(request, baseURL, token, id, decision, comment) {
  return request.post(baseURL + '/api/reports/' + id + '/decide', { headers: { Authorization: 'Bearer ' + token }, data: { decision, comment } });
}

function daysAgoISO(n) { return new Date(Date.now() - n * 24 * 3600 * 1000).toISOString().slice(0, 10); }
function todayISO() { return daysAgoISO(0); }

module.exports = { apiLogin, apiCreateDraft, apiSubmit, apiCreateSubmittedReport, apiDecide, daysAgoISO, todayISO };
