// API tests — Playwright request context (no browser). Same scenario IDs, API-level.
const { test, expect } = require('./fixtures');
const B = 'http://localhost:4400';

async function login(request, email, pw = 'demo1234') {
  const r = await request.post(B + '/api/login', { data: { email, password: pw } });
  return r.ok() ? (await r.json()).token : null;
}

test.describe('MediBook API (US-001)', () => {

  test('@QAIA-US-001-101 @AC1 GET /slots?specialty filters server-side', async ({ request }) => {
    const r = await request.get(B + '/api/slots?specialty=dermatology');
    expect(r.status()).toBe(200);
    const d = await r.json();
    expect(d.slots.every(s => s.specialty === 'dermatology')).toBeTruthy();
  });

  test('@QAIA-US-001-102 @AC2 @boundary book slot <2h ahead → 422', async ({ request }) => {
    const t = await login(request, 'patient@demo');
    const r = await request.post(B + '/api/book', { headers: { Authorization: 'Bearer ' + t }, data: { slotId: 's2' } });
    expect(r.status()).toBe(422);
    expect((await r.json()).error).toContain('2 hours');
  });

  test('@QAIA-US-001-103 @AC4 @negative double-booking same slot → 409 for the second', async ({ request }) => {
    const t1 = await login(request, 'patient@demo');
    const t2 = await login(request, 'minor@demo'); // authorized minor with guardian, cardiology dr1 ok
    const first = await request.post(B + '/api/book', { headers: { Authorization: 'Bearer ' + t1 }, data: { slotId: 's3' } });
    const second = await request.post(B + '/api/book', { headers: { Authorization: 'Bearer ' + t2 }, data: { slotId: 's3' } });
    expect(first.status()).toBe(201);
    expect(second.status()).toBe(409);
  });

  test('@QAIA-US-001-104 @AC3 @boundary 4th upcoming appointment refused', async ({ request }) => {
    const t = await login(request, 'patient@demo');
    for (const s of ['s1', 's3', 's5']) {
      const r = await request.post(B + '/api/book', { headers: { Authorization: 'Bearer ' + t }, data: { slotId: s } });
      expect(r.status()).toBe(201);
    }
    // add a 4th bookable slot dynamically is not possible; instead the 3 above = cap, 4th attempt on s4 (dermatology, +4h)
    const r4 = await request.post(B + '/api/book', { headers: { Authorization: 'Bearer ' + t }, data: { slotId: 's4' } });
    expect(r4.status()).toBe(422);
    expect((await r4.json()).error).toContain('maximum 3');
  });

  test('@QAIA-US-001-105 @AC7 @decision-table minor without guardian contact refused', async ({ request }) => {
    const t = await login(request, 'minor-noguardian@demo');
    const r = await request.post(B + '/api/book', { headers: { Authorization: 'Bearer ' + t }, data: { slotId: 's1' } });
    expect(r.status()).toBe(422);
    expect((await r.json()).error).toContain('guardian');
  });

  test('@QAIA-US-001-106 @AC7 @decision-table minor booking unauthorized practitioner refused', async ({ request }) => {
    const t = await login(request, 'minor@demo'); // has guardian, but dr2 not authorized for minors
    const r = await request.post(B + '/api/book', { headers: { Authorization: 'Bearer ' + t }, data: { slotId: 's3' } });
    expect(r.status()).toBe(422);
    expect((await r.json()).error).toContain('not authorized for minors');
  });

  test('@QAIA-US-001-107 @AC-auth @negative booking without token → 401', async ({ request }) => {
    const r = await request.post(B + '/api/book', { data: { slotId: 's1' } });
    expect(r.status()).toBe(401);
  });

  test('@QAIA-US-001-108 @AC8 booking is recorded in the audit trail', async ({ request }) => {
    const t = await login(request, 'patient@demo');
    await request.post(B + '/api/book', { headers: { Authorization: 'Bearer ' + t }, data: { slotId: 's1' } });
    // /api/audit now requires auth (external audit finding, 2026-07-26: it was unauthenticated,
    // leaking every patient's email/booking activity -- fixed in server.js).
    const a = await request.get(B + '/api/audit', { headers: { Authorization: 'Bearer ' + t } });
    expect(a.status()).toBe(200);
    const events = (await a.json()).audit.map(e => e.action);
    expect(events).toContain('book');
  });

  test('@QAIA-US-001-109 @AC8 @negative reading the audit trail without authentication is refused', async ({ request }) => {
    const r = await request.get(B + '/api/audit');
    expect(r.status()).toBe(401);
  });
});
