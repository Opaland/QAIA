> US-005 | source: state/US-005/03-design.md, conditions AC4-C1..AC4-C4, AC4-C6
Feature: NSF fee on a failed repayment

  @QAIA-US-005-018 @AC4 @P3 @decision-table
  # condition: AC4-C1
  Scenario: Staff applies an NSF fee to a repayment that failed after being recorded
    Given a loan whose repayment of 300.00 was recorded and has since failed (non-sufficient funds)
    When staff applies an NSF fee of 25.00
    Then the outstanding balance increases by 25.00

  @QAIA-US-005-019 @AC4 @P2 @negative @decision-table
  # condition: AC4-C2
  Scenario: Applying an NSF fee to a repayment that did not fail is refused
    Given a loan with outstanding balance 700.00 and a repayment of 300.00 that was successfully applied and never failed
    When staff attempts to apply an NSF fee against that repayment
    Then the fee application is refused because the repayment did not fail
    And the outstanding balance remains 700.00, unchanged by the refused attempt

  @QAIA-US-005-020 @AC4 @P1 @negative @error-guessing @assumption @low-confidence
  # condition: AC4-C3
  # assumption: source never states whether a second fee may be applied to the same failure; assumed refused
  Scenario: A second NSF fee on the same failed repayment is refused
    Given a loan with outstanding balance 725.00, a failed repayment that already has an NSF fee of 25.00 applied to it
    When staff attempts to apply a second NSF fee to the same failed repayment
    Then the second fee application is refused
    And the outstanding balance remains 725.00, unchanged by the refused attempt

  @QAIA-US-005-021 @AC4 @P1 @decision-table @open @low-confidence
  # condition: AC4-C4
  # open: Q5 (does the failed repayment's own reduction stay counted, or is it backed out?) -- proposed default: it remains counted
  Scenario: The failed repayment's own reduction stays applied when the fee is added
    Given a loan disbursed 1000.00 with a repayment of 300.00 recorded, leaving a balance of 700.00, and that repayment has since failed
    When staff applies an NSF fee of 25.00
    Then the outstanding balance is 725.00
    And the failed repayment's reduction of the balance is not reversed by the failure itself

  @QAIA-US-005-022 @AC4 @P1 @error-guessing @open @low-confidence
  # condition: AC4-C6
  # open: Q6 (the fee amount's determination is a project-configuration question) -- no fabricated literal asserted
  Scenario: The exact NSF fee amount is not asserted as a specific figure
    Given a loan with an outstanding balance of 700.00 and a failed repayment on it
    When staff applies an NSF fee
    Then the outstanding balance is greater than 700.00
    And the precise fee amount is determined by project configuration, not asserted here
