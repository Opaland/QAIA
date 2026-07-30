# Coverage matrix — US-EVAL-009

| AC | Condition | Scenario ID | Priority | Rationale | Confidence |
|---|---|---|---|---|---|
| AC1 | AC1-C1 | QAIA-US-EVAL-009-001 | P2 | Money-correctness of a single add, but simple/mature path | full |
| AC1 | AC1-C2 (Q1) | QAIA-US-EVAL-009-002 | P1 | Silent row-model defect on repeat add is a money-correctness risk; `[assumption]` | low (`@low-confidence`) |
| AC2 | AC2-C1 | *(deferred — see below)* | P3 | Directly source-stated empty-cart behavior; lowest-risk condition | full — **not generated, standing waiver** |
| AC2 | AC2-C2 | QAIA-US-EVAL-009-003 | P2 | Core multi-item Sub Total arithmetic, money-correctness | full |
| AC2 | AC2-C4 (Q6) | QAIA-US-EVAL-009-004 | P2 | Currency format/rounding, ISO 4217-grounded | low (`@low-confidence`) |
| AC2 | AC2-C5 | QAIA-US-EVAL-009-005 | P2 | Cart-persistence-across-navigation, workflow data-loss risk | low (`@low-confidence`) |
| AC3 | AC3-C1 | QAIA-US-EVAL-009-006 | P2 | Removal must not corrupt remaining money total | full |
| AC3 | AC3-C2 (Q5) | *(deferred — see below)* | P3 | Convergence to an already-tested empty state | full — **not generated, standing waiver** |
| AC3 | AC3-C3 (Q4) | *(deferred — see below)* | P3 | Idempotent double-submit edge case, robustness not money/access | low (`@low-confidence`) — **not generated, standing waiver** |
| AC3 | AC3-C4 (Q3) | QAIA-US-EVAL-009-007 | P1 | Out-of-stock reaching checkout is an inventory/policy risk; probability bumped for `[open]` status | low (`@low-confidence`, `[open]`) — **human arbitration pending** |
| AC3 | AC3-C5 (Q7) | QAIA-US-EVAL-009-008 | P1 | Cross-session cart access is an IDOR-class access-control breach; probability bumped for `[open]` status | low (`[open]`) — **human arbitration pending** |

8/11 conditions covered by a generated scenario. **AC2-C1, AC3-C2 and AC3-C3 are deferred to P3**
(`04-priorities.md`) by the default P1+P2 scope — standing, cited waivers. None of the three is a
`[req-neg]` condition (per `03-design.md`'s tagging: none of their proposed outcomes is itself a
refusal/error/denial), so this is an ordinary P3 scope deferral, not an exercise of
`testbook-generate`'s P3-`[req-neg]`-waiver rule. No other waivers.
