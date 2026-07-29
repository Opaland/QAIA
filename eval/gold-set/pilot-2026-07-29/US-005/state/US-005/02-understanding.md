---
stepsCompleted: [00-ingest, 01-review, 02-understanding]
lastStep: 02-understanding
lastSaved: 2026-07-29
---

# 02-understanding — US-005

Knowledge base: not yet consulted at this step (`rag-build` runs after this step in the
assigned journey order; nothing existed at project start — see `03-design.md` for the
knowledge state actually available to design). No `knowledge/index.md` existed when this
ambiguity hunt ran, so it proceeds on the source alone (degraded mode, shared-contract rule 8).

## Reformulation

A loan servicing operator needs the system to maintain one running number — the outstanding
balance — that is always exactly the sum of every currently-active money movement against a
loan: disbursed tranches (increase), repayments and refunds (decrease), NSF fees (increase),
minus whatever has been reversed. The main risk if this misbehaves is a **wrong balance**: a
customer told they owe more or less than they actually do, a loan marked "fully repaid" when
it isn't (or vice versa), or a reversal that corrupts unrelated transactions — all of which are
financial-integrity and audit defects, not cosmetic ones. This is a fintech/microfinance
servicing ledger; every ambiguity below is treated as **money-adjacent** by default.

## Ambiguity hunt

### Per-AC pass
- AC1: no stated cap on tranche count; no stated constraint on tranche amount sign; no stated
  constraint on disbursing a further tranche once repayments/refunds have already started.
- AC2: no stated behavior when a repayment amount exceeds the current outstanding balance
  (overpayment); no stated behavior for a repayment attempted after the loan already reached
  zero.
- AC3: no stated behavior for reversing an already-reversed repayment; no stated behavior for
  "un-reversing" (reinstating) a reversed repayment; no stated actor-restriction enforcement
  beyond naming "staff".
- AC4: no stated fee amount or how it is determined (fixed / configurable / staff-entered); no
  stated behavior for whether the original (failed) repayment's amount stays applied to the
  balance or is backed out when the fee is applied; no stated behavior for a duplicate fee
  application on the same failed repayment.
- AC5: no stated upper bound on refund amount relative to repayments actually received; no
  stated behavior when the qualifying repayment was itself later reversed (net repayments back
  to zero); no stated actor-restriction enforcement.
- AC6: this AC is itself an answer to several AC3/AC5 ordering questions — see Q4 below.

