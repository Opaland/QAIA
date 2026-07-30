# 00-source — US-EVAL-008

- **Source type**: live public demo, **primary source** (the site's own served HTML + linked
  JavaScript, read directly — not a blog/tutorial summary of "how DemoBlaze's cart works"), per
  `docs/SKILL-EVAL-CAMPAIGN-PROMPT.md`'s "explore freely on public demos" allowance. Target:
  **DemoBlaze** (`docs/DEMO-TARGETS.md` row: UI e-commerce ✅, API ⚠ undocumented, Self-host ❌,
  Security ❌, Perf "demo forbids") — chosen because it is a structurally different shape from
  every prior campaign run (`US-EVAL-001`..`007`): a client-driven SPA whose business rules
  (cart totals, order validation) live almost entirely in **served JavaScript**, not in HTML markup
  or server-rendered content, and it exercises the "e-commerce cart/checkout" business shape none
  of the prior seven runs has covered. Golden rule respected: DemoBlaze is a **shared public demo**
  (catalog row: Security ❌, Perf "demo forbids") — no `perf-check`/`security-surface` run against
  it anywhere in this campaign run; step 8 is scoped to `automate` (E2E) only, or "not applicable"
  for perf/security, per the campaign brief for this target.
- **Capture method**: direct unauthenticated `GET` (via `curl --compressed`, one request per
  resource, no scan/load pattern — golden rule respected) of the pages and JS files that implement
  the "add to cart → view cart → place order" flow. Not scraped beyond what these pages themselves
  link to. **No account was created, no order was actually submitted, no write request
  (`POST /addtocart`, `POST /login`, `POST /signup`, `POST /deletecart`) was sent** — every fact
  below is read from the **served source code itself** (the client-side JS that *would* build
  those requests), never from executing them against the shared demo's backend, which stays
  inside "explore," not a write/load pattern against shared infrastructure.
- **Capture date**: 2026-07-30.
- **Pages/files read (primary source, cited per fact below)**:
  - `GET https://www.demoblaze.com/index.html` → links `GET https://www.demoblaze.com/js/index.js`
  - `GET https://www.demoblaze.com/prod.html` → links `GET https://www.demoblaze.com/js/prod.js`
  - `GET https://www.demoblaze.com/cart.html` → links `GET https://www.demoblaze.com/js/cart.js`
  - `cart.html`'s own served HTML, lines ~588-635 (the `#orderModal` markup)

