# Coverage matrix — US-EVAL-006

| AC | Condition | Scenario ID | Priority | Rationale | Confidence |
|---|---|---|---|---|---|
| AC3 | AC3-C1 | QAIA-US-EVAL-006-001 | P2 | Presence-vs-visibility defect class, less severe variant (element already present) | low (`Q2` lower-bound timing assumption) |
| AC4 | AC4-C1 | QAIA-US-EVAL-006-002 | P2 | Establishes the premise for AC6-C1; a real presence-vs-visibility test-authoring mistake class | full |
| AC6 | AC6-C1 | QAIA-US-EVAL-006-003 | P1 | The feature's signature edge case — no element at all before the delay | low (`@low-confidence`) — **human arbitration welcome** (`Q2`) |
| AC6 | AC6-C2 | QAIA-US-EVAL-006-004 | P2 | Happy-path completion of the create-then-show mechanism | low (`Q2` lower-bound timing assumption) |

**P1+P2 scope (default, per `prioritize`'s Q22 quota trade-off): 4/4 conditions covered, 4
scenario blocks (no outline needed — each condition is a single, non-parametrized case).** 5 P3
conditions (`AC1-C1`, `AC2-C1`, `AC3-C2`, `AC5-C1`, `AC7-C1`) are listed in `state/04-priorities.md`
with their rationale but **not generated** in this run — a human call, deferred per the campaign's
non-interactive convention (see `04-priorities.md`).

**Honest zero — negative ratio**: none of the 4 in-scope scenarios qualifies as `@negative` under
`testbook-generate`'s own closed definition ("a scenario whose outcome is a refusal, an error, or
an explicitly denied access") — this page has no request that gets refused; `AC3-C1`/`AC6-C1`
assert an *absence at a point in time* (structurally closer to the closed definition's own
carve-out, "list-exclusion/filtering scenarios are not `@negative`"), not a denial. Recorded here
rather than mis-tagged to chase the 40% target — see `synthesis.md`'s ratio explainer.
