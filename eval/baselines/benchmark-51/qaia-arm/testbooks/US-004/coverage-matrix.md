---
stepsCompleted: [05-testbook-generate]
lastStep: 05-testbook-generate
lastSaved: 2026-07-28
---

# Coverage matrix — US-004

AC → condition → scenario ID → priority → rationale → confidence. Priorities and rationale
column sourced from `state/US-004/04-priorities.md` (lightweight assignment — see deviation
note there).

| AC | Condition | Scenario ID | Priority | Rationale | Confidence |
|---|---|---|---|---|---|
| AC1 | AC1-C1 | @QAIA-US-004-001 | P1 | Core lifecycle entry | full |
| AC1 | AC1-C2 | @QAIA-US-004-002 | P1 | Core lifecycle — approval reached | full |
| AC1 | AC1-C3 | @QAIA-US-004-003 | P1 | Core lifecycle — rejection reached | full |
| AC1 | AC1-C4 | @QAIA-US-004-004 | P2 | Secondary branch | full |
| AC1 | AC1-C5 | @QAIA-US-004-005 | P1 | Loop re-entry, feeds re-submission | full |
| AC1 | AC1-C6 | @QAIA-US-004-006 | P1 | Loop re-entry, feeds re-submission | full |
| AC1 | AC1-C7 | @QAIA-US-004-007 | P2 | Forbidden-transition guard | full |
| AC1 | AC1-C8 | @QAIA-US-004-008 | P2 | Forbidden-transition guard | low (`[assumption:Q9]`) |
| AC1 | AC1-C9 | @QAIA-US-004-009 | P3 | State-model gap | low (`[open:Q5]`) |
| AC7 | AC7-C1 | @QAIA-US-004-010 | P1 | Terminal-state integrity | full |
| AC7 | AC7-C2 | @QAIA-US-004-011 | P1 | Terminal-state integrity | full |
| AC7 | AC7-C3 | @QAIA-US-004-012 | P2 | Downstream consequence | full |
| AC1 | EXP-1 | @QAIA-US-004-013 | P3 | CRUD reflex, not source-stated | low (`[assumption]`) |
| AC2 | AC2-C1 | @QAIA-US-004-014 | P1 | Threshold routing, core | full |
| AC2 | AC2-C2 | @QAIA-US-004-015 | P2 | Boundary at €500 | low (`[open:Q1]`) |
| AC2 | AC2-C3 | @QAIA-US-004-016 | P2 | Non-boundary BVA | full |
| AC2 | AC2-C4 | @QAIA-US-004-017 | P2 | Non-boundary BVA | full |
| AC2 | AC2-C5 | @QAIA-US-004-018 | P2 | Boundary at €5000 | low (`[open:Q1]`) |
| AC2 | AC2-C6 | @QAIA-US-004-019 | P1 | Threshold routing, top tier | full |
| AC2 | AC2-C7 | @QAIA-US-004-020 | P2 | Baseline confirmation for AC3 | full |
| AC3 | AC3-C1 | @QAIA-US-004-021 | P1 | Self-approval denial (financial control) | full |
| AC3 | AC3-C2 | @QAIA-US-004-022 | P2 | Narrow single-tier manager case | low (`[open:Q3]`) |
| AC3 | AC3-C3 | @QAIA-US-004-023 | P2 | Manager-submitter above €5000 | low (`[open:Q2]`) |
| AC3 | AC3-C4 | @QAIA-US-004-024 | P1 | Financial-control enforcement | full |
| AC4 | AC4-C1 | @QAIA-US-004-025 | P1 | Mandatory-field refusal | full |
| AC4 | AC4-C2 | @QAIA-US-004-026 | P1 | Mandatory-field refusal | full |
| AC4 | AC4-C3 | @QAIA-US-004-027 | P1 | Mandatory-field refusal | full |
| AC4 | AC4-C4 | @QAIA-US-004-028 | P2 | Boundary happy path | full (`[assumption:Q6]` clock) |
| AC4 | AC4-C5 | @QAIA-US-004-029 | P1 | 90-day refusal, core | full (`[assumption:Q6]` clock) |
| AC4 | AC4-C6 | @QAIA-US-004-030 | P2 | Happy path, non-boundary | full |
| AC4 | AC4-C7 | @QAIA-US-004-031 | P2 | Future-date handling | low (`[assumption]`) |
| AC5 | AC5-C1 | @QAIA-US-004-032 | P2 | Non-boundary happy path | full |
| AC5 | AC5-C2 | @QAIA-US-004-033 | P1 | Receipt-threshold boundary, core | full |
| AC5 | AC5-C3 | @QAIA-US-004-034 | P1 | Receipt-mandatory refusal, core | full |
| AC5 | AC5-C4 | @QAIA-US-004-035 | P2 | Happy path confirmation | full |
| AC5 | AC5-C5 | @QAIA-US-004-036 | P2 | Currency-timing interaction | low (`[open:Q7]`) |
| AC6 | AC6-C1 | @QAIA-US-004-037 | P1 | Baseline (no conversion) | full |
| AC6 | AC6-C2 | @QAIA-US-004-038 | P1 | Conversion core | low (`[open:Q8]`, qualitative assertion only) |
| AC6 | AC6-C3 | @QAIA-US-004-039 | P2 | Downstream threshold consequence | full |
| AC6 | AC6-C4 | @QAIA-US-004-040 | P3 | Weekend/holiday rate fallback | low (`[open:Q8]`) |
| AC6 | AC6-C5 | @QAIA-US-004-041 | P2 | Metamorphic relation check | full |
| AC6 | AC6-C6 | @QAIA-US-004-042 | P2 | Unsupported currency, error-guessing | low (`[assumption]`) |
| AC8 | AC8-C1 | @QAIA-US-004-043 | P1 | Audit-trail core | full |
| AC8 | AC8-C2 | @QAIA-US-004-044 | P1 | Comment-length enforcement, core | full |
| AC8 | AC8-C3 | @QAIA-US-004-045 | P2 | Boundary confirmation | full |
| AC8 | AC8-C4 | @QAIA-US-004-046 | P1 | Comment-length enforcement, core | full |
| AC8 | AC8-C5 | @QAIA-US-004-047 | P2 | Boundary confirmation | full |
| AC8 | AC8-C6 | @QAIA-US-004-048 | P2 | Negative-space confirmation | full |
| AC3 | EXP-2 | @QAIA-US-004-049 | P1 | Authorization/IDOR, high risk | low (`[assumption]`) |
| AC3 | EXP-3 | @QAIA-US-004-050 | P1 | Authorization/unauthenticated, high risk | low (`[assumption]`) |
| AC1,AC2,AC3,AC6,AC8 | journey (use-case) | @QAIA-US-004-051 | — (`@smoke`, excluded) | End-to-end confidence check | full |

## AC coverage summary
- AC1: 10/10 conditions covered (9 design + EXP-1) — 10 scenarios
- AC2: 7/7 — 7 scenarios
- AC3: 6/6 (4 design + EXP-2/EXP-3) — 6 scenarios
- AC4: 7/7 — 7 scenarios
- AC5: 5/5 — 5 scenarios
- AC6: 6/6 — 6 scenarios
- AC7: 3/3 — 3 scenarios
- AC8: 6/6 — 6 scenarios
- **AC coverage: 8/8 acceptance criteria have at least one covering scenario.**
- Plus 1 `@smoke` journey scenario (excluded from the counts above).
