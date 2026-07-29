Feature: Configure a payment-required enrolment method
  # US-007 (course manager configures paid access). AC1.

  Background:
    Given a course "Intro to Statistics"
    And a course manager is managing that course
    And a payment account "Institute Payments" is available with at least one enabled payment method

  @QAIA-US-007-001 @AC1 @P3 @ep
  Scenario: Manager adds a payment-required method with valid fee and currency
    When the manager adds a "payment required" enrolment method with fee amount "49.00" and currency "EUR" on the payment account "Institute Payments"
    Then the enrolment method is created and active on the course
    # condition: AC1-C1

  @QAIA-US-007-002 @AC1 @P1 @negative @boundary
  Scenario: Manager cannot set a fee amount of zero
    When the manager attempts to add a "payment required" enrolment method with fee amount "0.00" and currency "EUR"
    Then the configuration is rejected with a validation error stating the fee must be greater than zero
    # condition: AC1-C2
    # rule: BR-KB-002

  @QAIA-US-007-003 @AC1 @P1 @negative @boundary
  Scenario: Manager cannot set a negative fee amount
    When the manager attempts to add a "payment required" enrolment method with fee amount "-5.00" and currency "EUR"
    Then the configuration is rejected with a validation error stating the fee must be greater than zero
    # condition: AC1-C3
    # rule: BR-KB-002

  @QAIA-US-007-004 @AC1 @P1 @negative @ep @oracle:iso4217
  Scenario: Manager cannot set an invalid currency code
    When the manager attempts to add a "payment required" enrolment method with fee amount "49.00" and currency "XXX"
    Then the configuration is rejected with a validation error stating the currency code is invalid
    # condition: AC1-C4
    # oracle: iso4217 XXX (ISO 4217 reserved "no currency" code, not assignable to a method)

  @QAIA-US-007-005 @AC1 @P2 @boundary @oracle:iso4217
  Scenario Outline: Fee amount precision respects the configured currency's minor units
    When the manager adds a "payment required" enrolment method with fee amount "<amount>" and currency "<currency>"
    Then the configuration is <outcome>
    # condition: AC1-C5
    # oracle: iso4217 minor-unit rule (JPY has 0 minor units, EUR has 2)

    Examples:
      | amount | currency | outcome                                                              |
      | 500    | JPY      | accepted                                                             |
      | 500.50 | JPY      | rejected with a validation error stating JPY allows no decimal places |
      | 49.99  | EUR      | accepted                                                             |

  @QAIA-US-007-006 @AC1 @P2 @negative @ep
  Scenario: Manager cannot add the method without selecting a payment account
    When the manager attempts to add a "payment required" enrolment method with fee amount "49.00" and currency "EUR" and no payment account selected
    Then the configuration is rejected with a validation error stating a payment account is required
    # condition: AC1-C6

  @QAIA-US-007-007 @AC1 @P3 @low-confidence @crud
  Scenario: Manager adds a second independent payment-required method to the same course
    When the manager adds a second "payment required" enrolment method with fee amount "99.00" and currency "USD" to the same course
    Then both payment-required methods exist independently on the course, each with its own fee and currency
    # condition: AC1-C7
    # assumption: Q4

  @QAIA-US-007-008 @AC1 @P1 @negative @decision-table
  Scenario: A non-manager cannot configure a payment-required enrolment method
    When a user without course-management permission attempts to add a "payment required" enrolment method
    Then the action is denied with a permission error and no method is created
    # condition: AC1-C8

  @QAIA-US-007-009 @AC1 @P3 @low-confidence @crud
  Scenario: Manager updates the fee amount of an existing payment-required method
    When the manager edits the existing payment-required method's fee amount from "49.00" to "59.00"
    Then the method's configured fee amount is "59.00"
    # condition: AC1-C9
    # assumption

  @QAIA-US-007-010 @AC1 @P2 @low-confidence @crud
  Scenario: Manager removes the payment-required method from the course
    When the manager removes the payment-required enrolment method from the course
    Then the course no longer requires payment through that method
    # condition: AC1-C10
    # assumption
