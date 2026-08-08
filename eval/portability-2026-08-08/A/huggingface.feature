Feature: US-004 Expense Report Workflow

# Shared immutable setup
Background:
  Given an authenticated employee

# US-004 AC1-C1: draft → submitted succeeds
@QAIA-US-004-001 @AC1 @P2 @state-transition
Scenario: Submit a draft report with valid data
  Given a draft expense report with valid data
  When the employee submits the report
  Then the report transitions to submitted

# US-004 AC1-C2: changes‑requested → draft re‑entry, report editable again
@QAIA-US-004-002 @AC1 @P2 @state-transition
Scenario: Request changes then revert to draft
  Given a submitted expense report
  And the manager requests changes
  When the report status changes to changes‑requested
  And the employee reverts the report to draft
  Then the report is editable again

# US-004 AC1-C3: edit draft after changes‑requested and re‑submit successfully
@QAIA-US-004-003 @AC1 @P2 @state-transition
Scenario: Edit a re‑entered draft and submit
  Given a draft expense report that was previously changes‑requested
  When the employee edits the report
  And the employee submits the report
  Then the report transitions to submitted

# US-004 AC1-C4: refuse submission when not in draft
@QAIA-US-004-004 @AC1 @P2 @state-transition @negative
Scenario: Reject submission of a non‑draft report
  Given an expense report in submitted status
  When the employee attempts to submit the report
  Then the submission is refused

# US-004 AC1-C5: refuse editing when not in draft
@QAIA-US-004-005 @AC1 @P2 @state-transition @negative
Scenario: Reject editing of a non‑draft report
  Given an expense report in submitted status
  When the employee attempts to edit the report
  Then the edit is refused

# US-004 AC1-C6: refuse rejecting a draft (low‑confidence)
@QAIA-US-004-006 @AC1 @P1 @state-transition @negative @low-confidence
Scenario: Reject drafting a report
  # open: Q3
  Given a draft expense report
  When the manager attempts to reject the report
  Then the rejection is refused

# US-004 AC2-C1: amount just under €500 requires 1 approval
@QAIA-US-004-007 @AC2 @P1 @boundary
Scenario: Single approval for amount just under €500
  Given a draft expense report with total €499.99
  When the employee submits the report
  Then the report requires manager approval only

# US-004 AC2-C2: amount exactly €500 requires 2 approvals (low‑confidence)
@QAIA-US-004-008 @AC2 @P1 @boundary @low-confidence
Scenario: Two approvals for amount exactly €500
  # open: Q1
  Given a draft expense report with total €500.00
  When the employee submits the report
  Then the report requires manager and finance approvals

# US-004 AC2-C3: amount exactly €5000 requires 2 approvals (low‑confidence)
@QAIA-US-004-009 @AC2 @P1 @boundary @low-confidence
Scenario: Two approvals for amount exactly €5000
  # open: Q1
  Given a draft expense report with total €5000.00
  When the employee submits the report
  Then the report requires manager and finance approvals

# US-004 AC2-C4: amount just above €5000 requires 3 approvals
@QAIA-US-004-010 @AC2 @P1 @boundary
Scenario: Three approvals for amount just above €5000
  Given a draft expense report with total €5000.01
  When the employee submits the report
  Then the report requires manager, finance, and director approvals
  And the report reaches approved status

# US-004 AC2-C5: refuse out‑of‑order approval (decision‑table)
@QAIA-US-004-011 @AC2 @P1 @decision-table @negative
Scenario: Reject out‑of‑order approver
  Given a draft expense report awaiting manager approval
  When a finance user attempts to approve the report
  Then the approval is refused

# US-004 AC3-C1: refuse self‑approval (decision‑table)
@QAIA-US-004-012 @AC3 @P1 @decision-table @negative
Scenario: Reject self‑approval
  Given a draft expense report submitted by manager
  When the manager attempts to approve their own report
  Then the approval is refused

# US-004 AC3-C2: manager‑submitted < €500 report escalated to finance (low‑confidence)
@QAIA-US-004-013 @AC3 @P1 @decision-table @low-confidence
Scenario: Escalate manager‑submitted low‑value report
  # open: Q2
  Given a draft expense report of €400 submitted by a manager
  When the report reaches the approval stage
  Then finance approval is required instead of manager

