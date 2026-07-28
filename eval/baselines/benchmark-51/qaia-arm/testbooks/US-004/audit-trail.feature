> US-004 | source: US → AC8 → 03-design.md conditions AC8-C1..C6
Feature: Audit trail and mandatory transition comments

  Background:
    Given an employee with a submitted expense report

  @QAIA-US-004-043 @AC8 @P1 @ep
  # condition: AC8-C1
  Scenario: Every state transition records who and when
    Given the report is in "submitted" state
    When an approver approves the report
    Then the transition record stores the approver's identity and the transition timestamp

  @QAIA-US-004-044 @AC8 @P1 @negative @boundary
  # condition: AC8-C2
  Scenario: Rejection with a comment shorter than 10 characters is blocked
    Given an approver rejecting the report
    When the approver submits a rejection with a 9-character comment
    Then the rejection is refused with an explanatory message about the minimum comment length

  @QAIA-US-004-045 @AC8 @P2 @boundary
  # condition: AC8-C3
  Scenario: Rejection with a comment of exactly 10 characters is accepted
    Given an approver rejecting the report
    When the approver submits a rejection with a 10-character comment
    Then the rejection is accepted and the comment is recorded

  @QAIA-US-004-046 @AC8 @P1 @negative @boundary
  # condition: AC8-C4
  Scenario: Changes-requested with a comment shorter than 10 characters is blocked
    Given an approver requesting changes on the report
    When the approver submits a changes-requested decision with a 9-character comment
    Then the decision is refused with an explanatory message about the minimum comment length

  @QAIA-US-004-047 @AC8 @P2 @boundary
  # condition: AC8-C5
  Scenario: Changes-requested with a comment of exactly 10 characters is accepted
    Given an approver requesting changes on the report
    When the approver submits a changes-requested decision with a 10-character comment
    Then the decision is accepted and the comment is recorded

  @QAIA-US-004-048 @AC8 @P2 @ep
  # condition: AC8-C6
  Scenario: Approval does not require a comment
    Given an approver approving the report
    When the approver approves the report without supplying any comment
    Then the approval is accepted
