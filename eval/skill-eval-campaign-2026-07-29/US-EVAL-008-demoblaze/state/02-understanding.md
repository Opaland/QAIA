# 02-understanding — US-EVAL-008

## Reformulation

Who: any DemoBlaze shopper, guest or logged-in, moving from a product page to the cart to
checkout. What: add a product to the cart, see an accurate running total on the cart page, remove
an unwanted item, and submit a "Place Order" form that in reality validates only two of its six
visible fields. Why: this flow is where a storefront either protects the user from a broken
purchase (wrong total, silently-dropped errors, no confirmation) or doesn't — and the captured
source shows several places where it structurally doesn't (guest errors swallowed, four order
fields never read, no auth gate on checkout at all). Main risk if it misbehaves: a user believes
an item was added or an order was placed when the underlying request actually failed (AC3, AC8's
un-awaited `deletecart`) — a false-positive "success" signal is a worse defect than a visible
failure, because it is invisible to the shopper and to a shallow test suite alike, which is why it
drives the priority scores below.

Knowledge base: `.qaia/knowledge/` does not exist for this campaign directory — recorded per
shared-contract rule 8 ("degraded modes are explicit"), proceeding on the source alone.

## Ambiguity hunt

**Q1 — guest-path error-swallowing (AC3) is confirmed by source, but is it independently
re-verifiable live?** The code unconditionally alerts `"Product added"` in the guest branch,
never inspecting `data.errorMessage` — this is a deterministic fact of the read source, not
ambiguous behavior. The open question is testability: forcing the live API to actually return an
`errorMessage` for a guest `/addtocart` call is not something black-box UI automation can reliably
and safely manufacture without manipulating the shared backend outside "explore" (golden rule).
- Classification: step 3, a safe default exists (assert only the directly observable, always-true
  part — the generic success alert appears on a normal add — and cite the "never differentiates"
  claim as a documented source fact rather than an independently re-proven one) → **`[assumption]`**.

**Q2 — AC8's un-awaited `deletecart` / stale `Amount` is a race condition; is it scenario-testable
without flakiness?** The success dialog fires synchronously, not inside `deletecart`'s own
(empty) success callback, and `total` is computed once at cart-page load. A scenario asserting the
exact timing relationship between the dialog and the delete request completing would depend on
network timing, which is inherently flaky, not a stable black-box assertion; and re-observing
staleness would need a second tab modifying the cart mid-session, an artificial harness this
capture didn't set up.
- Classification: step 3, safe default (scope this US-slice's `Amount` assertion to the
  single-session case — no concurrent modification — and flag the race condition itself as a
  named robustness gap, not asserted with a specific timing outcome) → **`[assumption]`**.

**Q3 — is unauthenticated ("guest") checkout an intended, permitted business policy, or should
purchasing require login?** `purchaseOrder()` contains **no** authentication check at all — the
`tokenp_` cookie is consulted only to choose which identifier `deleteCart` uses, never as a gate
on whether the purchase itself may proceed. The source is silent on whether this is intentional
(a deliberate "no account needed to buy" storefront policy) or an oversight.
- Classification: step 2 applies — this is a genuine **access-control/business-policy** question
  on a monetary action (who may complete a purchase), not a mechanically-forced technical default;
  the source's silence does not by itself imply either "guest checkout is allowed" or "guest
  checkout should be blocked" is the *correct* policy, only that the *current code* has no gate →
  **`[open]`**. Per `testbook-generate`'s "generating on `[open]` items" rule, the observed
  behavior (no gate — guest and logged-in checkout both succeed identically) is still generated as
  a scenario, tagged `@low-confidence`, citing Q3 inline — never silently asserting a gate that
  isn't there, and never silently omitting the guest-checkout scenario either.

## Adversarial pass (by AC type)

- **State machine / lifecycle**: the flow has a simple lifecycle (empty cart → item(s) added →
  order placed → cart cleared). Re-entrance: can "Place Order" be submitted twice in quick
  succession (double-click) before the first `deletecart`/redirect completes? The source has no
  debounce/disable-on-submit on the "Purchase" button — not guarded against, but this is the same
  un-awaited-async shape already logged as **Q2**, not a separate question. Forbidden transitions:
  none stated (no "cart must be non-empty to place an order" check was found in `purchaseOrder()`
  — an order can be "placed" against an empty cart, generating an id and a success dialog with
  `Amount: 0 USD`, since nothing in the read source blocks it). This empty-cart-checkout case is
  a genuine, source-confirmed gap — carried into design as a condition, not a question (the
  source's silence here is a confirmed absence-of-a-check, not an ambiguity about what the code
  does).
