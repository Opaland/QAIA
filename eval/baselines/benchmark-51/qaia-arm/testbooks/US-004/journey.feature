> US-004 | source: use-case technique, at most one journey scenario per US (istqb-design) — excluded from atomicity/negative-ratio accounting
Feature: End-to-end expense report journey

  @QAIA-US-004-051 @smoke @use-case
  # journey: covers AC1, AC2 (top tier), AC3 baseline, AC6, AC8 at the journey level only — does not re-verify any atomically-covered behavior
  Scenario: A large non-EUR report is approved through the full manager-finance-director chain
    Given an employee submits an expense report in a foreign currency whose EUR-converted total exceeds €5000, with all line items complete and receipted
    When the report is approved in sequence by the manager, then finance, then a director
    Then the report ends in "approved" state with a complete audit trail of all three approvals
