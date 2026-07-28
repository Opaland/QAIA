> US-004 | source: US → AC6 → 03-design.md conditions AC6-C1..C6
Feature: Non-EUR expense line conversion

  Background:
    Given an employee editing a draft expense report

  @QAIA-US-004-037 @AC6 @P1 @ep
  # condition: AC6-C1
  Scenario: EUR line item is not converted
    Given a line item of €80.00
    When the report total is computed
    Then the line contributes €80.00 to the total with no conversion applied

  @QAIA-US-004-038 @AC6 @P1 @ep @low-confidence
  # condition: AC6-C2
  # open: Q8 — rate source is not stated; no fabricated precise literal is asserted here
  Scenario: Non-EUR line item is converted at the expense-date rate
    Given a line item of 100 USD dated on a business day with a published USD-to-EUR rate
    When the report total is computed
    Then the line contributes an EUR amount computed using that expense date's exchange rate, not a different date's rate

  @QAIA-US-004-039 @AC6 @P2 @boundary
  # condition: AC6-C3
  Scenario: Converted total, not the original-currency amount, drives the approval tier
    Given a non-EUR line item whose original-currency amount would sit in the single-approval tier but whose EUR-converted amount exceeds €500
    When the approval chain is computed
    Then the chain is selected using the converted EUR total, requiring manager then finance

  @QAIA-US-004-040 @AC6 @P3 @error-guessing @low-confidence
  # condition: AC6-C4
  # open: Q8 — no published rate on the expense date; proposed default is the prior business day's rate
  Scenario: Non-EUR line dated on a weekend with no published rate falls back to the prior business day's rate
    Given a line item in a foreign currency dated on a weekend with no published rate for that date
    When the report total is computed
    Then the line is converted using the most recent prior business day's published rate

  @QAIA-US-004-041 @AC6 @P2 @metamorphic
  # condition: AC6-C5
  Scenario Outline: Doubling a non-EUR line's original amount doubles its converted contribution
    Given a line item of <original> USD dated on a business day with a published USD-to-EUR rate
    And a second, otherwise identical report with a line item of <doubled> USD on the same date
    When the report totals are computed for both
    Then the second report's converted contribution from that line is twice the first's

    Examples:
      | original | doubled |
      | 50       | 100     |

  @QAIA-US-004-042 @AC6 @P2 @negative @error-guessing @low-confidence @assumption
  # condition: AC6-C6
  # assumption: unsupported currency handling is not stated by the source; safe default is refusal
  Scenario: Line item in an unsupported or invalid currency code is blocked
    Given a line item with a currency code that is not EUR and not a recognized supported currency
    When the employee submits the report
    Then submission is blocked with an explanatory message about the unsupported currency
