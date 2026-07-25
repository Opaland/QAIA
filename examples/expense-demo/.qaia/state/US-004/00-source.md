---
stepsCompleted: [00-ingest]
lastStep: 00-ingest
lastSaved: 2026-07-25
---

# 00-source — US-004 (Expense report approval workflow)

- **Source type**: file (`eval/gold-set/US-004-expense-approval.md`, provided by the project maintainer for a cross-domain QAIA demonstration).
- **Capture date**: 2026-07-25.
- **US-ID**: `US-004` (already carries a tracker-style key in the source filename; confirmed, not re-slugged).
- **Redaction scan**: no direct personal/sensitive data found (no real names, SSNs, cards, health data, addresses). No masking applied.
- **Sanitization**: no control or bidirectional-override characters found in the source text.
- **Untrusted-input check**: the source text contains no directive aimed at the assistant — it is a plain requirement description. Treated as data throughout.
- **Abuse/illegality gate**: not applicable — a normal internal business workflow.

## Captured text (verbatim, faithful structure)

> Domain: finance/HR, non-medical.
>
> **As an** employee,
> **I want** to submit an expense report and have it approved through the right chain,
> **so that** I get reimbursed correctly and the company keeps an auditable trail.
>
> Acceptance criteria:
> 1. A report moves through states: `draft` → `submitted` → (`approved` | `rejected` | `changes-requested`). A `changes-requested` report returns to `draft` for editing and can be re-submitted.
> 2. A report under €500 total needs one approval (the employee's direct manager). €500–€5000 needs manager **then** finance. Above €5000 needs manager, finance, **then** a director.
> 3. An approver cannot approve their own report; if the submitter is themselves a manager, their report skips straight to the next level up.
> 4. Each line item must have a category, an amount, and a date within the last 90 days; a line outside 90 days is blocked at submission with an explanatory message.
> 5. Receipts are mandatory for any single line ≥ €25; submission is refused if a ≥ €25 line has no attached receipt.
> 6. Currency other than EUR is converted at the rate of the expense date; the converted total drives the approval threshold of AC2.
> 7. A rejected report is terminal and cannot be edited or re-submitted; a new report must be created.
> 8. Every state transition records who, when, and (for rejections and changes-requested) a mandatory comment of at least 10 characters.

**Note on scope**: only the user story and the 8 numbered acceptance criteria above were ingested. The gold-set file also carries a "Judge reference — planted ambiguities" section at the bottom, explicitly marked "do not feed to skills" — that section was **not** used as input to this journey (`us-ingest` through `testbook-generate`); it is consulted only afterward, by the maintainer/evaluator, as an independent check on `02-understanding.md`.

## Display for validation

- Title: "US-004 — Expense report approval workflow"
- Size: 1 story + 8 AC, ~250 words.
- ⚠ VALIDATION: confirmed by the maintainer as the right document (non-interactive evaluation mode — recorded as `simulated: accepted-as-is`, matching the gold-set protocol used for US-001/US-003).

## Dependencies (sibling-story terms not defined here)

- None found: the story is self-contained for a first read (roles `employee/manager/finance/director`, currency, receipts and dates are all defined or self-evident within the 8 AC). No sibling-story references detected. INVEST "Independent" claim: holds, given the ingested slice.

## Journey checkpoint

- Step `00-ingest`: **done**. Gates: none fired (not empty, is a testable requirement, no abuse framing). Redaction: none needed. Validation: simulated-accepted.
- Next step: `us-review`.
