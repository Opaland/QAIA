---
stepsCompleted: [00-ingest, 01-review, 02-understanding, 03-design]
lastStep: 03-design
lastSaved: 2026-07-30
---

# 03-design — US-EVAL-009

## AC → technique map

- **AC1** (add computes a correct row Total Cost) → **Equivalence partitioning** (single-item add
  vs. repeat-add of the same item) extended by **State Transition Testing** on the per-item
  `absent → present` transition and its re-entrance case (Q1).
- **AC2** (Sub Total is the sum of all rows) → **Equivalence partitioning** (empty cart / single
  item / multiple distinct items) plus a **standardized-domain oracle** (ISO 4217, USD, 2 decimal
  places) on the arithmetic itself.
- **AC3** (remove recomputes Sub Total; checkout gated on non-empty) → **State Transition Testing**
  (`present → absent`, including the last-item-removed convergence to the empty state, and the
  re-entrance case of removing an already-absent row) crossed with **Decision Table Testing** for
  the out-of-stock-vs-checkout-availability axis (Q3) and the session-scoping axis (Q7).

## Sub-step 3b — standardized domain → oracle (applied)

Prices are USD, two-decimal-place amounts (`$16.50` observed) — an **ISO 4217** currency domain →
`oracle-generate` invoked. Applied: one grounded condition (`AC2-C4`) using the standard's own
two-decimal rounding convention on a summed multi-item Sub Total, tagged `@oracle:iso4217`. No
other field matches a standardized domain: Item IDs (`EST-1`), Product IDs (`FI-SW-01`) and
Descriptions are project-internal catalog identifiers, not a public standard.

## Sub-step 3c — systematic coverage expansion (applied where triggered, waived elsewhere)

- **List / collection view** — triggered: the cart table is a list of rows. **Empty-list** state is
  `AC2-C1` (already an AC-level requirement, not duplicated as a separate condition). **Sort /
  filter** — not triggered: no sort or filter control was observed on any fetched cart page, and
  a 3-to-4-row cart table is not plausibly sortable UI in this app; waived, with the reason stated
  rather than silently skipped. **Pagination** — not triggered, same reasoning (small, unpaginated
  table observed). **State persistence of cart contents across navigation away-and-back** — IS
  triggered (a shopper commonly browses another category mid-session) → derived as `AC2-C5` below.
- **Entity → full CRUD lifecycle** — triggered on the cart-item entity: **create** (add, AC1),
  **delete** (remove, AC3) are both in this US's slice. **Update** (in-place quantity edit) is
  **not** — per `02-understanding.md` Q2, no editable-quantity control was observed anywhere in the
  captured pages; recorded as a waiver here (`[assumption]`, not a silently dropped CRUD verb) —
  the cart is modeled as add/remove-only for this slice, re-add being the closest thing to an
  "update" (Q1, already `AC1-C2`).
- **Conditional behavior (decision table over variation axes)** — triggered: the out-of-stock ×
  checkout-availability axis (Q3, `AC3-C4`). Role/ownership axis — not triggered, this slice is
  guest-only by design (`00-source.md` dependencies), no role variation exists to cross.
- **Authorization & server-side enforcement** — triggered on the session-scoping axis: cross-session
  cart access/mutation (Q7, `AC3-C5`) is exactly the IDOR-shaped pattern this sub-step names by
  example, applied here to a session boundary rather than a user-account boundary since this US has
  no accounts in scope.
- **Enumerate every list/aggregation view** — not triggered beyond the one cart list already
  covered above; catalog-side listing (category/product pages) is out-of-slice per
  `00-source.md` dependencies. Waived.
- **Sibling collections of a named entity** — not triggered: a cart item is not itself described as
  "a collection of X" carrying an implied child entity with its own sub-collections. Waived.
- **Account & auth features → recovery path** — not triggered: this US is a guest shopping-cart
  capability, not an account/credential feature (sign-in is an out-of-slice dependency, not this
  slice's own subject). Waived, same reasoning as prior campaign runs on non-auth slices.

## Sub-step 3d — knowledge-driven conditions

No `knowledge/index.md` exists for this campaign directory (no team knowledge base was ever
initialized here). Recorded per shared-contract rule 8 (degraded mode): proceeding on the source
alone, nothing invented to compensate.

## Test conditions

- **AC1-C1** `[ep]` — a shopper adds a single item (`EST-1`, "Large Angelfish", `$16.50`) not
  already in the cart → a new row appears with Item ID `EST-1`, Product ID `FI-SW-01`,
  Description "Large Angelfish", List Price `$16.50`, Total Cost `$16.50`.
- **AC1-C2** `[state-transition]` `[assumption]` `@low-confidence` (Q1) — the same item is added a
  second time while already present in the cart → the existing row's Quantity increments (rather
  than a duplicate row being created) and its Total Cost scales to `$33.00` (`$16.50 × 2`).
