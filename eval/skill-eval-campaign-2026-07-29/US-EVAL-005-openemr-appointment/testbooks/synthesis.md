---
stepsCompleted: [testbook-generate]
lastStep: testbook-generate
lastSaved: 2026-07-29
---

# Synthesis — US-EVAL-005 (OpenEMR appointment booking)

**Scope**: appointment creation (`POST {base}/appointment`) — field-content correctness,
authentication/authorization, structural field validation (12 conditions generated, P1+P2 default
scope; 1 condition, AC3-C2, deferred to P3 and not generated — see waiver note below).
**Scenarios**: 12 atomic blocks (`002`, `011`, `012` are `Scenario Outline`s with 2 examples each,
each counted as 1 block per D20's single definition) + 0 smoke journey (skipped — the create-only
slice is already fully atomized across AC1-AC3; a single end-to-end `@smoke` scenario would only
re-verify behaviors already covered atomically).
**Negative ratio**: 11/12 blocks tagged `@negative` = 91.7 % (target ≥ 40 %, met without padding —
every negative traces to a real refusal condition from `03-design.md`, none invented to hit the
ratio; the ratio is this high organically because the design's own negative-pressure pass (ADR
0001) found many more refusal paths than happy-path variants in this create-only, validation-heavy
slice).
**Coverage**: AC1 4/4, AC2 4/4, AC3 4/5 (1 deferred to P3 by default scope) — 12/13 conditions
generated.

## Review order

`@low-confidence` first (`004, 006, 007, 008, 002, 003`), then P1 → P3 (`004, 005, 006, 007, 008` →
`001, 002, 003, 009, 010, 011, 012` → none generated at P3 — `AC3-C2` is deferred, see below).

## By-technique table

| Technique | ACs | Scenarios | Justification |
|---|---|---|---|
| `@ep` | AC1, AC3 | `001, 009, 010` (+ `011, 012` share `@ep` for the format-partition, also oracle-tagged) | Valid/invalid input classes treated the same way |
| `@boundary` | AC1 | `002, 003` | `pc_duration` ≤ 0 boundary; `pc_eventDate` past/future boundary |
| `@decision-table` | AC1, AC2 | `004, 005, 006, 007, 008` | Multi-axis conditions (facility×time overlap; token state × scope × field validity) crossed into one action |
| `@oracle:iso8601` | AC3 | `011, 012` | ISO 8601 invalid-corpus cases for `pc_eventDate`/`pc_startTime`, grounded not guessed |

## Open / assumption / low-confidence list (full, per shared contract)

- **Q1** `[open]`, `@low-confidence` — **human arbitration required**: is an appointment
  overlapping an existing one for the same facility/time refused, or does OpenEMR intentionally
  allow double-booking (a real, common EHR feature)? `004` encodes a *proposed* default (refused),
  not a confirmed behavior.
- **Q2** `[assumption]` — a well-formed `pid` with no matching patient record is refused (`010`).
- **Q3** `[assumption]` — a nonexistent `pc_facility` is refused (`009`).
- **Q4** `[assumption]`, `@low-confidence` — a past-dated `pc_eventDate` is refused; a plausible
  legitimate backfill exception exists and is not ruled out (`003`).
- **Q5** `[assumption]`, `@low-confidence` — `pc_duration` ≤ 0 refused; exact floor unconfirmed
  (`002`).
- **Q6** `[open]`, `@low-confidence` — **human arbitration required**: is a Bearer token's `pid`
  reach scoped to the caller's own site/facility, or can any authenticated caller book for any
  patient regardless of site? `007` encodes a *proposed* default (refused), not the real scoping
  rule.
- **Q7** `[assumption]`, `@low-confidence` — an expired/revoked Bearer token is refused, standard
  OAuth2 behavior assumed but not independently confirmed for this endpoint (`006`).
- **Q8** `[open]`, `[out-of-slice]` — the cancellation/rescheduling mechanism (the documented
  `crus` permission set has no `d`) is not designed in this slice; flagged as a dependency, no
  scenario generated for it.