- **Captured facts (faithful, not paraphrased into stronger claims than the source supports)**:

  > `js/index.js` and `js/prod.js` and `js/cart.js` all declare
  > `var API_URL = 'https://api.demoblaze.com';` (overridable by a fetched `config.json`, not
  > inspected further — out of slice) — confirms the catalog's "API ⚠ undocumented" row: a real,
  > callable REST backend exists, reachable directly, but with no published Swagger/OpenAPI spec
  > found linked from any of these three pages.
  >
  > **`prod.js` — `addToCart(idp)`** (product detail page, literal code):
  > ```
  > function addToCart(idp) {
  >   var token = getCookie("tokenp_");
  >   if (token.length > 0) {
  >     $.ajax({ type:'POST', url: API_URL + '/addtocart',
  >       data: JSON.stringify({ "id": guid(), "cookie": token, "prod_id": idp, "flag": true }),
  >       success: function (data) {
  >         if (data.errorMessage == "Token has expired") { alert("Your token has expired, please login again."); }
  >         else if (data.errorMessage == "Bad parameter, token malformed.") { alert("Bad parameter, token malformed."); }
  >         else if (data.errorMessage == "Bad parameter, flag is incorrect.") { alert("Bad parameter, flag is incorrect."); }
  >         else { alert("Product added."); }
  >       }
  >     });
  >   } else {
  >     $.ajax({ type:'POST', url: API_URL + '/addtocart',
  >       data: JSON.stringify({ "id": guid(), "cookie": document.cookie, "prod_id": idp, "flag": false }),
  >       success: function (data) { alert("Product added"); }
  >     });
  >   }
  >   return false;
  > }
  > ```
  > Two branches on whether cookie `tokenp_` (a login token) is present. Logged-in branch: `cookie`
  > field = the token, `flag: true`, and the success handler branches on `data.errorMessage` with
  > **four** distinct outcomes, one of them the confirmation alert `"Product added."` **(with a
  > trailing period)**. Guest branch: `cookie` field = the raw `document.cookie` string (not a
  > token), `flag: false`, and the success handler **always** alerts `"Product added"` **(no
  > trailing period)** — it never inspects `data.errorMessage` at all, so any error the API might
  > return for a guest add-to-cart is silently swallowed and reported to the user as success.
  >
  > **`cart.js` — cart population** (`viewcart` then per-item `view`, literal code, both the
  > logged-in and guest branches use this identical shape, only the `/viewcart` request body's
  > `cookie`/`flag` differ — logged-in: `{cookie: token, flag: true}`; guest:
  > `{cookie: document.cookie, flag: false}`):
  > ```
  > data.Items.forEach(function (articleItem) {
  >   $.ajax({ type:'POST', url: API_URL + '/view', data: JSON.stringify({ "id": articleItem.prod_id }),
  >     success: function (data) {
  >       var valew2 = JSON.parse(JSON.stringify(data));
  >       var itid = "'" + articleItem.id + "'";
  >       $('#tbodyid').append('<tr class="success"><td><img ... src="'+valew2["img"]+'"></td>'
  >         + '<td>'+valew2["title"]+'</td><td>'+valew2["price"]+'</td>'
  >         + '<td><a href="#" onclick="deleteItem('+itid+')">Delete</a></td></tr>');
  >       $('#totalp').empty(); $('#totalm').empty();
  >       total = total + parseInt(valew2["price"]);
  >       $('#totalp').append(total);
  >       $('#totalm').append("Total: " + total);
  >     }
  >   });
  > })
  > ```
  > `total` is a module-level variable (`var total = 0;`, declared once at file load, cart.js line
  > 5) accumulated across every per-item `/view` response as they resolve (each is an independent
  > async call, order of arrival not guaranteed to match cart order) via `parseInt(price)` —
  > **truncates any decimal cents** if a price ever carried them (no decimal price was observed in
  > this capture; not confirmed either way, see "Not confirmed" below). `#totalp` and `#totalm` are
  > both cleared and re-appended to on *every* item's resolution, not only the last one — so the
  > displayed total visibly climbs item-by-item as each `/view` call resolves, rather than
  > appearing once, fully summed.
  >
  > **`cart.js` — `deleteItem(id)`** (literal code):
  > ```
  > function deleteItem(id) {
  >   $.ajax({ type: 'POST', url: API_URL + '/deleteitem', data: JSON.stringify({ "id": id }),
  >     success: function (data) { location.reload(); }
  >   });
  > }
  > ```
  > No confirmation dialog before the delete request fires (the "Delete" link's `onclick` calls
  > this directly); on success, a full page reload (which re-runs the entire `viewcart` fetch
  > sequence above, rebuilding the total from scratch).
  >
  > **`cart.html` served markup, `#orderModal`** (lines ~588-635, literal): six input fields —
  > `#name` ("Name:"), `#country` ("Country:"), `#city` ("City:"), `#card` ("Credit card:"),
  > `#month` ("Month:"), `#year` ("Year:") — plus a `#totalm` label (repurposed here as the modal's
  > "Total:" line, same element ID `viewcart` already writes the running total into) and an empty
  > `<label id="errors">` slot for inline error text that is **never populated by any code path
  > read in this capture** (`purchaseOrder()` uses `alert(...)`, not `#errors`, for its one error
  > case — the `#errors` label exists in markup but appears to be dead UI, not confirmed further).
  >
  > **`cart.js` — `purchaseOrder()`** (literal code):
  > ```
  > function purchaseOrder() {
  >   var idr = Math.floor((Math.random() * 10000000) + 1);
  >   var name = document.getElementById("name").value;
  >   var creditcard = document.getElementById("card").value;
  >   var date = new Date();
  >   if (name == "" || creditcard == "") {
  >     alert("Please fill out Name and Creditcard.");
  >   } else {
  >     var token = getCookie("tokenp_");
  >     if (token.length > 0) { deleteCart(usern); } else { deleteCart(document.cookie); }
  >     swal({ title: "Thank you for your purchase!",
  >       text: "Id: " + idr + "\n" + "Amount: " + total + " USD" + "\n"
  >         + "Card Number: " + creditcard + "\n" + "Name: " + name + "\n"
  >         + "Date: " + date.getDate() + "/" + date.getMonth() + "/" + date.getFullYear(),
  >       type: "success", confirmButtonText: "OK" }, function (isConfirm) {
  >         if (isConfirm) { location.href = 'index.html'; }
  >       });
  >   }
  > }
  > ```
  > Only `name` and `creditcard` (`#card`) are read from the DOM by this function — `#country`,
  > `#city`, `#month`, `#year` are declared in the modal's markup but **never referenced anywhere
  > in `purchaseOrder()` or elsewhere in `cart.js`**: not read, not validated, not sent to the
  > server, not shown in the confirmation dialog. The only validation is a non-empty check on
  > `name` and `creditcard` — no format check (card-number shape, Luhn, expiry, country/city
  > free-text) on any field, confirmed by reading the function's complete body (no other branch
  > exists). `deleteCart(...)` (`POST /deletecart`) is fired, and the `swal(...)` success dialog is
  > constructed and shown **in the same synchronous flow, not inside `deleteCart`'s own `success`
  > callback** (`deleteCart`'s callback body is empty — literal code:
  > `success: function (data) { }`) — so the confirmation dialog is not gated on the delete-cart
  > request actually having completed (or succeeded) server-side.
  > The dialog text's "Amount" is the page's in-memory `total` (the running sum computed at cart
  > load, not re-fetched at purchase time — if the user's cart changed server-side in another tab
  > since page load, `total` would be stale); "Card Number" echoes the raw entered string verbatim
  > (no masking).

