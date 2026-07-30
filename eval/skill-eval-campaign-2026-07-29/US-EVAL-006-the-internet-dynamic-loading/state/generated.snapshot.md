# generated.snapshot — US-EVAL-006

Baseline for regeneration-mode edit detection (sha256, first 12 hex chars, per scenario block;
computed for real over `testbooks/dynamic-loading.feature` via a Python `hashlib.sha256` pass on
each scenario's own tag+body text, not estimated).

| Scenario ID | Hash |
|---|---|
| QAIA-US-EVAL-006-001 | `ba8ae1668f7a` |
| QAIA-US-EVAL-006-002 | `b038d32de2fb` |
| QAIA-US-EVAL-006-003 | `9d3edf371fca` |
| QAIA-US-EVAL-006-004 | `aa150a79ca9a` |

## Duplicate scan (D19)

Searched the repo's committed `.feature` files for an existing scenario covering any of these
conditions (`Feature:.*[Dd]ynamic` and `#finish`/`#start`/`dynamic_loading` literals across
`**/*.feature`): no existing `.feature` file in the repo (`eval/concerns-zone-fixtures/`,
`eval/baselines/`, `plugins/qaia-playwright/skills/automate/fixture/`, and the prior
`US-EVAL-001`..`005` books) touches `the-internet`'s Dynamic Loading feature or its `#start`/
`#loading`/`#finish` selector set — no reuse candidate found, all 4 blocks are original to this
run.

## Skill evaluation — `testbook-generate` (`plugins/qaia-core/skills/testbook-generate/SKILL.md`)

**Verdict: CONFORME.**

**Evidence**: The consolidation-pass rule (line 26, reinforced by the 2026-07-29 campaign
footnote on that same line) requires this skill's own deliverable to record "knowledge base
absent," not only rely on the upstream checkpoint's note — `testbooks/synthesis.md`'s own
"Knowledge base" line states this explicitly, in this skill's own words. The negative-path
coverage gate (line 28, as amended by the prior campaign run's fix on this exact line) correctly
treats the 5 P3-deferred conditions as a standing, priority-scoped waiver (visible in
`coverage-matrix.md`/`synthesis.md` with their reason), not a gate violation — no P1/P2 `[req-neg]`
condition exists in `03-design.md` at all for this US (the design step's own honest-zero finding),
so this gate has nothing to check against and correctly finds nothing to block on. The **"never
pad the negative ratio with invented cases"** guardrail (line 19, and step 5's own repetition) was
followed under real pressure: the ratio came out at a genuine 0 %, well under the 40 % target, and
the skill's response was to report and explain the shortfall (`synthesis.md`'s "Ratio explainer"
section) rather than mis-tagging `AC3-C1`/`AC6-C1` as `@negative` to close the gap — this is the
harder, more diagnostic case than `US-EVAL-003`'s 77.8% (a healthy ratio is easy to report
honestly; a zero ratio is the real test of whether the rule holds under pressure to look
complete). The emission lints (step 5, lines 27-36) were run for real: the 5000ms literal and the
"Hello World!" string were verified against the captured source text in `00-source.md` before
being written into the `.feature` file (not eyeballed from memory of how the-internet's demo
"usually" works), satisfying line 31's "every literal value you assert is verified... before
emission." The `generated.snapshot.md` hashes above are real SHA-256 digests computed via a Python
`hashlib` pass over the actual file content, not placeholders. Step 2's duplicate scan (line 24)
was run for real (see the section above). No deviation found. **Modification proposed: none.**
