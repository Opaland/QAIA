# US-EVAL-011 | source: state/US-EVAL-011/03-design.md, conditions AC1-C3, AC2-C1..AC2-C3, AC3-C1..AC3-C3
# (AC1-C1, AC1-C2 deferred, P3, default scope — see coverage-matrix.md / synthesis.md waiver note)
# Target: QuickPizza (grafana/quickpizza), POST {BASE_URL}/api/pizza, per README.md and pkg/http/http.go
Feature: QuickPizza pizza recommendation stays correct, validated and within its own published performance envelope

  @QAIA-US-EVAL-011-001 @AC1 @P1 @negative @ep @open @low-confidence
  # condition: AC1-C3
  # open: Q1 -- whether POST /api/pizza requires authentication is not confirmed by any source
  # (README summary says no auth requirements are mentioned; every fetched k6 example script sends
  # an Authorization header anyway). Proposed default generated below (accepted, not refused):
  # human arbitration required before this is trusted. NOTE: because the proposed default is
  # "accepted", this scenario's own outcome is a success, not a refusal -- it is intentionally NOT
  # tagged @negative-outcome in its Then, even though the underlying condition was flagged
  # [req-neg] at design time as an auth-boundary probe (see synthesis.md for this distinction).
  Scenario: A pizza recommendation request without an Authorization header is not rejected outright (proposed default, unconfirmed)
    Given a caller with a valid, fully-specified Restrictions object
    And no Authorization header is supplied
    When the caller requests a pizza recommendation
    Then the request is not rejected solely for missing authentication

  @QAIA-US-EVAL-011-002 @AC2 @P1 @boundary
  # condition: AC2-C1
  # assumption: Q2 -- the threshold (p95<500ms) is the project's own worked k6 example
  # (k6/foundations/05.thresholds.js) against this same endpoint, adopted as the working target;
  # not confirmed as an official contractual SLO by any separate source.
  Scenario: The 95th percentile response time stays under the project's own published threshold under sustained concurrent load
    Given a sustained concurrent load of requests against the pizza recommendation endpoint
    And each request carries a valid, fully-specified Restrictions object
    When the load run completes
    Then the 95th percentile response time is under 500 milliseconds

  @QAIA-US-EVAL-011-003 @AC2 @P1 @boundary
  # condition: AC2-C2
  # assumption: Q2 -- same basis as AC2-C1, the p99 tail-latency threshold from
  # k6/foundations/05.thresholds.js.
  Scenario: The 99th percentile response time stays under the project's own published threshold under sustained concurrent load
    Given a sustained concurrent load of requests against the pizza recommendation endpoint
    And each request carries a valid, fully-specified Restrictions object
    When the load run completes
    Then the 99th percentile response time is under 1000 milliseconds

  @QAIA-US-EVAL-011-004 @AC2 @P1 @boundary
  # condition: AC2-C3
  # assumption: Q2 -- same basis as AC2-C1/AC2-C2, the error-rate threshold from
  # k6/foundations/05.thresholds.js. NOTE: flagged [req-neg] at design time (a rule that can fail),
  # but its Then asserts a positive "stays within bound" outcome, not a refusal -- correctly NOT
  # tagged @negative per this skill's own closed @negative definition (see synthesis.md).
  Scenario: The HTTP error rate stays under the project's own published threshold under sustained concurrent load
    Given a sustained concurrent load of requests against the pizza recommendation endpoint
    And each request carries a valid, fully-specified Restrictions object
    When the load run completes
    Then the HTTP error rate across the run is under 1 percent

  @QAIA-US-EVAL-011-005 @AC3 @P2 @negative @domain-analysis @low-confidence
  # condition: AC3-C1
  # assumption: Q4 -- minNumberOfToppings greater than maxNumberOfToppings is refused; a silent
  # auto-swap is also plausible and not ruled out by any source.
  Scenario: A recommendation request with minNumberOfToppings greater than maxNumberOfToppings is refused
    Given a caller with a Restrictions object where minNumberOfToppings exceeds maxNumberOfToppings
    When the caller requests a pizza recommendation
    Then the recommendation request is refused
    And no recommendation is returned

  @QAIA-US-EVAL-011-006 @AC3 @P2 @negative @ep @low-confidence
  # condition: AC3-C2
  # assumption: Q5 -- a negative maxCaloriesPerSlice is refused rather than silently clamped.
  Scenario: A recommendation request with a negative maxCaloriesPerSlice is refused
    Given a caller with a Restrictions object where maxCaloriesPerSlice is negative
    When the caller requests a pizza recommendation
    Then the recommendation request is refused
    And no recommendation is returned

  @QAIA-US-EVAL-011-007 @AC3 @P1 @negative @ep @open @low-confidence
  # condition: AC3-C3
  # open: Q6 -- whether an over-length customName is refused or silently truncated is unconfirmed,
  # and MaxPizzaNameLength's own numeric value was never quoted by any source; this scenario uses
  # a large probe value (10000 characters) as a stand-in for the real, unknown boundary. Proposed
  # default generated below (refused): human arbitration required before this is trusted.
  Scenario: A recommendation request with a far-over-length customName is refused (proposed default, unconfirmed boundary)
    Given a caller with a Restrictions object whose customName is far longer than any plausible limit
    When the caller requests a pizza recommendation
    Then the recommendation request is refused
    And no recommendation is returned
