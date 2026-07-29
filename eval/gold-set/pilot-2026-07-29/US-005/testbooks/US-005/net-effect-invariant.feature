> US-005 | source: state/US-005/03-design.md, conditions AC6-C1..AC6-C4
Feature: Outstanding balance is always the net effect of currently-active transactions

  @QAIA-US-005-029 @AC6 @P1 @domain-analysis
  # condition: AC6-C1
  # rule: BR-KB-001
  Scenario: Reversing a repayment then a refund yields the correct combined net effect
    Given a loan disbursed 1000.00 with a repayment of 300.00 and a later refund of 50.00 both active, leaving a balance of 650.00
    When the repayment is reversed first and the refund is reversed second
    Then the outstanding balance is 1000.00

  @QAIA-US-005-030 @AC6 @P1 @metamorphic
  # condition: AC6-C2
  # rule: BR-KB-001
  Scenario: Reversing the same repayment and refund in the opposite order yields the identical final balance
    Given a loan disbursed 1000.00 with a repayment of 300.00 and a later refund of 50.00 both active, leaving a balance of 650.00
    When the refund is reversed first and the repayment is reversed second
    Then the outstanding balance is 1000.00, identical to reversing them in the opposite order

  @QAIA-US-005-031 @AC6 @P1 @pairwise
  # condition: AC6-C3
  Scenario: The balance reflects only the currently-active transactions among several interleaved ones
    Given a loan disbursed 1000.00, with a first repayment of 300.00 active, a second repayment of 100.00 that was later reversed, and a refund of 50.00 active
    When the outstanding balance is computed
    Then the outstanding balance is 650.00, excluding the reversed second repayment entirely

  @QAIA-US-005-032 @AC6 @P2 @domain-analysis
  # condition: AC6-C4
  # rule: BR-KB-001
  Scenario: Reversing one transaction does not alter an unrelated active transaction's own recorded amount
    Given a loan with an active repayment of 300.00 and an active refund of 50.00, leaving a balance of 650.00
    When the repayment is reversed
    Then the refund's own recorded amount remains 50.00 and still active
    And the outstanding balance is 950.00
