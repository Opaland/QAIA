# US-EVAL-002 | source: state/US-EVAL-002/03-design.md, conditions AC1-C1..AC4-C1
# Target: https://api.practicesoftwaretesting.com (public demo API, explore-only per docs/DEMO-TARGETS.md license caveat)
Feature: Toolshop cart and checkout create a confirmed order for an authenticated or guest customer

  @QAIA-US-EVAL-002-001 @AC1 @P2 @ep
  # condition: AC1-C1
  Scenario: A valid product and quantity are added to the cart
    Given an empty cart
    When a valid product is added to the cart with quantity 1
    Then the cart reflects the added product

  @QAIA-US-EVAL-002-002 @AC1 @P2 @negative @decision-table
  # condition: AC1-C2
  # assumption: Q2 -- an unrecognized product_id is refused/errors; exact status not confirmed by any source.
  Scenario: An unrecognized product is refused when adding to the cart
    Given an empty cart
    When a product with an unrecognized product_id is added to the cart
    Then the add-to-cart request is refused
    And the cart remains empty

  @QAIA-US-EVAL-002-003 @AC1 @P2 @negative @boundary @low-confidence
  # condition: AC1-C3
  # assumption: Q3 -- a zero or negative quantity is refused; the exact accepted floor is not
  # confirmed by any source.
  Scenario Outline: A non-positive quantity is refused when adding to the cart
    Given an empty cart
    When a valid product is added to the cart with quantity <quantity>
    Then the add-to-cart request is refused
    And the cart remains empty

    Examples:
      | quantity |
      | 0        |
      | -1       |

  @QAIA-US-EVAL-002-004 @AC2 @P1 @decision-table
  # condition: AC2-C1
  Scenario: An authenticated customer completes checkout on a cart they own
    Given an authenticated customer with a non-empty cart they own
    When the customer checks out
    Then an invoice is created from the cart

  @QAIA-US-EVAL-002-005 @AC2 @P1 @negative @decision-table
  # condition: AC2-C2
  Scenario: An unauthenticated checkout attempt is refused
    Given a non-empty cart and no authenticated session
    When checkout is attempted without authentication
    Then the checkout request is refused
    And no invoice is created

  @QAIA-US-EVAL-002-006 @AC2 @P2 @negative @decision-table
  # condition: AC2-C3
  # assumption: Q1 -- checkout against an empty cart is refused; not confirmed by any source.
  Scenario: Checkout against an empty cart is refused
    Given an authenticated customer with an empty cart they own
    When the customer checks out
    Then the checkout request is refused
    And no invoice is created

  @QAIA-US-EVAL-002-007 @AC2 @P1 @negative @decision-table @low-confidence
  # condition: AC2-C4
  # open: Q6 -- whether checking out a cart owned by another customer returns a non-disclosing
  # refusal or one confirming the cart's existence is not confirmed by any source. Proposed
  # default generated below (refused): human arbitration required before this is trusted.
  Scenario: Checkout against a cart owned by another customer is refused (proposed default, unconfirmed)
    Given an authenticated customer and a non-empty cart owned by a different customer
    When the customer attempts to check out that cart
    Then the checkout request is refused
    And no invoice is created

  @QAIA-US-EVAL-002-008 @AC3 @P1 @ep
  # condition: AC3-C1
  Scenario: A guest completes checkout with complete guest details
    Given a non-empty cart and no authenticated session
    When the guest checks out with a valid email, first name and last name
    Then an invoice is created from the cart

  @QAIA-US-EVAL-002-009 @AC3 @P2 @negative @decision-table
  # condition: AC3-C2
  # assumption: Q4 -- a missing required guest field is refused; not confirmed by any source.
  Scenario Outline: A guest checkout missing a required guest field is refused
    Given a non-empty cart and no authenticated session
    When the guest checks out with <missing_field> missing
    Then the checkout request is refused
    And no invoice is created

    Examples:
      | missing_field    |
      | guest_email      |
      | guest_first_name |
      | guest_last_name  |

  @QAIA-US-EVAL-002-010 @AC3 @P2 @negative @ep @oracle:rfc5322
  # condition: AC3-C3
  # oracle: rfc5322 guest_email format -- RFC 5322 invalid-corpus case (missing "@"/domain)
  Scenario: A guest checkout with a malformed email address is refused
    Given a non-empty cart and no authenticated session
    When the guest checks out with a syntactically invalid email address
    Then the checkout request is refused
    And no invoice is created

  @QAIA-US-EVAL-002-011 @AC4 @P1 @state-transition @low-confidence
  # condition: AC4-C1
  # open: Q5 -- the initial status of a newly created invoice is not confirmed by any source.
  # Proposed default generated below (AWAITING_FULFILLMENT): human arbitration required.
  Scenario: A newly created invoice starts in the awaiting-fulfillment status (proposed default, unconfirmed)
    Given an authenticated customer with a non-empty cart they own
    When the customer checks out
    Then the created invoice has status "AWAITING_FULFILLMENT"
