> US-005 | source: state/US-005/03-design.md, conditions AC3-C1..AC3-C4, AC3-C6
Feature: Repayment reversal restores the balance to its pre-repayment value

  @QAIA-US-005-013 @AC3 @P2 @state-transition
  # condition: AC3-C1
  Scenario: Reversing a repayment restores the balance to its value immediately before it
    Given a loan disbursed 1000.00 with a repayment of 300.00 applied, leaving a balance of 700.00
    When that repayment is reversed
    Then the outstanding balance is restored to 1000.00

  @QAIA-US-005-014 @AC3 @P1 @state-transition
  # condition: AC3-C2
  Scenario: Reversing the repayment that fully repaid a loan reopens it
    Given a loan fully repaid by a repayment of 500.00, with an outstanding balance of 0.00
    When that repayment is reversed
    Then the outstanding balance is restored to 500.00
    And the loan is no longer fully repaid

  @QAIA-US-005-015 @AC3 @P2 @negative @error-guessing
  # condition: AC3-C3
  Scenario: Reversing the same repayment a second time is refused
    Given a loan disbursed 1000.00 whose repayment of 300.00 has already been reversed once, leaving a balance of 1000.00
    When staff attempts to reverse that same repayment again
    Then the reversal is refused because the repayment was already reversed
    And the outstanding balance remains 1000.00, unchanged by the refused attempt

  @QAIA-US-005-016 @AC3 @P2 @negative @error-guessing
  # condition: AC3-C4
  Scenario: Reversing a repayment that does not exist on the loan is refused
    Given a loan disbursed 1000.00 with no repayment matching a given repayment reference
    When staff attempts to reverse that non-existent repayment
    Then the reversal is refused because no such repayment exists on this loan
    And the outstanding balance remains 1000.00, unchanged by the refused attempt

  @QAIA-US-005-017 @AC3 @P1 @state-transition
  # condition: AC3-C6
  # rule: BR-KB-001
  Scenario: Reversing an earlier repayment leaves other still-active transactions unaffected
    Given a loan disbursed 1000.00 with a repayment of 300.00 applied and a later refund of 50.00 applied, leaving a balance of 650.00
    When the repayment of 300.00 is reversed
    Then the outstanding balance is 950.00
    And the refund of 50.00 remains applied and unaffected
