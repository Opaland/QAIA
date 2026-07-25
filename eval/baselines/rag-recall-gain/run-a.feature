# Run A — FIT-118, generated WITHOUT a knowledge base.
# 16 scenarios, 9 @negative (56.25% negative ratio). Zero config-driven literals asserted —
# the four flagged gaps (credit cost, cancellation cutoff, no-show consequence, waitlist
# promotion mechanism) are NOT covered here; see run-a-journey.md "Ceiling" section.

Feature: Class booking — confirm, cancel, waitlist (FIT-118, no knowledge base)

  Background:
    Given a studio member "Alex" is signed in
    And a class "Vinyasa Flow" on the schedule with 10 total spots

  @QAIA-FIT-118-001 @AC1 @P1 @ep
  # condition: AC1-C1
  Scenario: Booking an available class confirms the spot
    Given "Vinyasa Flow" has 3 remaining spots
    When Alex books "Vinyasa Flow"
    Then the booking is confirmed
    And "Vinyasa Flow" has 2 remaining spots

  @QAIA-FIT-118-002 @AC1 @P1 @ep
  # condition: AC1-C2
  Scenario: Booking a class deducts membership credits
    Given "Vinyasa Flow" has 3 remaining spots
    And Alex has a positive membership credit balance
    When Alex books "Vinyasa Flow"
    Then Alex's credit balance decreases

  @QAIA-FIT-118-003 @AC1 @P1 @negative @decision-table
  # condition: AC1-C3 [req-neg]
  Scenario: A full class is not offered for direct booking
    Given "Vinyasa Flow" has 0 remaining spots
    When Alex attempts to book "Vinyasa Flow"
    Then the booking is rejected
    And Alex is offered the waitlist instead

  @QAIA-FIT-118-004 @AC1 @P1 @negative @ep
  # condition: AC1-C4 [req-neg]
  Scenario: Booking with an insufficient credit balance is rejected
    Given "Vinyasa Flow" has 3 remaining spots
    And Alex has a credit balance of 0
    When Alex attempts to book "Vinyasa Flow"
    Then the booking is rejected with "insufficient credits"

  @QAIA-FIT-118-005 @AC1 @P1 @negative @error-guessing @low-confidence
  # condition: AC1-C5 [req-neg] [assumption: Q6]
  Scenario: Unauthenticated access to booking is denied
    Given no member is signed in
    When an anonymous visitor attempts to book "Vinyasa Flow"
    Then the request is denied

  @QAIA-FIT-118-006 @AC1 @P2 @negative @error-guessing
  # condition: AC1-C6 [req-neg]
  Scenario: Booking the same class slot twice by the same member is rejected
    Given Alex already has a confirmed booking on "Vinyasa Flow"
    When Alex attempts to book "Vinyasa Flow" again
    Then the booking is rejected as a duplicate

  @QAIA-FIT-118-007 @AC1 @P3 @ep
  # condition: AC1-C7
  Scenario: The class schedule can be filtered by instructor
    Given the schedule lists classes from multiple instructors
    When Alex filters the schedule by instructor "Priya"
    Then only classes taught by "Priya" are shown

  @QAIA-FIT-118-008 @AC1 @P3 @ep
  # condition: AC1-C8
  Scenario: An empty schedule shows an empty state
    Given no classes are scheduled for the selected day
    When Alex views the schedule for that day
    Then an empty-schedule message is shown, not an error

  @QAIA-FIT-118-009 @AC2 @P1 @ep
  # condition: AC2-C1
  Scenario: Cancelling a booking frees the spot
    Given Alex has a confirmed booking on "Vinyasa Flow" with 2 remaining spots
    When Alex cancels the booking
    Then "Vinyasa Flow" has 3 remaining spots

  @QAIA-FIT-118-010 @AC2 @P1 @negative @error-guessing
  # condition: AC2-C2 [req-neg]
  Scenario: Cancelling another member's booking is rejected
    Given a booking on "Vinyasa Flow" belongs to member "Jordan"
    When Alex attempts to cancel Jordan's booking
    Then the request is denied

  @QAIA-FIT-118-011 @AC2 @P2 @negative @state-transition
  # condition: AC2-C3 [req-neg]
  Scenario: Cancelling an already-cancelled booking is rejected
    Given Alex's booking on "Vinyasa Flow" is already cancelled
    When Alex attempts to cancel it again
    Then the request is rejected as already cancelled

  @QAIA-FIT-118-012 @AC2 @P2 @negative @state-transition
  # condition: AC2-C4 [req-neg]
  Scenario: Cancelling a booking after the class occurred is rejected
    Given Alex's booking on "Vinyasa Flow" is for a class that has already taken place
    When Alex attempts to cancel it
    Then the request is rejected as the class has already occurred

  @QAIA-FIT-118-013 @AC3 @P1 @state-transition
  # condition: AC3-C1
  Scenario: Joining the waitlist of a full class succeeds
    Given "Vinyasa Flow" has 0 remaining spots
    When Alex joins the waitlist for "Vinyasa Flow"
    Then Alex is added to the waitlist with a recorded position

  @QAIA-FIT-118-014 @AC3 @P2 @negative @decision-table
  # condition: AC3-C2 [req-neg]
  Scenario: Joining the waitlist of a class that is not full is rejected
    Given "Vinyasa Flow" has 3 remaining spots
    When Alex attempts to join the waitlist for "Vinyasa Flow"
    Then the request is rejected because direct booking is available

  @QAIA-FIT-118-015 @AC3 @P2 @state-transition @low-confidence
  # condition: AC3-C3 [assumption: Q8]
  Scenario: Leaving a waitlist spot succeeds
    Given Alex is on the waitlist for "Vinyasa Flow"
    When Alex leaves the waitlist
    Then Alex is no longer on the waitlist for "Vinyasa Flow"

  @QAIA-FIT-118-016 @AC3 @P2 @negative @error-guessing
  # condition: AC3-C4 [req-neg]
  Scenario: Joining the same waitlist twice is rejected
    Given Alex is already on the waitlist for "Vinyasa Flow"
    When Alex attempts to join the waitlist for "Vinyasa Flow" again
    Then the request is rejected as a duplicate
