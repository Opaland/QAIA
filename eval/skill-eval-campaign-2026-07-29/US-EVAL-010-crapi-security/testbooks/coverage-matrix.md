# Coverage matrix — US-EVAL-010

| AC | Condition | Scenario ID | Priority | Rationale | Confidence |
|---|---|---|---|---|---|
| AC2 | AC2-C1 | QAIA-US-EVAL-010-001 | P1 | Canonical BOLA leak (crAPI Challenge 1) — confirmed-present in the current vulnerable implementation, safety/privacy-adjacent impact | full |
| AC2 | AC2-C2 | QAIA-US-EVAL-010-002 | P2 | Denial status-code correctness, secondary to the leak itself | low (`Q1` assumption) — **human arbitration welcome** (`403` vs `404`) |
| AC3 | AC3-C1 | QAIA-US-EVAL-010-003 | P1 | Full authentication bypass would be strictly worse than AC2's ownership-only bypass | full |
| AC3 | AC3-C2 | QAIA-US-EVAL-010-004 | P2 | Narrower attack surface (requires stale credential material) than AC3-C1 | full |
| AC4 | AC4-C1 | QAIA-US-EVAL-010-005 | P2 | Anti-disclosure convergence (nonexistent ID vs wrong-owner ID look identical) | low (`Q3` assumption) — **human arbitration welcome** |

**P1+P2 scope (default, per `prioritize`'s Q22 quota trade-off): 5/5 in-scope conditions covered,
5 scenario blocks (no outline needed — each condition is a single, non-parametrized case).** 1 P3
condition (`AC1-C1`, the owner-happy-path) is listed in `state/04-priorities.md` with its rationale
but **not generated** in this run — a human call, deferred per the campaign's non-interactive
convention.

**Negative ratio: 5/5 = 100 %** (well above the 40 % target) — every in-scope condition in this
security-authorization slice is a refusal/denial path under `testbook-generate`'s own closed
`@negative` definition; the one positive/happy-path condition (`AC1-C1`) is exactly the one
deferred to P3. This is the mirror image of `US-EVAL-006`'s honest **zero** — recorded here as a
genuine, unmassaged result of this AC set's real shape, not inflated or padded (there was nothing
to pad: all five conditions already qualify honestly).
