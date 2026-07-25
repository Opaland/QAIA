---
stepsCompleted: [00-ingest, 01-review]
lastStep: 01-review
lastSaved: 2026-07-25
---

# 01-extraction — US-004

## Story

- **As a**: employee
- **I want**: to submit an expense report and have it approved through the right chain
- **So that**: I get reimbursed correctly and the company keeps an auditable trail

## Acceptance criteria (numbered, stable — never renumbered downstream)

- **AC1** — State machine: `draft` → `submitted` → (`approved` | `rejected` | `changes-requested`). `changes-requested` → `draft` (editable), and a `draft` can be re-submitted.
- **AC2** — Approval chain by amount band: `<€500` → manager only; `€500–€5000` → manager then finance; `>€5000` → manager, finance, then director.
- **AC3** — Self-approval forbidden; a manager-submitter's report "skips straight to the next level up".
- **AC4** — Line item shape: category, amount, date; date must be within the last 90 days or submission is blocked with an explanatory message.
- **AC5** — Receipt mandatory for any single line ≥ €25; submission refused otherwise.
- **AC6** — Non-EUR currency converted at the rate of the expense date; the converted total drives AC2's threshold.
- **AC7** — `rejected` is terminal: no edit, no re-submit; a new report is required.
- **AC8** — Every state transition records who + when; `rejected` and `changes-requested` additionally require a comment ≥ 10 characters.

## Business rules / constraints found outside the numbered AC list

- Roles are implied, not defined in a glossary: `employee`, `manager` (with a "direct manager" relationship to an employee), `finance`, `director`. The story assumes a fixed reporting hierarction but does not spell it out — treated as a business rule the design must make explicit test data for.
- "the right chain" (story goal) is operationalized by AC2/AC3 together.
- Currency: EUR is the reference/reporting currency (implicit from "currency other than EUR is converted").

## Referenced artifacts not analyzed

- None. No attachments, mockups or external links in the source.

## Present but not classifiable

- None — every sentence in the source maps to a story element, an AC, or a rule above. Nothing dropped.

## What was NOT found (explicit, per the diff mentality)

- No non-functional requirements (performance, availability) stated.
- No explicit currency list (which currencies are accepted) — only "other than EUR" is mentioned.
- No explicit definition of "explanatory message" content for AC4, nor of audit-trail visibility/access (who may read the audit trail).
- No mention of notifications (email/in-app) to approvers or submitters.

⚠ VALIDATION: extraction confirmed (non-interactive mode — `simulated: accepted-as-is`, no corrections). Every AC in the source is captured; numbering AC1–AC8 is final and will anchor all downstream traceability (conditions, scenarios, coverage matrix).

## Journey checkpoint

- Step `01-review`: **done**.
- Next step: `need-understanding`.
