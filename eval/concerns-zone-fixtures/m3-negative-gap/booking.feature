# ACs targeted: AC1..AC8 (all present at least once; AC3 and AC6 negatives missing — see doc)
Feature: Teleconsultation appointment booking

  @QAIA-US-001-001 @AC1 @P2
  Scenario: Patient sees only slots matching the selected specialty
    Given a patient has filtered the slot list by specialty "Dermatology"
    When the slot list is displayed
    Then only slots from practitioners with the "Dermatology" specialty are shown

  @QAIA-US-001-002 @AC2 @P1 @negative
  Scenario: Booking a slot less than 2 hours away is refused
    Given a slot starting in 45 minutes
    When the patient attempts to book the slot
    Then the booking is refused with a "slot too soon" message

  @QAIA-US-001-003 @AC2 @P2
  Scenario: Booking a slot at least 2 hours away succeeds
    Given a slot starting in 3 hours
    When the patient attempts to book the slot
    Then the booking is confirmed

  @QAIA-US-001-004 @AC3 @P2
  Scenario: Patient with fewer than 3 upcoming appointments can book another
    Given the patient already has 2 upcoming teleconsultation appointments
    When the patient books a new slot
    Then the new appointment is added to the patient's upcoming appointments

  @QAIA-US-001-005 @AC4 @P1 @negative
  Scenario: Second patient is informed when a slot is taken concurrently
    Given two patients attempt to book the same slot at the same time
    When both booking requests are processed
    Then the first request is confirmed and the second patient is informed the slot is gone

  @AC5 @P2
  Scenario: Confirmation shows practitioner and time, then persists after a page reload
    Given a patient books a slot with Dr. Martin at 14:00 patient-local time
    When the booking is confirmed
    Then the confirmation shows the practitioner's name "Dr. Martin" and the date/time "14:00"
    When the patient reloads the appointments page
    Then the confirmation is still visible

  @QAIA-US-001-006 @AC6 @P2
  Scenario: Cancelling more than 4 hours before the appointment succeeds
    Given an upcoming appointment starting in 6 hours
    When the patient cancels the appointment
    Then the appointment is removed from the patient's upcoming appointments

  @QAIA-US-001-007 @AC7 @P2 @negative
  Scenario: Minor cannot book with a practitioner not authorized for minors
    Given a patient flagged as a minor selects a practitioner not authorized for minors
    When the patient attempts to book the slot
    Then the booking is refused with a "practitioner not authorized for minors" message

  @AC8 @P3
  Scenario: Booking is recorded in the audit trail
    Given a patient books a slot
    When the booking is confirmed
    Then an audit entry is recorded with the patient, the action "book", and the timestamp

  @AC8 @P3
  Scenario: Cancellation is recorded in the audit trail
    Given a patient cancels an appointment
    When the cancellation is confirmed
    Then an audit entry is recorded with the patient, the action "cancel", and the timestamp
