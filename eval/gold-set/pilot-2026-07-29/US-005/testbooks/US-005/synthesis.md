---
stepsCompleted: [05-testbook-generate]
lastStep: 05-testbook-generate
lastSaved: 2026-07-29
---

# Synthesis — US-005 (Loan repayment and refund servicing)

Date: 2026-07-29. Mode: non-interactive pilot run (all `⚠ VALIDATION` points
`simulated: accepted-as-is`).

## Counts
- **Scenarios**: 36 total (35 atomic + 1 `@smoke` journey, excluded from the counts below).
- **By priority** (of the 35 non-smoke): P1 = 20, P2 = 11, P3 = 4.
- **Negative-path coverage**: 15 `@negative` scenarios / 35 total blocks = **42.9%** raw ratio
  (D20 single definition). Required-negative gate (ADR 0001): **15/15** `[req-neg]` conditions
  from `state/US-005/03-design.md` have a covering `@negative` scenario — gate **passes**.
- **AC coverage**: **6/6** acceptance criteria have at least one covering scenario.
- **Open questions**: 10 total (see full list below) — 1 answered, 2 assumption, 7 open.
- **`@low-confidence` scenarios**: 14 — @QAIA-US-005-003, 004, 005, 006, 010, 011, 020, 021,
  022, 025, 028, 033, 034, 035 (verified by tag count in the `.feature` files).
- **Knowledge base applied**: `BR-KB-001` (reversal order-independence, AC6) — cited on
  scenarios 017, 029, 030, 032. One entry only; this is a freshly-initialized project
  knowledge base for the pilot, not a rich pre-existing one — an empty-or-thin
  `knowledgeApplied` here reflects the base's youth, not a simple domain (see `03-design.md`).

## Ratio explainer
The 42.9% negative ratio sits comfortably above the D20 40% signal — no shortfall to flag.
Read AC-by-AC: refusal/error paths concentrate in AC1 (invalid tranche amounts), AC2
(overpayment, repayment on a closed loan), AC3 (double/nonexistent reversal, unauthorized
actor), AC4 (fee misapplication, unauthorized actor), and AC5 (refund eligibility and
ceiling checks, double reversal, unauthorized actor). AC6 carries no refusal path of its
own — it is a computed-invariant check (the balance always equals the net of active
transactions), so its four scenarios are legitimately non-negative, and that is why AC6's
block is entirely happy-path/metamorphic while still being fully covered.

## Out-of-slice dependencies
None recorded. `00-source.md`'s `dependencies:` list is empty — the ingested slice is
self-contained; no sibling-backlog story was referenced by the source text.

## Full numbered question list (from `state/US-005/02-understanding.md`)
1. **Q1** [AC2] — Overpayment: repayment amount exceeds the outstanding balance. **`[open]`**.
   Proposed default: refused (deny-by-default, no credit-balance concept invented).
2. **Q2** [AC1] — Can a tranche be disbursed after servicing activity (repayments/refunds)
   has already started? **`[assumption]`**: yes, it adds to the current balance like any
   other active transaction.
3. **Q3** [AC3] — Can a reversed repayment later be reinstated ("un-reversed")? **`[open]`**.
   No safe default either way; not generated as a scenario (no proposed default to generate
   from — the negative "un-reversal is refused" reading is itself the open question, not an
   assumption).
4. **Q4** [AC3×AC6] — Does reversing one repayment require or block reversing other
   repayments/refunds? **answered** — AC6 states reversals are independent and order-agnostic
   (promoted to `BR-KB-001`).
5. **Q5** [AC4×AC2×AC6] — Does a failed repayment's own balance reduction stay counted once an
   NSF fee is applied, or is it backed out? **`[open]`**. Proposed default: stays counted (the
   AC only says the fee is *added*, not that the failure itself reverses anything).
6. **Q6** [AC4] — What determines the NSF fee amount (fixed / configured / staff-entered)?
   **`[open]`**. No literal fee amount asserted anywhere in the book (scenario 022 is
   deliberately qualitative).
7. **Q7** [AC4×AC6] — Can an NSF fee itself be reversed? **`[open]`**. Not generated as a
   scenario either way — no safe default to propose, and inventing "fee reversal exists/does
   not exist" would be a guess in either direction.
