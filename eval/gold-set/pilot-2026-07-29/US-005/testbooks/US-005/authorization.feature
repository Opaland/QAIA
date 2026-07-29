> US-005 | source: state/US-005/03-design.md, conditions AC3-C5, AC4-C5, AC5-C7 (systematic-expansion 3c reflex)
Feature: Staff-only enforcement on reversal, fee, and refund actions

  @QAIA-US-005-033 @AC3 @P1 @negative @error-guessing @assumption @low-confidence
  # condition: AC3-C5
  # assumption: source names only "staff" as the reversal actor; non-staff/unauthenticated is assumed refused, enforced server-side
  Scenario: A non-staff actor cannot reverse a repayment
    Given a loan disbursed 1000.00 with a repayment of 300.00 applied, leaving a balance of 700.00
    When a non-staff, unauthenticated actor attempts to reverse that repayment, bypassing the UI directly
    Then the reversal is refused because the actor does not hold the required staff role
    And the outstanding balance remains 700.00, unchanged by the refused attempt

  @QAIA-US-005-034 @AC4 @P1 @negative @error-guessing @assumption @low-confidence
  # condition: AC4-C5
  # assumption: source names only "staff" as the fee-application actor; non-staff/unauthenticated is assumed refused, enforced server-side
  Scenario: A non-staff actor cannot apply an NSF fee
    Given a loan with outstanding balance 700.00 and a failed repayment recorded on it
    When a non-staff, unauthenticated actor attempts to apply an NSF fee, bypassing the UI directly
    Then the fee application is refused because the actor does not hold the required staff role
    And the outstanding balance remains 700.00, unchanged by the refused attempt

  @QAIA-US-005-035 @AC5 @P1 @negative @error-guessing @assumption @low-confidence
  # condition: AC5-C7
  # assumption: source names only "staff" as the refund actor; non-staff/unauthenticated is assumed refused, enforced server-side
  Scenario: A non-staff actor cannot issue a refund
    Given a loan disbursed 1000.00 with a repayment of 300.00 applied, leaving a balance of 700.00
    When a non-staff, unauthenticated actor attempts to issue a refund of 50.00, bypassing the UI directly
    Then the refund is refused because the actor does not hold the required staff role
    And the outstanding balance remains 700.00, unchanged by the refused attempt
