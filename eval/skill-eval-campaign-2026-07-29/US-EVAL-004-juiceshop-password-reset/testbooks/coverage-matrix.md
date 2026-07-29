# Coverage matrix — US-EVAL-004

| AC | Condition | Scenario ID | Priority | Rationale | Confidence |
|---|---|---|---|---|---|
| AC1 | AC1-C1 | QAIA-US-EVAL-004-001 | P2 | Total-feature-loss blast radius if the lookup breaks, but mature/simple GET | full |
| AC1 | AC1-C2 (Q1) | QAIA-US-EVAL-004-002 | P1 | Account-existence disclosure risk; probability bumped for `[open]` status | low (`@low-confidence`, `[open]`) — **human arbitration pending** |
| AC2 | AC2-C1 | QAIA-US-EVAL-004-003 | P1 | Core success path; decision-table logic surface | full |
| AC3 | AC3-C1 | QAIA-US-EVAL-004-004 | P1 | Auth-bypass-class failure if a wrong answer is accepted | full (refusal qualitative only, `[assumption]` Q2) |
| AC3 | AC3-C2 (Q3) | QAIA-US-EVAL-004-005 | P1 | Brute-force/account-takeover risk; probability bumped for `[open]` status | low (`@low-confidence`, `[open]`) — **human arbitration pending** |
| AC4 | AC4-C1, AC4-C4 | QAIA-US-EVAL-004-007 | P2 | Off-by-one boundary-bug class, real but not itself a takeover path | full |
| AC4 | AC4-C2, AC4-C3 | QAIA-US-EVAL-004-006 | P2 | Same reasoning, accept side of the boundary | full |
| AC4 | AC4-C5 | — (waived) | P3 | Below default P1+P2 generation threshold — see `synthesis.md` | full (not generated, quota trade-off) |
| AC4 | AC4-C6 (Q4) | QAIA-US-EVAL-004-008 | P1 | Defense-in-depth gap if the backend doesn't re-validate; probability bumped for `[open]` status | low (`@low-confidence`, `[open]`) — **human arbitration pending** |

10/11 conditions covered (P1+P2 default scope). 1 waived (AC4-C5, P3, quota trade-off, not a gap).
