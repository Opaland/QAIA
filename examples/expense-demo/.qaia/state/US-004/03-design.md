---
stepsCompleted: [00-ingest, 01-review, 02-understanding, 03-design]
lastStep: 03-design
lastSaved: 2026-07-25
---

# 03-design — US-004 (ISTQB technique map + conditions)

Knowledge base: absent for this project slice — proceeding on the source + `02-understanding.md`
alone (degraded mode, shared-contract rule 8). `design.knowledgeApplied` will be empty in the
manifest.

## AC → technique map

| AC | Technique(s) | Justification |
|---|---|---|
| AC1 | State transition | Explicit lifecycle (`draft/submitted/approved/rejected/changes-requested`) with a re-entrant loop (`changes-requested → draft`) — the textbook fit for state-transition testing. |
| AC2 | Boundary value analysis + Decision table | Three amount bands with two literal boundaries (€500, €5000) → BVA; the resulting required-role set per band is a decision table (amount band × role). |
| AC3 | Decision table | Outcome (who approves next) is a function of two independent conditions: submitter's role × current chain position — classic decision-table shape. |
| AC4 | Equivalence partitioning + Boundary value analysis | Line shape is an EP class (complete/incomplete); the 90-day age check is a boundary on a computed duration. |
| AC5 | Boundary value analysis | A strict amount threshold (€25) on receipt requirement — BVA at value/value-1. |
| AC6 | Equivalence partitioning + Error guessing | Currency conversion is an EP class (EUR vs non-EUR); missing/stale rate is an error-guessing condition anchored on the ambiguity log (Q4). |
| AC7 | State transition | Terminal-state rule — re-uses AC1's state model, asserting `rejected` has no outgoing edge. |
| AC8 | Boundary value analysis + Error guessing | The 10-character comment minimum is a literal boundary; audit-trail completeness is error-guessing/checklist (who/when present on every transition). |
| (cross-cutting) | Error guessing / checklist | Authorization and IDOR conditions, anchored on the `istqb-design` 3c systematic-expansion checklist (not named per-AC in the source, but a reflex expansion for any authenticated multi-actor workflow). |

## Test conditions (input contract for `testbook-generate`)

Tag legend: `[req-neg]` = required-negative (ADR 0001 gate). `@low-conf` = built on an
`[open]`/`[assumption]` item from `02-understanding.md`, cites the question ID.

### AC1 — state transition

- **AC1-C1** — `draft` → `submitted` with valid data succeeds. `[ep]`
- **AC1-C2** — `submitted` → `changes-requested` → `draft` (re-entrant); report is editable again. `[state-transition]`
- **AC1-C3** — a `changes-requested`-turned-`draft` report is edited and re-submitted successfully. `[state-transition]`
- **AC1-C4** — `[req-neg]` submitting a report that is not `draft` (e.g. already `submitted`) is refused. `[state-transition]`
- **AC1-C5** — `[req-neg]` editing a report that is not `draft` is refused. `[state-transition]`
- **AC1-C6** — `[req-neg]` rejecting a report currently in `draft` (including one reached via `changes-requested`) is refused — only `submitted` accepts a decision. `@low-conf(Q3)` `[state-transition]`

### AC2 — boundary / decision table (approval chain by amount)

- **AC2-C1** — total just under €500 (e.g. €499.99) requires exactly 1 approval (manager). `[boundary]`
- **AC2-C2** — total exactly €500.00 requires 2 approvals (manager, finance). `@low-conf(Q1)` `[boundary]`
- **AC2-C3** — total exactly €5000.00 still requires 2 approvals (manager, finance) — upper end of band B. `@low-conf(Q1)` `[boundary]`
- **AC2-C4** — total just above €5000 (e.g. €5000.01) requires 3 approvals (manager, finance, director); full chain drives the report to `approved`. `[boundary]`
- **AC2-C5** — `[req-neg]` an approver whose role is not the current expected role in the chain (out-of-order attempt, e.g. finance acting before manager) is refused. `[decision-table]`

### AC3 — decision table (self-approval / skip-level)

- **AC3-C1** — `[req-neg]` an approver attempting to decide on their own report is refused, regardless of role or band. `[decision-table]`
- **AC3-C2** — a manager submits a <€500 report: the manager step is replaced by finance (escalation), not left empty. `@low-conf(Q2)` `[decision-table]`
- **AC3-C3** — a manager submits a >€5000 report: the manager step is dropped (finance already required later), finance and director remain. `@low-conf(Q2)` `[decision-table]`
- **AC3-C4** — a finance user submits a report requiring finance's own sign-off: the same skip/escalate rule generalizes (finance step replaced by director, or dropped if director already required). `@low-conf(Q8)` `[decision-table]`

