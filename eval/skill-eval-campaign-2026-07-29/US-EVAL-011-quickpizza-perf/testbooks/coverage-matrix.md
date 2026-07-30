# Coverage matrix — US-EVAL-011

| AC | Condition | Scenario ID | Priority | Rationale | Confidence |
|---|---|---|---|---|---|
| AC1 | AC1-C1 | *(deferred — see below)* | P3 | Simple, well-documented input handling; probability low | full — **not generated, standing waiver** |
| AC1 | AC1-C2 | *(deferred — see below)* | P3 | Same class as AC1-C1, defaults-applied partition | full — **not generated, standing waiver** |
| AC1 | AC1-C3 (Q1) | QAIA-US-EVAL-011-001 | P1 | Auth-boundary miss on a public demo endpoint; probability bumped for `[open]` status | low (`@low-confidence`, `[open]`) — **human arbitration pending** |
| AC2 | AC2-C1 | QAIA-US-EVAL-011-002 | P1 | This target exists specifically to be load-tested; a p95 regression is the exact failure class it was picked to catch | low (`@low-confidence` inherited from Q2 — threshold source is the project's own worked example, not a confirmed SLO) |
| AC2 | AC2-C2 | QAIA-US-EVAL-011-003 | P1 | Tail-latency (p99) regression, distinct failure mode from p95 | low (`@low-confidence`, same Q2 basis) |
| AC2 | AC2-C3 | QAIA-US-EVAL-011-004 | P1 | Rising error rate under load is a service-availability failure | low (`@low-confidence`, same Q2 basis) |
| AC3 | AC3-C1 (Q4) | QAIA-US-EVAL-011-005 | P2 | Inverted toppings range, data-integrity gap | full (`[assumption]`) |
| AC3 | AC3-C2 (Q5) | QAIA-US-EVAL-011-006 | P2 | Negative calorie cap, data-integrity gap | full (`[assumption]`) |
| AC3 | AC3-C3 (Q6) | QAIA-US-EVAL-011-007 | P1 | Over-length name, storage-hygiene gap; probability bumped for `[open]` status, boundary itself unknown | low (`@low-confidence`, `[open]`) — **human arbitration pending** |

7/9 conditions covered by a generated scenario. **AC1-C1 and AC1-C2 are deferred to P3 by the
default P1+P2 scope** (`04-priorities.md`) — a standing, cited waiver per `testbook-generate`'s own
scope rule ("Confirm target coverage with the user (P1+P2 by default; P3 on request)"). Unlike
US-EVAL-005's AC3-C2 precedent, these two are **not** `[req-neg]` conditions, so the negative-path
gate (ADR 0001) never applied to them in the first place — their absence is a plain scope waiver,
not a negative-path gate exception. **Consequence worth flagging at the human gate**: this means
the delivered book contains **no happy-path scenario at all** — every generated scenario is either
a boundary/performance assertion (AC2) or a refusal/negative-boundary probe (AC1-C3, AC3-C1..C3).
No `@smoke` end-to-end journey scenario was added to compensate: `istqb-design`'s own AC1 →
technique map (`03-design.md`) selected Equivalence Partitioning only, never Scenario-Based Testing,
so generating a smoke journey at this step would exceed what design actually authorized — per the
campaign protocol's own step 6 discipline ("no anticipation beyond what 1-4 have posed"). Flagged
here rather than silently patched.
