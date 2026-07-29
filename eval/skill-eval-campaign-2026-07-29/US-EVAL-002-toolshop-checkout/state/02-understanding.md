---
stepsCompleted: [00-ingest, 01-review, 02-understanding]
lastStep: 02-understanding
lastSaved: 2026-07-29
---

# 02-understanding — US-EVAL-002

## Reformulation

Who: any Toolshop customer, signed in or anonymous, who has added at least one product to a
cart. What: the cart must accept a valid product/quantity and reject an invalid one, and checkout
must turn a cart into a confirmed invoice through exactly one of two structurally parallel paths
(authenticated `POST /invoices` vs. guest `POST /invoices/guest`), never letting an unauthenticated
caller reach the authenticated path or vice versa. Why: this is the revenue-critical moment of the
whole storefront — every product page and cart interaction exists to arrive here. Main risk if it
misbehaves: a checkout that silently succeeds against bad input (empty cart, unowned cart, missing
guest identity) produces an invoice that shouldn't exist — worse than a checkout that wrongly
refuses a valid attempt, because a phantom order is harder to detect and undo than a retryable
failure.

## Ambiguity hunt

**Q1 — checkout against an empty cart.** No source confirms whether `POST /invoices` /
`POST /invoices/guest` succeed, are refused, or produce a degenerate (zero-line) invoice when the
referenced cart has no items.
- Classification: step 3 — a safe default exists (refusing an empty-cart checkout is the
  lower-risk, standard e-commerce assumption; silently accepting one and issuing a $0 order is not
  a plausible intended behavior) → **`[assumption]`**.

**Q2 — invalid `product_id` on add-to-cart.** No source states the response when `product_id`
does not match a real product.
- Classification: step 3, safe default exists (reject/error) → **`[assumption]`**.

**Q3 — quantity boundary on add-to-cart.** No source states the accepted range for `quantity`;
whether `0` or a negative value is accepted, silently clamped, or refused.
- Classification: step 3, safe default exists (reject `quantity <= 0`, standard boundary
  assumption for a countable stock item) → **`[assumption]`**, `@low-confidence` (the exact
  boundary — is `quantity: 0` refused or is `1` the true floor — is not independently confirmed).

**Q4 — guest checkout missing a required guest field.** No source states the response when
`guest_email`, `guest_first_name`, or `guest_last_name` is omitted from `POST /invoices/guest`.
- Classification: step 3, safe default exists (a documented required-looking field missing →
  validation refusal) → **`[assumption]`**.

**Q5 — initial invoice status.** Which of the five documented statuses
(`AWAITING_FULFILLMENT`, `ON_HOLD`, `AWAITING_SHIPMENT`, `SHIPPED`, `COMPLETED`) a newly created
invoice starts in is not stated anywhere in the fetched documentation.
- Classification: step 4 — this is a genuine business-workflow decision among five named values,
  not a binary safe-vs-unsafe default (unlike Q1-Q4, there is no obviously "safer" choice among
  five named statuses) → **`[open]`**.