- **AC2-C1** `[ep]` — nothing has ever been added to the cart → "Your cart is empty." is shown and
  Sub Total is `$0`. (Directly stated by the source, not an inferred default.)
- **AC2-C2** `[ep]` — two distinct items are in the cart (`EST-1` "Large Angelfish" `$16.50` and
  `EST-2` "Small Angelfish" `$16.50`) → Sub Total equals `$33.00` (`$16.50 + $16.50`, computed).
- **AC2-C4** `[ep]` `@oracle:iso4217` `@low-confidence` (Q6) — a Sub Total sum is computed and
  displayed → the result is rounded/displayed to exactly two decimal places, USD convention (no
  observed source price forces a sub-cent rounding case, so this condition asserts the *format*
  invariant rather than a specific rounding tie-break).
- **AC2-C5** `[ep]` `[assumption]` `@low-confidence` — after adding an item, the shopper navigates
  to a different category and back to the cart → the previously added item and Sub Total are still
  present (session-scoped cart persistence).
- **AC3-C1** `[state-transition]` — a cart holds two distinct items; the shopper clicks "Remove" on
  one row → that row disappears and Sub Total decreases by exactly that row's own Total Cost,
  leaving the other row and its own Total Cost unchanged.
- **AC3-C2** `[state-transition]` `[assumption]` (Q5) — the shopper removes the only item in the
  cart → the cart converges to the same empty state as `AC2-C1` ("Your cart is empty.", Sub Total
  `$0`).
- **AC3-C3** `[state-transition]` `[assumption]` `@low-confidence` (Q4) — "Remove" is
  triggered again for a row already removed (stale link / double-submit) → no hard error; the
  removal is idempotent (the item is simply already absent). Not tagged `[req-neg]`: the proposed
  outcome is a no-op, not a refusal/error/denial.
- **AC3-C4** `[decision-table]` `[open]` `@low-confidence` (Q3) — the cart contains an
  item whose `In Stock? = false` (as observed live on `EST-1`) and the shopper reaches "Proceed to
  Checkout" → **proposed default**: checkout remains available (the observed UI never blocked
  adding the item, and backorder/pre-order is a real, common e-commerce pattern); genuinely open,
  human arbitration required before trusting this assertion either way. Not tagged `[req-neg]`:
  the proposed default outcome (checkout still allowed) is itself permissive, not a refusal — the
  negative-shaped alternative is the unconfirmed one.
- **AC3-C5** `[decision-table]` `[req-neg]` `[open]` (Q7) — a second, independent guest session
  attempts to view or mutate the first session's cart (no shared credential, only whatever session
  identifier the app uses) → **proposed default**: refused/not visible (standard session-isolation
  expectation); genuinely open — the exact session-binding mechanism was never independently
  confirmed live (stateless `WebFetch` could not hold or compare two live sessions), human
  arbitration required.

## Journey

| Step | Status |
|---|---|
| 03-design | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) |

## Skill evaluation — `istqb-design`

- **Skill evaluated**: `plugins/qaia-core/skills/istqb-design/SKILL.md`.
- **Input**: `02-understanding.md` above (3 ACs, 7 logged questions).
- **Output**: this file.
- **Verdict**: **CONFORME.**
- **Evidence**: `SKILL.md` line 103's own guardrail flags that a 3c sub-step with no mention at
  all is a defect, specifically citing the "account & auth recovery path" bullet. This run's
  `## Sub-step 3c` section addresses every named bullet explicitly, including that exact bullet —
  correctly marked "not triggered" with a stated reason (a guest shopping-cart capability, not an
  account/credential feature) rather than omitted, and the "state persistence across navigation"
  facet of the list/collection bullet is correctly *triggered* rather than reflexively waived
  alongside its sibling sort/filter/pagination facets, which are separately and honestly waived
  with their own stated reason (no such controls were ever observed on any fetched page). Line 98
  requires 3b/3c/3d to each "appear in the checkpoint with its outcome... never silently absent" —
  all three sub-steps have their own headed section with per-bullet outcomes above. The ISO 4217
  oracle (line 76) correctly triggers only on the currency-arithmetic field, not on the
  project-internal Item/Product IDs — avoiding over-application of an oracle where none grounds it.
- **Modification proposed**: none.
