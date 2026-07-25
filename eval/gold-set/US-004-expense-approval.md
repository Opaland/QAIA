# US-004 — Expense report approval workflow

> Gold set item. Original synthetic content (clean-room), MIT-licensed. Domain: finance/HR, non-medical (tests cross-domain robustness). State-machine + decision-table heavy.
> Deliberate ambiguities listed at the bottom for judge reference only — NOT part of the US text given to the skills.

## User story

**As an** employee,
**I want** to submit an expense report and have it approved through the right chain,
**so that** I get reimbursed correctly and the company keeps an auditable trail.

## Acceptance criteria

1. A report moves through states: `draft` → `submitted` → (`approved` | `rejected` | `changes-requested`). A `changes-requested` report returns to `draft` for editing and can be re-submitted.
2. A report under €500 total needs one approval (the employee's direct manager). €500–€5000 needs manager **then** finance. Above €5000 needs manager, finance, **then** a director.
3. An approver cannot approve their own report; if the submitter is themselves a manager, their report skips straight to the next level up.
4. Each line item must have a category, an amount, and a date within the last 90 days; a line outside 90 days is blocked at submission with an explanatory message.
5. Receipts are mandatory for any single line ≥ €25; submission is refused if a ≥ €25 line has no attached receipt.
6. Currency other than EUR is converted at the rate of the expense date; the converted total drives the approval threshold of AC2.
7. A rejected report is terminal and cannot be edited or re-submitted; a new report must be created.
8. Every state transition records who, when, and (for rejections and changes-requested) a mandatory comment of at least 10 characters.

## Judge reference — planted ambiguities (do not feed to skills)

- AC2/AC6: is the €500/€5000 threshold inclusive or exclusive? "under €500" vs "€500–€5000" — what happens at exactly €500.00? Deliberately ambiguous at the boundary.
- AC3: if a manager submits a report **above €5000**, does "skip to next level up" mean skip only the manager step (finance + director remain) or something else? Under-specified.
- AC1 × AC7: a `changes-requested` report returning to `draft` — can it be *rejected* from there, becoming terminal, or only re-submitted? Interaction left open.
- AC6: which rate source, and what if no rate exists for a weekend/holiday expense date? Not specified.
