// API tests — Playwright request context (no browser). Same scenario IDs as the QAIA
// test book (qaia-journey/testbooks/US-004/*.feature), API-level. Covers the boundary/decision-table
// heavy conditions (AC2, AC3, AC5, AC6, AC8, auth) more efficiently than a UI would.
const { test, expect } = require('./fixtures');
const { apiLogin, apiCreateDraft, apiSubmit, apiCreateSubmittedReport, apiDecide, daysAgoISO, todayISO } = require('./helpers');

const B = 'http://localhost:4500';

test.describe('ExpenseFlow API (US-004)', () => {

  // --- AC1 / AC7 remainder (E2E covers 001-004; API covers the negative state-machine cases) ---

  test('@QAIA-US-004-005 @AC1 @P2 @negative submitting an already-submitted report is refused', async ({ request }) => {
    const t = await apiLogin(request, B, 'employee@demo');
    const { id } = await apiCreateSubmittedReport(request, B, t, { lines: [{ category: 'taxi', amount: 20, date: todayISO(), receipt: true }] });
    const r = await request.post(B + '/api/reports/' + id + '/submit', { headers: { Authorization: 'Bearer ' + t } });
    expect(r.status()).toBe(409);
  });

  test('@QAIA-US-004-006 @AC1 @P2 @negative editing a submitted report is refused', async ({ request }) => {
    const t = await apiLogin(request, B, 'employee@demo');
    const { id } = await apiCreateSubmittedReport(request, B, t, { lines: [{ category: 'taxi', amount: 20, date: todayISO(), receipt: true }] });
    const r = await request.put(B + '/api/reports/' + id, { headers: { Authorization: 'Bearer ' + t }, data: { currency: 'EUR', lines: [] } });
    expect(r.status()).toBe(409);
  });

  test('@QAIA-US-004-007 @AC1 @AC7 @P1 @negative @low-confidence a draft via changes-requested cannot be rejected directly (open: Q3)', async ({ request }) => {
    const emp = await apiLogin(request, B, 'employee@demo');
    const mgr = await apiLogin(request, B, 'manager@demo');
    const { id } = await apiCreateSubmittedReport(request, B, emp, { lines: [{ category: 'taxi', amount: 20, date: todayISO(), receipt: true }] });
    const cr = await apiDecide(request, B, mgr, id, 'changes-requested', 'please add more detail');
    expect((await cr.json()).report.status).toBe('draft');
    const rej = await apiDecide(request, B, mgr, id, 'reject', 'not acceptable at all now');
    expect(rej.status()).toBe(409);
  });

  test('@QAIA-US-004-028 @AC7 @P2 @negative a rejected report cannot be edited', async ({ request }) => {
    const emp = await apiLogin(request, B, 'employee@demo');
    const mgr = await apiLogin(request, B, 'manager@demo');
    const { id } = await apiCreateSubmittedReport(request, B, emp, { lines: [{ category: 'taxi', amount: 20, date: todayISO(), receipt: true }] });
    await apiDecide(request, B, mgr, id, 'reject', 'not a business expense');
    const r = await request.put(B + '/api/reports/' + id, { headers: { Authorization: 'Bearer ' + emp }, data: { currency: 'EUR', lines: [] } });
    expect(r.status()).toBe(409);
  });

  test('@QAIA-US-004-029 @AC7 @P2 @negative a rejected report cannot be re-submitted', async ({ request }) => {
    const emp = await apiLogin(request, B, 'employee@demo');
    const mgr = await apiLogin(request, B, 'manager@demo');
    const { id } = await apiCreateSubmittedReport(request, B, emp, { lines: [{ category: 'taxi', amount: 20, date: todayISO(), receipt: true }] });
    await apiDecide(request, B, mgr, id, 'reject', 'not a business expense');
    const r = await request.post(B + '/api/reports/' + id + '/submit', { headers: { Authorization: 'Bearer ' + emp } });
    expect(r.status()).toBe(409);
  });

  // --- AC2 boundaries ---

  test('@QAIA-US-004-008 @AC2 @P1 @boundary just under €500 needs only manager', async ({ request }) => {
    const emp = await apiLogin(request, B, 'employee@demo');
    const { id } = await apiCreateSubmittedReport(request, B, emp, { lines: [{ category: 'x', amount: 499.99, date: todayISO(), receipt: true }] });
    const mgr = await apiLogin(request, B, 'manager@demo');
    const r = await apiDecide(request, B, mgr, id, 'approve');
    expect((await r.json()).report.status).toBe('approved');
  });

  test('@QAIA-US-004-009 @AC2 @P1 @boundary @low-confidence exactly €500.00 needs manager then finance (open: Q1)', async ({ request }) => {
    const emp = await apiLogin(request, B, 'employee@demo');
    const { id } = await apiCreateSubmittedReport(request, B, emp, { lines: [{ category: 'x', amount: 500.00, date: todayISO(), receipt: true }] });
    const mgr = await apiLogin(request, B, 'manager@demo');
    const r = await apiDecide(request, B, mgr, id, 'approve');
    expect((await r.json()).report.status).toBe('submitted'); // still awaits finance
  });

  test('@QAIA-US-004-010 @AC2 @P1 @boundary @low-confidence exactly €5000.00 stays in manager+finance band (open: Q1)', async ({ request }) => {
    const emp = await apiLogin(request, B, 'employee@demo');
    const { id } = await apiCreateSubmittedReport(request, B, emp, { lines: [{ category: 'x', amount: 5000.00, date: todayISO(), receipt: true }] });
    const mgr = await apiLogin(request, B, 'manager@demo');
    const fin = await apiLogin(request, B, 'finance@demo');
    await apiDecide(request, B, mgr, id, 'approve');
    const r = await apiDecide(request, B, fin, id, 'approve');
    expect((await r.json()).report.status).toBe('approved'); // no director step
  });

  test('@QAIA-US-004-011 @AC2 @P1 @boundary just above €5000 needs manager, finance, director', async ({ request }) => {
    const emp = await apiLogin(request, B, 'employee@demo');
    const { id } = await apiCreateSubmittedReport(request, B, emp, { lines: [{ category: 'x', amount: 5000.01, date: todayISO(), receipt: true }] });
    const mgr = await apiLogin(request, B, 'manager@demo');
    const fin = await apiLogin(request, B, 'finance@demo');
    const dir = await apiLogin(request, B, 'director@demo');
    await apiDecide(request, B, mgr, id, 'approve');
    const midway = await apiDecide(request, B, fin, id, 'approve');
    expect((await midway.json()).report.status).toBe('submitted');
    const r = await apiDecide(request, B, dir, id, 'approve');
    expect((await r.json()).report.status).toBe('approved');
  });

  test('@QAIA-US-004-012 @AC2 @P1 @negative approver acting out of chain order is refused', async ({ request }) => {
    const emp = await apiLogin(request, B, 'employee@demo');
    const { id } = await apiCreateSubmittedReport(request, B, emp, { lines: [{ category: 'x', amount: 5000.01, date: todayISO(), receipt: true }] });
    const fin = await apiLogin(request, B, 'finance@demo');
    const r = await apiDecide(request, B, fin, id, 'approve');
    expect(r.status()).toBe(403);
  });

  // --- AC3 self-approval / skip-level ---

  test('@QAIA-US-004-013 @AC3 @P1 @negative an approver cannot decide on their own report', async ({ request }) => {
    const mgr = await apiLogin(request, B, 'manager@demo');
    const { id } = await apiCreateSubmittedReport(request, B, mgr, { lines: [{ category: 'x', amount: 499.99, date: todayISO(), receipt: true }] });
    const r = await apiDecide(request, B, mgr, id, 'approve');
    expect(r.status()).toBe(403);
  });

  test('@QAIA-US-004-014 @AC3 @P1 @low-confidence a manager\'s own small report escalates to finance (open: Q2)', async ({ request }) => {
    const mgr = await apiLogin(request, B, 'manager@demo');
    const { id } = await apiCreateSubmittedReport(request, B, mgr, { lines: [{ category: 'x', amount: 100.00, date: todayISO(), receipt: true }] });
    const fin = await apiLogin(request, B, 'finance@demo');
    const r = await apiDecide(request, B, fin, id, 'approve');
    expect((await r.json()).report.status).toBe('approved');
  });

  test('@QAIA-US-004-015 @AC3 @P1 @low-confidence a manager\'s own large report drops only the manager step (open: Q2)', async ({ request }) => {
    const mgr = await apiLogin(request, B, 'manager@demo');
    const { id } = await apiCreateSubmittedReport(request, B, mgr, { lines: [{ category: 'x', amount: 5000.01, date: todayISO(), receipt: true }] });
    const fin = await apiLogin(request, B, 'finance@demo');
    const dir = await apiLogin(request, B, 'director@demo');
    const mid = await apiDecide(request, B, fin, id, 'approve');
    expect((await mid.json()).report.status).toBe('submitted');
    const r = await apiDecide(request, B, dir, id, 'approve');
    expect((await r.json()).report.status).toBe('approved');
  });

  test('@QAIA-US-004-016 @AC3 @P1 @low-confidence a finance user\'s own large report escalates finance to director (open: Q8)', async ({ request }) => {
    const fin = await apiLogin(request, B, 'finance@demo');
    const { id } = await apiCreateSubmittedReport(request, B, fin, { lines: [{ category: 'x', amount: 5000.01, date: todayISO(), receipt: true }] });
    const mgr = await apiLogin(request, B, 'manager@demo');
    const dir = await apiLogin(request, B, 'director@demo');
    const mid = await apiDecide(request, B, mgr, id, 'approve');
    expect((await mid.json()).report.status).toBe('submitted');
    const r = await apiDecide(request, B, dir, id, 'approve');
    expect((await r.json()).report.status).toBe('approved');
  });

  // --- AC4 line-item validation ---

  test('@QAIA-US-004-017 @AC4 @P3 @negative a line missing required fields is refused', async ({ request }) => {
    const t = await apiLogin(request, B, 'employee@demo');
    const id = await apiCreateDraft(request, B, t, { lines: [{ category: '', amount: 10, date: todayISO(), receipt: true }] });
    const r = await apiSubmit(request, B, t, id);
    expect(r.status()).toBe(422);
  });

  test('@QAIA-US-004-018 @AC4 @P2 @boundary @low-confidence a line dated exactly 90 days ago is accepted (assumption: Q5)', async ({ request }) => {
    const t = await apiLogin(request, B, 'employee@demo');
    const { submitResponse } = await apiCreateSubmittedReport(request, B, t, { lines: [{ category: 'supplies', amount: 10, date: daysAgoISO(90), receipt: true }] });
    expect(submitResponse.status()).toBe(200);
  });

  test('@QAIA-US-004-019 @AC4 @P2 @negative @boundary a line dated 91 days ago is blocked with a message', async ({ request }) => {
    const t = await apiLogin(request, B, 'employee@demo');
    const id = await apiCreateDraft(request, B, t, { lines: [{ category: 'supplies', amount: 10, date: daysAgoISO(91), receipt: true }] });
    const r = await apiSubmit(request, B, t, id);
    expect(r.status()).toBe(422);
    expect((await r.json()).error).toContain('90 days');
  });

  // --- AC5 receipt threshold ---

  test('@QAIA-US-004-020 @AC5 @P2 @boundary line just under €25 needs no receipt', async ({ request }) => {
    const t = await apiLogin(request, B, 'employee@demo');
    const { submitResponse } = await apiCreateSubmittedReport(request, B, t, { lines: [{ category: 'coffee', amount: 24.99, date: todayISO(), receipt: false }] });
    expect(submitResponse.status()).toBe(200);
  });

  test('@QAIA-US-004-021 @AC5 @P1 @negative line at exactly €25 without receipt is refused', async ({ request }) => {
    const t = await apiLogin(request, B, 'employee@demo');
    const id = await apiCreateDraft(request, B, t, { lines: [{ category: 'gear', amount: 25.00, date: todayISO(), receipt: false }] });
    const r = await apiSubmit(request, B, t, id);
    expect(r.status()).toBe(422);
    expect((await r.json()).error).toContain('receipt');
  });

  test('@QAIA-US-004-022 @AC5 @P3 line at €25 with a receipt is accepted', async ({ request }) => {
    const t = await apiLogin(request, B, 'employee@demo');
    const { submitResponse } = await apiCreateSubmittedReport(request, B, t, { lines: [{ category: 'gear', amount: 25.00, date: todayISO(), receipt: true }] });
    expect(submitResponse.status()).toBe(200);
  });

  test('@QAIA-US-004-023 @AC5 @AC6 @P1 @negative @low-confidence a non-EUR line crossing €25 EUR-equivalent is refused (open: Q6)', async ({ request }) => {
    const t = await apiLogin(request, B, 'employee@demo');
    const id = await apiCreateDraft(request, B, t, { currency: 'USD', lines: [{ category: 'gear', amount: 30.00, date: '2026-07-21', receipt: false }] });
    const r = await apiSubmit(request, B, t, id);
    expect(r.status()).toBe(422);
    expect((await r.json()).error).toContain('receipt');
  });

  // --- AC6 currency conversion ---

  test('@QAIA-US-004-024 @AC6 @P1 a non-EUR total drives the approval band', async ({ request }) => {
    const t = await apiLogin(request, B, 'employee@demo');
    const { id, submitResponse } = await apiCreateSubmittedReport(request, B, t, { currency: 'USD', lines: [{ category: 'hotel', amount: 543.00, date: '2026-07-21', receipt: true }] });
    expect(submitResponse.status()).toBe(200);
    const body = await submitResponse.json();
    expect(body.report.totalEur).toBeCloseTo(500.10, 2);
    const mgr = await apiLogin(request, B, 'manager@demo');
    const mid = await apiDecide(request, B, mgr, id, 'approve');
    expect((await mid.json()).report.status).toBe('submitted'); // finance still required (band B)
  });

  test('@QAIA-US-004-025 @AC6 @P1 @negative @low-confidence unresolvable currency is refused (open: Q4)', async ({ request }) => {
    const t = await apiLogin(request, B, 'employee@demo');
    const id = await apiCreateDraft(request, B, t, { currency: 'CHF', lines: [{ category: 'hotel', amount: 100, date: '2026-07-21', receipt: true }] });
    const r = await apiSubmit(request, B, t, id);
    expect(r.status()).toBe(422);
    expect((await r.json()).error).toContain('exchange rate');
  });

  test('@QAIA-US-004-026 @AC6 @P1 @low-confidence a weekend rate gap falls back to the last available rate (open: Q4)', async ({ request }) => {
    const t = await apiLogin(request, B, 'employee@demo');
    const { submitResponse } = await apiCreateSubmittedReport(request, B, t, { currency: 'USD', lines: [{ category: 'hotel', amount: 100, date: '2026-07-25', receipt: true }] });
    const body = await submitResponse.json();
    expect(body.report.rateStale).toBe(true);
    expect(body.report.totalEur).toBeCloseTo(91.90, 2);
  });

  test('@QAIA-US-004-027 @AC2 @AC3 @AC6 @P1 @low-confidence manager stale-rate report drives band and escalation together (open: Q7)', async ({ request }) => {
    const mgr = await apiLogin(request, B, 'manager@demo');
    const { id, submitResponse } = await apiCreateSubmittedReport(request, B, mgr, { currency: 'USD', lines: [{ category: 'conference', amount: 550.00, date: '2026-07-25', receipt: true }] });
    const body = await submitResponse.json();
    expect(body.report.rateStale).toBe(true);
    const fin = await apiLogin(request, B, 'finance@demo');
    const r = await apiDecide(request, B, fin, id, 'approve');
    expect((await r.json()).report.status).toBe('approved'); // manager step was dropped (self), finance was the only remaining step
  });

  // --- AC8 mandatory comments + audit trail ---

  test('@QAIA-US-004-030 @AC8 @P2 @negative rejecting without a sufficient comment is refused', async ({ request }) => {
    const emp = await apiLogin(request, B, 'employee@demo');
    const mgr = await apiLogin(request, B, 'manager@demo');
    const { id } = await apiCreateSubmittedReport(request, B, emp, { lines: [{ category: 'x', amount: 20, date: todayISO(), receipt: true }] });
    const r = await apiDecide(request, B, mgr, id, 'reject', 'too short');
    expect(r.status()).toBe(422);
  });

  test('@QAIA-US-004-031 @AC8 @P2 @negative changes-requested without a sufficient comment is refused', async ({ request }) => {
    const emp = await apiLogin(request, B, 'employee@demo');
    const mgr = await apiLogin(request, B, 'manager@demo');
    const { id } = await apiCreateSubmittedReport(request, B, emp, { lines: [{ category: 'x', amount: 20, date: todayISO(), receipt: true }] });
    const r = await apiDecide(request, B, mgr, id, 'changes-requested', 'too short');
    expect(r.status()).toBe(422);
  });

  test('@QAIA-US-004-032 @AC8 @P2 @boundary a comment of exactly 10 characters is accepted', async ({ request }) => {
    const emp = await apiLogin(request, B, 'employee@demo');
    const mgr = await apiLogin(request, B, 'manager@demo');
    const { id } = await apiCreateSubmittedReport(request, B, emp, { lines: [{ category: 'x', amount: 20, date: todayISO(), receipt: true }] });
    const comment = '1234567890'; // exactly 10 chars
    expect(comment.length).toBe(10);
    const r = await apiDecide(request, B, mgr, id, 'reject', comment);
    expect((await r.json()).report.status).toBe('rejected');
  });

  test('@QAIA-US-004-033 @AC8 @P3 approving does not require a comment', async ({ request }) => {
    const emp = await apiLogin(request, B, 'employee@demo');
    const mgr = await apiLogin(request, B, 'manager@demo');
    const { id } = await apiCreateSubmittedReport(request, B, emp, { lines: [{ category: 'x', amount: 499.99, date: todayISO(), receipt: true }] });
    const r = await apiDecide(request, B, mgr, id, 'approve', undefined);
    expect((await r.json()).report.status).toBe('approved');
  });

  test('@QAIA-US-004-034 @AC8 @P1 every transition is recorded in the audit trail with who and when', async ({ request }) => {
    const emp = await apiLogin(request, B, 'employee@demo');
    const mgr = await apiLogin(request, B, 'manager@demo');
    const { id } = await apiCreateSubmittedReport(request, B, emp, { lines: [{ category: 'x', amount: 20, date: todayISO(), receipt: true }] });
    await apiDecide(request, B, mgr, id, 'approve');
    const a = await request.get(B + '/api/audit');
    const events = (await a.json()).audit;
    const submitEvt = events.find(e => e.action === 'submit' && e.who === 'employee@demo');
    const approveEvt = events.find(e => e.action === 'approve' && e.who === 'manager@demo');
    expect(submitEvt).toBeTruthy();
    expect(approveEvt).toBeTruthy();
    expect(typeof submitEvt.at).toBe('number');
    expect(typeof approveEvt.at).toBe('number');
  });

  // --- cross-cutting authorization (3c systematic expansion) ---

  test('@QAIA-US-004-035 @AC-auth @P2 @negative creating a report without authentication is refused', async ({ request }) => {
    const r = await request.post(B + '/api/reports');
    expect(r.status()).toBe(401);
  });

  test('@QAIA-US-004-036 @AC-auth @P2 @negative deciding without authentication is refused', async ({ request }) => {
    const emp = await apiLogin(request, B, 'employee@demo');
    const { id } = await apiCreateSubmittedReport(request, B, emp, { lines: [{ category: 'x', amount: 20, date: todayISO(), receipt: true }] });
    const r = await request.post(B + '/api/reports/' + id + '/decide', { data: { decision: 'approve' } });
    expect(r.status()).toBe(401);
  });

  test('@QAIA-US-004-037 @AC-auth @P1 @negative an employee cannot edit another employee\'s draft (IDOR)', async ({ request }) => {
    const mgr = await apiLogin(request, B, 'manager@demo');
    const id = await apiCreateDraft(request, B, mgr, { lines: [{ category: 'x', amount: 20, date: todayISO(), receipt: true }] });
    const emp = await apiLogin(request, B, 'employee@demo');
    const r = await request.put(B + '/api/reports/' + id, { headers: { Authorization: 'Bearer ' + emp }, data: { currency: 'EUR', lines: [] } });
    expect(r.status()).toBe(404); // not found, not 403 -> no existence disclosure
  });

  // Read-path IDOR (#48 security-surface risk-based review, 2026-07-26): GET was never
  // ownership-checked, unlike PUT above -- any authenticated user could read any other
  // user's report by id, including an unsubmitted draft. Fixed in app/server.js to mirror
  // the same visibility rule as ?scope=inbox: owner always sees it; an approver only once
  // it is submitted and currently awaiting their role.
  test('@QAIA-US-004-039 @AC-auth @P1 @negative a manager cannot read an employee\'s unsubmitted draft (IDOR, read path)', async ({ request }) => {
    const emp = await apiLogin(request, B, 'employee@demo');
    const id = await apiCreateDraft(request, B, emp, { lines: [{ category: 'x', amount: 20, date: todayISO(), receipt: true }] });
    const mgr = await apiLogin(request, B, 'manager@demo');
    const r = await request.get(B + '/api/reports/' + id, { headers: { Authorization: 'Bearer ' + mgr } });
    expect(r.status()).toBe(404); // not found, not 403 -> no existence disclosure
  });

  test('@QAIA-US-004-040 @AC-auth @P2 the current approver CAN read a report once it is submitted and awaiting their role', async ({ request }) => {
    const emp = await apiLogin(request, B, 'employee@demo');
    const { id } = await apiCreateSubmittedReport(request, B, emp, { lines: [{ category: 'x', amount: 20, date: todayISO(), receipt: true }] });
    const mgr = await apiLogin(request, B, 'manager@demo');
    const r = await request.get(B + '/api/reports/' + id, { headers: { Authorization: 'Bearer ' + mgr } });
    expect(r.status()).toBe(200);
  });

  test('@QAIA-US-004-041 @AC-auth @P2 @negative an approver not yet in the chain cannot read a submitted report (IDOR, read path)', async ({ request }) => {
    const emp = await apiLogin(request, B, 'employee@demo');
    const { id } = await apiCreateSubmittedReport(request, B, emp, { lines: [{ category: 'x', amount: 20, date: todayISO(), receipt: true }] });
    const fin = await apiLogin(request, B, 'finance@demo');
    const r = await request.get(B + '/api/reports/' + id, { headers: { Authorization: 'Bearer ' + fin } });
    expect(r.status()).toBe(404); // band A report, only awaiting the manager -> finance is not yet in the chain
  });
});
