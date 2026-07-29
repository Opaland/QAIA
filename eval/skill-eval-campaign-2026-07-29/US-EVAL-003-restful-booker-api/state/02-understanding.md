# 02-understanding — US-EVAL-003

## Reformulation

Who: any API client (a booking front-end, a partner integration, a test harness) calling
`POST /booking/`. What: the booking service must persist a new booking only when every field
passes its own validation rule, the stay's `checkin` date is strictly before `checkout`, and the
requested room has no overlapping existing booking — and must reject with the correct status
(400 for field-shape errors, 409 for date/collision errors) otherwise. Why: this is the single
write path that creates the data every other booking endpoint (`GET`, `PUT`, `DELETE`, `summary`)
reads and mutates — a leak here (an invalid range or a double-booked room silently persisted)
corrupts every downstream read, not just this call. Main risk if it misbehaves: a room booked
twice for overlapping dates (a business-integrity failure visible to a real guest) is worse than a
false rejection of a valid booking (an availability annoyance) — asymmetric severity, feeds
`prioritize`.

Knowledge base: `.qaia/knowledge/` does not exist for this campaign directory — recorded per
shared-contract rule 8 ("degraded modes are explicit"), proceeding on the source alone.

## Ambiguity hunt

**Q1 — `roomid` referential validity.** `Booking.java`'s only constraint on `roomid` is `@Min(1)`
(a syntactic lower bound). Nothing in the `booking` service's source calls the platform's separate
`room` microservice to confirm the `roomid` actually corresponds to a real room before persisting.
No source read confirms whether an out-of-range/nonexistent `roomid` (e.g. `99999`) is accepted or
rejected by this service.
- Classification: step 3 of the decision tree — a safe default exists (each microservice of this
  platform owns one concern; this booking service's own code has no cross-service call for this
  check, so the safe, source-grounded default is that it does **not** validate room existence,
  only the syntactic `≥1` bound) → **`[assumption]`**. Scenarios below use a syntactically valid
  but not-necessarily-real `roomid` and do not assert an existence check.

**Q2 — exact validation-error message text for `roomid`/`depositpaid`.** `firstname`/`lastname`
carry an explicit `message = "..."` attribute on their constraints; `roomid`'s `@Min(1)` and
`depositpaid`'s `@NotNull` do not — Spring Bean Validation's default message would apply, but its
exact wording is not part of this service's own source and was not separately confirmed.
- Classification: step 3, safe default exists (asserting only "the field appears in
  `fieldErrors[]`" is the low-risk choice; asserting the exact default-message string would be an
  unconfirmed literal) → **`[assumption]`**. Scenarios assert the field name appears in the error,
  not the exact message text, for these two fields only (the two with explicit `message=` text
  are asserted verbatim, since that part **is** confirmed by source).

**Q3 — check ordering when a bean-validation failure (AC2/AC5) and an invalid date range (AC3)
both apply to the same request.** `BookingService.createBooking`'s own code only runs *after*
Spring's `@Valid @RequestBody` binding succeeds — bean-validation failures short-circuit at the
framework layer, before `BookingService.createBooking`'s date check ever executes. This ordering
is standard Spring MVC `@Valid` semantics (validated in argument resolution, before the controller
method body runs), not something stated inside `BookingController.java`/`Booking.java` themselves.
- Classification: step 2 exception applies — this is mechanically forced by the framework
  contract Spring itself guarantees for `@Valid @RequestBody`, not a product policy choice, so the
  money/policy-style escalation to `[open]` does not fit → step 3, **`[assumption]`**: a request
  violating both a bean constraint and the date-range rule returns **400** (bean validation wins),
  never 409.

## Adversarial pass (by AC type)

- **State machine / lifecycle**: not applicable — a booking has no lifecycle states visible in
  this slice (creation only; update/cancel/delete are out-of-slice per `00-source.md`).
- **Auth / tokens / permissions**: confirmed by source, not ambiguous — `createBooking` has no
  `@CookieValue` parameter, unlike its sibling endpoints on the same controller; this is a
  deliberate asymmetry in the real code, not a gap. No question raised (already recorded as a
  business rule in `01-extraction.md`).
