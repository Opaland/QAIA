let token = null;
const $ = (id) => document.getElementById(id);
const api = (path, opts = {}) => fetch(path, { ...opts, headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: 'Bearer ' + token } : {}), ...(opts.headers || {}) } });
function msg(text, kind) { const m = $('message') || document.body; m.className = 'msg ' + kind; m.textContent = text; }

$('login-btn').addEventListener('click', async () => {
  const r = await api('/api/login', { method: 'POST', body: JSON.stringify({ email: $('email').value, password: $('password').value }) });
  const d = await r.json();
  if (!r.ok) { let m = $('message'); if (!m) { m = document.createElement('div'); m.id = 'message'; m.setAttribute('role', 'status'); $('login-section').appendChild(m); } m.className = 'msg error'; m.textContent = d.error; return; }
  token = d.token; $('login-section').hidden = true; $('app-section').hidden = false;
  $('whoami').textContent = $('email').value; loadSlots(); loadAppointments();
});
$('logout-btn').addEventListener('click', () => { token = null; $('app-section').hidden = true; $('login-section').hidden = false; });
$('specialty').addEventListener('change', loadSlots);

async function loadSlots() {
  const spec = $('specialty').value;
  const r = await api('/api/slots' + (spec ? '?specialty=' + spec : ''));
  const d = await r.json();
  const box = $('slots'); box.innerHTML = '';
  d.slots.forEach(s => {
    const el = document.createElement('div'); el.className = 'slot'; el.setAttribute('role', 'listitem'); el.dataset.slotId = s.id;
    const when = new Date(s.start).toLocaleString();
    el.innerHTML = `<span>${s.practitioner} — ${s.specialty} — ${when}</span>`;
    const btn = document.createElement('button'); btn.textContent = 'Book'; btn.dataset.testid = 'book-' + s.id;
    btn.disabled = !s.bookableNow; if (!s.bookableNow) btn.title = 'Starts in less than 2 hours';
    btn.addEventListener('click', () => book(s.id));
    el.appendChild(btn); box.appendChild(el);
  });
}
async function book(slotId) {
  const r = await api('/api/book', { method: 'POST', body: JSON.stringify({ slotId }) });
  const d = await r.json();
  if (!r.ok) return msg(d.error, 'error');
  msg('Booking confirmed with ' + d.confirmation.practitioner, 'ok'); loadSlots(); loadAppointments();
}
async function loadAppointments() {
  const r = await api('/api/appointments'); const d = await r.json();
  const box = $('appointments'); box.innerHTML = '';
  (d.appointments || []).forEach(a => {
    const el = document.createElement('div'); el.className = 'slot'; el.setAttribute('role', 'listitem');
    el.innerHTML = `<span>${a.practitionerName} — ${new Date(a.start).toLocaleString()} — ${a.status}</span>`;
    if (a.status === 'booked') { const c = document.createElement('button'); c.textContent = 'Cancel'; c.dataset.testid = 'cancel-' + a.id; c.addEventListener('click', () => cancel(a.id)); el.appendChild(c); }
    box.appendChild(el);
  });
}
async function cancel(appointmentId) {
  const r = await api('/api/cancel', { method: 'POST', body: JSON.stringify({ appointmentId }) });
  const d = await r.json();
  if (!r.ok) return msg(d.error, 'error');
  msg('Appointment cancelled', 'ok'); loadSlots(); loadAppointments();
}
