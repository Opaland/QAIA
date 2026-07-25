---
stepsCompleted: [00-ingest]
lastStep: 00-ingest
lastSaved: 2026-07-25
---

# 00-source — US-002

## Source

- **Type**: file (gold-set fixture)
- **Location**: `eval/gold-set/US-002-dosage-validation.md`
- **Capture date**: 2026-07-25
- **US-ID**: `US-002` (taken from the gold-set filename; no tracker key present in the document itself)

## Triage gates

- Empty / whitespace only: not fired — substantial content (story + 8 numbered ACs).
- Not a testable requirement: not fired — describes a concrete capability (dosage validation) with explicit, checkable behavior.
- Abuse / illegality gate: not fired — no unlawful/abusive framing.

## Sensitive-data redaction

Scanned for direct personal/sensitive data (national IDs/SSN, payment card numbers, health status,
precise address, phone, email of real individuals). **None found** — the source is synthetic
(clean-room gold-set fixture, MIT-licensed) and contains no real individuals' data. Role names
("prescribing physician", "pediatric specialist") and generic references to "renal insufficiency
flag" are domain/business-rule concepts, not identifiable personal health data about a real
person. No masking applied; redaction ledger: none (nothing redacted).

## Captured text (verbatim, faithful)

# US-002 — Prescription dosage validation

> Gold set item. Original synthetic content (clean-room), MIT-licensed. Domain: health, prescribing module. Rich in boundary values — exercises equivalence partitioning and boundary value analysis.
> Deliberate ambiguities listed at the bottom for judge reference only.

## User story

**As a** prescribing physician,
**I want** the system to validate the dosage of a prescription against the drug's safety rules before I sign it,
**so that** dosage errors are caught before they reach the pharmacy.

## Acceptance criteria

1. Each drug has a reference record: minimum effective dose, maximum safe dose per intake, maximum cumulative dose per 24 h, and an age floor (minimum patient age in years).
2. A dosage strictly below the minimum effective dose triggers a *warning* the physician may override with a documented reason.
3. A dosage above the maximum safe dose per intake triggers a *blocking error*: the prescription cannot be signed.
4. The cumulative dose over 24 h (all intakes of the same drug for that patient) must not exceed the maximum cumulative dose; exceeding it is blocking.
5. If the patient's age is below the drug's age floor, prescription is blocked, except when the physician holds the "pediatric specialist" role, in which case it becomes an overridable warning with mandatory justification.
6. For patients with a recorded renal insufficiency flag, all maximum thresholds are reduced by 50 % before validation.
7. Every override (warning bypass) records the physician's identity, timestamp, and justification text of at least 20 characters in the audit trail.
8. Validation results (pass / warning / blocked, with rule identifiers) are returned within the signing screen without page reload.

> Note: the source document also carries a "Judge reference — planted ambiguities" section, marked
> explicitly "do not feed to skills" (evaluation-harness instrumentation, not part of the US).
> Per that instruction, it was **not** captured into this checkpoint and is excluded from downstream
> steps — flagged here for traceability only, not treated as source content.

## Attachments / referenced artifacts

None referenced (no links, mockups, or external attachments in the source).

## Dependencies (sibling-story terms, out-of-slice)

- Drug reference records (minimum/maximum thresholds, age floor) — defined by a drug-catalog
  system/story, not by this US. Referenced but not defined here.
- "Renal insufficiency flag" — sourced from the patient record; the story that sets/maintains this
  flag is not this one.
- Role model ("pediatric specialist" role) — presumably defined by an access-control/roles story.
- The source does not claim INVEST "Independent" explicitly, but these three undefined external
  terms mean it is not fully independent in practice.

## User validation

⚠ VALIDATION (US-ID, right document/version): **simulated: default applied** — non-interactive
run (no interactive user present in this measurement session). Default applied: US-ID accepted as
proposed (`US-002`), document accepted as the correct/current version of the gold-set fixture as
read from `eval/gold-set/US-002-dosage-validation.md`. This is a first-class status per the shared
contract (skills/README.md rule 3) and appears in the arbitration list as pending human review.
