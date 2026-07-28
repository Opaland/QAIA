# US-005 — Loan repayment and refund servicing

> Gold set item, sourced from a real product (Apache Fineract, `apache/fineract`, ASF 2.0,
> `fineract-e2e-tests-runner/src/test/resources/features/LoanProduct.feature`, scenarios
> "Scenario1"-"Scenario10" / TestRail C52-C62 only — the file's later scenarios (charge-off
> reason enumeration, buy-down fee flags, multi-tranche product config) are Fineract-specific
> configuration surface, not general business rules, and are deliberately excluded from this
> ticket's scope). Domain: fintech/microfinance loan servicing, non-medical. The AC below are a
> faithful business-language derivation from reading the real scenarios, not a copy of their
> Gherkin steps or test data. Original raw oracle kept at
> `eval/gold-set/oracle-2026-07-29/fineract-loanproduct-raw.feature` for post-hoc comparison —
> NOT given to any generation skill.

## User story

**As a** loan servicing operator,
**I want** a loan's outstanding balance to always reflect the net effect of every disbursement,
repayment, refund, and their reversals,
**so that** the amount a customer still owes is always accurate and auditable.

## Acceptance criteria

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
