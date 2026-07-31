# 03-design — US-EVAL-010

## AC → technique map

- **AC1** (owner request succeeds) → **Equivalence Partitioning** — the single "caller is the
  vehicle's owner" valid class.
- **AC2** (cross-owner request denied) → **Decision Table Testing (§3.3.1)** — this is the
  `istqb-design` 3c reflex pattern "Authorization & server-side enforcement," specifically its
  **cross-tenant access (IDOR)** cell, crossed with **AC3**'s authentication axis below into one
  table. Also error-guessing-adjacent (§3.4.2): BOLA/IDOR is the textbook error-guessing catalog
  item for any object-ID-bearing endpoint.
- **AC3** (no/invalid auth denied) → **Equivalence Partitioning** (two invalid classes: missing
  token, invalid/expired token) + the same 3c "unauthenticated access" cell.
- **AC4** (GUID space is not itself a control) → not a separate technique; it shapes the **test
  data** for AC2/AC2's decision table (the "other owner's `vehicleId`" must be a real, valid GUID
  obtained out-of-band, never an incremented integer — testing "GUIDs can't be counted" would be a
  non-finding given the source's own premise) and motivates a distinct **Error Guessing** condition
  for a syntactically-valid-but-nonexistent GUID (AC4-C1 below), the "not found" partition Q3
  raised in `02-understanding.md`.

## Decision table (built before deriving conditions, per State-Transition/Decision-Table CT-MBT
## discipline analogue — cross the two real axes explicitly)

| Authenticated? | Caller relation to `vehicleId` | Expected outcome | Condition |
|---|---|---|---|
| No | (n/a — auth checked first) | Deny, no location in body | AC3-C1/AC3-C2 |
| Yes | Owner of `vehicleId` | Allow, `200` + location | AC1-C1 |
| Yes | Different user's real `vehicleId` | Deny, no location in body | AC2-C1/AC2-C2 |
| Yes | `vehicleId` does not exist at all | Deny, no location in body | AC4-C1 |

Authentication is evaluated before authorization (`02-understanding.md` cross-AC pass), so the
table's first row short-circuits the other two axes — matching how the source's own two challenges
(this one, and the separate Challenge 14 "no auth check" endpoint) are independent defect classes,
not the same code path.

## Test conditions

### AC1 — owner access
- **AC1-C1** `[ep]` — authenticated as the vehicle's owner, requesting that owner's own
  `vehicleId`: response is `200`, body contains that vehicle's location (latitude, longitude).

### AC2 — cross-owner denial (the core BOLA condition)
- **AC2-C1** `[decision-table]` — authenticated as user A, requesting user B's real `vehicleId`:
  response body does **not** contain B's vehicle's actual coordinates under any field name (not
  merely "the top-level `location` field is absent" — the sniffer/completeness discipline requires
  checking the whole body, since a BOLA regression could leak the same data under a renamed key).
- **AC2-C2** `[decision-table]` `[assumption]` (Q1) — same request as AC2-C1: response status is
  `404` (the adopted anti-disclosure default from the Triple-AC pass), not `200` and not `403`.
  `@low-confidence` — the underlying "must not leak" assertion (AC2-C1) is not in doubt, only this
  exact status code.

### AC3 — authentication required
- **AC3-C1** `[ep]` — no authentication token at all, requesting any `vehicleId`: response is not
  `200`, body contains no location data.
- **AC3-C2** `[ep]` — an invalid/expired token, requesting any `vehicleId`: same denial as AC3-C1
  (folded per `02-understanding.md`'s adversarial pass: the outcome, not the diagnostic detail, is
  what this AC set asserts).

### AC4 — GUID space is not a control (informs AC2's data + one distinct condition)
- **AC4-C1** `[error-guessing]` `[assumption]` (Q3) — authenticated, requesting a syntactically
  well-formed GUID that does not correspond to any existing vehicle: response is `404`, no location
  data — same status as AC2-C2, a deliberate convergence (Triple-AC pass) so "wrong owner" and "no
  such vehicle" are indistinguishable to the caller.

## Negative pressure (ADR 0001)

**Three of the four in-scope conditions are `[req-neg]`**: AC2-C1, AC2-C2 (a refusal/denial path —
the entire point of this US), AC3-C1, AC3-C2 (authentication refusal), AC4-C1 (not-found refusal).
Only AC1-C1 is a positive/happy-path condition. This is the **inverse** shape of `US-EVAL-006`'s
honest-zero finding — flagged here for contrast, not because the rubric requires balance: a
security-authorization US-slice is *expected* to skew heavily toward refusal paths, and forcing
extra happy-path conditions to "balance" the set would be the wrong response to this AC set's real
risk shape.

## 3b — Standardized domains → oracle (`oracle-generate`)

**Applicable, not invoked this run.** HTTP status codes are named as one of `istqb-design`'s own
example standardized domains (3b). AC2-C2/AC4-C1's expected `404` and AC1-C1's expected `200` are
conventional REST semantics, not fabricated — but a dedicated `oracle-generate` pass (which would
also enumerate the full conventional status-code space: `401` vs `403` for AC3, edge cases like
`400` for a malformed GUID) was **not run**, since it sits outside this campaign's canonical
7-skill path (`docs/SKILL-EVAL-CAMPAIGN-PROMPT.md` lists the seven skills exercised; `oracle-generate`
is not one of them). Recorded here rather than silently skipped, per this step's own checkpoint
requirement.

## 3c — Systematic coverage expansion

- **List/collection view**: not applicable — a single-resource lookup, no set of items.
- **Full CRUD lifecycle**: not applicable — this slice is read-only (`GET`); no create/update/
  delete of a vehicle or its location is described by the source.
- **Conditional behavior (decision table)**: **applied** — see the decision table above, crossing
  authentication × ownership-relation, the two real axes this endpoint has.
- **Authorization & server-side enforcement**: **applied, and this pattern's own examples are
  exactly this US's content** — unauthenticated access → AC3; cross-tenant access (IDOR) → AC2;
  the "UI-bypass" example (the rule must hold even when sent directly, not through a UI) is
  **already trivially satisfied and not a distinct condition**, since crAPI's vehicle-location
  endpoint is a pure API with no UI layer in front of it to bypass in the first place — every
  scenario in this book *is* a direct API call by construction. "Permission denied (wrong role)"
  and "uniqueness/constraint violation" do not apply — the source describes no role hierarchy or
  uniqueness rule on this endpoint, only per-owner scoping.
- **Enumerate every list/aggregation view**: not applicable, same reason as "list/collection view."
- **Sibling collections of a named entity**: not applicable — a vehicle's location is a scalar
  attribute pair (lat/long), not described as itself a collection, and the source names no
  sub-collection rolling up here.
- **Account & auth recovery path**: not applicable — this is a resource-access-control feature
  (object-level authorization on an existing session), not a login/account-recovery feature; no
  password-reset/forgot-account flow is in scope for this slice (that is crAPI's own separate
  Challenge 3, explicitly out-of-slice per `00-source.md`).

## 3d — Knowledge-driven conditions

`.qaia/knowledge/` does not exist for this campaign directory — recorded per shared-contract rule
8, proceeding on the source alone (no `BR-KB-nnn` rules applied; `design.knowledgeApplied` will be
empty in the manifest).

## Journey

| Step | Status |
|---|---|
| 03-design | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) |

## Skill evaluation — `istqb-design` (`plugins/qaia-core/skills/istqb-design/SKILL.md`)

See separate evaluator pass (spawned after this checkpoint).
