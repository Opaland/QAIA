# US-EVAL-010 | source: state/03-design.md, conditions AC2-C1, AC2-C2, AC3-C1, AC3-C2, AC4-C1
# (P1+P2 scope; AC1-C1 is P3, deferred per state/04-priorities.md)
# Target: crAPI (OWASP), Identity microservice, GET /identity/api/v2/vehicle/{vehicleId}/location
# -- Challenge 1 (BOLA), docs/challenges.md, primary source; concrete endpoint path corroborated by
# secondary sources only, see state/00-source.md.
Feature: Vehicle-location endpoint enforces per-owner authorization (BOLA hardening, crAPI Challenge 1)

  @QAIA-US-EVAL-010-001 @AC2 @P1 @decision-table
  # condition: AC2-C1
  Scenario: A cross-owner request never returns another user's vehicle location
    Given user A holds a valid authentication token and user B owns a real vehicle with a known "vehicleId"
    When user A requests "/identity/api/v2/vehicle/{vehicleId}/location" for user B's "vehicleId"
    Then the response body does not contain user B's vehicle's coordinates anywhere in it

  @QAIA-US-EVAL-010-002 @AC2 @P2 @decision-table @low-confidence
  # condition: AC2-C2
  # assumption: Q1 -- the adopted anti-disclosure default is 404 (not 403), per the Triple-AC pass
  # in state/02-understanding.md; the underlying "must not leak" requirement (scenario 001) is not
  # in doubt, only this exact status code.
  Scenario: A cross-owner request is denied with a not-found status, not a leak-confirming status
    Given user A holds a valid authentication token and user B owns a real vehicle with a known "vehicleId"
    When user A requests "/identity/api/v2/vehicle/{vehicleId}/location" for user B's "vehicleId"
    Then the response status is 404

  @QAIA-US-EVAL-010-003 @AC3 @P1 @ep
  # condition: AC3-C1
  Scenario: A request with no authentication token is denied and leaks no location data
    Given a caller holds no authentication token
    When the caller requests "/identity/api/v2/vehicle/{vehicleId}/location" for any existing "vehicleId"
    Then the response status is not 200
    And the response body contains no vehicle location data

  @QAIA-US-EVAL-010-004 @AC3 @P2 @ep
  # condition: AC3-C2
  Scenario: A request with an invalid or expired authentication token is denied and leaks no location data
    Given a caller holds an invalid or expired authentication token
    When the caller requests "/identity/api/v2/vehicle/{vehicleId}/location" for any existing "vehicleId"
    Then the response status is not 200
    And the response body contains no vehicle location data

  @QAIA-US-EVAL-010-005 @AC4 @P2 @error-guessing @low-confidence
  # condition: AC4-C1
  # assumption: Q3 -- a nonexistent vehicleId converges on the same 404 response as scenario 002's
  # cross-owner denial, so the two failure reasons are indistinguishable to the caller.
  Scenario: A syntactically valid but nonexistent vehicleId is denied with the same status as a cross-owner request
    Given an authenticated caller and a syntactically well-formed "vehicleId" that matches no existing vehicle
    When the caller requests "/identity/api/v2/vehicle/{vehicleId}/location" for that nonexistent "vehicleId"
    Then the response status is 404
    And the response body contains no vehicle location data