**Q6 — cart ownership at checkout (auth boundary).** The documentation never states whether
`POST /invoices` validates that the cart being invoiced belongs to the authenticated caller, or
whether any `cart_id` reachable by that caller can be submitted (a potential IDOR: one signed-in
user checking out another user's cart).
- Classification: per step 3 of the adversarial pass below ("access boundary → question, never
  assumption"), this is an **auth-boundary** point the US never states → **`[open]`**, never
  defaulted to "obviously enforced."

**Q7 — how an invoice references its cart.** The fetched documentation did not expand
`InvoiceRequest`'s field list, so whether it carries a `cart_id` (linking AC2/AC3 back to the
cart created in AC1) or some other mechanism is not confirmed.
- Classification: step 3, safe default exists (a `cart_id`-referencing field is the only
  documented way the two endpoints could possibly know which items to invoice, and no source
  contradicts it) → **`[assumption]`**, `@low-confidence`.

## Adversarial pass (by AC type — mandatory)

- **State machine / lifecycle (AC4)**: the invoice's initial state is exactly Q5 above — logged,
  not silently defaulted. Re-entrance (can `POST /invoices` be called twice against the same cart,
  producing two invoices, or is the cart consumed/cleared on success?) is a genuine second
  lifecycle question the documentation does not answer either — folded into Q1's family as an
  **`[assumption]`**: a successful checkout is assumed to consume the cart (checking out twice
  against the same cart is out-of-slice here, not independently tested, since the "cart cleared on
  success" behavior itself is unconfirmed and would need its own question to test rigorously).
- **Auth / tokens / permissions (AC2 vs AC3)**: this is Q6 above — the authenticated/guest split
  itself is clearly documented (two distinct endpoints, one gated by `apiAuth`), but *which* cart
  an authenticated caller may reference is not, and that indistinguishability question (does an
  unauthorized cart_id return a 403 or a 404, disclosing vs. not disclosing that the cart exists)
  is carried into the triple-AC pass below rather than resolved here.
- **Sorting / pagination**: not applicable — no list/aggregation view is in this US's slice (`GET
  /invoices` and `GET /invoices/search` are out-of-slice per `00-source.md` dependencies).
- **Thresholds / quantities (AC1)**: this is Q3 above (the `quantity` boundary).

## Cross-AC interaction pass (mandatory)

AC1 (cart) feeds AC2/AC3 (checkout) at exactly one boundary: what a checkout call does when the
referenced cart is empty or non-existent — this is Q1. AC2 and AC3 do not otherwise interact (they
are alternative, mutually exclusive paths for the same underlying "turn a cart into an invoice"
action, not two rules applied to the same resource in sequence).

## Triple-AC contradiction pass (mandatory)

Candidate triplet: a **restricted-resource** rule (a cart belongs to exactly one user), a
**scoping** rule (an authenticated caller's `POST /invoices` should only ever act on carts it owns),
and an **anti-disclosure/error-shape** rule (should attempting to checkout someone else's cart
return a `404` — as if the cart id doesn't exist, avoiding confirming *whose* cart it is — or a
`403` — confirming the cart exists but access is denied?). This triplet exists in this US (unlike a
case where the pattern genuinely does not apply) and is not answered by any fetched source: it is
the same question as Q6, now stated with its full three-rule shape rather than only as an
auth-boundary flag. No separate question ID is created (Q6 already captures it); this section
exists to make the triple-intersection reasoning itself visible per the skill's own mandatory-trace
rule, not to silently fold it into a plain auth question without a citable trace.

## Q&A log

| ID | Question | Status | Resolution |
|---|---|---|---|
| Q1 | Checkout against an empty cart | `[assumption]` | Refused |
| Q2 | Invalid `product_id` on add-to-cart | `[assumption]` | Refused/error |
| Q3 | Quantity ≤ 0 on add-to-cart | `[assumption]`, `@low-confidence` | Refused |
| Q4 | Guest checkout missing a required guest field | `[assumption]` | Refused (validation) |
| Q5 | Initial invoice status | `[open]` | No default asserted with confidence — proposed default `AWAITING_FULFILLMENT` (first-listed, workflow-start-shaped) generated as `@low-confidence`, human arbitration required |
| Q6 | Cart ownership at checkout (IDOR-shaped auth boundary) | `[open]` | No default asserted; error-shape (403 vs 404) left open, human arbitration required |
| Q7 | Invoice-to-cart linkage mechanism | `[assumption]`, `@low-confidence` | Assumed a `cart_id`-referencing field exists on `InvoiceRequest` |

## Journey

| Step | Status |
|---|---|
| 02-understanding | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) |

## Skill evaluation — `need-understanding`

- **Skill evaluated**: `plugins/qaia-core/skills/need-understanding/SKILL.md`.
- **Input**: `01-extraction.md` above (4 ACs, API-only source, several unconfirmed behaviors
  already flagged at extraction).
- **Output**: this file.
- **Verdict**: **CONFORME.**
- **Evidence**: both mandatory trace sections the skill's own guardrail calls out as commonly
  skipped (line 48: "Omitting the required trace of step 3 or step 4a... is the same defect as
  silently resolving an ambiguity") are present as their own headed sections above (`## Adversarial
  pass` and `## Triple-AC contradiction pass`), each stating its finding rather than a bare
  "not applicable." The classification decision tree (line 30, step 3 vs step 4) was applied
  case-by-case with a stated reason each time (Q1-Q4, Q7 get a stated safe default; Q5-Q6 get the
  explicit "no safe default without escalation" reasoning) rather than a blanket call, matching the
  "stop at first match" instruction (line 30).
- **Modification proposed**: none.
