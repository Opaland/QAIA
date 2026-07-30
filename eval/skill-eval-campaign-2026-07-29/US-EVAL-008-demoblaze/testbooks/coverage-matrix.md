# Coverage matrix — US-EVAL-008

| AC | Condition | Scenario ID | Priority | Rationale | Confidence |
|---|---|---|---|---|---|
| AC2 | AC2-C1 | QAIA-US-EVAL-008-001 | P2 | Expired-token error surfaced correctly to a logged-in shopper | full |
| AC2 | AC2-C2 | QAIA-US-EVAL-008-002 | P2 | Malformed-token error surfaced correctly | full |
| AC2 | AC2-C3 | QAIA-US-EVAL-008-003 | P2 | Flag-incorrect error surfaced correctly | full |
| AC3 | AC3-C1 | QAIA-US-EVAL-008-004 | P1 | Highest-risk false-positive class: guest errors silently reported as success | low (`Q1` — only the live-observable success case is asserted) |
| AC4 | AC4-C2 | QAIA-US-EVAL-008-005 | P2 | Multi-item accumulation across independent async fetches is a real complexity/correctness risk | full |
| AC7 | AC7-C3 | QAIA-US-EVAL-008-006 | P2 | Whitespace-only credit card bypasses validation — a real order-integrity gap a naive test misses | full (confirmed by source: no `.trim()`) |
| AC8 | AC8-C1 | QAIA-US-EVAL-008-007 | P2 | Core conversion action of the whole flow | full |
| AC8 | AC8-C2 | QAIA-US-EVAL-008-008 | P2 | Amount-staleness risk, scoped to single-session | low (`Q2` — multi-tab race not asserted) |
| AC8 | AC8-C3 | QAIA-US-EVAL-008-009 | P1 | No login-gate on checkout — genuine business-policy question | low (`@low-confidence`) — **human arbitration welcome** (`Q3`) |
| AC8 | AC8-C4 | QAIA-US-EVAL-008-010 | P2 | Empty-cart checkout succeeds unguarded — real data-integrity edge case | full (confirmed by source: no emptiness check) |

**P1+P2 scope (default, per `prioritize`'s Q22 quota trade-off): 10/10 in-scope conditions
covered, 10 scenario blocks (no outline needed — each condition is a single, non-parametrized
case).** 11 P3 conditions (`AC1-C1`, `AC1-C2`, `AC2-C4`, `AC4-C1`, `AC4-C3`, `AC5-C1`, `AC6-C1`,
`AC6-C2`, `AC7-C1`, `AC7-C2`, `AC9-C1`) are listed in `state/04-priorities.md` with their
rationale but **not generated** in this run — a human call, deferred per the campaign's
non-interactive convention.

**Standing `[req-neg]` waiver**: `AC7-C1`/`AC7-C2` (Name-empty / Credit-card-empty validation
blocks) are `[req-neg]` conditions from `03-design.md` that scored P3 in `04-priorities.md` — not
generated in this run, carried here by name per `testbook-generate`'s own gate rule (a
priority-scoped waiver is not a silent gate violation as long as it stays visible). All three
P1/P2 `[req-neg]` conditions (`AC2-C1`, `AC2-C2`, `AC2-C3`) **are** covered above.

**Negative ratio**: 3/10 blocks tagged `@negative` (`001`, `002`, `003`) = **30%** (target ≥ 40%,
not met). The three negative scenarios are exactly the P1/P2 `[req-neg]` set; the only other
`[req-neg]` conditions in the design (`AC7-C1`/`AC7-C2`) are P3-deferred, not padded in — see
`synthesis.md`'s ratio explainer.
