# Synthesis — US-EVAL-006 (the-internet: Dynamically Loaded Page Elements)

**Scope**: P1+P2 conditions only (4/9 conditions, default scope per `prioritize`'s Q22 quota
trade-off — the 5 P3 conditions are listed in `state/04-priorities.md`, not generated here, a
human call deferred non-interactively).
**Scenarios**: 4 atomic blocks, 0 outlines (each in-scope condition is a single case, not a
parametrized set), + 0 smoke journey (skipped — clicking "Start" and observing the reveal *is*
already the entire end-to-end journey for each example; a separate `@smoke` scenario would just
re-run AC3-C1+AC3-C2 or AC6-C1+AC6-C2 back to back with no new journey-level assertion, which the
`istqb-design` scenario-based-testing constraint's own "never re-verifying behaviors already
covered atomically" rule argues against adding).
**Negative ratio**: 0/4 blocks tagged `@negative` = **0 %** (target ≥ 40 %, **honestly not met**).
This is not a shortfall of coverage — it is a correct application of `testbook-generate`'s own
closed `@negative` definition ("a refusal, an error, or an explicitly denied access"): this page
has no rule that refuses a request, so no condition in scope qualifies, and none was force-tagged
to chase the ratio (`testbook-generate`'s own guardrail: "never pad the negative ratio with
invented cases... flag the shortfall to the user instead of fabricating"). See "Ratio explainer"
below.
**Coverage**: AC3 1/1 (of the P1+P2 subset), AC4 1/1, AC6 2/2 — 4/4 in-scope conditions covered, 0
waived within scope.
**Knowledge base**: absent for this campaign directory (recorded per shared-contract rule 8 and
`03-design.md` 3d) — this skill's own record, not only relying on the upstream checkpoint's note.

## Open / assumption / low-confidence list (full, per shared contract)

- **Q1** `[assumption]` — what happens on a forced/programmatic second click while a reveal timer
  is already pending? Not generated as a scenario (no real pointer-reachable path to it in either
  example); flagged as a named gap for a future robustness-focused US, not asserted either way.
- **Q2** `[assumption]`, `@low-confidence` on `QAIA-US-EVAL-006-003` — **human arbitration
  welcome, not blocking**: is the 5000ms delay best treated as a strict lower bound (standard
  `setTimeout` semantics) for automation, or does the target's own test-runner convention expect a
  different wait strategy (fixed sleep vs. polling assertion)? All four scenarios encode the
  *lower-bound* reading; a different convention would only change the wait mechanism used by the
  automation layer, not the asserted DOM states themselves.

## Ratio explainer

**Needed** — the negative ratio (0 %) is below the 40 % target, and the reason is stated plainly
rather than padded: this US-slice's in-scope conditions are two "not yet" state checks
(`AC3-C1`, `AC6-C1`) and two positive/happy-path checks (`AC4-C1`, `AC6-C2`); none is a
request-refusal in `testbook-generate`'s own closed sense. Forcing an invented refusal scenario
(there is no input to reject on a page with no form validation) would be fabrication, not honest
coverage — flagged for the human reviewer rather than silently worked around.

## Out-of-slice dependencies

- `the-internet`'s other "edge case" pages (`dynamic_controls`, `disappearing_elements`,
  `slow_resource`, etc.) — same demo app, separate features, not designed here (see
  `00-source.md` dependencies).

## Review order

`@low-confidence` first (`QAIA-US-EVAL-006-003` [Q2]), then P1 → P2: `003` (P1, already listed),
then `001`, `002`, `004` (P2).

## By-technique table

| Technique | ACs | Scenarios | Justification |
|---|---|---|---|
| `@ep` | AC4 | `002` | A representative-class initial-state check, not a threshold. |
| `@state-transition` + `@bva` | AC3, AC6 | `001`, `003`, `004` | Every in-scope condition here is an edge of the `idle → loading → revealed` state machine crossed with the 5000ms boundary (Q2) — see the state × event table in `03-design.md`. |

## Priority rationale (full — copied from `04-priorities.md` per the deliverable rule)

See `coverage-matrix.md`'s Rationale column for the one-line risk driver behind every scored
condition in scope. **Human arbitration welcome**: `AC6-C1`/Q2 — the P1 rank rests on an
`[assumption]` about timing semantics, not a literal source statement (though the underlying
`setTimeout` contract itself is standard, well-documented JS behavior, not a guess about this
specific page).

## Coverage matrix

See `testbooks/coverage-matrix.md` (linked, not duplicated here).

## Changelog

None — initial generation, no prior book existed for this US-ID.

## Sourcing honesty note

Grounded in **primary source** (the two example pages' own served HTML + inline JavaScript, read
directly via `GET`, not a secondary write-up) — see `00-source.md` for the exact pages read.
Confidence on the DOM structure, click handlers, and the literal 5000ms/`"Hello World!"` values is
source-grade; confidence on the timing-semantics assumption (Q2) is explicitly lower and flagged
for human arbitration, not blended into the rest.
