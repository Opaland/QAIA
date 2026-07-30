# Synthesis — US-EVAL-008 (DemoBlaze: add to cart, review total, place order)

**Scope**: P1+P2 conditions only (10/21 conditions, default scope per `prioritize`'s Q22 quota
trade-off — the 11 P3 conditions are listed in `state/04-priorities.md`, not generated here, a
human call deferred non-interactively).
**Scenarios**: 10 atomic blocks, 0 outlines (each in-scope condition is a single case), + 0 smoke
journey (skipped — no single end-to-end journey scenario was added beyond the 10 atomic ones;
`istqb-design`'s Scenario-Based Testing constraint caps this at one per US and this flow's
individual atomic scenarios already exercise every state-machine edge derived in `03-design.md`'s
state × event table without needing a separate re-verification pass).
**Negative ratio**: 3/10 blocks tagged `@negative` = **30%** (target ≥ 40%, **honestly not met**).
This is not a padding shortfall — `testbook-generate`'s own closed `@negative` definition
("a refusal, an error, or an explicitly denied access") is satisfied by exactly 3 in-scope
conditions (`AC2-C1`..`C3`); the other two `[req-neg]` conditions in the full design (`AC7-C1`,
`AC7-C2`) are P3-deferred by the priority scores in `04-priorities.md`, not by a `testbook-generate`
choice — see "Ratio explainer" below.
**Coverage**: AC2 3/3 (of the P1+P2 subset), AC3 1/1, AC4 1/1, AC7 1/1, AC8 4/4 — 10/10 in-scope
conditions covered, 0 waived within scope (the `AC7-C1`/`AC7-C2` waiver is a priority-scope
exclusion, not an in-scope waiver — see coverage matrix).
**Knowledge base**: absent for this campaign directory (recorded per shared-contract rule 8 and
`03-design.md` 3d) — this skill's own record, not only relying on the upstream checkpoint's note.

## Open / assumption / low-confidence list (full, per shared contract)

- **Q1** `[assumption]`, `@low-confidence` on `QAIA-US-EVAL-008-004` — the guest add-to-cart
  path's "never surfaces a backend error" property is cited from source, not independently
  forced live (would require manufacturing a live backend error against the shared demo, outside
  this capture's read-only/no-write-request discipline).
- **Q2** `[assumption]`, `@low-confidence` on `QAIA-US-EVAL-008-008` — the confirmation dialog's
  Amount is scoped to a single session with no concurrent cart modification; the un-awaited
  `deletecart`/stale-Amount race itself is a named gap for a future robustness-focused US, not
  asserted with a specific timing outcome.
- **Q3** `[open]`, `@low-confidence` on `QAIA-US-EVAL-008-009` — **human arbitration requested,
  not blocking**: is unauthenticated ("guest") checkout the intended business policy, or should
  purchasing require login? No gate exists either way in the captured source. This scenario
  asserts the current, observed no-gate behavior; a policy decision either way would only change
  whether this scenario should instead assert a block, not the rest of the book.

## Ratio explainer

**Needed** — the negative ratio (30%) is below the 40% target, and the reason is stated plainly
rather than padded: this US-slice's full `[req-neg]` set has exactly 5 conditions (`03-design.md`),
of which 3 (`AC2-C1`..`C3`) are P1/P2 and in scope here, and 2 (`AC7-C1`/`AC7-C2`, the required-
field validation blocks) are P3-deferred by `04-priorities.md`'s own risk scoring, not by this
step. Forcing `AC4-C2`, `AC7-C3`, or `AC8-C4` to carry `@negative` would be mistagging — none of
them is a refusal/error/denial under the closed definition (they are, respectively, a correctness
check on a happy-path sum, a validation-*gap* that lets a bad value *through*, and an unguarded
edge case that *succeeds* when perhaps it shouldn't — none is the system refusing anything).
Generating `AC7-C1`/`AC7-C2` at their true P3 priority would raise the ratio to 5/12 ≈ 42% but
would violate the P1+P2 default scope from `prioritize` without a human's explicit override —
flagged here for the human reviewer as the fastest lever to both close the gap and add two more
`[req-neg]` scenarios, rather than silently expanding scope or fabricating unrelated negatives.

## Out-of-slice dependencies

- `js/index.js`'s catalog listing/pagination/category-filter logic (`/entries`, `/pagination`,
  `/bycat`) — a separate "browse catalog" US-slice, not designed here.
- `logIn()`/`register()` (all three captured files) — a separate "auth" US-slice; referenced here
  only for how the `tokenp_` cookie changes AC1-AC4's/AC8's request shape.
- The guest-cart-identifier (raw `document.cookie` GUID) IDOR-shape observation from
  `03-design.md`'s 3c pass — explicitly out of scope: exercising it is a security-surface probe,
  and DemoBlaze's catalog row forbids security-surface testing on this shared demo
  (`docs/DEMO-TARGETS.md`). Flagged as a gap for a `security-surface` run on a self-hosted target,
  never generated here.

## Review order

`@low-confidence` first (`QAIA-US-EVAL-008-009` [Q3, `[open]`, human arbitration requested], then
`004`, `008` [both `[assumption]`]), then P1 → P2 for the rest: `004`/`009` already listed (P1),
then `001`, `002`, `003`, `005`, `006`, `007`, `008`, `010` (P2).

## By-technique table

| Technique | ACs | Scenarios | Justification |
|---|---|---|---|
| `@decision-table` | AC2 | `001`, `002`, `003` | Three columns of the `errorMessage` decision table crossed with the logged-in add-to-cart branch — see `03-design.md`. |
| `@ep` | AC3, AC8 | `004`, `007`, `008`, `009` | Each is a representative-class check of a distinct partition (guest success; valid purchase; single-session Amount; guest checkout), not a threshold. |
| `@boundary` | AC4, AC7 | `005`, `006` | Multi-item sum accumulation and the whitespace-only credit-card boundary — see `03-design.md`. |
| `@state-transition` | AC8 | `010` | The `S0 empty cart → S3 ordered` edge of the state × event table in `03-design.md`, confirmed source-grounded (no cart-emptiness guard found). |

## Priority rationale (full — copied from `04-priorities.md` per the deliverable rule)

See `coverage-matrix.md`'s Rationale column for the one-line risk driver behind every scored
condition in scope. **Human arbitration welcome**: `AC8-C3`/Q3 — the P1 rank rests on an `[open]`
policy question (is guest checkout intended?), not a literal source statement of either policy;
`AC3-C1`/Q1 and `AC8-C2`/Q2 rest on `[assumption]`s about what this capture's read-only discipline
can and cannot independently re-verify live, not about the underlying code's determinism.

## Coverage matrix

See `testbooks/coverage-matrix.md` (linked, not duplicated here).

## Changelog

None — initial generation, no prior book existed for this US-ID.

## Sourcing honesty note

Grounded in **primary source** (DemoBlaze's own served HTML + linked JavaScript for
`index.html`/`prod.html`/`cart.html`, read directly, no write request sent — see `00-source.md`
for the exact resources read). Confidence on the request shapes, validation logic, and literal
copy (alert strings, field names) is source-grade; confidence on the three flagged questions
(`Q1`/`Q2`/`Q3`) is explicitly lower and flagged for human arbitration, not blended into the rest.
