# AC1 — state transition
# AC1-C1 — draft → submitted with valid data succeeds. [ep]
@QAIA-US-004-001 @AC1 @P2 @ep
Scenario: Submit a draft expense report with valid data
  Given a draft expense report exists
  When the employee submits the report
  Then the report status should be "submitted"

# AC1-C2 — submitted → changes-requested → draft (re-entrant); report is editable again. [state-transition]
@QAIA-US-004-002 @AC1 @P2 @state-transition
Scenario: Re-open a submitted report to changes-requested and return to draft
  Given a submitted expense report exists
  When the manager requests changes with a valid comment
  And the employee edits the report
  Then the report status should be "draft"
  And the report should be editable

# AC1-C3 — a changes-requested-turned-draft report is edited and re-submitted successfully. [state-transition]
@QAIA-US-004-003 @AC1 @P2 @state-transition
Scenario: Edit and re-submit a report after changes were requested
  Given a draft expense report exists after changes were requested
  When the employee submits the report
  Then the report status should be "submitted"

# AC1-C4 — [req-neg] submitting a report that is not draft (e.g. already submitted) is refused. [state-transition]
@QAIA-US-004-004 @AC1 @P2 @state-transition @negative
Scenario: Refuse submission of a non-draft report
  Given a submitted expense report exists
  When the employee attempts to submit the report
  Then the submission should be refused
  And the report status should remain "submitted"

# AC1-C5 — [req-neg] editing a report that is not draft is refused. [state-transition]
@QAIA-US-004-005 @AC1 @P2 @state-transition @negative
Scenario: Refuse editing of a non-draft report
  Given a submitted expense report exists
  When the employee attempts to edit the report
  Then the edit should be refused
  And the report status should remain "submitted"

# AC1-C6 — [req-neg] rejecting a report currently in draft (including via changes-requested) is refused — only submitted accepts a decision. [state-transition] @low-conf(Q3)
@QAIA-US-004-006 @AC1 @P1 @state-transition @negative @low-confidence
Scenario: Refuse rejection of a draft report
  Given a draft expense report exists
  When the manager attempts to reject the report
  Then the rejection should be refused
  And the report status should remain "draft"

# AC2 — boundary / decision table (approval chain by amount)
# AC2-C1 — total just under €500 (e.g. €499.99) requires exactly 1 approval (manager). [boundary]
@QAIA-US-004-007 @AC2 @P1 @boundary
Scenario: Approve expense report under €500 with manager approval
  Given an expense report with total €499.99 exists in "submitted" state
  When the manager approves the report
  Then the report status should be "approved"

# AC2-C2 — total exactly €500.00 requires 2 approvals (manager, finance). [boundary] @low-conf(Q1)
@QAIA-US-004-008 @AC2 @P1 @boundary @low-confidence
Scenario: Require finance approval for expense report exactly €500.00
  Given an expense report with total €500.00 exists in "submitted" state
  When the manager approves the report
  Then the report status should be "changes-requested"
  And the report should require finance approval
  When the finance approver approves the report
  Then the report status should be "approved"

# AC2-C3 — total exactly €5000.00 still requires 2 approvals (manager, finance) — upper end of band B. [boundary] @low-conf(Q1)
@QAIA-US-004-009 @AC2 @P1 @boundary @low-confidence
Scenario: Require finance approval for expense report exactly €5000.00
  Given an expense report with total €5000.00 exists in "submitted" state
  When the manager approves the report
  Then the report status should be "changes-requested"
  And the report should require finance approval
  When the finance approver approves the report
  Then the report status should be "approved"

# AC2-C4 — total just above €5000 (e.g. €5000.01) requires 3 approvals (manager, finance, director); full chain drives the report to approved. [boundary]
@QAIA-US-004-010 @AC2 @P1 @boundary
Scenario: Approve expense report over €5000 with full approval chain
  Given an expense report with total €5000.01 exists in "submitted" state
  When the manager approves the report
  Then the report status should be "changes-requested"
  And the report should require finance approval
  When the finance approver approves the report
  Then the report status should be "changes-requested"
  And the report should require director approval
  When the director approves the report
  Then the report status should be "approved"

