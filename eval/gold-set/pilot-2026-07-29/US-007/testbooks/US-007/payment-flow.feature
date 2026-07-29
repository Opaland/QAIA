Feature: Payment method selection, cancellation and completion
  # US-007. AC3, plus the single end-to-end journey scenario (AC1-AC4).

  Background:
    Given a course "Intro to Statistics" requires payment via a "payment required" enrolment method
    And the configured payment account has payment methods "Card Gateway" and "Bank Transfer" enabled
    And a logged-in student who is not enrolled is at the fee prompt

  @QAIA-US-007-019 @AC3 @P3 @ep
  Scenario: Student selects an enabled payment method and proceeds
    When the student selects the payment method "Card Gateway"
    Then the student is taken to the "Card Gateway" payment step
    # condition: AC3-C1

  @QAIA-US-007-020 @AC3 @P2 @ep
  Scenario: Only methods enabled on the account are offered
    When the student views the available payment methods
    Then only "Card Gateway" and "Bank Transfer" are listed, and no other gateway is shown
    # condition: AC3-C2

  @QAIA-US-007-021 @AC3 @P2 @negative @state-transition
  Scenario: Student cancels the payment flow
    When the student cancels the payment flow
    Then the student is not enrolled and is not charged
    # condition: AC3-C3

  @QAIA-US-007-022 @AC3 @P1 @negative @low-confidence @state-transition
  Scenario: A declined payment does not enrol or charge the student
    Given the student selected the payment method "Card Gateway"
    When the payment attempt is declined by the gateway
    Then the student is not enrolled, is not charged, and sees an error with the option to retry
    # condition: AC3-C4
    # assumption: Q2
    # rule: BR-KB-001

  @QAIA-US-007-023 @AC3 @P3 @state-transition
  Scenario: Student cancels and retries the payment prompt more than once
    Given the student cancelled the payment flow once already
    When the student re-opens the fee prompt and cancels again
    Then the student remains not enrolled and not charged after each attempt, with no limit on retries
    # condition: AC3-C5

  @QAIA-US-007-024 @AC3 @P1 @negative @low-confidence @error-guessing
  Scenario: No payment method is enabled on the configured account
    Given the configured payment account has zero enabled payment methods
    When the student reaches the fee prompt
    Then the student sees a message that no payment option is currently available, no content is shown, and no charge occurs
    # condition: AC3-C6
    # assumption: Q9

  @QAIA-US-007-025 @AC3 @P1 @ep
  Scenario: A successful payment enrols and charges the student exactly the configured fee
    Given the student selected the payment method "Card Gateway"
    When the payment succeeds
    Then the student becomes enrolled in the course and is charged exactly "49.00 EUR"
    # condition: AC3-C7

  @QAIA-US-007-031 @AC1 @AC2 @AC3 @AC4 @smoke @use-case
  Scenario: End-to-end paid enrolment journey for an initially anonymous visitor
    Given a course "Intro to Statistics" requires payment via a "payment required" enrolment method configured with fee "49.00 EUR" and payment method "Card Gateway" enabled
    When an anonymous guest visits the course, logs in when prompted, selects "Card Gateway", and completes a successful payment
    Then the student ends the journey enrolled in the course with course content visible
    # journey: AC1-AC4 end-to-end; excluded from atomicity and negative-ratio accounting (istqb-design journey exception)
