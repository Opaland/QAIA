Feature: Cancel a teleconsultation appointment
  As a registered patient
  I want to cancel an upcoming teleconsultation appointment within the allowed window
  So that I free my slot and the practitioner's when I can no longer attend

  Background:
    Given the platform has practitioner "Dr. Alia Novak" registered under specialty "Cardiology"

  # AC6 — cancellation window
  @QAIA-US001-014 @AC6 @P2 @boundary
  # condition: AC6-C1
  Scenario Outline: Cancellation is allowed at or before the 4-hour threshold
    Given a patient has an upcoming appointment with "Dr. Alia Novak" starting in <lead_time> from now
    When the patient cancels that appointment
    Then the cancellation is confirmed

    Examples:
      | lead_time |
      | 4 hours   |
      | 5 hours   |

  @QAIA-US001-015 @AC6 @P1 @negative @boundary
  # condition: AC6-C2 [req-neg]
  Scenario: Cancellation is refused inside the 4-hour window
    Given a patient has an upcoming appointment with "Dr. Alia Novak" starting in 3 hours 59 minutes from now
    When the patient attempts to cancel that appointment
    Then the cancellation is refused with a message stating the cancellation window has passed

  @QAIA-US001-016 @AC6 @P1 @negative @error-guessing
  # condition: AC6-C3 [req-neg]
  Scenario: A patient cannot cancel another patient's appointment
    Given patient "A" has an upcoming appointment with "Dr. Alia Novak"
    And patient "B" is signed in
    When patient "B" attempts to cancel patient "A"'s appointment
    Then the request is refused with an authorization error

  @QAIA-US001-017 @AC6 @P2 @negative @error-guessing
  # condition: AC6-C4 [req-neg]
  Scenario: An unauthenticated cancellation attempt is refused
    Given a patient has an upcoming appointment with "Dr. Alia Novak"
    And no patient is signed in
    When a request is made to cancel that appointment
    Then the request is refused with an authentication-required error

  @QAIA-US001-018 @AC6 @AC2 @P3 @low-confidence @error-guessing
  # condition: AC6-C5 [assumption] — open: Q3 (cross-AC: is a slot freed by a legal on-time cancellation, but now < 2h from start, rebookable by someone else? not specified)
  Scenario: A slot freed by an on-time cancellation with less than 2 hours remaining stays unbookable (proposed default)
    Given a patient has an upcoming appointment with "Dr. Alia Novak" starting in 4 hours 5 minutes from now
    And the patient cancels it, leaving the slot with 1 hour 55 minutes remaining before its original start
    When another patient attempts to book that freed slot
    Then the booking is refused, consistent with the 2-hour minimum lead time rule

  # AC8 — audit trail (cancellation)
  @QAIA-US001-023 @AC8 @P2 @ep
  # condition: AC8-C2
  Scenario: A cancellation event is recorded in the audit trail
    Given a patient cancels an upcoming appointment with "Dr. Alia Novak"
    When the audit trail for that appointment is inspected
    Then it contains an entry recording who cancelled it, what was cancelled, and when
