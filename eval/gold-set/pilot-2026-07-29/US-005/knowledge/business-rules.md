# Business rules — loan ledger / reversal ordering

<!-- rule-id counter: next = BR-KB-002 -->

## BR-KB-001 — Reversals are independent and order-agnostic

**Statement**: Repayments and refunds on a loan can each be reversed independently of one
another and in any order; reversing one does not require or block reversing any other, and the
final outstanding balance is exactly the net effect of whichever transactions remain active,
regardless of the order in which reversals happened.

- **Provenance**: US-005, AC6, literal restatement ("Repayments and refunds can each be
  reversed independently and in any order relative to each other..."). Captured via
  `need-understanding` (Q4, answered) → `rag-build`, 2026-07-29.
- **Decided by**: source text (AC6) — not a human arbitration, but not a guess either: quoted
  directly, so provenance is the US itself.
- **Applies to**: AC3 (repayment reversal), AC5 (refund reversal), AC6 (net-effect invariant).
  Cited in `03-design.md` and on the corresponding scenarios as `# rule: BR-KB-001`.
