Feature: Expense Report Submission and Approval Workflow (US-004)

  Background:
    Given the expense management system is initialized with current exchange rates

  @QAIA-US-004-000 @AC1 @P1 @smoke
  Scenario: End-to-end expense report submission and multi-level approval journey
    # Journey condition: AC1 / AC2
    Given an employee "Alice" has a draft expense report with lines totaling 600.00 EUR
    And "Bob" is assigned as manager and "Carol" as finance officer
    When "Alice" submits the expense report and managers "Bob" and "Carol" approve it in order
    Then the expense report status becomes "approved"

  @QAIA-US-004-001 @AC1 @P2 @state-transition
  Scenario: Submitting a valid draft expense report transitions status to submitted
    # Condition: AC1-C1
    Given an employee has a draft expense report with valid line items
    When the employee submits the expense report
    Then the expense report status becomes "submitted"

  @QAIA-US-004-002 @AC1 @P2 @state-transition
  Scenario: Requesting changes returns a submitted report to editable draft status
    # Condition: AC1-C2
    Given an expense report in "submitted" status
    When an approver requests changes on the expense report
    Then the expense report status transitions to "draft"
    And the expense report becomes editable again

  @QAIA-US-004-003 @AC1 @P2 @state-transition
  Scenario: Editing and resubmitting a report returned for changes succeeds
    # Condition: AC1-C3
    Given an expense report in "draft" status previously returned via "changes-requested"
    And the employee modifies the report line items
    When the employee submits the updated expense report
    Then the expense report status transitions to "submitted"

  @QAIA-US-004-004 @AC1 @P2 @negative @state-transition
  Scenario: Submitting a report that is not in draft status is refused
    # Condition: AC1-C4
    Given an expense report in "submitted" status
    When the employee attempts to submit the expense report
    Then the submission action is refused
    And the expense report status remains "submitted"

  @QAIA-US-004-005 @AC1 @P2 @negative @state-transition
  Scenario: Editing a report that is not in draft status is refused
    # Condition: AC1-C5
    Given an expense report in "submitted" status
    When the employee attempts to modify line items on the expense report
    Then the edit action is refused
    And the expense report contents remain unchanged

  @QAIA-US-004-006 @AC1 @P1 @negative @state-transition @low-confidence
  Scenario: Rejecting a draft expense report is refused
    # Condition: AC1-C6
    # open: Q3
    Given an expense report in "draft" status
    When an approver attempts to reject the expense report
    Then the rejection action is refused
    And the expense report status remains "draft"

  @QAIA-US-004-007 @AC2 @P1 @boundary
  Scenario: Expense report total just under 500 EUR requires 1 manager approval
    # Condition: AC2-C1
    Given an employee submits an expense report totaling 499.99 EUR
    When the system evaluates the approval routing rules
    Then the approval chain requires exactly 1 approval from "manager"

  @QAIA-US-004-008 @AC2 @P1 @boundary @low-confidence
  Scenario: Expense report total of exactly 500 EUR requires 2 approvals
    # Condition: AC2-C2
    # open: Q1
    Given an employee submits an expense report totaling 500.00 EUR
    When the system evaluates the approval routing rules
    Then the approval chain requires exactly 2 approvals from "manager" and "finance"

  @QAIA-US-004-009 @AC2 @P1 @boundary @low-confidence
  Scenario: Expense report total of exactly 5000 EUR requires 2 approvals
    # Condition: AC2-C3
    # open: Q1
    Given an employee submits an expense report totaling 5000.00 EUR
    When the system evaluates the approval routing rules
    Then the approval chain requires exactly 2 approvals from "manager" and "finance"

  @QAIA-US-004-010 @AC2 @P1 @boundary
  Scenario: Expense report total just over 5000 EUR requires 3 approvals
    # Condition: AC2-C4
    Given an employee submits an expense report totaling 5000.01 EUR
    When the system evaluates the approval routing rules
    Then the approval chain requires 3 approvals from "manager", "finance", and "director"

  @QAIA-US-004-011 @AC2 @P1 @negative @decision-table
  Scenario: Out of order approval attempt in multi-level chain is refused
    # Condition: AC2-C5
    Given a submitted expense report requiring sequential approval from manager then finance
    And the manager step has not been completed
    When a finance user attempts to approve the expense report
    Then the approval action is refused with an out-of-order error

  @QAIA-US-004-012 @AC3 @P1 @negative @decision-table
  Scenario: Self approval of expense report is strictly refused
    # Condition: AC3-C1
    Given an expense report created and submitted by user "Bob"
    When "Bob" in his approver role attempts to approve the expense report
    Then the approval action is refused with a self-approval prohibition error

  @QAIA-US-004-013 @AC3 @P1 @decision-table @low-confidence
  Scenario: Manager self submission below 500 EUR escalates manager step to finance
    # Condition: AC3-C2
    # open: Q2
    Given a manager submits an expense report totaling 300.00 EUR
    When the system generates the approval chain
    Then the manager approval step is replaced by "finance"

  @QAIA-US-004-014 @AC3 @P1 @decision-table @low-confidence
  Scenario: Manager self submission above 5000 EUR drops manager step and retains finance and director
    # Condition: AC3-C3
    # open: Q2
    Given a manager submits an expense report totaling 6000.00 EUR
    When the system generates the approval chain
    Then the manager approval step is omitted
    And the approval chain requires "finance" followed by "director"

  @QAIA-US-004-015 @AC3 @P1 @decision-table @low-confidence
  Scenario: Finance user self submission replaces finance step with director
    # Condition: AC3-C4
    # open: Q8
    Given a finance officer submits an expense report requiring finance sign-off
    When the system generates the approval chain
    Then the finance approval step is replaced by "director"

  @QAIA-US-004-016 @AC4 @P3 @negative @ep
  Scenario: Expense line item missing required fields is blocked at submission
    # Condition: AC4-C1
    Given a draft expense report with a line item missing field "category"
    When the employee attempts to submit the expense report
    Then the submission is refused with an incomplete line validation error

  @QAIA-US-004-017 @AC4 @P2 @boundary @low-confidence
  Scenario: Expense line dated exactly 90 days ago is accepted
    # Condition: AC4-C2
    # open: Q5
    Given current server date is "2026-07-25"
    And a draft expense report containing a line item dated "2026-04-26"
    When the employee submits the expense report
    Then the submission is accepted successfully

  @QAIA-US-004-018 @AC4 @P2 @negative @boundary
  Scenario: Expense line dated 91 days ago is blocked at submission
    # Condition: AC4-C3
    Given current server date is "2026-07-25"
    And a draft expense report containing a line item dated "2026-04-25"
    When the employee attempts to submit the expense report
    Then the submission is blocked with an age threshold exceeding 90 days error

  @QAIA-US-004-019 @AC5 @P2 @boundary
  Scenario: Expense line total just under 25 EUR without receipt is accepted
    # Condition: AC5-C1
    Given a draft expense report containing a line item of 24.99 EUR without a receipt
    When the employee submits the expense report
    Then the submission is accepted successfully

  @QAIA-US-004-020 @AC5 @P1 @negative @boundary
  Scenario: Expense line total at exactly 25 EUR without receipt is refused
    # Condition: AC5-C2
    Given a draft expense report containing a line item of 25.00 EUR without a receipt
    When the employee attempts to submit the expense report
    Then the submission is refused with a missing receipt mandatory error

  @QAIA-US-004-021 @AC5 @P3 @ep
  Scenario: Expense line equal to or exceeding 25 EUR with receipt is accepted
    # Condition: AC5-C3
    Given a draft expense report containing a line item of 50.00 EUR with an attached receipt
    When the employee submits the expense report
    Then the submission is accepted successfully

  @QAIA-US-004-022 @AC5 @P1 @negative @boundary @low-confidence
  Scenario: Non EUR line with face value under 25 but EUR equivalent at or above 25 without receipt is refused
    # Condition: AC5-C4
    # open: Q6
    Given a foreign currency line item of 20.00 USD converting to 25.50 EUR without a receipt
    When the employee attempts to submit the expense report
    Then the submission is refused based on the EUR-equivalent receipt threshold

  @QAIA-US-004-023 @AC6 @P1 @ep
  Scenario: Foreign currency report converted total correctly determines approval threshold band
    # Condition: AC6-C1
    Given a foreign currency expense report totaling 600.00 USD converting to 550.00 EUR
    When the employee submits the expense report
    Then the approval chain routing is evaluated using 550.00 EUR requiring manager and finance sign-off

  @QAIA-US-004-024 @AC6 @P1 @negative @error-guessing @low-confidence
  Scenario: Foreign currency with unresolvable exchange rate is refused at submission
    # Condition: AC6-C2
    # open: Q4
    Given an expense line item in currency "XYZ" with no available exchange rate
    When the employee attempts to submit the expense report
    Then the submission is refused with an unresolvable exchange rate error message

  @QAIA-US-004-025 @AC6 @P1 @error-guessing @low-confidence
  Scenario: Foreign currency on non trading day uses last available rate and flags report as rateStale
    # Condition: AC6-C3
    # open: Q4
    Given a foreign currency expense line dated on a weekend with no exact date rate
    When the employee submits the expense report
    Then the conversion uses the last available prior exchange rate
    And the expense report is flagged as "rateStale"

  @QAIA-US-004-026 @AC6 @P1 @decision-table @low-confidence
  Scenario: Stale rate converted foreign report by manager near boundary drives band and self approval rules
    # Condition: AC6-C4
    # open: Q7
    Given a manager submits a foreign expense report converted via a stale fallback rate to 500.50 EUR
    When the system generates the approval routing
    Then approval rules apply based on the converted 500.50 EUR total including manager self-approval escalation
    And the report retains the "rateStale" flag

  @QAIA-US-004-027 @AC7 @P2 @negative @state-transition
  Scenario: Modifying a rejected expense report is refused
    # Condition: AC7-C1
    Given an expense report in "rejected" status
    When the employee attempts to edit line items on the expense report
    Then the edit action is refused

  @QAIA-US-004-028 @AC7 @P2 @negative @state-transition
  Scenario: Resubmitting a rejected expense report is refused
    # Condition: AC7-C2
    Given an expense report in "rejected" status
    When the employee attempts to submit the expense report
    Then the submission action is refused

  @QAIA-US-004-029 @AC8 @P2 @negative @boundary
  Scenario: Rejecting an expense report with comment under 10 characters is refused
    # Condition: AC8-C1
    Given a submitted expense report awaiting approval
    When an approver attempts to reject the expense report with a 5-character comment "Short"
    Then the rejection action is refused with a comment length error

  @QAIA-US-004-030 @AC8 @P2 @negative @boundary
  Scenario: Requesting changes on expense report without comment is refused
    # Condition: AC8-C2
    Given a submitted expense report awaiting approval
    When an approver attempts to request changes without providing a comment
    Then the change request action is refused with a missing comment error

  @QAIA-US-004-031 @AC8 @P2 @boundary
  Scenario: Decision comment of exactly 10 characters is accepted
    # Condition: AC8-C3
    Given a submitted expense report awaiting approval
    When an approver rejects the expense report with comment "1234567890"
    Then the rejection action succeeds

  @QAIA-US-004-032 @AC8 @P3 @ep
  Scenario: Approving an expense report does not require a comment
    # Condition: AC8-C4
    Given a submitted expense report awaiting approval
    When an approver approves the expense report without a comment
    Then the approval action succeeds

  @QAIA-US-004-033 @AC8 @P1 @error-guessing
  Scenario: Every state transition logs actor identity and timestamp in audit trail
    # Condition: AC8-C5
    Given an expense report progressing through creation, submission, approval, and completion
    When each lifecycle transition occurs
    Then an audit log entry is recorded containing the actor user ID and timestamp

  @QAIA-US-004-034 @AC-auth @P2 @negative @error-guessing
  Scenario: Creating expense report without authentication is refused with HTTP 401
    # Condition: AC-auth-C1
    Given an unauthenticated client session
    When the client attempts to create an expense report
    Then the request is refused with HTTP status 401 Unauthorized

  @QAIA-US-004-035 @AC-auth @P2 @negative @error-guessing
  Scenario: Deciding on expense report without authentication is refused with HTTP 401
    # Condition: AC-auth-C2
    Given an unauthenticated client session
    When the client attempts to approve an expense report
    Then the request is refused with HTTP status 401 Unauthorized

  @QAIA-US-004-036 @AC-auth @P1 @negative @error-guessing
  Scenario: Editing another employee draft report returns HTTP 404 to prevent IDOR disclosure
    # Condition: AC-auth-C3
    Given an authenticated employee "Alice"
    And a draft expense report "r2" belonging to employee "Bob"
    When "Alice" attempts to modify expense report "r2"
    Then the request is refused with HTTP status 404 Not Found without disclosing resource existence

  @QAIA-US-004-037 @AC-list @P3 @ep
  Scenario: Employee with no expense reports sees explicit empty state
    # Condition: AC-list-C1
    Given an authenticated employee who has submitted zero expense reports
    When the employee views the "My reports" list page
    Then an explicit empty state component is displayed