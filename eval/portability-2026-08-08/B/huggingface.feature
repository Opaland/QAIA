Feature: US-004 Expense Report Workflow

# US-004 AC1 AC1-C1
@QAIA-US-004-001 @AC1 @P2 @state-transition
Scenario: Submitting a draft report with valid data succeeds
  Given a report in draft status with valid data
  When the user submits the report
  Then the report status becomes submitted

# US-004 AC1 AC1-C2
@QAIA-US-004-002 @AC1 @P2 @state-transition
Scenario: Requesting changes on a submitted report moves it to changes‑requested
  Given a report in submitted status
  When a reviewer requests changes on the report
  Then the report status becomes changes-requested

# US-004 AC1 AC1-C3
@QAIA-US-004-003 @AC1 @P2 @state-transition
Scenario: Resubmitting a report after changes‑requested returns it to draft
  Given a report that was changes‑requested and has been returned to draft
  When the author submits the report
  Then the report status becomes submitted

# US-004 AC1 AC1-C4
@QAIA-US-004-004 @AC1 @P2 @state-transition @negative
Scenario: Submitting a report that is not draft is refused
  Given a report in submitted status
  When the user attempts to submit the report
  Then the submission is refused with an error

# US-004 AC1 AC1-C5
@QAIA-US-004-005 @AC1 @P2 @state-transition @negative
Scenario: Editing a report that is not draft is refused
  Given a report in submitted status
  When the user attempts to edit the report
  Then the edit operation is refused with an error

# US-004 AC1 AC1-C6
@QAIA-US-004-006 @AC1 @P1 @state-transition @negative @low-confidence
Scenario: Rejecting a draft report is refused
  Given a report in draft status
  When a reviewer attempts to reject the report
  Then the rejection is refused with an error

# US-004 AC2 AC2-C1
@QAIA-US-004-007 @AC2 @P1 @boundary
Scenario: Total just under €500 requires a single manager approval
  Given a report with a total amount of €499.99
  When the approval workflow is evaluated
  Then the approval chain contains exactly 1 approver (manager)

# US-004 AC2 AC2-C2
@QAIA-US-004-008 @AC2 @P1 @boundary @low-confidence
Scenario: Total exactly €500 requires manager and finance approvals
  Given a report with a total amount of €500.00
  When the approval workflow is evaluated
  Then the approval chain contains exactly 2 approvers (manager and finance)

# US-004 AC2 AC2-C3
@QAIA-US-004-009 @AC2 @P1 @boundary @low-confidence
Scenario: Total exactly €5000 still requires manager and finance approvals
  Given a report with a total amount of €5000.00
  When the approval workflow is evaluated
  Then the approval chain contains exactly 2 approvers (manager and finance)

# US-004 AC2 AC2-C4
@QAIA-US-004-010 @AC2 @P1 @boundary
Scenario: Total just above €5000 requires three approvals and results in approved status
  Given a report with a total amount of €5000.01
  When the approval workflow is evaluated
  Then the approval chain contains exactly 3 approvers (manager, finance, director)
  And the final report status becomes approved

# US-004 AC2 AC2-C5
@QAIA-US-004-011 @AC2 @P1 @decision-table @negative
Scenario: Out‑of‑order approver attempt is refused
  Given a report awaiting manager approval
  When a finance user attempts to approve before the manager
  Then the approval attempt is refused with an error

# US-004 AC3 AC3-C1
@QAIA-US-004-012 @AC3 @P1 @decision-table @negative
Scenario: Self‑approval of a report is refused
  Given a report submitted by a manager
  When the same manager attempts to approve the report
  Then the approval attempt is refused with an error

# US-004 AC3 AC3-C2
@QAIA-US-004-013 @AC3 @P1 @decision-table @low-confidence
Scenario: Manager submits a < €500 report; finance step replaces manager
  Given a report with a total amount of €400.00 submitted by a manager
  When the approval workflow is evaluated
  Then the finance approver replaces the manager step in the approval chain

# US-004 AC3 AC3-C3
@QAIA-US-004-014 @AC3 @P1 @decision-table @low-confidence
Scenario: Manager submits a > €5000 report; manager step is dropped
  Given a report with a total amount of €6000.00 submitted by a manager
  When the approval workflow is evaluated
  Then the manager step is omitted from the approval chain

# US-004 AC3 AC3-C4
@QAIA-US-004-015 @AC3 @P1 @decision-table @low-confidence
Scenario: Finance user submits a report requiring finance’s own sign‑off; finance step is replaced by director
  Given a report with a total amount of €3000.00 submitted by a finance user
  When the approval workflow is evaluated
  Then the finance approver step is replaced by the director in the approval chain

# US-004 AC4 AC4-C1
@QAIA-US-004-016 @AC4 @P3 @ep @negative
Scenario: Submitting a line missing required fields is refused
  Given a report line with missing category, amount, or date
  When the user attempts to submit the line
  Then the submission is refused with a validation error

# US-004 AC4 AC4-C2
@QAIA-US-004-017 @AC4 @P2 @boundary @low-confidence
Scenario: Line dated exactly 90 days ago is accepted
  Given a report line dated 90 days before the current server date
  When the user submits the line
  Then the line is accepted

# US-004 AC4 AC4-C3
@QAIA-US-004-018 @AC4 @P2 @boundary @negative
Scenario: Line dated 91 days ago is blocked at submission
  Given a report line dated 91 days before the current server date
  When the user attempts to submit the line
  Then the submission is refused with a date‑range error

# US-004 AC5 AC5-C1
@QAIA-US-004-019 @AC5 @P2 @boundary
Scenario: Line just under €25 threshold without receipt is accepted
  Given a report line with an amount of €24.99 and no receipt
  When the user submits the line
  Then the line is accepted

