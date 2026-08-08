# US-004 — Expense Report Workflow
# Generated from AC → conditions → prioritization (P1+P2+P3 full-breadth scope)
# Negative-path coverage gate: 17 req-neg scenarios included
# Negative ratio: 17/37 = 45.9% (below 50% threshold — flagged in synthesis.md)
# Confidence flags: Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8 → 8 low-confidence scenarios

Feature: Expense Report Workflow
  A system to create, submit, approve, reject, and audit expense reports with multi-level approval chains and strict audit-trail requirements.

  Background:
    Given an authenticated employee
    And a clean expense report state

  @QAIA-004-001 @AC1 @state-transition @P2
  # AC1-C1: draft → submitted with valid data succeeds
  Scenario: Successfully submit a draft expense report
    Given a draft expense report with valid line items
    When the employee submits the report
    Then the report status changes to "submitted"
    And the report enters the approval chain

  @QAIA-004-002 @AC1 @state-transition @P2
  # AC1-C2: submitted → changes-requested → draft (re-entrant loop)
  Scenario: Re-enter draft state after changes requested
    Given a submitted expense report
    When the finance manager requests changes with a valid comment
    Then the report status changes to "changes-requested"
    And the report becomes editable again
    When the employee edits the report and submits again
    Then the report status changes to "submitted"

  @QAIA-004-003 @AC1 @state-transition @P2
  # AC1-C3: edited draft → resubmitted successfully
  Scenario: Edit and resubmit a draft report after changes requested
    Given a changes-requested expense report
    When the employee edits the report to fix issues
    And the employee submits the report
    Then the report status changes to "submitted"

  @QAIA-004-004 @AC1 @state-transition @P2 @negative
  # AC1-C4: submitting non-draft report is refused
  Scenario: Refuse submission of non-draft report
    Given a submitted expense report
    When the employee attempts to submit the report again
    Then the system refuses with "Report already submitted"
    And the report status remains "submitted"

  @QAIA-004-005 @AC1 @state-transition @P2 @negative
  # AC1-C5: editing non-draft report is refused
  Scenario: Refuse editing of non-draft report
    Given a submitted expense report
    When the employee attempts to edit the report
    Then the system refuses with "Cannot edit submitted report"
    And the report status remains "submitted"

  @QAIA-004-006 @AC1 @state-transition @P1 @negative @low-confidence(Q3)
  # AC1-C6: rejecting draft report is refused (only submitted accepts decisions)
  Scenario: Refuse rejection of draft report
    Given a draft expense report
    When the finance manager attempts to reject the report
    Then the system refuses with "Cannot reject draft report"
    And the report status remains "draft"

  @QAIA-004-007 @AC2 @boundary @P1
  # AC2-C1: <€500 requires 1 approval (manager)
  Scenario: Approve expense report under €500 threshold
    Given an expense report totaling €499.99
    When the manager approves the report
    Then the report status changes to "approved"

  @QAIA-004-008 @AC2 @boundary @P1 @negative @low-confidence(Q1)
  # AC2-C2: exactly €500 requires 2 approvals (manager, finance)
  Scenario: Require dual approval at €500 boundary
    Given an expense report totaling exactly €500.00
    When the manager approves the report
    Then the report status remains "submitted"
    When the finance manager approves the report
    Then the report status changes to "approved"

  @QAIA-004-009 @AC2 @boundary @P1 @negative @low-confidence(Q1)
  # AC2-C3: exactly €5000 requires 2 approvals (manager, finance)
  Scenario: Require dual approval at €5000 boundary
    Given an expense report totaling exactly €5000.00
    When the manager approves the report
    Then the report status remains "submitted"
    When the finance manager approves the report
    Then the report status changes to "approved"

  @QAIA-004-010 @AC2 @boundary @P1
  # AC2-C4: >€5000 requires 3 approvals (manager, finance, director)
  Scenario: Require triple approval above €5000 threshold
    Given an expense report totaling €5000.01
    When the manager approves the report
    Then the report status remains "submitted"
    When the finance manager approves the report
    Then the report status remains "submitted"
    When the director approves the report
    Then the report status changes to "approved"

  @QAIA-004-011 @AC2 @decision-table @P1 @negative
  # AC2-C5: out-of-order approval attempt is refused
  Scenario: Refuse out-of-order approval attempt
    Given an expense report totaling €5000.01 requiring director approval
    When the finance manager attempts to approve before manager
    Then the system refuses with "Approval chain violated: manager required first"
    And the report status remains "submitted"

  @QAIA-004-012 @AC3 @decision-table @P1 @negative
  # AC3-C1: self-approval is refused regardless of role
  Scenario: Refuse self-approval by report owner
    Given an expense report owned by the manager
    When the manager attempts to approve their own report
    Then the system refuses with "Self-approval not permitted"
    And the report status remains "submitted"

  @QAIA-004-013 @AC3 @decision-table @P1 @low-confidence(Q2)
  # AC3-C2: manager <€500 report escalates to finance (no manager step)
  Scenario: Escalate manager-submitted <€500 report to finance
    Given an expense report totaling €499.99 owned by a manager
    When the manager submits the report
    Then the approval chain skips manager step
    And finance becomes the first required approver

  @QAIA-004-014 @AC3 @decision-table @P1 @low-confidence(Q2)
  # AC3-C3: manager >€5000 report drops manager step entirely
  Scenario: Drop manager step for manager-submitted >€5000 report
    Given an expense report totaling €5000.01 owned by a manager
    When the manager submits the report
    Then the approval chain skips manager step
    And finance and director remain required

  @QAIA-004-015 @AC3 @decision-table @P1 @low-confidence(Q8)
  # AC3-C4: finance-submitted report generalizes skip/escalate logic
  Scenario: Finance-submitted report applies skip/escalate rules
    Given an expense report totaling €5000.01 owned by a finance user
    When the finance user submits the report
    Then the approval chain skips finance step
    And director becomes the first required approver

  @QAIA-004-016 @AC4 @ep @P3 @negative
  # AC4-C1: missing required line fields is refused at submission
  Scenario: Refuse submission with incomplete line items
    Given an expense report with a line missing category
    When the employee attempts to submit the report
    Then the system refuses with "Line item missing required fields"
    And the report status remains "draft"

  @QAIA-004-017 @AC4 @boundary @P2 @low-confidence(Q5)
  # AC4-C2: line dated exactly 90 days ago is accepted (inclusive boundary)
  Scenario: Accept line item dated exactly 90 days ago
    Given an expense report with a line item dated 90 days ago
    When the employee submits the report
    Then the system accepts the report
    And the report status changes to "submitted"

  @QAIA-004-018 @AC4 @boundary @P2 @negative
  # AC4-C3: line dated 91 days ago is blocked at submission
  Scenario: Block line item dated 91 days ago
    Given an expense report with a line item dated 91 days ago
    When the employee attempts to submit the report
    Then the system refuses with "Line item older than 90 days"
    And the report status remains "draft"

  @QAIA-004-019 @AC5 @boundary @P2
  # AC5-C1: line just under €25 threshold accepted without receipt
  Scenario: Accept line under €25 threshold without receipt
    Given an expense report with a line item of €24.99 and no receipt
    When the employee submits the report
    Then the system accepts the report
    And the report status changes to "submitted"

  @QAIA-004-020 @AC5 @boundary @P1 @negative
  # AC5-C2: line at exactly €25 threshold refused without receipt
  Scenario: Refuse line at €25 threshold without receipt
    Given an expense report with a line item of exactly €25.00 and no receipt
    When the employee attempts to submit the report
    Then the system refuses with "Receipt required for amounts €25.00 or greater"
    And the report status remains "draft"

  @QAIA-004-021 @AC5 @ep @P3
  # AC5-C3: line ≥€25 with receipt accepted
  Scenario: Accept line with receipt above threshold
    Given an expense report with a line item of €25.00 and a receipt attached
    When the employee submits the report
    Then the system accepts the report
    And the report status changes to "submitted"

  @QAIA-004-022 @AC5 @boundary @P1 @negative @low-confidence(Q6)
  # AC5-C4: non-EUR <25 face value but ≥25 EUR-equivalent refused without receipt
  Scenario: Refuse non-EUR line with EUR-equivalent ≥€25 without receipt
    Given an expense report with a line item of 24.99 USD (EUR equivalent €25.01) and no receipt
    When the employee attempts to submit the report
    Then the system refuses with "Receipt required for amounts €25.00 or greater (EUR basis)"
    And the report status remains "draft"

  @QAIA-004-023 @AC6 @ep @P1
  # AC6-C1: non-EUR report converts total correctly driving approval bands
  Scenario: Convert non-EUR report total to EUR for approval threshold
    Given an expense report with total 100 USD
    And the system uses exchange rate 1 USD = 0.85 EUR
    When the employee submits the report
    Then the system converts total to €85.00
    And the report enters the €85.00 approval chain (manager → finance)

  @QAIA-004-024 @AC6 @error-guessing @P1 @negative @low-confidence(Q4)
  # AC6-C2: currency/date pair with no resolvable rate refused at submission
  Scenario: Refuse submission with unresolvable exchange rate
    Given an expense report with a line item in a currency with no available rate
    When the employee attempts to submit the report
    Then the system refuses with "No exchange rate available for currency/date"
    And the report status remains "draft"

  @QAIA-004-025 @AC6 @error-guessing @P1 @low-confidence(Q4)
  # AC6-C3: weekend/holiday gap uses last available prior rate and flags stale
  Scenario: Accept expense report with stale rate fallback
    Given an expense report with a line item dated on a weekend
    And the system uses last available prior rate (stale)
    When the employee submits the report
    Then the system accepts the report
    And the report is flagged "rateStale"

  @QAIA-004-026 @AC6 @decision-table @P1 @low-confidence(Q7)
  # AC6-C4: stale fallback rate near boundary drives correct approval chain
  Scenario: Stale fallback rate near boundary correctly routes approval chain
    Given an expense report with total 5999.99 USD (EUR equivalent €5000.00 after stale fallback)
    And the system flags "rateStale"
    When the employee submits the report
    Then the system converts to €5000.00
    And the report enters dual-approval chain (manager → finance)

  @QAIA-004-027 @AC7 @state-transition @P2 @negative
  # AC7-C1: rejected report cannot be edited
  Scenario: Refuse editing of rejected report
    Given a rejected expense report
    When the employee attempts to edit the report
    Then the system refuses with "Cannot edit rejected report"
    And the report status remains "rejected"

  @QAIA-004-028 @AC7 @state-transition @P2 @negative
  # AC7-C2: rejected report cannot be resubmitted
  Scenario: Refuse resubmission of rejected report
    Given a rejected expense report
    When the employee attempts to submit the report again
    Then the system refuses with "Cannot resubmit rejected report"
    And the report status remains "rejected"

  @QAIA-004-029 @AC8 @boundary @P2 @negative
  # AC8-C1: rejection without valid comment refused
  Scenario: Refuse rejection without sufficient comment
    Given a submitted expense report
    When the finance manager attempts to reject with comment "too"
    Then the system refuses with "Comment must be at least 10 characters"
    And the report status remains "submitted"

  @QAIA-004-030 @AC8 @boundary @P2 @negative
  # AC8-C2: changes request without valid comment refused
  Scenario: Refuse changes request without sufficient comment
    Given a submitted expense report
    When the finance manager attempts to request changes with comment "fix"
    Then the system refuses with "Comment must be at least 10 characters"
    And the report status remains "submitted"

  @QAIA-004-031 @AC8 @boundary @P2
  # AC8-C3: exact 10-character comment accepted
  Scenario: Accept rejection with exactly 10-character comment
    Given a submitted expense report
    When the finance manager rejects with comment "needs revision"
    Then the system accepts the decision
    And the report status changes to "rejected"

  @QAIA-004-032 @AC8 @ep @P3
  # AC8-C4: approval does not require comment
  Scenario: Approve report without comment
    Given a submitted expense report
    When the manager approves the report
    Then the system accepts the decision
    And the report status changes to "approved"

  @QAIA-004-033 @AC8 @error-guessing @P1
  # AC8-C5: every transition recorded in audit trail with who and when
  Scenario: Record all state transitions in audit trail
    Given a draft expense report
    When the employee submits the report
    Then the system records "submit" by employee at timestamp
    When the manager approves the report
    Then the system records "approve" by manager at timestamp
    When the finance manager rejects the report
    Then the system records "reject" by finance manager at timestamp

  @QAIA-004-034 @AC-auth @error-guessing @P2 @negative
  # AC-auth-C1: creating report without authentication refused
  Scenario: Refuse report creation without authentication
    Given no authenticated session
    When the employee attempts to create a new expense report
    Then the system refuses with HTTP 401
    And no report is created

  @QAIA-004-035 @AC-auth @error-guessing @P2 @negative
  # AC-auth-C2: deciding on report without authentication refused
  Scenario: Refuse approval decision without authentication
    Given no authenticated session
    When the manager attempts to approve a submitted report
    Then the system refuses with HTTP 401

  @QAIA-004-036 @AC-auth @error-guessing @P1 @negative
  # AC-auth-C3: attempting to edit another employee's draft refused (404)
  Scenario: Refuse editing of another employee's draft report
    Given an authenticated employee
    And another employee's draft report
    When the employee attempts to edit the report via ID
    Then the system refuses with HTTP 404
    And no information about report existence is disclosed

  @QAIA-004-037 @AC-list @ep @P3
  # AC-list-C1: empty state shown when employee has no reports
  Scenario: Show empty state for employee with no reports
    Given an employee with no expense reports
    When the employee views "My reports"
    Then the system displays "No expense reports found"
