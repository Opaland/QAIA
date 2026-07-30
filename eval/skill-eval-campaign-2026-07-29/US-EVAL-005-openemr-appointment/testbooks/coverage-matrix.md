# Coverage matrix — US-EVAL-005

| AC | Condition | Scenario ID | Priority | Rationale | Confidence |
|---|---|---|---|---|---|
| AC1 | AC1-C1 | QAIA-US-EVAL-005-001 | P2 | Total-service-loss blast radius if broken, but mature/simple CRUD | full |
| AC1 | AC1-C2 (Q5) | QAIA-US-EVAL-005-002 | P2 | Duration-boundary, workflow/data-integrity gap | low (`@low-confidence`) |
| AC1 | AC1-C3 (Q4) | QAIA-US-EVAL-005-003 | P2 | Past-date scheduling-data-integrity gap, plausible legitimate exception exists | low (`@low-confidence`) |
| AC1 | AC1-C4 (Q1) | QAIA-US-EVAL-005-004 | P1 | Double-booking is a clinical-scheduling-safety risk; probability bumped for `[open]` status | low (`@low-confidence`, `[open]`) — **human arbitration pending** |
| AC2 | AC2-C1 | QAIA-US-EVAL-005-005 | P1 | Unauthenticated creation is an auth-bypass-class failure on a health-record system | full |
| AC2 | AC2-C2 (Q7) | QAIA-US-EVAL-005-006 | P1 | Expired/revoked token treated as valid, same auth-bypass class | low (`@low-confidence`) |
| AC2 | AC2-C3 (Q6) | QAIA-US-EVAL-005-007 | P1 | Cross-site/cross-tenant booking is a health-data access-control breach (IDOR-class); probability bumped for `[open]` status | low (`@low-confidence`, `[open]`) — **human arbitration pending** |
| AC2 | AC2-C4 (Q9) | QAIA-US-EVAL-005-008 | P1 | Auth-vs-validation-order disclosure nuance; probability bumped for `[open]` status | low (`@low-confidence`, `[open]`) — **human arbitration pending** |
| AC3 | AC3-C2 | *(deferred — see below)* | P3 | Missing-field validation directly stated by source (not an assumption); default scope excludes P3 | full — **not generated, standing waiver** |
| AC3 | AC3-C3 (Q3) | QAIA-US-EVAL-005-009 | P2 | Reference-validation gap (nonexistent facility) | full (`[assumption]`) |
| AC3 | AC3-C4 (Q2) | QAIA-US-EVAL-005-010 | P2 | Reference-validation gap (nonexistent patient) | full (`[assumption]`) |
| AC3 | AC3-C5 | QAIA-US-EVAL-005-011 | P2 | Format-validation gap, ISO 8601-grounded | full (`@oracle:iso8601`) |
| AC3 | AC3-C6 | QAIA-US-EVAL-005-012 | P2 | Format-validation gap, ISO 8601-grounded | full (`@oracle:iso8601`) |

12/13 conditions covered by a generated scenario. **AC3-C2 is deferred to P3 by the default
P1+P2 scope** (`04-priorities.md`) — a standing, cited waiver per `testbook-generate`'s own rule
that a `[req-neg]` condition left at P3 by the default scope is not a silent gate violation,
provided it still appears here with its reason. No other waivers.
