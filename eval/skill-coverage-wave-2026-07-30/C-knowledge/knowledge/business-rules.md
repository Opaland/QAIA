# Business rules — cart arithmetic & checkout availability

One concern per entry, declarative and testable, provenance mandatory (shared contract rule 5).
Scope: OctoPerf Pet Store (JPetStore-style) shopping cart. Only statements that a source
**actually establishes** are rules here; everything still `[open]`/`[assumption]` in
`02-understanding.md` is listed at the bottom as *not yet a rule* and stays out of the index'd
rule body (a rule that is really an assumption is exactly the "converged, confident, wrong"
failure mode).

## BR-KB-001 — a cart row's Total Cost is List Price × Quantity
Each cart row displays Item ID, Product ID, Description, List Price and a **Total Cost equal to
`List Price × Quantity`** for that row. A row whose Total Cost differs from that product is a
defect, not a rounding preference.
_Provenance: US-EVAL-009 AC1, 2026-07-30, decided-by observed-behaviour (live capture
`state/00-source.md` → `state/01-extraction.md` line 22-24)._

## BR-KB-002 — Sub Total is the sum of the rows currently in the cart
The cart's **Sub Total equals the sum of every row's Total Cost currently present**. Removing a
row recomputes the Sub Total by subtracting exactly that row's Total Cost — never the whole prior
Sub Total, never a stale cached value.
_Provenance: US-EVAL-009 AC2 + AC3, 2026-07-30, decided-by observed-behaviour
(`state/01-extraction.md` lines 25-28; cross-AC reading confirmed in `state/02-understanding.md`
"Cross-AC interaction pass")._

## BR-KB-003 — the empty cart has a defined shape
An empty cart displays the literal text **"Your cart is empty."** and a **Sub Total of `$0`**.
_Provenance: US-EVAL-009 AC2, 2026-07-30, decided-by observed-behaviour
(`state/01-extraction.md` line 26)._

## BR-KB-004 — money is displayed as USD, `$` prefix, exactly two decimals
Every monetary value in the cart (List Price, Total Cost, Sub Total) is rendered in **US dollars
with a `$` prefix and exactly two decimal places** (e.g. `$16.50`). Any arithmetic assertion on
cart values asserts against that format, not against a bare number.
_Provenance: US-EVAL-009, 2026-07-30, decided-by observed-behaviour (`state/01-extraction.md`
lines 35-36, "Business rules / constraints found outside the AC list"). Standardized domain:
ISO 4217 USD, 2 minor units._

## BR-KB-005 — "Proceed to Checkout" is available whenever the cart is non-empty
The **"Proceed to Checkout" action is available for any non-empty cart**. Emptiness is the only
condition confirmed to govern its availability.
_Provenance: US-EVAL-009 AC3, 2026-07-30, decided-by observed-behaviour
(`state/01-extraction.md` lines 27-28). Deliberately silent on the out-of-stock axis — see
NOT-A-RULE-1._

## BR-KB-006 — an out-of-stock item can still be added to the cart
An item whose **`In Stock?` column reads `false` can still be added to the cart**: "Add to Cart"
succeeds and the row appears. Observed on `EST-1` ("Large Angelfish").
_Provenance: US-EVAL-009, 2026-07-30, decided-by observed-behaviour (`state/01-extraction.md`
lines 32-34). Scope limited to **adding** — the checkout side is NOT-A-RULE-1._

---

## Not yet rules (do not retrieve as truth)

These are recorded so a later `rag-build` pass does not "rediscover" them as rules. They carry the
classification given by `need-understanding` in `state/02-understanding.md`; promoting any of them
requires a human decision (⚠ VALIDATION — **pending-validation**, no human in this campaign run).

| ID | Statement under question | Classification (source) |
|---|---|---|
| NOT-A-RULE-1 | Does `In Stock? = false` block "Proceed to Checkout"? | `[open]` (Q3) — genuine business-policy fork, backorder is an equally common pattern |
| NOT-A-RULE-2 | Is a guest cart strictly isolated from another guest session? | `[open]` (Q7) — access boundary, never defaulted |
| NOT-A-RULE-3 | Repeat add of the same item increments the row's Quantity | `[assumption]` `@low-confidence` (Q1) |
| NOT-A-RULE-4 | The cart is add/remove-only, no in-place quantity edit | `[assumption]` (Q2) |
| NOT-A-RULE-5 | Removing an already-removed row is an idempotent no-op | `[assumption]` `@low-confidence` (Q4) |
| NOT-A-RULE-6 | Sub-cent Sub Total sums round half-up at two decimals | `[assumption]` `@low-confidence` (Q6) |
