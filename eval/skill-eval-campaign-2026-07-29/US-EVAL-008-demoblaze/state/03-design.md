# 03-design — US-EVAL-008

## AC → technique map

- **AC1** (add-to-cart request shape by session state) → **Equivalence partitioning** (guest vs
  logged-in are two distinct partitions of the same action).
- **AC2** (logged-in add-to-cart error branching) → **Decision Table Testing** — four columns over
  the single `errorMessage` variable (expired / malformed / flag-incorrect / none).
- **AC3** (guest add-to-cart, always-generic response) → **Equivalence partitioning**, scoped by
  **Q1** `[assumption]` to the one live-observable partition (a normal, non-erroring add).
- **AC4** (cart population + running total) → **State Transition Testing** (empty → populated cart
  state) + **Boundary Value Analysis** (one item vs several items, to exercise the accumulation
  logic, not just presence).
- **AC5** (delete → reload) → **State Transition Testing** (populated → reduced/empty cart edge).
- **AC6** (order-modal field surface vs what's actually read) → **Equivalence partitioning** (the
  four unread fields form one "any value, no effect" partition, confirmed by source, not guessed).
- **AC7** (client-side required-field validation) → **Decision Table Testing** (name × card, each
  empty/non-empty) + **Boundary Value Analysis** on the whitespace-only string (Q found in
  `need-understanding`: no `.trim()` in the read source).
- **AC8** (successful purchase + its three flagged gaps) → **State Transition Testing** (cart →
  ordered) + **Equivalence partitioning**, scoped by **Q2** `[assumption]` (single-session
  `Amount`) and **Q3** `[open]` (guest checkout permitted — generated `@low-confidence`, citing
  Q3, per `testbook-generate`'s own rule for `[open]` items) + the empty-cart-checkout gap found
  in the adversarial pass (`02-understanding.md`).
- **AC9** (confirm → redirect) → **State Transition Testing** (terminal transition of the
  lifecycle below).

## State × event table (CT-MBT discipline, built before deriving conditions)

| State \ Event | `add-to-cart` | `delete-item` | `place-order` (valid fields) | `place-order` (invalid fields) | `confirm-dialog` |
|---|---|---|---|---|---|
| **S0 empty cart** | → **S1 has-items** (AC1) | not applicable (no rows) | → **S3 ordered** (AC8-C4, empty-cart checkout — no guard found in source) | → **S0** (unchanged, AC7) | not applicable |
| **S1 has-items (1 item)** | → **S1** (adds a 2nd item, becomes the 2-item case below) | → **S0** (AC5) | → **S3 ordered** (AC8) | → **S1** (unchanged, AC7) | not applicable |
| **S2 has-items (2+ items)** | → **S2** (accumulates further, not separately asserted beyond AC4-C2) | → **S1 or S0** depending on which/how many removed (only the single-delete edge is asserted, AC5) | → **S3 ordered** (AC8, total = multi-item sum) | → **S2** (unchanged, AC7) | not applicable |
| **S3 ordered** (dialog shown) | not applicable (modal is up) | not applicable | not applicable | not applicable | → **S0** (AC9, redirect to `index.html`, cart cleared server-side via `deletecart`) |

The **S0 → S3** edge (empty-cart checkout succeeding with no guard) is a genuinely
source-confirmed transition, not a fabricated one: `purchaseOrder()`'s complete body (read in
`00-source.md`) contains no cart-emptiness check anywhere before generating the order id and
showing the success dialog.

## Test conditions

### AC1 — add-to-cart request shape
- **AC1-C1** `[ep]` — no `tokenp_` cookie present: request sent with `flag: false`,
  `cookie: document.cookie`.
- **AC1-C2** `[ep]` — `tokenp_` cookie present: request sent with `flag: true`,
  `cookie: <token>`.

### AC2 — logged-in add-to-cart error branching
- **AC2-C1** `[decision-table]` `[req-neg]` — response `errorMessage` = "Token has expired" →
  alert "Your token has expired, please login again."
- **AC2-C2** `[decision-table]` `[req-neg]` — response `errorMessage` = "Bad parameter, token
  malformed." → matching alert shown verbatim.
- **AC2-C3** `[decision-table]` `[req-neg]` — response `errorMessage` = "Bad parameter, flag is
  incorrect." → matching alert shown verbatim.
