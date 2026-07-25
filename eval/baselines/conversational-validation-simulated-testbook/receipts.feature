Feature: Receipt requirement for expense lines
  As an employee
  I want to know exactly when a receipt is mandatory
  So that my report is not refused for a missing attachment I didn't know was required

  Background:
    Given a draft expense report belonging to "Employee A" with a valid category and date on every line

  @QAIA-US004-023 @AC5 @P2 @ep
  # condition: AC5-C1
  Scenario: A line under €25 does not require a receipt
    Given a line item of "€18.40" with no receipt attached
    When "Employee A" submits the report
    Then the line is accepted

  @QAIA-US004-024 @AC5 @P1 @negative @boundary
  # condition: AC5-C2 [req-neg] — priority corrected P2 -> P1 by the persona (a missing-receipt control on a reimbursable expense is an audit/anti-fraud control, not a cosmetic gap; the story's own "auditable trail" goal is directly at stake)
  Scenario: A line of €25 or more without a receipt is refused
    Given a line item of "€60.00" with no receipt attached
    When "Employee A" submits the report
    Then submission is refused with a message stating a receipt is required

  @QAIA-US004-025 @AC5 @P1 @negative @boundary
  # condition: AC5-C3 [req-neg] — inherits the same priority correction as AC5-C2 (same underlying control)
  Scenario: A line of exactly €25.00 without a receipt is refused
    Given a line item of "€25.00" with no receipt attached
    When "Employee A" submits the report
    Then submission is refused with a message stating a receipt is required

  @QAIA-US004-026 @AC5 @P2 @boundary
  # condition: AC5-C4
  Scenario: A line of €24.99 without a receipt is accepted
    Given a line item of "€24.99" with no receipt attached
    When "Employee A" submits the report
    Then the line is accepted

  @QAIA-US004-027 @AC5 @P2 @ep
  # condition: AC5-C5
  Scenario: A line of €25 or more with a receipt attached is accepted
    Given a line item of "€60.00" with a receipt attached
    When "Employee A" submits the report
    Then the line is accepted

  @QAIA-US004-028 @AC5 @AC6 @P2 @low-confidence @negative @boundary
  # condition: AC5-C6 [assumption] — decision: Q11 (the €25 receipt threshold is evaluated on the converted EUR amount, for consistency with AC6 driving "the approval threshold of AC2" — extended here by analogy since the source only states this for AC2's threshold)
  Scenario: A foreign-currency line that converts to €25 or more requires a receipt (proposed default)
    Given a line item of "$28.00" dated on a day it converts to "€25.80", with no receipt attached
    When "Employee A" submits the report
    Then submission is refused with a message stating a receipt is required
