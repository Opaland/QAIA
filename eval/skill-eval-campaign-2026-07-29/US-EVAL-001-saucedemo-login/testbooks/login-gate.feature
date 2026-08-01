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
  # resolved: Q1 -- the generic refusal wording is now confirmed, by the same live probe
  # that answered Q2 and Q3 (2026-08-01, eval/ci-proof-2026-08-01/oracle-probe-saucedemo.txt).
  # Asserting it is not cosmetic: "generic" is the anti-enumeration requirement, and a Then
  # that only says "a message is shown" is satisfied by "No such user".
  Scenario: An unknown username is refused with the generic message
    Given the login page is open
    When an unrecognized username logs in with any password
    Then the login is refused
    And the message "Username and password do not match any user in this service" is shown
    And the product catalog is not displayed

  @QAIA-US-EVAL-001-004 @AC3 @P1 @negative @decision-table
  # condition: AC3-C2
  # resolved: Q1 -- same confirmed wording as 003. That the two are identical is the point;
  # scenario 007 asserts the identity itself, which neither of these two can express alone.
  Scenario: A known username with the wrong password is refused with the generic message
    Given the login page is open
    When "standard_user" logs in with an incorrect password
    Then the login is refused
    And the message "Username and password do not match any user in this service" is shown
    And the product catalog is not displayed

  @QAIA-US-EVAL-001-005 @AC3 @P2 @negative @decision-table
  # condition: AC3-C3
  # resolved: Q2 -- the assumption that an empty field falls through to the generic
  # refusal path is DISCONFIRMED. The application emits a distinct required-field
  # message per empty field. Confirmed against the live application on 2026-08-01,
  # raw output kept in eval/ci-proof-2026-08-01/oracle-probe-saucedemo.txt.
  Scenario Outline: An empty username or password field is refused with a required-field message
    Given the login page is open
    When "<username>" logs in with password "<password>"
    Then the login is refused
    And the message "<message>" is shown
    And the product catalog is not displayed

    Examples:
      | username       | password      | message              |
      |                | secret_sauce  | Username is required |
      | standard_user  |               | Password is required |

  @QAIA-US-EVAL-001-006 @AC2 @P1 @negative @decision-table
  # condition: AC2-C2
  # resolved: Q3 -- the proposed default (locked-out state wins) is DISCONFIRMED.
  # Credentials are validated before lock state, so a wrong password on a locked
  # account yields the generic invalid-credentials message; the locked-out message
  # appears only when the password is correct (see 002). Confirmed against the live
  # application on 2026-08-01, raw output kept in
  # eval/ci-proof-2026-08-01/oracle-probe-saucedemo.txt.
  Scenario: A locked-out account with an incorrect password is refused with the generic message
    Given the login page is open
    When "locked_out_user" logs in with an incorrect password
    Then the login is refused
    And the message "Username and password do not match any user in this service" is shown
    And the product catalog is not displayed

  @QAIA-US-EVAL-001-007 @AC3 @P1 @negative @decision-table
  # condition: AC3-C4 (new -- the requirement "generic" carries and no scenario stated)
  # Added 2026-08-01 after the first automation-rubric pass (issue #63) found that 003 and
  # 004 could both pass against an application that answers "No such user" to one and
  # "Wrong password" to the other -- i.e. against exactly the user-enumeration defect the
  # word "generic" exists to forbid. The requirement is an EQUALITY between two refusals,
  # and no per-scenario assertion can express it: it needs its own scenario.
  Scenario: An unknown username and a wrong password are refused indistinguishably
    Given the login page is open
    When an unrecognized username is refused and a known username with a wrong password is refused
    Then both refusals show the same message