- **AC2-C4** `[decision-table]` — no `errorMessage` (success) → alert "Product added." (trailing
  period, distinct literal from AC3-C1's guest-path copy).

### AC3 — guest add-to-cart
- **AC3-C1** `[ep]` `[assumption]` (Q1) — a normal (non-erroring) guest add: alert "Product added"
  (no trailing period). The "never differentiates on `errorMessage`" claim is cited from source in
  `00-source.md`/`02-understanding.md`, not independently forced live — no scenario asserts a
  guest-path *error* outcome, since that would require manufacturing a live backend error this
  capture's golden-rule discipline does not permit.

### AC4 — cart population + running total
- **AC4-C1** `[state-transition]` — a cart with exactly one item: one row rendered (image, title,
  price, Delete link), total equals that item's price.
- **AC4-C2** `[bva]` — a cart with two or more items: total equals the exact integer sum of every
  fetched item's price (accumulation logic, not just single-value display).
- **AC4-C3** `[ep]` — an empty cart (0 items): no rows rendered, total displays `0` (the 3c
  "list/collection view → empty-list state" reflex pattern, applied — see 3c below).

### AC5 — delete
- **AC5-C1** `[state-transition]` — clicking "Delete" on a row: that row's `deleteitem` request
  fires immediately (no confirmation prompt), then the page reloads and the deleted item's row and
  price no longer contribute to the recomputed total.

### AC6 — order-modal field surface
- **AC6-C1** `[ep]` — opening "Place Order" shows all six fields (Name, Country, City, Credit
  card, Month, Year) plus the Total label.
- **AC6-C2** `[ep]` `[assumption]` — arbitrary/garbage values in Country, City, Month, Year (or
  leaving them empty) never block submission and never appear in the confirmation dialog —
  confirmed by source (`purchaseOrder()` never reads these four fields at all).

### AC7 — required-field validation
- **AC7-C1** `[decision-table]` `[req-neg]` — Name empty, Credit card non-empty: alert "Please
  fill out Name and Creditcard.", no order id generated, modal stays open.
- **AC7-C2** `[decision-table]` `[req-neg]` — Name non-empty, Credit card empty: same alert and
  outcome as AC7-C1 (symmetric, both blocked by the same `||` condition).
- **AC7-C3** `[bva]` — Credit card = a whitespace-only string (e.g. a single space): passes the
  `== ""` check (not blocked) — confirmed by source (no `.trim()` in `purchaseOrder()`), a
  boundary the naive "non-empty" reading misses.

### AC8 — successful purchase
- **AC8-C1** `[ep]` — Name and Credit card both non-empty, cart has items: order id generated,
  `deletecart` fired, success dialog shows Id/Amount/Card Number/Name/Date, all sourced as
  described in `00-source.md`.
- **AC8-C2** `[ep]` `[assumption]` (Q2) — the dialog's Amount equals the cart total as loaded at
  cart-page-view time (single-session scope; no concurrent-tab cart modification asserted either
  way — that race is a named gap, not a scenario).
- **AC8-C3** `[ep]` `[assumption]` (Q3) `@low-confidence` — an unauthenticated (guest) shopper can
  complete the identical purchase flow with identical outcome shape (no login-required gate found
  in source) — generated per `need-understanding`'s rule for `[open]` items, citing Q3 inline;
  **human arbitration welcome** on whether this is the intended policy.
- **AC8-C4** `[state-transition]` — placing an order against an **empty** cart (S0→S3 in the
  table above) still succeeds: an order id is generated and the dialog shows `Amount: 0 USD`
  rather than being blocked — the adversarial-pass finding from `02-understanding.md`, confirmed
  by source (no emptiness guard in `purchaseOrder()`).

### AC9 — confirm → redirect
- **AC9-C1** `[state-transition]` — confirming the success dialog navigates to `index.html`.

## Negative pressure (ADR 0001)

**5 `[req-neg]` conditions**: `AC2-C1`, `AC2-C2`, `AC2-C3` (the three logged-in add-to-cart error
branches — each is a genuine refusal/error response surfaced to the user) and `AC7-C1`, `AC7-C2`
(the two required-field validation blocks on "Place Order"). **`AC3-C1` is deliberately NOT
tagged `[req-neg]`**, even though it is adjacent to an error-handling AC: the only condition this
capture can actually exercise live is the success case (Q1); asserting a guest-path *refusal*
scenario without a way to force one would be exactly the fabrication `istqb-design`'s own
guardrail (line 102) forbids. This is the mirror case of `US-EVAL-006`'s honest zero — here the
honest finding is a **real, non-zero, but capped** `[req-neg]` set, not padded past what the
source and this capture's read-only discipline can support.

## 3b — Standardized domains → oracle (`oracle-generate`)

**Considered, not invoked.** `AC7`/`AC8`'s "Credit card" field is nominally a card-number domain
(one of `oracle-generate`'s named standards, Luhn), but the source confirms **no format/Luhn/
expiry validation exists on this field at all** — `purchaseOrder()`'s only check is non-empty.
Invoking `oracle-generate` here would fabricate a validation rule the code does not implement
(exactly the "guessing them" fabrication this sub-step exists to prevent, run in the wrong
direction). Instead, the *absence* of validation is itself the tested property, captured
qualitatively as `AC7-C3` (whitespace passes) and implicitly by `AC8-C1` (any non-empty string,
including an obviously-invalid card number, succeeds) — no oracle-shaped literal is asserted.

## 3c — Systematic coverage expansion (each pattern's outcome stated, none silently absent)

- **List/collection view** (the cart is one): **applied** — empty-list state → `AC4-C3`;
  multi-item accumulation → `AC4-C2`. **Sort/filter/pagination/state-persistence**: not
  applicable — the captured `cart.js` has no sort, filter, or pagination control on the cart table
  (unlike `index.js`'s catalog, which is out-of-slice per `00-source.md` dependencies).
- **Full CRUD lifecycle**: create (`AC1`, add) and delete (`AC5`) are in-slice; **read** is `AC4`.
  **Update (change quantity) was not found in the captured source at all** — no quantity field or
  update endpoint appears anywhere in `cart.js`/`prod.js` — flagged here as an absence confirmed
  by source, not assumed to exist and not silently skipped. No update condition is generated
  (there is nothing to test that isn't fabricated).
- **Conditional behavior (decision table over variation axes)**: **applied**, via `AC2`'s
  decision table (the `errorMessage` axis) and the guest/logged-in axis already crossed by `AC1`/
  `AC3` vs `AC2`.
- **Authorization & server-side enforcement**: **partially applies, partially out-of-scope by
  design.** Unauthenticated purchase → `AC8-C3` (Q3). **Cross-tenant/IDOR-shape observation**: the
  guest path identifies the cart via the raw `document.cookie` GUID (not a server-issued token) —
  if that value were guessable or exposed, a second party could in principle address another
  guest's cart. This is a real, source-grounded observation, but **exercising it (attempting to
  read/tamper with another session's cart) is a security-surface probe, and DemoBlaze's catalog
  row explicitly forbids security-surface testing on this shared demo** (`docs/DEMO-TARGETS.md`,
  Security ❌) — flagged here as a named gap for a `security-surface` run against a self-hosted
  target, **not generated as a scenario**, per the campaign's golden rule.
- **Enumerate every list/aggregation view**: only one list exists in this slice (the cart) —
  already covered above.
- **Sibling collections of a named entity**: not applicable — no entity here is described as "a
  collection of X" with its own sub-collections.
- **Account & auth recovery path**: not applicable — this US-slice is not an authentication
  feature (login/signup themselves are out-of-slice, per `00-source.md` dependencies).

## 3d — Knowledge-driven conditions

`.qaia/knowledge/` does not exist for this campaign directory — recorded per shared-contract rule
8, proceeding on the source alone (no `BR-KB-nnn` rules applied; `design.knowledgeApplied` will be
empty in the manifest).

## Journey

| Step | Status |
|---|---|
| 03-design | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) |

## Skill evaluation — `istqb-design` (`plugins/qaia-core/skills/istqb-design/SKILL.md`)

**Verdict: CONFORME.**

**Evidence**: Step 5's checkpoint rule (line 98) requires every sub-step of 3b/3c/3d to appear
with its stated outcome — done above (3b: considered and explicitly declined with a reason; 3c:
all seven patterns given an explicit applied/not-applicable call, including the CRUD pattern's
"update not found in source, not fabricated" finding and the authorization pattern's explicit
security-surface carve-out; 3d: absent, stated plainly). The State Transition Testing technique's
own "build the explicit state × event table first" instruction (palette line 43) was followed
literally before any condition was derived from it, including the two `not applicable` cells and
the genuinely source-confirmed `S0→S3` (empty-cart-checkout) edge. Step 3's negative-pressure gate
(line 75) produced a real, non-trivial, but deliberately capped `[req-neg]` set (5 conditions) —
`AC3-C1` was correctly excluded with a stated reason rather than either padded in (fabricating an
unreachable live-error scenario) or silently dropped without explanation, which is the same
"unjustified technique/condition is a rubric defect" discipline (line 102) `US-EVAL-006` applied
to its own honest-zero case. 3b's oracle sub-step correctly recognized a nominal-standard-domain
field (`Credit card`) and explicitly *declined* to invoke `oracle-generate` because the source has
no validation logic to ground an oracle against — using the sub-step's own fabrication-avoidance
purpose in the direction of restraint rather than application. No deviation found. **Modification
proposed: none.**
