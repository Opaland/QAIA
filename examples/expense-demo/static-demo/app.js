// ExpenseFlow UI — IDENTICAL to ../app/public/app.js except the api() function below, which
// calls the in-memory mock-backend.js instead of a real fetch (GitHub Pages serves static
// files only, no Node backend). Keeping the rest byte-for-byte the same means this static
// build is a faithful UI fixture for usability-heuristic-review/a11y-audit/visual-check, not a
// simplified stand-in that would test something other than the real app's actual markup.
let token = null, me = null, draftId = null, lineCount = 0;

const $ = (id) => document.getElementById(id);
function showMsg(text, ok) { $('message').textContent = text; $('message').className = 'msg ' + (ok ? 'ok' : 'error'); }

async function api(path, opts = {}) {
  const headers = Object.assign({ 'Content-Type': 'application/json' }, opts.headers || {});
  if (token) headers.Authorization = 'Bearer ' + token;
  return window.__mockBackend.handle(path, Object.assign({}, opts, { headers }));
}

$('login-btn').addEventListener('click', async () => {
  const email = $('email').value, password = $('password').value;
  const r = await api('/api/login', { method: 'POST', body: JSON.stringify({ email, password }) });
  if (!r.ok) { showMsg(r.data.error || 'login failed', false); return; }
  token = r.data.token; me = { email, role: r.data.role, name: r.data.name };
  $('login-section').hidden = true; $('app-section').hidden = false;
  $('whoami').textContent = me.name; $('role').textContent = me.role; $('role2').textContent = me.role;
  await refresh();
});

$('logout-btn').addEventListener('click', () => {
  token = null; me = null; draftId = null;
  $('login-section').hidden = false; $('app-section').hidden = true;
  $('mine').innerHTML = ''; $('inbox').innerHTML = ''; $('draft-section').hidden = true;
});

$('new-report-btn').addEventListener('click', async () => {
  const r = await api('/api/reports', { method: 'POST' });
  if (!r.ok) { showMsg(r.data.error, false); return; }
  draftId = r.data.report.id;
  $('draft-id').textContent = draftId;
  $('lines').innerHTML = ''; lineCount = 0;
  $('draft-section').hidden = false;
  addLineRow();
});

function addLineRow() {
  const idx = lineCount++;
  const row = document.createElement('div');
  row.className = 'line-row';
  row.innerHTML = `
    <input data-testid="line-category-${idx}" placeholder="Category" />
    <input data-testid="line-amount-${idx}" type="number" step="0.01" placeholder="Amount" />
    <input data-testid="line-date-${idx}" type="date" />
    <label><input data-testid="line-receipt-${idx}" type="checkbox" /> Receipt</label>
    <button data-testid="remove-line-${idx}" type="button">Remove</button>`;
  $('lines').appendChild(row);
  row.querySelector(`[data-testid="remove-line-${idx}"]`).addEventListener('click', () => row.remove());
}
$('add-line-btn').addEventListener('click', addLineRow);

function collectLines() {
  const rows = $('lines').querySelectorAll('.line-row');
  const lines = [];
  rows.forEach((row) => {
    const cat = row.querySelector('input[data-testid^="line-category-"]').value;
    const amt = parseFloat(row.querySelector('input[data-testid^="line-amount-"]').value);
    const date = row.querySelector('input[data-testid^="line-date-"]').value;
    const receipt = row.querySelector('input[data-testid^="line-receipt-"]').checked;
    if (cat || !isNaN(amt) || date) lines.push({ category: cat, amount: amt, date, receipt });
  });
  return lines;
}

$('submit-report-btn').addEventListener('click', async () => {
  const currency = $('currency').value;
  const lines = collectLines();
  const put = await api('/api/reports/' + draftId, { method: 'PUT', body: JSON.stringify({ currency, lines }) });
  if (!put.ok) { showMsg(put.data.error, false); return; }
  const r = await api('/api/reports/' + draftId + '/submit', { method: 'POST' });
  if (!r.ok) { showMsg(r.data.error, false); return; }
  showMsg('Report submitted (total ' + r.data.report.totalEur + ' EUR)', true);
  $('draft-section').hidden = true;
  await refresh();
});

async function refresh() {
  const mine = await api('/api/reports?scope=mine');
  renderList($('mine'), mine.data.reports || [], true);
  const inbox = await api('/api/reports?scope=inbox');
  renderList($('inbox'), inbox.data.reports || [], false);
}

function renderList(container, reports, isMine) {
  container.innerHTML = '';
  // a `role="list"` container needs a `role="listitem"` child even when empty
  // (WCAG/ARIA aria-required-children — found by the a11y automation, see traceability.md).
  if (reports.length === 0) { container.innerHTML = '<p role="listitem">No reports.</p>'; return; }
  for (const r of reports) {
    const div = document.createElement('div');
    div.className = 'card'; div.setAttribute('role', 'listitem'); div.setAttribute('data-testid', 'report-' + r.id);
    const statusClass = 'status status-' + r.status;
    div.innerHTML = `<p>Report <strong>${r.id}</strong> — <span class="${statusClass}" data-testid="status-${r.id}">${r.status}</span> — total: ${r.totalEur ?? '—'} EUR ${r.rateStale ? '<em>(stale FX rate)</em>' : ''}</p>`;
    if (isMine && r.status === 'draft') {
      div.innerHTML += `<button data-testid="edit-${r.id}">Edit & submit</button>`;
    }
    if (!isMine) {
      div.innerHTML += `
        <label for="comment-${r.id}">Comment (required for reject / changes-requested)</label>
        <textarea data-testid="comment-${r.id}" id="comment-${r.id}"></textarea>
        <button data-testid="approve-${r.id}">Approve</button>
        <button data-testid="reject-${r.id}">Reject</button>
        <button data-testid="changes-${r.id}">Request changes</button>`;
    }
    container.appendChild(div);
    if (isMine && r.status === 'draft') {
      div.querySelector('[data-testid="edit-' + r.id + '"]').addEventListener('click', () => {
        draftId = r.id; $('draft-id').textContent = r.id; $('lines').innerHTML = ''; lineCount = 0;
        $('draft-section').hidden = false; addLineRow();
      });
    }
    if (!isMine) {
      div.querySelector('[data-testid="approve-' + r.id + '"]').addEventListener('click', () => decide(r.id, 'approve'));
      div.querySelector('[data-testid="reject-' + r.id + '"]').addEventListener('click', () => decide(r.id, 'reject'));
      div.querySelector('[data-testid="changes-' + r.id + '"]').addEventListener('click', () => decide(r.id, 'changes-requested'));
    }
  }
}

async function decide(id, decision) {
  const comment = document.getElementById('comment-' + id) ? document.getElementById('comment-' + id).value : '';
  const r = await api('/api/reports/' + id + '/decide', { method: 'POST', body: JSON.stringify({ decision, comment }) });
  if (!r.ok) { showMsg(r.data.error, false); return; }
  showMsg('Decision recorded: ' + decision, true);
  await refresh();
}
