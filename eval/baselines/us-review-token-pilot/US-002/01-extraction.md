---
stepsCompleted: [00-ingest, 01-review]
lastStep: 01-review
lastSaved: 2026-07-25
---

# 01-extraction — US-002 (extraction check)

Source: `.qaia/state/US-002/00-source.md` (captured 2026-07-25 from `eval/gold-set/US-002-dosage-validation.md`).

## Story

**As a** prescribing physician,
**I want** the system to validate the dosage of a prescription against the drug's safety rules before I sign it,
**so that** dosage errors are caught before they reach the pharmacy.

Present in the source, explicitly in As a / I want / So that form — no reconstruction needed.

## Acceptance criteria (stable numbering — never renumber after validation)

- **AC1.** Each drug has a reference record: minimum effective dose, maximum safe dose per intake, maximum cumulative dose per 24 h, and an age floor (minimum patient age in years).
- **AC2.** A dosage strictly below the minimum effective dose triggers a *warning* the physician may override with a documented reason.
- **AC3.** A dosage above the maximum safe dose per intake triggers a *blocking error*: the prescription cannot be signed.
- **AC4.** The cumulative dose over 24 h (all intakes of the same drug for that patient) must not exceed the maximum cumulative dose; exceeding it is blocking.
- **AC5.** If the patient's age is below the drug's age floor, prescription is blocked, except when the physician holds the "pediatric specialist" role, in which case it becomes an overridable warning with mandatory justification.
- **AC6.** For patients with a recorded renal insufficiency flag, all maximum thresholds are reduced by 50 % before validation.
- **AC7.** Every override (warning bypass) records the physician's identity, timestamp, and justification text of at least 20 characters in the audit trail.
- **AC8.** Validation results (pass / warning / blocked, with rule identifiers) are returned within the signing screen without page reload.

All 8 quoted verbatim from the source — no paraphrase needed, the source's AC list is already atomic and numbered per drug-safety rule.

## Business rules and constraints found outside the AC list

None. Unlike some sources, this US carries no separate "business rules" prose block outside the
numbered AC list — every constraint (thresholds, role exception, audit fields, UI latency) is
already expressed inside one of the 8 ACs. Nothing extra to extract here.

## Referenced artifacts not analyzed

None. The source contains no links, attachments, or mockups referencing external material.

## Present in the source but not classifiable

None found. Every sentence of the source maps cleanly onto either the story or one of the 8 ACs;
nothing was dropped or left unassigned.

## Diff mentality — what was explicitly NOT found

- **No non-functional requirement beyond AC8's UI-latency constraint** ("without page reload") —
  no explicit performance budget, no accessibility requirement, no localization requirement.
- **No concrete numeric thresholds.** AC1 defines the *shape* of the reference record (four
  threshold fields) but the source gives no actual mg/kg values — thresholds are per-drug data,
  not specified here. This is expected for a US of this kind, not a gap.
- **No explicit error-message copy** for the blocking cases (AC3, AC4, AC5) — only that they are
  blocking, not what is shown to the physician.
- **No data-retention or access-control statement** for the audit trail in AC7 (who can read it,
  how long it is kept).
- **No explicit statement of INVEST "Independent"** — and per `00-source.md`'s dependency list,
  the story is *not* fully independent: it leans on an external drug-catalog story (thresholds),
  a patient-record story (renal-insufficiency flag), and a roles story ("pediatric specialist").

**This is not a non-spec.** The source names a concrete capability (dosage validation against
per-drug safety rules) with eight checkable, numbered acceptance criteria covering the happy path,
two independent blocking paths, one role-conditioned exception, a data-transform rule, an audit
requirement, and a UX constraint. Proceed to `need-understanding` — there is real behavior here to
question and design tests against, not an empty shell.

## Validation

⚠ VALIDATION (extraction confirmed or corrected): **simulated: default applied** — non-interactive
run, no interactive user present in this measurement session. Default applied: the structure above
is accepted as-is (no corrections requested). First-class status per the shared contract
(`skills/README.md` rule 3); recorded here and flagged in `journey.md` as pending human review.
