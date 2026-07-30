---
stepsCompleted: [00-ingest, 01-review, 02-understanding]
lastStep: 02-understanding
lastSaved: 2026-07-29
---

# 02-understanding — US-EVAL-005

## Reformulation

Who: any authenticated caller of OpenEMR's Standard API (clinic staff, or a patient-facing
integration acting through a Bearer token) attempting to schedule a new appointment for an
existing patient. What: a `POST {base}/appointment` request must accept a structurally valid,
authenticated booking request and create the corresponding `pc_event` record, while rejecting a
request that is unauthenticated, structurally invalid, or references a patient/facility that does
not exist. Why: appointment scheduling is the entry point to nearly every clinical encounter — a
booking that silently fails, silently double-books a provider, or silently succeeds against a
malformed/unauthorized request corrupts the clinic's schedule of record. Main risk if it
misbehaves: a phantom or corrupted appointment (wrong patient, wrong time, or a slot silently
double-booked) is worse than an over-eager refusal, because clinical scheduling errors propagate
into missed care and are hard to detect after the fact — the same asymmetry as US-EVAL-002's
checkout case, now in a domain where the cost of a wrong "success" is a missed patient encounter
rather than a phantom order.

## Ambiguity hunt

**Q1 — double-booking (overlapping appointment for the same provider/facility/time).** No source
states whether `POST {base}/appointment` checks for an existing appointment overlapping the
requested `pc_facility` + `pc_eventDate` + `pc_startTime` + `pc_duration` window before creating a
new one.
- Classification: step 3 asks whether a safe default exists — it does not here. Real-world EHR
  scheduling **intentionally allows double-booking** in many clinics (overbooking for walk-ins,
  overflow slots, multiple exam rooms per provider) as a front-desk decision, so "refuse on
  overlap" is not an obviously safe assumption the way "refuse an empty cart" was in US-EVAL-002 →
  **`[open]`**.

**Q2 — invalid `pid` (a patient ID that does not exist).** No source states the response when
`pid` does not match a real patient record.
- Classification: step 3, safe default exists (reject via `validationErrors`, the documented error
  channel) → **`[assumption]`**.

**Q3 — invalid `pc_facility` (a facility ID that does not exist).** Same reasoning as Q2.
- Classification: step 3, safe default exists (reject) → **`[assumption]`**.

**Q4 — `pc_eventDate` in the past.** No source states whether creating an appointment dated before
today is refused, silently accepted (e.g. for backfilling a historical record), or accepted only
under a different permission.
- Classification: step 3, a safe default exists for the *forward-booking* use case this US targets
  (reject a past date) — but a plausible legitimate need (staff backfilling a walk-in encounter
  after the fact) makes the default less certain than Q2/Q3 → **`[assumption]`**, `@low-confidence`.

**Q5 — `pc_duration` boundary.** No source states the accepted range; whether `0` or a negative
value is rejected, silently clamped, or silently accepted producing a zero-length event.
- Classification: step 3, safe default exists (reject `pc_duration <= 0`, standard boundary
  assumption for a countable time span) → **`[assumption]`**, `@low-confidence`.

**Q6 — cross-site/cross-tenant `pid` scoping (IDOR-shaped auth boundary).** OpenEMR supports
multi-site deployments; the documentation never states whether an authenticated caller's Bearer
token is scoped to one site/facility, and if so, whether `POST {base}/appointment` validates that
the supplied `pid` belongs to a patient within the caller's authorized scope, or accepts any `pid`
reachable by that caller's token regardless of site.
- Classification: per the mandatory adversarial pass rule ("access boundary → question, never
  assumption"), this is an **auth-boundary/access-scoping** point the source never states →
  **`[open]`**, never defaulted to "obviously enforced."

**Q7 — expired/revoked Bearer token.** The documentation states a valid `Authorization: Bearer`
header is required but does not explicitly restate standard OAuth2 expiration/revocation
behavior for this specific endpoint.
- Classification: step 3, safe default exists (an expired/revoked token is refused exactly like a
  missing one — standard OAuth2 behavior, not a novel product decision for this resource
  specifically) → **`[assumption]`**, `@low-confidence` (the exact status code, 401 vs 403, is not
  independently confirmed for this endpoint).

**Q8 — cancellation/rescheduling mechanism.** `STANDARD_API.md`'s documented permission set for
this resource is `crus` (no `d` for delete); whether an appointment is cancelled via a status field
flip through `PUT`, or is genuinely not deletable through this API at all, is not stated.
- Classification: step 1b — this plausibly lives in a sibling capability (`00-source.md`
  dependencies already flag it as out-of-slice) rather than in this ingested slice → **`[open]`**,
  `[out-of-slice]`. Not designed into a scenario here; recorded so it is not silently forgotten.

**Q9 — order of auth-check vs. field-validation, and its disclosure shape.** When a request is
**both** unauthenticated **and** structurally invalid (e.g. missing `pid`, malformed
`pc_eventDate`) or references a `pid` outside the caller's scope (Q6), the documentation does not
state which check runs first, nor whether the response shape differs in a way that discloses
whether the referenced patient/slot exists to an unauthorized or unauthenticated caller.
- Classification: this is the triple-intersection question below (a restricted-resource rule, a
  scoping rule, and an anti-disclosure/error-shape rule meeting at once) — no safe default is
  obvious among "401 always wins" vs "422 discloses validation detail first" → **`[open]`**.

## Adversarial pass (by AC type — mandatory)

- **State machine / lifecycle**: this slice documents only the creation action (`crus` includes no
  documented `d`); there is no multi-state lifecycle to test for re-entrance within AC1-AC3
  themselves. The closest re-entrance question — can the identical `pid` + time window be submitted
  twice, producing two appointments — is folded into **Q1**'s family (a duplicate submission is
  indistinguishable from a double-booking at the API level with the information available).
