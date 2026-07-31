# PROPOSED, NOT ACCEPTED -- oracle-generate step 2 (SKILL.md l.67) requires human arbitration.
# pending-validation: no human was available in this run. NOT merged into
# eval/skill-eval-campaign-2026-07-29/US-EVAL-009-octoperf-petstore/testbooks/octoperf-petstore-cart.feature
# Source: state/03-design.md conditions + plugins/qaia-core/skills/oracle-generate/oracles/library.md
Feature: OctoPerf Pet Store cart -- oracle-derived additions (proposed)

  @QAIA-US-EVAL-009-P01 @AC2 @P2 @ep @oracle:iso4217
  # condition: AC2-C6
  # oracle: iso4217 USD minor-units=2 (oracles/library.md l.33) -- the quantum is 0.01; a sum of
  # 2-decimal amounts is exactly 2-decimal (derive.py: residue 0.00), so the testable failure is
  # binary-float representation drift (derive.py: 0.1 + 0.2 = 0.30000000000000004), not a tie-break.
  Scenario: The displayed Sub Total equals the exact decimal sum of the row Total Costs
    Given the cart contains rows whose Total Costs are $0.10 and $0.20
    When the shopper views the cart
    Then the Sub Total is displayed as $0.30
    And it is not displayed as $0.30000000000000004 or any value differing from the exact sum by less than one cent

  @QAIA-US-EVAL-009-P02 @AC3 @P1 @negative @ep @oracle:http
  # condition: AC3-N1
  # oracle: http RFC 9110 "resource not found OR not visible" -> 404 (oracles/library.md l.23)
  Scenario: Adding an item ID that does not exist in the catalog is refused with 404
    Given the shopper has an active session
    When the shopper requests Cart.action with addItemToCart and a workingItemId that is absent from the catalog
    Then the response status is 404
    And no row is added to the cart

  @QAIA-US-EVAL-009-P03 @AC3 @P1 @negative @ep @oracle:http
  # condition: AC3-N2
  # oracle: http RFC 9110 "malformed body/params" -> 400 (oracles/library.md l.23)
  Scenario: Adding an item with an empty workingItemId parameter is refused with 400
    Given the shopper has an active session
    When the shopper requests Cart.action with addItemToCart and an empty workingItemId parameter
    Then the response status is 400
    And no row is added to the cart

  @QAIA-US-EVAL-009-P04 @AC3 @P1 @negative @decision-table @oracle:http @low-confidence
  # condition: AC3-C5b
  # oracle: http RFC 9110 -- 403 "authenticated but not allowed" / 404 "not visible (privacy)"
  # (oracles/library.md l.23). BOTH are oracle-legal; which one the store uses is a product
  # decision, so this stays [open] -- the oracle supplies the status set, never the choice.
  Scenario: A second guest session cannot remove an item from the first session's cart (proposed default, unconfirmed)
    Given session A's cart contains item EST-1
    And a second, unrelated guest session B exists with no shared credential
    When session B requests Cart.action with removeItemFromCart and workingItemId EST-1 against session A's cart
    Then the response status is 403 or 404
    And session A's cart still contains item EST-1
