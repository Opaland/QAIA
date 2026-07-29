# Coverage matrix — US-EVAL-002

| AC | Condition | Scenario ID | Priority | Rationale | Confidence |
|---|---|---|---|---|---|
| AC1 | AC1-C1 | QAIA-US-EVAL-002-001 | P2 | Total-service-loss blast radius if broken, but mature/simple CRUD | full |
| AC1 | AC1-C2 (Q2) | QAIA-US-EVAL-002-002 | P2 | Bad-request-handling gap, decision-table branch | full (`[assumption]`) |
| AC1 | AC1-C3 (Q3) | QAIA-US-EVAL-002-003 | P2 | Same class, exact floor unconfirmed | low (`@low-confidence`) |
| AC2 | AC2-C1 | QAIA-US-EVAL-002-004 | P1 | Core authenticated-revenue path, multi-axis decision-table logic | full |
| AC2 | AC2-C2 | QAIA-US-EVAL-002-005 | P1 | Auth-bypass-class failure | full |
| AC2 | AC2-C3 (Q1) | QAIA-US-EVAL-002-006 | P2 | Data-integrity gap, not access-control | full (`[assumption]`) |
| AC2 | AC2-C4 (Q6) | QAIA-US-EVAL-002-007 | P1 | Cross-tenant/IDOR access-control risk, probability bumped for `[open]` status | low (`@low-confidence`, `[open]`) — **human arbitration pending** |
| AC3 | AC3-C1 | QAIA-US-EVAL-002-008 | P1 | Core guest-revenue path | full |
| AC3 | AC3-C2 (Q4) | QAIA-US-EVAL-002-009 | P2 | Validation-refusal gap | full (`[assumption]`) |
| AC3 | AC3-C3 | QAIA-US-EVAL-002-010 | P2 | Format-validation gap, RFC 5322-grounded | full (`[assumption]`, `@oracle:rfc5322`) |
| AC4 | AC4-C1 (Q5) | QAIA-US-EVAL-002-011 | P1 | Workflow-correctness, probability bumped for `[open]` status | low (`@low-confidence`, `[open]`) — **human arbitration pending** |

All P1/P2 conditions covered (default scope, no P3 conditions exist in this slice). No waivers.
