---
stepsCompleted: [00-ingest]
lastStep: 00-ingest
lastSaved: 2026-07-29
---

# 00-source — US-EVAL-005

- **Source type**: live application + official project documentation (bring-your-own target, per
  `docs/SKILL-EVAL-CAMPAIGN-PROMPT.md`), captured via `WebFetch` — not a written ticket.
- **Designated target**: `OpenEMR` — `docs/DEMO-TARGETS.md` "Recommended pairing" entry: GPL-3.0
  medical record system, "REST + FHIR R4 API with Swagger", demo `one.openemr.io/d/openemr`
  (creds `admin`/`pass`, reset daily 08:30 UTC). Explore-only per the campaign's golden rule — no
  `perf-check`/`security-surface` against the shared demo; this campaign stops before any
  automation step regardless.
- **Capture date**: 2026-07-29.

## What was actually fetched

- `WebFetch https://one.openemr.io/d/openemr` → **HTTP 404**.
- `WebFetch https://one.openemr.io/` (same host, root) → returned the **default Apache "It
  works!" placeholder page** — the demo container DEMO-TARGETS.md names is not currently mounted
  at this host. **Per `us-ingest` step 1's guardrail** ("if the designated URL... do not
  autonomously substitute or supplement with other URLs to fill the gap — tell the user"), this
  run does **not** silently swap in an unrelated third-party OpenEMR demo instance to paper over
  the gap. The live-demo capture is honestly recorded as **unavailable at this capture time**, not
  worked around.
- `WebFetch https://github.com/openemr/openemr/blob/master/API_README.md` → **succeeded**. This is
  the OpenEMR project's own canonical API documentation, hosted in the same repository
  DEMO-TARGETS.md cites for the "REST + FHIR R4 API with Swagger" trait — used as the grounding
  source in place of the unreachable live instance, not a search-engine substitution. Contains:
  `"✅ Encounter, Appointment, CarePlan, CareTeam"` (FHIR resources supported) and a pointer to
  `Documentation/api/STANDARD_API.md` for the REST (non-FHIR) surface.
- `WebFetch https://raw.githubusercontent.com/openemr/openemr/master/Documentation/api/STANDARD_API.md`
  → **succeeded**, real REST endpoint documentation for the `appointment` resource.
- `WebFetch https://github.com/openemr/openemr/blob/master/Documentation/api/FHIR_API.md` →
  **succeeded**, confirms `Appointment` is a listed FHIR resource under "Administration Resources"
  with its own Swagger anchor.
- `WebFetch https://demo.openemr.io/openemr/` (a **different**, well-known OpenEMR community demo
  domain, not the one DEMO-TARGETS.md names) → returned a real login page (username/password
  fields, language dropdown, no credentials shown on the page itself). **Recorded for transparency
  only** — this domain was not the designated one, so nothing from it is used to ground any AC
  below; it only confirms a real OpenEMR login screen shape exists in the wild, consistent with,
  but not a substitute for, the designated target.
- `WebFetch https://demo.openemr.io/openemr/swagger/` → returned only the page title "Swagger UI",
  no body content (JS-rendered shell) — same pattern as US-EVAL-002's Toolshop Swagger UI fetch.
  Not used to ground any AC, for the same reason as above.

## Captured text (faithful, not paraphrased)

> **REST `appointment` resource** (`Documentation/api/STANDARD_API.md`) — Base path:
> `{base}/appointment` where base is `https://{your-openemr-host}/apis/{site}/api`. Permissions:
> `crus` (Create, Read, Update, Search) — references the `pc_event` table. Example POST request
> fields: `pc_catid` ("5"), `pc_title` ("Annual Physical"), `pc_duration` ("1800", seconds),
> `pc_eventDate` ("2024-02-15", `YYYY-MM-DD`), `pc_startTime` ("09:00:00"), `pc_facility` ("1"),
> `pid` ("1", patient ID). Authentication: `Authorization: Bearer YOUR_ACCESS_TOKEN` with
> appropriate scopes. Response format: `validationErrors`, `internalErrors`, `data` fields.
>
> **FHIR `Appointment` resource** (`API_README.md`, `FHIR_API.md`) — listed among supported FHIR
> R4 resources (`"✅ Encounter, Appointment, CarePlan, CareTeam"`), and again under Administration
> Resources with its own Swagger anchor
> (`https://demo.openemr.io/openemr/swagger/#/fhir/get_fhir_Appointment`). General OAuth2 scope
> pattern shown for other resources in the same doc: `patient/Patient.rs`,
> `patient/Observation.rs` (read+search suffix `.rs`) — the exact `Appointment`-specific scope
> string was not quoted anywhere the fetch tool surfaced.
>
> (Sources: `WebFetch` on `github.com/openemr/openemr/blob/master/API_README.md`,
> `raw.githubusercontent.com/openemr/openemr/master/Documentation/api/STANDARD_API.md`, and
> `github.com/openemr/openemr/blob/master/Documentation/api/FHIR_API.md`, all 2026-07-29.)

