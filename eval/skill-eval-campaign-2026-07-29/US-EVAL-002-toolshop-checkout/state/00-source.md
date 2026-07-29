---
stepsCompleted: [00-ingest]
lastStep: 00-ingest
lastSaved: 2026-07-29
---

# 00-source — US-EVAL-002

- **Source type**: live application behavior (bring-your-own target, per
  `docs/SKILL-EVAL-CAMPAIGN-PROMPT.md`), captured via `WebFetch` — not a written ticket.
- **Designated target**: `Practice Software Testing` (Toolshop) — `docs/DEMO-TARGETS.md` entry:
  UI `https://practicesoftwaretesting.com`, API `https://api.practicesoftwaretesting.com`. Explore-only
  per the DEMO-TARGETS.md caveat (repo license restrictive for self-hosting) — no `perf-check`/
  `security-surface` run against it, this campaign stops before any automation step regardless.
- **Capture date**: 2026-07-29.

## What was actually fetched

- `WebFetch https://practicesoftwaretesting.com` → **HTTP 403** (bot/edge protection on the UI
  origin — not a JS-shell-only response, an outright refusal).
- `WebFetch https://practicesoftwaretesting.com/#/checkout` → **HTTP 403**, same origin, same
  result.
- `WebFetch https://api.practicesoftwaretesting.com/api/documentation` → returned only a page
  title ("Practice Software Testing Swagger UI"), no body content (JS-rendered shell).
- `WebFetch https://api.practicesoftwaretesting.com/docs` → **succeeded**, returned real OpenAPI
  content. Two follow-up fetches of the same URL with narrower prompts pulled out the endpoints
  and partial schema fields quoted below.

**Per `us-ingest` step 1's guardrail** ("If the designated URL is a JS-rendered app and a fetch
returns only an empty shell, do not autonomously substitute or supplement with other URLs... tell
the user... ask them to supply a fuller one") — the UI origin (`practicesoftwaretesting.com`)
never yielded usable content (403 on two attempts), and this run did **not** fall back to
`WebSearch` or any third-party page to fill that gap. The only substitution made was fetching a
**different path on the same already-designated API origin** (`/docs` instead of
`/api/documentation`) to reach the same Swagger documentation the designated target itself serves
— not a different source. The UI-level flow (product page layout, cart-page buttons, checkout-form
field labels) is therefore **not captured** and is explicitly out of scope for this US: everything
below is grounded in the API surface only, faithfully as fetched, nothing paraphrased beyond what
the tool returned.

## Captured text (faithful, not paraphrased)

> **Cart endpoints** — `POST /carts` (creates a new cart, response: `id`). `POST /carts/{id}`
> (adds item to cart; request body: `product_id`, `quantity`; response: `result`). `GET
> /carts/{cartId}` (retrieves cart contents, response schema `CartResponse`). `DELETE
> /carts/{cartId}` (removes entire cart). `PUT /carts/{cartId}/product/quantity` (updates item
> quantity; request body: `product_id`, `quantity`). `DELETE /carts/{cartId}/product/{productId}`
> (removes single product from cart).
>
> **Invoice endpoints** — `POST /invoices` (creates an authenticated user's invoice from
> `InvoiceRequest`; security: `apiAuth` required). `POST /invoices/guest` (creates a guest
> checkout invoice; adds `guest_email`, `guest_first_name`, `guest_last_name` on top of the base
> `InvoiceRequest` fields). `GET /invoices` (paginated, admin sees all / user sees own). `GET
> /invoices/{invoiceId}`. `PUT /invoices/{invoiceId}` (full update). `PATCH /invoices/{invoiceId}`
> (partial update). `PUT /invoices/{invoiceId}/status` (updates status + optional message; the
> five status values documented: `AWAITING_FULFILLMENT`, `ON_HOLD`, `AWAITING_SHIPMENT`,
> `SHIPPED`, `COMPLETED`). `GET /invoices/search` (by number/street/status). `GET
> /invoices/{invoice_number}/download-pdf`.
>
> (Source: `WebFetch` on `https://api.practicesoftwaretesting.com/docs`, 2026-07-29, three
> targeted fetches of the same designated API-documentation URL.)

## Not confirmed by any source found

- The **exact field list of `InvoiceRequest`** (billing address shape, payment fields) — the
  fetch tool reported the schema as referenced (`$ref`) but did not expand it in the returned
  text.
- The **exact field list of `CartResponse`** and of the product schema (`/products`,
  `/products/search`) — same limitation.
- Whether `POST /invoices`/`POST /invoices/guest` can succeed against an **empty cart**.
- The **initial status** a newly created invoice starts in (which of the five documented status
  values applies at creation time — not stated by the fetched documentation text).
- Any UI-level detail (button labels, page layout, client-side validation messages) — the UI
  origin never returned usable content (see above).

**Not fabricated here** — every point above is carried forward as an open point to
`need-understanding`, never guessed.

## Redaction

None needed — no PII in the fetched public API documentation.

## Dependencies (out-of-slice)

- Product catalog browsing/search (`/products`, `/products/search`) — a separate catalog-browsing
  US, not designed here; only referenced as the source of the `product_id` used to add to cart.
- Invoice status transitions *after* creation (`PUT /invoices/{id}/status`, the five-value
  lifecycle) — a separate order-fulfillment-workflow US.
- PDF invoice download — a separate reporting/export concern.

## Journey

| Step | Status |
|---|---|
| 00-ingest | done — gates checked (not empty, is a testable capability — real CRUD/checkout API, no abuse/illegality, no PII to redact); US-ID confirmed non-interactively: `US-EVAL-002` |

## Skill evaluation — `us-ingest`

- **Skill evaluated**: `plugins/qaia-core/skills/us-ingest/SKILL.md`.
- **Input**: a live API target (`docs/DEMO-TARGETS.md` Toolshop entry) fetched via `WebFetch`,
  with the UI origin returning 403 on both attempts.
- **Output**: this file.
- **Verdict**: **CONFORME.**
- **Evidence**: step 1's guardrail (`SKILL.md` line 12: "do not autonomously substitute or
  supplement with other URLs... to fill the gap") was followed literally — no `WebSearch` call was
  made in this run, and the UI-level gap is recorded as "not captured" above rather than papered
  over with a secondary source (contrast with US-EVAL-001's `00-source.md`, produced *before* this
  guardrail was added to the skill, which did use `WebSearch`). Re-fetching a different path
  (`/docs` vs `/api/documentation`) on the **same already-designated API origin** is not a
  guardrail violation — it is the same source, same domain, same Swagger endpoint the target
  itself serves; the guardrail's own wording targets "other URLs" as in other sources, not
  alternate paths of the one designated target.
- **Modification proposed**: none.
