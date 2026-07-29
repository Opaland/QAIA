> US-005 | source: state/US-005/03-design.md, conditions AC5-C1..AC5-C6
Feature: Refund against a loan with prior repayments

  @QAIA-US-005-023 @AC5 @P2 @decision-table
  # condition: AC5-C1
  Scenario: A refund reduces the balance in addition to a prior repayment
    Given a loan disbursed 1000.00 with a repayment of 300.00 already applied, leaving a balance of 700.00
    When staff issues a refund of 50.00
    Then the outstanding balance is 650.00

  @QAIA-US-005-024 @AC5 @P2 @negative @decision-table
  # condition: AC5-C2
  Scenario: A refund against a loan with no repayments is refused
    Given a loan disbursed 1000.00 with no repayments ever applied, its balance still 1000.00
    When staff attempts to issue a refund of 50.00
    Then the refund is refused because the loan has received no repayment
    And the outstanding balance remains 1000.00, unchanged by the refused attempt

  @QAIA-US-005-025 @AC5 @P1 @negative @boundary @open @low-confidence
  # condition: AC5-C3
  # open: Q9 (upper bound on refund amount) -- proposed default: may not exceed net repayments received
  Scenario: A refund exceeding the net repayments received is refused
    Given a loan disbursed 1000.00 with net repayments received of 300.00, leaving a balance of 700.00
    When staff attempts to issue a refund of 350.00
    Then the refund is refused because it exceeds the net repayments received
    And the outstanding balance remains 700.00, unchanged by the refused attempt

  @QAIA-US-005-026 @AC5 @P3 @state-transition
  # condition: AC5-C4
  Scenario: Reversing a refund restores the balance to its value immediately before it
    Given a loan disbursed 1000.00 with a repayment of 300.00 and a refund of 50.00 both applied, leaving a balance of 650.00
    When that refund is reversed
    Then the outstanding balance is restored to 700.00

  @QAIA-US-005-027 @AC5 @P2 @negative @error-guessing
  # condition: AC5-C5
  Scenario: Reversing the same refund a second time is refused
    Given a loan with outstanding balance 700.00 whose refund of 50.00 has already been reversed once
    When staff attempts to reverse that same refund again
    Then the second reversal is refused because the refund was already reversed
    And the outstanding balance remains 700.00, unchanged by the refused attempt

  @QAIA-US-005-028 @AC5 @P1 @negative @decision-table @open @low-confidence
  # condition: AC5-C6
  # open: Q8 (does the refund prerequisite survive a later reversal of its qualifying repayment?) -- proposed default: no, refund is refused
  Scenario: A refund is refused once its qualifying repayment has been reversed
    Given a loan disbursed 1000.00 whose sole repayment of 300.00 has since been reversed, leaving a balance of 1000.00 and net repayments received at 0.00
    When staff attempts to issue a refund of 50.00 against that loan
    Then the refund is refused because the loan currently has no net repayments received
    And the outstanding balance remains 1000.00, unchanged by the refused attempt
