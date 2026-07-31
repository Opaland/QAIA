# 02-understanding — US-EVAL-010

## Reformulation

Who: any crAPI-registered user acting as an authenticated (or unauthenticated) API caller against
the Identity microservice's vehicle-location endpoint. What: `GET
/identity/api/v2/vehicle/{vehicleId}/location` must return coordinates only when the caller is the
vehicle's actual owner — never for another user's `vehicleId`, and never for no/invalid
authentication. Why: crAPI's own Challenge 1 names this exact endpoint shape as its canonical
Broken Object Level Authorization (BOLA) teaching defect (OWASP API Security Top 10 #1) — the
GUID-based `vehicleId` is not itself a control, only an obstacle to casual enumeration; the actual
authorization check must happen server-side, per request, regardless of how the caller obtained
the ID. Main risk if it misbehaves: an attacker who obtains any valid `vehicleId` (leaked in
another response body, a shared trip, a community post, or even guessed via a UUID-timing/format
weakness) can silently track any vehicle's real-time-or-last-known location with no audit trail
distinguishing it from the legitimate owner's own request — a physical-safety-adjacent
information-disclosure risk (stalking/tracking), not merely a data-hygiene one, which is why this
condition set scores impact higher than a typical BOLA on cosmetic data in `prioritize`.

Knowledge base: `.qaia/knowledge/` does not exist for this campaign directory — recorded per
shared-contract rule 8, proceeding on the source alone.

## Ambiguity hunt

**Q1 — what response should a cross-owner request (AC2) return: `403` (exists, denied) or `404`
(avoid confirming the ID is valid at all)?** `docs/challenges.md` documents that the flaw exists
(a `200` leak today) but states no target-state contract for the corrected behavior's exact status
code — this is genuinely undecided by the source.
- Classification: step 2's protected-domain gate doesn't cleanly fire (this isn't money/minors/
  health/compliance-evidence), but it **is** the campaign's own calibration triplet shape
  (restricted-state resource × per-owner scoping × anti-disclosure choice) — see the Triple-AC pass
  below, which is where this is actually adjudicated, not duplicated here. → carried to the
  Triple-AC section, resolved there as `[assumption]` (a security-conscious default exists and is
  low-risk either way for *this* AC's purpose, unlike the patient-results calibration example
  where existence-disclosure itself was safety-relevant).

**Q2 — is "current location" a live/real-time GPS read, or a static/mock value assigned once at
vehicle registration?** crAPI is a teaching demo simulating a car-buying platform, not a real
fleet-tracking system integrated with actual GPS hardware — the source never states the data is
live-updating.
- Classification: step 3 (a safe, low-risk default exists: treat "location" as a queryable
  attribute of the vehicle record, whatever its update cadence — assertions check "the endpoint
  returns *a* location value belonging to that vehicle," not that it changes between polls) →
  **`[assumption]`**. Downstream scenarios do not assert real-time freshness.

**Q3 — does a request for a `vehicleId` that doesn't exist at all (neither the caller's nor any
other user's) get the same treatment as AC2's cross-owner case, or a distinct "not found" path?**
Not addressed by any of AC1-AC4 as extracted.
- Classification: step 3, a safe default exists (treat as `404`, the conventional REST response
  for a non-existent resource, distinct in *reason* from AC2's authorization denial but
  indistinguishable in *response shape* if AC2 also resolves to `404` per Q1's outcome — this
  convergence is itself a desirable anti-disclosure property, noted in the Triple-AC pass) →
  **`[assumption]`**.

## Adversarial pass (by AC type)

- **State machine / lifecycle**: not applicable — the vehicle-location endpoint is a stateless
  read, no lifecycle/status field is described in this slice.
- **Auth / tokens / permissions (the type this US is centrally about)**: revocation vs expiration
  — AC3 as extracted says "no token, or an invalid/expired one" is denied, without distinguishing
  the two; `need-understanding`'s own guidance treats this distinction as usually immaterial to the
  *outcome* (both must be denied) even if the *diagnostic detail* differs, so no new question is
  raised beyond folding both into AC3 as written. Scope change mid-session (a token issued while
  owning vehicle X, then the vehicle is sold/transferred) — **not addressed by the source at all**,
  and crAPI's own catalog does not describe a vehicle-transfer feature; noted as an out-of-slice
  gap, not fabricated into a question with no textual anchor. Indistinguishability under every
  response path — this is exactly Q1/the Triple-AC pass below (does a denial for "wrong owner" look
  identical to a denial for "no such vehicle"?).
- **Sorting / pagination**: not applicable — a single-resource lookup, no list view in this slice.
- **Thresholds / quantities**: not applicable — no numeric threshold, limit, or rounding rule in
  this AC set (coordinates are a value pair, not a bounded quantity being tested for a cutoff).

## Cross-AC interaction pass

- **AC1 × AC2 (same endpoint, ownership is the only varying factor)**: confirmed by source (both
  are the same endpoint under `docs/challenges.md`'s single challenge), not ambiguous — the
  deliberate contrast is the whole point of Challenge 1. No new question.
- **AC2 × AC4 (GUID unguessability is not a substitute for AC2's server-side check)**: AC4 already
  states, per source, that the non-sequential ID space is explicitly *not* relied upon as the
  control — this is a confirmed fact, not a gap, and downstream design must not generate a
  scenario implying "GUIDs are safe enough" (that would contradict the source's own stated premise
  in Challenge 1's second sentence).
- **AC3 × AC2 (does authentication-failure at AC3 hide or interact with AC2's authorization
  question?)**: these are independent gates — a request must pass authentication (AC3) *before*
  authorization (AC2) is even evaluated; no interaction beyond ordering, which is the conventional
  and uncontested order (authenticate, then authorize). No new question.

## Triple-AC contradiction pass

**Applies — matches the campaign's own calibration shape.** A *restricted-state* resource (another
user's vehicle location — AC2), a *scoping* rule (per-owner access, not per-role or per-org), and
an *anti-disclosure* concern (does the denial response confirm the `vehicleId` is valid, thereby
still leaking *something* — "this GUID belongs to *someone*" — even while correctly denying the
location itself?) all meet at AC2. Resolution carried from Q1 above: **`[assumption]`**, not
`[open]`, because — unlike the patient-results calibration example, where the *existence itself* of
a restricted record was the safety-sensitive fact — here both plausible answers (`403`
"exists, forbidden" or `404` "not found") are independently defensible security postures, and the
convention that minimizes disclosure (`404`, converging with Q3's not-found case so a cross-owner
denial and a nonexistent-ID request are indistinguishable to the caller) is adopted as the working
default, flagged `@low-confidence` for human arbitration on the exact status code rather than
asserted with full confidence. The *underlying* AC2 requirement itself (must not leak the location)
is not in doubt — only the precise denial status code is.

## Q&A log

| ID | Question | Status | Resolution |
|---|---|---|---|
| Q1 | What status code should a cross-owner request (AC2) return: `403` or `404`? | `[assumption]` | `404` (avoid confirming ID validity), adjudicated via the Triple-AC pass; `@low-confidence`, human arbitration welcome on the exact code, not on the underlying "must not leak location" requirement |
| Q2 | Is "current location" live-GPS or a static/mock per-vehicle value? | `[assumption]` | Treated as an opaque per-vehicle attribute; scenarios assert presence/ownership-scoping, not freshness/real-time behavior |
| Q3 | What should a request for a non-existent `vehicleId` return? | `[assumption]` | `404`, converging with Q1's AC2 default for a uniform anti-disclosure response shape |

## Journey

| Step | Status |
|---|---|
| 02-understanding | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) |

## Skill evaluation — `need-understanding` (`plugins/qaia-core/skills/need-understanding/SKILL.md`)

See separate evaluator pass (spawned after this checkpoint).
