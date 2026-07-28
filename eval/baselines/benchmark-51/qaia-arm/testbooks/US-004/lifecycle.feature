> US-004 | source: US → AC1, AC7 → 03-design.md conditions AC1-C1..C9, AC7-C1..C3, EXP-1
Feature: Expense report lifecycle and terminal states

  Background:
    Given an employee with an active expense report

  @QAIA-US-004-001 @AC1 @P1 @state-transition
  # condition: AC1-C1
  Scenario: Draft report is submitted
    Given the report is in "draft" state with all mandatory line-item fields present
    When the employee submits the report
    Then the report moves to "submitted" state

  @QAIA-US-004-002 @AC1 @P1 @state-transition
  # condition: AC1-C2
  Scenario: Submitted report reaches final approval
    Given the report is in "submitted" state and has passed every required approval level
    When the last required approver approves the report
    Then the report moves to "approved" state

  @QAIA-US-004-003 @AC1 @P1 @negative @state-transition
  # condition: AC1-C3
  Scenario: Submitted report is rejected
    Given the report is in "submitted" state
    When an approver rejects the report with a valid comment
    Then the report moves to "rejected" state

  @QAIA-US-004-004 @AC1 @P2 @state-transition
  # condition: AC1-C4
  Scenario: Submitted report is sent back for changes
    Given the report is in "submitted" state
    When an approver requests changes with a valid comment
    Then the report moves to "changes-requested" state

  @QAIA-US-004-005 @AC1 @P1 @state-transition
  # condition: AC1-C5
  Scenario: Changes-requested report returns to draft
    Given the report is in "changes-requested" state
    When the employee opens the report for editing
    Then the report moves to "draft" state

  @QAIA-US-004-006 @AC1 @P1 @state-transition
  # condition: AC1-C6
  Scenario: Draft report re-submitted after changes were requested
    Given the report is in "draft" state having previously been "changes-requested"
    When the employee re-submits the report
    Then the report moves to "submitted" state

  @QAIA-US-004-007 @AC1 @P2 @negative @state-transition
  # condition: AC1-C7
  Scenario: A draft report cannot skip directly to approved
    Given the report is in "draft" state
    When a direct transition to "approved" is attempted, bypassing "submitted"
    Then the transition is rejected as forbidden and the report stays in "draft" state

  @QAIA-US-004-008 @AC1 @P2 @negative @state-transition @low-confidence
  # condition: AC1-C8
  # assumption: Q9 — approved is treated as terminal, like rejected (AC7 is explicit only about rejected)
  Scenario: An approved report cannot be further transitioned
    Given the report is in "approved" state
    When any further transition (edit, re-submit, approve, reject, request-changes) is attempted
    Then the transition is rejected as forbidden and the report stays in "approved" state

  @QAIA-US-004-009 @AC1 @P3 @negative @state-transition @low-confidence
  # condition: AC1-C9
  # open: Q5 — the state model does not track per-level pending-approver progress
  Scenario: An approver whose level already signed off cannot act again on the same report
    Given the report's manager-level approval has already been recorded on this report
    When the same manager attempts to approve or reject the report a second time
    Then the transition is rejected as forbidden

  @QAIA-US-004-010 @AC7 @P1 @negative @state-transition
  # condition: AC7-C1
  Scenario: A rejected report cannot be edited
    Given the report is in "rejected" state
    When the employee attempts to edit the report
    Then the edit is refused because the report is terminal

  @QAIA-US-004-011 @AC7 @P1 @negative @state-transition
  # condition: AC7-C2
  Scenario: A rejected report cannot be re-submitted
    Given the report is in "rejected" state
    When the employee attempts to re-submit the report
    Then the re-submission is refused because the report is terminal

  @QAIA-US-004-012 @AC7 @P2 @state-transition
  # condition: AC7-C3
  Scenario: A new report can be created after a rejection
    Given the employee has a report in "rejected" state
    When the employee creates a new expense report
    Then a new, independent report is created in "draft" state

  @QAIA-US-004-013 @AC1 @P3 @assumption @low-confidence @crud
  # condition: EXP-1
  # assumption: draft-delete is a CRUD reflex not stated by the source; safe default is "allowed" for the owner
  Scenario: Employee deletes their own draft report before submission
    Given the report is in "draft" state and owned by the employee
    When the employee deletes the report
    Then the report no longer exists and no approval record is created for it
