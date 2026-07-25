Feature: Book a teleconsultation appointment
  As a registered patient
  I want to book a teleconsultation slot with a practitioner of a chosen specialty
  So that I can get a consultation without traveling to the clinic

  Background:
    Given the platform has practitioner "Dr. Alia Novak" registered under specialty "Cardiology"
    And the platform has practitioner "Dr. Ben Osei" registered under specialty "Dermatology"

  # AC1 — specialty filter
  @QAIA-US001-001 @AC1 @P2 @ep
  # condition: AC1-C1
  Scenario: Slots matching the selected specialty are shown
    Given "Dr. Alia Novak" has an open slot on "2026-08-01 10:00"
    When a patient filters available slots by specialty "Cardiology"
    Then the slot with "Dr. Alia Novak" on "2026-08-01 10:00" is listed

  @QAIA-US001-002 @AC1 @P2 @ep
  # condition: AC1-C2
  Scenario: Slots of a non-matching specialty are excluded
    Given "Dr. Ben Osei" has an open slot on "2026-08-01 11:00"
    When a patient filters available slots by specialty "Cardiology"
    Then the slot with "Dr. Ben Osei" is not listed

  @QAIA-US001-003 @AC1 @P1 @negative @error-guessing
  # condition: AC1-C3 [req-neg]
  Scenario: Unauthenticated access to the slot list is refused
    Given no patient is signed in
    When a request is made to list available slots for specialty "Cardiology"
    Then the request is refused with an authentication-required error

  # AC2 — 2-hour booking threshold
  @QAIA-US001-004 @AC2 @P1 @boundary
  # condition: AC2-C1
  Scenario Outline: A slot is bookable when it starts at least 2 hours from now
    Given "Dr. Alia Novak" has an open slot starting in <lead_time> from now
    When a patient books that slot
    Then the booking is confirmed

    Examples:
      | lead_time |
      | 2 hours   |
      | 2 hours 1 minute |

  @QAIA-US001-005 @AC2 @P1 @negative @boundary
  # condition: AC2-C2 [req-neg]
  Scenario: Booking is refused for a slot starting in less than 2 hours
    Given "Dr. Alia Novak" has an open slot starting in 1 hour 59 minutes from now
    When a patient books that slot
    Then the booking is refused with a message stating the slot is too soon

  @QAIA-US001-006 @AC2 @P3 @low-confidence @ep
  # condition: AC2-C3 [assumption] — open: Q1 (which timezone: patient's or practitioner's? not specified in the source)
  Scenario: The 2-hour threshold is evaluated against the patient's local time (proposed default)
    Given a patient whose local timezone is "UTC-5" and "Dr. Alia Novak" whose local timezone is "UTC+1"
    And "Dr. Alia Novak" has an open slot starting in 1 hour 45 minutes of the patient's local time
    When the patient attempts to book that slot
    Then the booking is refused, because in the patient's local time the slot starts in less than 2 hours

  # AC3 — max 3 upcoming appointments
  @QAIA-US001-007 @AC3 @P2 @boundary
  # condition: AC3-C1
  Scenario Outline: A patient below the appointment limit can book another
    Given a patient with <upcoming_count> upcoming teleconsultation appointments
    When the patient books another available slot
    Then the booking is confirmed

    Examples:
      | upcoming_count |
      | 0               |
      | 1               |
      | 2               |

  @QAIA-US001-008 @AC3 @P1 @negative @boundary
  # condition: AC3-C2 [req-neg]
  Scenario: A patient at the appointment limit cannot book a 4th
    Given a patient with 3 upcoming teleconsultation appointments
    When the patient attempts to book another available slot
    Then the booking is refused with a message stating the appointment limit is reached

  @QAIA-US001-009 @AC3 @P3 @low-confidence @ep
  # condition: AC3-C3 [assumption] — open: Q2 (does a cancellation immediately free a slot in the count? not specified)
  Scenario: Cancelling an appointment immediately frees a slot in the upcoming-count (proposed default)
    Given a patient with 3 upcoming teleconsultation appointments
    When the patient cancels one of them more than 4 hours before its start
    Then the patient can immediately book another available slot

  # AC4 — slot exclusivity and race condition
  @QAIA-US001-010 @AC4 @P1 @ep
  # condition: AC4-C1
  Scenario: A booked slot immediately becomes unavailable to other patients
    Given "Dr. Alia Novak" has an open slot on "2026-08-01 10:00"
    And a patient books that slot
    When a second patient views "Dr. Alia Novak"'s available slots
    Then the slot on "2026-08-01 10:00" is no longer listed as available

  @QAIA-US001-011 @AC4 @P1 @negative @error-guessing
  # condition: AC4-C2 [req-neg]
  Scenario: The losing patient in a concurrent booking attempt is informed the slot is gone
    Given "Dr. Alia Novak" has an open slot on "2026-08-01 10:00"
    And two patients submit a booking for that same slot at the same time
    When the first booking is confirmed
    Then the second patient's booking is refused with a message stating the slot is no longer available

  @QAIA-US001-012 @AC4 @P1 @negative @error-guessing
  # condition: AC4-C3 [req-neg]
  Scenario: A direct API request cannot book a slot that is already taken (UI-bypass)
    Given "Dr. Alia Novak" has a slot on "2026-08-01 10:00" already booked by another patient
    When a patient sends a booking request for that slot directly to the API
    Then the request is refused with a message stating the slot is no longer available

  # AC5 — confirmation content
  @QAIA-US001-013 @AC5 @P1 @ep
  # condition: AC5-C1
  Scenario: A successful booking produces a complete confirmation
    Given a patient whose local timezone is "UTC-5"
    And "Dr. Alia Novak" has an open slot on "2026-08-01 10:00 UTC"
    When the patient books that slot
    Then the confirmation shows the practitioner name "Dr. Alia Novak"
    And the confirmation shows the date and time converted to the patient's local timezone
    And the confirmation includes a connection link

  # AC7 — minors
  @QAIA-US001-019 @AC7 @P1 @negative @decision-table
  # condition: AC7-C1 [req-neg]
  Scenario: A minor patient cannot book a practitioner not authorized for minors
    Given a patient flagged as a minor
    And "Dr. Alia Novak" is not authorized to consult minors
    When the minor patient attempts to book a slot with "Dr. Alia Novak"
    Then the booking is refused with a message stating the practitioner is not authorized for minors

  @QAIA-US001-020 @AC7 @P1 @decision-table
  # condition: AC7-C2
  Scenario: A minor patient can book an authorized practitioner and the guardian is notified
    Given a patient flagged as a minor with a guardian contact on file
    And "Dr. Ben Osei" is authorized to consult minors
    When the minor patient books a slot with "Dr. Ben Osei"
    Then the booking is confirmed
    And the confirmation is also sent to the guardian's contact on file

  @QAIA-US001-021 @AC7 @P2 @low-confidence @error-guessing
  # condition: AC7-C3 [assumption] — open: Q4 (no guardian contact on file — not specified)
  Scenario: Booking for a minor without a guardian contact on file is blocked (proposed default)
    Given a patient flagged as a minor with no guardian contact on file
    And "Dr. Ben Osei" is authorized to consult minors
    When the minor patient attempts to book a slot with "Dr. Ben Osei"
    Then the booking is refused with a message requesting a guardian contact before booking

  # AC8 — audit trail (booking)
  @QAIA-US001-022 @AC8 @P2 @ep
  # condition: AC8-C1
  Scenario: A booking event is recorded in the audit trail
    Given a patient books a slot with "Dr. Alia Novak"
    When the audit trail for that appointment is inspected
    Then it contains an entry recording who booked it, what was booked, and when

  # Journey (use-case technique, excluded from atomicity/ratio accounting)
  @QAIA-US001-024 @smoke @use-case
  Scenario: End-to-end — a patient books and later cancels a teleconsultation within policy
    Given a patient filters available slots by specialty "Cardiology"
    And selects a slot with "Dr. Alia Novak" starting in 3 days
    When the patient books that slot
    Then the booking is confirmed with a connection link
    When the patient cancels that appointment more than 4 hours before its start
    Then the cancellation is confirmed and the slot becomes available again