8. **Q8** [AC5×AC3] — Does the refund prerequisite ("at least one repayment") survive if that
   repayment was later reversed? **`[open]`**. Proposed default: no, refund refused.
9. **Q9** [AC5] — Is there an upper bound on refund amount relative to net repayments
   received? **`[open]`**. Proposed default: refund may not exceed net repayments received.
10. **Q10** [AC3, AC4, AC5] — Are non-staff/unauthenticated actors blocked from reversal, fee
    application, and refund issuance? **`[assumption]`**: yes, deny-by-default, enforced
    server-side.

**ACs that produced at least one `[open]` question**: AC2 (Q1), AC3 (Q3, Q7 via AC4 overlap),
AC4 (Q5, Q6, Q7), AC5 (Q8, Q9). AC1 carries only an `[assumption]` (Q2). AC6 carries only the
`answered` interaction (Q4).

**Not generated as scenarios** (genuinely no safe default either direction, per the
"generating on open items" rule's own limit — a scenario still needs *a* proposed behavior to
render; Q3 and Q7 have none defensible): Q3 (repayment un-reversal permissibility) and Q7 (fee
reversibility) are recorded here and in `openArbitrations`, not silently dropped, but do not
appear as `.feature` scenarios — flagged for human arbitration before either could be
generated without guessing.

## Review order
`@low-confidence` first, then P1 → P3.

**`@low-confidence` (14)**: @QAIA-US-005-003 (tranche-count assumption), 004 (zero-amount
assumption), 005 (negative-amount assumption), 006 (Q2), 010 (Q1), 011 (fully-repaid-guard
assumption), 020 (duplicate-fee assumption), 021 (Q5), 022 (Q6, qualitative), 025 (Q9), 028
(Q8), 033/034/035 (Q10, staff-only enforcement).

**Then P1 (20)**, **P2 (11)**, **P3 (4)** as tagged in the `.feature` files and
`coverage-matrix.md`.

## By-technique table

Counts below are the exact `@<technique>` tag counts in the `.feature` files (one technique
tag per scenario, per the generation rules), not estimates.

| Technique | ACs | Scenarios | Justification |
|---|---|---|---|
| Error guessing | AC1 (C6), AC3, AC4, AC5 (incl. the 3-scenario auth reflex) | 9 | Double/nonexistent reversal, duplicate fee, unauthorized actor, unverified interleaving |
| Decision table | AC4, AC5 | 6 | Fee-applicability and refund-eligibility cells |
| Boundary value analysis | AC1, AC2, AC5 | 6 | Zero/negative tranche, exact-zero balance boundary, refund ceiling |
| Equivalence partitioning | AC1, AC2 | 5 | Tranche-count/repayment-count classes, cumulative running totals |
| State transition | AC2, AC3, AC5 | 5 | Fully-repaid terminal/re-entrant state, refund reversal mirror |
| Domain analysis | AC6 | 2 | Multiple independently-toggled transactions, combined coverage |
| Metamorphic testing | AC6 | 1 | Reversal-order independence — a relation, not a fabricated literal |
| Combinatorial testing (pairwise) | AC6 | 1 | Several interleaved active/reversed transactions |
| Use case (journey) | AC1–AC6 | 1 (`@smoke`, excluded) | Single end-to-end confidence check |

Sum of non-smoke rows = 9+6+6+5+5+2+1+1 = 35, matching the total non-smoke scenario count
exactly.

## Priority rationale
See `state/US-005/04-priorities.md` for the per-condition risk driver (one line each) and the
full impact×probability rubric. Regulated-context default applied throughout (fintech loan
ledger): money-affecting conditions default to impact 3.

## Arbitration list (pending human review — all `simulated: accepted-as-is`)
- 10 questions from `02-understanding.md` (7 open, 2 assumption, 1 answered — see above).
- Two open questions (Q3, Q7) with no scenario generated because no safe default exists.
- The technique map and derived conditions in `03-design.md`.
- The full priority table in `04-priorities.md`.
- The generation scope decision (full P1+P2+P3 book generated, broadened from the P1+P2
  default, so the pilot's coverage is complete for later comparison).
- This synthesis and the coverage matrix.

## Changelog
Initial generation — no prior book existed in this output directory.
