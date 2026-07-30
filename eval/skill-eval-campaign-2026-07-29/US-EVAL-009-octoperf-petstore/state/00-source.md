---
stepsCompleted: [00-ingest]
lastStep: 00-ingest
lastSaved: 2026-07-30
---

# 00-source — US-EVAL-009

- **Source type**: live public application (bring-your-own target, per
  `docs/SKILL-EVAL-CAMPAIGN-PROMPT.md`), captured via `WebFetch` — not a written ticket.
- **Designated target**: `OctoPerf Pet Store` — `docs/DEMO-TARGETS.md` row: "OctoPerf Pet Store |
  ❌ (self-host) | ✅ (JPetStore-style) | ❌ (no API) | ❌ (no mobile) | ❌ (no security) | demo
  forbids [perf] — self-host a JPetStore clone for a real k6 run | ❌ (no a11y) | ❌ (no visual)".
  Explore-only per the campaign's golden rule.
- **Capture date**: 2026-07-30.

## ⚠ Golden-rule limitation — recorded explicitly, not worked around

`docs/DEMO-TARGETS.md` names this target *specifically* as the load-testing (k6/OctoPerf) showcase
— "demo forbids [perf] — self-host a JPetStore clone for a real k6 run" — meaning **performance
is the natural fit for this target's own catalog entry, and it is exactly the capability this run
must NOT exercise**, because `petstore.octoperf.com` is a shared public demo, not self-hosted in
this session. Consequently:
- **No `perf-check`** is run against `petstore.octoperf.com` in this session, under any framing
  (not "just a light smoke run", not "read-only"). The catalog entry's own remedy — self-host a
  JPetStore clone (Docker/VPS) — is out of scope for this evaluation run.
- **No `security-surface`** either — the row marks Security ❌, and the shared golden rule in
  `docs/DEMO-TARGETS.md` line 3 forbids security scans against any non-self-hosted shared demo
  regardless of the target's own row.
- This is stated here, at ingestion, rather than silently discovered at step 8 — so the whole
  7-step design phase is scoped toward a UI functional flow from the start, not perf/security.

## What was actually fetched

