---
stepsCompleted: [00-ingest, 01-review, 02-understanding]
lastStep: 02-understanding
lastSaved: 2026-07-30
---

# 02-understanding — US-EVAL-009

## Reformulation

Who: a guest shopper browsing the JPetStore catalog (no sign-in required for this slice — sign-in
is only a dependency of checkout, per `00-source.md`). What: adding an item computes and displays
a correct per-row Total Cost and a cart-wide Sub Total that is exactly the sum of the visible
rows, and removing a row must recompute that Sub Total to match what remains, with "Proceed to
Checkout" gated only on the cart being non-empty. Why: the cart is the arithmetic ledger the
shopper trusts before paying — a wrong subtotal (over- or under-counted) either overcharges the
shopper or under-collects for the store, and a "Proceed to Checkout" that is reachable when it
shouldn't be (or blocked when it shouldn't be) breaks the one gate between browsing and paying.
Main risk if it misbehaves: a silently wrong Sub Total is worse than a UI glitch, because unlike a
missing button, an incorrect total can go unnoticed by the shopper and only surfaces at payment —
the same "silent-wrongness is worse than an honest refusal" asymmetry as prior campaign runs, now
in a plain arithmetic form rather than an access-control one.

## Ambiguity hunt

**Q1 — repeat add of the same item.** No source states whether clicking "Add to Cart" for `EST-1`
a second time increments the existing row's Quantity to 2 (Total Cost `$33.00`) or creates a
second, duplicate row. A live re-check via `WebFetch` could not resolve this (stateless fetch,
session cookie not held across calls — recorded in `00-source.md`).
- Classification: step 3, a safe default exists (standard shopping-cart behavior increments the
  existing row's quantity rather than duplicating it — the "Quantity" column header only makes
  sense under this reading) → **`[assumption]`**, `@low-confidence` (the alternative, JPetStore 6
  historically treats each `addItemToCart` call as increment-or-insert on `itemId`, consistent
  with this default, but not independently confirmed live here).

**Q2 — editable quantity after adding.** No "Update Cart" button or quantity input was observed on
the one non-empty cart state captured. Is the cart genuinely add/remove-only (no in-place quantity
edit), or does an editable control exist in a state not captured (e.g. only after a second add)?
- Classification: step 3, safe default exists (treat the cart as add/remove-only for this slice,
  consistent with every button actually observed: "Remove" and "Proceed to Checkout", no
  "Update") → **`[assumption]`**.

**Q3 — does an out-of-stock item (`In Stock? = false`, observed on `EST-1`) block "Proceed to
Checkout"?** No source states this. This is a genuine business-policy question (some stores let a
shopper add and even pay for a backordered item; others block it at checkout) — not a mechanically
forced consequence either way.
- Classification: step 3's "reasonable practitioner" test does not land cleanly here — allowing
  checkout with an out-of-stock item is a real, common pattern (backorder/pre-order), so "block
  it" is not an obviously safe default the way "reject a malformed date" was in prior runs →
  **`[open]`**.

**Q4 — removing an item, then attempting to remove it again (double-submit / stale link).** No
source states whether a second "Remove" click on an already-removed row (e.g. via a stale rendered
page or double-click) errors, no-ops, or is even reachable given the row disappears from the page.
- Classification: step 3, a safe default exists (a no-op/idempotent removal — the row is simply
  already gone, nothing to remove — rather than a hard error) → **`[assumption]`**,
  `@low-confidence`.

**Q5 — empty-cart-after-last-remove.** No source directly confirms that removing the only item in
the cart re-shows the exact "Your cart is empty." / "Sub Total: $0" state captured for a genuinely
never-populated cart, rather than some other transitional empty state.
- Classification: step 3, safe default exists (AC2 already states the empty-cart shape; removing
  down to zero items should converge to the same state) → **`[assumption]`**.

**Q6 — currency arithmetic / rounding.** No source states the rounding rule if a Sub Total sum
produces a sub-cent value (not observed with the one price sampled, `$16.50`, but not ruled out for
other catalog items).
- Classification: step 3, safe default exists (standard two-decimal-place currency rounding,
  round-half-up or banker's — the exact tie-break is not itself testable without a source price
  landing exactly on a half-cent) → **`[assumption]`**, `@low-confidence`. Standardized domain
  (ISO 4217, USD, 2 decimal places) — flagged for the oracle sub-step.

**Q7 — cart session isolation (access-boundary-shaped).** No source states whether the cart is
strictly scoped to the shopper's own browser session (cookie-based, per classic JPetStore 6
behavior) with no cross-session leakage, or whether any session/URL parameter could expose or
mutate another shopper's cart.
- Classification: per the mandatory adversarial pass rule ("access boundary → question, never
  assumption"), this is an access-boundary point no source explicitly confirms →
  **`[open]`**, never defaulted to "obviously session-isolated."

## Adversarial pass (by AC type — mandatory)

- **State machine / lifecycle**: the cart's per-item state is `absent → present → absent` (add /
  remove). Re-entrance is exactly **Q1** (adding the same item again while already present) and
  **Q4** (removing an already-absent item again). No other transitions are documented (no
  "pause"/"save for later" state observed).
