---
stepsCompleted: [00-ingest, 01-review, 02-understanding, 03-design, 04-priorities, 05-testbook-generate]
lastStep: 05-testbook-generate
lastSaved: 2026-07-25
---

# generated.snapshot — US-004

Regeneration baseline (C3 fix): scenario IDs generated in this run, for future diff-based
regeneration to detect human edits against. First generation — no prior snapshot to diff
against.

| Scenario ID | File | Title |
|---|---|---|
| @QAIA-US-004-001 | workflow-state-machine.feature | End-to-end journey — draft to first approval on a small report |
| @QAIA-US-004-002 | workflow-state-machine.feature | A complete draft is submitted successfully |
| @QAIA-US-004-003 | workflow-state-machine.feature | A changes-requested report returns to draft |
| @QAIA-US-004-004 | workflow-state-machine.feature | A changes-requested-turned-draft report is edited and re-submitted |
| @QAIA-US-004-005 | workflow-state-machine.feature | Submitting an already-submitted report is refused |
| @QAIA-US-004-006 | workflow-state-machine.feature | Editing a submitted (non-draft) report is refused |
| @QAIA-US-004-007 | workflow-state-machine.feature | A draft reached via changes-requested cannot be rejected directly |
| @QAIA-US-004-008 | approval-chain.feature | A report just under €500 needs only the manager's approval |
| @QAIA-US-004-009 | approval-chain.feature | A report of exactly €500.00 needs manager then finance |
| @QAIA-US-004-010 | approval-chain.feature | A report of exactly €5000.00 still needs only manager then finance |
| @QAIA-US-004-011 | approval-chain.feature | A report just above €5000 needs manager, finance, then director |
| @QAIA-US-004-012 | approval-chain.feature | An approver acting out of chain order is refused |
| @QAIA-US-004-013 | approval-chain.feature | An approver cannot decide on their own report |
| @QAIA-US-004-014 | approval-chain.feature | A manager's own small report escalates directly to finance |
| @QAIA-US-004-015 | approval-chain.feature | A manager's own large report skips the manager step but keeps finance and director |
| @QAIA-US-004-016 | approval-chain.feature | A finance user's own large report escalates the finance step to director |
| @QAIA-US-004-017 | line-items.feature | A line missing required fields is refused at submission |
| @QAIA-US-004-018 | line-items.feature | A line dated exactly 90 days ago is accepted |
| @QAIA-US-004-019 | line-items.feature | A line dated 91 days ago is blocked with an explanatory message |
| @QAIA-US-004-020 | line-items.feature | A line just under the receipt threshold needs no receipt |
| @QAIA-US-004-021 | line-items.feature | A line at exactly the receipt threshold without a receipt is refused |
| @QAIA-US-004-022 | line-items.feature | A line at or above the receipt threshold with a receipt is accepted |
| @QAIA-US-004-023 | line-items.feature | A non-EUR line whose EUR-equivalent crosses the receipt threshold is refused |
| @QAIA-US-004-024 | approval-chain.feature | A non-EUR report's converted total drives the approval band |
| @QAIA-US-004-025 | approval-chain.feature | Submitting in a currency with no resolvable rate is refused |
| @QAIA-US-004-026 | approval-chain.feature | An expense dated in a weekend rate gap uses the last available rate |
| @QAIA-US-004-027 | approval-chain.feature | A manager's stale-rate foreign report still drives band and escalation together |
| @QAIA-US-004-028 | workflow-state-machine.feature | A rejected report cannot be edited |
| @QAIA-US-004-029 | workflow-state-machine.feature | A rejected report cannot be re-submitted |
| @QAIA-US-004-030 | audit-and-auth.feature | Rejecting without a sufficient comment is refused |
| @QAIA-US-004-031 | audit-and-auth.feature | Requesting changes without a sufficient comment is refused |
| @QAIA-US-004-032 | audit-and-auth.feature | A comment of exactly 10 characters is accepted |
| @QAIA-US-004-033 | audit-and-auth.feature | Approving a report does not require a comment |
| @QAIA-US-004-034 | audit-and-auth.feature | Every transition is recorded in the audit trail with who and when |
| @QAIA-US-004-035 | audit-and-auth.feature | Creating a report without authentication is refused |
| @QAIA-US-004-036 | audit-and-auth.feature | Deciding on a report without authentication is refused |
| @QAIA-US-004-037 | audit-and-auth.feature | An employee cannot edit another employee's draft report |
| @QAIA-US-004-038 | audit-and-auth.feature | An employee with no reports sees an empty "My reports" list |

No retired IDs (first generation).
