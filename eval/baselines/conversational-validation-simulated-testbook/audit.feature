Feature: Audit trail and mandatory review comments
  As a company relying on this workflow for reimbursement
  I want every transition recorded and every rejection/changes-requested explained
  So that the process stays auditable

  # AC8a — audit fields on every transition (split from the source's single AC8
  # during us-review, at the persona's request, to separate the always-on audit-log
  # rule from the conditional comment-validation rule below)

  @QAIA-US004-029 @AC8a @P2 @ep
  # condition: AC8a-C1
  Scenario Outline: Every state transition records who made it and when
    Given a report about to undergo a "<transition>" transition
    When the transition happens
    Then the audit trail gains an entry recording who performed it and when

    Examples:
      | transition                          |
      | draft -> submitted                  |
      | submitted -> approved                |
      | submitted -> rejected                |
      | submitted -> changes-requested       |

  # AC8b — mandatory comment on rejection / changes-requested

  @QAIA-US004-030 @AC8b @P1 @negative @ep
  # condition: AC8b-C2 [req-neg]
  Scenario: Rejecting a report without a comment is blocked
    Given a report in state "submitted" awaiting a director's decision
    When the director attempts to reject it without entering a comment
    Then the rejection is refused, requiring a comment of at least 10 characters

  @QAIA-US004-031 @AC8b @P1 @negative @ep
  # condition: AC8b-C3 [req-neg]
  Scenario: Requesting changes without a comment is blocked
    Given a report in state "submitted" awaiting a manager's decision
    When the manager attempts to request changes without entering a comment
    Then the transition is refused, requiring a comment of at least 10 characters

  @QAIA-US004-032 @AC8b @P2 @boundary
  # condition: AC8b-C4
  Scenario: A rejection comment of exactly 10 characters is accepted
    Given a report in state "submitted" awaiting a director's decision
    When the director rejects it with the comment "Duplicate."
    Then the rejection is recorded with that comment

  @QAIA-US004-033 @AC8b @P2 @negative @boundary
  # condition: AC8b-C5 [req-neg]
  Scenario: A rejection comment of 9 characters is refused
    Given a report in state "submitted" awaiting a director's decision
    When the director attempts to reject it with the comment "Too short"
    Then the rejection is refused, requiring a comment of at least 10 characters
