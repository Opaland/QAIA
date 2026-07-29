---
stepsCompleted: [00-ingest, 01-review, 02-understanding, 03-design, 04-priorities, 05-generate]
lastStep: 05-generate
lastSaved: 2026-07-29
---

# Coverage matrix — US-006

AC -> condition -> scenario ID -> priority -> rationale (copied verbatim from
`state/US-006/04-priorities.md`, per the deliverable rule, rubric dim. 9) -> confidence.

| AC | Condition(s) | Scenario ID | Priority | Rationale | Confidence |
|---|---|---|---|---|---|
| AC1 | (compositional — role/config partitions, no dedicated condition) | — | — | Every scenario below that varies role or the private flag exercises AC1's own partitions; no standalone action to assert. | normal |
| AC2 | AC2-C1 | *waived* | P3 | Baseline positive, single simple rule, no crossing logic — out of default P1+P2 scope. | normal |
| AC2 | AC2-C2 | 001 | P1 | Unauthorized disclosure of a non-public report to an anonymous viewer. | normal |
| AC2 | AC2-C3 | 002 | P1 | Unauthorized disclosure to an unrelated basic user. | normal |
| AC2 | AC2-C4/C5/C6 | 003 | P2 | Wrongful denial to legitimate viewers (owner/manager/admin). | normal |
| AC2 | AC2-C7 | *waived* | P3 | Simple creation path, no role-crossing complexity — out of default scope. | normal |
| AC2 | AC2-C8 | 004 | P1 | Same disclosure risk generalized to an unnamed non-published status. | low (Q8) |
| AC2 | AC2-C9a | 005 | P1 | Disclosure risk; `[open]` Q1 bumps probability. | low (Q1 open) |
| AC2 | AC2-C9b | 006 | P1 | Disclosure risk; `[open]` Q1 bumps probability (list-exclusion side). | low (Q1 open) |
| AC3 | AC3-C1 | 007 | P1 | Field-level disclosure of a specifically locked field. | normal |
| AC3 | AC3-C2/C3 | 008 | P2 | Legitimate manager/admin field access — functional correctness. | normal |
| AC4 | AC4-C1/C2 | 009 | P1 | Identity disclosure (real name/email) — the AC's headline privacy concern. | normal |
| AC4 | AC4-C3/C4 | 010 | P2 | Legitimate manager/admin identity access. | normal |
| AC4 | AC4-C5 | 011 | P2 | Self-view exception — informational correctness, not a breach if wrong. | low (Q4) |
| AC5 | AC5-C1 | 012 | P1 | Private-mode anonymous list-access breach. | normal |
| AC5 | AC5-C2 | 013 | P1 | Private-mode anonymous view-access breach. | normal |
| AC5 | AC5-C3 | 014 | P1 | Private-mode anonymous registration breach. | normal |
| AC5 | AC5-C4 | 015 | P1 | Private-mode anonymous creation breach. | low (Q5) |
| AC5 | AC5-C5 | 016 | P2 | Authenticated-role access retained under private mode — regression risk, not a breach. | low (Q10) |
| AC5 | AC5-C6 | 017 | P2 | Registration-toggle self-service block — functional, moderate crossing logic. | normal |
| AC5 | AC5-C7 | 018 | P1 | `[open]` Q9 bumps probability — genuine uncertainty on the admin-created-account exception. | low (Q9 open) |
| AC6 | AC6-C1 | *waived* | P3 | Single-condition ownership check, no crossing logic — out of default scope. | normal |
| AC6 | AC6-C2/C3 | 019 | P1 | Unauthorized destructive action — irrecoverable media loss. | normal |
| AC6 | AC6-C4 | 020 | P2 | Admin capability over unowned media — functional correctness of the documented exception. | normal |
| AC6 | AC6-C5 | 021 | P2 | Admin capability over any owned media — functional, admin already fully privileged. | low (Q7) |
| AC6 | AC6-C6 | 022 | P1 | Unauthorized destructive action by a manager beyond their stated permission scope. | low (Q6) |
| AC2, AC3, AC4, AC6 (journey) | — | 023 (`@smoke`) | n/a | End-to-end confidence check crossing four ACs; excluded from priority/atomicity accounting. | normal |

## Summary

- **AC total**: 6. **AC covered**: 6 (AC1 covered compositionally, explicitly noted rather than
  left ambiguous).
- **Conditions derived**: 31. **Required-negative (`[req-neg]`) conditions**: 16, all 16 covered
  by a `@negative` scenario — the ADR 0001 gate is **met** (16/16).
- **Generated scope**: P1 (14 scenario blocks) + P2 (8 scenario blocks) + 1 `@smoke` journey = 23
  blocks. **P3 waived** (3 conditions: AC2-C1, AC2-C7, AC6-C1) — listed above, not silently
  dropped.
- **Negative ratio** (D20, `@negative` blocks / all non-smoke blocks): 14/22 = **63.6 %** — well
  above the 40 % signal threshold (reported as a bias signal, never a gate).
- **`@low-confidence` scenarios**: 9 (004, 005, 006, 011, 015, 016, 018, 021, 022) — every one
  cites its question ID inline (`# assumption: Qn` or `# open: Qn`).