### AC4 — equivalence partitioning / boundary

- **AC4-C1** — `[req-neg]` a line missing category, amount, or date is refused at submission. `[ep]`
- **AC4-C2** — a line dated exactly 90 days ago is accepted (inclusive boundary; server-clock reference, Q5). `@low-conf(Q5)` `[boundary]`
- **AC4-C3** — `[req-neg]` a line dated 91 days ago is blocked at submission with an explanatory message. `[boundary]`

### AC5 — boundary value analysis

- **AC5-C1** — a line just under the EUR-equivalent €25 threshold, no receipt, is accepted. `[boundary]`
- **AC5-C2** — `[req-neg]` a line at exactly the EUR-equivalent €25 threshold, no receipt, is refused. `[boundary]`
- **AC5-C3** — a line ≥ €25 with a receipt attached is accepted. `[ep]`
- **AC5-C4** — `[req-neg]` a non-EUR line whose face value is < 25 but whose EUR-equivalent is ≥ 25 (no receipt) is refused — receipt threshold is EUR-basis, not face-value. `@low-conf(Q6)` `[boundary]`

### AC6 — equivalence partitioning / error guessing (currency)

- **AC6-C1** — a non-EUR report's total is converted correctly and the converted total (not the face value) drives AC2's band. `[ep]`
- **AC6-C2** — `[req-neg]` a currency/date pair with no resolvable rate at all is refused at submission with an explanatory message. `@low-conf(Q4)` `[error-guessing]`
- **AC6-C3** — an expense dated in a weekend/holiday gap (no exact-date rate) is accepted using the last available prior rate, and the report is flagged `rateStale`. `@low-conf(Q4)` `[error-guessing]`
- **AC6-C4** — a manager-submitted foreign-currency report converted via a stale fallback rate, landing near a band boundary, still drives both the band and the self-approval escalation from that (flagged) total. `@low-conf(Q7)` `[decision-table]`

### AC7 — state transition (terminal)

- **AC7-C1** — `[req-neg]` a `rejected` report cannot be edited. `[state-transition]`
- **AC7-C2** — `[req-neg]` a `rejected` report cannot be re-submitted. `[state-transition]`

### AC8 — boundary / error guessing (audit trail)

- **AC8-C1** — `[req-neg]` rejecting without a comment, or with a comment under 10 characters, is refused. `[boundary]`
- **AC8-C2** — `[req-neg]` requesting changes without a comment, or with a comment under 10 characters, is refused. `[boundary]`
- **AC8-C3** — a comment of exactly 10 characters is accepted (boundary). `[boundary]`
- **AC8-C4** — approving a report does not require a comment. `[ep]`
- **AC8-C5** — every transition (create, submit, approve, reject, changes-requested) is recorded in the audit trail with who and when. `[error-guessing]`

### Cross-cutting — authorization & server-side enforcement (3c systematic expansion)

- **AC-auth-C1** — `[req-neg]` creating a report without authentication is refused (401). `[error-guessing]`
- **AC-auth-C2** — `[req-neg]` deciding on a report without authentication is refused (401). `[error-guessing]`
- **AC-auth-C3** — `[req-neg]` an employee attempting to edit another employee's draft is refused without disclosing whether the report exists (404, not 403). `[error-guessing]`

### List view (3c reflex, minimal — see ceiling note below)

- **AC-list-C1** — an employee with no reports sees an explicit empty state on "My reports". `[ep]`

## Ceiling — ranges NOT generated (3c, honest recall over fabrication)

- **No delete/discard mechanism** for a draft is named anywhere in the source → not generated (would be fabrication per the ceiling rule); flagged as a gap in `synthesis.md`.
- **No sort/filter/pagination** on the "mine"/"inbox" lists is named or implied by the source (unlike, say, a search screen) → not generated; flagged as a gap.
- **No notification mechanism** (email/in-app) is named → not generated; flagged as a gap.

## Journey checkpoint

- Step `03-design`: **done**. 37 conditions across 8 AC + 2 cross-cutting groups; 17 tagged
  `[req-neg]`.
- Next step: `prioritize`.
