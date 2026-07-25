Feature: Approval chain routing (amount tier, self-approval, currency conversion)
  As an employee and as an approver
  I want the approval chain to match the report's amount, currency and submitter
  So that the right people sign off and no one approves their own report

  Background:
    Given the report is in state "submitted"

  # AC2 x AC3 x AC6 — unified cross-cutting decision table (istqb-design merge,
  # applied after the persona objected to treating AC2/AC3/AC6 as independent techniques)

  @QAIA-US004-010 @AC2 @P2 @decision-table
  # condition: AC2-C1 / AC2-C3 / AC2-C5
  Scenario Outline: The approval chain matches the report's amount tier
    Given a report totalling "<amount>" in EUR submitted by a non-manager employee
    When the required approval chain for this report is determined
    Then it requires exactly "<chain>"

    Examples:
      | amount     | chain                              |
      | €120.00    | manager                             |
      | €2,500.00  | manager, finance                    |
      | €6,000.00  | manager, finance, director          |

  @QAIA-US004-011 @AC2 @P1 @boundary @decision-table
  # condition: AC2-C2 / AC2-C4 — decision: Q1 (both tier boundaries are inclusive of the higher tier: exactly €500.00 needs finance, exactly €5000.00 needs a director)
  Scenario Outline: An amount exactly at a tier boundary falls into the higher tier
    Given a report totalling "<amount>" in EUR submitted by a non-manager employee
    When the required approval chain for this report is determined
    Then it requires exactly "<chain>"

    Examples:
      | amount     | chain                              |
      | €500.00    | manager, finance                    |
      | €5,000.00  | manager, finance, director          |

  @QAIA-US004-012 @AC2 @AC3 @P1 @decision-table
  # condition: AC2-C6 — decision: Q2 ("skip to the next level up" means skip only the submitter's own manager sign-off; every other approval level the amount requires still applies)
  Scenario: A manager's own report above the top threshold skips only the manager step
    Given a report totalling "€7,300.00" in EUR submitted by "Manager B", who is themselves a manager
    When the required approval chain for this report is determined
    Then it requires exactly "finance, director"
    And "Manager B" is not in the chain

  @QAIA-US004-013 @AC2 @AC6 @P2 @decision-table
  # condition: AC2-C8 (AC2 x AC6 interaction — added when istqb-design merged the three ACs into one decision table)
  Scenario: A foreign-currency amount that converts across a tier boundary uses the converted chain
    Given a report with a single line of "$540.00" dated on a day the USD/EUR rate converts it to "€498.50", and a second line of "$5.00" converting to "€4.60", totalling "€503.10" once converted
    When the required approval chain for this report is determined
    Then it requires exactly "manager, finance"
    And the chain is based on the converted EUR total, not the original currency total

  @QAIA-US004-014 @AC2 @AC6 @P2 @low-confidence @decision-table
  # condition: AC2-C9 — decision: Q4 (no FX rate exists for a weekend/holiday expense date -> use the previous business day's closing rate; which FX source is used is separately flagged open for Finance) — priority corrected P1 -> P2 by the persona (fallback always resolves; the residual risk is a slightly-off rate, not a blocked or mis-routed report)
  Scenario: An expense dated on a non-trading day is converted using the previous business day's rate
    Given a line item of "$100.00" dated on a Saturday, when the most recent trading day before it is the preceding Friday
    When the line's EUR-converted amount is computed
    Then it uses the Friday closing USD/EUR rate
    # open: Q4b (which FX rate source/provider — ECB reference rate proposed, not confirmed by the source)

  @QAIA-US004-015 @AC3 @P1 @negative @decision-table
  # condition: AC3-C1 [req-neg]
  Scenario: An approver cannot approve their own submitted report
    Given a report submitted by "Employee A" is awaiting manager approval
    When "Employee A" attempts to approve their own report at the manager step
    Then the approval is refused

  @QAIA-US004-016 @AC3 @P2 @low-confidence @decision-table
  # condition: AC3-C2 [assumption] — extension of AC3's stated rule (only "manager" is named in the source) to the finance role, since the same self-approval principle plausibly applies to every approval level, not only the first one
  Scenario: A finance employee's own report skips only the finance step (proposed extension)
    Given a report totalling "€6,300.00" submitted by an employee who holds the finance role, requiring manager, finance and director approval
    When the required approval chain for this report is determined
    Then it requires exactly "manager, director"
    And the finance employee is not asked to approve their own finance-level review