### Adversarial pass by AC type (mandatory)
- **State machine / lifecycle** (the loan's own status: has-balance / fully-repaid): can
  `fully-repaid` be re-entered after being left (e.g. a reversal on a fully repaid loan
  reopens it, then it is repaid again)? — this is a re-entrance case, not a one-way terminal
  state; captured as Q3-adjacent design condition (AC3), not `[open]` on its own since AC3's
  "restores exactly what it was before" already answers it (the balance simply moves off
  zero again — no new question needed here beyond confirming this reading).
- **Auth / permissions**: AC3, AC4 and AC5 each name "staff" as the actor for reversal / fee /
  refund. The source never explicitly forbids a non-staff actor, but naming the actor
  consistently across three ACs is a real signal, not silence — this becomes Q10
  (`[assumption]`, not `[open]`, since a concrete actor is named and "no other actor is
  authorized" is the standard safe reading of a role name in this kind of spec).
- **Thresholds / quantities**: the only true boundary values are "balance reaches zero" (AC2)
  and the sign/size of tranche and refund amounts — captured in the conditions below.

### Cross-AC interaction pass (mandatory)
- AC3 × AC6: does reversing one repayment require reversing (or being blocked by) later
  repayments/refunds still active on the same loan? → **Q4**.
- AC4 × AC6: is an NSF fee itself a reversible transaction under AC6's "repayments and
  refunds" umbrella, or a third, non-reversible kind? → **Q7**.
- AC5 × AC3: does a refund's "at least one repayment" prerequisite survive if that repayment is
  later reversed? → **Q8**.
- AC4 × AC2: when a fee is applied, does the failed repayment's amount remain counted in the
  balance, or does applying the fee imply the failed repayment's effect is backed out first?
  → **Q5**.

### Triple-AC contradiction pass
- AC2 × AC4 × AC6: a repayment is recorded (reduces balance), later marked failed, a fee is
  applied (increases balance) — does the *transaction itself* (the original repayment) stay
  "active" for AC6's net-effect accounting, or does "failing" implicitly retire it as a
  distinct kind of reversal? This is the same gap as Q5, restated at the three-AC
  intersection — no new question needed, but it raises Q5's stakes (it decides whether AC6's
  invariant is even well-defined for a failed repayment). Flagged in Q5's rationale.

## Questions (Q1–Q10)

1. **Q1** [AC2] — A repayment amount exceeds the current outstanding balance (overpayment): is
   it refused, capped at zero, or allowed to create a negative/credit balance?
   **`[open]`** — genuine money policy, no safe default a practitioner can assume without
   escalation. Proposed default for generation: **refused** (a repayment may not exceed the
   outstanding balance) — the deny-by-default reading that avoids inventing a credit-balance
   concept the source never mentions.
2. **Q2** [AC1] — Can an additional tranche be disbursed on a loan that has already had
   repayments or refunds applied (i.e. is disbursement always the very first event, or can it
   interleave with servicing activity)? **`[assumption]`** — safe default: yes, an additional
   tranche may be disbursed at any point before the loan is closed, and simply adds to the
   balance like any other active transaction (consistent with AC6's general "sum of active
   transactions" framing). Low confidence, no explicit source statement either way.
3. **Q3** [AC3] — Can a reversed repayment later be reinstated ("un-reversed")? **`[open]`** —
   no safe default; this is a genuine state-machine permissibility question with no
   safety-obvious answer either way (not a destructive action either direction).
4. **Q4** [AC3 × AC6] — Does reversing one repayment require or block reversing other
   repayments/refunds recorded before or after it on the same loan? **answered** — AC6
   states explicitly: "Repayments and refunds can each be reversed independently and **in any
   order** relative to each other." No ordering constraint exists; each reversal only restores
   its own transaction's amount.
5. **Q5** [AC4 × AC2 × AC6] — When an NSF fee is applied to a failed repayment, does the
   original (failed) repayment's amount remain counted against the balance, or is it backed
   out (reversed) as part of "failing"? **`[open]`** — money-policy, protected-domain (this
   changes the actual amount owed), source silent. Proposed default for generation: the
   failed repayment's amount **remains applied** (AC4 only says the fee is *added*, it never
   says the original amount is removed) — but this is exactly the kind of reading that must
   not be silently asserted with confidence; generated `@low-confidence`.
6. **Q6** [AC4] — What determines the NSF fee amount (a fixed constant, a per-loan/product
   configuration, or a staff-entered ad hoc amount)? **`[open]`** — money policy, config-driven,
   source and (at this stage) knowledge base both silent.
7. **Q7** [AC4 × AC6] — Can an NSF fee itself be reversed, the way a repayment or refund can?
   **`[open]`** — AC6 only names "repayments and refunds" as reversible; the fee is a third
   kind of transaction the source never states is reversible. No safe default.
8. **Q8** [AC5 × AC3] — Does the "at least one repayment" prerequisite for issuing a refund
   still hold if that repayment was later reversed (so net repayments on the loan are back to
   zero)? **`[open]`** — money policy, no safe default (both readings are defensible).
9. **Q9** [AC5] — Is there an upper bound on refund amount relative to total repayments
   actually received (net of reversals)? **`[open]`** — money policy; proposed default for
   generation: a refund may not exceed the net repayments received (deny-by-default, avoids
   inventing an uncapped-refund concept).
10. **Q10** [AC3, AC4, AC5] — All three staff-only actions (reversal, fee application, refund
    issuance) name "staff" as the actor with no other actor mentioned. Should any non-staff or
    unauthenticated attempt at these actions be refused, enforced server-side? **`[assumption]`**
    — deny-by-default is the standard safe reading for money-movement actions consistently
    attributed to a named role; low confidence since the source never states an enforcement
    rule explicitly, only names the actor.

## Validation

⚠ VALIDATION per question — recorded per shared-contract rule 3 (non-interactive run):
`simulated: accepted-as-is` for all ten (assumption defaults accepted as working assumptions;
open items stay open and still receive the stated proposed default so downstream generation is
possible per `testbook-generate`'s "generating on open items" rule; Q4 is `answered` directly
from the source, no default needed).

## Knowledge capture offer

Q4's answer states a reusable, source-grounded rule ("reversals of repayments/refunds are
independent and order-agnostic — AC6") — offered to `rag-build` as a candidate entry (accepted;
see `knowledge/business-rules.md`, `BR-KB-001`).
