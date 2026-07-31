# 01-extraction — US-EVAL-010

## Story `[reconstructed]`

**As a** crAPI platform user who owns a registered vehicle,
**I want** the vehicle-location endpoint (`GET /identity/api/v2/vehicle/{vehicleId}/location`) to
only ever return coordinates to the vehicle's actual owner,
**so that** no other authenticated user — or unauthenticated caller — can track any vehicle by
supplying/guessing its `vehicleId`, the exact object-level-authorization failure crAPI's own
Challenge 1 documents as its canonical teaching defect (OWASP API Security Top 10 #1, BOLA).

*(Not expressed as a user story in the source — `docs/challenges.md` states the challenge as an
attacker's goal, not a product requirement. Reconstructed as the corresponding **secure-behavior**
requirement per `us-review` step 1's `[reconstructed]` license, since a security-teaching target's
"vulnerability" is, from a test-design point of view, simply "the acceptance criteria the real
implementation fails.")*

## Acceptance criteria (numbered, stable — AC1..AC4)

- **AC1.** A `GET` to `/identity/api/v2/vehicle/{vehicleId}/location` with a valid authentication
  token belonging to the vehicle's owner, using that owner's own `vehicleId`, returns `200` with
  the vehicle's current location (latitude, longitude).
- **AC2.** A `GET` to the same endpoint with a valid authentication token belonging to user A, but
  using a `vehicleId` that belongs to a **different** user B, must **not** return user B's vehicle
  location data — this is the object-level authorization check Challenge 1 exists to demonstrate is
  currently missing (the deliberately vulnerable implementation returns `200` with B's coordinates
  regardless of who asks; the *acceptance criterion* under test is that a corrected implementation
  denies this).
- **AC3.** A `GET` to the same endpoint with no authentication token, or an invalid/expired one, is
  denied (not defaulting to treating the caller as if authenticated, and not returning any vehicle's
  location).
- **AC4.** `vehicleId` values are GUIDs, not sequential integers (`docs/challenges.md`'s own stated
  premise) — the challenge explicitly frames non-enumerability of the ID space as *not itself* a
  sufficient control: Challenge 1's actual ask is "find a way to expose the vehicle ID of another
  user," meaning the ID's unguessability is not relied upon as the authorization mechanism, and a
  correct fix must enforce ownership at the endpoint regardless of how the requester obtained the
  ID (a leaked ID, a shared trip reference, another endpoint's response body, etc.).

## Business rules / constraints found outside the AC list

- The vehicle-location endpoint sits in the **Identity** microservice's API surface per
  `docs/overview.md`, separate from **Workshop** (mechanic reports — Challenge 2, an independent
  BOLA on a different resource) and **Community** (blogs/comments) — this US-slice does not touch
  those other services' endpoints.
- `docs/challenges.md` frames Challenge 1 as "find an API endpoint that receives a vehicle ID and
  returns information about it" — i.e. the challenge itself is partly a *discovery* exercise (find
  the undocumented/hidden endpoint). This US-slice designs against the endpoint **once found**
  (its path is only known from secondary-source corroboration, see `00-source.md`), not the
  discovery process itself, which is not a testable behavior in the ISTQB sense.

## Referenced artifacts not analyzed

- `docs/challenges.md` Challenges 2-18 (mechanic-report BOLA, password reset, unauthenticated
  endpoint discovery, JWT forgery, mass assignment, SSRF, NoSQL/SQL injection, LLM prompt
  injection) — out-of-slice, listed in `00-source.md` dependencies.
- The Postman collection / OpenAPI spec crAPI ships in its repo (not fetched in this capture —
  the exact request/response schema for the location endpoint beyond "latitude, longitude" is not
  analyzed here).

## Present but not classifiable

- None.

## What was NOT found

- The exact HTTP status code(s) a corrected implementation "should" return for AC2/AC3 (`403` vs
  `404` vs a generic error) — `challenges.md` states the flaw's existence, not a target-state
  contract for what "fixed" looks like; carried to `need-understanding` as an open point.
- Whether the location endpoint's authentication check is independent from, or shares code with,
  Challenge 14's unrelated "endpoint with no auth check at all" — not stated; not assumed to be the
  same endpoint (see `00-source.md` "not confirmed").

## Journey

| Step | Status |
|---|---|
| 00-ingest | done |
| 01-review | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) |

## Skill evaluation — `us-review` (`plugins/qaia-core/skills/us-review/SKILL.md`)

See separate evaluator pass (spawned after this checkpoint).
