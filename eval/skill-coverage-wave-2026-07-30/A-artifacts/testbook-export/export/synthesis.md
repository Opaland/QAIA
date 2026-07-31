---
stepsCompleted: [testbook-generate]
lastStep: testbook-generate
lastSaved: 2026-07-30
---

# Synthesis — US-EVAL-009 (OctoPerf Pet Store shopping cart)

**Scope**: add-to-cart, Sub Total computation, remove-from-cart, checkout availability (11
conditions designed, P1+P2 default scope; 3 conditions — AC2-C1, AC3-C2, AC3-C3 — deferred to P3
and not generated, see waiver note below).
**Scenarios**: 8 atomic blocks, no `Scenario Outline`s this run (every condition's coverage is a
single concrete case; none merges same-priority/same-confidence example rows) + 0 smoke journey
(skipped — the add/view/remove slice is already fully atomized across AC1-AC3; a single
end-to-end `@smoke` scenario would only re-verify behaviors already covered atomically).
**Negative ratio**: 1/8 blocks tagged `@negative` = **12.5 %** (target ≥ 40 %, **not met — reported
honestly, not padded**). This slice is structurally happy-path-heavy: unlike an API-validation
slice (rejecting malformed input) or an auth-gate slice (rejecting unauthenticated access), a
shopping cart's core behaviors (compute a total, sum a subtotal, persist across navigation, gate
checkout on non-emptiness) are mostly *positive*-outcome rules by nature — only one condition in
this design (`AC3-C5`, cross-session isolation) is itself a refusal. Reaching 40 % would require
inventing refusal-shaped scenarios not grounded in any fetched source or design condition, which
`testbook-generate`'s own rule forbids — flagged here as a real shortfall instead.
**Coverage**: AC1 2/2, AC2 2/3 (1 deferred to P3), AC3 3/5 (2 deferred to P3) — 8/11 conditions
generated, all 3 ACs have at least one generated scenario.

## Review order

`@low-confidence` first (`002, 004, 005, 007, 008`), then P1 → P3 (`002, 007, 008` → `001, 003,
004, 005, 006` → none generated at P3 — `AC2-C1`, `AC3-C2`, `AC3-C3` are deferred, see below).

## By-technique table

| Technique | ACs | Scenarios | Justification |
|---|---|---|---|
| `@ep` | AC1, AC2 | `001, 003, 004, 005` | Single-item vs. multi-item add classes; format invariant treated as its own partition |
| `@state-transition` | AC1, AC3 | `002, 006` | Per-item `absent → present` re-entrance (repeat add); `present → absent` (remove) |
| `@decision-table` | AC3 | `007, 008` | Out-of-stock × checkout-availability axis; session-scoping axis |
| `@oracle:iso4217` | AC2 | `004` | Two-decimal-place USD formatting, grounded not guessed |

## Open / assumption / low-confidence list (full, per shared contract)

- **Q1** `[assumption]`, `@low-confidence` — repeat-adding the same item increments its existing
  row's quantity and scales its total cost, rather than duplicating the row (`002`). Not
  independently confirmed live (stateless `WebFetch` could not hold a session across two add
  calls).
- **Q3** `[open]`, `@low-confidence` — **human arbitration required**: does an out-of-stock item
  (`In Stock? = false`, observed live on `EST-1`) block "Proceed to Checkout"? `007` encodes a
  *proposed* default (checkout remains available), not a confirmed behavior.
- **Q4** `[assumption]`, `@low-confidence` — a double-submitted "Remove" on an already-absent row
  is idempotent, not an error; deferred to P3, not generated this round (see waiver note).
- **Q5** `[assumption]` — removing the last item converges to the same empty-cart state as AC2-C1;
  deferred to P3, not generated this round (see waiver note).
- **Q6** `[assumption]`, `@low-confidence` — Sub Total is displayed with two-decimal-place USD
  formatting (`004`); no source price forces a genuine sub-cent rounding tie-break.
- **Q7** `[open]` — **human arbitration required**: is a guest cart strictly isolated per session,
  with no cross-session view/mutate path? `008` encodes a *proposed* default (refused/isolated),
  not a confirmed behavior — the exact session-binding mechanism was never independently confirmed
  live (two concurrent sessions cannot be compared via stateless `WebFetch`).