# AC2-C5 — [req-neg] an approver whose role is not the current expected role in the chain (out-of-order attempt, e.g. finance acting before manager) is refused. [decision-table]
@QAIA-US-004-011 @AC2 @P1 @decision-table @negative
Scenario: Refuse out-of-order approval attempt
  Given an expense report with total €5000.01 exists in "submitted" state
  When the finance approver attempts to approve the report
  Then the approval should be refused
  And the report status should remain "submitted"

# AC3 — decision table (self-approval / skip-level)
# AC3-C1 — [req-neg] an approver attempting to decide on their own report is refused, regardless of role or band. [decision-table]
@QAIA-US-004-012 @AC3 @P1 @decision-table @negative
Scenario: Refuse self-approval of expense report
  Given an expense report created by the manager exists in "submitted" state
  When the manager attempts to approve the report
  Then the approval should be refused
  And the report status should remain "submitted"

# AC3-C2 — a manager submits a <€500 report: the manager step is replaced by finance (escalation), not left empty. [decision-table] @low-conf(Q2)
@QAIA-US-004-013 @AC3 @P1 @decision-table @low-confidence
Scenario: Escalate manager approval for <€500 report to finance
  Given an expense report with total €499.99 created by the manager exists in "submitted" state
  When the manager attempts to approve the report
  Then the approval should be refused
  And the report should be routed directly to finance for approval

# AC3-C3 — a manager submits a >€5000 report: the manager step is dropped (finance already required later), finance and director remain. [decision-table] @low-conf(Q2)
@QAIA-US-004-014 @AC3 @P1 @decision-table @low-confidence
Scenario: Skip manager approval for >€5000 report
  Given an expense report with total €5000.01 created by the manager exists in "submitted" state
  When the manager attempts to approve the report
  Then the approval should be refused
  And the report should skip manager approval and require finance and director approval

# AC3-C4 — a finance user submits a report requiring finance's own sign-off: the same skip/escalate rule generalizes (finance step replaced by director, or dropped if director already required). [decision-table] @low-conf(Q8)
@QAIA-US-004-015 @AC3 @P1 @decision-table @low-confidence
Scenario: Skip finance approval when finance user submits report requiring finance sign-off
  Given an expense report with total €5000.01 created by the finance user exists in "submitted" state
  When the finance user attempts to approve the report
  Then the approval should be refused
  And the report should skip finance approval and require director approval

# AC4 — equivalence partitioning / boundary
# AC4-C1 — [req-neg] a line missing category, amount, or date is refused at submission. [ep]
@QAIA-US-004-016 @AC4 @P3 @ep @negative
Scenario: Refuse expense report with missing line item data
  Given an expense report with a line item missing category exists
  When the employee attempts to submit the report
  Then the submission should be refused
  And an error message should indicate missing required fields

# AC4-C2 — a line dated exactly 90 days ago is accepted (inclusive boundary; server-clock reference). [boundary] @low-conf(Q5)
@QAIA-US-004-017 @AC4 @P2 @boundary @low-confidence
Scenario: Accept expense report line dated exactly 90 days ago
  Given an expense report with a line item dated exactly 90 days ago exists
  When the employee submits the report
  Then the report should be accepted
  And the line item should be included

# AC4-C3 — [req-neg] a line dated 91 days ago is blocked at submission with an explanatory message. [boundary]
@QAIA-US-004-018 @AC4 @P2 @boundary @negative
Scenario: Block expense report line dated 91 days ago
  Given an expense report with a line item dated 91 days ago exists
  When the employee attempts to submit the report
  Then the submission should be refused
  And an error message should indicate the line is too old

# AC5 — boundary value analysis
# AC5-C1 — a line just under the EUR-equivalent €25 threshold, no receipt, is accepted. [boundary]
@QAIA-US-004-019 @AC5 @P2 @boundary
Scenario: Accept expense report line just under €25 threshold without receipt
  Given an expense report with a line item of €24.99 and no receipt exists
  When the employee submits the report
  Then the report should be accepted

