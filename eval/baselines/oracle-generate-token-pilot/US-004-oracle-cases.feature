# oracle-generate pilot run — US-004 (expense report approval workflow, eval/gold-set).
# AC6 (non-EUR currency conversion) and AC4 (90-day date window) touch standardized domains;
# the ISO 4217 and ISO 8601 oracles supplied the grounded cases below. Every scenario is tagged
# @oracle:<standard> with a # oracle: citation, never presented as a requirement of US-004
# itself. Two scenarios are @low-confidence: the oracle proposes a real edge case, but US-004
# does not resolve what the expected behavior is — flagged as an open question (Q1, Q2), not
# guessed. See US-004-design-conditions.md for the full detect/propose/emit record.

Feature: US-004 expense line items — currency and date conditions grounded in ISO 4217 / ISO 8601

  Background:
    Given an employee is submitting an expense report line item

  @QAIA-EXP-ORC-001 @US-004 @AC6 @P2 @oracle:iso4217
  # oracle: ISO 4217 — valid three-letter currency codes, including the JPY (0 minor units) and
  # BHD (3 minor units) exceptions to the default 2-decimal rule
  Scenario Outline: A line item in a valid non-EUR currency is accepted and converted
    When the employee enters a line item with currency "<currency>" and amount "<amount>"
    Then the currency is accepted and the amount is converted to EUR at the expense date's rate
    Examples:
      | currency | amount |
      | USD      | 120.00 |
      | JPY      | 15000  |
      | BHD      | 42.500 |

  @QAIA-EXP-ORC-002 @US-004 @AC6 @P2 @negative @oracle:iso4217
  # oracle: ISO 4217 — malformed or non-existent currency codes
  Scenario Outline: A line item with an invalid currency code is rejected at submission
    When the employee enters a line item with currency "<currency>" and amount "50.00"
    Then submission is refused with an "invalid currency code" error
    Examples:
      | currency |
      | EU       |
      | EURO     |
      | US$      |
      | XXX      |

  @QAIA-EXP-ORC-003 @US-004 @AC6 @P3 @negative @oracle:iso4217 @low-confidence
  # oracle: ISO 4217 minor-unit rule — JPY has 0 decimal places, BHD has 3 — [open]: US-004 AC6
  # does not say how a fractional-JPY amount, or a BHD amount finer than 3 decimals, is rounded
  # or rejected. Q1: does the system reject, or silently round, an amount that violates its
  # currency's minor-unit precision?
  Scenario Outline: A line item amount with a precision inconsistent with its currency's minor unit
    When the employee enters a line item with currency "<currency>" and amount "<amount>"
    Then the rounding-or-rejection behavior is undefined by US-004 — flagged for arbitration (Q1)
    Examples:
      | currency | amount  |
      | JPY      | 1500.50 |
      | BHD      | 42.5005 |

  @QAIA-EXP-ORC-004 @US-004 @AC4 @P2 @negative @oracle:iso8601
  # oracle: ISO 8601 — calendar-impossible dates (2023 and 2100 are not leap years; April has 30
  # days), distinct from the "outside 90 days" business rule in AC4
  Scenario Outline: A line item with a calendar-impossible date is rejected as malformed, not as out-of-window
    When the employee enters a line item dated "<date>"
    Then submission is refused with an "invalid date" error
    Examples:
      | date       |
      | 2023-02-29 |
      | 2100-02-29 |
      | 2023-04-31 |

  @QAIA-EXP-ORC-005 @US-004 @AC4 @P2 @boundary @oracle:iso8601
  # oracle: ISO 8601 leap day — 2024 is a leap year, so 2024-02-29 is a real, valid calendar date
  Scenario: A line item dated on a leap day within the 90-day window is accepted
    Given today's date is "2024-04-15"
    When the employee enters a line item dated "2024-02-29"
    Then the line item is accepted as within the 90-day window

  @QAIA-EXP-ORC-006 @US-004 @AC4 @P3 @low-confidence @oracle:iso8601
  # oracle: ISO 8601 permits both a date and a date-time-with-offset representation — [open]:
  # AC4 says "a date" but does not say whether a full date-time is accepted for a line item, or
  # which of the date/date-time portions drives the 90-day window. Q2.
  Scenario: A line item date supplied as a full ISO 8601 date-time is submitted
    When the employee enters a line item dated "2026-05-01T23:30:00+02:00"
    Then whether the date or date-time portion drives the 90-day window is undefined by US-004 — flagged for arbitration (Q2)