- **Sorting / pagination**: not applicable — creation returns a single resource, no list/paging
  in this slice.
- **Thresholds / quantities (inclusive/exclusive at every bound)**: `@Size(min=3, max=18)` /
  `@Size(min=3, max=30)` on `firstname`/`lastname` are standard Jakarta Bean Validation semantics
  — both bounds **inclusive** (confirmed by the annotation's own documented contract, not
  ambiguous): 3 and 18/30 chars pass, 2 and 19/31 chars fail. `checkin < checkout` (strict,
  `compareTo(...) < 0`) means an **equal-date** range (0-night stay) is invalid — confirmed by
  source, not ambiguous. These boundaries feed `istqb-design`'s BVA technique directly, no `[open]`
  needed since both are literal, unambiguous constraints in the read source.

## Cross-AC interaction pass

- **AC1 × AC4 (room-scoping)**: `checkForBookingConflict`'s query is parameterized by `roomid`
  (`ps.setInt(7, bookingToCheck.getRoomid())`) — an overlapping date range on a *different* room
  does not block a new booking. Confirmed by source, not ambiguous: two bookings with identical
  dates on two different `roomid`s both succeed.
- **AC3 × AC4 (which 409 "wins" when both apply)**: `BookingService.createBooking` checks
  `dateCheckValidator.isValid` first; only when dates are valid does it call
  `checkForBookingConflict`. So an invalid-range request is rejected on the date check alone,
  never reaching the collision check — confirmed by source. **Not independently observable
  black-box**, though: both branches return the same 409 with no distinguishing body (already
  noted in `01-extraction.md`'s business rules) — the ordering is real but invisible to a client,
  so no scenario below claims to distinguish the two causes from the response alone.
- **AC2/AC5 × AC3 (which status wins)**: this is Q3 above — logged there, not duplicated.

## Triple-AC contradiction pass

No triplet of a *protected/restricted-state* rule, a *filtering/scoping* rule, and an
*anti-disclosure/error-shape* rule applies to this slice — this US has no protected-state entity,
no scoped filtering, and no existence-disclosure concern (creation of a new resource, not lookup
of an existing one where "not found" vs "not authorized" could conflate). **Not applicable, no
matching pattern in this US** — the calibration example (patient-results/org-scope/404-avoidance)
requires a lookup-and-disclosure shape this creation-only slice does not have.

## Q&A log

| ID | Question | Status | Resolution |
|---|---|---|---|
| Q1 | Does the booking service validate that `roomid` refers to a real room? | `[assumption]` | No — only the syntactic `≥1` bound is checked by this service's own code; scenarios use a syntactically valid `roomid` without asserting existence-checking |
| Q2 | Exact error message text for `roomid`/`depositpaid` violations | `[assumption]` | Not asserted verbatim (only confirmed for `firstname`/`lastname`, which have explicit `message=` text); scenarios assert the field name appears in `fieldErrors[]` |
| Q3 | Which status wins when a bean-validation failure and an invalid date range both apply | `[assumption]` | 400 wins (Spring's `@Valid` binding runs before the service's date check) |

## Journey

| Step | Status |
|---|---|
| 02-understanding | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) |

## Skill evaluation — `need-understanding` (`plugins/qaia-core/skills/need-understanding/SKILL.md`)

**Verdict: CONFORME.**

**Evidence**: Step 3 (line 20) and step 4a (line 28) both require an explicit, checkable section
even when "not applicable" — done above ("## Adversarial pass" and "## Triple-AC contradiction
pass" sections both present with an explicit "not applicable, no matching pattern" call where
that's the true finding), exactly what the 2026-07-29 footnote on guardrail line 48 says was
missing in the prior campaign run (found there: "both passes were implicitly touched on... but
never surfaced as their own checkable section"). Step 5a's classification tree (lines 30-36) was
applied in order for all three questions, with the step-2 money/policy exception (line 33)
correctly invoked for Q3 (a mechanically-forced framework behavior, not a policy choice) rather
than defaulting it to `[open]`. Step 8's checkpoint requirements (line 43) are all present. No
deviation found. **Modification proposed: none.**
