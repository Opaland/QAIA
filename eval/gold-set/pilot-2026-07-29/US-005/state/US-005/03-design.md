---
stepsCompleted: [00-ingest, 01-review, 02-understanding, rag-build, 03-design]
lastStep: 03-design
lastSaved: 2026-07-29
---

# 03-design — US-005

Knowledge base: **present, one entry** (`knowledge/business-rules.md`, `BR-KB-001` —
reversal order-independence, AC6). Routed through `knowledge/index.md` first; matched on tags
`reversal`, `refund`, `repayment`, `balance`. `design.knowledgeApplied = ["BR-KB-001"]`.

## Oracle-generate check (standardized domains)

Scanned `01-extraction.md` for standardized-domain triggers (card/PAN, date/expiry, HTTP
status, email, currency code, country code, IBAN). **None found**: US-005 speaks only of
abstract monetary amounts and staff actions, no dates/deadlines, no card numbers, no currency
codes, no API contract. `oracle-generate` is a no-op for this US — recorded here rather than
silently skipped. `design.oracles = []`.

## AC → technique map

- **AC1** (disbursement, single/multi-tranche summation) → **Equivalence partitioning**
  (single-tranche vs multi-tranche classes) + **Boundary value analysis** (zero and negative
  tranche amounts — a disbursement amount is a quantity with an implicit lower bound at zero).
- **AC2** (repayment reduces balance, zero ⇒ fully repaid) → **Boundary value analysis** (the
  balance-reaches-exactly-zero boundary, and the boundary just above zero) + **Equivalence
  partitioning** (partial repayment / exact repayment / overpayment classes) + **State
  transition** (active ⇄ fully-repaid as a two-state lifecycle on the loan itself).
- **AC3** (repayment reversal) → **State transition** (reversal as an inverse transition,
  including re-entrance into "active" from "fully-repaid") + **Error guessing** (double
  reversal, reversing a non-existent repayment) — anchored on Q3's re-entrance question and
  BR-KB-001's ordering guarantee.
- **AC4** (NSF fee) → **Decision table** (repayment outcome [succeeded/failed] × fee-application
  attempt → allowed/refused) + **Boundary value analysis** (fee amount added to balance,
  qualitative since Q6 leaves the amount itself ungrounded).
- **AC5** (refund) → **Decision table** (prior-repayment-exists? × net-repayments-vs-refund-amount
  → allowed/refused) + **Boundary value analysis** (refund amount at/over the net-repayments
  ceiling) + **State transition** (refund reversal, mirroring AC3).
- **AC6** (net-effect invariant across independent reversals) → **Metamorphic testing** (the
  exact expected balance after an arbitrary sequence of reversals isn't a single fixed formula
  to hand-verify per path — but a checkable *relation* holds: reordering independent reversals
  never changes the final balance) + **Combinatorial/Domain testing** (several transactions,
  each independently active/reversed, combined coverage rather than one-at-a-time).

## Systematic coverage expansion (3c reflex, mandatory)

- **CRUD / lifecycle reflex**: the loan's balance-bearing lifecycle is create(disburse) →
  modify(repay/refund/fee) → inverse(reverse). Read is implicit (the balance is always
  queryable); there is no "delete a loan" concept in the source, so that branch of the CRUD
  reflex does not apply here — noted rather than silently skipped.
- **Authorization & server-side enforcement reflex** (Q10, `[assumption]`): three conditions
  derived — a non-staff/unauthenticated attempt at (a) reversing a repayment, (b) applying an
  NSF fee, (c) issuing or reversing a refund — each refused, enforced server-side even via a
  direct request bypassing any UI. All `[req-neg]`, `[assumption:Q10]`, `@low-confidence`.
- **Ceiling — explicitly NOT generated**: the *exact* NSF fee amount (Q6) and whether it is a
  flat constant vs. product-configured value is config-driven policy this thin US cannot
  answer and the knowledge base does not (yet) hold — flagged as a gap for the user/knowledge
  base, not invented as a literal. Likewise, no specific currency/rounding rule is asserted;
  amounts are treated as abstract numeric quantities per the source's own abstraction level.

## Derived test conditions

Numbered `ACn-Cm`; `[req-neg]` = required-negative (ADR 0001 gate); `[open:Qn]` /
`[assumption:Qn]` = inherits the cited question's status and confidence.

### AC1 — Disbursement (EP + BVA)
- AC1-C1 single tranche disbursed → outstanding balance = tranche amount (happy path)
- AC1-C2 two tranches disbursed over time → balance = sum of both (happy path, multi-tranche)
- AC1-C3 three or more tranches disbursed over time → balance = cumulative sum, confirming no
  hard tranche-count cap `[assumption]` `@low-confidence` (no stated maximum)
- AC1-C4 tranche amount = 0 → disbursement refused `[req-neg]` `[assumption]` `@low-confidence`
  (a zero-amount disbursement carries no economic meaning; safe default is refusal)
- AC1-C5 tranche amount is negative → disbursement refused `[req-neg]` `[assumption]`
  `@low-confidence`
- AC1-C6 an additional tranche is disbursed after a repayment has already reduced the balance →
  balance increases by the new tranche on top of the already-reduced balance `[assumption:Q2]`
  `@low-confidence`