# US-004 AC5 AC5-C2
@QAIA-US-004-020 @AC5 @P1 @boundary @negative
Scenario: Line at exactly €25 threshold without receipt is refused
  Given a report line with an amount of €25.00 and no receipt
  When the user attempts to submit the line
  Then the submission is refused with a receipt‑required error

# US-004 AC5 AC5-C3
@QAIA-US-004-021 @AC5 @P3 @ep
Scenario: Line ≥ €25 with a receipt attached is accepted
  Given a report line with an amount of €30.00, a receipt attached, and any currency
  When the user submits the line
  Then the line is accepted

# US-004 AC5 AC5-C4
@QAIA-US-004-022 @AC5 @P1 @boundary @negative @low-confidence
Scenario: Non‑EUR line below €25 but EUR‑equivalent ≥ €25 without receipt is refused
  Given a non‑EUR report line with a face value of €20.00, an EUR‑equivalent of €25.00, and no receipt
  When the user attempts to submit the line
  Then the submission is refused with a receipt‑required error

# US-004 AC6 AC6-C1
@QAIA-US-004-023 @AC6 @P1 @ep
Scenario: Non‑EUR total is converted correctly and drives the approval band
  Given a non‑EUR report with a total that converts to €750.00
  When the conversion is performed
  Then the resulting amount places the report in the €500‑€5000 approval band

# US-004 AC6 AC6-C2
@QAIA-US-004-024 @AC6 @P1 @error-guessing @negative @low-confidence
Scenario: Submission with a currency/date pair that has no resolvable rate is refused
  Given a report with a currency/date pair for which no exchange rate can be found
  When the user attempts to submit the report
  Then the submission is refused with an exchange‑rate error

# US-004 AC6 AC6-C3
@QAIA-US-004-025 @AC6 @P1 @error-guessing @low-confidence
Scenario: Weekend/holiday dated expense uses last available prior rate and is flagged as stale
  Given a report dated on a weekend with no rate for that day, using the most recent prior rate
  When the conversion is performed
  Then the conversion uses the prior rate and the report is flagged as rateStale

# US-004 AC6 AC6-C4
@QAIA-US-004-026 @AC6 @P1 @decision-table @low-confidence
Scenario: Manager‑submitted foreign‑currency report near a boundary with a stale rate still drives band and escalation
  Given a manager‑submitted report in foreign currency that converts (using a stale rate) to €499.99
  When the approval workflow is evaluated
  Then the report falls in the < €500 band and the finance escalation rule is applied

# US-004 AC7 AC7-C1
@QAIA-US-004-027 @AC7 @P2 @state-transition @negative
Scenario: Editing a rejected report is refused
  Given a report in rejected status
  When the user attempts to edit the report
  Then the edit operation is refused with an error

# US-004 AC7 AC7-C2
@QAIA-US-004-028 @AC7 @P2 @state-transition @negative
Scenario: Re‑submitting a rejected report is refused
  Given a report in rejected status
  When the user attempts to re‑submit the report
  Then the submission is refused with an error

# US-004 AC8 AC8-C1
@QAIA-US-004-029 @AC8 @P2 @boundary @negative
Scenario: Rejecting without a comment or with a comment under 10 characters is refused
  Given a report pending rejection
  When the reviewer attempts to reject the report with a comment shorter than 10 characters
  Then the rejection is refused with a validation error

# US-004 AC8 AC8-C2
@QAIA-US-004-030 @AC8 @P2 @boundary @negative
Scenario: Requesting changes without a comment or with a comment under 10 characters is refused
  Given a report pending changes‑requested
  When the reviewer attempts to request changes with a comment shorter than 10 characters
  Then the request is refused with a validation error

# US-004 AC8 AC8-C3
@QAIA-US-004-031 @AC8 @P2 @boundary
Scenario: A comment of exactly 10 characters is accepted
  Given a report pending approval with a comment of exactly 10 characters
  When the reviewer submits the comment
  Then the comment is accepted

# US-004 AC8 AC8-C4
@QAIA-US-004-032 @AC8 @P3 @ep
Scenario: Approving a report does not require a comment
  Given a report pending approval
  When the approver approves the report without providing a comment
  Then the approval succeeds

# US-004 AC8 AC8-C5
@QAIA-US-004-033 @AC8 @P1 @error-guessing
Scenario: Every transition is recorded in the audit trail with who and when
  Given any transition event on a report (create, submit, approve, reject, changes‑requested)
  When the event occurs
  Then an audit‑trail entry is created recording the user identity and timestamp

# US-004 AC-auth AC-auth-C1
@QAIA-US-004-034 @AC-auth @P2 @error-guessing @negative
Scenario: Creating a report without authentication is refused (401)
  Given an unauthenticated user
  When the user attempts to create a new report
  Then the operation is refused with an HTTP 401 error

# US-004 AC-auth AC-auth-C2
@QAIA-US-004-035 @AC-auth @P2 @error-guessing @negative
Scenario: Deciding on a report without authentication is refused (401)
  Given an unauthenticated user
  When the user attempts to approve a report
  Then the operation is refused with an HTTP 401 error

# US-004 AC-auth AC-auth-C3
@QAIA-US-004-036 @AC-auth @P1 @error-guessing @negative
Scenario: Editing another employee’s draft without permission is refused without disclosing existence (404)
  Given a draft report owned by employee A
  And user B is authenticated as a different employee
  When user B attempts to edit employee A’s draft report
  Then the operation is refused with an HTTP 404 error

# US-004 AC-list AC-list-C1
@QAIA-US-004-037 @AC-list @P3 @ep
Scenario: Employee with no reports sees an explicit empty state
  Given an authenticated employee with no reports in the system
  When the employee views the “My reports” list
  Then the list is displayed as empty with a clear “no reports” message