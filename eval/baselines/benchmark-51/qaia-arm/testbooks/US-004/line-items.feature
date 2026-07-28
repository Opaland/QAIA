> US-004 | source: US → AC4, AC5 → 03-design.md conditions AC4-C1..C7, AC5-C1..C5
Feature: Expense line-item validation and receipt requirements

  Background:
    Given an employee editing a draft expense report

  @QAIA-US-004-025 @AC4 @P1 @negative @ep
  # condition: AC4-C1
  Scenario: Line item missing a category is blocked at submission
    Given a line item with an amount, a date within 90 days, but no category
    When the employee submits the report
    Then submission is blocked with an explanatory message about the missing category

  @QAIA-US-004-026 @AC4 @P1 @negative @ep
  # condition: AC4-C2
  Scenario: Line item missing an amount is blocked at submission
    Given a line item with a category, a date within 90 days, but no amount
    When the employee submits the report
    Then submission is blocked with an explanatory message about the missing amount

  @QAIA-US-004-027 @AC4 @P1 @negative @ep
  # condition: AC4-C3
  Scenario: Line item missing a date is blocked at submission
    Given a line item with a category, an amount, but no date
    When the employee submits the report
    Then submission is blocked with an explanatory message about the missing date

  @QAIA-US-004-028 @AC4 @P2 @boundary
  # condition: AC4-C4
  # assumption: Q6 — reference clock is server-side UTC calendar date at submission time
  Scenario: Line item dated exactly 90 days before submission is accepted
    Given a complete line item dated exactly 90 days before the submission date
    When the employee submits the report
    Then the submission is accepted

  @QAIA-US-004-029 @AC4 @P1 @negative @boundary
  # condition: AC4-C5
  # assumption: Q6 — reference clock is server-side UTC calendar date at submission time
  Scenario: Line item dated 91 days before submission is blocked
    Given a complete line item dated 91 days before the submission date
    When the employee submits the report
    Then submission is blocked with an explanatory message about the date being outside 90 days

  @QAIA-US-004-030 @AC4 @P2 @ep
  # condition: AC4-C6
  Scenario: Line item dated today is accepted
    Given a complete line item dated the same day as submission
    When the employee submits the report
    Then the submission is accepted

  @QAIA-US-004-031 @AC4 @P2 @negative @ep @low-confidence
  # condition: AC4-C7
  # assumption: source is silent on future-dated lines; safe default follows the "recency" intent of AC4
  Scenario: Line item dated in the future is blocked
    Given a complete line item dated one day after the submission date
    When the employee submits the report
    Then submission is blocked with an explanatory message about the invalid future date

  @QAIA-US-004-032 @AC5 @P2 @boundary
  # condition: AC5-C1
  Scenario: Line item under 25 euros does not require a receipt
    Given a line item of €24.99 with no attached receipt
    When the employee submits the report
    Then the submission is accepted

  @QAIA-US-004-033 @AC5 @P1 @boundary
  # condition: AC5-C2
  Scenario: Line item of exactly 25 euros requires a receipt
    Given a line item of €25.00 with no attached receipt
    When the employee submits the report
    Then submission is blocked because a receipt is mandatory at this amount

  @QAIA-US-004-034 @AC5 @P1 @negative @boundary
  # condition: AC5-C3
  Scenario: Line item at or above 25 euros without a receipt is refused
    Given a line item of €40.00 with no attached receipt
    When the employee submits the report
    Then submission is refused with an explanatory message about the missing receipt

  @QAIA-US-004-035 @AC5 @P2 @ep
  # condition: AC5-C4
  Scenario: Line item at or above 25 euros with a receipt is accepted
    Given a line item of €40.00 with a receipt attached
    When the employee submits the report
    Then the submission is accepted

  @QAIA-US-004-036 @AC5 @P2 @negative @boundary @low-confidence
  # condition: AC5-C5
  # open: Q7 — whether the 25-euro threshold applies pre- or post-conversion is not stated by the source
  Scenario: Non-EUR line whose original amount and converted amount fall on opposite sides of 25 euros
    Given a non-EUR line item whose original-currency amount is at or above the receipt threshold but whose EUR-converted amount is not, and no receipt is attached
    When the employee submits the report
    Then submission is refused, per the proposed default of applying the threshold to the original-currency amount
