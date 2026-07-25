# Minimal excerpt, deliberately built for issue #41 (self-review lint validation).
# Not a real product US — three scenarios, each with a concrete, assertable Then,
# chosen to exercise the three violation classes step 4 must catch.

Feature: Booking cancellation window (fixture for automate's assertion self-review)

  @QAIA-FIXTURE-041-001 @AC6 @P1
  Scenario: cancellation refused less than 4h before start
    Given a patient has booked a slot starting in 3 hours
    When the patient requests cancellation
    Then the system refuses the cancellation and shows "less than 4 hours"

  @QAIA-FIXTURE-041-002 @AC6 @P1
  Scenario: cancel button is enabled once a slot is booked
    Given a patient has booked a slot starting in 26 hours
    When the booking confirmation is displayed
    Then the cancel button is visible and enabled

  @QAIA-FIXTURE-041-003 @AC1 @P2
  Scenario: specialty filter shows only matching practitioners
    Given the practitioner list contains dermatology and cardiology slots
    When the patient filters by "dermatology"
    Then only dermatology slots are displayed
