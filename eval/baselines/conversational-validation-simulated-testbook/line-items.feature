Feature: Expense line item validation
  As an employee
  I want each expense line checked before submission
  So that only complete, in-window lines reach the approval chain

  Background:
    Given a draft expense report belonging to "Employee A"

  @QAIA-US004-017 @AC4 @P2 @ep
  # condition: AC4-C1
  Scenario: A line dated within the last 90 days is accepted
    Given a line item dated "45 days" before today with a category and an amount
    When "Employee A" submits the report
    Then the line is accepted

  @QAIA-US004-018 @AC4 @P2 @negative @boundary
  # condition: AC4-C2 [req-neg]
  Scenario: A line dated more than 90 days ago is blocked at submission
    Given a line item dated "91 days" before today with a category and an amount
    When "Employee A" submits the report
    Then submission is refused with a message stating the line is outside the 90-day window

  @QAIA-US004-019 @AC4 @P3 @low-confidence @boundary
  # condition: AC4-C3 [assumption] — open: Q5 ("within the last 90 days" is read as inclusive of day 90 exactly; the reference clock is the server's submission date, not the expense date's own timezone — not stated in the source)
  Scenario: A line dated exactly 90 days ago is accepted (proposed default)
    Given a line item dated exactly "90 days" before today with a category and an amount
    When "Employee A" submits the report
    Then the line is accepted

  @QAIA-US004-020 @AC4 @P2 @negative @ep
  # condition: AC4-C4 [req-neg]
  Scenario: A line missing a category is blocked at submission
    Given a line item with an amount and a date but no category
    When "Employee A" submits the report
    Then submission is refused with a message stating the category is required

  @QAIA-US004-021 @AC4 @P3 @low-confidence @negative @boundary
  # condition: AC4-C5 [req-neg][assumption] — the source states a line "must have ... an amount" but does not state a minimum; proposed default: an amount must be strictly greater than €0.00
  Scenario: A line with a zero amount is blocked at submission (proposed default)
    Given a line item with a category, a date within 90 days, and an amount of "€0.00"
    When "Employee A" submits the report
    Then submission is refused with a message stating the amount must be greater than zero

  @QAIA-US004-022 @AC4 @P2 @low-confidence @negative @ep
  # condition: AC4-C6 [assumption] — decision: Q10 (a single invalid line blocks the whole submission; the report is not partially submittable — consistent with "submission is refused" language used for the other AC4/AC5 refusal rules)
  Scenario: One invalid line blocks submission of an otherwise valid report
    Given a report with two valid line items and one line item dated "120 days" before today
    When "Employee A" submits the report
    Then the whole submission is refused, including the two otherwise-valid lines
