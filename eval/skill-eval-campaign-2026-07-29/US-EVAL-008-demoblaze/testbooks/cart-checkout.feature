# US-EVAL-008 | source: state/US-EVAL-008/03-design.md, conditions AC2-C1, AC2-C2, AC2-C3,
# AC3-C1, AC4-C2, AC7-C3, AC8-C1, AC8-C2, AC8-C3, AC8-C4 (P1+P2 scope)
# Target: DemoBlaze (demoblaze.com) -- primary-source grounded from the served HTML + linked
# JS of index.html/prod.html/cart.html (docs/DEMO-TARGETS.md, UI e-commerce row), not a blog
# summary. No write request was sent against the shared demo while capturing the source.
Feature: Add to cart, review the cart total, and place an order on DemoBlaze

  @QAIA-US-EVAL-008-001 @AC2 @P2 @decision-table @negative
  # condition: AC2-C1
  Scenario: Logged-in add-to-cart surfaces an expired-token error verbatim
    Given a shopper with a session token cookie is on a product page
    When they click "Add to cart" and the backend response's errorMessage is "Token has expired"
    Then the alert "Your token has expired, please login again." is shown
    And no "Product added." confirmation is shown

  @QAIA-US-EVAL-008-002 @AC2 @P2 @decision-table @negative
  # condition: AC2-C2
  Scenario: Logged-in add-to-cart surfaces a malformed-token error verbatim
    Given a shopper with a session token cookie is on a product page
    When they click "Add to cart" and the backend response's errorMessage is "Bad parameter, token malformed."
    Then the alert "Bad parameter, token malformed." is shown
    And no "Product added." confirmation is shown

  @QAIA-US-EVAL-008-003 @AC2 @P2 @decision-table @negative
  # condition: AC2-C3
  Scenario: Logged-in add-to-cart surfaces a flag-incorrect error verbatim
    Given a shopper with a session token cookie is on a product page
    When they click "Add to cart" and the backend response's errorMessage is "Bad parameter, flag is incorrect."
    Then the alert "Bad parameter, flag is incorrect." is shown
    And no "Product added." confirmation is shown

  @QAIA-US-EVAL-008-004 @AC3 @P1 @ep @low-confidence
  # condition: AC3-C1
  # assumption: Q1 -- only the live-observable success case is asserted; the guest path's
  # "never surfaces a backend error" property is cited from source (00-source.md), not forced
  # live via an artificially-induced backend error.
  Scenario: Guest add-to-cart shows a generic success alert with no trailing period
    Given a shopper with no session token cookie is on a product page
    When they click "Add to cart" and the backend responds successfully
    Then the alert "Product added" is shown, with no trailing period

  @QAIA-US-EVAL-008-005 @AC4 @P2 @boundary
  # condition: AC4-C2
  Scenario: The cart total is the exact sum of every fetched item's price
    Given a cart containing two items with fetched prices of $360 and $790
    When the cart page finishes loading both items
    Then the displayed total equals 1150
    And both "#totalp" and "#totalm" reflect the same value

  @QAIA-US-EVAL-008-006 @AC7 @P2 @boundary
  # condition: AC7-C3
  Scenario: A whitespace-only credit card value is not rejected by client-side validation
    Given the "Place Order" modal is open with "Name" filled and "Credit card" set to a single space character
    When the shopper clicks "Purchase"
    Then no "Please fill out Name and Creditcard." alert is shown
    And the purchase proceeds to the confirmation dialog

  @QAIA-US-EVAL-008-007 @AC8 @P2 @ep
  # condition: AC8-C1
  Scenario: A valid purchase shows a confirmation dialog with the entered and computed values
    Given a non-empty cart and the "Place Order" modal open with "Name" and "Credit card" both filled
    When the shopper clicks "Purchase"
    Then a confirmation dialog is shown containing a generated order Id, the cart's total as Amount, the entered credit card value verbatim as Card Number, the entered Name, and the current date
    And a request to clear the cart is sent

  @QAIA-US-EVAL-008-008 @AC8 @P2 @ep @low-confidence
  # condition: AC8-C2
  # assumption: Q2 -- scoped to a single session with no concurrent cart modification between
  # cart-page load and clicking Purchase; the un-awaited deletecart race itself is a named gap,
  # not asserted with a specific timing outcome.
  Scenario: The confirmation dialog's Amount matches the total shown on the cart page before purchasing
    Given a non-empty cart whose displayed total is a known value, with no concurrent modification since the cart page loaded
    When the shopper fills "Name" and "Credit card" and clicks "Purchase"
    Then the confirmation dialog's Amount equals the total that was displayed on the cart page

  @QAIA-US-EVAL-008-009 @AC8 @P1 @ep @low-confidence
  # condition: AC8-C3
  # open: Q3 -- no login-required gate was found in the captured source for purchaseOrder();
  # this scenario asserts the current, observed no-gate behavior. Human arbitration requested
  # on whether unauthenticated checkout is the intended policy (state/US-EVAL-008/04-priorities.md).
  Scenario: A guest (unauthenticated) shopper can complete the purchase flow identically to a logged-in shopper
    Given a shopper with no session token cookie, a non-empty cart, and the "Place Order" modal filled with "Name" and "Credit card"
    When they click "Purchase"
    Then the same confirmation dialog shape is shown as for a logged-in shopper
    And no authentication prompt or block occurs

  @QAIA-US-EVAL-008-010 @AC8 @P2 @state-transition
  # condition: AC8-C4
  Scenario: Placing an order against an empty cart still succeeds with a zero amount
    Given an empty cart and the "Place Order" modal filled with "Name" and "Credit card"
    When the shopper clicks "Purchase"
    Then a confirmation dialog is shown with Amount equal to 0 USD
    And no "cart is empty" block prevents the order
