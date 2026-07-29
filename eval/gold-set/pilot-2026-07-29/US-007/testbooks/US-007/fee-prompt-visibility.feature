Feature: Fee prompt gates content, for both logged-in students and guests
  # US-007. AC2 (logged-in student) and AC4 (anonymous guest).

  Background:
    Given a course "Intro to Statistics" requires payment via a "payment required" enrolment method
    And the configured fee amount is "49.00" in currency "EUR"

  @QAIA-US-007-011 @AC2 @P1 @ep
  Scenario: A logged-in, not-yet-enrolled student sees the fee prompt before any content
    Given a logged-in student who is not enrolled in the course
    When the student visits the course
    Then the student sees a prompt stating payment is required showing the fee amount "49.00 EUR"
    And no course content is shown
    # condition: AC2-C1

  @QAIA-US-007-012 @AC2 @P3 @ep
  Scenario: The displayed fee amount matches the configured amount exactly
    Given a logged-in student who is not enrolled in the course
    When the student visits the course
    Then the fee amount shown is exactly "49.00 EUR", the configured value
    # condition: AC2-C2

  @QAIA-US-007-013 @AC2 @P3 @state-transition
  Scenario: An already-enrolled student sees course content directly
    Given a logged-in student already enrolled in the course through another enrolment method
    When the student visits the course
    Then the course content is shown directly with no fee prompt
    # condition: AC2-C3
    # answered: Q5

  @QAIA-US-007-014 @AC2 @P1 @negative @error-guessing
  Scenario: A not-yet-enrolled student cannot reach course content by a direct request
    Given a logged-in student who is not enrolled in the course
    When the student requests a course content page directly, bypassing the fee prompt
    Then the request is blocked server-side and no course content is returned
    # condition: AC2-C4

  @QAIA-US-007-015 @AC4 @P3 @ep
  Scenario: An anonymous guest sees the same fee-required messaging as a logged-in student
    Given an anonymous guest, not logged in
    When the guest visits the course
    Then the guest sees the same fee-required messaging showing the fee amount "49.00 EUR"
    # condition: AC4-C1

  @QAIA-US-007-016 @AC4 @P1 @negative @decision-table
  Scenario: A guest is prompted to log in and never shown payment method selection
    Given an anonymous guest, not logged in
    When the guest visits the course
    Then the guest is prompted to log in
    And the guest is not shown any payment method selection
    # condition: AC4-C2

  @QAIA-US-007-017 @AC4 @P1 @negative @error-guessing
  Scenario: An unauthenticated direct request to the payment action is rejected server-side
    Given an anonymous guest, not logged in
    When an unauthenticated request is sent directly to the course's payment/enrolment action, bypassing the UI
    Then the request is rejected and redirected to authentication, with no payment method exposed
    # condition: AC4-C3

  @QAIA-US-007-018 @AC4 @P3 @low-confidence @ep
  Scenario: A guest resumes the fee prompt for the same course after logging in
    Given an anonymous guest, not logged in, who reached the course's fee prompt
    When the guest logs in
    Then the guest is returned to the fee prompt for the same course, now as a logged-in student
    # condition: AC4-C4
    # assumption: Q6