## Not confirmed by any source found

- Whether `POST /apis/{site}/api/appointment` **rejects a time slot that overlaps an existing
  appointment for the same provider** (double-booking) — the `crus` permission list and the example
  fields say nothing about conflict detection.
- The exact **response/validation behavior for an invalid `pid`** (a patient ID that does not
  exist) or an invalid `pc_facility`.
- The **exact FHIR `Appointment` OAuth2 scope string** (`user/Appointment.rs`,
  `patient/Appointment.rs`, or another shape) — only the general `.rs` pattern on sibling
  resources was quoted, not the resource-specific one.
- Any **UI-level detail** of the scheduling/calendar module (button labels, calendar widget
  behavior, client-side validation copy) — the designated live demo never yielded usable content
  (404 / placeholder page), and the out-of-scope `demo.openemr.io` login page was not explored
  beyond its login form per the discipline above.
- Whether a **cancelled** appointment's slot becomes bookable again, and whether **rescheduling**
  is a distinct operation (`PUT`) or a delete+recreate.
- Full field list/constraints of `pc_catid` (a fixed enumeration of appointment categories, or a
  free-form reference to another resource) — only the one example value ("5") was shown.

**Not fabricated here** — every point above is carried forward as an open point to
`need-understanding`, never guessed.

## Redaction

None needed — no PII in the fetched public GitHub documentation or the out-of-scope demo login
page (no data was entered, only page structure observed).

## Dependencies (out-of-slice)

- Patient registration/lookup (`GET /api/patient`, `POST /api/patient`) — a separate US; `pid` is
  only ever a given input here (an existing patient is assumed to already exist).
- Provider/facility management — a separate administrative US; `pc_facility` is a given input.
- Appointment category (`pc_catid`) management/configuration — a separate admin-config US.
- FHIR-level `Appointment` read/search via OAuth2 (`GET /apis/{site}/fhir/Appointment`) — a
  sibling capability to the REST `crus` surface above; not designed in this slice, which focuses
  on the booking action itself (the REST resource is the one whose full CRU fields were actually
  quoted by a source).

## Journey

| Step | Status |
|---|---|
| 00-ingest | done — gates checked (not empty, is a testable capability — real scheduling API, no abuse/illegality, no PII to redact); US-ID confirmed non-interactively: `US-EVAL-005` |

## Skill evaluation — `us-ingest`

- **Skill evaluated**: `plugins/qaia-core/skills/us-ingest/SKILL.md`.
- **Input**: a live medical-scheduling target (`docs/DEMO-TARGETS.md` OpenEMR entry) whose
  designated demo URL 404'd, plus the same project's official GitHub API documentation.
- **Output**: this file.
- **Verdict**: **CONFORME.**
- **Evidence**: step 1's guardrail (`SKILL.md` line 12: "do not autonomously substitute or
  supplement with other URLs... to fill the gap") was followed for the *live-instance* gap — no
  `WebSearch` call was made, and no unrelated third-party OpenEMR instance was used to ground any
  AC (the `demo.openemr.io` fetch is explicitly quarantined above, "recorded for transparency
  only... nothing from it is used to ground any AC"). Falling back to
  `github.com/openemr/openemr/.../API_README.md` and `STANDARD_API.md` is not a guardrail
  violation for the same reason US-EVAL-002's `/docs` vs `/api/documentation` re-fetch was not one:
  it is the designated target's **own** documentation, the exact "REST + FHIR R4 API with Swagger"
  surface `docs/DEMO-TARGETS.md` names as this target's defining trait — not a different, unrelated
  source found via search.
- **Modification proposed**: none.
