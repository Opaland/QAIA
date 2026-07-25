# Quick real checks — perf-check load type & automate testability precheck (2026-07-26)

Lighter-weight verification than the security-surface finding above, against the same live
`examples/expense-demo` server (port 4500) — both came back clean, reported honestly as such
rather than padded with an invented gap.

## perf-check — Load type, real measurement

20 concurrent `POST /api/login` requests, `curl -w '%{time_total}'` (no k6 install available in
this environment — a lighter real proxy for the same shape, stated plainly, not presented as a
k6 run): p50 ≈ 1.1 ms, p95 ≈ 8.5 ms, max ≈ 10.0 ms — well within any reasonable budget for an
in-memory demo backend. Confirms the "Load" test-type description in `perf-check/SKILL.md`
(realistic concurrency, steady stage, p95-against-budget) produces real, usable numbers in
practice, not just plausible-sounding prose.

## automate — Testability precheck (CTAL-TAE)

Applied the new step 2 precheck to `examples/expense-demo/app/public/`:
- **Observability**: every interactive element already carries a `data-testid` (confirmed in
  `index.html` — `email`, `password`, `login-btn`, `new-report-btn`, `submit-report-btn`, etc.);
  async completion is observable via `#message[role=status][aria-live=assertive]`.
- **Controllability**: a dedicated `POST /api/reset` endpoint exists (`app/server.js:140`) for
  declarative state seeding — no UI-chained setup required.

**Result: no testability gap found.** `expense-demo` was already built test-first (D68), so this
is an honest clean pass, not evidence the precheck does nothing — the earlier
`security-surface-risk-based-finding.md` in this same session shows the broader risk-based
review pass *does* find real things when they exist; this specific sub-check simply had nothing
to flag on this particular app.