- **Auth / tokens / permissions**: covered by **Q3** above (no gate on checkout) and **AC2/AC3**'s
  asymmetry (logged-in vs guest add-to-cart error handling) — both already logged, not duplicated.
  No token revocation/expiration-mid-session behavior is defined for the cart/checkout flow itself
  (only `addToCart`'s logged-in branch reacts to an expired/malformed token, and only for the
  *add* action, never for *viewing* the cart or *placing* an order — `viewcart`/`purchaseOrder`
  have no equivalent token-freshness check in the captured source). Flagged as a business-rule
  observation in `01-extraction.md`, not re-asked here.
- **Sorting / pagination**: not applicable — the cart is a short, unsorted, unpaginated list in
  this captured flow.
- **Thresholds / quantities**: the one quantity threshold is the empty-string check on Name/Credit
  card (AC7) — confirmed exact (`== ""`, no `.trim()` visible), so a whitespace-only value (e.g.
  `" "`) passes as "non-empty" per the literal code; this is answered directly by the source, not
  ambiguous, and becomes a boundary condition in `istqb-design`, not a question here.

## Cross-AC interaction pass

- **AC4 (running total) × AC5 (delete)**: after a delete, the page fully reloads, re-running the
  entire `viewcart` fetch sequence and recomputing `total` from zero — confirmed consistent by
  source, no ambiguity.
- **AC4 (total) × AC8 (Amount in dialog)**: the interaction is exactly **Q2** above (staleness) —
  logged there, not duplicated.
- **AC2/AC3 (add-to-cart error asymmetry) × AC8 (purchase)**: does the same guest/logged-in
  error-branching pattern from `addToCart` repeat inside `purchaseOrder`? No — confirmed by
  source: `purchaseOrder()` has no `errorMessage`-branching logic at all, for either guest or
  logged-in flows; its only validation is the client-side empty-field check (AC7). Noted here so
  downstream design does not assume the two functions share error-handling shape.

## Triple-AC contradiction pass

No triplet of a *protected/restricted-state* rule, a *filtering/scoping* rule, and an
*anti-disclosure/error-shape* rule applies to this slice — there is no restricted-state entity, no
org/tenant-scoped resource, and no existence-disclosure concern (a cart tied to a cookie/token,
not a shared or protected record). **Not applicable, no matching pattern in this US.**

## Q&A log

| ID | Question | Status | Resolution |
|---|---|---|---|
| Q1 | Is guest-path error-swallowing (never checking `errorMessage`) independently re-verifiable live, or only assertable as a documented source fact? | `[assumption]` | Scenario asserts the directly observable part (generic success alert on a normal add); the "never differentiates" claim is cited from source, not independently re-forced via a live error condition |
| Q2 | Is the un-awaited `deletecart`/stale `Amount` race condition scenario-testable without flakiness? | `[assumption]` | Scoped to single-session (no concurrent-tab modification); `Amount` assertion uses the cart total as loaded; the race itself is a named robustness gap, not asserted with a specific timing outcome |
| Q3 | Should unauthenticated ("guest") checkout be permitted, or is this a gap the storefront should close? | `[open]` | No gate exists in the read source either way (business-policy silence, not a technical default); the observed no-gate behavior is still generated as a `@low-confidence` scenario citing Q3, per `testbook-generate`'s own rule for `[open]` items |

## Journey

| Step | Status |
|---|---|
| 02-understanding | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign
  run) |

## Skill evaluation — `need-understanding` (`plugins/qaia-core/skills/need-understanding/SKILL.md`)

**Verdict: CONFORME.**

**Evidence**: Step 3 (line 20) and step 4a (line 28) both require an explicit, checkable section
even when "not applicable" — done above ("## Adversarial pass" and "## Triple-AC contradiction
pass" both present, the latter with an explicit "not applicable, no matching pattern" call). Step
5a's classification tree (lines 30-36) was applied in order for all three questions, with the
step-2 protected/policy branch correctly invoked for **Q3** (a genuine access-control/business-
policy silence on a monetary action, not a mechanically-forced default) rather than defaulting it
to `[assumption]` the way Q1/Q2 (genuinely mechanical/testability constraints) were — this
produces real classification diversity (2 `[assumption]`, 1 `[open]`) rather than converging all
three to the same band, which the calibration examples on line 36 warn against blurring. Step 6's
`[open]`-handling and step 8's checkpoint requirements are all present. No deviation found.
**Modification proposed: none.**
