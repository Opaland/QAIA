> US-004 | source: US → AC2, AC3 → 03-design.md conditions AC2-C1..C7, AC3-C1..C4
Feature: Amount-tiered approval chain and self-approval prevention

  Background:
    Given an employee with a submitted expense report in EUR

  @QAIA-US-004-014 @AC2 @P1 @boundary
  # condition: AC2-C1
  Scenario: Report just under 500 euros requires only the manager
    Given the report total is €499.99
    When the approval chain is computed
    Then only the employee's direct manager is required to approve

  @QAIA-US-004-015 @AC2 @P2 @boundary @low-confidence
  # condition: AC2-C2
  # open: Q1 — exact-boundary tier ownership is not stated by the source
  Scenario: Report of exactly 500 euros requires manager then finance
    Given the report total is €500.00
    When the approval chain is computed
    Then the employee's direct manager and finance are both required to approve, in that order

  @QAIA-US-004-016 @AC2 @P2 @boundary
  # condition: AC2-C3
  Scenario: Report just above 500 euros requires manager then finance
    Given the report total is €500.01
    When the approval chain is computed
    Then the employee's direct manager and finance are both required to approve, in that order

  @QAIA-US-004-017 @AC2 @P2 @boundary
  # condition: AC2-C4
  Scenario: Report just under 5000 euros requires manager then finance
    Given the report total is €4999.99
    When the approval chain is computed
    Then the employee's direct manager and finance are both required to approve, in that order

  @QAIA-US-004-018 @AC2 @P2 @boundary @low-confidence
  # condition: AC2-C5
  # open: Q1 — exact-boundary tier ownership is not stated by the source
  Scenario: Report of exactly 5000 euros requires manager then finance
    Given the report total is €5000.00
    When the approval chain is computed
    Then the employee's direct manager and finance are both required to approve, in that order

  @QAIA-US-004-019 @AC2 @P1 @boundary
  # condition: AC2-C6
  Scenario: Report just above 5000 euros requires manager finance and director
    Given the report total is €5000.01
    When the approval chain is computed
    Then the employee's direct manager, finance, and a director are all required to approve, in that order

  @QAIA-US-004-020 @AC2 @P2 @decision-table
  # condition: AC2-C7
  Scenario: Ordinary employee's approval chain is not shortened
    Given the submitter is a regular employee who is not a manager, finance, or director
    When the approval chain is computed for a report requiring manager and finance
    Then both the manager and finance levels remain required, unshortened

  @QAIA-US-004-021 @AC3 @P1 @negative @decision-table
  # condition: AC3-C1
  Scenario: An approver cannot approve their own report
    Given the report's submitter and the current pending approver are the same person
    When that person attempts to approve the report
    Then the approval is refused because the approver is the submitter

  @QAIA-US-004-022 @AC3 @P2 @domain-analysis @low-confidence
  # condition: AC3-C2
  # open: Q3 — manager-submitter under the single-approval tier has no level above manager stated by the source
  Scenario: Manager submits their own report under the single-approval tier
    Given the submitter is themselves a manager and the report total is €499.99
    When the approval chain is computed
    Then the manager level is skipped for this submitter, per the proposed default routing to the next available level

  @QAIA-US-004-023 @AC3 @P2 @domain-analysis @low-confidence
  # condition: AC3-C3
  # open: Q2 — "skip to next level up" scope beyond the manager step is not stated by the source
  Scenario: Manager submits their own report above 5000 euros
    Given the submitter is themselves a manager and the report total is €5000.01
    When the approval chain is computed
    Then the manager level is skipped for this submitter, and finance then director remain required

  @QAIA-US-004-024 @AC3 @P1 @negative @decision-table
  # condition: AC3-C4
  Scenario: A manager cannot approve at the level skipped on their own behalf
    Given the submitter is a manager whose own manager-level was skipped on their own report
    When that manager attempts to approve their own report at the skipped level
    Then the approval is refused because the approver is the submitter
