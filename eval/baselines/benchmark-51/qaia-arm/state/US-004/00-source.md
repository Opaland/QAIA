---
stepsCompleted: [00-ingest]
lastStep: 00-ingest
lastSaved: 2026-07-28
---

# 00-source — US-004

- **Source type**: file (Markdown), read from the repository.
- **Location**: `eval/gold-set/US-004-expense-approval.md`.
- **Sections read**: `## User story` and `## Acceptance criteria` **only** — the file's
  "Judge reference — planted ambiguities" section was deliberately NOT read (task constraint;
  also consistent with ingest's "fetch/read exactly that source — nothing else" once the
  designated slice is the two named sections).
- **Capture date**: 2026-07-28.
- **US-ID**: US-004 — `simulated: accepted-as-is`.
- **Redaction**: scanned for national IDs/SSN, card numbers, health status, precise address,
  phone, email of real individuals — **none found**. Nothing masked. `type → placeholder →
  count` ledger: empty.
- **Sanitization**: no control characters or bidi-override characters found.
- **Attachments/images referenced**: none.
- **Dependencies** (sibling-story terms used but not defined here): none explicitly
  referenced by name; roles ("direct manager", "finance", "director") are used as if their
  definition (who holds them, how they're assigned) is common organizational knowledge, not
  as a pointer to another backlog story — recorded as an ambiguity/gap in `02-understanding.md`
  rather than a sibling dependency, since nothing in the text points to another ticket.

## Captured text (faithful, as ingested)

### User story

As an employee, I want to submit an expense report and have it approved through the right
chain, so that I get reimbursed correctly and the company keeps an auditable trail.

### Acceptance criteria

1. A report moves through states: `draft` → `submitted` → (`approved` | `rejected` |
   `changes-requested`). A `changes-requested` report returns to `draft` for editing and can be
   re-submitted.
2. A report under €500 total needs one approval (the employee's direct manager). €500–€5000
   needs manager **then** finance. Above €5000 needs manager, finance, **then** a director.
3. An approver cannot approve their own report; if the submitter is themselves a manager, their
   report skips straight to the next level up.
4. Each line item must have a category, an amount, and a date within the last 90 days; a line
   outside 90 days is blocked at submission with an explanatory message.
5. Receipts are mandatory for any single line ≥ €25; submission is refused if a ≥ €25 line has
   no attached receipt.
6. Currency other than EUR is converted at the rate of the expense date; the converted total
   drives the approval threshold of AC2.
7. A rejected report is terminal and cannot be edited or re-submitted; a new report must be
   created.
8. Every state transition records who, when, and (for rejections and changes-requested) a
   mandatory comment of at least 10 characters.

## Validation

⚠ VALIDATION (source correct, right version): `simulated: accepted-as-is`.