### AC2 — Repayment (BVA + EP + state-transition)
- AC2-C1 partial repayment less than the outstanding balance → balance reduced by the
  repayment amount, loan remains active (happy path)
- AC2-C2 repayment amount = exactly the outstanding balance (boundary) → balance reaches
  zero, loan becomes fully repaid
- AC2-C3 repayment amount = outstanding balance minus a small unit (boundary just under) →
  balance is reduced but not zero, loan remains active
- AC2-C4 repayment amount > outstanding balance (overpayment) → refused `[req-neg]`
  `[open:Q1]` `@low-confidence`
- AC2-C5 a repayment is attempted on a loan already fully repaid (balance = 0) → refused
  `[req-neg]` `[assumption]` `@low-confidence` (mirrors AC2-C4's deny-by-default reading;
  no stated concept of a "credit" repayment)
- AC2-C6 two partial repayments applied in sequence → balance reflects the cumulative
  reduction of both (happy path, confirms running-total semantics)

### AC3 — Repayment reversal (state-transition + error-guessing)
- AC3-C1 a repayment is reversed → balance restored to exactly its value immediately before
  that repayment (happy path)
- AC3-C2 a repayment that brought the balance to exactly zero (fully repaid) is reversed →
  balance restored above zero, loan returns to active (re-entrance case, state-transition)
- AC3-C3 the same repayment is reversed a second time → refused `[req-neg]`
- AC3-C4 a reversal is attempted against a repayment that was never recorded on this loan →
  refused `[req-neg]`
- AC3-C5 a non-staff/unauthenticated actor attempts to reverse a repayment → refused
  `[req-neg]` `[assumption:Q10]` `@low-confidence`
- AC3-C6 an earlier repayment is reversed while a later, still-active repayment and refund
  remain on the loan → the balance changes by exactly the reversed repayment's amount; the
  other still-active transactions are unaffected `# rule: BR-KB-001`

### AC4 — NSF fee (decision table + BVA)
- AC4-C1 a repayment is recorded, later marked failed (NSF), and staff applies the fee → the
  fee amount is added to the outstanding balance (happy path)
- AC4-C2 staff attempts to apply an NSF fee to a repayment that has not failed (still
  successful) → refused `[req-neg]`
- AC4-C3 staff attempts to apply a second NSF fee for the same already-fee'd failed repayment
  → refused `[req-neg]` `[assumption]` `@low-confidence` (no stated allowance for duplicate
  fees on one failure)
- AC4-C4 after an NSF fee is applied, the failed repayment's own amount remains counted
  against the balance (qualitative — no fabricated literal) `[open:Q5]` `@low-confidence`
- AC4-C5 a non-staff/unauthenticated actor attempts to apply an NSF fee → refused `[req-neg]`
  `[assumption:Q10]` `@low-confidence`
- AC4-C6 the NSF fee amount itself is asserted only qualitatively ("a fee amount is added"),
  never as a fabricated precise literal, since its determination is ungrounded `[open:Q6]`
  `@low-confidence`

### AC5 — Refund (decision table + BVA + state-transition)
- AC5-C1 a refund is issued against a loan with exactly one prior repayment → balance reduced
  by the refund amount, in addition to the repayment already applied (happy path)
- AC5-C2 a refund is attempted against a loan with zero repayments → refused `[req-neg]`
- AC5-C3 a refund amount exceeds the net repayments received on the loan → refused `[req-neg]`
  `[open:Q9]` `@low-confidence`
- AC5-C4 a refund is reversed → balance restored to exactly its value immediately before that
  refund (happy path, mirrors AC3-C1)
- AC5-C5 the same refund is reversed a second time → refused `[req-neg]`
- AC5-C6 a refund is attempted against a loan whose sole qualifying repayment was later
  reversed (net repayments back to zero) → refused `[req-neg]` `[open:Q8]` `@low-confidence`
- AC5-C7 a non-staff/unauthenticated actor attempts to issue or reverse a refund → refused
  `[req-neg]` `[assumption:Q10]` `@low-confidence`

### AC6 — Net-effect invariant (metamorphic + combinatorial/domain)
- AC6-C1 a repayment and a later refund are both reversed, repayment reversed first then
  refund → final balance equals the net effect of all still-active transactions (happy path)
- AC6-C2 same two reversals in the opposite order (refund reversed first, then the repayment)
  → final balance is identical to AC6-C1's result — the **metamorphic relation**: reversal
  order does not change the final balance `# rule: BR-KB-001`
- AC6-C3 multiple repayments and refunds interleaved with a non-trivial mix of active and
  reversed transactions → outstanding balance recomputed correctly as the sum of active
  transactions only (combinatorial/domain testing across several independently-toggled
  transactions)
- AC6-C4 reversing one repayment does not alter the recorded amount of an unrelated,
  still-active refund or repayment (isolation check, error-guessing adjacent)

## Journey scenario (use-case technique, at most one per US)

One `@smoke` end-to-end scenario: a loan is disbursed in two tranches, receives two
repayments (one later reversed), an NSF fee is applied following a failed repayment, and a
refund is issued and later reversed — the final outstanding balance is checked as the single
journey-level `Then`. Excluded from atomicity/negative-ratio accounting per the technique's
constraint.

## Validation

⚠ VALIDATION (technique map + conditions): `simulated: accepted-as-is`.
