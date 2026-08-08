# US-004: Expense Report Submission and Multi-Level Approval Workflow

Feature: Expense report management and multi-level approval workflow
  As an employee submitting expenses or a manager/approver reviewing reports
  I want a clear submission, conversion, threshold, and approval process
  So that business expenses are accurately validated, audited, and controlled

  Background:
    Given the expense management system is configured with standard currency conversion rates
    And default approval chain rules are active for all departments

  # US-004 -> AC1 -> AC1-C1
  @QAIA-US-004-001 @AC1 @P2 @ep
  Scenario: Successfully submit a valid draft expense report
    Given an employee has an expense report in "draft" status with valid lines
    When the employee submits the expense report
    Then the expense report status transitions to "submitted"
    And the report enters the approval workflow

  # US-004 -> AC1 -> AC1-C2
  # open: Q3
  @QAIA-US-004-002 @AC1 @P2 @state-transition
  Scenario: Request changes on a submitted report moves it back to draft and allows editing
    Given an approver has requested changes on a "submitted" expense report
    When the expense report status changes to "changes-requested"
    Then the expense report status transitions to "draft"
    And the employee is permitted to edit the expense report lines

  # US-004 -> AC1 -> AC1-C3
  @QAIA-US-004-003 @AC1 @P2 @state-transition
  Scenario: Re-submit an expense report after addressing requested changes
    Given an employee has edited an expense report previously marked as "changes-requested"
    When the employee re-submits the updated expense report
    Then the expense report status transitions to "submitted"
    And the approval chain is re-initialized

  # US-004 -> AC1 -> AC1-C4
  @QAIA-US-004-004 @AC1 @P2 @negative @state-transition
  Scenario: Refuse submission of an expense report that is not in draft status
    Given an expense report is currently in "submitted" status
    When the employee attempts to submit the expense report again
    Then the submission action is refused with an error indicating the report is not in draft status

  # US-004 -> AC1 -> AC1-C5
  @QAIA-US-004-005 @AC1 @P2 @negative @state-transition
  Scenario: Refuse editing an expense report that is not in draft status
    Given an expense report is currently in "submitted" status
    When the employee attempts to modify a line on the expense report
    Then the edit operation is refused with an error indicating the report is locked

  # US-004 -> AC1 -> AC1-C6
  # open: Q3
  @QAIA-US-004-006 @AC1 @P1 @negative @state-transition @low-confidence
  Scenario: Refuse rejection of a draft expense report before submission
    Given an expense report is currently in "draft" status
    When an approver attempts to reject the expense report
    Then the rejection action is refused with an error indicating only submitted reports can be decided upon

  # US-004 -> AC2 -> AC2-C1
  @QAIA-US-004-007 @AC2 @P1 @boundary
  Scenario: Require single manager approval for report total under 500 EUR
    Given an employee submits an expense report with a total of 499.99 EUR
    When the approval chain is determined
    Then the approval chain requires exactly 1 approval from "Manager"

  # US-004 -> AC2 -> AC2-C2
  # open: Q1
  @QAIA-US-004-008 @AC2 @P1 @boundary @low-confidence
  Scenario: Require manager and finance approval for report total exactly 500 EUR
    Given an employee submits an expense report with a total of 500.00 EUR
    When the approval chain is determined
    Then the approval chain requires exactly 2 approvals from "Manager" and "Finance"

  # US-004 -> AC2 -> AC2-C3
  # open: Q1
  @QAIA-US-004-009 @AC2 @P1 @boundary @low-confidence
  Scenario: Require manager and finance approval for report total upper boundary of 5000 EUR
    Given an employee submits an expense report with a total of 5000.00 EUR
    When the approval chain is determined
    Then the approval chain requires exactly 2 approvals from "Manager" and "Finance"

  # US-004 -> AC2 -> AC2-C4
  @QAIA-US-004-010 @AC2 @P1 @boundary
  Scenario: Require 3-level approval chain for report total over 5000 EUR
    Given an employee submits an expense report with a total of 5000.01 EUR
    When the full approval sequence is executed by Manager, Finance, and Director in order
    Then the expense report status transitions to "approved"

  # US-004 -> AC2 -> AC2-C5
  @QAIA-US-004-011 @AC2 @P1 @negative @decision-table
  Scenario: Refuse out-of-order approval attempt by secondary approver
    Given an expense report of 600.00 EUR is pending approval at the "Manager" step
    When a "Finance" user attempts to approve the report before the "Manager"
    Then the approval decision is refused with an out-of-order workflow error

  # US-004 -> AC3 -> AC3-C1
  @QAIA-US-004-012 @AC3 @P1 @negative @decision-table
  Scenario: Prevent an approver from approving their own expense report
    Given a user with role "Manager" submits an expense report for themselves
    When the same "Manager" attempts to approve their own expense report
    Then the decision action is refused with a self-approval prohibition error

  # US-004 -> AC3 -> AC3-C2
  # open: Q2
  @QAIA-US-004-013 @AC3 @P1 @decision-table @low-confidence
  Scenario: Escalate manager self-submitted report under 500 EUR to finance
    Given a user with role "Manager" submits an expense report with a total of 300.00 EUR
    When the approval chain is calculated for manager self-submission
    Then the "Manager" step is replaced by "Finance" as the sole required approver

  # US-004 -> AC3 -> AC3-C3
  # open: Q2
  @QAIA-US-004-014 @AC3 @P1 @decision-table @low-confidence
  Scenario: Skip manager step for manager self-submitted report over 5000 EUR
    Given a user with role "Manager" submits an expense report with a total of 6000.00 EUR
    When the approval chain is calculated for manager self-submission
    Then the "Manager" step is dropped and the chain requires approvals from "Finance" then "Director"

  # US-004 -> AC3 -> AC3-C4
  # open: Q8
  @QAIA-US-004-015 @AC3 @P1 @decision-table @low-confidence
  Scenario: Generalize self-approval rule for finance user submitting an expense report
    Given a user with role "Finance" submits an expense report requiring finance sign-off
    When the approval chain is calculated for finance self-submission
    Then the "Finance" step is escalated to "Director" to avoid self-approval

  # US-004 -> AC4 -> AC4-C1
  @QAIA-US-004-016 @AC4 @P3 @negative @ep
  Scenario: Refuse submission of an expense report with incomplete line data
    Given an expense report draft contains a line missing amount or category details
    When the employee attempts to submit the expense report
    Then the submission is refused with a validation error indicating mandatory line fields are missing

  # US-004 -> AC4 -> AC4-C2
  # open: Q5
  @QAIA-US-004-017 @AC4 @P2 @boundary @low-confidence
  Scenario: Accept an expense line dated exactly 90 days ago based on server clock
    Given an expense line is dated exactly 90 days prior to current server date
    When the employee submits the expense report
    Then the date validation succeeds and the line is accepted

  # US-004 -> AC4 -> AC4-C3
  @QAIA-US-004-018 @AC4 @P2 @negative @boundary
  Scenario: Refuse an expense line dated 91 days ago as exceeding maximum age limit
    Given an expense line is dated 91 days prior to current server date
    When the employee attempts to submit the expense report
    Then the submission is blocked with an error message stating the expense exceeds the 90-day limit

  # US-004 -> AC5 -> AC5-C1
  @QAIA-US-004-019 @AC5 @P2 @boundary
  Scenario: Accept line without receipt when amount is below 25 EUR threshold
    Given an expense line has an amount of 24.99 EUR and no receipt attached
    When the employee submits the expense report
    Then the line validation passes without requiring a receipt

  # US-004 -> AC5 -> AC5-C2
  @QAIA-US-004-020 @AC5 @P1 @negative @boundary
  Scenario: Refuse line without receipt when amount is exactly at 25 EUR threshold
    Given an expense line has an amount of 25.00 EUR and no receipt attached
    When the employee attempts to submit the expense report
    Then the submission is refused with an error indicating a receipt is mandatory for expenses of 25 EUR or more

  # US-004 -> AC5 -> AC5-C3
  @QAIA-US-004-021 @AC5 @P3 @ep
  Scenario: Accept line with receipt attached for expense equal to or above 25 EUR
    Given an expense line has an amount of 50.00 EUR and a valid receipt image attached
    When the employee submits the expense report
    Then the line validation succeeds

  # US-004 -> AC5 -> AC5-C4
  # open: Q6
  @QAIA-US-004-022 @AC5 @P1 @negative @boundary @low-confidence
  Scenario: Evaluate receipt threshold on converted EUR equivalent for foreign currency expenses
    Given a foreign currency expense line has face value 20 USD whose converted value is 26 EUR with no receipt attached
    When the employee attempts to submit the expense report
    Then the submission is refused because the EUR equivalent meets the mandatory receipt threshold

  # US-004 -> AC6 -> AC6-C1
  @QAIA-US-004-023 @AC6 @P1 @ep
  Scenario: Convert non-EUR report total to determine approval band threshold
    Given an expense report contains lines totaling 600 USD converted to 550 EUR at active exchange rates
    When the approval chain is calculated
    Then the approval band is evaluated against 550 EUR requiring Manager and Finance approvals

  # US-004 -> AC6 -> AC6-C2
  # open: Q4
  @QAIA-US-004-024 @AC6 @P1 @negative @error-guessing @low-confidence
  Scenario: Refuse submission when foreign currency conversion rate cannot be resolved
    Given an expense line uses an unresolvable foreign currency with no available rate
    When the employee attempts to submit the expense report
    Then the submission is refused with an error message indicating missing exchange rate data

  # US-004 -> AC6 -> AC6-C3
  # open: Q4
  @QAIA-US-004-025 @AC6 @P1 @error-guessing @low-confidence
  Scenario: Fall back to last available rate for weekend expense date and tag report as rateStale
    Given an expense line is dated on a weekend where no exact-date conversion rate exists
    When the employee submits the expense report
    Then the system applies the last available weekday rate and flags the report with "rateStale"

  # US-004 -> AC6 -> AC6-C4
  # open: Q7
  @QAIA-US-004-026 @AC6 @P1 @decision-table @low-confidence
  Scenario: Handle foreign currency conversion fallback near boundary for manager self-submitted report
    Given a manager submits a foreign currency report converted via stale fallback rate landing at 505 EUR
    When the system evaluates approval rules and self-approval constraints
    Then the report total of 505 EUR drives a 2-level chain where manager step is replaced by finance and director

  # US-004 -> AC7 -> AC7-C1
  @QAIA-US-004-027 @AC7 @P2 @negative @state-transition
  Scenario: Refuse editing a rejected expense report
    Given an expense report is in "rejected" terminal status
    When an employee attempts to edit lines on the rejected report
    Then the modification is refused because rejected reports are in a terminal state

  # US-004 -> AC7 -> AC7-C2
  @QAIA-US-004-028 @AC7 @P2 @negative @state-transition
  Scenario: Refuse re-submitting a rejected expense report
    Given an expense report is in "rejected" terminal status
    When an employee attempts to re-submit the rejected report
    Then the submission is refused because rejected reports cannot transition out of terminal status

  # US-004 -> AC8 -> AC8-C1
  @QAIA-US-004-029 @AC8 @P2 @negative @boundary
  Scenario: Refuse rejection decision when comment length is under 10 characters
    Given an approver attempts to reject a submitted expense report
    When the approver enters a rejection comment of "Too costly" (10 chars missing / 9 chars)
    Then the rejection is refused with an error stating comments must be at least 10 characters long

  # US-004 -> AC8 -> AC8-C2
  @QAIA-US-004-030 @AC8 @P2 @negative @boundary
  Scenario: Refuse changes request decision when comment is missing or shorter than 10 characters
    Given an approver attempts to request changes on a submitted report
    When the approver submits a comment with 5 characters
    Then the changes request action is refused due to insufficient comment length

  # US-004 -> AC8 -> AC8-C3
  @QAIA-US-004-031 @AC8 @P2 @boundary
  Scenario: Accept decision comment with exactly 10 characters minimum length
    Given an approver requests changes on a submitted expense report
    When the approver submits a comment of exactly 10 characters "Fix date 1"
    Then the decision is recorded successfully

  # US-004 -> AC8 -> AC8-C4
  @QAIA-US-004-032 @AC8 @P3 @ep
  Scenario: Allow report approval without requiring an approval comment
    Given an approver decides to approve a submitted expense report
    When the approver submits the approval decision without entering a comment
    Then the expense report status transitions to "approved" successfully

  # US-004 -> AC8 -> AC8-C5
  @QAIA-US-004-033 @AC8 @P1 @error-guessing
  Scenario: Record complete audit log entry with actor identity and timestamp for state transitions
    Given an expense report undergoes a state transition decision
    When the decision operation completes
    Then an audit log entry is persisted recording the actor user ID, state transition, and exact server timestamp

  # US-004 -> AC-auth -> AC-auth-C1
  @QAIA-US-004-034 @AC-auth @P2 @negative @error-guessing
  Scenario: Refuse report creation request from unauthenticated user
    Given an unauthenticated HTTP request is sent to create an expense report
    When the API processes the request
    Then the server responds with an HTTP 401 Unauthorized status

  # US-004 -> AC-auth -> AC-auth-C2
  @QAIA-US-004-035 @AC-auth @P2 @negative @error-guessing
  Scenario: Refuse approval decision request from unauthenticated user
    Given an unauthenticated HTTP request is sent to approve an expense report
    When the API processes the request
    Then the server responds with an HTTP 401 Unauthorized status

  # US-004 -> AC-auth -> AC-auth-C3
  @QAIA-US-004-036 @AC-auth @P1 @negative @error-guessing
  Scenario: Return HTTP 404 Not Found when employee attempts to access or edit another employee draft report
    Given Employee A attempts to modify a draft expense report belonging to Employee B
    When the request is evaluated by the authorization layer
    Then the server responds with HTTP 404 Not Found to avoid leaking report existence

  # US-004 -> AC-list -> AC-list-C1
  @QAIA-US-004-037 @AC-list @P3 @ep
  Scenario: Display explicit empty state when an employee has no expense reports
    Given an employee has no submitted or draft expense reports in the system
    When the employee views the "My Reports" page
    Then an explicit empty state view is displayed stating "No expense reports found"

  # US-004 -> Journey / Smoke
  @QAIA-US-004-038 @smoke @P1
  Scenario: Complete end-to-end multi-level approval journey for a standard expense report
    Given an employee creates a draft report with valid expense lines and receipts over 5000 EUR
    When the employee submits the report and each designated approver in the chain approves in sequence
    Then the expense report achieves final "approved" status with a full audit trail recorded