- **Q9** `[open]`, `@low-confidence` — **human arbitration required**: when a request is both
  unauthenticated and structurally invalid, does the 401 win with no validation detail disclosed,
  or does field validation run (and partially leak) first? `008` encodes a *proposed* default
  (401 wins, no disclosure), not a confirmed behavior.

## Deferred / waived conditions

- **AC3-C2** (`pid` omitted entirely from the request body) — `P3` by `04-priorities.md`'s scoring
  (impact 2, probability 1: this behavior is directly stated by the source's `validationErrors`
  channel, not an inferred default, so it scores lower-risk than the other `[assumption]`-based
  validation gaps). Excluded from this book by the default P1+P2 scope — a standing, cited waiver,
  not a silent gap; still listed in `coverage-matrix.md`.

## Out-of-slice (not designed here)

- Patient registration/lookup (`GET`/`POST /api/patient`) — a separate US; `pid` is only ever a
  given input here.
- Provider/facility management — a separate administrative US; `pc_facility` is a given input.
- Appointment category (`pc_catid`) management/configuration — a separate admin-config US.
- Cancellation/rescheduling (Q8) — the documented `crus` permission set has no delete; whether this
  exists via a status-flip `PUT` or is genuinely absent from this API is unresolved and out of
  this slice.
- FHIR-level `Appointment` read/search via OAuth2 — a sibling capability to the REST `crus`
  surface designed here; not this US's slice.
- Search/list of existing appointments (the `s` in `crus`) — a separate list/filter US.

## Sourcing honesty note

This US was captured from the OpenEMR project's own GitHub API documentation
(`STANDARD_API.md`, `API_README.md`, `FHIR_API.md`) via `WebFetch`, **not** from a live capture of
the designated demo instance: `docs/DEMO-TARGETS.md`'s named URL
(`one.openemr.io/d/openemr`) returned HTTP 404 at capture time, and the host's root served only a
bare default Apache placeholder page (see `00-source.md`) — the demo container was not reachable,
not merely JS-shell-only. No unrelated third-party OpenEMR instance was substituted to fill that
gap (per `us-ingest`'s own guardrail); a different, well-known OpenEMR community demo domain
(`demo.openemr.io`) was fetched only to confirm a real login-page shape exists in the wild, and is
explicitly **not** used to ground any AC or scenario above. Business-correctness confidence for
this book therefore rests entirely on the project's own official API reference documentation
(directly quoted field names, permission model, error-channel name), which is a real, primary
source for the target's documented interface — but it is not a live-instance-verified capture, and
several behaviors the documentation simply never states (double-booking, cross-site scoping,
error-precedence under simultaneous failures) remain genuinely open per the Q&A log above.

## Skill evaluation — `testbook-generate`

- **Skill evaluated**: `plugins/qaia-core/skills/testbook-generate/SKILL.md`.
- **Input**: `03-design.md` (13 conditions) and `04-priorities.md` (12 P1/P2, 1 P3) above.
- **Output**: `openemr-appointment-booking.feature`, this synthesis, `coverage-matrix.md`,
  `state/generated.snapshot.md`.
- **Verdict**: **CONFORME.**
- **Evidence**: line 28's rule that "a `[req-neg]` condition left at P3 by step 1's default scope
  is not a silent gate violation... provided it still appears (condition ID + reason) in the
  coverage matrix/synthesis rather than vanishing from the count" is exercised for real by this
  run's `AC3-C2` (a genuine P3 `[req-neg]` condition, unlike every prior campaign run's condition
  set, which happened to be entirely P1/P2) — both `coverage-matrix.md` and the "Deferred / waived
  conditions" section above name it explicitly with its reason, rather than it silently vanishing
  from the 13-condition design count down to 12 generated scenarios. Line 19's rule for `[open]`
  conditions ("still gets its scenario, written with the proposed safe default... tagged
  `@low-confidence`, with an inline comment citing the question ID") is followed exactly by
  scenarios `004`, `007`, `008` — all three carry `# open: Qn` comments and `@low-confidence`
  tags. The negative ratio (91.7 %) was computed, not padded — every one of the 11 negative
  scenarios traces to a real `[req-neg]` condition from `03-design.md`.
- **Modification proposed**: none.
