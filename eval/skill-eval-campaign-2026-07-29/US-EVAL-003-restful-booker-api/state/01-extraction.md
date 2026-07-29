# 01-extraction — US-EVAL-003

## Story `[reconstructed]`

**As an** API client of the Restful-Booker-Platform booking service,
**I want** `POST /booking/` to persist a new room booking only when its fields are well-formed,
its stay dates are a valid range, and it does not collide with an existing booking for the same
room,
**so that** every booking the system holds is guaranteed internally consistent (no inverted/
same-day stays, no double-booked rooms) without relying on client-side checks.

*(Not expressed as a story in the source — this is source code, not a ticket. Reconstructed from
`BookingController.createBooking` + `BookingService.createBooking` + the two validation layers
they call, per `us-review` step 1's `[reconstructed]` license for a real capability with no story
phrasing.)*

## Acceptance criteria (numbered, stable — AC1..AC5)

- **AC1.** A `POST /booking/` request with all required fields well-formed (`roomid` ≥ 1,
  `firstname` 3-18 chars non-blank, `lastname` 3-30 chars non-blank, `depositpaid` present,
  `bookingdates.checkin` strictly before `bookingdates.checkout`) **and** no overlapping existing
  booking on that `roomid` succeeds: **HTTP 201**, body `{bookingid, booking: {...}}` echoing the
  persisted fields.
- **AC2.** A request violating a field-level constraint (`roomid` < 1; `firstname`/`lastname`
  blank or outside its size range; `depositpaid` absent; `bookingdates` absent) is rejected:
  **HTTP 400**, body listing the offending field(s) (exact message text for `roomid`/`depositpaid`
  not confirmed by source — see open point below).
- **AC3.** A request whose `bookingdates.checkin` is not strictly before `bookingdates.checkout`
  (equal dates, or checkout before checkin) is rejected: **HTTP 409** (no distinguishing body —
  same status as AC4's collision case).
- **AC4.** A request for a `roomid` whose date range overlaps an existing booking on that same
  room is rejected: **HTTP 409** (no distinguishing body from AC3).
- **AC5.** When present, `email` must be a well-formed email address and `phone` must be 11-21
  characters; a malformed optional field is rejected the same way as AC2 (**HTTP 400**).

## Business rules / constraints found outside the AC list

- `createBooking` (`POST /booking/`) does **not** require the `token` cookie that gates
  `getBookings`/`getIndividualBooking`/`updateBooking`/`deleteBooking` on the same controller —
  creation is intentionally open, not behind the platform's auth check. Noted so downstream design
  does not invent an auth-gated AC for this specific endpoint.
- AC3 and AC4 share the exact same HTTP status (409) with no differentiating response body — a
  client cannot programmatically tell "bad date range" from "room double-booked" from the response
  alone. This is a real characteristic of the API, not a gap in this extraction.

## Referenced artifacts not analyzed

- The platform's `room`, `auth`, and `message` microservices (out-of-slice, see `00-source.md`
  dependencies).

## Present but not classifiable

- None.

## What was NOT found

- Exact `fieldErrors[]` message text for `roomid`'s `@Min(1)` and `depositpaid`'s `@NotNull`
  violations — no custom `message` attribute set in source for either, so Spring's default Bean
  Validation message applies; not read from source, **not asserted verbatim** in AC2/AC5-derived
  scenarios (kept qualitative: "an error naming the offending field"). Carried to
  `need-understanding` as an open point, not invented here.

## Journey

| Step | Status |
|---|---|
| 00-ingest | done |
| 01-review | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) |

## Skill evaluation — `us-review` (`plugins/qaia-core/skills/us-review/SKILL.md`)

**Verdict: CONFORME.**

**Evidence**: Step 1 (line 13) requires marking a reconstructed story `[reconstructed]` when the
source has no story phrasing — done in the "Story" heading above, exactly the marker the
2026-07-29 footnote on that same line says was previously skipped. Step 1's AC numbering (line 14)
is stable (`AC1`..`AC5`), matching guardrail line 25 ("every AC gets a stable number here... never
renumber after validation"). Step 2 (line 18) requires explicitly listing what was NOT found —
done in its own section, and the thin-but-real-capability carve-out on line 18 correctly does not
fire the not-a-spec gate here (this is a real, richly-specified capability, not a non-spec). No
deviation found. **Modification proposed: none.**
