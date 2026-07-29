---
stepsCompleted: [00-ingest, 01-review]
lastStep: 01-review
lastSaved: 2026-07-29
---

# 01-extraction — US-005

## Story
- **As a** loan servicing operator,
- **I want** a loan's outstanding balance to always reflect the net effect of every
  disbursement, repayment, refund, and their reversals,
- **so that** the amount a customer still owes is always accurate and auditable.

## Acceptance criteria (numbered, stable — never renumbered downstream)

- **AC1** — Disbursement. A loan is disbursed to a client for a principal amount, in a single
  tranche or in multiple tranches over time. Outstanding balance = sum of all tranches
  disbursed so far.
- **AC2** — Repayment. A customer repayment reduces the outstanding balance by the repayment
  amount. Balance reaching zero ⇒ loan fully repaid.
- **AC3** — Repayment reversal. Staff can reverse any repayment; the balance is restored to
  exactly what it was immediately before that repayment.
- **AC4** — NSF fee. If a recorded repayment later fails (e.g. NSF), staff can apply an NSF
  fee; the fee amount is added to the outstanding balance.
- **AC5** — Refund. Staff can issue a refund against a loan that has received at least one
  repayment; a refund of amount X reduces the balance by X, in addition to repayments already
  applied. A refund can itself be reversed, restoring the balance to its pre-refund value.
- **AC6** — Net-effect invariant. Repayments and refunds can each be reversed independently
  and in any order relative to each other; the outstanding balance must, at every point in
  time, equal exactly the net effect of all currently-active (non-reversed) transactions.

## Business rules / constraints found outside the numbered AC list

None found outside the six AC. AC6 functions as a cross-cutting invariant rather than a new
piece of behavior — it constrains how AC3/AC5's reversal mechanics must compose, and is
treated as such in `need-understanding` and `istqb-design` (an invariant to test across
combinations, not an isolated condition).

## Referenced artifacts not analyzed

None — no attachments, mockups, or links in the ingested slice.

## Present in source but not classifiable

None. Every sentence of the ingested slice maps cleanly onto one of the six AC above; nothing
was dropped or left unclassified.

## Validation

⚠ VALIDATION (extraction confirmed, no missing AC, no misread rule): `simulated: accepted-as-is`.
