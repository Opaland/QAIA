---
stepsCompleted: [00-ingest, 01-review, 02-understanding, rag-build, 03-design, 04-priorities]
lastStep: 04-priorities
lastSaved: 2026-07-29
---

# 04-priorities — US-005

Regulated-context default applied (`prioritize` guardrail): this is a fintech/microfinance
loan-servicing ledger, so conditions whose failure means an incorrect amount owed or a bypassed
staff-only control are scored **impact 3** by default; routine mechanics and edge confirmations
with no direct money-correctness stake are scored lower. Every score below is a proposal —
recorded as `simulated: accepted-as-is` in this non-interactive run (no git-history signal
applied: no target repo path was named for this session, so that optional input is silently
skipped per the skill's own rule).

Priority = impact × probability → **P1 (≥6) / P2 (3-4) / P3 (≤2)**.

| Condition | Impact | Probability | Priority | Rationale |
|---|---|---|---|---|
| AC1-C1 | 3 | 1 | P2 | Baseline disbursement sets the balance; clearly stated, low defect likelihood |
| AC1-C2 | 3 | 2 | P1 | Multi-tranche summation is the AC's own headline behavior |
| AC1-C3 | 1 | 3 | P2 | No stated cap; low real-world stake but assumption-driven uncertainty |
| AC1-C4 | 2 | 3 | P1 | Zero-amount guard is an assumed default, not source-stated |
| AC1-C5 | 2 | 3 | P1 | Negative-amount guard is an assumed default, not source-stated |
| AC1-C6 | 2 | 3 | P1 | Disbursement-after-servicing interleaving is an unverified assumption (Q2) |
| AC2-C1 | 2 | 1 | P3 | Plain partial repayment, directly and simply stated |
| AC2-C2 | 3 | 2 | P1 | The exact zero-balance boundary is the AC's core "fully repaid" trigger |
| AC2-C3 | 2 | 2 | P2 | Adjacent boundary just under zero, moderate boundary risk |
| AC2-C4 | 3 | 3 | P1 | Overpayment handling is a genuine open money-policy question (Q1) |
| AC2-C5 | 2 | 3 | P1 | Repayment-after-fully-repaid is an assumed guard, not source-stated |
| AC2-C6 | 1 | 1 | P3 | Cumulative running-total confirmation, low complexity |
| AC3-C1 | 3 | 1 | P2 | Reversal restoring balance is directly stated and simple to verify |
| AC3-C2 | 3 | 2 | P1 | Re-entrance from fully-repaid back to active is a state-machine edge case |
| AC3-C3 | 2 | 2 | P2 | Double-reversal guard, moderate implementation risk |
| AC3-C4 | 2 | 2 | P2 | Reversing a non-existent repayment, moderate implementation risk |
| AC3-C5 | 3 | 3 | P1 | Staff-only enforcement is an assumption (Q10); security-adjacent |
| AC3-C6 | 3 | 2 | P1 | Isolation of reversals under BR-KB-001 is core ledger correctness |
| AC4-C1 | 2 | 1 | P3 | Fee-addition happy path, directly stated and simple |
| AC4-C2 | 2 | 2 | P2 | Fee-on-non-failed-repayment guard, moderate risk |
| AC4-C3 | 2 | 3 | P1 | Duplicate-fee guard is an unstated assumption |
| AC4-C4 | 3 | 3 | P1 | Whether the failed repayment's amount stays counted is a genuine open gap (Q5) affecting the actual balance |
| AC4-C5 | 3 | 3 | P1 | Staff-only enforcement assumption (Q10); security-adjacent |
| AC4-C6 | 2 | 3 | P1 | Fee amount itself is an open config/policy gap (Q6) |
| AC5-C1 | 3 | 1 | P2 | Refund happy path directly stated |
| AC5-C2 | 2 | 2 | P2 | Refund-without-repayment guard, directly implied by the AC's own prerequisite wording |
| AC5-C3 | 3 | 3 | P1 | Refund-exceeds-repayments ceiling is a genuine open money-policy question (Q9) |
| AC5-C4 | 2 | 1 | P3 | Refund reversal happy path, mirrors AC3-C1, low complexity |
| AC5-C5 | 2 | 2 | P2 | Double-reversal-of-refund guard, moderate risk |
| AC5-C6 | 3 | 3 | P1 | Refund-eligibility-after-repayment-reversed is a genuine open interaction gap (Q8) |
| AC5-C7 | 3 | 3 | P1 | Staff-only enforcement assumption (Q10); security-adjacent |
| AC6-C1 | 3 | 2 | P1 | Multi-transaction reversal composition is the invariant's core claim |
| AC6-C2 | 3 | 2 | P1 | Metamorphic order-independence check, core invariant |
| AC6-C3 | 3 | 3 | P1 | Highest combinatorial complexity (several interleaved active/reversed transactions) |
| AC6-C4 | 2 | 2 | P2 | Isolation of unrelated transactions during a reversal, moderate risk |

## Totals
20 × P1, 11 × P2, 4 × P3 (35 conditions total, matching `03-design.md`).

## Validation

⚠ VALIDATION (scores approved, no user override in this non-interactive run):
`simulated: accepted-as-is`. Next step: `testbook-generate`, covering P1+P2 fully by default,
P3 the user's call (quota trade-off) — this run generates the **full** P1+P2+P3 book so the
pilot's coverage is complete for later comparison against the held-out oracle, a deliberate
scope broadening recorded here and in `journey.md`.