# AC5-C2 — [req-neg] a line at exactly the EUR-equivalent €25 threshold, no receipt, is refused. [boundary]
@QAIA-US-004-020 @AC5 @P1 @boundary @negative
Scenario: Refuse expense report line at exactly €25 threshold without receipt
  Given an expense report with a line item of €25.00 and no receipt exists
  When the employee attempts to submit the report
  Then the submission should be refused
  And an error message should indicate receipt is required

# AC5-C3 — a line ≥ €25 with a receipt attached is accepted. [ep]
@QAIA-US-004-021 @AC5 @P3 @ep
Scenario: Accept expense report line ≥ €25 with receipt
  Given an expense report with a line item of €25.00 and a receipt exists
  When the employee submits the report
  Then the report should be accepted

# AC5-C4 — [req-neg] a non-EUR line whose face value is < 25 but whose EUR-equivalent is ≥ 25 (no receipt) is refused — receipt threshold is EUR-basis, not face-value. [boundary] @low-conf(Q6)
@QAIA-US-004-022 @AC5 @P1 @boundary @negative @low-confidence
Scenario: Refuse non-EUR expense report line with face value <25 but EUR equivalent ≥25 without receipt
  Given an expense report with a line item of 24.99 USD (EUR equivalent €25.01) and no receipt exists
  When the employee attempts to submit the report
  Then the submission should be refused
  And an error message should indicate receipt is required

# AC6 — equivalence partitioning / error guessing (currency)
# AC6-C1 — a non-EUR report's total is converted correctly and the converted total (not the face value) drives AC2's band. [ep]
@QAIA-US-004-023 @AC6 @P1 @ep
Scenario: Convert non-EUR expense report total correctly for approval band determination
  Given an expense report with total 5000.01 USD exists
  And the EUR conversion rate is 1.0
  When the report is submitted
  Then the converted total should be €5000.01
  And the report should require 3 approvals

# AC6-C2 — [req-neg] a currency/date pair with no resolvable rate at all is refused at submission with an explanatory message. [error-guessing] @low-conf(Q4)
@QAIA-US-004-024 @AC6 @P1 @error-guessing @negative @low-confidence
Scenario: Refuse expense report with no resolvable currency conversion rate
  Given an expense report with a line item in an unsupported currency on a date with no rate exists
  When the employee attempts to submit the report
  Then the submission should be refused
  And an error message should indicate no conversion rate available

# AC6-C3 — an expense dated in a weekend/holiday gap (no exact-date rate) is accepted using the last available prior rate, and the report is flagged rateStale. [error-guessing] @low-conf(Q4)
@QAIA-US-004-025 @AC6 @P1 @error-guessing @low-confidence
Scenario: Accept expense report with stale currency conversion rate
  Given an expense report with a line item in USD dated on a weekend exists
  And the last available USD rate is 1.0
  When the employee submits the report
  Then the report should be accepted
  And the report should be flagged as having a stale rate

# AC6-C4 — a manager-submitted foreign-currency report converted via a stale fallback rate, landing near a band boundary, still drives both the band and the self-approval escalation from that (flagged) total. [decision-table] @low-conf(Q7)
@QAIA-US-004-026 @AC6 @P1 @decision-table @low-confidence
Scenario: Apply approval chain based on stale-converted total with escalation
  Given an expense report with total 499.99 USD (EUR equivalent €499.99) created by a manager exists
  And the report is flagged as having a stale rate
  When the manager attempts to approve the report
  Then the approval should be refused
  And the report should be routed directly to finance for approval

# AC7 — state transition (terminal)
# AC7-C1 — [req-neg] a rejected report cannot be edited. [state-transition]
@QAIA-US-004-027 @AC7 @P2 @state-transition @negative
Scenario: Refuse editing of a rejected report
  Given a rejected expense report exists
  When the employee attempts to edit the report
  Then the edit should be refused
  And the report status should remain "rejected"

