# ACs targeted: AC1..AC8, all covered including both positive and required-negative paths
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

  @QAIA-US-001-005 @AC3 @P1 @negative
  Scenario: A 4th upcoming appointment is refused
    Given the patient already has 3 upcoming teleconsultation appointments
    When the patient attempts to book a 4th slot
    Then the booking is refused with a "maximum appointments reached" message

  @QAIA-US-001-006 @AC4 @P1 @negative
  Scenario: Second patient is informed when a slot is taken concurrently
    Given two patients attempt to book the same slot at the same time
    When both booking requests are processed
    Then the first request is confirmed and the second patient is informed the slot is gone

  @QAIA-US-001-007 @AC5 @P2
  Scenario: Confirmation contains practitioner, time and connection link
    Given a patient books a slot with Dr. Martin at 14:00 patient-local time
    When the booking is confirmed
    Then the confirmation shows the practitioner's name "Dr. Martin", the date/time "14:00", and a connection link

  @QAIA-US-001-008 @AC6 @P2
  Scenario: Cancelling more than 4 hours before the appointment succeeds
    Given an upcoming appointment starting in 6 hours
    When the patient cancels the appointment
    Then the appointment is removed from the patient's upcoming appointments

  @QAIA-US-001-009 @AC6 @P1 @negative
  Scenario: Cancelling less than 4 hours before the appointment is refused
    Given an upcoming appointment starting in 2 hours
    When the patient attempts to cancel the appointment
    Then the cancellation is refused with an explanatory message

  @QAIA-US-001-010 @AC7 @P2
  Scenario: Minor books with an authorized practitioner and guardian is notified
    Given a patient flagged as a minor selects a practitioner authorized for minors
    When the booking is confirmed
    Then the confirmation is sent to the patient and to the legal guardian's contact on file

  @QAIA-US-001-011 @AC7 @P3 @negative
  Scenario: Minor cannot book with a practitioner not authorized for minors
    Given a patient flagged as a minor selects a practitioner not authorized for minors
    When the patient attempts to book the slot
    Then the booking is refused with a "practitioner not authorized for minors" message

  @QAIA-US-001-012 @AC8 @P3
  Scenario: Booking is recorded in the audit trail
    Given a patient books a slot
    When the booking is confirmed
    Then an audit entry is recorded with the patient, the action "book", and the timestamp

  @QAIA-US-001-013 @AC8 @P3
  Scenario: Cancellation is recorded in the audit trail
    Given a patient cancels an appointment
    When the cancellation is confirmed
    Then an audit entry is recorded with the patient, the action "cancel", and the timestamp
