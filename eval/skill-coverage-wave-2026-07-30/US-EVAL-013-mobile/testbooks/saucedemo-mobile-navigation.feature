# US-EVAL-013 — Swag Labs catalogue navigation on a narrow (phone) viewport
# Target: https://www.saucedemo.com/ (public practice app; its own published demo credentials)
# Mobile = browser emulation only (Playwright device descriptors) — native iOS/Android out of scope (D100).
# Upstream provenance: extraction unconfirmed, priorities proposed-but-not-arbitrated (no human in session).
Feature: The navigation drawer takes over a phone screen and stays the only route out of the catalogue

  Background:
    Given the Swag Labs demo application is available at https://www.saucedemo.com/

  @QAIA-US-EVAL-013-001 @AC1 @P1 @boundary @low-confidence
  # condition: AC1-C3 (479 px), AC1-C4 (480 px) — merged: same priority, same confidence
  # open: Q1 (is 480 px inclusive on the phone side? proposed default applied)
  Scenario Outline: At the top edge of the phone class the drawer covers the whole viewport
    Given a signed-in shopper viewing the catalogue at a viewport <width> px wide
    When the shopper opens the navigation drawer
    Then the drawer is <width> CSS px wide, occupying 100 percent of the viewport width

    Examples:
      | width |
      | 479   |
      | 480   |

  @QAIA-US-EVAL-013-002 @AC2 @P1 @boundary @low-confidence
  # condition: AC2-C1 (481 px — boundary + 1)
  # open: Q1
  Scenario: One pixel past the phone class the drawer becomes a fixed side panel
    Given a signed-in shopper viewing the catalogue at a viewport 481 px wide
    When the shopper opens the navigation drawer
    Then the drawer is 300 CSS px wide, occupying 62 percent of the viewport width

  @QAIA-US-EVAL-013-003 @AC1 @P2 @ep @low-confidence
  # condition: AC1-C1 (320 px), AC1-C2 (390 px) — representatives of the phone partition
  # open: Q1
  Scenario Outline: Anywhere inside the phone class the drawer covers the whole viewport
    Given a signed-in shopper viewing the catalogue at a viewport <width> px wide
    When the shopper opens the navigation drawer
    Then the drawer is <width> CSS px wide, occupying 100 percent of the viewport width

    Examples:
      | width |
      | 320   |
      | 390   |

  @QAIA-US-EVAL-013-004 @AC3 @P1 @decision-table @negative
  # condition: AC3-C1 [req-neg] — phone viewport, drawer open: the catalogue is unreachable
  Scenario: A tap aimed at the catalogue while the drawer is open changes nothing
    Given a signed-in shopper on a phone device descriptor with an empty cart
    And the navigation drawer is open
    When the shopper taps the point where the first product card's centre lies
    Then the topmost element at that point belongs to the drawer's item list
    And the cart badge is still absent, showing no item was added

  @QAIA-US-EVAL-013-005 @AC3 @P2 @decision-table
  # condition: AC3-C2 — control cell: same viewport, drawer closed, the catalogue does respond
  Scenario: With the drawer closed the same phone viewport adds the product to the cart
    Given a signed-in shopper on a phone device descriptor with an empty cart
    And the navigation drawer is closed
    When the shopper taps "Add to cart" on the first product card
    Then the cart badge reads "1"

  @QAIA-US-EVAL-013-006 @AC4 @P1 @state-transition
  # condition: AC4-C1 — transition Closed --tapBurger--> Open
  Scenario: Tapping the burger opens the drawer
    Given a signed-in shopper on a phone device descriptor with the navigation drawer closed
    When the shopper taps the burger control
    Then the drawer reports aria-hidden "false"

  @QAIA-US-EVAL-013-007 @AC4 @P1 @state-transition
  # condition: AC4-C2 — transition Open --tapCross--> Closed
  Scenario: Tapping the close control closes the drawer
    Given a signed-in shopper on a phone device descriptor with the navigation drawer open
    When the shopper taps the drawer's close control
    Then the drawer reports aria-hidden "true"

  @QAIA-US-EVAL-013-008 @AC4 @P1 @state-transition
  # condition: AC4-C3 — re-entrance: two full open/close cycles, no degraded state
  Scenario: The drawer still opens after two full open-close cycles
    Given a signed-in shopper on a phone device descriptor who has already opened and closed the drawer twice
    When the shopper taps the burger control again
    Then the drawer reports aria-hidden "false"

  @QAIA-US-EVAL-013-009 @AC4 @P2 @error-guessing
  # condition: AC4-C4 — the drawer is the only route to Logout on a phone
  Scenario: No sign-out control exists outside the drawer on a phone
    Given a signed-in shopper on a phone device descriptor
    When the shopper looks for every control on the page whose label mentions logout or sign out
    Then exactly 1 such control exists, and it sits inside the navigation drawer

  @QAIA-US-EVAL-013-010 @AC5 @P2 @state-transition
  # condition: AC5-C1 — transition authenticated --tapLogout--> anonymous
  Scenario: Signing out from the drawer returns the shopper to the login page
    Given a signed-in shopper on a phone device descriptor with the navigation drawer open
    When the shopper taps "Logout"
    Then the browser is on https://www.saucedemo.com/ and the Login button is displayed

  @QAIA-US-EVAL-013-011 @AC5 @P1 @negative @state-transition
  # condition: AC5-C2 [req-neg] — the revoked session cannot walk back into the catalogue
  Scenario: After signing out, requesting the catalogue URL directly is refused
    Given a shopper on a phone device descriptor who has just signed out from the drawer
    When the shopper requests https://www.saucedemo.com/inventory.html directly
    Then the browser stays on https://www.saucedemo.com/ and shows the error "Epic sadface: You can only access '/inventory.html' when you are logged in."

  @QAIA-US-EVAL-013-012 @AC5 @P1 @negative @error-guessing
  # condition: AC5-C3 [req-neg] — never-authenticated access, a distinct path from revocation
  Scenario: A shopper who never signed in cannot reach the catalogue URL
    Given a shopper on a phone device descriptor with no session, who has never signed in
    When the shopper requests https://www.saucedemo.com/inventory.html directly
    Then the browser stays on https://www.saucedemo.com/ and shows the error "Epic sadface: You can only access '/inventory.html' when you are logged in."

  @QAIA-US-EVAL-013-013 @AC5 @P1 @negative @error-guessing
  # condition: AC5-C4 [req-neg] — every other guarded route, not only the one the AC names
  Scenario Outline: A shopper with no session cannot reach any other guarded page either
    Given a shopper on a phone device descriptor with no session, who has never signed in
    When the shopper requests https://www.saucedemo.com/<path> directly
    Then the browser stays on https://www.saucedemo.com/ and shows the error "Epic sadface: You can only access '/<path>' when you are logged in."

    Examples:
      | path                  |
      | cart.html             |
      | checkout-step-one.html |

  @QAIA-US-EVAL-013-014 @AC6 @P2 @boundary @low-confidence
  # condition: AC6-C1 (899 px), AC6-C2 (900 px) — merged: same priority, same confidence
  # open: Q2 (is the 40 px stub an intended mobile presentation or a degradation?)
  Scenario Outline: The sort control is a stub below 900 px and full width from 900 px
    Given a signed-in shopper viewing the catalogue at a viewport <width> px wide
    When the shopper looks at the product sort control
    Then the sort control is <rendered> CSS px wide

    Examples:
      | width | rendered |
      | 899   | 40       |
      | 900   | 223      |

  @QAIA-US-EVAL-013-015 @AC6 @P2 @state-transition
  # condition: AC6-C3 — the sort selection survives a drawer open/close cycle
  Scenario: The chosen sort order survives opening and closing the drawer
    Given a signed-in shopper on a phone device descriptor who has sorted the catalogue by "Name (Z to A)"
    When the shopper performs one full open-close cycle of the navigation drawer
    Then the sort control still reads "Name (Z to A)"

  @QAIA-US-EVAL-013-016 @AC7 @P1 @boundary @low-confidence @oracle:wcag-2.2-2.5.8
  # condition: AC7-C3 — measured target size against the published WCAG 2.2 SC 2.5.8 minimum (24x24 CSS px)
  # open: Q3 (is a 20x20 px burger an accepted target size for this product?)
  Scenario: The burger control is smaller than the published minimum touch-target size
    Given a signed-in shopper on a phone device descriptor
    When the shopper's burger control is measured
    Then it is 20 by 20 CSS px, which is below the 24 by 24 CSS px minimum of WCAG 2.2 SC 2.5.8

  @QAIA-US-EVAL-013-017 @AC1 @AC4 @AC5 @P1 @use-case @smoke
  # condition: AC-J (journey; excluded from atomicity accounting and from the negative ratio)
  Scenario: A shopper browses, opens the full-screen drawer and signs out of a phone session
    Given a shopper on a phone device descriptor who has signed in to the catalogue
    When the shopper opens the drawer and signs out
    Then the session is over: requesting the catalogue URL directly shows the signed-out error
