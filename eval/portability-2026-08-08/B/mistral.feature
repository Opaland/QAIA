# QAIA test book — US-004 — expense report workflow
# Generated from 03-design.md + 04-priorities.md
# Scope: P1+P2+P3 (full-breadth demo)
# Negative-path gate: 17/17 [req-neg] conditions covered
# Negative ratio: 10/37 = 27 %
# Confidence: 11/37 scenarios @low-confidence (Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8)

Feature: Expense report workflow
  A user can create, edit, submit, and obtain approval for expense reports with multi-level controls and audit trails.

  Background:
    Given an authenticated employee
    And a clean expense report state

  Scenario: Draft report transitions to submitted with valid data
    # AC1-C1 | technique: state-transition
    @QAIA-004-001 @AC1 @P2 @state-transition
    Given a report in state 'draft'
    When the employee submits the report
    Then the report state becomes 'submitted'

  Scenario: Changes requested on a submitted report allow editing (re-entrant loop)
    # AC1-C2 | technique: state-transition
    @QAIA-004-002 @AC1 @P2 @state-transition
    Given a report in state 'submitted'
    When a manager requests changes with a 10-character comment
    And the employee edits the report
    Then the report state becomes 'draft'

  Scenario: Edited draft report is resubmitted successfully
    # AC1-C3 | technique: state-transition
    @QAIA-004-003 @AC1 @P2 @state-transition
    Given a report in state 'draft'
    When the employee submits the report
    Then the report state becomes 'submitted'

  Scenario: Submitting a report that is not in draft is refused
    # AC1-C4 [req-neg] | technique: state-transition
    @QAIA-004-004 @AC1 @P2 @state-transition @negative
    Given a report in state 'submitted'
    When the employee attempts to submit the report
    Then the submission is refused
    And the report remains in state 'submitted'

  Scenario: Editing a report that is not in draft is refused
    # AC1-C5 [req-neg] | technique: state-transition
    @QAIA-004-005 @AC1 @P2 @state-transition @negative
    Given a report in state 'submitted'
    When the employee attempts to edit the report
    Then the edit is refused
    And the report remains in state 'submitted'

  Scenario: Rejecting a report in draft is refused
    # AC1-C6 [req-neg] | technique: state-transition | @low-confidence(Q3)
    @QAIA-004-006 @AC1 @P1 @state-transition @negative @low-confidence
    Given a report in state 'draft'
    When a manager attempts to reject the report
    Then the rejection is refused
    And the report remains in state 'draft'
    # open: Q3

  Scenario Outline: Amount under €500 requires exactly one approval (manager)
    # AC2-C1 | technique: boundary
    @QAIA-004-007 @AC2 @P1 @boundary
    Examples:
      | total |
      | 499.99 |

  Scenario Outline: Amount exactly €500.00 requires two approvals (manager + finance)
    # AC2-C2 [req-neg-adjacent] | technique: boundary | @low-confidence(Q1)
    @QAIA-004-008 @AC2 @P1 @boundary @low-confidence
    Examples:
      | total |
      | 500.00 |
    # open: Q1

  Scenario Outline: Amount exactly €5000.00 requires two approvals (manager + finance)
    # AC2-C3 | technique: boundary | @low-confidence(Q1)
    @QAIA-004-009 @AC2 @P1 @boundary @low-confidence
    Examples:
      | total |
      | 5000.00 |
    # open: Q1

  Scenario Outline: Amount just above €5000 requires three approvals (manager → finance → director)
    # AC2-C4 | technique: boundary
    @QAIA-004-010 @AC2 @P1 @boundary
    Examples:
      | total   |
      | 5000.01 |

  Scenario: Out-of-order approval attempt is refused
    # AC2-C5 [req-neg] | technique: decision-table
    @QAIA-004-011 @AC2 @P1 @decision-table @negative
    Given a report in state 'submitted' with total €5000.01
    When finance attempts to approve before manager
    Then the approval is refused
    And the report remains in state 'submitted'

  Scenario: Employee attempting to approve their own report is refused
    # AC3-C1 [req-neg] | technique: decision-table
    @QAIA-004-012 @AC3 @P1 @decision-table @negative
    Given a report in state 'submitted' owned by the employee
    When the employee attempts to approve the report
    Then the approval is refused
    And the report remains in state 'submitted'

  Scenario: Manager-submitted <€500 report escalates finance approval
    # AC3-C2 | technique: decision-table | @low-confidence(Q2)
    @QAIA-004-013 @AC3 @P1 @decision-table @low-confidence
    Given a manager-owned report with total €499.99
    When the manager submits the report
    Then the next approver is 'finance'
    # open: Q2

  Scenario: Manager-submitted >€5000 report drops manager step and keeps finance+director
    # AC3-C3 | technique: decision-table | @low-confidence(Q2)
    @QAIA-004-014 @AC3 @P1 @decision-table @low-confidence
    Given a manager-owned report with total €5000.01
    When the manager submits the report
    Then the next approver is 'finance'
    And the subsequent approver is 'director'
    # open: Q2

  Scenario: Finance-user submission generalizes skip/escalate rule
    # AC3-C4 | technique: decision-table | @low-confidence(Q8)
    @QAIA-004-015 @AC3 @P1 @decision-table @low-confidence
    Given a finance-owned report requiring finance approval
    When the finance user submits the report
    Then the next approver is 'director'
    # open: Q8

  Scenario: Missing line category, amount, or date is refused at submission
    # AC4-C1 [req-neg] | technique: ep
    @QAIA-004-016 @AC4 @P3 @ep @negative
    Given a report with an incomplete line
    When the employee submits the report
    Then the submission is refused

  Scenario: Line dated exactly 90 days ago is accepted (inclusive boundary)
    # AC4-C2 | technique: boundary | @low-confidence(Q5)
    @QAIA-004-017 @AC4 @P2 @boundary @low-confidence
    Given a line dated exactly 90 days ago (server-clock reference)
    When the employee submits the report
    Then the line is accepted
    # open: Q5

  Scenario: Line dated 91 days ago is blocked at submission
    # AC4-C3 [req-neg] | technique: boundary
    @QAIA-004-018 @AC4 @P2 @boundary @negative
    Given a line dated 91 days ago
    When the employee submits the report
    Then the submission is refused with an explanatory message

  Scenario Outline: Line just under EUR €25 threshold without receipt is accepted
    # AC5-C1 | technique: boundary
    @QAIA-004-019 @AC5 @P2 @boundary
    Examples:
      | amount |
      | 24.99  |

  Scenario: Line at exactly EUR €25 threshold without receipt is refused
    # AC5-C2 [req-neg] | technique: boundary
    @QAIA-004-020 @AC5 @P1 @boundary @negative
    Given a line with EUR-equivalent total €25.00 and no receipt
    When the employee submits the report
    Then the submission is refused

  Scenario: Line ≥ €25 with a receipt attached is accepted
    # AC5-C3 | technique: ep
    @QAIA-004-021 @AC5 @P3 @ep
    Given a line with EUR-equivalent total €25.00 and a receipt attached
    When the employee submits the report
    Then the line is accepted

  Scenario: Non-EUR line whose EUR-equivalent ≥ €25 without receipt is refused
    # AC5-C4 [req-neg] | technique: boundary | @low-confidence(Q6)
    @QAIA-004-022 @AC5 @P1 @boundary @negative @low-confidence
    Given a line with face value 24.99 in USD (EUR-equivalent €25.01) and no receipt
    When the employee submits the report
    Then the submission is refused
    # open: Q6

  Scenario: Non-EUR report total is converted correctly and drives approval band
    # AC6-C1 | technique: ep
    @QAIA-004-023 @AC6 @P1 @ep
    Given a non-EUR report with total 5000.01 USD
    And a conversion rate of 1.0000 USD/EUR
    When the report is submitted
    Then the converted total is €5000.01
    And the required approval chain is manager → finance → director

  Scenario: Currency/date pair with no resolvable rate is refused at submission
    # AC6-C2 [req-neg] | technique: error-guessing | @low-confidence(Q4)
    @QAIA-004-024 @AC6 @P1 @error-guessing @negative @low-confidence
    Given a report with a line dated 2026-07-26 in a currency with no available rate
    When the employee submits the report
    Then the submission is refused with an explanatory message
    # open: Q4

  Scenario: Expense dated in a weekend/holiday gap uses last available prior rate and flags stale
    # AC6-C3 | technique: error-guessing | @low-confidence(Q4)
    @QAIA-004-025 @AC6 @P1 @error-guessing @low-confidence
    Given a report with a line dated 2026-07-26 (weekend) in USD
    And the last available rate on 2026-07-04 is 1.0000 USD/EUR
    When the report is submitted
    Then the converted total uses the rate 1.0000 USD/EUR
    And the report is flagged 'rateStale'
    # open: Q4

  Scenario: Stale-rate converted total still drives band and escalation
    # AC6-C4 | technique: decision-table | @low-confidence(Q7)
    @QAIA-004-026 @AC6 @P1 @decision-table @low-confidence
    Given a manager-owned report with total 5000.01 USD
    And a stale conversion rate of 1.0000 USD/EUR
    When the manager submits the report
    Then the converted total is €5000.01
    And the next approver is 'finance'
    And the subsequent approver is 'director'
    # open: Q7

  Scenario: Editing a rejected report is refused
    # AC7-C1 [req-neg] | technique: state-transition
    @QAIA-004-027 @AC7 @P2 @state-transition @negative
    Given a report in state 'rejected'
    When the employee attempts to edit the report
    Then the edit is refused
    And the report remains in state 'rejected'

  Scenario: Resubmitting a rejected report is refused
    # AC7-C2 [req-neg] | technique: state-transition
    @QAIA-004-028 @AC7 @P2 @state-transition @negative
    Given a report in state 'rejected'
    When the employee attempts to submit the report
    Then the submission is refused
    And the report remains in state 'rejected'

  Scenario: Rejecting without a comment or with a comment under 10 characters is refused
    # AC8-C1 [req-neg] | technique: boundary
    @QAIA-004-029 @AC8 @P2 @boundary @negative
    Given a report in state 'submitted'
    When a manager attempts to reject the report with a comment of length 9
    Then the rejection is refused

  Scenario: Requesting changes without a comment or with a comment under 10 characters is refused
    # AC8-C2 [req-neg] | technique: boundary
    @QAIA-004-030 @AC8 @P2 @boundary @negative
    Given a report in state 'submitted'
    When a manager attempts to request changes with a comment of length 9
    Then the request is refused

  Scenario: Comment of exactly 10 characters is accepted
    # AC8-C3 | technique: boundary
    @QAIA-004-031 @AC8 @P2 @boundary
    Given a report in state 'submitted'
    When a manager attempts to reject the report with a comment of length 10
    Then the rejection is accepted

  Scenario: Approving a report does not require a comment
    # AC8-C4 | technique: ep
    @QAIA-004-032 @AC8 @P3 @ep
    Given a report in state 'submitted'
    When a manager approves the report
    Then the approval is accepted

  Scenario: Every transition is recorded in the audit trail with who and when
    # AC8-C5 | technique: error-guessing
    @QAIA-004-033 @AC8 @P1 @error-guessing
    Given a report in state 'draft'
    When the employee submits the report
    And a manager requests changes with a 10-character comment
    And the employee edits the report
    And the employee resubmits the report
    And a manager approves the report
    Then the audit trail contains entries for:
      | who      | when          | action               |
      | employee | <timestamp>   | create               |
      | employee | <timestamp>   | submit               |
      | manager  | <timestamp>   | changes-requested    |
      | employee | <timestamp>   | edit                 |
      | employee | <timestamp>   | submit               |
      | manager  | <timestamp>   | approve              |

  Scenario: Creating a report without authentication is refused
    # AC-auth-C1 [req-neg] | technique: error-guessing
    @QAIA-004-034 @AC-auth @P2 @error-guessing @negative
    Given an unauthenticated request
    When an employee attempts to create a report
    Then the request is refused with HTTP 401

  Scenario: Deciding on a report without authentication is refused
    # AC-auth-C2 [req-neg] | technique: error-guessing
    @QAIA-004-034 @AC-auth @P2 @error-guessing @negative
    Given an unauthenticated request
    When an employee attempts to decide on a report
    Then the request is refused with HTTP 401

  Scenario: Attempting to edit another employee's draft is refused without disclosing existence
    # AC-auth-C3 [req-neg] | technique: error-guessing
    @QAIA-004-035 @AC-auth @P1 @error-guessing @negative
    Given an authenticated employee
    When the employee attempts to edit another employee's draft report
    Then the request is refused with HTTP 404

  Scenario: Employee with no reports sees explicit empty state
    # AC-list-C1 | technique: ep
    @QAIA-004-036 @AC-list @P3 @ep
    Given an employee with no reports
    When the employee views "My reports"
    Then the UI displays "No reports found"
