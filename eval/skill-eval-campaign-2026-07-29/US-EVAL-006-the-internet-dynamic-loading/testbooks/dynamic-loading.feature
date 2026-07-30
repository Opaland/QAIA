# US-EVAL-006 | source: state/US-EVAL-006/03-design.md, conditions AC3-C1, AC4-C1, AC6-C1, AC6-C2 (P1+P2 scope)
# Target: the-internet (Herokuapp), "Dynamically Loaded Page Elements" feature -- primary-source
# grounded from the pages' own served HTML + inline JS (docs/DEMO-TARGETS.md, UI edge cases row),
# not a blog summary.
Feature: Dynamically loaded page elements reveal "Hello World!" via two distinct DOM mechanisms

  @QAIA-US-EVAL-006-001 @AC3 @P2 @state-transition @bva
  # condition: AC3-C1
  # assumption: Q2 -- the 5000ms delay is a lower bound (standard browser setTimeout semantics),
  # not an exact instant; this scenario's check window stays comfortably under 5000ms rather than
  # skirting the boundary.
  Scenario: Example 1's pre-existing hidden element is not yet visible before the delay elapses
    Given the client navigates to "/dynamic_loading/1" and clicks "Start"
    When less than 5000ms have elapsed since the click
    Then "Hello World!" is not visible
    And the "Loading..." indicator is still visible

  @QAIA-US-EVAL-006-002 @AC4 @P2 @ep
  # condition: AC4-C1
  Scenario: Example 2 has no Hello World element in the DOM at all before any click
    Given the client navigates to "/dynamic_loading/2"
    When the page finishes loading, before any click
    Then no element matching "#finish" exists anywhere in the DOM
    And a "Start" button is visible

  @QAIA-US-EVAL-006-003 @AC6 @P1 @state-transition @bva @low-confidence
  # condition: AC6-C1
  # assumption: Q2 -- same lower-bound timing semantics as scenario 001, applied to the stricter
  # "does not exist at all" assertion this example requires (not merely "not visible").
  Scenario: Example 2's Hello World element still does not exist in the DOM before the delay elapses
    Given the client navigates to "/dynamic_loading/2" and clicks "Start"
    When less than 5000ms have elapsed since the click
    Then no element matching "#finish" exists anywhere in the DOM
    And the "Loading..." indicator is still visible

  @QAIA-US-EVAL-006-004 @AC6 @P2 @state-transition @bva
  # condition: AC6-C2
  Scenario: Example 2's Hello World element is created and shown after the delay elapses
    Given the client navigates to "/dynamic_loading/2" and clicks "Start"
    When the client waits until at least 5000ms have elapsed since the click
    Then a new element matching "#finish" exists in the DOM and is visible
    And it displays the text "Hello World!"
    And the "Loading..." indicator is no longer visible
