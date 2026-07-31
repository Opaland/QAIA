# US-EVAL-009 | oracle-generate PROPOSAL, step 3 output — NOT merged into the campaign test book.
# Status: pending-validation (SKILL.md Steps 2 is a human gate: "the oracle *proposes*; the human
# arbitrates" — no human was available in this run, so nothing here is "accepted").
# Oracle: ISO 4217, entry "## ISO 4217 (currency codes)" of
# plugins/qaia-core/skills/oracle-generate/oracles/library.md ("Minor-unit rule drives rounding").
Feature: OctoPerf Pet Store cart amounts respect the ISO 4217 minor-unit rule for USD

  @QAIA-US-EVAL-009-O01 @AC1 @P2 @ep @oracle:iso4217
  # condition: AC1-O1 (proposed, derived — extends AC1-C1's row assertions)
  # oracle: iso4217 USD minor-unit=2 -> every monetary field is an integral number of cents,
  # displayed with exactly two decimal places (library.md, "ISO 4217 (currency codes)").
  Scenario: Every monetary field of a cart row is displayed with exactly two decimal places
    Given the cart contains item EST-1 with List Price $16.50
    When the shopper views the cart
    Then the List Price displays exactly 2 decimal places, as "$16.50"
    And the Total Cost displays exactly 2 decimal places, as "$16.50"

  @QAIA-US-EVAL-009-O02 @AC2 @P3 @boundary @oracle:iso4217 @low-confidence
  # condition: AC2-O2 (proposed, derived — the minor-unit boundary AC2-C4 stops short of)
  # oracle: iso4217 USD minor-unit=2 -> a summed Sub Total is rounded to the cent; the
  # half-cent tie-break is the boundary case (library.md, "Minor-unit rule drives rounding").
  # open: no observed catalog price and no observed integer quantity can produce a sub-cent
  # Sub Total (2-decimal prices x integer quantities stay on the cent), so this boundary is
  # NOT reachable from any confirmed input. Kept P3 and flagged rather than fabricated with an
  # invented price -- SKILL.md guardrail "Never invent... an oracle is a citation, not a guess."
  Scenario: A Sub Total that would land on a half cent is rounded to a whole cent
    Given the cart contents produce a Sub Total with a sub-cent component
    When the shopper views the cart
    Then the Sub Total displays a whole number of cents, with exactly 2 decimal places
