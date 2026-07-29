# US-EVAL-001 | source: state/US-EVAL-001/03-design.md, conditions AC1-C1..AC2-C2
# Target: https://www.saucedemo.com/ (public practice app, no auth/PII risk)
Feature: SauceDemo login gate lets through only valid, non-locked credentials

  @QAIA-US-EVAL-001-001 @AC1 @P2 @ep
  # condition: AC1-C1
  Scenario: A valid, non-locked account logs in and reaches the product catalog
    Given the login page is open
    When "standard_user" logs in with password "secret_sauce"
    Then the login succeeds and the product catalog is displayed

  @QAIA-US-EVAL-001-002 @AC2 @P1 @negative @ep
  # condition: AC2-C1
  Scenario: A valid but locked-out account is refused with the locked-out message
    Given the login page is open
    When "locked_out_user" logs in with password "secret_sauce"
    Then the login is refused
    And the message "Sorry, this user has been locked out." is shown
    And the product catalog is not displayed

  @QAIA-US-EVAL-001-003 @AC3 @P1 @negative @decision-table
  # condition: AC3-C1
  Scenario: An unknown username is refused
    Given the login page is open
    When an unrecognized username logs in with any password
    Then the login is refused with a generic message
    And the product catalog is not displayed

  @QAIA-US-EVAL-001-004 @AC3 @P1 @negative @decision-table
  # condition: AC3-C2
  Scenario: A known username with the wrong password is refused
    Given the login page is open
    When "standard_user" logs in with an incorrect password
    Then the login is refused with a generic message
    And the product catalog is not displayed

  @QAIA-US-EVAL-001-005 @AC3 @P2 @negative @decision-table @low-confidence
  # condition: AC3-C3
  # assumption: Q2 -- an empty username or password field falls through to the
  # same generic refusal path as AC3-C1/C2; no distinct client-side validation
  # message is asserted since no source confirms one exists.
  Scenario Outline: An empty username or password field is refused
    Given the login page is open
    When "<username>" logs in with password "<password>"
    Then the login is refused
    And the product catalog is not displayed

    Examples:
      | username       | password      |
      |                | secret_sauce  |
      | standard_user  |               |

  @QAIA-US-EVAL-001-006 @AC2 @P1 @negative @decision-table @low-confidence
  # condition: AC2-C2
  # open: Q3 -- whether a locked account with an incorrect password still shows
  # the locked-out message, or falls back to the generic invalid-credentials
  # message, is not confirmed by any source. Proposed default generated below
  # (locked-out state wins): human arbitration required before this is trusted.
  Scenario: A locked-out account with an incorrect password still shows the locked-out message (proposed default, unconfirmed)
    Given the login page is open
    When "locked_out_user" logs in with an incorrect password
    Then the login is refused
    And the message "Sorry, this user has been locked out." is shown
    And the product catalog is not displayed
