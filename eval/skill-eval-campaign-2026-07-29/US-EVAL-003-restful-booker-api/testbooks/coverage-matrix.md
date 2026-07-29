# Coverage matrix — US-EVAL-003

| AC | Condition | Scenario ID | Priority | Rationale | Confidence |
|---|---|---|---|---|---|
| AC1 | AC1-C1 | QAIA-US-EVAL-003-001 | P2 | Total-service-loss blast radius if broken, but simplest/best-tested path | full |
| AC1 | AC1-C5 (Q1) | QAIA-US-EVAL-003-002 | P1 | Impact 2, probability bumped for `[assumption]` status | low (`@low-confidence`) — **human arbitration pending** |
| AC2 | AC2-C1 | QAIA-US-EVAL-003-003 (Outline row 1) | P2 | Off-by-one on `@Min` is a classic BVA-class defect | full |
| AC2 | AC2-C2 | QAIA-US-EVAL-003-003 (Outline row 2) | P2 | Off-by-one on `@Size` min | full |
| AC2 | AC2-C3 | QAIA-US-EVAL-003-003 (Outline row 3) | P2 | Off-by-one on `@Size` max | full |
| AC2 | AC2-C5 | QAIA-US-EVAL-003-003 (Outline row 4) | P2 | Off-by-one on `@Size` min | full |
| AC2 | AC2-C6 | QAIA-US-EVAL-003-003 (Outline row 5) | P2 | Off-by-one on `@Size` max | full |
| AC2 | AC2-C8 | QAIA-US-EVAL-003-004 | P2 | A missing boolean field slipping through corrupts a business field | full |
| AC2 | AC2-C9 | QAIA-US-EVAL-003-005 | P2 | A missing date range breaks every downstream date-dependent read | full |
| AC3 | AC3-C1 | QAIA-US-EVAL-003-006 | P1 | Business-integrity failure (0-night stay persisted), easy off-by-one | full |
| AC3 | AC3-C2 | QAIA-US-EVAL-003-007 | P1 | Same reasoning, inverted range | full |
| AC4 | AC4-C1 | QAIA-US-EVAL-003-008 | P1 | Worst-case business failure (double-booked room), complex overlap logic | full |
| AC2+AC3 | AC-DT-1 (Q3) | QAIA-US-EVAL-003-009 | P1 | Impact 3, probability bumped for `[assumption]` status | low (`@low-confidence`) — **human arbitration pending** |

**P1+P2 scope (default, per `prioritize`'s Q22 quota trade-off): 13/13 conditions covered, 9
scenario blocks (1 outline = 5 conditions).** 11 P3 conditions (AC1-C2/C3/C4, AC2-C4/C7, AC4-C2,
AC5-C1..C5) are listed in `state/04-priorities.md` with their rationale but **not generated** in
this run — a human call, deferred per the campaign's non-interactive convention (see
`04-priorities.md`).
