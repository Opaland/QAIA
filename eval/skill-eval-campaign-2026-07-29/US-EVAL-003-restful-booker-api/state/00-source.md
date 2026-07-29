# 00-source — US-EVAL-003

- **Source type**: live public repository, **primary source** (Java source code of the API
  implementation itself, not a blog/spec summary), per `docs/SKILL-EVAL-CAMPAIGN-PROMPT.md`'s
  "explore freely on public demos" allowance and the parent campaign brief's instruction to ground
  the US in real endpoints/fields via the target's public docs/repo before writing anything.
  Target: `Restful-Booker-Platform` (`docs/DEMO-TARGETS.md` row, API ✅✅, self-hostable via
  Docker) — specifically its `booking` microservice
  (`github.com/mwinteringham/restful-booker-platform`, branch `trunk`).
- **Capture method**: `WebSearch` to locate the repository and confirm which of the two similarly
  named projects (`mwinteringham/restful-booker` — the older single-service API — vs.
  `mwinteringham/restful-booker-platform` — the microservice SaaS platform named in
  `DEMO-TARGETS.md`) is the actual campaign target, then direct read of the `booking` service's
  Java source via the GitHub REST API / raw content (unauthenticated, public repo, no scraping of
  anything not designated) — not a paraphrase of a secondary write-up.
- **Capture date**: 2026-07-29.
- **Files read (primary source, cited per fact below)**:
  - `booking/src/main/java/com/automationintesting/api/BookingController.java`
  - `booking/src/main/java/com/automationintesting/model/db/Booking.java`
  - `booking/src/main/java/com/automationintesting/service/BookingService.java`
  - `booking/src/main/java/com/automationintesting/service/DateCheckValidator.java`
  - `booking/src/main/java/com/automationintesting/service/MethodArgumentNotValidExceptionHandler.java`
  - `booking/src/main/java/com/automationintesting/model/db/CreatedBooking.java`
  - `booking/src/test/java/com/automationintesting/integration/BookingValidationIT.java`
  - `booking/src/test/java/com/automationintesting/integration/BookingDateConflictIT.java`

- **Captured facts (faithful, not paraphrased into stronger claims than the source supports)**:

  > `POST /booking/` (`BookingController.createBooking`, `@Valid @RequestBody Booking booking`)
  > creates a booking. Request body fields (`Booking.java`): `roomid` (int, `@Min(1)`),
  > `firstname` (String, `@NotBlank`, `@Size(min=3, max=18)`), `lastname` (String, `@NotBlank`,
  > `@Size(min=3, max=30)`), `depositpaid` (boolean, `@NotNull`), `bookingdates` (nested object:
  > `checkin`, `checkout`, both dates), and optional `email` (`@Email` when present) / `phone`
  > (String, `@Size(min=11, max=21)` when present).
  >
  > Bean-validation failures (blank/oversized name, missing `depositpaid`, `roomid < 1`, malformed
  > email/phone) are caught by `MethodArgumentNotValidExceptionHandler` → **HTTP 400**, body
  > `{errorCode, error, errorMessage, fieldErrors[]}` (`BookingValidationIT.testPostValidation`
  > confirms 400 on a payload missing `roomid`/`firstname`/`lastname`/`depositpaid`/`bookingdates`).
  >
  > Date-range validity is a **separate, non-bean-validation check**: `DateCheckValidator.isValid`
  > returns `checkin != null && checkout != null && checkin.compareTo(checkout) < 0` — i.e.
  > checkin must be strictly before checkout (same-day or inverted range is invalid). If invalid,
  > `BookingService.createBooking` returns **HTTP 409 CONFLICT** (not 400) — same status code as a
  > genuine double-booking conflict, and the response carries no body distinguishing the two cases
  > (`BookingService.createBooking`: `if (!dateCheckValidator.isValid(...)) return new
  > BookingResult(HttpStatus.CONFLICT)`, no error payload attached on that branch).
  >
  > Double-booking: `bookingDB.checkForBookingConflict` checks for any other booking on the same
  > `roomid` whose date range overlaps (checkin+1 day .. checkout window against existing
  > bookings) → **HTTP 409 CONFLICT** if found. `BookingDateConflictIT.testBookingConflict`
  > confirms this by POSTing the identical payload (room 1, 2020-02-01→2020-02-02) twice: second
  > POST returns 409.
  >
  > Success: **HTTP 201 CREATED**, body `CreatedBooking { bookingid, booking }` where `booking`
  > echoes the persisted `Booking` (`CreatedBooking.java`).
  >
  > `GET /booking/{id}` and `POST /booking/` for `getBookings`/`getIndividualBooking`/
  > `deleteBooking`/`updateBooking` require a `token` cookie checked by `AuthRequests.postCheckAuth`
  > (→ 403 if absent/invalid) — **`createBooking` itself does not require this cookie** (no
  > `@CookieValue` parameter on that controller method) — noted so the AC set below does not
  > invent an auth requirement the source does not have for *this* endpoint.

- **Not confirmed by any source found**: the exact wording of `fieldErrors[]` entries beyond what
  `@NotBlank`'s `message = "..."` attribute states for `firstname`/`lastname` (no message text is
  set for `roomid`'s `@Min(1)` or `depositpaid`'s `@NotNull`, so Spring's default Bean Validation
  message applies — not read from source, **not asserted verbatim in AC/scenarios below**, kept
  qualitative ("a validation error listing the offending field") rather than fabricated.
- **Redaction**: none needed (public API test fixtures, synthetic names/emails from the repo's own
  integration tests, not real PII).
- **Dependencies (out-of-slice)**: `GET /booking/`, `GET /booking/{id}`, `PUT /booking/{id}`,
  `DELETE /booking/{id}`, `GET /unavailable`, `GET /summary`, and the `auth`/`message`/`room`
  microservices of the same platform are separate concerns of the same platform, not designed
  here — this US-slice is scoped to `POST /booking/` (creation) only, per the parent campaign
  brief's "as an API client, I create a room booking" framing.

## Journey

| Step | Status |
|---|---|
| 00-ingest | done — gates checked (not empty, is a testable capability — a real, running API with
  enforced validation rules, no abuse/illegality, no PII to redact) |

## Skill evaluation — `us-ingest` (`plugins/qaia-core/skills/us-ingest/SKILL.md`)

**Verdict: CONFORME.**

**Evidence**: Step 1 (lines 12-13) requires fetching "exactly that source — nothing else" and, per
the 2026-07-29 footnote already present on line 12, forbids silently substituting a different URL
when the designated one returns nothing usable. Here the designated target was `docs/DEMO-TARGETS.md`'s
`Restful-Booker-Platform` row itself (not a single URL) — the campaign brief explicitly asked to
"explore its public docs/repo via WebFetch first to ground it," which step 1 accommodates as
identifying-the-source research, not a mid-ingestion silent substitution (the distinction the
2026-07-29 footnote actually polices: switching sources *after* one designated fetch comes back
empty, not doing the initial discovery). Step 2's triage gates (line 14-17) were run: not empty,
a real testable capability (a running API with codified validation), no abuse framing. Step 3's
redaction gate (line 18) correctly found nothing to mask. Step 4/6's ⚠ VALIDATION points are
marked `simulated: accepted-as-is` below (no human reviewer in this non-interactive campaign run,
per shared-contract rule 3's `simulated` convention) rather than fabricated as a real human
decision. No deviation found between what step 1-7 literally asks for and what this checkpoint
does. **Modification proposed: none.**

⚠ VALIDATION (US-ID, captured-source confirmation): `simulated: accepted-as-is`.
