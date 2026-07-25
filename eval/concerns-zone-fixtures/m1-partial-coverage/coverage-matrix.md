# Coverage matrix — US-001 (fixture M1)

| AC | Condition | Scenario ID | Priority | Rationale | Confidence |
|---|---|---|---|---|---|
| AC1 | specialty filter | @QAIA-US-001-001 | P2 | important | normal |
| AC2 | <2h refused [req-neg] | @QAIA-US-001-002 | P1 | important | normal |
| AC2 | >=2h succeeds | (untagged) | P2 | important | normal |
| AC3 | 3rd appointment allowed | @QAIA-US-001-003 | P2 | important | normal |
| AC4 | race condition informed [req-neg] | @QAIA-US-001-004 | P1 | important | normal |
| AC5 | confirmation content | @QAIA-US-001-005 | P2 | important | normal |
| AC6 | <4h cancel refused [req-neg] | (untagged) | P1 | important | normal |
| AC6 | >=4h cancel succeeds | @QAIA-US-001-006 | P2 | important | normal |
| AC8 | booking audit entry | @QAIA-US-001-007 | P3 | important | normal |
| AC8 | cancellation audit entry | @QAIA-US-001-007 | P3 | important | normal |

**Gaps**: AC7 (minors / guardian contact) has no scenario — not generated in this pass.
AC3's "4th appointment refused" required-negative condition has no scenario.
