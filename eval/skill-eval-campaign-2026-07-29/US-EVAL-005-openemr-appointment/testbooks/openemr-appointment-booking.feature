# US-EVAL-005 | source: state/US-EVAL-005/03-design.md, conditions AC1-C1..AC3-C6 (AC3-C2 deferred, P3, default scope)
# Target: OpenEMR Standard API, POST {base}/appointment (base = https://{your-openemr-host}/apis/{site}/api), per Documentation/api/STANDARD_API.md
Feature: OpenEMR appointment booking creates a scheduling event for an authenticated caller

  @QAIA-US-EVAL-005-001 @AC1 @P2 @ep
  # condition: AC1-C1
  Scenario: A valid appointment request is created for an authenticated caller
    Given an authenticated caller with a valid access token
    And an existing patient, facility and appointment category
    When the caller creates an appointment with valid category, title, duration, a future date and a well-formed start time
    Then the appointment is created and returned in the response data

  @QAIA-US-EVAL-005-002 @AC1 @P2 @negative @boundary @low-confidence
  # condition: AC1-C2
  # assumption: Q5 -- a zero or negative duration is refused; the exact accepted floor is not
  # confirmed by any source.
  Scenario Outline: A non-positive duration is refused when creating an appointment
    Given an authenticated caller with a valid access token
    And an existing patient, facility and appointment category
    When the caller creates an appointment with duration <duration> seconds
    Then the appointment creation is refused
    And no appointment is created

    Examples:
      | duration |
      | 0        |
      | -1       |

  @QAIA-US-EVAL-005-003 @AC1 @P2 @negative @boundary @low-confidence
  # condition: AC1-C3
  # assumption: Q4 -- an appointment dated in the past is refused; not confirmed by any source
  # (a legitimate backfill use case may exist, hence low-confidence).
  Scenario: An appointment dated in the past is refused
    Given an authenticated caller with a valid access token
    And an existing patient, facility and appointment category
    When the caller creates an appointment with an event date before today
    Then the appointment creation is refused
    And no appointment is created

  @QAIA-US-EVAL-005-004 @AC1 @P1 @negative @decision-table @low-confidence
  # condition: AC1-C4
  # open: Q1 -- whether an appointment overlapping an existing one for the same facility and time
  # window is refused is not confirmed by any source. Proposed default generated below (refused):
  # human arbitration required before this is trusted (real EHR practice often allows intentional
  # overbooking).
  Scenario: An appointment overlapping an existing appointment for the same facility is refused (proposed default, unconfirmed)
    Given an authenticated caller with a valid access token
    And an existing appointment for a facility on a given date and time
    When the caller creates a new appointment for the same facility overlapping that date and time
    Then the appointment creation is refused
    And no appointment is created

  @QAIA-US-EVAL-005-005 @AC2 @P1 @negative @decision-table
  # condition: AC2-C1
  Scenario: An unauthenticated appointment creation attempt is refused
    Given no Authorization header is supplied
    And an existing patient, facility and appointment category
    When an appointment creation is attempted without authentication
    Then the appointment creation is refused
    And no appointment is created

  @QAIA-US-EVAL-005-006 @AC2 @P1 @negative @decision-table @low-confidence
  # condition: AC2-C2
  # assumption: Q7 -- an expired or revoked Bearer token is refused; standard OAuth2 behavior
  # assumed, not independently confirmed for this endpoint.
  Scenario: An appointment creation attempt with an expired or revoked token is refused
    Given a caller presenting an expired or revoked Bearer token
    And an existing patient, facility and appointment category
    When the caller attempts to create an appointment
    Then the appointment creation is refused
    And no appointment is created

  @QAIA-US-EVAL-005-007 @AC2 @P1 @negative @decision-table @low-confidence
  # condition: AC2-C3
  # open: Q6 -- whether a caller authenticated for one site/facility scope can create an
  # appointment for a patient outside that scope is not confirmed by any source. Proposed default
  # generated below (refused): human arbitration required before this is trusted.
  Scenario: An appointment creation for a patient outside the caller's authorized scope is refused (proposed default, unconfirmed)
    Given an authenticated caller with a valid access token scoped to one site
    And an existing patient belonging to a different, out-of-scope site
    When the caller attempts to create an appointment for that out-of-scope patient
    Then the appointment creation is refused
    And no appointment is created

  @QAIA-US-EVAL-005-008 @AC2 @P1 @negative @decision-table @low-confidence
  # condition: AC2-C4
  # open: Q9 -- when a request is both unauthenticated and structurally invalid, which check
  # determines the response and whether validation detail is disclosed to an unauthenticated
  # caller is not confirmed by any source. Proposed default generated below (authentication
  # failure wins, no validation detail disclosed): human arbitration required.
  Scenario: An unauthenticated request with a missing required field is refused without disclosing validation detail (proposed default, unconfirmed)
    Given no Authorization header is supplied
    And the request body omits a required field
    When an appointment creation is attempted
    Then the appointment creation is refused as an authentication failure
    And no field-validation detail about the missing field is disclosed

  @QAIA-US-EVAL-005-009 @AC3 @P2 @negative @ep
  # condition: AC3-C3
  # assumption: Q3 -- a nonexistent pc_facility is refused via validationErrors; not confirmed by
  # any source.
  Scenario: An appointment creation referencing a nonexistent facility is refused
    Given an authenticated caller with a valid access token
    And an existing patient and appointment category
    When the caller creates an appointment referencing a facility id that does not exist
    Then the appointment creation is refused with a validation error
    And no appointment is created

  @QAIA-US-EVAL-005-010 @AC3 @P2 @negative @ep
  # condition: AC3-C4
  # assumption: Q2 -- a well-formed pid with no matching patient record is refused via
  # validationErrors; not confirmed by any source.
  Scenario: An appointment creation referencing a nonexistent patient is refused
    Given an authenticated caller with a valid access token
    And an existing facility and appointment category
    When the caller creates an appointment referencing a patient id that does not exist
    Then the appointment creation is refused with a validation error
    And no appointment is created

  @QAIA-US-EVAL-005-011 @AC3 @P2 @negative @ep @oracle:iso8601
  # condition: AC3-C5
  # oracle: iso8601 pc_eventDate format -- ISO 8601 invalid-corpus cases (non-existent calendar
  # day, out-of-range month).
  Scenario Outline: An appointment creation with a malformed event date is refused
    Given an authenticated caller with a valid access token
    And an existing patient, facility and appointment category
    When the caller creates an appointment with event date "<event_date>"
    Then the appointment creation is refused with a validation error
    And no appointment is created

    Examples:
      | event_date |
      | 2024-02-30 |
      | 2024-13-01 |

  @QAIA-US-EVAL-005-012 @AC3 @P2 @negative @ep @oracle:iso8601
  # condition: AC3-C6
  # oracle: iso8601 pc_startTime format -- ISO 8601 invalid-corpus cases (out-of-range hour,
  # out-of-range minute).
  Scenario Outline: An appointment creation with a malformed start time is refused
    Given an authenticated caller with a valid access token
    And an existing patient, facility and appointment category
    When the caller creates an appointment with start time "<start_time>"
    Then the appointment creation is refused with a validation error
    And no appointment is created

    Examples:
      | start_time |
      | 25:00:00   |
      | 12:75:00   |