- **derived (3c)** `[assumption]`, `@low-confidence` — cart contents persist across navigation
  away and back within the same session (`005`); not itself sourced from a fetched page, derived
  from `istqb-design`'s systematic-coverage reflex for list-view state persistence.

## Deferred / waived conditions

- **AC2-C1** (empty-cart message/subtotal) — `P3` by `04-priorities.md`'s scoring (impact 1,
  probability 1: this is the one condition most directly confirmed live, not an assumption).
  Excluded from this book by the default P1+P2 scope — a standing, cited waiver, not a silent gap;
  still listed in `coverage-matrix.md`.
- **AC3-C2** (removing the last item converges to the empty state) — `P3` (impact 1, probability
  1). Same treatment as AC2-C1.
- **AC3-C3** (idempotent double-remove) — `P3` (impact 1, probability 2, `[assumption]`). Same
  treatment. None of these three conditions is `[req-neg]` (their proposed outcomes are not
  refusals), so this deferral is an ordinary P3 scope trade-off, not an exercise of the
  P3-`[req-neg]`-waiver rule `testbook-generate` names explicitly.

## Out-of-slice (not designed here)

- Sign-in / account creation (`Account.action?signonForm=`, "Register Now!") — a separate US; this
  slice treats add/view/remove as guest-accessible.
- Checkout / order placement (billing address, payment, order confirmation) — a separate US;
  "Proceed to Checkout" is this slice's boundary, not its content.
- Catalog browsing / category and product listing (search, category navigation, sort/filter) — a
  separate US; this slice starts at "Add to Cart" for an already-located item.

## Sourcing honesty note

This US was captured from a live read of `petstore.octoperf.com` (`Catalog.action`,
`Account.action?signonForm=`, `Cart.action?viewCart=`, `Cart.action?addItemToCart=`) via
`WebFetch`, all 2026-07-30 — a fully reachable, server-rendered JSP application, unlike several
prior campaign targets whose designated URL 404'd or was a JS-only shell. However, `WebFetch` is
**stateless across separate calls** (no session-cookie jar persists between fetches), so several
behaviors that require comparing two states of the *same* session (repeat-add quantity behavior,
Q1) or two *different* concurrent sessions (cross-session isolation, Q7) could not be directly
observed live and remain genuinely `[assumption]`/`[open]` per `02-understanding.md`, not
fabricated past that limit. Per `docs/DEMO-TARGETS.md`'s own row for this target, **no
`perf-check` or `security-surface` was run** against this shared public demo at any point in this
session — the catalog entry's own remedy (self-host a JPetStore clone for a real k6 run) was not
pursued, consistent with the campaign's golden rule; this book is a UI-functional testbook only.

## Skill evaluation — `testbook-generate`

- **Skill evaluated**: `plugins/qaia-core/skills/testbook-generate/SKILL.md`.
- **Input**: `03-design.md` (11 conditions) and `04-priorities.md` (8 P1/P2, 3 P3) above.
- **Output**: `octoperf-petstore-cart.feature`, this synthesis, `coverage-matrix.md`,
  `state/generated.snapshot.md`.
- **Verdict**: **CONFORME.**
- **Evidence**: line 19's "Never pad the negative ratio with invented cases: if reaching 40 %
  requires error-guessing scenarios not grounded in the source or knowledge base, flag the
  shortfall to the user instead of fabricating" is exercised for real by this run — the negative
  ratio (12.5 %) falls well under the 40 % target, and rather than inventing refusal-shaped
  scenarios to close the gap, the synthesis states the shortfall plainly with a structural reason
  (a cart's core behaviors are mostly positive-outcome by nature) instead of padding. Line 28's
  P3-`[req-neg]`-waiver rule is correctly recognized as **not** the mechanism at play for this
  run's three P3 deferrals (AC2-C1, AC3-C2, AC3-C3) — none of them is `[req-neg]`, and the
  synthesis says so explicitly rather than mislabeling an ordinary scope trade-off as an exercise
  of that specific rule. Line 32 ("a computed value is only as grounded as its inputs") is
  respected in `003`/`006`/`002`: every asserted dollar amount (`$33.00`, `$16.50`) is arithmetic
  over the two prices `00-source.md` actually observed live (`$16.50` × 2 items, or × quantity 2),
  never a fabricated literal.
- **Modification proposed**: none.
