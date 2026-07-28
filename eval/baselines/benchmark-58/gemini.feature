Feature: Expense report approval workflow
  As an employee
  I want to submit an expense report and have it approved through the right chain
  So that I get reimbursed correctly and the company keeps an auditable trail

  Rule: State transitions and lifecycle (AC1)

    @US-004-AC1-01 @AC1 @state-transition @P1
    Scenario: Happy path lifecycle from draft to approved
      Given an employee has an expense report in "draft" state
      When the employee submits the expense report
      Then the report status changes to "submitted"
      When the required approver approves the report
      Then the report status changes to "approved"

    @US-004-AC1-02 @AC1 @state-transition @P1
    Scenario: Changes requested flow allows editing and re-submission
      Given an expense report is in "submitted" state
      When the approver requests changes with a valid comment "Please upload clearer itemized receipt"
      Then the report status changes to "changes-requested"
      When the employee updates the expense report
      Then the report returns to "draft" state
      When the employee submits the report again
      Then the report status changes to "submitted"

    @US-004-AC1-03 @AC1 @state-transition @negative @P2
    Scenario: Invalid transition directly from draft to approved
      Given an employee has an expense report in "draft" state
      When an administrative action attempts to set status directly to "approved"
      Then the transition is rejected as invalid

    # AMBIGUITY: AC1 does not explicitly state whether an expense report in 'submitted' status can be edited before approval.
    @US-004-AC1-04 @AC1 @state-transition @negative @low-confidence @P2
    Scenario: Report cannot be edited while in submitted state
      Given an expense report is in "submitted" state
      When the employee attempts to edit line items
      Then the edit operation is refused with error "Cannot edit a report in submitted state"


  Rule: Approval hierarchy thresholds (AC2)

    @US-004-AC2-01 @AC2 @boundary @P1
    Scenario: Report total of 499.99 EUR requires manager approval only
      Given an expense report has a total value of 499.99 EUR
      When the employee submits the report
      Then the required approval sequence is ["Direct Manager"]

    @US-004-AC2-02 @AC2 @boundary @P1
    Scenario: Report total of 500.00 EUR requires manager then finance approval
      Given an expense report has a total value of 500.00 EUR
      When the employee submits the report
      Then the required approval sequence is ["Direct Manager", "Finance"]

    @US-004-AC2-03 @AC2 @boundary @P1
    Scenario: Report total of 5000.00 EUR requires manager then finance approval
      Given an expense report has a total value of 5000.00 EUR
      When the employee submits the report
      Then the required approval sequence is ["Direct Manager", "Finance"]

    @US-004-AC2-04 @AC2 @boundary @P1
    Scenario: Report total of 5000.01 EUR requires manager, finance, then director approval
      Given an expense report has a total value of 5000.01 EUR
      When the employee submits the report
      Then the required approval sequence is ["Direct Manager", "Finance", "Director"]


  Rule: Self-approval restriction and submitter hierarchy skipping (AC3)

    @US-004-AC3-01 @AC3 @decision-table @P1
    Scenario: Manager submitter report skips direct manager step to next level
      Given the submitter is a "Manager"
      And the expense report total is 1200.00 EUR
      When the report is submitted
      Then the initial approver assigned is "Finance"
      And the "Direct Manager" approval step is bypassed

    @US-004-AC3-02 @AC3 @decision-table @P1
    Scenario: Approver cannot approve their own expense report
      Given a manager submits an expense report
      When the manager attempts to approve their own report
      Then the action is blocked with error "Self-approval is not permitted"

    # AMBIGUITY: AC3 does not specify who approves a report above 5000 EUR submitted by a Director.
    @US-004-AC3-03 @AC3 @decision-table @low-confidence @P2
    Scenario: Director submitter report above 5000 EUR skips director level to executive board
      Given the submitter is a "Director"
      And the expense report total is 6000.00 EUR
      When the report is submitted
      Then the required approval sequence is ["Finance", "Executive Board"]


  Rule: Line item validation and 90-day window (AC4)

    @US-004-AC4-01 @AC4 @boundary @P1
    Scenario: Line items dated exactly 90 days ago are accepted
      Given an expense report with a valid category and amount
      And a line item dated 90 days ago from today
      When the employee submits the report
      Then the submission is accepted

    @US-004-AC4-02 @AC4 @boundary @negative @P1
    Scenario: Line items dated 91 days ago are blocked at submission
      Given an expense report with a valid category and amount
      And a line item dated 91 days ago from today
      When the employee attempts to submit the report
      Then the submission is blocked
      And an explanatory message "Line item date exceeds maximum allowed age of 90 days" is displayed

    # AMBIGUITY: AC4 mentions 'within the last 90 days' but does not explicitly mention future-dated expense lines.
    @US-004-AC4-03 @AC4 @error-guessing @negative @low-confidence @P2
    Scenario: Line items with future dates are blocked at submission
      Given an expense report with a valid category and amount
      And a line item dated 1 day in the future
      When the employee attempts to submit the report
      Then the submission is blocked
      And an explanatory message "Expense date cannot be in the future" is displayed


  Rule: Receipt requirements (AC5)

    @US-004-AC5-01 @AC5 @boundary @P1
    Scenario: Line item of 24.99 EUR without receipt is accepted
      Given an expense report line item of 24.99 EUR with no receipt attached
      When the employee submits the report
      Then the submission succeeds

    @US-004-AC5-02 @AC5 @boundary @negative @P1
    Scenario: Line item of 25.00 EUR without receipt is refused
      Given an expense report line item of 25.00 EUR with no receipt attached
      When the employee attempts to submit the report
      Then the submission is refused
      And an error message "Receipt mandatory for line items of 25.00 EUR or greater" is displayed

    @US-004-AC5-03 @AC5 @boundary @P2
    Scenario: Line item of 25.00 EUR with attached receipt is accepted
      Given an expense report line item of 25.00 EUR with a valid receipt attached
      When the employee submits the report
      Then the submission succeeds


  Rule: Currency conversion and threshold evaluation (AC6)

    @US-004-AC6-01 @AC6 @use-case @P1
    Scenario: Non-EUR currency is converted at expense date rate to evaluate approval thresholds
      Given an expense line item of 550.00 USD dated "2026-03-01"
      And the USD to EUR exchange rate on "2026-03-01" was 0.92
      When the report is submitted
      Then the converted total is calculated as 506.00 EUR
      And the report requires approval sequence ["Direct Manager", "Finance"]


  Rule: Terminal state for rejected reports (AC7)

    @US-004-AC7-01 @AC7 @state-transition @negative @P1
    Scenario: Rejected report cannot be edited
      Given an expense report is in "rejected" state
      When the employee attempts to modify any line item
      Then the action is refused with error "Rejected reports are final and cannot be edited"

    @US-004-AC7-02 @AC7 @state-transition @negative @P1
    Scenario: Rejected report cannot be re-submitted
      Given an expense report is in "rejected" state
      When the employee attempts to resubmit the report
      Then the action is refused with error "Rejected reports cannot be re-submitted; please create a new report"


  Rule: Audit trail and mandatory comments (AC8)

    @US-004-AC8-01 @AC8 @use-case @P1
    Scenario: State transition records user identity, timestamp, and action
      Given a user "mgr_smith" performs an approval transition
      When the status changes from "submitted" to "approved"
      Then an audit log entry is created recording:
        | Field     | Value          |
        | actor     | mgr_smith      |
        | timestamp | current_time   |
        | fromState | submitted      |
        | toState   | approved       |

    @US-004-AC8-02 @AC8 @boundary @P2
    Scenario: Rejection succeeds with comment of exactly 10 characters
      Given an expense report in "submitted" state
      When the approver rejects the report with comment "1234567890"
      Then the report status changes to "rejected"
      And the audit log records the comment "1234567890"

    @US-004-AC8-03 @AC8 @boundary @negative @P1
    Scenario: Rejection fails with comment under 10 characters
      Given an expense report in "submitted" state
      When the approver attempts to reject the report with comment "Too short"
      Then the rejection action is blocked
      And an error message "Comment must be at least 10 characters long" is displayed

    @US-004-AC8-04 @AC8 @boundary @negative @P1
    Scenario: Changes-requested fails with comment under 10 characters
      Given an expense report in "submitted" state
      When the approver attempts to request changes with comment "Fix this!"
      Then the action is blocked
      And an error message "Comment must be at least 10 characters long" is displayed

    @US-004-AC8-05 @AC8 @state-transition @negative @P2
    Scenario: Rejection fails when comment is omitted
      Given an expense report in "submitted" state
      When the approver attempts to reject the report without providing a comment
      Then the rejection action is blocked
      And an error message "Comment is required for rejection" is displayed
