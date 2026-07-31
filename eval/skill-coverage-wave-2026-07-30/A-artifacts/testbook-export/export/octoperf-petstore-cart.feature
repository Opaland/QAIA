# US-EVAL-009 | source: state/US-EVAL-009/03-design.md, conditions AC1-C1..AC3-C5 (AC2-C1, AC3-C2, AC3-C3 deferred, P3, default scope)
# Target: OctoPerf Pet Store (JPetStore-style), petstore.octoperf.com/actions/Cart.action, add/view/remove flow
Feature: OctoPerf Pet Store shopping cart computes correct totals and gates checkout

  @QAIA-US-EVAL-009-001 @AC1 @P2 @ep
  # condition: AC1-C1
  Scenario: Adding a single item creates a cart row with the correct total cost
    Given an empty cart
    When the shopper adds item EST-1 to the cart
    Then the cart shows a row for item EST-1, product FI-SW-01, description "Large Angelfish", list price $16.50 and total cost $16.50

  @QAIA-US-EVAL-009-002 @AC1 @P1 @state-transition @low-confidence
  # condition: AC1-C2
  # assumption: Q1 -- adding an already-present item again increments its existing row's
  # quantity and scales its total cost, rather than creating a duplicate row; not independently
  # confirmed live (stateless fetch could not hold a session across two add calls).
  Scenario: Adding an already-present item again increments its quantity instead of duplicating the row
    Given the cart already contains item EST-1 with quantity 1
    When the shopper adds item EST-1 to the cart again
    Then the EST-1 row's quantity becomes 2 and its total cost becomes $33.00
    And no second EST-1 row is created

  @QAIA-US-EVAL-009-003 @AC2 @P2 @ep
  # condition: AC2-C2
  Scenario: The Sub Total equals the sum of every distinct item's total cost
    Given the cart already contains item EST-1 at $16.50 and item EST-2 at $16.50
    When the shopper views the cart
    Then the Sub Total equals $33.00

  @QAIA-US-EVAL-009-004 @AC2 @P2 @ep @oracle:iso4217 @low-confidence
  # condition: AC2-C4
  # assumption: Q6 -- Sub Total is displayed with standard two-decimal-place USD formatting; no
  # source price forces a sub-cent rounding tie-break, so only the format invariant is asserted.
  Scenario: The Sub Total is displayed with two-decimal-place USD formatting
    Given the cart contains at least one item
    When the shopper views the cart
    Then the Sub Total is shown with exactly two decimal places

  @QAIA-US-EVAL-009-005 @AC2 @P2 @ep @low-confidence
  # condition: AC2-C5
  # assumption: derived from istqb-design sub-step 3c (list-view state persistence) -- the cart is
  # expected to persist across navigation within the same session; not independently confirmed.
  Scenario: Cart contents persist after navigating away and back to the cart
    Given the shopper has added item EST-1 to the cart
    When the shopper browses a different category and then returns to the cart
    Then item EST-1 and its total cost $16.50 are still present
    And the Sub Total is unchanged

  @QAIA-US-EVAL-009-006 @AC3 @P2 @state-transition
  # condition: AC3-C1
  Scenario: Removing one item recomputes the Sub Total without affecting the remaining item
    Given the cart contains item EST-1 at $16.50 and item EST-2 at $16.50 with Sub Total $33.00
    When the shopper removes the EST-1 row
    Then the EST-1 row no longer appears in the cart
    And the Sub Total decreases to $16.50

  @QAIA-US-EVAL-009-007 @AC3 @P1 @decision-table @low-confidence
  # condition: AC3-C4
  # open: Q3 -- whether an item marked "In Stock? = false" blocks "Proceed to Checkout" is not
  # confirmed by any source. Proposed default generated below (checkout remains available): human
  # arbitration required before this is trusted (blocking out-of-stock checkout is an equally
  # plausible real e-commerce policy).
  Scenario: Checkout remains available with an out-of-stock item in the cart (proposed default, unconfirmed)
    Given the cart contains an item whose "In Stock?" value is false
    When the shopper proceeds to checkout
    Then the "Proceed to Checkout" action is available

  @QAIA-US-EVAL-009-008 @AC3 @P1 @negative @decision-table @low-confidence
  # condition: AC3-C5
  # open: Q7 -- whether one guest session's cart is isolated from a second, unrelated guest
  # session (no shared credential) is not confirmed by any source (stateless WebFetch could not
  # hold two live sessions to compare). Proposed default generated below (refused/isolated): human
  # arbitration required.
  Scenario: A second, unrelated guest session cannot view or mutate the first session's cart (proposed default, unconfirmed)
    Given a shopper has added items to their own cart in session A
    And a second, unrelated guest session B exists with no shared credential
    When session B attempts to view or mutate session A's cart
    Then the attempt is refused
    And session A's cart is unaffected
