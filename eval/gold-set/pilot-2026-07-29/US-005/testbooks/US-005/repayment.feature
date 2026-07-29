> US-005 | source: state/US-005/03-design.md, conditions AC2-C1..AC2-C6
Feature: Customer repayment reduces the outstanding balance

  @QAIA-US-005-007 @AC2 @P3 @ep
  # condition: AC2-C1
  Scenario: A partial repayment reduces the balance and leaves the loan active
    Given a loan with an outstanding balance of 1000.00
    When a repayment of 400.00 is recorded
    Then the outstanding balance is 600.00
    And the loan is not fully repaid

  @QAIA-US-005-008 @AC2 @P1 @boundary
  # condition: AC2-C2
  Scenario: A repayment equal to the outstanding balance brings it to exactly zero
    Given a loan with an outstanding balance of 500.00
    When a repayment of 500.00 is recorded
    Then the outstanding balance is 0.00
    And the loan is fully repaid

  @QAIA-US-005-009 @AC2 @P2 @boundary
  # condition: AC2-C3
  Scenario: A repayment one cent under the outstanding balance leaves the loan active
    Given a loan with an outstanding balance of 500.00
    When a repayment of 499.99 is recorded
    Then the outstanding balance is 0.01
    And the loan is not fully repaid

  @QAIA-US-005-010 @AC2 @P1 @negative @boundary @open @low-confidence
  # condition: AC2-C4
  # open: Q1 (repayment exceeding the outstanding balance) -- proposed default: refused
  Scenario: A repayment exceeding the outstanding balance is refused
    Given a loan with an outstanding balance of 500.00
    When a repayment of 500.01 is recorded
    Then the repayment is refused because it exceeds the outstanding balance
    And the outstanding balance remains 500.00

  @QAIA-US-005-011 @AC2 @P1 @negative @state-transition @assumption @low-confidence
  # condition: AC2-C5
  # assumption: source never states whether a fully repaid loan can receive further repayments; assumed refused
  Scenario: A repayment attempted on an already fully repaid loan is refused
    Given a loan that is already fully repaid, with an outstanding balance of 0.00
    When a repayment of 100.00 is attempted
    Then the repayment is refused because the loan has no outstanding balance
    And the outstanding balance remains 0.00

  @QAIA-US-005-012 @AC2 @P3 @ep
  # condition: AC2-C6
  Scenario: Two repayments in sequence produce the cumulative reduction of both
    Given a loan with an outstanding balance of 1000.00 and a first repayment of 300.00 already applied, leaving a balance of 700.00
    When a second repayment of 200.00 is recorded
    Then the outstanding balance is 500.00
