# Business rules — cart stock gating & price display (OctoPerf Pet Store)

One concern per entry, declarative and testable, provenance mandatory (shared contract rule 5).
Extracted from `eval/skill-eval-campaign-2026-07-29/US-EVAL-009-octoperf-petstore/state/01-extraction.md`,
section "Business rules / constraints found outside the AC list" — rules that do not live in any
AC, which is exactly why they belong here (README "RAG in use", D38 ceiling).

## BR-KB-001 — stock availability does not gate adding an item to the cart

An item whose cart row shows `In Stock? = false` **can still be added to the cart**: the
"Add to Cart" action succeeds and the row is created with its normal Item ID, Product ID,
Description, List Price and Total Cost. Availability is surfaced as a per-row column, not as a
precondition of the add action. Observed concretely on item `EST-1` ("Large Angelfish",
product `FI-SW-01`), whose row displayed `In Stock? = false` while the add succeeded.

**Explicitly unresolved — do not extend this rule to checkout.** Whether an
`In Stock? = false` row blocks or permits "Proceed to Checkout" is `[open]`: no fetched page
states it, and the two candidate policies (allow / block) are both plausible for a real
storefront. The test book's scenario `QAIA-US-EVAL-009-007` carries the "allow" branch as an
explicitly-labelled proposed default awaiting arbitration; this entry does **not** ratify it.

_Provenance: US-EVAL-009, 2026-07-30, decided-by `[open]` — this is an **observed live-UI
behaviour**, not a decision recorded by a named role. The observation is in
`01-extraction.md` ("observed `false` for `EST-1` ... even though 'Add to Cart' succeeded and the
item was added anyway"); the same file states the checkout-gating question "is not stated by any
fetched page", and it is tracked as open point Q3 in `02-understanding.md`._

## BR-KB-002 — cart monetary values are displayed as two-decimal USD with a `$` prefix

Every monetary value rendered by the cart (List Price, per-row Total Cost, Sub Total) is
displayed in US dollars as `$` immediately followed by the amount with **exactly two decimal
places** — e.g. `$16.50`, never `$16.5`, never `16.50 USD`, never a thousands separator variant
that drops the decimals. Any arithmetic assertion on cart totals compares against this format,
and a format deviation is a defect in its own right, independent of whether the numeric value is
correct.

_Provenance: US-EVAL-009, 2026-07-30, decided-by `[open]` — observed live-UI formatting
(`01-extraction.md`: "Prices are shown in **US dollars with a `$` prefix and two decimal
places** (`$16.50`)"). No source states the rounding mode applied when a computed Sub Total would
carry a third decimal; `02-understanding.md` Q6 records that no source price forces such a
tie-break, so **rounding behaviour is not asserted here** and must not be inferred from this
entry._

## Candidate examined and NOT promoted

The third bullet of `01-extraction.md`'s constraints section — "No 'Update Cart' button or
editable quantity field was observed ... how (or whether) it is user-editable after the item is
added is unconfirmed" — is an **absence of observation**, not a declarative testable rule. Per
this skill's guardrail ("Keep entries declarative and testable ... not narrative"), promoting an
unconfirmed absence to a knowledge rule would manufacture a project truth out of a gap in the
capture. It stays an open point in `02-understanding.md`; it is recorded here only so a future
reader knows it was examined and deliberately not promoted.

## Contradiction check performed (rag-build step 2)

Before writing, both entries were checked against every file listed in `index.md`. The base was
empty at initialization, so **no existing statement could be contradicted** — no ⚠ VALIDATION
arbitration was triggered, and none was simulated. Duplicate check: no prior entry covered stock
gating or currency format.
