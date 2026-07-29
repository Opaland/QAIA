Feature: Custom display name and description for the payment-required method
  # US-007. AC5.

  Background:
    Given a course "Intro to Statistics" has a "payment required" enrolment method built from the default method
    And the manager gives it the custom display name "Certificate Track Fee" and description "One-time certificate track access fee"

  @QAIA-US-007-026 @AC5 @P3 @ep
  Scenario: Manager sets a custom display name and description
    When the manager saves the custom name "Certificate Track Fee" and its description
    Then the configuration is accepted and the method carries the custom name and description
    # condition: AC5-C1

  @QAIA-US-007-027 @AC5 @P2 @decision-table
  Scenario: A logged-in student sees only the custom name, never the default
    Given a logged-in student who is not enrolled in the course
    When the student views the fee prompt
    Then the student sees the name "Certificate Track Fee" and never the default method name
    # condition: AC5-C2

  @QAIA-US-007-028 @AC5 @P2 @decision-table
  Scenario: An anonymous guest sees only the custom name, never the default
    Given an anonymous guest, not logged in
    When the guest views the fee prompt
    Then the guest sees the name "Certificate Track Fee" and never the default method name
    # condition: AC5-C3
    # answered: Q8 (AC4 x AC5 triple-read: AC4's guest messaging is unqualified by login state, AC5's naming scope is "anywhere a student can see it")

  @QAIA-US-007-029 @AC5 @P3 @decision-table
  Scenario: The manager's management view still shows the method's default origin
    Given the manager is viewing the course's enrolment methods management screen
    When the manager opens the customized method's details
    Then the manager sees both the custom name and that it was built from the default method
    # condition: AC5-C4

  @QAIA-US-007-030 @AC5 @P2 @low-confidence @state-transition
  Scenario: Renaming the method is immediately reflected in all subsequent views
    Given the method previously carried the custom name "Certificate Track Fee"
    When the manager renames it to "Statistics Certificate Fee"
    Then every subsequent student and guest view shows "Statistics Certificate Fee" immediately, with no trace of the prior custom name
    # condition: AC5-C5
    # assumption: Q7
    # rule: BR-KB-003
