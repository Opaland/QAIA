Feature: Expense report lifecycle (states, terminal rules, re-entrance)
  As an employee
  I want my expense report to move through a controlled review lifecycle
  So that reimbursement follows the right chain and stays auditable

  Background:
    Given an employee "Employee A" who is not a manager
    And an expense report belonging to "Employee A"

  # AC1 — draft -> submitted
  @QAIA-US004-001 @AC1 @P2 @state-transition
  # condition: AC1-C1
  Scenario: A complete draft report can be submitted
    Given the report is in state "draft" with all required line items complete
    When "Employee A" submits the report
    Then the report moves to state "submitted"
    And the transition records who submitted it and when

  # AC1 — review outcomes (partitions of the same "review decision" behavior)
  @QAIA-US004-002 @AC1 @P2 @state-transition
  # condition: AC1-C2 / AC1-C3 / AC1-C4
  Scenario Outline: A submitted report resolves per the reviewer's decision
    Given the report is in state "submitted"
    When the required approver reviews it and decides "<decision>"
    Then the report moves to state "<resulting_state>"

    Examples:
      | decision         | resulting_state    |
      | approve          | approved            |
      | reject           | rejected            |
      | request changes  | changes-requested   |

  # AC1 — changes-requested loops back to draft and can be re-submitted
  @QAIA-US004-003 @AC1 @P2 @state-transition
  # condition: AC1-C5 / AC1-C6
  Scenario: A changes-requested report returns to draft and can be re-submitted
    Given the report is in state "changes-requested" with a recorded reviewer comment
    When "Employee A" edits the report and re-submits it
    Then the report moves to state "submitted"
    And the approval chain re-evaluates from the manager step

  # AC1 — forbidden transitions
  @QAIA-US004-004 @AC1 @P1 @negative @state-transition
  # condition: AC1-C7 [req-neg]
  Scenario: A draft report cannot move directly to approved, skipping submission
    Given the report is in state "draft"
    When an attempt is made to set the report directly to state "approved"
    Then the transition is refused as invalid

  @QAIA-US004-005 @AC1 @AC7 @P1 @negative @state-transition
  # condition: AC1-C8 [req-neg]
  Scenario: A rejected report cannot be edited
    Given the report is in state "rejected"
    When "Employee A" attempts to edit a line item on the report
    Then the edit is refused because the report is terminal

  @QAIA-US004-006 @AC1 @AC7 @P1 @negative @state-transition
  # condition: AC1-C9 [req-neg]
  Scenario: A rejected report cannot be re-submitted
    Given the report is in state "rejected"
    When "Employee A" attempts to re-submit the report
    Then the re-submission is refused because the report is terminal
    And "Employee A" is told to create a new report instead

  # AC1 — re-entrance (a state machine's own reflex check)
  @QAIA-US004-007 @AC1 @P2 @state-transition
  # condition: AC1-C10
  Scenario: A report can go through changes-requested more than once
    Given the report has already completed one changes-requested -> draft -> re-submitted cycle
    When the newly re-submitted report is reviewed again and the reviewer decides "request changes"
    Then the report moves to state "changes-requested" for a second correction round
    And both rounds remain visible in the report's history

  # AC1 — approved terminality (Q9, [assumption], not objected)
  @QAIA-US004-008 @AC1 @P3 @low-confidence @negative @state-transition
  # condition: AC1-C11 [assumption] — open: Q9 (the source does not state whether "approved" is terminal like "rejected"; proposed default: yes, no reversal mechanism is described)
  Scenario: An approved report cannot be further edited (proposed default)
    Given the report is in state "approved"
    When "Employee A" attempts to edit a line item on the report
    Then the edit is refused because the report is terminal

  # AC1 x AC7 — second-cycle rejection (added at the final synthesis validation,
  # to prove the Q3 answer actually shipped as a scenario, not just as a decision)
  @QAIA-US004-009 @AC1 @AC7 @P2 @state-transition
  # condition: AC1-C12 — decision: Q3 (a changes-requested -> draft -> re-submitted report is not a protected state; it follows the ordinary AC2 chain and any approver in that chain can still reject it, per AC7)
  Scenario: A report rejected on its second submission cycle is terminal, same as a first-cycle rejection
    Given the report has already completed one changes-requested -> draft -> re-submitted cycle
    And it is again in state "submitted"
    When the required approver reviews it and decides "reject"
    Then the report moves to state "rejected"
    And it cannot be edited or re-submitted, identically to a report rejected on its first cycle

  # Journey (use-case technique, excluded from atomicity/ratio accounting)
  @QAIA-US004-034 @smoke @use-case
  Scenario: End-to-end — a report is corrected once, then approved through the full chain
    Given "Employee A" drafts a report totalling "€6,200.00" with all receipts attached
    When "Employee A" submits the report
    Then the report requires manager, finance and director approval in that order
    When the manager requests changes citing a missing category on one line
    Then the report returns to draft
    When "Employee A" fixes the line and re-submits
    Then the report goes back through manager, finance and director approval
    When each required approver approves it in turn
    Then the report reaches state "approved"
