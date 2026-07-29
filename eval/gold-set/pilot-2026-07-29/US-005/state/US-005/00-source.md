---
stepsCompleted: [00-ingest]
lastStep: 00-ingest
lastSaved: 2026-07-29
---

# 00-source — US-005

- **Source type**: file (Markdown), read from the repository.
- **Location**: `eval/gold-set/US-005-loan-servicing.md`.
- **Sections read**: the header note, `## User story` and `## Acceptance criteria` only.
  The header note itself names a held-out raw oracle file
  (`eval/gold-set/oracle-2026-07-29/fineract-loanproduct-raw.feature`) — that file and its
  README are explicitly **not read, not fetched, not referenced** by this run (evaluation
  harness constraint, also consistent with `us-ingest`'s "fetch/read exactly that source —
  nothing else" once the designated slice is the story + AC).
- **Capture date**: 2026-07-29.
- **US-ID**: `US-005` — matches the source filename/title; a second gold-set item
  (`US-005-loyalty-points.md`) also exists under this numeric ID in the shared `eval/gold-set/`
  directory, but it is a distinct file the ingest step was not pointed at, so no ID collision
  applies to this run's own `.qaia`-equivalent output tree. `simulated: accepted-as-is`.
- **Triage gates**: not empty; is a testable requirement (a ledger/balance-computation spec
  with numbered AC, not a recipe/RFC/design doc); no abuse/illegality framing found. All gates
  pass, proceed.
- **Redaction**: scanned for national IDs/SSN, payment card numbers, health status, precise
  address, phone, email of real individuals — **none found** (the text is abstract business
  language: "a client", "staff", amounts — no real individual's data). Nothing masked.
  `type → placeholder → count` ledger: empty.
- **Sanitization**: no control characters or bidirectional-override characters found.
- **Attachments/images referenced**: none.
- **Dependencies** (sibling-story terms used but not defined here): none explicitly named.
  The source is self-contained about the loan ledger mechanics; it does not point to another
  backlog item for terms like "principal", "tranche", "NSF fee" — these are treated as
  domain vocabulary, not undefined pointers to a sibling story. Open points about *policy*
  values (fee amount, refund caps, overpayment handling) are recorded as ambiguities in
  `02-understanding.md`, not as sibling dependencies, since nothing in the text suggests they
  are defined elsewhere in the same backlog.

## Captured text (faithful, as ingested)

### User story

As a loan servicing operator, I want a loan's outstanding balance to always reflect the net
effect of every disbursement, repayment, refund, and their reversals, so that the amount a
customer still owes is always accurate and auditable.

### Acceptance criteria

1. A loan is disbursed to a client for a principal amount. A loan may be disbursed in a single
   tranche or in multiple tranches over time; the outstanding balance equals the sum of all
   tranches disbursed so far.
2. A customer repayment reduces the outstanding balance by the repayment amount. When the
   outstanding balance reaches zero, the loan is fully repaid.
3. Any repayment can be reversed by staff. Reversing a repayment restores the outstanding
   balance to exactly what it was immediately before that repayment was applied.
4. If a repayment fails after being recorded (e.g. non-sufficient funds), staff can apply an
   NSF (non-sufficient-funds) fee to the loan. The fee amount is added to the outstanding
   balance.
5. Staff can issue a refund against a loan that has already received at least one repayment.
   A refund of amount X reduces the outstanding balance by X (in addition to any repayments
   already applied). A refund can itself be reversed, restoring the balance to its value
   immediately before that refund.
6. Repayments and refunds can each be reversed independently and in any order relative to each
   other; at every point in time the outstanding balance must reflect exactly the net effect of
   all currently-active (non-reversed) disbursement/repayment/refund transactions.

## Validation

⚠ VALIDATION (source correct, right version): `simulated: accepted-as-is`.
