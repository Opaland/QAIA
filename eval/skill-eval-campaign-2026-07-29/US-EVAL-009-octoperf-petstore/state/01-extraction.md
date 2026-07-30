---
stepsCompleted: [00-ingest, 01-review]
lastStep: 01-review
lastSaved: 2026-07-30
---

# 01-extraction — US-EVAL-009

## Story

**As a** guest shopper browsing the JPetStore catalog,
**I want** to add a specific item to my cart, see it reflected with the correct line total and
subtotal, and remove it if I change my mind,
**so that** I can build up an order before proceeding to checkout.

*(`[reconstructed]` — the fetched pages describe a cart UI and its controls, not a user story;
per `us-review` step 1, "no story phrasing found but a real capability is described → reconstruct
it and mark it `[reconstructed]`".)*

## Acceptance criteria (numbered, stable — AC1..AC3)

- **AC1.** From an item's product page, clicking "Add to Cart" for a given item ID adds that item
  to the cart, and the cart shows a row with the correct Item ID, Product ID, Description, List
  Price, and a Total Cost equal to `List Price × Quantity`.
- **AC2.** The cart's "Sub Total" equals the sum of every row's Total Cost currently in the cart;
  an empty cart shows "Your cart is empty." and a Sub Total of `$0`.
- **AC3.** Clicking "Remove" on a cart row removes that item from the cart and recomputes the
  Sub Total accordingly; "Proceed to Checkout" is available whenever the cart is non-empty.

## Business rules / constraints found outside the AC list

- The cart table exposes an **"In Stock?"** column per row — observed `false` for `EST-1` ("Large
  Angelfish") even though "Add to Cart" succeeded and the item was added anyway. Whether this is
  purely informational or actually gates "Proceed to Checkout" is not stated by any fetched page.
- Prices are shown in **US dollars with a `$` prefix and two decimal places** (`$16.50`) —
  currency/format worth making explicit for any arithmetic assertion.
- No "Update Cart" button or editable quantity field was observed on the one non-empty cart state
  captured — "Quantity" appears as a column header, but how (or whether) it is user-editable after
  the item is added is unconfirmed.

## Referenced artifacts not analyzed

- The checkout flow itself (billing/shipping form, order confirmation) — not fetched; out of this
  slice's boundary (`00-source.md` dependencies).
- The sign-in and "Register Now!" account-creation forms — fetched only as bare, unsubmitted forms;
  their validation/error behavior is not analyzed here.
- Category/product browsing beyond the Fish category and the one `FI-SW-01` product page — used
  only to reach a real item ID (`EST-1`), not analyzed as its own capability.

## Present but not classifiable

- None.

## What was NOT found

- No formal AC numbering in the source (a live UI, not a written ticket) — numbering above is this
  skill's own reconstruction.
- No confirmed behavior for: adding the **same item twice** (increment existing row vs. new row —
  a real `WebFetch` session-state limitation, see `00-source.md`), an **editable quantity**
  mechanism, whether an **out-of-stock** (`In Stock? = false`) item can reach checkout, the
  **sign-in error** message text, and **empty-cart-after-last-remove** behavior — all carried to
  `need-understanding` as open points, none invented here.

## Journey

| Step | Status |
|---|---|
| 00-ingest | done |
| 01-review | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run, no human reviewer at this micro-step; only the pre-automation gate is a hard human stop per the campaign prompt) |

## Skill evaluation — `us-review`

- **Skill evaluated**: `plugins/qaia-core/skills/us-review/SKILL.md`.
- **Input**: `00-source.md` above (live UI capture, no story phrasing, no AC numbering, several
  observed-but-unconfirmed behaviors already flagged: repeat add-to-cart, out-of-stock gating).
- **Output**: this file.
- **Verdict**: **CONFORME.**
- **Evidence**: `SKILL.md` line 13 requires that when no story is present but a real capability is
  described, it be "reconstruct[ed]... mark[ed] `[reconstructed]`" — done verbatim in the Story
  section above. Step 2's "show the diff mentality... explicitly list what you did NOT find" (line
  18) is satisfied by the "What was NOT found" section, which lists both structural absences (no
  AC numbering) and content absences (repeat-add behavior, editable quantity, out-of-stock
  checkout gating, sign-in error text, empty-cart-after-remove) without inventing any of them here
  — correctly deferred to `need-understanding` per line 24 ("resolving it is the next skill's job,
  with the user").
- **Modification proposed**: none.
