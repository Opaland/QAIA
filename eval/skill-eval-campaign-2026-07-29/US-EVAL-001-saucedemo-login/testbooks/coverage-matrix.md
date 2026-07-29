# Coverage matrix — US-EVAL-001

| AC | Condition | Scenario ID | Priority | Rationale | Confidence |
|---|---|---|---|---|---|
| AC1 | AC1-C1 | QAIA-US-EVAL-001-001 | P2 | Total-service-loss blast radius if broken, but mature/simple logic | full |
| AC2 | AC2-C1 | QAIA-US-EVAL-001-002 | P1 | Access-control failure class, moderate state-check complexity | full |
| AC3 | AC3-C1 | QAIA-US-EVAL-001-003 | P1 | Auth-bypass-class failure, decision-table logic surface | full |
| AC3 | AC3-C2 | QAIA-US-EVAL-001-004 | P1 | Same, password-mismatch branch | full |
| AC3 | AC3-C3 (Q2) | QAIA-US-EVAL-001-005 | P2 | Impact capped — built on an `[assumption]` | low (`@low-confidence`) |
| AC2 | AC2-C2 (Q3) | QAIA-US-EVAL-001-006 | P1 | Impact 3, probability bumped for `[open]` status per `prioritize` rule | low (`@low-confidence`, `[open]`) — **human arbitration pending** |

All P1/P2 conditions covered (default scope, no P3 conditions exist in this slice). No waivers.
