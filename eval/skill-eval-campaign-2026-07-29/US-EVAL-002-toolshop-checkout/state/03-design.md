---
stepsCompleted: [00-ingest, 01-review, 02-understanding, 03-design]
lastStep: 03-design
lastSaved: 2026-07-29
---

# 03-design — US-EVAL-002

## AC → technique map

- **AC1** (add product to cart) → **Equivalence partitioning** (valid product/quantity class vs.
  invalid-product-id class) extended by **Boundary Value Analysis** on `quantity` (the ≤0 boundary,
  Q3).
- **AC2** (authenticated checkout) → **Decision Table Testing** — authentication (yes/no) × cart
  state (owned-and-non-empty / empty / not-owned) crossed against one "invoice created / refused"
  action is a genuine multi-axis combination, not opportunistic pair-picking.
- **AC3** (guest checkout) → **Equivalence partitioning** (complete-guest-fields class vs.
  missing-field class) plus a **standardized-domain oracle** (RFC 5322) on `guest_email`'s format.
- **AC4** (initial invoice status) → **State Transition Testing** — the single transition
  "cart → created invoice" lands on one of five documented states; the state × event table is
  degenerate here (one event, one starting cell, target state itself the open question, Q5) but
  the technique is still the correct frame, not decision-table, because the question is which
  *state* results, not which combination of conditions applies.

## Sub-step 3b — standardized domain → oracle (applied)

`guest_email` (AC3) is a `format: email` field → **RFC 5322** built-in oracle triggered
(`oracle-generate`, built-in library, no network/no project file needed). Applied: one grounded
negative condition (`AC3-C3`, malformed email format) tagged `@oracle:rfc5322`, citing the
standard rather than guessing what "malformed" means. The **project-OpenAPI oracle**
(`oracles/openapi.md`) was **not** invoked — it requires a single user-designated local
`.yaml`/`.json` file (bounded, opt-in); this run only has `WebFetch`-retrieved documentation text,
not a local spec file, so that path is correctly not available, not silently skipped.

## Sub-step 3c — systematic coverage expansion (applied where triggered, waived elsewhere)

- **List/collection view** — not triggered: no list/aggregation screen is in this US's slice
  (`GET /invoices`, `GET /invoices/search` are out-of-slice per `00-source.md`). Waived.
- **Entity → full CRUD lifecycle** — triggered on the cart entity (create/add/update-quantity/
  delete exist per `00-source.md`), but update-quantity and delete are explicitly out-of-slice
  (this US's slice is "add to cart" + checkout, not full cart management) — **waived**, recorded
  as a dependency, not silently dropped.
- **Conditional behavior (decision table over variation axes)** — triggered: this *is* AC2's
  decision table (authenticated vs. guest, owned vs. not-owned, empty vs. non-empty cart).
  Applied.
- **Authorization & server-side enforcement** — triggered: unauthenticated access to `POST
  /invoices` (`AC2-C2`) and cross-tenant/IDOR access to another caller's cart (`AC2-C4`, Q6) are
  both derived here, exactly the pattern this sub-step names by example. Applied.
- **Enumerate every list/aggregation view** — not applicable, no list view exists in scope
  (same reasoning as the first bullet). Waived.
- **Sibling collections of a named entity** — not triggered: a cart's items are the entity's own
  primary content (already covered by AC1), not a *child* entity with its own sub-collections the
  source implies but doesn't name. Waived.
- **Account & auth features → recovery path** — not triggered: this US is a cart/checkout
  capability, not an account/credential feature; no login/password/recovery flow is implied here.
  Waived (contrast with the prior campaign run's US, a login US, where this same sub-step *was*
  the directly-triggered one).

## Sub-step 3d — knowledge-driven conditions

No `knowledge/index.md` exists for this campaign directory (no team knowledge base was ever
initialized here). Recorded per shared-contract rule 8 (degraded mode): proceeding on the source
alone, nothing invented to compensate.

## Test conditions

- **AC1-C1** `[ep]` — valid `product_id` + `quantity: 1` → cart reflects the added item.
- **AC1-C2** `[decision-table]` `[req-neg]` (Q2) — unrecognized `product_id` → add refused/errors.
- **AC1-C3** `[boundary]` `[req-neg]` `[assumption]` `@low-confidence` (Q3) — `quantity: 0` (or
  negative) → add refused.
- **AC2-C1** `[decision-table]` — authenticated caller, a cart it owns, non-empty → `POST
  /invoices` succeeds, invoice created.
- **AC2-C2** `[decision-table]` `[req-neg]` — unauthenticated caller → `POST /invoices` refused
  (no `apiAuth`, per the documented security requirement).
- **AC2-C3** `[decision-table]` `[req-neg]` `[assumption]` (Q1) — authenticated caller, an empty
  cart → checkout refused.
- **AC2-C4** `[decision-table]` `[req-neg]` `[open]` `@low-confidence` (Q6) — authenticated
  caller submits a `cart_id` it does not own → **proposed default**: refused; the exact error
  shape (403 confirming existence vs. 404 non-disclosing) is genuinely open, human arbitration
  needed.
- **AC3-C1** `[ep]` — guest, complete `guest_email`/`guest_first_name`/`guest_last_name`, a
  non-empty cart → `POST /invoices/guest` succeeds, invoice created.
- **AC3-C2** `[decision-table]` `[req-neg]` `[assumption]` (Q4) — guest checkout missing one
  required guest field → refused.
- **AC3-C3** `[req-neg]` `[assumption]` `@oracle:rfc5322` — guest checkout with a syntactically
  malformed `guest_email` (RFC 5322 invalid corpus, e.g. missing `@`/domain) → refused.
- **AC4-C1** `[state-transition]` `[open]` `@low-confidence` (Q5) — a freshly created invoice's
  initial status → **proposed default**: `AWAITING_FULFILLMENT` (first-listed, workflow-start
  shaped); genuinely open, human arbitration needed before trusting this assertion.

## Journey

| Step | Status |
|---|---|
| 03-design | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) |

## Skill evaluation — `istqb-design`

- **Skill evaluated**: `plugins/qaia-core/skills/istqb-design/SKILL.md`.
- **Input**: `02-understanding.md` above (4 ACs, 7 logged questions).
- **Output**: this file.
- **Verdict**: **CONFORME.**
- **Evidence**: `SKILL.md` line 103's own guardrail warns that "a sub-step of 3c with no mention
  at all... is a defect" and specifically flags that the login-US run of this same campaign missed
  the "account & auth recovery path" bullet silently. This run's `## Sub-step 3c` section addresses
  every named bullet explicitly, including that exact recovery-path bullet — correctly marked
  "not triggered" with a stated reason (this is not an auth-feature US) rather than omitted. Line
  98 requires 3b/3c/3d to each "appear in the checkpoint with its outcome — applied... or
  explicitly waived... never silently absent" — all three sub-steps have their own headed section
  above with per-bullet outcomes, not a blanket "n/a".
- **Modification proposed**: none.
