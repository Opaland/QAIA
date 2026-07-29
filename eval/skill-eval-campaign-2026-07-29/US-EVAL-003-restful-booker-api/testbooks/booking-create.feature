# US-EVAL-003 | source: state/US-EVAL-003/03-design.md, conditions AC1-C1..AC-DT-1 (P1+P2 scope)
# Target: Restful-Booker-Platform booking microservice, POST /booking/ (self-hostable via Docker,
# per docs/DEMO-TARGETS.md -- primary-source grounded from mwinteringham/restful-booker-platform
# `booking` service Java source, not a blog summary)
Feature: Booking creation enforces field validation, date-range validity and room-conflict rules

  @QAIA-US-EVAL-003-001 @AC1 @P2 @ep
  # condition: AC1-C1
  Scenario: A well-formed booking with no room conflict is created
    Given a booking payload for an existing, unbooked room with roomid 1, firstname "Leo", lastname "Doe", depositpaid true, and a one-night stay from 2027-03-10 to 2027-03-11
    When the client submits it via "POST /booking/"
    Then the response status is 201
    And the response body contains an assigned "bookingid"
    And the response body's "booking" object echoes the submitted roomid, firstname, lastname, depositpaid and bookingdates

  @QAIA-US-EVAL-003-002 @AC1 @P1 @ep @low-confidence
  # condition: AC1-C5
  # assumption: Q1 -- the booking service's own source only enforces roomid >= 1, with no call
  # to the platform's separate room service to confirm the room exists. Proposed default
  # generated below (existence not checked): human arbitration required before this is trusted.
  Scenario: A booking for a syntactically valid but unconfirmed roomid is still created (proposed default, unconfirmed)
    Given a booking payload otherwise identical to a well-formed booking, but with roomid 999999
    When the client submits it via "POST /booking/"
    Then the response status is 201
    And the response body's "booking" object echoes roomid 999999

  @QAIA-US-EVAL-003-003 @AC2 @P2 @negative @boundary
  # condition: AC2-C1, AC2-C2, AC2-C3, AC2-C5, AC2-C6
  Scenario Outline: A field-shape boundary violation is rejected
    Given a booking payload otherwise well-formed, except its "<field>" is set to "<value>"
    When the client submits it via "POST /booking/"
    Then the response status is 400
    And the response body's "fieldErrors" names "<field>"

    Examples:
      | field     | value                                | note                            |
      | roomid    | 0                                     | below the minimum of 1          |
      | firstname | Jo                                    | 2 chars, below the minimum of 3 |
      | firstname | AAAAAAAAAAAAAAAAAAA                   | 19 chars, above the maximum of 18 |
      | lastname  | Wu                                    | 2 chars, below the minimum of 3 |
      | lastname  | AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA       | 31 chars, above the maximum of 30 |

  @QAIA-US-EVAL-003-004 @AC2 @P2 @negative @ep
  # condition: AC2-C8
  Scenario: A booking missing the depositpaid field is rejected
    Given a booking payload otherwise well-formed, with the "depositpaid" field omitted entirely
    When the client submits it via "POST /booking/"
    Then the response status is 400
    And the response body's "fieldErrors" names "depositpaid"

  @QAIA-US-EVAL-003-005 @AC2 @P2 @negative @ep
  # condition: AC2-C9
  Scenario: A booking missing the bookingdates field is rejected
    Given a booking payload otherwise well-formed, with the "bookingdates" field omitted entirely
    When the client submits it via "POST /booking/"
    Then the response status is 400
    And the response body's "fieldErrors" names "bookingdates"

  @QAIA-US-EVAL-003-006 @AC3 @P1 @negative @boundary
  # condition: AC3-C1
  Scenario: A same-day (0-night) stay is rejected as an invalid date range
    Given a booking payload otherwise well-formed, with checkin 2027-03-10 and checkout 2027-03-10
    When the client submits it via "POST /booking/"
    Then the response status is 409

  @QAIA-US-EVAL-003-007 @AC3 @P1 @negative @boundary
  # condition: AC3-C2
  Scenario: A checkout date before checkin is rejected as an invalid date range
    Given a booking payload otherwise well-formed, with checkin 2027-03-11 and checkout 2027-03-10
    When the client submits it via "POST /booking/"
    Then the response status is 409

  @QAIA-US-EVAL-003-008 @AC4 @P1 @negative @decision-table
  # condition: AC4-C1
  Scenario: A booking overlapping an existing booking on the same room is rejected as a conflict
    Given an existing booking for roomid 2 from 2027-04-01 to 2027-04-05
    When the client submits a new booking for roomid 2 with overlapping dates from 2027-04-03 to 2027-04-06 via "POST /booking/"
    Then the response status is 409

  @QAIA-US-EVAL-003-009 @AC2 @AC3 @P1 @negative @decision-table @low-confidence
  # condition: AC-DT-1
  # open: Q3 -- whether a field-shape violation or an invalid date range wins the response status
  # when both apply to the same request is not stated in Booking.java/BookingController.java
  # itself (it follows from standard Spring MVC @Valid-before-controller-body semantics, not a
  # literal line in this service's own source). Proposed default generated below (field-shape
  # wins): human arbitration required before this is trusted.
  Scenario: A request with both a blank firstname and an invalid date range returns the field-validation status, not the conflict status (proposed default, unconfirmed)
    Given a booking payload with firstname "" (blank) and checkin 2027-03-10 equal to checkout 2027-03-10
    When the client submits it via "POST /booking/"
    Then the response status is 400
    And the response status is not 409