- **Auth / tokens / permissions (AC2)**: covered by **Q6** (scoping/IDOR) and **Q7**
  (expiration/revocation). Indistinguishability under every response path (does a 401 for a bad
  token look identical to a 401 for a missing token) is not independently questioned — the source
  states both cases require "a valid access token," treating them as one class, which is the
  documented behavior, not an assumption.
- **Sorting / pagination**: not applicable — this US's slice is the create action only; the `s`
  (Search) permission's list/query behavior is a sibling capability, out of slice (`00-source.md`
  dependencies). Waived.
- **Thresholds / quantities (AC1)**: this is **Q5** (the `pc_duration` boundary) and **Q4** (the
  `pc_eventDate` past-date boundary, a date threshold rather than a numeric one).

## Cross-AC interaction pass (mandatory)

AC1 (create with valid fields) and AC3 (field-validation refusal) intersect with AC2
(authentication) at exactly the question raised in **Q9**: when a request fails *both* the auth
check and the field-validation check simultaneously, which one determines the response, and does
the losing check's detail leak through anyway. AC1 and AC2 also intersect at **Q6** (an
authenticated-but-out-of-scope request is neither a clean AC1 success nor a clean AC2 refusal —
it is a third case the source never names).

## Triple-AC contradiction pass (mandatory)

Candidate triplet: a **restricted-resource** rule (a patient record, referenced by `pid`, belongs
to one site/facility and is not universally visible), a **scoping** rule (a Bearer token is
presumably scoped to the caller's own site, per Q6), and an **anti-disclosure/error-shape** rule
(should an out-of-scope `pid` return a validation-style `422` — implicitly confirming the `pid`
is well-formed and could exist — or a `401`/`403` that reveals nothing about whether that `pid`
is valid?). This triplet exists in this US (unlike a case where the pattern genuinely does not
apply) and is exactly **Q9**, restated here with its full three-rule shape per the skill's own
mandatory-trace rule — no separate question ID is created, Q9 already captures it.

## Q&A log

| ID | Question | Status | Resolution |
|---|---|---|---|
| Q1 | Double-booking / overlapping appointment for the same provider-facility-time | `[open]` | No default asserted with confidence — proposed default (refused) generated as `@low-confidence`, human arbitration required (real EHRs often allow intentional overbooking) |
| Q2 | Invalid `pid` on create | `[assumption]` | Refused via `validationErrors` |
| Q3 | Invalid `pc_facility` on create | `[assumption]` | Refused via `validationErrors` |
| Q4 | `pc_eventDate` in the past | `[assumption]`, `@low-confidence` | Refused |
| Q5 | `pc_duration` ≤ 0 | `[assumption]`, `@low-confidence` | Refused |
| Q6 | Cross-site/cross-tenant `pid` scoping (IDOR-shaped auth boundary) | `[open]` | No default asserted; human arbitration required |
| Q7 | Expired/revoked Bearer token | `[assumption]`, `@low-confidence` | Refused (standard OAuth2 behavior assumed) |
| Q8 | Cancellation/rescheduling mechanism | `[open]`, `[out-of-slice]` | Not designed in this slice; flagged as a dependency |
| Q9 | Auth-check vs. field-validation order and disclosure shape when both fail at once | `[open]` | No default asserted; human arbitration required |

## Journey

| Step | Status |
|---|---|
| 02-understanding | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) |

## Skill evaluation — `need-understanding`

- **Skill evaluated**: `plugins/qaia-core/skills/need-understanding/SKILL.md`.
- **Input**: `01-extraction.md` above (3 ACs, API-only source, several unconfirmed behaviors
  already flagged at extraction).
- **Output**: this file.
- **Verdict**: **CONFORME.**
- **Evidence**: both mandatory trace sections the skill's own guardrail calls out (line 48:
  "Omitting the required trace of step 3 or step 4a... is the same defect as silently resolving an
  ambiguity") are present as their own headed sections (`## Adversarial pass` and `## Triple-AC
  contradiction pass`), each stating a finding rather than a bare "not applicable" — including the
  sorting/pagination bullet, correctly marked "not applicable" *with a stated reason* (out of
  slice) rather than omitted. The classification decision tree (line 30) was applied case-by-case:
  Q1's "no safe default" reasoning explicitly contrasts with US-EVAL-002's own Q1 (an empty-cart
  checkout, which *did* have an uncontroversial safe default) to justify why this domain's
  double-booking question lands on `[open]` instead of `[assumption]` despite superficially similar
  phrasing — showing the tree's step 3 "reasonable practitioner" test was actually reasoned about,
  not applied mechanically. The access-boundary rule (line 26: "never assert... when the source
  implies public read access") is respected by Q6 landing on `[open]` rather than an assumed
  "scoping enforced."
- **Modification proposed**: none.
