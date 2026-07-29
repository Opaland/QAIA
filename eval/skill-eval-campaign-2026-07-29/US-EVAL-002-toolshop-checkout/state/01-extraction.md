---
stepsCompleted: [00-ingest, 01-review]
lastStep: 01-review
lastSaved: 2026-07-29
---

# 01-extraction — US-EVAL-002

## Story

**As a** Toolshop customer (signed in or guest),
**I want** to add a product to my cart and complete checkout by creating an order (invoice),
**so that** my selected products are purchased and I receive a confirmed order.

*(`[reconstructed]` — the API documentation describes endpoints and fields, not a user story;
per `us-review` step 1, "no story phrasing found but a real capability is described →
reconstruct it and mark it `[reconstructed]`".)*

## Acceptance criteria (numbered, stable — AC1..AC4)

- **AC1.** A customer adds a product to their cart (`product_id` + `quantity`) and the cart
  reflects the added item.
- **AC2.** A **signed-in, authenticated** customer completes checkout by creating an invoice from
  their cart (`POST /invoices`, requires `apiAuth`).
- **AC3.** A **guest** (unauthenticated) customer completes checkout by creating an invoice via
  `POST /invoices/guest`, supplying `guest_email`, `guest_first_name`, `guest_last_name` in
  addition to the base invoice fields.
- **AC4.** A newly created invoice is assigned an initial status drawn from the documented status
  set (`AWAITING_FULFILLMENT`, `ON_HOLD`, `AWAITING_SHIPMENT`, `SHIPPED`, `COMPLETED`). *(Exact
  initial value not confirmed by any source found — see open point below.)*

## Business rules / constraints found outside the AC list

- `PUT /carts/{cartId}/product/quantity` and `DELETE /carts/{cartId}/product/{productId}` exist
  as pre-checkout cart-editing operations — out of scope for this US (cart *creation and add* is
  the slice; editing/removal is a sibling capability, noted as a dependency).
- Invoice status can be changed post-creation via `PUT /invoices/{invoiceId}/status` — a separate
  fulfillment-workflow concern, not this US's checkout moment.
- `POST /invoices` requires `apiAuth`; `POST /invoices/guest` is documented as a distinct endpoint
  for the unauthenticated path — the two are structurally parallel but not the same operation.

## Referenced artifacts not analyzed

- The full OpenAPI/Swagger JSON document itself (only the text the fetch tool surfaced was read;
  the complete schema for `InvoiceRequest`, `CartResponse`, and the product model was not fully
  expanded by the tool) — listed as "not analyzed" rather than silently assumed complete.

## Present but not classifiable

- None.

## What was NOT found

- No formal AC numbering in the source (an API doc, not a written ticket) — numbering above is
  this skill's own reconstruction.
- No UI-level behavior (button labels, form field names as shown to a human, client-side
  validation copy) — the UI origin returned HTTP 403 on every fetch attempt (see `00-source.md`).
- No stated behavior for: checkout against an **empty cart**, an **invalid `product_id`**, an
  **invalid quantity** (zero/negative), a **guest checkout missing a required guest field**, or
  the **initial invoice status** — all carried to `need-understanding` as open points, none
  invented here.

## Journey

| Step | Status |
|---|---|
| 00-ingest | done |
| 01-review | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run, no human reviewer at this micro-step; only the pre-automation gate is a hard human stop per the campaign prompt) |

## Skill evaluation — `us-review`

- **Skill evaluated**: `plugins/qaia-core/skills/us-review/SKILL.md`.
- **Input**: `00-source.md` above (API documentation text, no story phrasing, no AC numbering).
- **Output**: this file.
- **Verdict**: **CONFORME.**
- **Evidence**: `SKILL.md` line 13 requires that when no story is present but a real capability is
  described, it be "reconstruct[ed]... mark[ed] `[reconstructed]`" — done verbatim in the Story
  section above, distinct from US-EVAL-001's own case (no story *and* not classifiable as one
  without reconstruction license — that file used "not expressed in the source" instead, which is
  the other branch of the same line, correctly a different choice because that source truly had no
  describable capability shape until AC extraction). Step 2's "show the diff mentality... explicitly
  list what you did NOT find" (line 18) is satisfied by the "What was NOT found" section, which
  lists both structural absences (no AC numbering) and content absences (empty-cart, invalid
  product_id, invalid quantity, missing guest field, initial status) without inventing defaults for
  any of them here — resolution is correctly deferred to `need-understanding` per the skill's own
  guardrail (line 24: "resolving it is the next skill's job, with the user").
- **Modification proposed**: none.