# AC7-C2 — [req-neg] a rejected report cannot be re-submitted. [state-transition]
@QAIA-US-004-028 @AC7 @P2 @state-transition @negative
Scenario: Refuse re-submission of a rejected report
  Given a rejected expense report exists
  When the employee attempts to submit the report
  Then the submission should be refused
  And the report status should remain "rejected"

# AC8 — boundary / error guessing (audit trail)
# AC8-C1 — [req-neg] rejecting without a comment, or with a comment under 10 characters, is refused. [boundary]
@QAIA-US-004-029 @AC8 @P2 @boundary @negative
Scenario: Refuse rejection without valid comment
  Given a submitted expense report exists
  When the manager attempts to reject the report with comment "short"
  Then the rejection should be refused
  And the report status should remain "submitted"

# AC8-C2 — [req-neg] requesting changes without a comment, or with a comment under 10 characters, is refused. [boundary]
@QAIA-US-004-030 @AC8 @P2 @boundary @negative
Scenario: Refuse changes request without valid comment
  Given a submitted expense report exists
  When the manager attempts to request changes with comment "tiny"
  Then the changes request should be refused
  And the report status should remain "submitted"

# AC8-C3 — a comment of exactly 10 characters is accepted (boundary). [boundary]
@QAIA-US-004-031 @AC8 @P2 @boundary
Scenario: Accept rejection with exactly 10 character comment
  Given a submitted expense report exists
  When the manager rejects the report with comment "1234567890"
  Then the rejection should succeed
  And the report status should be "rejected"

# AC8-C4 — approving a report does not require a comment. [ep]
@QAIA-US-004-032 @AC8 @P3 @ep
Scenario: Approve expense report without comment
  Given a submitted expense report exists
  When the manager approves the report
  Then the approval should succeed
  And the report status should be "approved"

# AC8-C5 — every transition (create, submit, approve, reject, changes-requested) is recorded in the audit trail with who and when. [error-guessing]
@QAIA-US-004-033 @AC8 @P1 @error-guessing
Scenario: Record all transitions in audit trail
  Given an expense report exists
  When the employee submits the report
  Then the audit trail should contain a "submit" entry with employee and timestamp
  When the manager approves the report
  Then the audit trail should contain an "approve" entry with manager and timestamp
  When the manager rejects the report with a valid comment
  Then the audit trail should contain a "reject" entry with manager and timestamp
  When the manager requests changes with a valid comment
  Then the audit trail should contain a "changes-requested" entry with manager and timestamp

# Cross-cutting — authorization & server-side enforcement
# AC-auth-C1 — [req-neg] creating a report without authentication is refused (401). [error-guessing]
@QAIA-US-004-034 @AC-auth @P2 @error-guessing @negative
Scenario: Refuse unauthenticated report creation
  Given an unauthenticated session
  When the user attempts to create a new expense report
  Then the creation should be refused with status 401

# AC-auth-C2 — [req-neg] deciding on a report without authentication is refused (401). [error-guessing]
@QAIA-US-004-035 @AC-auth @P2 @error-guessing @negative
Scenario: Refuse unauthenticated decision on report
  Given an unauthenticated session
  When the user attempts to approve a submitted expense report
  Then the decision should be refused with status 401

# AC-auth-C3 — [req-neg] an employee attempting to edit another employee's draft is refused without disclosing whether the report exists (404, not 403). [error-guessing]
@QAIA-US-004-036 @AC-auth @P1 @error-guessing @negative
Scenario: Refuse unauthorized edit of another employee's draft report
  Given an expense report owned by another employee exists in "draft" state
  When the employee attempts to edit the report
  Then the edit should be refused with status 404

# List view
# AC-list-C1 — an employee with no reports sees an explicit empty state on "My reports". [ep]
@QAIA-US-004-037 @AC-list @P3 @ep
Scenario: Show empty state when employee has no reports
  Given an employee with no expense reports
  When the employee views their reports
  Then they should see an empty state message
