---
stepsCompleted: [collect, classify, store-examples, propose-promotions, prune, close-the-loop]
lastStep: close-the-loop
lastSaved: 2026-07-25
nextRuleId: BR-KB-003
---

# Feedback rules — promoted from US-004 corrections (expense-demo)

Rules promoted after human (simulated, non-interactive run — `skills/README.md` rule 3)
validation, per `feedback/SKILL.md` step 4 (D22: promotion is always human-validated, never
automatic). This is a **project-local** counter (`expense-demo` has no pre-existing
`knowledge/business-rules.md` in this worktree — degraded mode, shared-contract rule 8), so
numbering starts at `BR-KB-001` rather than continuing another project's sequence.

## BR-KB-001 — unresolved or stale FX rate routes to manual finance review, never a silent value or a hard refusal

Currency conversion (AC6) must not (a) hard-refuse submission when no rate resolves for the
expense's currency, nor (b) silently apply an unbounded "last available prior rate" fallback.
Both cases instead move the report to a `pending-rate` status, held out of every approver's
queue, with Finance notified to resolve the rate manually. The "last available prior rate"
fallback is valid only within a **5-business-day** cap (`fx.staleRateCapBusinessDays = 5`);
beyond the cap, the same `pending-rate` hold applies instead of ever using a rate that old.

**Source examples**: `feedback/examples/US-004-1.md`, `feedback/examples/US-004-2.md`
(2 recurring instances — meets the ≥ 2 threshold, D22).
**Affects**: AC6 (all conditions), and by extension AC2/AC3 wherever a stale/unresolved
converted total would otherwise drive the approval band or the self-approval-skip logic
(AC6-C4, the AC2×AC3×AC6 intersection).
**Scenarios flagged for regeneration** (sibling scenarios of the affected AC, per `SKILL.md`
step 4 — not rewritten by this pilot; `testbook-generate` regenerates on its next diff-based
pass): `@QAIA-US-004-025`, `@QAIA-US-004-026`, `@QAIA-US-004-027`.
_Provenance: simulated Finance SME correction, non-interactive pilot run, 2026-07-25._

## BR-KB-002 — negative/refusal scenarios carry a machine-readable reason code

Every `@negative` scenario's refusal `Then` step asserts a machine-readable reason code in
addition to the HTTP status (e.g. `refused with a 403 status and reason code
"APPROVAL_OUT_OF_ORDER"`), not the status alone. Project-wide Gherkin convention, not specific
to AC2/AC3.

**Source example**: `feedback/examples/US-004-3.md` (1 instance — promoted via the
skill's single-criterion path, "user explicitly asks for immediate promotion",
`SKILL.md` step 4, not the ≥ 2 recurrence threshold).
**Affects**: all 17 `@negative` scenarios in `.qaia/testbooks/US-004/` (see
`coverage-matrix.md`), and every future negative scenario `testbook-generate` produces
project-wide.
**Scenarios flagged for regeneration**: `@QAIA-US-004-005`, `006`, `007`, `012`, `013`, `017`,
`019`, `021`, `023`, `025`, `028`, `029`, `030`, `031`, `035`, `036`, `037` (all 17 `@negative`
scenarios — a style rule with this scope touches the whole book, not just the two illustrated
in the source example).
_Provenance: simulated QA-lead correction, non-interactive pilot run, 2026-07-25._

## Not promoted

`feedback/examples/US-004-4.md` (`one-off` — fixture category label `"hotel"` vs. the project's
`Lodging` enum value) stays an example only: specific to this project's seed data, does not
recur, no immediate-promotion request. Re-evaluate if the same pattern (a placeholder value
outside a project's fixed enum) recurs in a future US.

## Handoff not performed in this pilot (honest gap)

Per `SKILL.md` step 4, an approved promotion is normally handed to `rag-build`, which writes it
into `knowledge/business-rules.md`, updates `knowledge/index.md`, and runs the contradiction
check against any existing rule (guardrail, Q31). **`rag-build` was not run as part of this
pilot** — `expense-demo` has no `knowledge/` directory in this worktree (degraded mode, shared
contract rule 8: recorded here rather than silently assumed), so there is also no existing rule
to contradict. `BR-KB-001`/`BR-KB-002` exist only in this file until a `rag-build` run
materializes them into the knowledge base; `istqb-design`'s next run on US-004 (or a sibling US)
would not yet retrieve them.