- **Auth / tokens / permissions**: this slice is deliberately guest-scoped (no sign-in required,
  per `00-source.md` dependencies) — the closest analog to an auth boundary is **Q7** (session
  isolation of the cart itself), correctly treated as `[open]` rather than assumed safe.
- **Sorting / pagination**: not applicable — the cart is a single small table with no sort/filter
  control observed on any fetched page, and the catalog-side list/filter behavior is out-of-slice
  (`00-source.md` dependencies). Waived.
- **Thresholds / quantities**: **Q6** (currency rounding boundary). No numeric quantity-limit
  boundary was found to test (no max-quantity-per-item control was observed — consistent with Q2's
  finding that no quantity-edit mechanism exists at all in this captured state).

## Cross-AC interaction pass (mandatory)

AC1 (add computes a correct row Total Cost) and AC2 (Sub Total is the sum of all rows) intersect
exactly at **Q1**: if a repeat add increments quantity (the assumed default) the row's own Total
Cost must scale (`price × quantity`) and the Sub Total must reflect that scaled total, not a
second `$16.50` line — getting this wrong is silently plausible either way (a
duplicate-row-summed-correctly cart *looks* right in the Sub Total even if the row model is wrong,
which is exactly the "converged, confident, wrong" failure mode `istqb-design`'s own guardrail
warns about). AC3 (remove recomputes Sub Total) intersects AC2 at the mirror case: removing one
row of a multi-row cart must subtract exactly that row's Total Cost, never the whole prior Sub
Total or a stale cached value.

## Triple-AC contradiction pass (mandatory)

No matching pattern in this US: the mandatory triplet shape (a *restricted/protected-state* rule +
a *scoping* rule + an *anti-disclosure/error-shape* rule all meeting on the same entity) requires a
resource whose existence/state a rule can legitimately hide from an unauthorized viewer. This
slice's cart has no such protected-state entity — the closest candidate, the out-of-stock flag
(Q3), is a **business-policy** question (block checkout or not), not an access-disclosure one (the
`In Stock?` value is already shown openly to the shopper who added it, nothing is being hidden at
a boundary). **Not applicable here** — recorded per the skill's own rule to state this explicitly
rather than leave the section silently absent.

## Q&A log

| ID | Question | Status | Resolution |
|---|---|---|---|
| Q1 | Repeat add of the same item — increment existing row vs. new row | `[assumption]`, `@low-confidence` | Increments the existing row's Quantity (and its Total Cost scales accordingly) |
| Q2 | Editable quantity after adding | `[assumption]` | No in-place quantity edit exists in this slice; cart is add/remove-only |
| Q3 | Out-of-stock (`In Stock? = false`) item blocking "Proceed to Checkout" | `[open]` | No default asserted with confidence — proposed default (checkout still allowed) generated as `@low-confidence`, human arbitration required |
| Q4 | Removing an already-removed item again (double-submit/stale link) | `[assumption]`, `@low-confidence` | No-op/idempotent, no hard error |
| Q5 | Empty-cart-after-last-remove converges to the same empty state as AC2 | `[assumption]` | Yes — "Your cart is empty." / "Sub Total: $0" |
| Q6 | Currency rounding for Sub Total sums | `[assumption]`, `@low-confidence` | Standard two-decimal USD rounding (ISO 4217) |
| Q7 | Cart session isolation across shoppers (access-boundary-shaped) | `[open]` | No default asserted; human arbitration required |

## Journey

| Step | Status |
|---|---|
| 02-understanding | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) |

## Skill evaluation — `need-understanding`

- **Skill evaluated**: `plugins/qaia-core/skills/need-understanding/SKILL.md`.
- **Input**: `01-extraction.md` above (3 ACs, live-UI-only source, several unconfirmed behaviors
  already flagged at extraction).
- **Output**: this file.
- **Verdict**: **CONFORME.**
- **Evidence**: both mandatory trace sections the skill's own guardrail calls out (line 48:
  "Omitting the required trace of step 3 or step 4a... is the same defect as silently resolving an
  ambiguity") are present as their own headed sections (`## Adversarial pass` and `## Triple-AC
  contradiction pass`), each stating a finding rather than a bare "not applicable" — including the
  triple-AC pass, which is correctly marked "not applicable" *with a stated reason* (no
  protected-state/anti-disclosure entity exists in this slice) rather than omitted, and the
  sorting/pagination adversarial bullet, same treatment. The access-boundary rule (line 26: "never
  assert... when the source implies public read access") is respected by Q7 landing on `[open]`
  rather than an assumed "obviously session-isolated." The classification tree (line 30) was
  applied case-by-case: Q3's "no safe default" reasoning explicitly distinguishes a genuine
  business-policy fork (out-of-stock checkout) from a mechanically-forced default, matching the
  tree's step-3 "reasonable practitioner" test rather than a reflexive assumption.
- **Modification proposed**: none.
