# generated.snapshot — US-EVAL-008

Baseline for regeneration-mode edit detection (sha256, first 12 hex chars, per scenario block;
computed for real over `testbooks/cart-checkout.feature` via a Python `hashlib.sha256` pass on
each scenario's own tag+body text, not estimated).

| Scenario ID | Hash |
|---|---|
| QAIA-US-EVAL-008-001 | `7551d5a5a137` |
| QAIA-US-EVAL-008-002 | `05525c98d1fa` |
| QAIA-US-EVAL-008-003 | `673195d81f78` |
| QAIA-US-EVAL-008-004 | `4017b890b535` |
| QAIA-US-EVAL-008-005 | `258cb875909a` |
| QAIA-US-EVAL-008-006 | `9348353a1166` |
| QAIA-US-EVAL-008-007 | `ceb97451c2d0` |
| QAIA-US-EVAL-008-008 | `ace3dcb26943` |
| QAIA-US-EVAL-008-009 | `33ba99b6a408` |
| QAIA-US-EVAL-008-010 | `5724e7c3f816` |

## Duplicate scan (D19)

Searched the repo for any existing `.feature` file referencing DemoBlaze or its cart/checkout
selectors (`grep -rl "demoblaze\|DemoBlaze\|purchaseOrder\|addtocart" --include=*.feature .`): the
only match is `testbooks/cart-checkout.feature` itself — no prior `.feature` file
(`eval/concerns-zone-fixtures/`, `eval/baselines/`, `plugins/qaia-playwright/skills/automate/
fixture/`, or any `US-EVAL-001`..`007` book) touches DemoBlaze's cart/checkout flow — no reuse
candidate found, all 10 blocks are original to this run.

## Skill evaluation — `testbook-generate` (`plugins/qaia-core/skills/testbook-generate/SKILL.md`)

**Verdict: CONFORME.**

**Evidence**: The consolidation-pass rule (line 26) requires this skill's own deliverable to
record "knowledge base absent," not only rely on the upstream checkpoint's note — `testbooks/
synthesis.md`'s own "Knowledge base" line states this explicitly. The negative-path coverage gate
(line 28) correctly treats `AC7-C1`/`AC7-C2` (the two P3-deferred `[req-neg]` conditions from
`04-priorities.md`) as a standing, priority-scoped waiver, visible with their reason in
`coverage-matrix.md`/`synthesis.md`, not a silent gap — every P1/P2 `[req-neg]` condition
(`AC2-C1`, `AC2-C2`, `AC2-C3`) **is** covered, by scenarios `001`-`003`, satisfying the actual
blocking check. The **"never pad the negative ratio with invented cases"** guardrail (line 19,
repeated at step 5) was followed under real pressure: the ratio came out at 30% (3/10), under the
40% target, and the response was to report and explain the shortfall honestly (`synthesis.md`'s
ratio explainer, citing the P3-deferred `AC7` waiver as the actual cause) rather than mis-tagging
`AC4-C2`/`AC7-C3`/`AC8-C4` as `@negative` to close the gap — none of those three qualifies under
the closed `@negative` definition (none is a refusal/error/denial). The emission lints (step 5)
were run for real: every literal (`1150` for the two-item sum, `0` for the empty-cart case) was
computed/verified against the design conditions before being written into the `.feature` file, not
eyeballed. `generated.snapshot.md`'s hashes above are real SHA-256 digests computed via a Python
`hashlib` pass over the actual file content. Step 2's duplicate scan (line 24) was run for real
(see the section above). One correction made during this generation pass, self-caught before
emission rather than left in: the technique-tag closed list (line 16 of this SKILL.md) names
`@boundary`, not `@bva` — every boundary-value condition in this book (`005`, `006`) is tagged
`@boundary`, matching the closed list literally. No deviation found. **Modification proposed:
none.**
