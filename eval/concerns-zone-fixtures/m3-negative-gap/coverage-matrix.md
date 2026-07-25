# Coverage matrix — US-001 (fixture M3)

| AC | Condition | Scenario ID | Priority | Rationale | Confidence |
|---|---|---|---|---|---|
| AC1 | specialty filter | @QAIA-US-001-001 | P2 | important | normal |
| AC2 | <2h refused [req-neg] | @QAIA-US-001-002 | P1 | important | normal |
| AC2 | >=2h succeeds | @QAIA-US-001-003 | P2 | important | normal |
| AC3 | 3rd appointment allowed | @QAIA-US-001-004 | P2 | important | normal |
| AC4 | race condition informed [req-neg] | @QAIA-US-001-005 | P1 | important | normal |
| AC5 | confirmation name/time (link not checked) | (untagged) | P2 | important | normal |
| AC6 | >=4h cancel succeeds | @QAIA-US-001-006 | P2 | important | normal |
| AC7 | minor + unauthorized practitioner refused [req-neg] | @QAIA-US-001-007 | P2 | important | normal |
| AC8 | booking audit entry | (untagged) | P3 | important | normal |
| AC8 | cancellation audit entry | (untagged) | P3 | important | normal |

**Gaps (deliberate, listed honestly)**:
- AC3's required-negative condition ("4th appointment refused") has no scenario.
- AC6's required-negative condition ("<4h cancellation refused") has no scenario.
- AC5's connection-link field is never asserted.
- 3 of 10 scenarios have no `@QAIA-*` ID.
