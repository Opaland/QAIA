# Run B — FIT-118, generated WITH knowledge/business-rules.md (BR-KB-201..205).
# Additive to run-a.feature (IDs 001-016 unchanged, never renumbered — D18). This file holds
# only the NEW scenario blocks step 3d derived from the knowledge base, IDs 017-028.
# 11 new blocks realize 13 net-new conditions (017 and 022 are Outlines merging 2 conditions
# each per D20 — same behavior, same priority, same confidence, only the example row differs);
# ID 028 is the Q5 assumption-to-fact confirmation, tracked separately (not counted in the
# recall headline). See run-b-journey.md for the condition-by-condition table.
# CORRECTED after independent judge review: an earlier draft of this header said "12
# conditions" — off by one against the actual `# condition:` tag count. Fixed here; see
# rag-recall-gain.md "Defects found" for the judge's finer-grained finding this review also
# surfaced (BR-KB-203 is only partially realized even in this run).

Feature: Class booking — credits, cancellation penalties, waitlist timing (FIT-118, with knowledge base)

  Background:
    Given a studio member "Alex" is signed in
    And a class "Vinyasa Flow" on the schedule with 10 total spots

  @QAIA-FIT-118-017 @AC1 @P1 @ep
  # condition: AC1-C9, AC1-C10 | rule: BR-KB-201
  Scenario Outline: Booking deducts credits according to the class's time slot
    Given "<class>" has 3 remaining spots
    And Alex has a credit balance of 5
    When Alex books "<class>"
    Then Alex's credit balance is <balance-after>

    Examples:
      | class                        | balance-after |
      | Vinyasa Flow (standard slot) | 4              |
      | Power Hour (peak, Tue 18:30) | 3              |

  @QAIA-FIT-118-018 @AC1 @P1 @negative @decision-table
  # condition: AC1-C11 | rule: BR-KB-203
  Scenario: A Basic-tier member with no remaining monthly credits cannot book
    Given Alex is on the Basic tier with 0 remaining credits this month
    And "Vinyasa Flow" has 3 remaining spots
    When Alex attempts to book "Vinyasa Flow"
    Then the booking is rejected with "insufficient credits"

  @QAIA-FIT-118-019 @AC1 @P2 @boundary
  # condition: AC1-C12 | rule: BR-KB-203
  Scenario: A Premium member's credit rollover is capped at 10
    Given Alex is on the Premium tier with 11 unused credits at month end
    When the monthly rollover runs
    Then Alex's rolled-over balance is 10 credits
    And 1 credit is forfeited

  @QAIA-FIT-118-020 @AC1 @P2 @negative @decision-table
  # condition: AC1-C13 | rule: BR-KB-203
  Scenario: An Unlimited-tier member cannot make a second active booking on the same day
    Given Alex is on the Unlimited tier with an active booking today on "Vinyasa Flow"
    And "Power Hour" has 3 remaining spots later today
    When Alex attempts to book "Power Hour"
    Then the booking is rejected as exceeding the daily booking cap

  @QAIA-FIT-118-021 @AC1 @P1 @negative @decision-table
  # condition: AC1-C14 | rule: BR-KB-205
  Scenario: A member under an active no-show restriction cannot book
    Given Alex is under a no-show booking restriction until a future date
    And "Vinyasa Flow" has 3 remaining spots
    When Alex attempts to book "Vinyasa Flow"
    Then the booking is rejected because Alex is under a no-show restriction

  @QAIA-FIT-118-022 @AC2 @P1 @ep
  # condition: AC2-C5, AC2-C6 | rule: BR-KB-202
  Scenario Outline: Cancellation credit outcome depends on the cutoff
    Given Alex has a confirmed booking on "Vinyasa Flow" costing 1 credit
    And the class starts in <hours-before> hours
    When Alex cancels the booking
    Then <credit-outcome>

    Examples:
      | hours-before | credit-outcome                        |
      | 4             | no credit is forfeited                |
      | 3             | 1 credit is forfeited as a late fee   |

  @QAIA-FIT-118-023 @AC2 @P1 @state-transition
  # condition: AC2-C7 | rule: BR-KB-202
  Scenario: A no-show forfeits 2 credits
    Given Alex has a confirmed booking on "Vinyasa Flow" and does not cancel it
    When the class occurs and Alex did not attend
    Then Alex's booking is marked as a no-show
    And 2 credits are forfeited

  @QAIA-FIT-118-024 @AC2 @P1 @state-transition
  # condition: AC2-C8 | rule: BR-KB-205
  Scenario: A 3rd no-show within 30 days triggers a 7-day booking restriction
    Given Alex has 2 recorded no-shows within the last 30 days
    When a 3rd no-show is recorded for Alex within that window
    Then Alex is placed under a 7-day booking restriction
    And Alex receives a warning notification

  @QAIA-FIT-118-025 @AC3 @P2 @state-transition
  # condition: AC3-C5 | rule: BR-KB-204
  Scenario: A spot freed well before class start auto-promotes the earliest waitlisted member
    Given Jordan is the earliest-joined member on the waitlist for "Vinyasa Flow"
    And "Vinyasa Flow" starts in 5 hours
    When a booked spot on "Vinyasa Flow" is cancelled
    Then Jordan is automatically booked into "Vinyasa Flow"
    And Jordan is notified

  @QAIA-FIT-118-026 @AC3 @P2 @state-transition @boundary
  # condition: AC3-C6 | rule: BR-KB-204
  Scenario: A spot freed close to class start offers a 15-minute confirmation window
    Given Jordan is the earliest-joined member on the waitlist for "Vinyasa Flow"
    And "Vinyasa Flow" starts in 1 hour
    When a booked spot on "Vinyasa Flow" is cancelled
    Then Jordan is offered the spot with a 15-minute confirmation window

  @QAIA-FIT-118-027 @AC3 @P2 @state-transition
  # condition: AC3-C8 | rule: BR-KB-204
  # not tagged @negative: nothing was refused/errored/denied for a request Jordan made — this
  # is a passive timeout cascade, not a refusal (D20 closed definition, run-b-journey.md note)
  Scenario: An unconfirmed offer near class start passes to the next waitlisted member
    Given Jordan was offered a freed spot on "Vinyasa Flow" 16 minutes ago and did not confirm
    And Sam is the next-earliest-joined member on the waitlist
    When the 15-minute confirmation window expires
    Then the spot is offered to Sam
    And Jordan remains on the waitlist without the spot

  @QAIA-FIT-118-028 @AC3 @P3 @ep
  # condition: AC3-C7 | rule: BR-KB-204 | confirms: Q5 (was [assumption] in Run A)
  Scenario: Waitlist promotion follows first-in, first-out order
    Given Jordan joined the waitlist for "Vinyasa Flow" before Sam
    And a spot on "Vinyasa Flow" frees up
    When the waitlist is processed for promotion
    Then Jordan is offered or promoted before Sam
