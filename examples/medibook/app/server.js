// MediBook — minimal but realistic teleconsultation booking app (SUT for QAIA).
// Implements the US-001 acceptance criteria so generated tests have a real target.
// No external deps: Node http only. Deterministic in-memory store, reset per boot.
const http = require('http');
const fs = require('fs');
const path = require('path');

const NOW = () => Date.now();
const HOUR = 3600 * 1000;

// --- seed data -----------------------------------------------------------
function freshState() {
  const now = NOW();
  return {
    users: {
      'patient@demo': { pw: 'demo1234', role: 'patient', minor: false, guardianContact: null, id: 'p1' },
      'minor@demo': { pw: 'demo1234', role: 'patient', minor: true, guardianContact: 'guardian@demo', id: 'p2' },
      'minor-noguardian@demo': { pw: 'demo1234', role: 'patient', minor: true, guardianContact: null, id: 'p3' },
    },
    practitioners: [
      { id: 'dr1', name: 'Dr. Ada Reed', specialty: 'cardiology', minorsAuthorized: true },
      { id: 'dr2', name: 'Dr. Ben Cole', specialty: 'cardiology', minorsAuthorized: false },
      { id: 'dr3', name: 'Dr. Cara Ng', specialty: 'dermatology', minorsAuthorized: true },
    ],
    // slots: start relative to boot so "2h ahead" is testable deterministically
    slots: [
      { id: 's1', practitionerId: 'dr1', specialty: 'cardiology', start: now + 3 * HOUR, booked: false },
      { id: 's2', practitionerId: 'dr1', specialty: 'cardiology', start: now + 1 * HOUR, booked: false }, // < 2h: not bookable
      { id: 's3', practitionerId: 'dr2', specialty: 'cardiology', start: now + 5 * HOUR, booked: false },
      { id: 's4', practitionerId: 'dr3', specialty: 'dermatology', start: now + 4 * HOUR, booked: false },
      { id: 's5', practitionerId: 'dr1', specialty: 'cardiology', start: now + 26 * HOUR, booked: false },
    ],
    appointments: [], // {id, slotId, patientId, start, practitionerName, status}
    audit: [],
    seq: 1,
  };
}
let db = freshState();
const tokens = {}; // token -> email

function audit(action, who, detail) { db.audit.push({ action, who, detail, at: NOW() }); }
function upcomingCount(pid) { return db.appointments.filter(a => a.patientId === pid && a.status === 'booked' && a.start > NOW()).length; }
function json(res, code, obj) { res.writeHead(code, { 'Content-Type': 'application/json' }); res.end(JSON.stringify(obj)); }
function body(req) { return new Promise(r => { let d = ''; req.on('data', c => d += c); req.on('end', () => { try { r(JSON.parse(d || '{}')); } catch { r({}); } }); }); }
function auth(req) { const t = (req.headers.authorization || '').replace('Bearer ', ''); return tokens[t] ? { email: tokens[t], user: db.users[tokens[t]] } : null; }

