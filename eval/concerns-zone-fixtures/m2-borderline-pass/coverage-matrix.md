# Coverage matrix — US-001 (fixture M2)

| AC | Condition | Scenario ID | Priority | Rationale | Confidence |
|---|---|---|---|---|---|
| AC1 | specialty filter | @QAIA-US-001-001 | P2 | standard case | normal |
| AC2 | <2h refused [req-neg] | @QAIA-US-001-002 | P1 | standard case | normal |
| AC2 | >=2h succeeds | @QAIA-US-001-003 | P2 | standard case | normal |
| AC3 | 3rd appointment allowed | @QAIA-US-001-004 | P2 | standard case | normal |
| AC3 | 4th appointment refused [req-neg] | @QAIA-US-001-005 | P1 | important case | normal |
| AC4 | race condition informed [req-neg] | @QAIA-US-001-006 | P1 | important case | normal |
| AC5 | confirmation content (name/time/link) | @QAIA-US-001-007 | P2 | standard case | normal |
| AC6 | >=4h cancel succeeds | @QAIA-US-001-008 | P2 | standard case | normal |
| AC6 | <4h cancel refused [req-neg] | @QAIA-US-001-009 | P1 | important case | normal |
| AC7 | minor + authorized practitioner, guardian notified | @QAIA-US-001-010 | P2 | standard case | normal |
| AC7 | minor + unauthorized practitioner refused [req-neg] | @QAIA-US-001-011 | P3 | important case | normal |
| AC8 | booking audit entry | @QAIA-US-001-012 | P3 | standard case | normal |

**Coverage**: all 8 AC have >=1 scenario; all 5 identified required-negative conditions are
covered.

**Gaps**: AC7's "guardian contact missing on file" edge case has no scenario (silently assumed
away, not flagged as an open question). AC8's cancellation audit entry (as opposed to booking)
has no dedicated scenario.

**Note on scenario IDs**: the AC7-positive row above is recorded as `@QAIA-US-001-010`, matching
this project's ID sequence — cross-check against the `.feature` file before treating this as
authoritative.
