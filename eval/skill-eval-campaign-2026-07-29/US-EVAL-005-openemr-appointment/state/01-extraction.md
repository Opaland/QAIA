---
stepsCompleted: [00-ingest, 01-review]
lastStep: 01-review
lastSaved: 2026-07-29
---

# 01-extraction — US-EVAL-005

## Story

**As a** patient (or a clinic staff member scheduling on a patient's behalf),
**I want** to book a new appointment against an existing patient record, provider/facility and
appointment category,
**so that** a confirmed scheduling event is created for a specific date and time.

*(`[reconstructed]` — the fetched API documentation describes a resource and its fields, not a
user story; per `us-review` step 1, "no story phrasing found but a real capability is described →
reconstruct it and mark it `[reconstructed]`".)*

## Acceptance criteria (numbered, stable — AC1..AC3)

- **AC1.** A caller with valid credentials creates a new appointment (`POST
  {base}/appointment`) supplying `pc_catid`, `pc_title`, `pc_duration`, `pc_eventDate`,
  `pc_startTime`, `pc_facility`, and `pid` (an existing patient), and the appointment is created
  and returned in `data`.
- **AC2.** The `appointment` resource requires authentication: every request carries
  `Authorization: Bearer <token>`; a request without a valid token is refused.
- **AC3.** A request to create an appointment with a missing or structurally invalid required
  field (e.g. malformed `pc_eventDate`, missing `pid`) is refused and reported via
  `validationErrors`, not silently accepted or silently defaulted.

## Business rules / constraints found outside the AC list

- The resource's permission level is `crus` — Create, Read, Update, **Search** are documented;
  **Delete/cancel is not listed** among the documented permissions for this resource. Whether
  cancellation exists via a different mechanism (e.g. a status field flip through `PUT`) is not
  stated — out of scope for AC1-AC3, flagged as a dependency below.
- The FHIR `Appointment` resource exists as a parallel, separately-scoped read/search surface
  (`GET /apis/{site}/fhir/Appointment`) — structurally distinct from the REST `appointment`
  resource this US targets; not the same operation, not designed here.
- `pc_duration` is expressed in **seconds** (the example value "1800" = 30 minutes) — a unit worth
  making explicit since a caller supplying minutes by mistake would silently create a 30-second (or
  500-hour) appointment.

## Referenced artifacts not analyzed

- The full OpenAPI/Swagger JSON/YAML spec for the `appointment` resource (only the Markdown
  narrative in `STANDARD_API.md` was fetched; the interactive Swagger UI at
  `demo.openemr.io/openemr/swagger/#/...` returned only a JS-rendered shell, never expanded) — the
  complete request schema (which fields are truly required vs. optional, exact validation rules)
  was not fully confirmed.
- The `pc_event` database table structure referenced in passing by `STANDARD_API.md` — not
  inspected (out of scope; this US targets the documented API surface, not the schema).

## Present but not classifiable

- None.

## What was NOT found

- No formal AC numbering in the source (an API doc, not a written ticket) — numbering above is
  this skill's own reconstruction.
- No UI-level behavior (calendar widget, button labels, client-side validation copy) — the
  designated live demo never yielded usable content (see `00-source.md`).
- No stated behavior for: **double-booking** (two appointments for the same provider/facility
  overlapping in time), an **invalid `pid`**, an **invalid `pc_facility`**, **cancellation/deletion**,
  **rescheduling**, or the **exact FHIR `Appointment` OAuth2 scope string** — all carried to
  `need-understanding` as open points, none invented here.

## Journey

| Step | Status |
|---|---|
| 00-ingest | done |
| 01-review | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run, no human reviewer at this micro-step; only the pre-automation gate is a hard human stop per the campaign prompt) |

## Skill evaluation — `us-review`

- **Skill evaluated**: `plugins/qaia-core/skills/us-review/SKILL.md`.
- **Input**: `00-source.md` above (project API documentation text, no story phrasing, no AC
  numbering, one design gap already flagged: live demo unreachable).
- **Output**: this file.
- **Verdict**: **CONFORME.**
- **Evidence**: `SKILL.md` line 13 requires that when no story is present but a real capability is
  described, it be "reconstruct[ed]... mark[ed] `[reconstructed]`" — done verbatim in the Story
  section above. Step 2's "show the diff mentality... explicitly list what you did NOT find" (line
  18) is satisfied by the "What was NOT found" section, which lists both structural absences (no
  AC numbering) and content absences (double-booking, invalid `pid`/`pc_facility`, cancellation,
  rescheduling, exact FHIR scope) without inventing any of them here — correctly deferred to
  `need-understanding` per line 24 ("resolving it is the next skill's job, with the user").
- **Modification proposed**: none.
