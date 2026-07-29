---
stepsCompleted: [05-testbook-generate]
lastStep: 05-testbook-generate
lastSaved: 2026-07-29
---

# Coverage matrix — US-005

AC → condition → scenario ID → priority → rationale → confidence. Rationale column carries
`prioritize`'s one-line risk driver from `state/US-005/04-priorities.md` (rubric dim. 9).

| AC | Condition | Scenario | Priority | Rationale | Confidence |
|---|---|---|---|---|---|
| AC1 | AC1-C1 | @QAIA-US-005-001 | P2 | Baseline disbursement, clearly stated, low defect likelihood | full |
| AC1 | AC1-C2 | @QAIA-US-005-002 | P1 | Multi-tranche summation is the AC's own headline behavior | full |
| AC1 | AC1-C3 | @QAIA-US-005-003 | P2 | No stated cap; assumption-driven uncertainty | @low-confidence |
| AC1 | AC1-C4 | @QAIA-US-005-004 | P1 | Zero-amount guard is an assumed default | @low-confidence |
| AC1 | AC1-C5 | @QAIA-US-005-005 | P1 | Negative-amount guard is an assumed default | @low-confidence |
| AC1 | AC1-C6 | @QAIA-US-005-006 | P1 | Disbursement-after-servicing interleaving unverified (Q2) | @low-confidence |
| AC2 | AC2-C1 | @QAIA-US-005-007 | P3 | Plain partial repayment, simply stated | full |
| AC2 | AC2-C2 | @QAIA-US-005-008 | P1 | Exact zero-balance boundary is the AC's core trigger | full |
| AC2 | AC2-C3 | @QAIA-US-005-009 | P2 | Adjacent boundary just under zero | full |
| AC2 | AC2-C4 | @QAIA-US-005-010 | P1 | Overpayment handling is a genuine open money-policy question (Q1) | @low-confidence |
| AC2 | AC2-C5 | @QAIA-US-005-011 | P1 | Repayment-after-fully-repaid is an assumed guard | @low-confidence |
| AC2 | AC2-C6 | @QAIA-US-005-012 | P3 | Cumulative running-total confirmation, low complexity | full |
| AC3 | AC3-C1 | @QAIA-US-005-013 | P2 | Reversal restoring balance, directly stated | full |
| AC3 | AC3-C2 | @QAIA-US-005-014 | P1 | Re-entrance from fully-repaid to active, state-machine edge | full |
| AC3 | AC3-C3 | @QAIA-US-005-015 | P2 | Double-reversal guard, moderate implementation risk | full |
| AC3 | AC3-C4 | @QAIA-US-005-016 | P2 | Reversing a non-existent repayment, moderate risk | full |
| AC3 | AC3-C5 | @QAIA-US-005-033 | P1 | Staff-only enforcement is an assumption (Q10), security-adjacent | @low-confidence |
| AC3 | AC3-C6 | @QAIA-US-005-017 | P1 | Isolation of reversals under BR-KB-001, core ledger correctness | full |
| AC4 | AC4-C1 | @QAIA-US-005-018 | P3 | Fee-addition happy path, directly stated | full |
| AC4 | AC4-C2 | @QAIA-US-005-019 | P2 | Fee-on-non-failed-repayment guard, moderate risk | full |
| AC4 | AC4-C3 | @QAIA-US-005-020 | P1 | Duplicate-fee guard is an unstated assumption | @low-confidence |
| AC4 | AC4-C4 | @QAIA-US-005-021 | P1 | Failed-repayment-amount-stays-counted is an open gap (Q5) affecting the balance | @low-confidence |
| AC4 | AC4-C5 | @QAIA-US-005-034 | P1 | Staff-only enforcement assumption (Q10), security-adjacent | @low-confidence |
| AC4 | AC4-C6 | @QAIA-US-005-022 | P1 | Fee amount itself is an open config/policy gap (Q6) | @low-confidence |
| AC5 | AC5-C1 | @QAIA-US-005-023 | P2 | Refund happy path, directly stated | full |
| AC5 | AC5-C2 | @QAIA-US-005-024 | P2 | Refund-without-repayment guard, directly implied by AC5's own wording | full |
| AC5 | AC5-C3 | @QAIA-US-005-025 | P1 | Refund-exceeds-repayments ceiling is a genuine open question (Q9) | @low-confidence |
| AC5 | AC5-C4 | @QAIA-US-005-026 | P3 | Refund reversal happy path, mirrors AC3-C1, low complexity | full |
| AC5 | AC5-C5 | @QAIA-US-005-027 | P2 | Double-reversal-of-refund guard, moderate risk | full |
| AC5 | AC5-C6 | @QAIA-US-005-028 | P1 | Refund-eligibility-after-repayment-reversed is an open interaction gap (Q8) | @low-confidence |
| AC5 | AC5-C7 | @QAIA-US-005-035 | P1 | Staff-only enforcement assumption (Q10), security-adjacent | @low-confidence |
| AC6 | AC6-C1 | @QAIA-US-005-029 | P1 | Multi-transaction reversal composition, the invariant's core claim | full |
| AC6 | AC6-C2 | @QAIA-US-005-030 | P1 | Metamorphic order-independence check, core invariant | full |
| AC6 | AC6-C3 | @QAIA-US-005-031 | P1 | Highest combinatorial complexity (several interleaved transactions) | full |
| AC6 | AC6-C4 | @QAIA-US-005-032 | P2 | Isolation of unrelated transactions during a reversal | full |
| (journey) | — | @QAIA-US-005-036 | (excluded, @smoke) | End-to-end confidence check across all six AC | full |

## Totals
- 35 atomic conditions covered by 35 atomic scenarios (1:1), plus 1 `@smoke` journey scenario.
- **AC coverage**: 6/6.
- **Required-negative coverage (ADR 0001)**: 15/15 `[req-neg]` conditions from `03-design.md`
  have a covering `@negative` scenario (AC1-C4, AC1-C5, AC2-C4, AC2-C5, AC3-C3, AC3-C4,
  AC3-C5, AC4-C2, AC4-C3, AC4-C5, AC5-C2, AC5-C3, AC5-C5, AC5-C6, AC5-C7).
- **Negative ratio (D20)**: 15 `@negative` blocks / 35 total blocks = **42.9%**.