# US-004 AC3-C3: manager‑submitted > €5000 report skips manager (low‑confidence)
@QAIA-US-004-014 @AC3 @P1 @decision-table @low-confidence
Scenario: Skip manager for high‑value report
  # open: Q2
  Given a draft expense report of €6000 submitted by a manager
  When the report reaches the approval stage
  Then finance and director approvals are required, manager is omitted

# US-004 AC3-C4: finance‑submitted report escalates or skips finance (low‑confidence)
@QAIA-US-004-015 @AC3 @P1 @decision-table @low-confidence
Scenario: Finance user self‑approval handling
  # open: Q8
  Given a draft expense report submitted by a finance user that requires finance approval
  When the report reaches the approval stage
  Then director approval replaces finance, unless director is already required

# US-004 AC4-C1: refuse line with missing mandatory fields (equivalence partition)
@QAIA-US-004-016 @AC4 @P3 @ep @negative
Scenario: Reject line with missing mandatory data
  Given an expense line missing category, amount, or date
  When the employee attempts to submit the line
  Then the submission is refused

# US-004 AC4-C2: accept line dated exactly 90 days ago (boundary, low‑confidence)
@QAIA-US-004-017 @AC4 @P2 @boundary @low-confidence
Scenario: Accept line dated exactly 90 days ago
  # open: Q5
  Given an expense line dated 90 days ago
  When the employee submits the line
  Then the line is accepted

# US-004 AC4-C3: refuse line dated 91 days ago (boundary)
@QAIA-US-004-018 @AC4 @P2 @boundary @negative
Scenario: Reject line dated 91 days ago
  Given an expense line dated 91 days ago
  When the employee attempts to submit the line
  Then the submission is refused

# US-004 AC5-C1: accept line just under €25 without receipt (boundary)
@QAIA-US-004-019 @AC5 @P2 @boundary
Scenario: Accept line just under €25 without receipt
  Given an expense line with EUR‑equivalent total €24.99 and no receipt
  When the employee submits the line
  Then the line is accepted

# US-004 AC5-C2: refuse line exactly €25 without receipt (boundary, low‑confidence)
@QAIA-US-004-020 @AC5 @P1 @boundary @negative @low-confidence
Scenario: Reject line at €25 threshold without receipt
  # open: Q1
  Given an expense line with EUR‑equivalent total €25.00 and no receipt
  When the employee attempts to submit the line
  Then the submission is refused

# US-004 AC5-C3: accept line ≥ €25 with receipt (equivalence partition)
@QAIA-US-004-021 @AC5 @P3 @ep
Scenario: Accept line ≥ €25 with receipt
  Given an expense line with total €30.00 and a receipt attached
  When the employee submits the line
  Then the line is accepted

# US-004 AC5-C4: refuse non‑EUR line whose EUR‑equivalent ≥ €25 without receipt (low‑confidence)
@QAIA-US-004-022 @AC5 @P1 @boundary @negative @low-confidence
Scenario: Reject non‑EUR line exceeding EUR threshold without receipt
  # open: Q6
  Given a non‑EUR expense line with face value €20 whose EUR‑equivalent is €27 and no receipt
  When the employee attempts to submit the line
  Then the submission is refused

# US-004 AC6-C1: correct currency conversion drives approval band (equivalence partition)
@QAIA-US-004-023 @AC6 @P1 @ep
Scenario: Correct conversion of foreign currency total
  Given a non‑EUR expense report with total converted to €450
  When the employee submits the report
  Then the report follows the approval band for amounts under €500

# US-004 AC6-C2: refuse report when currency/date pair has no resolvable rate (error‑guessing, low‑confidence)
@QAIA-US-004-024 @AC6 @P1 @error-guessing @negative @low-confidence
Scenario: Reject report with unresolvable currency rate
  # open: Q4
  Given an expense report with a currency/date pair lacking a conversion rate
  When the employee attempts to submit the report
  Then the submission is refused

# US-004 AC6-C3: accept weekend/holiday date using stale prior rate, flag rateStale (error‑guessing, low‑confidence)
@QAIA-US-004-025 @AC6 @P1 @error-guessing @low-confidence
Scenario: Accept report with stale fallback rate
  # open: Q4
  Given an expense report dated on a weekend with no exact‑date rate
  When the system uses the last available prior rate
  Then the report is accepted and flagged as rateStale

