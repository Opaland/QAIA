# Feature file for US-004: Expense Report Submission and Approval Workflow

Feature: Expense Report Submission and Approval Workflow
  As an employee, manager, finance team member, or director
  I want to submit, review, approve, or reject expense reports with audit logging and multi-level rules
  So that expense claims are properly authorized, compliant with policy, and fully auditable

  Background:
    Given the expense reporting system is operational and reference exchange rates are available

  # US-004 -> AC1 -> AC1-C1
  @QAIA-US-004-001 @AC1 @P2 @ep
  Scenario: Successfully submit a draft expense report with valid data
    Given an employee has a draft expense report containing valid expense lines
    When the employee submits the expense report
    Then the expense report status becomes "submitted"

  # US-004 -> AC1 -> AC1-C2
  @QAIA-US-004-002 @AC1 @P2 @state-transition
  Scenario: Transition a submitted report back to draft when changes are requested
    Given an expense report in "submitted" status
    When an authorized approver requests changes with a valid comment
    Then the expense report status reverts to "draft" and is editable by the submitter

  # US-004 -> AC1 -> AC1-C3
  @QAIA-US-004-003 @AC1 @P2 @state-transition
  Scenario: Edit and re-submit a report previously returned for changes
    Given an expense report in "draft" status resulting from a changes-requested decision
    When the employee updates the line items and re-submits the report
    Then the expense report status transitions back to "submitted"

  # US-004 -> AC1 -> AC1-C4
  @QAIA-US-004-004 @AC1 @P2 @negative @state-transition
  Scenario: Refuse submission of a report that is not in draft status
    Given an expense report currently in "submitted" status
    When the employee attempts to submit the expense report again
    Then the system refuses the action with an error indicating the report is not in draft status

  # US-004 -> AC1 -> AC1-C5
  @QAIA-US-004-005 @AC1 @P2 @negative @state-transition
  Scenario: Refuse editing of a report that is not in draft status
    Given an expense report currently in "submitted" status
    When the employee attempts to update a line item on the report
    Then the system refuses the edit action with a status restriction error

  # US-004 -> AC1 -> AC1-C6
  # open: Q3
  @QAIA-US-004-006 @AC1 @P1 @negative @low-confidence @state-transition
  Scenario: Refuse rejection of an expense report currently in draft status
    Given an expense report currently in "draft" status
    When an approver attempts to reject the expense report
    Then the system refuses the rejection with an invalid state transition error

  # US-004 -> AC2 -> AC2-C1
  @QAIA-US-004-007 @AC2 @P1 @boundary
  Scenario: Require single manager approval for report total under 500 EUR
    Given an employee submits a report with total amount 499.99 EUR
    When the submission is processed for approval routing
    Then the approval chain is assigned exactly one step requiring "manager" approval

  # US-004 -> AC2 -> AC2-C2
  # open: Q1
  @QAIA-US-004-008 @AC2 @P1 @low-confidence @boundary
  Scenario: Require two approvals for report total exactly 500 EUR
    Given an employee submits a report with total amount 500.00 EUR
    When the submission is processed for approval routing
    Then the approval chain is assigned two sequential steps requiring "manager" then "finance" approval

  # US-004 -> AC2 -> AC2-C3
  # open: Q1
  @QAIA-US-004-009 @AC2 @P1 @low-confidence @boundary
  Scenario: Require two approvals for report total exactly 5000 EUR
    Given an employee submits a report with total amount 5000.00 EUR
    When the submission is processed for approval routing
    Then the approval chain is assigned two sequential steps requiring "manager" then "finance" approval

  # US-004 -> AC2 -> AC2-C4
  @QAIA-US-004-010 @AC2 @P1 @boundary
  Scenario: Require three approvals for report total exceeding 5000 EUR
    Given an employee submits a report with total amount 5000.01 EUR
    When the submission is processed for approval routing
    Then the approval chain is assigned three sequential steps requiring "manager", "finance", then "director" approval

  # US-004 -> AC2 -> AC2-C5
  @QAIA-US-004-011 @AC2 @P1 @negative @decision-table
  Scenario: Refuse approval out of designated step order
    Given an expense report in "submitted" status awaiting initial manager approval
    When a user with "finance" role attempts to approve the report before the manager step
    Then the system refuses the approval with an out-of-order sequence error

  # US-004 -> AC3 -> AC3-C1
  @QAIA-US-004-012 @AC3 @P1 @negative @decision-table
  Scenario: Refuse self-approval of an expense report
    Given a manager has submitted their own expense report requiring approval
    When the manager attempts to approve their own submitted report
    Then the system refuses the decision with a self-approval denial error

  # US-004 -> AC3 -> AC3-C2
  # open: Q2
  @QAIA-US-004-013 @AC3 @P1 @low-confidence @decision-table
  Scenario: Escalate manager self-submitted report under 500 EUR to finance
    Given a user with "manager" role submits an expense report totaling 300.00 EUR
    When the approval chain is constructed
    Then the first approval step is assigned to "finance" replacing the submitter's manager step

  # US-004 -> AC3 -> AC3-C3
  # open: Q2
  @QAIA-US-004-014 @AC3 @P1 @low-confidence @decision-table
  Scenario: Skip self-approval for manager report over 5000 EUR leaving finance and director
    Given a user with "manager" role submits an expense report totaling 6000.00 EUR
    When the approval chain is constructed
    Then the manager step is omitted and the remaining approval chain consists of "finance" followed by "director"

  # US-004 -> AC3 -> AC3-C4
  # open: Q8
  @QAIA-US-004-015 @AC3 @P1 @low-confidence @decision-table
  Scenario: Escalate finance user self-submitted report requiring finance sign-off to director
    Given a user with "finance" role submits an expense report totaling 1200.00 EUR
    When the approval chain is constructed
    Then the finance approval step is escalated to "director" role

  # US-004 -> AC4 -> AC4-C1
  @QAIA-US-004-016 @AC4 @P3 @negative @ep
  Scenario Outline: Refuse submission when an expense line is missing required fields
    Given a draft expense report with an expense line missing "<missing_field>"
    When the employee submits the expense report
    Then the system refuses submission with a field completeness validation error

    Examples:
      | missing_field |
      | category      |
      | amount        |
      | date          |

  # US-004 -> AC4 -> AC4-C2
  # open: Q5
  @QAIA-US-004-017 @AC4 @P2 @low-confidence @boundary
  Scenario: Accept expense line dated exactly 90 days ago
    Given an expense line dated exactly 90 days prior to the server evaluation date
    When the employee submits the expense report
    Then the expense line is accepted as valid regarding age limits

  # US-004 -> AC4 -> AC4-C3
  @QAIA-US-004-018 @AC4 @P2 @negative @boundary
  Scenario: Refuse submission of an expense line older than 90 days
    Given an expense line dated 91 days prior to the server evaluation date
    When the employee submits the expense report
    Then the system refuses submission with an line-age limit error

  # US-004 -> AC5 -> AC5-C1
  @QAIA-US-004-019 @AC5 @P2 @boundary
  Scenario: Accept line item under 25 EUR without receipt
    Given an expense line with an amount of 24.99 EUR and no attached receipt
    When the employee submits the expense report
    Then the expense line is accepted without requiring a receipt

  # US-004 -> AC5 -> AC5-C2
  @QAIA-US-004-020 @AC5 @P1 @negative @boundary
  Scenario: Refuse line item at exactly 25 EUR without receipt
    Given an expense line with an amount of 25.00 EUR and no attached receipt
    When the employee submits the expense report
    Then the system refuses submission with a receipt mandatory error

  # US-004 -> AC5 -> AC5-C3
  @QAIA-US-004-021 @AC5 @P3 @ep
  Scenario: Accept line item at or above 25 EUR when receipt is attached
    Given an expense line with an amount of 100.00 EUR and a valid attached receipt
    When the employee submits the expense report
    Then the expense line is accepted with its receipt attachment

  # US-004 -> AC5 -> AC5-C4
  # open: Q6
  @QAIA-US-004-022 @AC5 @P1 @negative @low-confidence @boundary
  Scenario: Refuse non-EUR line whose converted EUR total equals 25 EUR without receipt
    Given a non-EUR expense line with face value 20.00 USD converting to 25.00 EUR and no receipt attached
    When the employee submits the expense report
    Then the system refuses submission because the converted EUR equivalent reaches the 25 EUR receipt threshold

  # US-004 -> AC6 -> AC6-C1
  @QAIA-US-004-023 @AC6 @P1 @ep
  Scenario: Convert foreign currency line items and derive approval band from converted total
    Given an expense report with line items in USD totaling 600.00 USD converted at rate 0.90 EUR/USD to 540.00 EUR
    When the employee submits the expense report
    Then the approval chain is routed according to the 540.00 EUR total requiring manager and finance approval

  # US-004 -> AC6 -> AC6-C2
  # open: Q4
  @QAIA-US-004-024 @AC6 @P1 @negative @low-confidence @error-guessing
  Scenario: Refuse submission when currency rate cannot be resolved
    Given an expense report containing a non-EUR expense line for which no conversion rate exists
    When the employee submits the expense report
    Then the system refuses submission with an unresolvable currency conversion rate error

  # US-004 -> AC6 -> AC6-C3
  # open: Q4
  @QAIA-US-004-025 @AC6 @P1 @low-confidence @error-guessing
  Scenario: Fallback to last available rate for weekend or holiday date and flag report as stale
    Given an expense line dated on a Sunday where exact-date rate is absent but a Friday fallback rate of 0.85 EUR/USD exists
    When the employee submits the expense report
    Then the report is converted using the fallback rate and flagged with "rateStale" indicator

  # US-004 -> AC6 -> AC6-C4
  # open: Q7
  @QAIA-US-004-026 @AC6 @P1 @low-confidence @decision-table
  Scenario: Apply stale rate conversion boundary to determine both routing band and self-approval rules
    Given a manager submits a foreign currency report converted via a stale fallback rate resulting in 500.00 EUR
    When the report is processed for approval routing
    Then the report uses 500.00 EUR for band determination and routes to finance replacing manager self-approval

  # US-004 -> AC7 -> AC7-C1
  @QAIA-US-004-027 @AC7 @P2 @negative @state-transition
  Scenario: Refuse editing of a rejected expense report
    Given an expense report currently in "rejected" status
    When an employee attempts to edit line items on the report
    Then the system refuses the edit action on terminal state error

  # US-004 -> AC7 -> AC7-C2
  @QAIA-US-004-028 @AC7 @P2 @negative @state-transition
  Scenario: Refuse re-submission of a rejected expense report
    Given an expense report currently in "rejected" status
    When an employee attempts to submit the report
    Then the system refuses submission indicating the report is permanently rejected

  # US-004 -> AC8 -> AC8-C1
  @QAIA-US-004-029 @AC8 @P2 @negative @boundary
  Scenario Outline: Refuse report rejection when comment is missing or shorter than 10 characters
    Given an expense report in "submitted" status
    When an approver attempts to reject the report with comment "<comment_text>"
    Then the system refuses the rejection with a minimum comment length validation error

    Examples:
      | comment_text |
      |              |
      | Too short    |

  # US-004 -> AC8 -> AC8-C2
  @QAIA-US-004-030 @AC8 @P2 @negative @boundary
  Scenario Outline: Refuse request for changes when comment is missing or shorter than 10 characters
    Given an expense report in "submitted" status
    When an approver attempts to request changes with comment "<comment_text>"
    Then the system refuses the request with a minimum comment length validation error

    Examples:
      | comment_text |
      |              |
      | Fix this     |

  # US-004 -> AC8 -> AC8-C3
  @QAIA-US-004-031 @AC8 @P2 @boundary
  Scenario: Accept rejection comment of exactly 10 characters
    Given an expense report in "submitted" status
    When an approver rejects the report with comment "1234567890"
    Then the rejection is recorded successfully with the 10-character comment

  # US-004 -> AC8 -> AC8-C4
  @QAIA-US-004-032 @AC8 @P3 @ep
  Scenario: Accept report approval without requiring a comment
    Given an expense report in "submitted" status awaiting approval
    When an approver approves the report without providing any comment
    Then the report approval succeeds and transitions to the next step

  # US-004 -> AC8 -> AC8-C5
  @QAIA-US-004-033 @AC8 @P1 @error-guessing
  Scenario Outline: Audit trail records actor identity and timestamp for every state transition
    Given an expense report in "<initial_state>" status
    When an actor performs the "<action>" action
    Then an audit log entry is appended recording the action, actor user ID, and timestamp

    Examples:
      | initial_state | action           |
      | draft         | submit           |
      | submitted     | approve          |
      | submitted     | reject           |
      | submitted     | request-changes  |

  # US-004 -> AC-auth -> AC-auth-C1
  @QAIA-US-004-034 @AC-auth @P2 @negative @error-guessing
  Scenario: Refuse expense report creation without authentication
    Given an unauthenticated client request
    When the client attempts to create an expense report
    Then the system rejects the request with HTTP 401 Unauthorized status

  # US-004 -> AC-auth -> AC-auth-C2
  @QAIA-US-004-035 @AC-auth @P2 @negative @error-guessing
  Scenario: Refuse approval decision without authentication
    Given an unauthenticated client request
    When the client attempts to submit an approval decision on report "r123"
    Then the system rejects the decision request with HTTP 401 Unauthorized status

  # US-004 -> AC-auth -> AC-auth-C3
  @QAIA-US-004-036 @AC-auth @P1 @negative @error-guessing
  Scenario: Hide draft existence when an employee attempts IDOR edit on another user's draft
    Given an employee authenticated as "user_A"
    When user_A attempts to edit a draft report belonging to "user_B"
    Then the system refuses access with HTTP 404 Not Found status without revealing report existence

  # US-004 -> AC-list -> AC-list-C1
  @QAIA-US-004-037 @AC-list @P3 @ep
  Scenario: Display empty state view for employee with no expense reports
    Given an employee who has never created an expense report
    When the employee opens their "My Reports" list view
    Then an explicit empty state message is displayed indicating no reports exist

  # US-004 -> Journey -> Full end-to-end expense report lifecycle
  @QAIA-US-004-038 @journey @P1 @smoke
  Scenario: Full end-to-end expense report submission, request changes, resubmit, multi-level approval journey
    Given an employee creates a multi-line foreign currency report exceeding 5000 EUR
    When the employee submits the report, the manager requests changes, the employee resubmits, and sequential approvals by manager, finance, and director are recorded with full comments
    Then the expense report reaches "approved" status with a complete chronological audit log entries for all transitions