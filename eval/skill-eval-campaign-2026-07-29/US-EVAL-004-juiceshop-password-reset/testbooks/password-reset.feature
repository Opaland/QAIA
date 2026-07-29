# US-EVAL-004 | source: state/03-design.md, conditions AC1-C1..AC4-C6 (P1+P2 default scope)
# Target: https://demo.owasp-juice.shop/#/forgot-password (public OWASP demo, no scan/exploit performed)
Feature: Juice Shop password reset via security question

  @QAIA-US-EVAL-004-001 @AC1 @P2 @ep
  # condition: AC1-C1
  Scenario: Entering a registered account's email surfaces that account's own security question
    Given the "Forgot Password" page is open
    When the email of a registered account is submitted
    Then the Security Question field becomes enabled for that account

  @QAIA-US-EVAL-004-002 @AC1 @P1 @decision-table @low-confidence
  # condition: AC1-C2
  # open: Q1 -- whether the lookup discloses account existence for an email that is not a
  # registered account is not confirmed by any source (the live endpoint was unavailable this
  # session). Proposed default generated below (no distinguishable disclosure): human arbitration
  # required before this is trusted.
  Scenario: An email that is not a registered account gives no distinguishable existence signal (proposed default, unconfirmed)
    Given the "Forgot Password" page is open
    When an email that is not a registered account is submitted
    Then the Security Question field is enabled, the same as for a registered email
    And nothing in the response identifies the email as unregistered

  @QAIA-US-EVAL-004-003 @AC2 @P1 @decision-table
  # condition: AC2-C1
  Scenario: A registered account holder who answers the security question correctly resets their password
    Given the "Forgot Password" page is open for a registered account whose security question is displayed
    When the account holder answers the security question correctly and submits a new password, 5-40 characters, matching its repeat
    Then the password change succeeds and the system displays a confirmation

  @QAIA-US-EVAL-004-004 @AC3 @P1 @negative @decision-table
  # condition: AC3-C1
  # assumption: Q2 -- the refusal is asserted qualitatively only (a refusal occurs, the password
  # is unchanged); no specific message/status is asserted since none is sourced.
  Scenario: An incorrect answer to the security question is refused
    Given the "Forgot Password" page is open for a registered account whose security question is displayed
    When an incorrect answer to the security question is submitted with an otherwise valid new password
    Then the password change is refused
    And the account's password is not changed

  @QAIA-US-EVAL-004-005 @AC3 @P1 @negative @error-guessing @low-confidence
  # condition: AC3-C2
  # open: Q3 -- whether repeated wrong answers are ever throttled/blocked is not confirmed by any
  # source. Only the individually-refused outcome of each attempt is asserted; no claim is made
  # about a lockout existing or not existing beyond the attempts actually exercised.
  Scenario: Five consecutive incorrect answers are each individually refused (no lockout claim either way)
    Given the "Forgot Password" page is open for a registered account whose security question is displayed
    When 5 consecutive incorrect answers are submitted to the security question, one after another
    Then each of the 5 attempts is individually refused
    And the account's password is not changed

  @QAIA-US-EVAL-004-006 @AC4 @P2 @boundary
  # condition: AC4-C2, AC4-C3
  Scenario Outline: A new password at the accepted length boundary is valid
    Given the "Forgot Password" page is open for a registered account whose security question is answered correctly
    When a new password of <length> characters is submitted with an identical repeat
    Then the "Change" control is enabled and the password change succeeds

    Examples:
      | length |
      | 5      |
      | 40     |

  @QAIA-US-EVAL-004-007 @AC4 @P2 @negative @boundary
  # condition: AC4-C1, AC4-C4
  Scenario Outline: A new password outside the accepted length boundary is rejected
    Given the "Forgot Password" page is open for a registered account whose security question is answered correctly
    When a new password of <length> characters is submitted with an identical repeat
    Then the "Change" control stays disabled
    And the message "Password must be 5-40 characters long." is shown

    Examples:
      | length |
      | 4      |
      | 41     |

  @QAIA-US-EVAL-004-008 @AC4 @P1 @negative @error-guessing @low-confidence
  # condition: AC4-C6
  # open: Q4 -- whether the backend independently re-enforces the password-shape rule when the
  # UI's disabled control is bypassed is not confirmed by any source (the client-side behavior
  # was directly observed; the server-side behavior was not). Proposed default generated below
  # (backend re-validates, defense-in-depth): human arbitration required before this is trusted.
  Scenario: The password-shape rule is re-enforced when submitted directly, bypassing the disabled UI control (proposed default, unconfirmed)
    Given a registered account whose security question is answered correctly
    When an out-of-range new password is submitted directly to the backend, bypassing the UI's disabled "Change" control
    Then the password change is refused
    And the account's password is not changed
