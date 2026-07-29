# 03-design — US-EVAL-003

## AC → technique map

- **AC1** (well-formed request, no conflict → 201) → **Equivalence partitioning** (one representative
  of the "all-valid" class) + **Boundary Value Analysis** on every sized/dated field (`firstname`
  3-18, `lastname` 3-30, `checkin < checkout`) — the AC's own shape is a set of size/date
  thresholds, so BVA is the natural fit alongside the EP happy path.
- **AC2** (field-shape violation → 400) → **Equivalence partitioning** (blank-name class) +
  **Boundary Value Analysis** (each `@Size`/`@Min` threshold, value and value±1) — one BVA pass
  per independently-constrained field, per CTAL-TA's own BVA guidance, not opportunistic pairs.
- **AC3** (invalid date range → 409) → **Boundary Value Analysis** on the `checkin < checkout`
  boundary (equal-date and inverted-range are the two sides of the same strict-inequality bound).
- **AC4** (room double-booking → 409) → **Decision Table Testing**, crossed with AC3 — see the
  table below: "field-shape valid?" × "date-range valid?" × "room conflict?" is a genuine 3-axis
  combination (Q3 from `02-understanding.md` makes the first two axes non-independent: a field
  failure short-circuits before the date/conflict checks ever run), not two independent EP passes.
- **AC5** (optional `email`/`phone` format → 400) → **Equivalence partitioning** (well-formed vs
  malformed) grounded by the **RFC 5322 oracle** (step 3b below) for `email`, **Boundary Value
  Analysis** for `phone`'s `@Size(min=11, max=21)`.

## Decision table (field-shape × date-range × room-conflict)

| Field-shape valid? | Date-range valid? (only evaluated if field-shape valid, per Q3) | Room conflict? (only evaluated if date-range valid) | Outcome | Condition |
|---|---|---|---|---|
| No | — | — | 400 | AC2-* / AC5-* |
| Yes | No | — | 409 | AC3-C1/C2 |
| Yes | Yes | Yes | 409 | AC4-C1 |
| Yes | Yes | No | 201 | AC1-C1 |
| No **and** date-range also invalid (both apply at once) | — | — | 400 (field-shape wins, Q3) | AC-DT-1 |

## Test conditions

### AC1 — success path
- **AC1-C1** `[ep]` — all fields valid, no conflict → 201, body echoes submitted fields +
  assigned `bookingid`.
- **AC1-C2** `[bva]` — `firstname`/`lastname` at their **minimum** valid length (3 chars each) →
  201 (boundary inclusive, confirmed by `@Size` semantics, not an assumption).
- **AC1-C3** `[bva]` — `firstname`/`lastname` at their **maximum** valid length (18 / 30 chars) →
  201.
- **AC1-C4** `[bva]` — `checkin` exactly one day before `checkout` (minimal valid stay) → 201.
- **AC1-C5** `[assumption]` `@low-confidence` (Q1) — a syntactically valid but not-necessarily-real
  `roomid` (e.g. a very large integer) with everything else valid → 201, per Q1's proposed default
  that this service does not check room existence. Flagged, not asserted with full confidence.

### AC2 — field-shape violations → 400
- **AC2-C1** `[bva]` `[req-neg]` — `roomid` = 0 (below the `@Min(1)` bound) → 400,
  `fieldErrors[]` names `roomid` (exact message text not asserted, per Q2).
- **AC2-C2** `[bva]` `[req-neg]` — `firstname` at 2 chars (min − 1) → 400.
- **AC2-C3** `[bva]` `[req-neg]` — `firstname` at 19 chars (max + 1) → 400.
- **AC2-C4** `[ep]` `[req-neg]` — `firstname` blank/empty → 400, `fieldErrors[]` contains
  **"Firstname should not be blank"** (verbatim — confirmed by the `@NotBlank(message=...)`
  literal in source, not an assumption).
- **AC2-C5** `[bva]` `[req-neg]` — `lastname` at 2 chars (min − 1) → 400.
- **AC2-C6** `[bva]` `[req-neg]` — `lastname` at 31 chars (max + 1) → 400.
- **AC2-C7** `[ep]` `[req-neg]` — `lastname` blank/empty → 400, `fieldErrors[]` contains
  **"Lastname should not be blank"** (verbatim, confirmed).
- **AC2-C8** `[ep]` `[req-neg]` — `depositpaid` absent from the payload → 400 (field name in
  `fieldErrors[]`, message not asserted per Q2).
- **AC2-C9** `[ep]` `[req-neg]` — `bookingdates` absent from the payload → 400.

### AC3 — invalid date range → 409
- **AC3-C1** `[bva]` `[req-neg]` — `checkin` == `checkout` (same-day, 0-night stay) → 409.
- **AC3-C2** `[bva]` `[req-neg]` — `checkin` after `checkout` (inverted range) → 409.

### AC4 — room double-booking → 409 (and its cross-AC negative control)
- **AC4-C1** `[decision-table]` `[req-neg]` — a second booking for the same `roomid` with a date
  range overlapping an already-persisted booking → 409.
- **AC4-C2** `[decision-table]` — a second booking with the **same/overlapping dates** but a
  **different** `roomid` than the existing booking → 201 (per the cross-AC finding in
  `02-understanding.md`: the conflict check is `roomid`-scoped, confirmed by source).