- **Not confirmed by any source found**: what the API actually returns for any of these calls
  (no write request was sent, per the golden-rule/no-side-effects capture method above — this
  capture reads only the client code that *would* call the API, not live responses); whether
  DemoBlaze prices ever carry a decimal fraction (all product cards observed on the index page
  during this capture showed integer USD amounts, but the full catalog was not enumerated —
  out of slice, see dependencies below); the exact behavior if two cart items resolve their
  `/view` calls in an order that races the DOM append (cosmetic row order only, not a total-value
  risk, not probed further); and the exact string emitted when `data.errorMessage` is a value not
  in the three named cases within the logged-in `addToCart` branch (its `else` catches everything
  else generically as success — not confirmed this is the *only* remaining path via any other
  observed source, just the literal code structure).
- **Redaction**: none needed (no personal data anywhere in the captured pages/JS — static demo
  copy and public client code only; no login was performed, so no live session/token value was
  ever captured).
- **Dependencies (out-of-slice)**: `js/index.js`'s own catalog listing, pagination (`/pagination`,
  `/bycat`) and product-detail browsing are a separate US-slice (catalog browsing), not designed
  here — this slice is scoped to "add to cart → view cart → place order" only, starting from an
  already-known product id. Login/signup (`logIn()`, `register()` in all three files) are also a
  separate US-slice (auth) — referenced here only insofar as the presence/absence of the
  `tokenp_` cookie changes `addToCart`'s and `viewcart`'s request shape (AC1-AC4 below), never
  designed as their own feature in this run.

## Journey

| Step | Status |
|---|---|
| 00-ingest | done — gates checked (not empty, is a testable capability — a real, richly-specified cart/checkout flow with literal, readable JS — no abuse/illegality, no PII to redact) |

## Skill evaluation — `us-ingest` (`plugins/qaia-core/skills/us-ingest/SKILL.md`)

**Verdict: CONFORME.**

**Evidence**: Step 1 (line 12) requires fetching "exactly that source — nothing else." The
designated source is `docs/DEMO-TARGETS.md`'s `DemoBlaze` row (not a single URL); the six
resources read are exactly the three pages plus the three JS files each page itself links to —
no page outside that closed set was fetched, and critically, **no write/state-changing request
was sent** (no `/addtocart`, `/login`, `/deletecart` call), which respects both this step's
"nothing else" and the campaign brief's golden rule (shared demo, no load pattern) even more
strictly than a read-only `GET` scrape would require on its own. Step 2's triage gates
(lines 14-17) were run: not empty, a real testable capability, no abuse framing. Step 3's
redaction gate (line 18) correctly found nothing to mask. No deviation found. **Modification
proposed: none.**

⚠ VALIDATION (US-ID, captured-source confirmation): `simulated: accepted-as-is` (non-interactive
campaign run, per shared-contract rule 3's `simulated` convention).
