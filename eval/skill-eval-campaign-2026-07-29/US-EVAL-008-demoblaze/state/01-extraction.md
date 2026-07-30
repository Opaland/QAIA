# 01-extraction — US-EVAL-008

## Story `[reconstructed]`

**As a** DemoBlaze shopper (guest or logged-in),
**I want** to add a product to my cart from its product page, review my cart with an accurate
running total, remove an item I no longer want, and place an order by providing my name and
credit card,
**so that** I can complete a purchase and receive a confirmation with an order id — without the
storefront silently dropping an error, mis-summing my total, or accepting a payment form it never
actually validates.

*(Not expressed as a story in the source — this is a demo storefront, not a ticket. Reconstructed
from the three captured pages' own linked JS + served modal markup, per `us-review` step 1's
`[reconstructed]` license for a real capability with no story phrasing.)*

## Acceptance criteria (numbered, stable — AC1..AC9)

- **AC1.** From a product detail page, clicking "Add to cart" sends `POST /addtocart` with the
  product id, a freshly generated cart-item id, and `flag: true`/`cookie: <token>` when a
  `tokenp_` session-token cookie is present, else `flag: false`/`cookie: <raw document.cookie>`.
- **AC2.** Logged-in add-to-cart (`flag: true`): the success handler inspects the response's
  `errorMessage` and shows one of four distinct alerts — token expired, token malformed, flag
  incorrect, or else `"Product added."` (trailing period).
- **AC3.** Guest add-to-cart (`flag: false`): the success handler **always** alerts
  `"Product added"` (no trailing period) regardless of the response's `errorMessage` — an
  API-returned error is never surfaced to a guest.
- **AC4.** On the cart page, the table is populated via `POST /viewcart` followed by one
  `POST /view` per item (fetched by `prod_id`); each row shows image, title, price, and a
  "Delete" link; the running total is the integer sum (`parseInt` per item) of the fetched prices,
  displayed in two places (`#totalp` bare number, `#totalm` "Total: "-prefixed), each updated
  incrementally as every per-item `/view` call resolves (not once at the end).
- **AC5.** Clicking "Delete" on a cart row calls `POST /deleteitem` with that row's cart-item id,
  then reloads the page — no confirmation prompt before the delete request fires.
- **AC6.** The "Place Order" modal exposes six fields (Name, Country, City, Credit card, Month,
  Year) plus a Total label and an empty inline error slot, but `purchaseOrder()` only reads and
  validates Name and Credit card — Country, City, Month, Year are never read, validated, or
  included in the confirmation dialog by any code path in the captured source.
- **AC7.** Submitting with Name or Credit card empty shows `"Please fill out Name and
  Creditcard."` and does nothing else — cart untouched, no order id, modal stays open.
- **AC8.** Submitting with both Name and Credit card non-empty (any string — no format/Luhn/expiry
  check) immediately generates a random order id, fires `POST /deletecart` for the current cart
  owner, and shows a success dialog with the Id, the page's current in-memory total as Amount, the
  raw entered card number, the entered Name, and the client-side current date — the success
  dialog is not chained to (does not await) `deletecart`'s own response.
- **AC9.** Confirming the success dialog redirects to `index.html`.

## Business rules / constraints found outside the AC list

- The `#errors` label in the order modal's markup is never populated by any read code path
  (`purchaseOrder()`'s one validation failure uses a plain `alert(...)`, not this element) —
  present in the DOM but appears to be dead UI; not confirmed further (out of slice — would
  require exercising every code path, not just reading the source).
- `total` (the cart page's running-sum variable) is computed once at page load from the fetched
  cart contents and is **not re-fetched** at the moment "Purchase" is clicked — the Amount shown
  in the confirmation dialog reflects the cart as of page load, not necessarily the server's
  current state at submission time.
- The guest-path asymmetry (AC3 vs AC2) and the four unread modal fields (AC6) are the two most
  test-worthy business-rule gaps found outside the literal AC list — both are structural
  properties of the captured code, not inferred behavior.

## Referenced artifacts not analyzed

- `js/index.js`'s catalog listing/pagination/category-filter logic (`/entries`, `/pagination`,
  `/bycat`) — out-of-slice, see `00-source.md` dependencies (a separate "browse catalog" US-slice).
- `logIn()`/`register()` (all three files) — out-of-slice (a separate "auth" US-slice);
  referenced here only for how the `tokenp_` cookie's presence/absence changes AC1-AC4's request
  shape.
- `config.json` (can override `API_URL`/`HLS_URL`) — fetched by all three pages but its content
  was not read in this capture; not analyzed.
- The demo's product-video (`videojs`/HLS) modal — present in all three pages' JS, unrelated to
  the cart/checkout flow, not analyzed.

## Present but not classifiable

- None.

## What was NOT found

- Any live API response shape (`errorMessage` values beyond the three named literals, exact
  `/view`/`/viewcart` JSON schema) — no write/read request was actually sent against the shared
  demo's backend in this capture (see `00-source.md`'s capture-method note); carried to
  `need-understanding` as a named gap, not invented here.
- Whether any DemoBlaze product ever carries a non-integer price (would change AC4's `parseInt`
  truncation from a theoretical to a confirmed rounding defect) — not probed (would require
  enumerating the full catalog, out of slice for this cart/checkout-scoped capture).

## Journey

| Step | Status |
|---|---|
| 00-ingest | done |
| 01-review | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) |

## Skill evaluation — `us-review` (`plugins/qaia-core/skills/us-review/SKILL.md`)

**Verdict: CONFORME.**

**Evidence**: Step 1 (line 13) requires marking a reconstructed story `[reconstructed]` when the
source has no story phrasing — done in the "Story" heading above. Step 1's AC numbering (line 14)
is stable (`AC1`..`AC9`), matching the guardrail on line 25 ("every AC gets a stable number
here... never renumber after validation"). Step 2 (line 18) requires explicitly listing what was
NOT found — done in its own section, and the "thin US" carve-out on the same line correctly does
not fire here (this is a real, richly-specified capability — three working pages with literal,
readable JS behind them — not a non-spec). No deviation found. **Modification proposed: none.**