### AC5 — optional field format, grounded by the RFC 5322 oracle (step 3b)
- **AC5-C1** `[oracle:rfc5322]` `[req-neg]` — `email` = `"user@"` (RFC-5322-invalid, from the
  oracle's own invalid corpus) → 400.
- **AC5-C2** `[oracle:rfc5322]` — `email` = `"user+tag@example.com"` (RFC-5322-valid, from the
  oracle's own valid corpus) → 201, `email` persisted as submitted.
- **AC5-C3** `[bva]` `[req-neg]` — `phone` at 10 chars (min − 1) → 400.
- **AC5-C4** `[bva]` `[req-neg]` — `phone` at 22 chars (max + 1) → 400.
- **AC5-C5** `[bva]` — `phone` at exactly 11 chars (min boundary) → 201.

### Cross-cutting: Q3 ordering (field-shape vs. date-range, both invalid at once)
- **AC-DT-1** `[decision-table]` `[req-neg]` `[assumption]` `@low-confidence` (Q3) — `firstname`
  blank **and** `checkin == checkout` in the same request → 400 (field-shape check wins per Q3's
  proposed default — Spring's `@Valid` binding runs before the service's own date check), **not**
  409. Human arbitration flagged: this rests on standard Spring MVC framework semantics, not a
  literal statement in `Booking.java`/`BookingController.java`.

## 3b — Standardized domains → oracle (`oracle-generate`, applied)

Two standardized domains are touched: **email** (`AC5`, RFC 5322) and **HTTP status semantics**
(all ACs, RFC 9110 — `400`/`409`/`201` already correctly assigned per the built-in oracle's own
mapping: "malformed body/params → 400", "conflict / already exists / race lost → 409"). Applied:
`AC5-C1`/`AC5-C2` use the oracle's own canonical invalid/valid email corpus (`user@`,
`user+tag@example.com`) verbatim rather than an invented string — tagged `@oracle:rfc5322` above.
`phone` has no RFC/ISO standard in the library (it is a free-form sized string in this API, not a
validated E.164 number) — not forced into an oracle it doesn't have; handled by plain BVA instead
(`AC5-C3..C5`). No project OpenAPI/JSON Schema file was designated for this campaign run, so the
project-oracle sub-section (`oracles/openapi.md`) is correctly not invoked — the built-in library
alone grounds this.

## 3c — Systematic coverage expansion (each pattern's outcome stated, none silently absent)

- **List/collection view**: not applicable — `POST /booking/` creates a single resource; no
  list/sort/filter/pagination surface exists in this slice.
- **Full CRUD lifecycle**: **waived** — `GET`/`PUT`/`DELETE /booking/{id}` exist on the same
  controller but are explicitly out-of-slice (`00-source.md` dependencies: this US-slice is
  scoped to creation only, per the parent campaign brief). Not designed here, not silently
  dropped either — named as the reason.
- **Conditional behavior (decision table over variation axes)**: **applied** — the field-shape ×
  date-range × room-conflict decision table above is exactly this pattern; no config/role/
  visibility axis exists in this slice (creation has no feature flag or ownership dimension
  visible in the read source).
- **Authorization & server-side enforcement**: **partially applicable, resolved by source, not a
  gap** — `createBooking` has no `token`-cookie check (confirmed in `00-source.md`/
  `02-understanding.md`), so "unauthenticated access" is **not** a negative condition here (public
  by design, not an oversight) and cross-tenant/IDOR does not apply (no ownership model on a
  booking in this slice). The one real member of this pattern that **does** apply is
  **uniqueness/constraint violation** — already captured as `AC4-C1` (double-booking).
- **Enumerate every list/aggregation view**: not applicable, same reason as "list/collection view."
- **Sibling collections of a named entity**: not applicable — a `Booking` does not describe itself
  as "a collection of X" in this slice; no roll-up entity is implied.
- **Account & auth recovery path**: not applicable — this endpoint is not an authentication/account
  feature (no login, password, or account-recovery concept exists on `POST /booking/`); the
  pattern's trigger (account & auth features) is not matched.

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

**Evidence**: Step 5's checkpoint rule (line 98, reinforced by the guardrail footnote on line 103
from the 2026-07-29 campaign) requires every sub-step of 3b/3c/3d to appear with its outcome —
applied or explicitly waived with a reason — never silently absent. This checkpoint states an
outcome for all seven 3c patterns (four "not applicable" with a stated reason, one "waived" with a
named reason, two "applied") plus 3b (applied, with the one non-fit — `phone` — explicitly named
as "no RFC/ISO standard... not forced into an oracle it doesn't have") and 3d (absent, stated
plainly). This is exactly the defect the 2026-07-29 footnote on line 103 previously found missing
for a different US (the auth-recovery pattern silently skipped there) — here the same pattern
(auth recovery) is present and explicitly marked not applicable with its trigger-mismatch reason,
not silently dropped. Step 3's negative-pressure tagging (line 75) is applied to every
refusal-capable condition (`[req-neg]` on all 400/409 conditions). Step 3b (line 76) was correctly
invoked given a real standardized-domain match (email), not skipped as a reflex "not applicable"
the way US-EVAL-001 correctly skipped it for a domain with no standardized field. No deviation
found. **Modification proposed: none.**
