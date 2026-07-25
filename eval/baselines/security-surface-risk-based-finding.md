# Real IDOR found by the risk-based security-surface pass (2026-07-26)

Applying `security-surface`'s new Step 0 (asset/threat identification, D95/#48) to
`examples/expense-demo`: the sensitive asset "other users' expense report data, including
unsubmitted drafts" ranks IDOR/cross-tenant read access as the top-priority check category.
Running that check for real against the live server surfaced a genuine, previously
undocumented vulnerability — not a hypothetical.

## The defect

`app/server.js`'s `GET /api/reports/:id` had **no ownership check at all** — any authenticated
user, any role, could read any report by id, including another user's unsubmitted draft. The
sibling `PUT /api/reports/:id` (edit) *did* check `rpt.submitterId !== a.user.id` → 404. The
existing test suite (`tests/api.expense.spec.js`) only ever covered the write-path IDOR
(`@QAIA-US-004-037`), never the read path — an asymmetry a flat, non-risk-ranked checklist pass
would have had no particular reason to notice either.

## Verification (manual, not fabricated)

Playwright/`@playwright/test` was not installed in this environment, so this was verified via
direct HTTP calls against the real running server (`node app/server.js`, port 4500) rather than
through the Playwright test runner — stated plainly, not presented as an automated suite run:

1. Employee creates a draft → owner reads it: `200` (unaffected, correct).
2. Manager reads that same **unsubmitted draft** by id: **`200` before the fix, `404` after** —
   the confirmed defect and its fix.
3. Employee adds a line and submits → manager (the correct next approver) reads it: `200`
   (legitimate approval-chain access preserved, no over-correction).
4. Finance (not yet in the chain for a band-A report) reads the same submitted report: `404`
   (correctly excluded — not just "submitted" but "awaiting *this* role").

## Fix

`app/server.js`, `GET /api/reports/:id`: now allows the submitter always, or an approver only
when `status === 'submitted'` and `nextApproverRole(rpt) === a.user.role` — the exact same
visibility rule already used by `GET /api/reports?scope=inbox`, just applied to the single-report
read path too.

## Regression coverage added

Three new cases in `tests/api.expense.spec.js` (`@QAIA-US-004-039/040/041`) — new IDs, per the
"NNN never reused" stable-ID rule, not overwriting the existing `037` write-path case — covering
exactly the three behaviors verified above (draft blocked, current approver allowed, non-chain
approver blocked). Not yet run through the Playwright runner in this environment (no local
install available) — the manual HTTP verification above exercises the identical requests these
tests issue via the shared `helpers.js` functions (`apiLogin`/`apiCreateDraft`/
`apiCreateSubmittedReport`, read directly to confirm the equivalence), but this is a **substitute
observation, not a substitute for actually running the suite** — flagged honestly as a follow-up
if `@playwright/test` is installed in a future session.
