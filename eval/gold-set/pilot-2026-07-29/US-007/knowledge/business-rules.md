# Business rules — payment-gated flows & method naming

## BR-KB-001

A payment-required (paid-access) flow must never grant access, enrol the user, or record a charge on a failed, declined, timed-out, or user-cancelled payment attempt. Access/enrolment is granted only on an explicit successful-payment confirmation event.

- Provenance: US-007, need-understanding Q1/Q2, 2026-07-29, decided-by: simulated (non-interactive run, accepted default — flagged for human confirmation, see `openArbitrations`).
- Testable: yes — "cancel/fail → not enrolled, not charged" is directly assertable.

## BR-KB-002

A required-fee amount must be strictly greater than zero; configuration UIs must reject zero or negative fee amounts for a "payment required" method.

- Provenance: US-007, need-understanding Q1, 2026-07-29, decided-by: simulated.
- Testable: yes — boundary condition at 0 and below.

## BR-KB-003

A configurable display name/description on an enrolment (or similarly named) method is a live property: changing it changes what every subsequent viewer sees immediately; it is not versioned or snapshotted per prior viewer or prior enrolment.

- Provenance: US-007, need-understanding Q7, 2026-07-29, decided-by: simulated.
- Testable: yes — rename then re-view assertion.

No contradictions found against existing content (knowledge base was empty prior to this run).