const server = http.createServer(async (req, res) => {
  const u = new URL(req.url, 'http://x');
  const p = u.pathname;

  // --- API ---------------------------------------------------------------
  if (p === '/api/reset' && req.method === 'POST') { db = freshState(); for (const k in tokens) delete tokens[k]; return json(res, 200, { ok: true }); }

  if (p === '/api/login' && req.method === 'POST') {
    const b = await body(req); const user = db.users[b.email];
    if (!user || user.pw !== b.password) { audit('login_failed', b.email, {}); return json(res, 401, { error: 'invalid credentials' }); }
    const tok = 'tok-' + (db.seq++); tokens[tok] = b.email; audit('login', b.email, {});
    return json(res, 200, { token: tok, role: user.role, minor: user.minor });
  }

  if (p === '/api/slots' && req.method === 'GET') {
    const spec = u.searchParams.get('specialty');
    let slots = db.slots.filter(s => !s.booked);
    if (spec) slots = slots.filter(s => s.specialty === spec); // AC1: specialty filter
    const out = slots.map(s => ({ ...s, practitioner: db.practitioners.find(pr => pr.id === s.practitionerId).name, bookableNow: s.start >= NOW() + 2 * HOUR }));
    return json(res, 200, { slots: out, serverNow: NOW() });
  }

  if (p === '/api/book' && req.method === 'POST') {
    const a = auth(req); if (!a) return json(res, 401, { error: 'unauthenticated' });
    const b = await body(req); const slot = db.slots.find(s => s.id === b.slotId);
    if (!slot) return json(res, 404, { error: 'slot not found' });
    if (slot.booked) return json(res, 409, { error: 'slot no longer available' }); // AC4: race
    if (slot.start < NOW() + 2 * HOUR) return json(res, 422, { error: 'slot must start at least 2 hours ahead' }); // AC2
    if (upcomingCount(a.user.id) >= 3) return json(res, 422, { error: 'maximum 3 upcoming appointments' }); // AC3
    const pract = db.practitioners.find(pr => pr.id === slot.practitionerId);
    if (a.user.minor) { // AC7
      if (!pract.minorsAuthorized) return json(res, 422, { error: 'practitioner not authorized for minors' });
      if (!a.user.guardianContact) return json(res, 422, { error: 'guardian contact required for minors' });
    }
    slot.booked = true;
    const appt = { id: 'a' + (db.seq++), slotId: slot.id, patientId: a.user.id, start: slot.start, practitionerName: pract.name, status: 'booked', guardianNotified: a.user.minor ? a.user.guardianContact : null };
    db.appointments.push(appt); audit('book', a.email, { slotId: slot.id });
    return json(res, 201, { appointment: appt, confirmation: { practitioner: pract.name, startIso: new Date(slot.start).toISOString(), link: 'https://meet.demo/' + appt.id } }); // AC5
  }

  if (p === '/api/cancel' && req.method === 'POST') {
    const a = auth(req); if (!a) return json(res, 401, { error: 'unauthenticated' });
    const b = await body(req); const appt = db.appointments.find(x => x.id === b.appointmentId && x.patientId === a.user.id);
    if (!appt || appt.status !== 'booked') return json(res, 404, { error: 'appointment not found' });
    if (appt.start - NOW() < 4 * HOUR) return json(res, 422, { error: 'cancellation refused: less than 4 hours before start' }); // AC6
    appt.status = 'cancelled'; const slot = db.slots.find(s => s.id === appt.slotId); if (slot) slot.booked = false;
    audit('cancel', a.email, { appointmentId: appt.id });
    return json(res, 200, { ok: true });
  }

  if (p === '/api/appointments' && req.method === 'GET') {
    const a = auth(req); if (!a) return json(res, 401, { error: 'unauthenticated' });
    return json(res, 200, { appointments: db.appointments.filter(x => x.patientId === a.user.id) });
  }

  if (p === '/api/audit' && req.method === 'GET') {
    // Auth fix (found by the 2026-07-26 external audit workflow, live curl reproduction):
    // AC8 requires transitions to BE recorded (who/when) but never specifies WHO may read the
    // trail back -- silently resolved as fully open instead of authenticated-only, exposing
    // every patient's email and booking/cancellation activity to an unauthenticated caller.
    // Same class as expense-demo's identical gap (D96 IDOR lineage); same fix: default-deny.
    const a = auth(req); if (!a) return json(res, 401, { error: 'unauthenticated' });
    return json(res, 200, { audit: db.audit });
  }

  // --- static ------------------------------------------------------------
  let file = p === '/' ? '/index.html' : p;
  const fp = path.join(__dirname, 'public', file);
  if (fp.startsWith(path.join(__dirname, 'public')) && fs.existsSync(fp) && fs.statSync(fp).isFile()) {
    const ext = path.extname(fp); const ct = ext === '.html' ? 'text/html' : ext === '.js' ? 'text/javascript' : ext === '.css' ? 'text/css' : 'text/plain';
    res.writeHead(200, { 'Content-Type': ct }); return res.end(fs.readFileSync(fp));
  }
  json(res, 404, { error: 'not found' });
});

const PORT = process.env.PORT || 4400;
server.listen(PORT, () => console.log('MediBook SUT on http://localhost:' + PORT));