- `WebFetch https://petstore.octoperf.com/actions/Catalog.action` → succeeded. Top nav: logo link,
  cart access, "Sign In", a help link ("?"). Five category tiles: Fish ("Saltwater, Freshwater"),
  Dogs ("Various Breeds"), Cats ("Various Breeds, Exotic Varieties"), Reptiles ("Lizards, Turtles,
  Snakes"), Birds ("Exotic Varieties"). No search box visible. Footer: "Elevate you load-testing
  with OctoPerf!", "Hosted by https://octoperf.com | Powered by www.mybatis.org".
- `WebFetch https://petstore.octoperf.com/actions/Account.action?signonForm=` → succeeded. Sign-in
  form fields **"Username"** and **"Password"**; a **"Register Now!"** link to account creation; no
  error message visible on the bare form.
- `WebFetch https://petstore.octoperf.com/actions/Catalog.action?viewCategory=&categoryId=FISH` →
  succeeded. Four products listed: `FI-SW-01` Angelfish, `FI-SW-02` Tiger Shark, `FI-FW-01` Koi,
  `FI-FW-02` Goldfish. No price shown at this level, no pagination controls.
- `WebFetch https://petstore.octoperf.com/actions/Catalog.action?viewProduct=&productId=FI-SW-01` →
  succeeded. Two items under product `FI-SW-01`: `EST-1` "Large Angelfish" $16.50, `EST-2` "Small
  Angelfish" $16.50. Columns: Item ID, Product ID, Description, List Price. Each row has an
  "Add to Cart" action. No in-stock status shown at this level.
- `WebFetch https://petstore.octoperf.com/actions/Cart.action?viewCart=` (empty session) →
  succeeded. Columns: "Item ID", "Product ID", "Description", "In Stock?", "Quantity", "List
  Price", "Total Cost". Empty state text: **"Your cart is empty."** Subtotal line: **"Sub Total:
  $0"**. "Return to Main Menu" link present.
- `WebFetch https://petstore.octoperf.com/actions/Cart.action?addItemToCart=&workingItemId=EST-1`
  → succeeded. Cart row: Item ID `EST-1`, Product ID `FI-SW-01`, Description "Large Angelfish",
  **In Stock?: `false`**, List Price `$16.50`, Total Cost `$16.50`. Subtotal: **"Sub Total:
  $16.50"**. Buttons visible: **"Remove"** (per row) and **"Proceed to Checkout"**. No "Update
  Cart" and no "Continue Shopping" button observed on this page.

## Captured text (faithful, not paraphrased)

> Cart table columns (verbatim): "Item ID", "Product ID", "Description", "In Stock?", "Quantity",
> "List Price", "Total Cost". Empty-cart text: "Your cart is empty." Subtotal label: "Sub Total:
> $<amount>". After adding `EST-1` once: row shows In Stock? = `false`, List Price = `$16.50`,
> Total Cost = `$16.50`, Subtotal = `$16.50`. Buttons on a non-empty cart: "Remove", "Proceed to
> Checkout".
>
> (Sources: `WebFetch` on `petstore.octoperf.com/actions/Catalog.action`,
> `.../Account.action?signonForm=`, `.../Catalog.action?viewCategory=&categoryId=FISH`,
> `.../Catalog.action?viewProduct=&productId=FI-SW-01`, `.../Cart.action?viewCart=`, and
> `.../Cart.action?addItemToCart=&workingItemId=EST-1`, all 2026-07-30.)

## Not confirmed by any source found

- Whether adding the **same item a second time** increments the existing row's `Quantity` or
  creates a second row — a repeat `WebFetch` of the add-to-cart URL returned the tool's 15-minute
  cache of the first response (no session-cookie persistence across separate stateless `WebFetch`
  calls), so this could not be reliably observed live. Recorded as a genuine tooling limitation,
  not guessed past.
- Whether a **quantity input box** exists anywhere in the cart UI to let a user change quantity
  directly (the fetched cart table has a "Quantity" column header but no editable control was
  observed, and no "Update Cart" button was seen) — plausible that JPetStore 6's cart is
  add/remove-only with no in-place quantity edit, but not independently confirmed by exploring
  every state.
- Whether an item whose `In Stock? = false` (observed on `EST-1`/"Large Angelfish") can actually
  proceed through "Proceed to Checkout", or is blocked/warned at that step — checkout itself was
  not explored (would require a signed-in session and real form submission, out of scope for a
  read-only capture).
- The full sign-in error message text for a wrong username/password (the bare form was captured,
  not a submitted attempt).
- Whether "Register Now!" account creation requires an email/valid-format check, or any other
  field validation.
- Behavior when removing the last item from the cart (does the empty-cart message reappear, is
  there a confirmation step).

## Not fabricated here

Every point above is carried forward as an open point to `need-understanding`, never guessed.

## Redaction

None needed — no PII in the fetched public catalog/cart pages; no credentials were entered or
observed (the sign-in form was captured empty, never submitted).

## Dependencies (out-of-slice)

- Sign-in / account creation (`Account.action?signonForm=`, "Register Now!") — a separate US;
  this slice treats "add to cart / view cart / remove item" as available to a guest session
  (JPetStore 6's classic flow only requires sign-in at checkout), not gated behind login.
- Checkout / order placement (billing address, payment, order confirmation) — a separate US;
  "Proceed to Checkout" is this slice's boundary, not its content.
- Catalog browsing / category and product listing (search, category navigation) — a separate US;
  this slice assumes a product/item is already located and starts at "Add to Cart".

## Journey

| Step | Status |
|---|---|
| 00-ingest | done — gates checked (not empty, is a testable capability — real e-commerce cart UI, no abuse/illegality, no PII to redact); US-ID confirmed non-interactively: `US-EVAL-009` |

## Skill evaluation — `us-ingest`

- **Skill evaluated**: `plugins/qaia-core/skills/us-ingest/SKILL.md`.
- **Input**: a live UI-only e-commerce demo target (`docs/DEMO-TARGETS.md` OctoPerf Pet Store
  entry), reachable and fully JS-optional (server-rendered JSP pages), unlike several prior
  campaign targets whose designated URL 404'd or was a JS shell.
- **Output**: this file.
- **Verdict**: **CONFORME.**
- **Evidence**: every `WebFetch` call targeted only the one designated host
  (`petstore.octoperf.com`), per `SKILL.md` line 26 ("Never fetch any URL other than the one the
  user designated") — no `WebSearch` was used to *ground any AC* (the one `WebSearch` call in this
  run's transcript was used only to locate the designated target's own live URL from
  `docs/DEMO-TARGETS.md`'s bare catalog-entry name, before any `us-ingest` step began — the same
  discovery pattern every prior campaign run has used to resolve a catalog row into a fetchable
  URL, not a step-1 substitution for missing content). The "not confirmed" section above honestly
  records a real tooling limitation (stateless `WebFetch` cannot hold a session cookie across
  calls) rather than fabricating an observed quantity-increment behavior — consistent with step 2's
  scale/decomposition and step 3's redaction gates both being correctly not triggered (no PII, no
  bundled backlog).
- **Modification proposed**: none.
