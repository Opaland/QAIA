---
stepsCompleted: [05-testbook-generate]
lastStep: 05-testbook-generate
lastSaved: 2026-07-28
---

# Synthesis — US-004 (Expense report approval workflow)

Date: 2026-07-28. Mode: non-interactive benchmark run (all `⚠ VALIDATION` points
`simulated: accepted-as-is`).

## Counts
- **Scenarios**: 51 total (50 atomic + 1 `@smoke` journey, excluded from the counts below).
- **By priority** (of the 50 non-smoke): P1 = 24, P2 = 23, P3 = 3.
- **Negative-path coverage**: 20 `@negative` scenarios / 50 total blocks = **40%** raw ratio
  (D20 single definition). Required-negative gate (ADR 0001): **20/20** `[req-neg]` conditions
  from `state/US-004/03-design.md` have a covering `@negative` scenario — gate **passes**.
- **AC coverage**: **8/8** acceptance criteria have at least one covering scenario.
- **Open questions**: 10 total (see full list below) — 1 answered, 3 assumption, 6 open.
- **`@low-confidence` scenarios**: 14 — @QAIA-US-004-008, 009, 013, 015, 018, 022, 023, 031,
  036, 038, 040, 042, 049, 050 (verified by tag count in the `.feature` files).
- **Knowledge base applied**: none (`design.knowledgeApplied = []`) — base absent for this
  project, degraded mode recorded, nothing invented (see `03-design.md`).

## Ratio explainer
The 40% negative ratio sits right at the D20 target, not below it — no shortfall to flag. If
read AC-by-AC: refusal/error paths concentrate in AC1 (forbidden transitions), AC3 (self-approval
denial), AC4 (missing-field/90-day blocks), AC5 (missing-receipt refusal), AC7 (terminal-state
enforcement), AC8 (comment-length enforcement) and the two authorization reflex conditions.
AC2 and most of AC6 are threshold/conversion **routing** logic with no refusal path of their own
(a report is never "refused" for being under or over a tier) — their scenarios are legitimately
non-negative, and that is why AC2's block is entirely happy-path/boundary while still being
fully covered.

## Out-of-slice dependencies
None recorded. `00-source.md`'s `dependencies:` list is empty for this ingested slice — no
sibling-backlog story was referenced by the source. (Undefined operational details — role
identity, currency rate source — are captured as open/assumption questions in
`02-understanding.md`, not as sibling-story dependencies, since nothing in the source pointed
to another ticket defining them.)

## Full numbered question list (from `state/US-004/02-understanding.md`)
1. **Q1** [AC2, AC6] — Threshold boundary inclusivity at exactly €500.00 and €5000.00.
   **`[open]`**. Proposed default: middle band inclusive at both ends.
2. **Q2** [AC3] — Does "skip to next level up" for a manager-submitter skip only the manager
   step, leaving finance/director intact? **`[open]`**. Proposed default: yes, only the manager
   step is skipped.
3. **Q3** [AC1×AC2×AC3] — A manager submits their own report under €500 (single-approval tier):
   does the report end up with zero human approvals? **`[open]`**. No confident default
   proposable; flagged as the highest-impact gap of the pass (compliance-relevant).
4. **Q4** [AC1×AC7] — Can a re-submitted (post changes-requested) report subsequently be
   rejected? **answered** — AC1's general transition rule applies on every entry into
   `submitted`; AC7 restricts only what happens after rejection.
5. **Q5** [AC1×AC2] — How is partial multi-level approval progress tracked inside the single
   `submitted` state, and can a non-pending-level approver still act? **`[open]`**. No safe
   default. Proposed working default for generation: only the pending level may act.
6. **Q6** [AC4] — Reference clock for "within the last 90 days." **`[assumption]`**: server-side
   UTC calendar date at submission time.
7. **Q7** [AC5×AC6] — Does the €25 receipt threshold apply pre- or post-conversion?
   **`[open]`**. Proposed default: original line-currency amount.
8. **Q8** [AC6] — Rate source, and fallback when no rate exists for a weekend/holiday expense
   date. **`[open]`**. Proposed default: ECB daily reference rate, prior-business-day fallback.
9. **Q9** [AC1] — Is `approved` terminal like `rejected`? **`[assumption]`**: yes, terminal.
10. **Q10** [AC3] — Does the self-approval-skip rule generalize beyond the manager example?
    **`[assumption]`**: yes, it generalizes to any level where submitter = pending approver's
    role.

**ACs that produced at least one `[open]` question**: AC1 (Q3, Q5), AC2 (Q1, Q3), AC3 (Q2, Q3),
AC5 (Q7), AC6 (Q1, Q7, Q8). AC4 carries only an `[assumption]` (Q6), AC7 carries only an
`answered` interaction (Q4), AC8 raised no question in this pass.

## Review order
`@low-confidence` first, then P1 → P3.

**`@low-confidence` (14)**: @QAIA-US-004-008 (Q9), 009 (Q5), 013 (EXP-1), 015 (Q1), 018 (Q1),
022 (Q3), 023 (Q2), 031 (future-date assumption), 036 (Q7), 038 (Q8, qualitative), 040 (Q8),
042 (unsupported-currency assumption), 049 (EXP-2), 050 (EXP-3).

**Then P1 (24)**, **P2 (23)**, **P3 (3)** as tagged in the `.feature` files and
`coverage-matrix.md`.

## By-technique table

Counts below are the exact `@<technique>` tag counts in the `.feature` files (one technique tag
per scenario, per the generation rules), not estimates.

| Technique | ACs | Scenarios | Justification |
|---|---|---|---|
| State transition | AC1, AC7 | 12 | Explicit lifecycle with forbidden/terminal transitions |
| Boundary value analysis | AC2, AC4, AC5, AC8 | 17 | Amount tiers, 90-day window, €25 receipt line, 10-char comment |
| Decision table | AC2, AC3 | 3 | Role × amount-tier combinations |
| Domain analysis | AC3 | 2 | Submitter role × amount tier, combined coverage (not isolated BVA) |
| Equivalence partitioning | AC4, AC5, AC6, AC8 | 10 | Field-presence classes, currency classes, comment-requirement classes |
| Metamorphic testing | AC6 | 1 | Converted total's exact value is unsourced (rate); relation checked instead |
| Error guessing | AC6, AC3 (auth reflex) | 4 | Anchored on the rate-source gap and the unnamed role/auth model |
| CRUD | AC1 (EXP-1) | 1 | Draft-delete lifecycle reflex |
| Use case (journey) | AC1,2,3,6,8 | 1 (`@smoke`, excluded) | Single end-to-end confidence check |

Sum of non-smoke rows = 12+17+3+2+10+1+4+1 = 50, matching the total scenario count exactly.

## Priority rationale
See `state/US-004/04-priorities.md` for the per-condition risk driver (one line each) and the
full rubric. **Deviation flagged there**: this run's assigned skill sequence does not include
`prioritize`, so this is a lightweight, directly-reasoned assignment rather than a full
`prioritize` skill run — every entry is still `simulated: accepted-as-is` pending human
arbitration, same as every other validation point in this run.

## Arbitration list (pending human review — all `simulated: accepted-as-is`)
- 10 questions from `02-understanding.md` (6 open, 3 assumption, 1 answered — see above).
- The technique map and derived conditions in `03-design.md`.
- The lightweight priority assignment in `04-priorities.md` (plus the deviation itself).
- The generation scope decision (full P1+P2+P3 book generated, not the P1+P2 default).
- This synthesis and the coverage matrix.

## Changelog
Initial generation — no prior book existed in this output directory.
