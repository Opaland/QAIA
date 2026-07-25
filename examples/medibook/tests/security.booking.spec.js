// Security surface tests (passive + auth boundary) — decision D26.
// Self-hosted SUT, so these are permitted (never run against shared public demos).
const { test, expect } = require('./fixtures');
const B = 'http://localhost:4400';

test.describe('MediBook security surface', () => {

  test('@QAIA-SEC-001 protected endpoint rejects missing token (401)', async ({ request }) => {
    const r = await request.get(B + '/api/appointments');
    expect(r.status()).toBe(401);
  });

  test('@QAIA-SEC-002 protected endpoint rejects forged/invalid token (401)', async ({ request }) => {
    const r = await request.get(B + '/api/appointments', { headers: { Authorization: 'Bearer forged-token-xyz' } });
    expect(r.status()).toBe(401);
  });

  test('@QAIA-SEC-003 one patient cannot cancel another patient\'s appointment (IDOR)', async ({ request }) => {
    // patient books
    const t1 = (await (await request.post(B + '/api/login', { data: { email: 'patient@demo', password: 'demo1234' } })).json()).token;
    const appt = (await (await request.post(B + '/api/book', { headers: { Authorization: 'Bearer ' + t1 }, data: { slotId: 's5' } })).json()).appointment;
    // a different patient tries to cancel it by id
    const t2 = (await (await request.post(B + '/api/login', { data: { email: 'minor@demo', password: 'demo1234' } })).json()).token;
    const r = await request.post(B + '/api/cancel', { headers: { Authorization: 'Bearer ' + t2 }, data: { appointmentId: appt.id } });
    expect(r.status()).toBe(404); // not visible to another patient — no cross-tenant access
  });

  test('@QAIA-SEC-004 malformed JSON body does not 500 the server', async ({ request }) => {
    const r = await request.post(B + '/api/login', { headers: { 'Content-Type': 'application/json' }, data: '{ not valid json' });
    expect([400, 401]).toContain(r.status()); // rejected cleanly, never a 5xx
  });

  test('@QAIA-SEC-005 login does not leak which factor failed (user enumeration)', async ({ request }) => {
    const unknown = await request.post(B + '/api/login', { data: { email: 'nobody@demo', password: 'x' } });
    const wrongPw = await request.post(B + '/api/login', { data: { email: 'patient@demo', password: 'wrong' } });
    const b1 = await unknown.json(), b2 = await wrongPw.json();
    expect(unknown.status()).toBe(401);
    expect(wrongPw.status()).toBe(401);
    expect(b1.error).toBe(b2.error); // identical message → no account-existence disclosure
  });
});
