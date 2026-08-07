# Regression scenario produced by qaia-playwright:contract-probe, 2026-08-01.
# Target: examples/expense-demo (self-hosted, in-repo -- authorization basis (a)).
# Contract archived in ../contract-probe-2026-08-01/contract-source.md.
Feature: ExpenseFlow keeps its documented line-item and total guarantees under adversarial input

  @QAIA-CP-001 @negative @error-guessing
  # contract: AC4 "Each line item must have a category, an amount, and a date"
  #           (eval/gold-set/US-004-expense-approval.md, Acceptance criteria, line 17)
  # contract: AC2 "the converted total drives the approval threshold"
  #           (same file, line 15, via AC6 line 19)
  # Observed 2026-08-01, reproduced 3/3: an amount beyond IEEE-754 double range parses as
  # Infinity and serialises back to null. The line is accepted into `submitted` with a null
  # amount and a null total -- while a literal null amount is correctly refused with 422 by
  # the same validator. The report then sits in the approval workflow with no total to
  # compare against the EUR500/EUR5000 thresholds.
  Scenario: A line amount beyond the representable numeric range is refused at submission
    Given a draft expense report owned by the submitter
    And the report has one line with category "meal", date within the last 90 days and amount "1e309"
    When the submitter submits the report
    Then the submission is refused with a message naming the invalid amount
    And the report stays in state "draft"
    And no report is recorded with a null line amount or a null converted total
