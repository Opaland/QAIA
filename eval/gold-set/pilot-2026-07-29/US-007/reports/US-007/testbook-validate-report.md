---
stepsCompleted: [testbook-generate, testbook-export, testbook-validate]
lastStep: testbook-validate
lastSaved: 2026-07-29
---

# testbook-validate — audit report for US-007

Audited: the four `.feature` files in `../../testbooks/US-007/` (31 scenario blocks), against the source US (`eval/gold-set/US-007-course-fee-enrolment.md`, read via `00-source.md`/`01-extraction.md`) and `coverage-matrix.md`. This run is executed without code execution (no script materialized) — the structural algorithm below was applied step-by-step by hand over each file, per the "without code execution" fallback; this is reproducible by construction of the method but weaker than a run script, and is stated plainly per the skill's guardrail.

## Structural pass (step 0, separate from the checklist below)

Budget /100 — readability 25, completeness 30, coherence 20, traceability 25:

- **Readability: 23/25.** Declarative Given/When/Then throughout, consistent vocabulary ("payment-required enrolment method", "fee amount", "not enrolled"); minor terseness in a few `Then` clauses ("blocked server-side") costs 2 points for the least-detailed negative scenarios (014, 017).
- **Completeness: 30/30.** All 5 ACs are covered by scenarios that assert a concrete, verifiable outcome (never an image/table reference).
- **Coherence: 20/20.** No truncated steps; every `Scenario`/`Scenario Outline` is well-formed; `Background`s only state invariants shared by every scenario in their file.
- **Traceability: 25/25.** Every scenario carries a stable `@QAIA-US-007-NNN` ID, an `@ACn` tag, and a `# condition: ACn-Cm` comment; IDs 001-031 have no gap.

**Structural score: 98/100.**

**Detectors:**
- **C1 (hollow AC):** none found — every `Then` asserts a verifiable state/value, never an image/table/screenshot reference.
- **C2 (no expected result):** none found — no `Then` restates "works"/"responds correctly" without a concrete assertion.
- **Sniffer (fabrication):** 0 hits. Technical literals present (fee amounts, currency codes, method names like "Card Gateway") are declarative test fixtures, not unsourced precise business results; no `TODO`/`[À DÉFINIR]`/placeholder markers found.
- **Redundancy:** none — each scenario differs by a real, distinct behavioral condition (no same-shape-different-literal duplicates).

No forced STOP. Structural pass does not cap the gate below the checklist result.

## 8-dimension checklist

| Dimension | Score | Evidence |
|---|---|---|
| Atomicity | 2 | One `When` per scenario throughout; outcomes only in `Then`; the one journey scenario (031) is correctly tagged `@smoke` and excluded. |
| Coverage | 2 | 5/5 ACs have >=1 real scenario (`coverage-matrix.md`). |
| Negative-path coverage | 2 | 11/11 `[req-neg]` conditions covered (ADR 0001 gate); raw ratio 36.7 % reported, not scored against. |
| Technique fit | 2 | Every scenario carries exactly one closed-list technique tag, justified in `synthesis.md`'s by-technique table. |
| Business correctness | 2 | No scenario contradicts the source; all 6 extrapolated assumptions (Q1/Q2/Q4/Q6/Q7/Q9) are flagged `@low-confidence` with their question ID, never asserted as certain. |
| Ambiguity honesty | 2 | Two genuinely unresolved points (Q3, Q10) are visible in the synthesis and not defaulted into a scenario beyond the flagged fail-closed principle (Q9). |
| Traceability | 2 | Stable unique IDs, `@ACn` links, and the coverage matrix agree with the `.feature` files (cross-checked). |
| Gherkin form | 2 | Valid `Feature/Background/Scenario/Scenario Outline/Given/When/Then/And`; `Background` used only for true invariants; the one `Outline` (005) merges only same-priority/same-confidence rows. |

**Total: 16/16.**

## Gate decision

**PASS** (total >= 14, no dimension < 1; structural pass has no forced STOP, so it does not override).

## Highest-impact follow-ups (for a human reviewer)

1. Resolve **Q3** (pending-attempt visibility) and **Q10** (payment-account/gateway scope) with the product owner — both remain genuinely open.
2. Human-review the 7 `@low-confidence` scenarios (007, 009, 010, 018, 022, 024, 030) before treating them as final — they rest on accepted-by-default assumptions in this non-interactive run, not a human decision.
3. Confirm the P1 priority assignments resting on assumptions (022 — declined-payment handling, 024 — zero-enabled-methods) since a wrong assumption there would be the costliest miss in the book.

This is an audit only — no file was modified as part of this pass.
