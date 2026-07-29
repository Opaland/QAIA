> US-005 | source: state/US-005/03-design.md, conditions AC1-C1..AC1-C6
Feature: Loan disbursement establishes the outstanding balance

  @QAIA-US-005-001 @AC1 @P2 @ep
  # condition: AC1-C1
  Scenario: A single-tranche disbursement sets the outstanding balance to the tranche amount
    Given a new loan for client "C1" with no prior transactions
    When a single tranche of 1000.00 is disbursed
    Then the outstanding balance is 1000.00

  @QAIA-US-005-002 @AC1 @P1 @ep
  # condition: AC1-C2
  Scenario: A second tranche adds to the balance already established by the first
    Given a loan that has already received one tranche of 600.00
    When a second tranche of 400.00 is disbursed
    Then the outstanding balance is 1000.00

  @QAIA-US-005-003 @AC1 @P2 @ep @assumption @low-confidence
  # condition: AC1-C3
  # assumption: no stated cap on the number of tranches; cumulative summation is assumed unbounded
  Scenario: A third tranche continues the cumulative summation with no assumed count cap
    Given a loan that has already received two tranches totaling 900.00
    When a third tranche of 100.00 is disbursed
    Then the outstanding balance is 1000.00

  @QAIA-US-005-004 @AC1 @P1 @negative @boundary @assumption @low-confidence
  # condition: AC1-C4
  # assumption: source never states a minimum tranche amount; a zero-amount disbursement is assumed refused
  Scenario: A zero-amount tranche is refused
    Given a new loan for client "C1" with no prior transactions
    When a tranche of 0.00 is disbursed
    Then the disbursement is refused because a tranche amount must be greater than zero
    And the outstanding balance remains 0.00

  @QAIA-US-005-005 @AC1 @P1 @negative @boundary @assumption @low-confidence
  # condition: AC1-C5
  # assumption: source never states tranche amounts must be positive; a negative tranche is assumed refused
  Scenario: A negative-amount tranche is refused
    Given a new loan for client "C1" with no prior transactions
    When a tranche of -50.00 is disbursed
    Then the disbursement is refused because a tranche amount must be greater than zero
    And the outstanding balance remains 0.00

  @QAIA-US-005-006 @AC1 @P1 @error-guessing @assumption @low-confidence
  # condition: AC1-C6
  # assumption: source never states whether disbursement may occur after servicing activity has begun; assumed allowed, adding on top of the current balance
  Scenario: An additional tranche disbursed after a repayment has already reduced the balance
    Given a loan disbursed 1000.00 and a repayment of 300.00 already applied, leaving a balance of 700.00
    When a further tranche of 200.00 is disbursed
    Then the outstanding balance is 900.00
