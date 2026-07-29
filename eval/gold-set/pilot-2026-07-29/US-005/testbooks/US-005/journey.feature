> US-005 | source: state/US-005/03-design.md, journey scenario (use-case technique, at most one per US)
Feature: End-to-end loan servicing journey

  @QAIA-US-005-036 @smoke @AC1 @AC2 @AC3 @AC4 @AC5 @AC6 @use-case
  # journey: exercises disbursement, repayment, NSF fee, refund and both reversal kinds together;
  # single journey-level Then; excluded from atomicity and negative-ratio accounting (istqb-design/testbook-generate rule)
  Scenario: A loan moves through disbursement, repayment, an NSF fee, and reversed transactions, ending at the correct net balance
    Given a new loan for client "C1" with no prior transactions
    When a first tranche of 700.00 is disbursed
    And a second tranche of 300.00 is disbursed
    And a first repayment of 400.00 is recorded
    And a second repayment of 200.00 is recorded and subsequently fails
    And staff applies an NSF fee of 25.00 for that failed repayment
    And staff issues a refund of 50.00 against the loan's still-active first repayment
    And staff reverses the first repayment of 400.00
    And staff reverses the refund of 50.00
    Then the final outstanding balance is 825.00, equal to the net effect of every currently-active transaction
