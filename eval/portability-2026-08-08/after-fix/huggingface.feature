Feature: Expense Report Workflow

  @QAIA-US-004-001 @AC1 @P2 @state-transition
  Scenario: Draft report submission succeeds
    # AC1-C1 — draft → submitted with valid data succeeds.
    Given a draft report with valid data
    When the report is submitted
    Then the report status becomes submitted

  @QAIA-US-004-002 @AC1 @P2 @state-transition
  Scenario: Changes‑requested to draft transition allows editing
    # AC1-C2 — changes‑requested → draft (re‑entrant); report is editable again.
    Given a report in changes‑requested state
    When the report is moved to draft
    Then the report becomes editable

  @QAIA-US-004-003 @AC1 @P2 @state-transition
  Scenario: Editing a re‑entered draft and resubmitting succeeds
    # AC1-C3 — edited draft after changes‑requested is resubmitted successfully.
    Given a draft report that was previously changes‑requested and edited
    When the report is submitted
    Then the report status becomes submitted

  @QAIA-US-004-004 @AC1 @P2 @negative @state-transition
  Scenario: Submitting a non‑draft report is refused
    # AC1-C4 — submitting a report that is not draft is refused.
    Given a report that is already submitted
    When an attempt is made to submit the report
    Then the submission is refused

  @QAIA-US-004-005 @AC1 @P2 @negative @state-transition
  Scenario: Editing a non‑draft report is refused
    # AC1-C5 — editing a report that is not draft is refused.
    Given a report in submitted state
    When an attempt is made to edit the report
    Then the edit is refused

  @QAIA-US-004-006 @AC1 @P1 @negative @low-confidence
    # open: Q3
  Scenario: Rejecting a draft report is refused
    # AC1-C6 — rejecting a report in draft (or after changes‑requested) is refused.
    Given a draft report
    When an attempt is made to reject the report
    Then the rejection is refused

  @QAIA-US-004-007 @AC2 @P1 @boundary
  Scenario: Total just under €500 requires one manager approval
    # AC2-C1 — total just under €500 requires exactly 1 approval (manager).
    Given a report with total €499.99
    When the report is submitted for approval
    Then exactly one approval step by a manager is required

  @QAIA-US-004-008 @AC2 @P1 @boundary @low-confidence
    # open: Q1
  Scenario: Total exactly €500 requires two approvals
    # AC2-C2 — total exactly €500 requires manager and finance approvals.
    Given a report with total €500.00
    When the report is submitted for approval
    Then approvals by manager and finance are required

  @QAIA-US-004-009 @AC2 @P1 @boundary @low-confidence
    # open: Q1
  Scenario: Total exactly €5000 requires two approvals
    # AC2-C3 — total exactly €5000 requires manager and finance approvals.
    Given a report with total €5000.00
    When the report is submitted for approval
    Then approvals by manager and finance are required

  @QAIA-US-004-010 @AC2 @P1 @boundary
  Scenario: Total just above €5000 requires three approvals
    # AC2-C4 — total just above €5000 requires manager, finance, and director approvals.
    Given a report with total €5000.01
    When the report is submitted for approval
    Then approvals by manager, finance, and director are required

  @QAIA-US-004-011 @AC2 @P1 @negative @decision-table
  Scenario: Out‑of‑order approver is refused
    # AC2-C5 — approver acting out of order is refused.
    Given a report awaiting manager approval
    When a finance user attempts to approve before manager
    Then the approval attempt is refused

  @QAIA-US-004-012 @AC3 @P1 @negative @decision-table
  Scenario: Self‑approval is refused
    # AC3-C1 — an approver cannot approve their own report.
    Given a manager viewing their own report
    When the manager attempts to approve the report
    Then the approval is refused

  @QAIA-US-004-013 @AC3 @P1 @decision-table @low-confidence
    # open: Q2
  Scenario: Manager submission under €500 escalates to finance
    # AC3-C2 — manager submits <€500 report; finance step replaces manager.
    Given a manager submits a report with total €400.00
    When the approval chain is evaluated
    Then finance approval is required instead of manager

  @QAIA-US-004-014 @AC3 @P1 @decision-table @low-confidence
    # open: Q2
  Scenario: Manager submission over €5000 drops manager step
    # AC3-C3 — manager submits >€5000 report; manager step is dropped.
    Given a manager submits a report with total €6000.00
    When the approval chain is evaluated
    Then finance and director approvals are required, manager step omitted

  @QAIA-US-004-015 @AC3 @P1 @decision-table @low-confidence
    # open: Q8
  Scenario: Finance user submitting a report requiring finance approval escalates
    # AC3-C4 — finance user submits report needing finance sign‑off; escalated to director.
    Given a finance user submits a report that would require finance approval
    When the approval chain is evaluated
    Then director approval is required, finance step replaced

  @QAIA-US-004-016 @AC4 @P3 @negative @ep
  Scenario: Missing mandatory line fields cause submission refusal
    # AC4-C1 — line missing category, amount, or date is refused.
    Given a report line missing category, amount, or date
    When the report is submitted
    Then the submission is refused

  @QAIA-US-004-017 @AC4 @P2 @boundary @low-confidence
    # open: Q5
  Scenario: Line dated exactly 90 days ago is accepted
    # AC4-C2 — line dated exactly 90 days ago is accepted.
    Given a report line dated 90 days ago
    When the report is submitted
    Then the line is accepted

  @QAIA-US-004-018 @AC4 @P2 @negative @boundary
  Scenario: Line dated 91 days ago is blocked
    # AC4-C3 — line dated 91 days ago is blocked at submission.
    Given a report line dated 91 days ago
    When the report is submitted
    Then the submission is refused

  @QAIA-US-004-019 @AC5 @P2 @boundary
  Scenario: Line just under €25 threshold without receipt is accepted
    # AC5-C1 — line just under €25 threshold, no receipt, is accepted.
    Given a report line with EUR‑equivalent €24.99 and no receipt
    When the report is submitted
    Then the line is accepted

  @QAIA-US-004-020 @AC5 @P1 @negative @boundary
  Scenario: Line at exactly €25 threshold without receipt is refused
    # AC5-C2 — line at exactly €25 threshold, no receipt, is refused.
    Given a report line with EUR‑equivalent €25.00 and no receipt
    When the report is submitted
    Then the submission is refused

  @QAIA-US-004-021 @AC5 @P3 @ep
  Scenario: Line ≥ €25 with receipt is accepted
    # AC5-C3 — line ≥ €25 with receipt attached is accepted.
    Given a report line with EUR‑equivalent €30.00 and a receipt
    When the report is submitted
    Then the line is accepted

  @QAIA-US-004-022 @AC5 @P1 @negative @boundary @low-confidence
    # open: Q6
  Scenario: Non‑EUR line with face value <25 but EUR‑equivalent ≥25 is refused
    # AC5-C4 — non‑EUR line with face value <25 but EUR‑equivalent ≥25, no receipt, is refused.
    Given a non‑EUR report line with face value $20 and EUR‑equivalent €25.00, without receipt
    When the report is submitted
    Then the submission is refused

  @QAIA-US-004-023 @AC6 @P1 @ep
  Scenario: Correct currency conversion drives approval band
    # AC6-C1 — non‑EUR total is converted correctly and drives AC2 band.
    Given a non‑EUR report with total $6000 and a valid conversion rate
    When the report is submitted
    Then the converted total places the report in the appropriate approval band

  @QAIA-US-004-024 @AC6 @P1 @negative @error-guessing @low-confidence
    # open: Q4
  Scenario: Submission with unresolvable currency rate is refused
    # AC6-C2 — currency/date pair with no resolvable rate is refused.
    Given a report with currency/date pair lacking a conversion rate
    When the report is submitted
    Then the submission is refused

  @QAIA-US-004-025 @AC6 @P1 @error-guessing @low-confidence
    # open: Q4
  Scenario: Weekend/holiday rate fallback is accepted and flagged
    # AC6-C3 — expense dated in weekend/holiday uses last available rate and is flagged rateStale.
    Given a report dated on a holiday with no exact conversion rate, using a stale fallback rate
    When the report is submitted
    Then the report is accepted and flagged as rateStale

  @QAIA-US-004-026 @AC6 @P1 @decision-table @low-confidence
    # open: Q7
  Scenario: Stale rate near boundary still drives band and escalation
    # AC6-C4 — manager‑submitted foreign‑currency report with stale rate near boundary drives band and escalation.
    Given a manager submits a foreign‑currency report whose converted total is near a band boundary, using a stale rate
    When the approval chain is evaluated
    Then the appropriate band is selected and escalation rules are applied

  @QAIA-US-004-027 @AC7 @P2 @negative @state-transition
  Scenario: Editing a rejected report is refused
    # AC7-C1 — a rejected report cannot be edited.
    Given a rejected report
    When an attempt is made to edit the report
    Then the edit is refused

  @QAIA-US-004-028 @AC7 @P2 @negative @state-transition
  Scenario: Resubmitting a rejected report is refused
    # AC7-C2 — a rejected report cannot be re‑submitted.
    Given a rejected report
    When an attempt is made to resubmit the report
    Then the resubmission is refused

  @QAIA-US-004-029 @AC8 @P2 @negative @boundary
  Scenario: Rejecting without sufficient comment is refused
    # AC8-C1 — rejecting without a comment or with comment under 10 characters is refused.
    Given a rejected action attempted with a comment shorter than 10 characters
    When the reject operation is performed
    Then the rejection is refused

  @QAIA-US-004-030 @AC8 @P2 @negative @boundary
  Scenario: Requesting changes without sufficient comment is refused
    # AC8-C2 — requesting changes without a comment or with comment under 10 characters is refused.
    Given a changes‑requested action attempted with a comment shorter than 10 characters
    When the request is performed
    Then the request is refused

  @QAIA-US-004-031 @AC8 @P2 @boundary
  Scenario: Comment of exactly 10 characters is accepted
    # AC8-C3 — a comment of exactly 10 characters is accepted.
    Given a comment consisting of exactly ten characters
    When the comment is submitted with a reject or changes‑requested action
    Then the action is accepted

  @QAIA-US-004-032 @AC8 @P3 @ep
  Scenario: Approving a report does not require a comment
    # AC8-C4 — approving a report does not require a comment.
    Given an approval action on a report without any comment
    When the approval is performed
    Then the approval succeeds

  @QAIA-US-004-033 @AC8 @P1 @error-guessing
  Scenario: All transitions are recorded in the audit trail
    # AC8-C5 — every transition is recorded with who and when.
    Given any state transition on a report (create, submit, approve, reject, changes‑requested)
    When the transition occurs
    Then an audit‑trail entry recording the actor and timestamp is created

  @QAIA-US-004-034 @AC-auth @P2 @negative @error-guessing
  Scenario: Creating a report without authentication is refused
    # AC-auth-C1 — creating a report without authentication is refused (401).
    Given an unauthenticated user attempts to create a report
    When the creation request is processed
    Then the request is refused with status 401

  @QAIA-US-004-035 @AC-auth @P2 @negative @error-guessing
  Scenario: Deciding on a report without authentication is refused
    # AC-auth-C2 — deciding on a report without authentication is refused (401).
    Given an unauthenticated user attempts to approve a report
    When the decision request is processed
    Then the request is refused with status 401

  @QAIA-US-004-036 @AC-auth @P1 @negative @error-guessing
  Scenario: Editing another employee's draft is refused without disclosure
    # AC-auth-C3 — an employee editing another employee's draft is refused (404, not 403).
    Given an employee attempts to edit a draft report belonging to another employee
    When the edit request is processed
    Then the request is refused with status 404

  @QAIA-US-004-037 @AC-list @P3 @ep
  Scenario: Employee with no reports sees empty list
    # AC-list-C1 — an employee with no reports sees an explicit empty state on "My reports".
    Given an authenticated employee with no existing reports
    When the employee views the "My reports" list
    Then the list is shown as empty