# US-004 AC6-C4: stale fallback rate near band boundary still drives escalation (decision‑table, low‑confidence)
@QAIA-US-004-026 @AC6 @P1 @decision-table @low-confidence
Scenario: Escalation from stale rate near boundary
  # open: Q7
  Given a foreign‑currency expense report converted via a stale rate to €500.00
  When the employee submits the report
  Then the report requires manager and finance approvals according to the boundary rule
  And the self‑approval escalation logic is applied

# US-004 AC7-C1: refuse editing a rejected report (state‑transition)
@QAIA-US-004-027 @AC7 @P2 @state-transition @negative
Scenario: Reject edit of a rejected report
  Given a rejected expense report
  When the employee attempts to edit the report
  Then the edit is refused

# US-004 AC7-C2: refuse re‑submitting a rejected report (state‑transition)
@QAIA-US-004-028 @AC7 @P2 @state-transition @negative
Scenario: Reject re‑submission of a rejected report
  Given a rejected expense report
  When the employee attempts to submit the report again
  Then the submission is refused

# US-004 AC8-C1: reject without comment or comment < 10 chars (boundary)
@QAIA-US-004-029 @AC8 @P2 @boundary @negative
Scenario: Reject without sufficient comment
  Given a draft expense report
  When the manager attempts to reject the report without a comment
  Then the rejection is refused
  When the manager attempts to reject the report with a comment shorter than 10 characters
  Then the rejection is refused

# US-004 AC8-C2: request changes without comment or comment < 10 chars (boundary)
@QAIA-US-004-030 @AC8 @P2 @boundary @negative
Scenario: Request changes without sufficient comment
  Given a submitted expense report
  When the manager requests changes without a comment
  Then the request is refused
  When the manager requests changes with a comment shorter than 10 characters
  Then the request is refused

# US-004 AC8-C3: accept comment of exactly 10 characters (boundary)
@QAIA-US-004-031 @AC8 @P2 @boundary
Scenario: Accept comment of exactly ten characters
  Given a submitted expense report
  When the manager adds a comment of exactly ten characters and requests changes
  Then the request is accepted

# US-004 AC8-C4: approving a report does not require a comment (equivalence partition)
@QAIA-US-004-032 @AC8 @P3 @ep
Scenario: Approve report without comment
  Given a submitted expense report
  When the manager approves the report without providing a comment
  Then the approval is successful

# US-004 AC8-C5: every transition is recorded in audit trail (error‑guessing)
@QAIA-US-004-033 @AC8 @P1 @error-guessing
Scenario: Verify audit‑trail entries for all transitions
  Given a draft expense report
  When the employee submits the report
  And the manager requests changes
  And the employee edits the report and resubmits
  And the manager approves the report
  Then each transition is recorded in the audit trail with who and when

# US-004 AC-auth-C1: refuse creating a report without authentication (error‑guessing)
@QAIA-US-004-034 @AC-auth @P2 @error-guessing @negative
Scenario: Reject unauthenticated report creation
  Given an unauthenticated user
  When the user attempts to create a report
  Then the request is refused with status 401

# US-004 AC-auth-C2: refuse deciding on a report without authentication (error‑guessing)
@QAIA-US-004-035 @AC-auth @P2 @error-guessing @negative
Scenario: Reject unauthenticated decision on a report
  Given an unauthenticated user
  When the user attempts to approve a report
  Then the request is refused with status 401

# US-004 AC-auth-C3: refuse editing another employee's draft without disclosing existence (error‑guessing, low‑confidence)
@QAIA-US-004-036 @AC-auth @P1 @error-guessing @negative @low-confidence
Scenario: Reject cross‑employee draft edit without revealing existence
  # open: Q3
  Given an authenticated employee A
  And employee B has a draft report
  When employee A attempts to edit employee B's draft
  Then the request is refused with status 404

# US-004 AC-list-C1: employee with no reports sees empty list (equivalence partition)
@QAIA-US-004-037 @AC-list @P3 @ep
Scenario: View empty report list for employee with none
  Given an authenticated employee with no expense reports
  When the employee views "My reports"
  Then the list is displayed as empty

# US-004 End‑to‑end happy path (journey)
@QAIA-US-004-038 @smoke @P1
Scenario: Complete expense report lifecycle happy path
  Given an authenticated employee
  And a draft expense report with total €450 and valid data
  When the employee submits the report
  Then the report requires manager approval
  When the manager approves the report
  Then the report transitions to approved
  And the audit trail records the create, submit, and approve events with correct who and when