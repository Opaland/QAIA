# Coverage matrix — US-EVAL-001

| AC | Condition | Scenario ID | Priority | Rationale | Confidence |
|---|---|---|---|---|---|
| AC1 | AC1-C1 | QAIA-US-EVAL-001-001 | P2 | Total-service-loss blast radius if broken, but mature/simple logic | full |
| AC2 | AC2-C1 | QAIA-US-EVAL-001-002 | P1 | Access-control failure class, moderate state-check complexity | full |
| AC3 | AC3-C1 | QAIA-US-EVAL-001-003 | P1 | Auth-bypass-class failure, decision-table logic surface | full |
| AC3 | AC3-C2 | QAIA-US-EVAL-001-004 | P1 | Same, password-mismatch branch | full |
| AC3 | AC3-C3 (Q2) | QAIA-US-EVAL-001-005 | P2 | Was capped by an `[assumption]`; assumption disconfirmed 2026-08-01, scenario now asserts the real required-field messages | full (Q2 resolved) |
| AC2 | AC2-C2 (Q3) | QAIA-US-EVAL-001-006 | P1 | Probability was bumped for `[open]` status per `prioritize` rule; Q3 resolved 2026-08-01 by real execution, proposed default disconfirmed and corrected | full (Q3 resolved) |

All P1/P2 conditions covered (default scope, no P3 conditions exist in this slice). No waivers.

Both `@low-confidence` markers were cleared on 2026-08-01 by running the suite against the live
application (D132), not by paper arbitration — oracle output in
`eval/ci-proof-2026-08-01/oracle-probe-saucedemo.txt`.
