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

## Judge reference — planted ambiguities (do not feed to skills)

- Boundary semantics: are the thresholds inclusive or exclusive ("above", "below", "exceed")? Deliberately inconsistent wording.
- AC6: does the 50 % reduction also apply to the *minimum* effective dose? Not specified.
- AC4: is the 24 h window rolling or calendar-day? Not specified.
- Rounding: dosages can be decimal; no rounding rule is given.
