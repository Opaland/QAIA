> US-004 | source: systematic-expansion reflex (istqb-design 3c) — 03-design.md conditions EXP-2, EXP-3
Feature: Server-side authorization enforcement on approval actions

  @QAIA-US-004-049 @AC3 @P1 @negative @error-guessing @assumption @low-confidence
  # condition: EXP-2
  # assumption: source names no role model; safe default for a sensitive action is deny-by-default
  Scenario: A non-approver cannot approve another employee's report
    Given a report pending manager approval, and a user who is not that report's manager, finance, or director
    When that user attempts to approve the report
    Then the approval is refused because the user does not hold the required role for this report

  @QAIA-US-004-050 @AC3 @P1 @negative @error-guessing @assumption @low-confidence
  # condition: EXP-3
  # assumption: source names no auth model; safe default for a sensitive action is deny-by-default, enforced server-side
  Scenario: An unauthenticated request cannot submit or approve a report
    Given a report pending submission or approval, and a request carrying no valid session/credentials
    When that unauthenticated request attempts to submit or approve the report, bypassing the UI
    Then the request is refused server-side regardless of the UI it did not go through
