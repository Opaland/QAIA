# =============================================================================
# Feature: Expense Report Approval Workflow
# Traceability: scenario IDs use the pattern EXP-AC<n>-<seq>, where <n> maps
# directly to the acceptance criterion (AC1..AC8) in the user story.
#
# AMBIGUITIES / UNDERSPECIFIED ITEMS FLAGGED (not silently resolved; see notes
# inline as comments next to the affected scenarios too):
#
#   [AMBIG-1] AC2 threshold boundaries: the AC gives "under €500", "€500-5000",
#   "above €5000" — it does not state whether the €500 and €5000 boundary
#   values themselves belong to the lower or upper band. I have ASSUMED
#   "under €500" is strictly < 500 (so exactly €500 falls into the
#   manager+finance band), and "above €5000" is strictly > 5000 (so exactly
#   €5000 stays in the manager+finance band, not manager+finance+director).
#   This assumption is encoded in EXP-AC2-03 and EXP-AC2-06 and should be
#   confirmed with the business owner.
#
#   [AMBIG-2] AC3 "if the submitter is themselves a manager, their report
#   skips straight to the next level up" — it's not defined what "next level
#   up" means when the report would also require finance/director approval,
#   nor what happens if the submitter's own manager is unavailable / if the
#   submitter is a director (top of chain, no "next level"). I have assumed
#   "next level up" means the chain simply starts one rung higher (manager
#   step is skipped, finance/director steps proceed as normal per AC2), and
#   I have added a scenario questioning the top-of-chain case rather than
#   guessing an answer.
#
#   [AMBIG-3] AC4 "a date within the last 90 days" does not say relative to
#   what reference point — the expense line date vs. today's date, vs. the
#   submission date, vs. the report's creation date. I have ASSUMED "today's
#   date at the moment of submission" since that is when the rule is
#   enforced per the AC text ("blocked at submission"), but this is a
#   judgment call, not a stated fact.
#
#   [AMBIG-4] AC5 "any single line >= €25" — for a line item in a foreign
#   currency (per AC6), is the €25 receipt threshold evaluated against the
#   original currency amount or the EUR-converted amount? The AC text is
#   silent. I have assumed the CONVERTED (EUR) amount is used, for
#   consistency with AC6 driving thresholds off converted totals, and
#   flagged a dedicated scenario for it.
#
#   [AMBIG-5] AC6 does not specify the source or provider of the exchange
#   rate ("the rate of the expense date") — e.g. a central bank rate, a
#   payment processor's rate, or an internally maintained rate table. This
#   cannot be tested meaningfully without that definition; scenarios below
#   treat the rate as an opaque, correctly-provided value and do not attempt
#   to verify rate sourcing/accuracy.
#
#   [AMBIG-6] AC7 says a rejected report is terminal, but does not clarify
#   whether rejection can happen directly from `changes-requested` or only
#   from `submitted`, and whether a `changes-requested` report can be
#   rejected without ever being re-submitted. I've assumed rejection is only
#   reachable from `submitted` state (per AC1's transition diagram, which
#   only lists submitted -> {approved, rejected, changes-requested}), and
#   added a negative scenario asserting changes-requested cannot be directly
#   rejected without re-submission.
#
#   [AMBIG-7] AC8's "mandatory comment of at least 10 characters" does not
#   specify whether whitespace-only or whitespace-padded input counts toward
#   the 10-character minimum (e.g. is the comment trimmed before counting?).
#   I've assumed trimmed length is what's validated and flagged this
#   explicitly rather than silently picking a behavior with no test.
#
#   [AMBIG-8] Nothing in the AC defines who may perform "changes-requested"
#   edits/re-submission if the original submitter has left the company /
#   is unavailable, nor whether a manager-submitter's report re-entering
#   `draft` after changes-requested still skips the manager-approval level
#   on re-submission (AC1 + AC3 interaction). I've assumed the skip-level
#   status persists across re-submission but have NOT written a scenario
#   asserting this since it is a pure guess with no support in the text —
#   flagging it here as an open question instead of testing it silently.
# =============================================================================

Feature: Expense report submission and multi-level approval
  As an employee
  I want to submit an expense report and have it approved through the right chain
  So that I get reimbursed correctly and the company keeps an auditable trail

  # ---------------------------------------------------------------------------
  # AC1 — State machine: draft -> submitted -> (approved | rejected | changes-requested)
  #        changes-requested -> draft -> (re-submit)
  # ---------------------------------------------------------------------------

  @P1 @positive @AC1
  Scenario: EXP-AC1-01 - Draft report can be submitted
    Given an expense report "R-1001" is in state "draft"
    And the report has at least one valid line item
    When the employee submits report "R-1001"
    Then the report state is "submitted"

  @P1 @positive @AC1
  Scenario: EXP-AC1-02 - Submitted report can be approved
    Given an expense report "R-1002" is in state "submitted"
    And an eligible approver reviews it
    When the approver approves report "R-1002"
    Then the report state is "approved"

  @P1 @positive @AC1
  Scenario: EXP-AC1-03 - Submitted report can be rejected
    Given an expense report "R-1003" is in state "submitted"
    And an eligible approver reviews it
    When the approver rejects report "R-1003" with comment "Missing valid business justification"
    Then the report state is "rejected"

  @P1 @positive @AC1
  Scenario: EXP-AC1-04 - Submitted report can have changes requested
    Given an expense report "R-1004" is in state "submitted"
    And an eligible approver reviews it
    When the approver requests changes on report "R-1004" with comment "Wrong cost center on line 2"
    Then the report state is "changes-requested"

  @P1 @positive @AC1
  Scenario: EXP-AC1-05 - Changes-requested report returns to draft for editing
    Given an expense report "R-1005" is in state "changes-requested"
    When the employee opens report "R-1005" for editing
    Then the report state is "draft"

  @P1 @positive @AC1
  Scenario: EXP-AC1-06 - Draft report re-edited after changes-requested can be re-submitted
    Given an expense report "R-1006" returned to "draft" from "changes-requested"
    And the employee has corrected the flagged line item
    When the employee re-submits report "R-1006"
    Then the report state is "submitted"
    And the approval chain restarts from the first required approval level

  @P2 @negative @AC1
  Scenario: EXP-AC1-07 - Draft report cannot be approved directly
    Given an expense report "R-1007" is in state "draft"
    When an approver attempts to approve report "R-1007"
    Then the action is refused
    And an error indicates the report has not been submitted

  @P2 @negative @AC1
  Scenario: EXP-AC1-08 - Approved report cannot transition to any other state
    Given an expense report "R-1008" is in state "approved"
    When any user attempts to change the state of report "R-1008"
    Then the action is refused
    And an error indicates the report is in a terminal state

  @P2 @negative @AC1
  Scenario: EXP-AC1-09 - Draft report cannot be re-submitted without changes after changes-requested
    Given an expense report "R-1009" returned to "draft" from "changes-requested"
    And the employee has NOT modified any line item
    When the employee attempts to re-submit report "R-1009"
    Then the action is refused
    And an error indicates the flagged issue has not been addressed

  # ---------------------------------------------------------------------------
  # AC2 — Approval chain determined by converted total (see also AMBIG-1)
  # ---------------------------------------------------------------------------

  @P1 @positive @AC2
  Scenario: EXP-AC2-01 - Report under €500 requires only manager approval
    Given an expense report totalling "€499.99"
    When the employee submits the report
    Then the required approval chain is "manager"
    And approving as manager transitions the report to "approved"

  @P1 @positive @AC2
  Scenario: EXP-AC2-02 - Report between €500 and €5000 requires manager then finance
    Given an expense report totalling "€2500.00"
    When the employee submits the report
    Then the required approval chain is "manager, finance"
    And the report only reaches "approved" after both approvals are recorded in order

  @P1 @positive @AC2
  Scenario: EXP-AC2-03 - Report exactly at €500 boundary follows the manager+finance chain
    # See AMBIG-1: assumes "under €500" is strictly less-than, so exactly
    # €500 is treated as being in the €500-5000 band.
    Given an expense report totalling "€500.00"
    When the employee submits the report
    Then the required approval chain is "manager, finance"

  @P1 @positive @AC2
  Scenario: EXP-AC2-04 - Report above €5000 requires manager, finance, then director
    Given an expense report totalling "€5000.01"
    When the employee submits the report
    Then the required approval chain is "manager, finance, director"

  @P1 @negative @AC2
  Scenario: EXP-AC2-05 - Finance cannot approve before manager on a report requiring manager+finance
    Given an expense report totalling "€2500.00" in state "submitted"
    And no approval has yet been recorded
    When the finance approver attempts to approve the report
    Then the action is refused
    And an error indicates the manager approval is still pending

  @P2 @positive @AC2
  Scenario: EXP-AC2-06 - Report exactly at €5000 boundary does not require director approval
    # See AMBIG-1: assumes "above €5000" is strictly greater-than, so
    # exactly €5000 stays in the manager+finance band.
    Given an expense report totalling "€5000.00"
    When the employee submits the report
    Then the required approval chain is "manager, finance"
    And director approval is not required

  @P2 @negative @AC2
  Scenario: EXP-AC2-07 - Director cannot approve before finance on a report requiring all three levels
    Given an expense report totalling "€6000.00" in state "submitted"
    And the manager has approved but finance has not
    When the director attempts to approve the report
    Then the action is refused
    And an error indicates the finance approval is still pending

  # ---------------------------------------------------------------------------
  # AC3 — Self-approval and manager-submitter chain skip
  # ---------------------------------------------------------------------------

  @P1 @negative @AC3
  Scenario: EXP-AC3-01 - Approver cannot approve their own report
    Given an expense report "R-2001" submitted by "Alice"
    And "Alice" is also listed as the assigned approver for the current level
    When "Alice" attempts to approve report "R-2001"
    Then the action is refused
    And an error indicates approvers cannot approve their own report

  @P1 @negative @AC3
  Scenario: EXP-AC3-02 - Approver cannot reject their own report
    Given an expense report "R-2002" submitted by "Alice"
    And "Alice" is also listed as the assigned approver for the current level
    When "Alice" attempts to reject report "R-2002" with comment "Not applicable, self-review"
    Then the action is refused
    And an error indicates approvers cannot act on their own report

  @P1 @positive @AC3
  Scenario: EXP-AC3-03 - Manager-submitted report skips the manager approval level
    Given an expense report totalling "€300.00" submitted by manager "Bob"
    When "Bob" submits the report
    Then the required approval chain does not include "manager"
    And the report is routed to the next approval level up from "Bob"

  @P2 @positive @AC3
  Scenario: EXP-AC3-04 - Manager-submitted high-value report still requires finance and director
    Given an expense report totalling "€6000.00" submitted by manager "Bob"
    When "Bob" submits the report
    Then the required approval chain is "finance, director"

  @P3 @edge @AC3
  Scenario: EXP-AC3-05 - Behavior is undefined when a manager-submitter has no level above them
    # See AMBIG-2: the AC does not define what happens when the
    # submitting manager is already at the top of the hierarchy (e.g. a
    # director submitting their own expense report). This scenario
    # documents the gap rather than asserting an invented behavior.
    Given an expense report submitted by a manager who has no manager of their own
    When the manager submits the report
    Then the system's routing behavior is undefined by the acceptance criteria
    And this must be clarified with the business before implementation

  # ---------------------------------------------------------------------------
  # AC4 — Line item validation: category, amount, date within 90 days
  # ---------------------------------------------------------------------------

  @P1 @positive @AC4
  Scenario: EXP-AC4-01 - Line item with category, amount, and recent date is valid
    Given a line item with category "Travel", amount "€45.00", and date 10 days ago
    When the employee submits the report
    Then the line item passes validation

  @P1 @negative @AC4
  Scenario: EXP-AC4-02 - Line item missing category is rejected at submission
    Given a line item with no category, amount "€45.00", and date 10 days ago
    When the employee attempts to submit the report
    Then submission is blocked
    And an error indicates the category is required for the line item

  @P1 @negative @AC4
  Scenario: EXP-AC4-03 - Line item missing amount is rejected at submission
    Given a line item with category "Travel", no amount, and date 10 days ago
    When the employee attempts to submit the report
    Then submission is blocked
    And an error indicates the amount is required for the line item

  @P1 @negative @AC4
  Scenario: EXP-AC4-04 - Line item dated beyond 90 days is blocked at submission
    Given a line item with category "Meals", amount "€20.00", and date 91 days ago
    When the employee attempts to submit the report
    Then submission is blocked
    And an explanatory message states the line item date is outside the allowed 90-day window

  @P2 @positive @AC4
  Scenario: EXP-AC4-05 - Line item dated exactly 90 days ago is accepted
    Given a line item with category "Meals", amount "€20.00", and date exactly 90 days ago
    When the employee submits the report
    Then the line item passes validation

  @P2 @negative @AC4
  Scenario: EXP-AC4-06 - Line item with future date is rejected at submission
    Given a line item with category "Meals", amount "€20.00", and a date 1 day in the future
    When the employee attempts to submit the report
    Then submission is blocked
    And an error indicates the line item date cannot be in the future

  @P2 @negative @AC4
  Scenario: EXP-AC4-07 - Report with one invalid line among several valid lines is fully blocked
    Given a report with two valid line items and one line item dated 120 days ago
    When the employee attempts to submit the report
    Then submission is blocked entirely
    And the error identifies the specific line item that failed validation

  @P3 @edge @AC4
  Scenario: EXP-AC4-08 - Line item with zero amount is rejected
    Given a line item with category "Travel", amount "€0.00", and date 10 days ago
    When the employee attempts to submit the report
    Then submission is blocked
    And an error indicates the amount must be greater than zero

  @P3 @edge @AC4
  Scenario: EXP-AC4-09 - Line item with negative amount is rejected
    Given a line item with category "Travel", amount "-€10.00", and date 10 days ago
    When the employee attempts to submit the report
    Then submission is blocked
    And an error indicates the amount must be a positive value

  # ---------------------------------------------------------------------------
  # AC5 — Mandatory receipts for lines >= €25
  # ---------------------------------------------------------------------------

  @P1 @positive @AC5
  Scenario: EXP-AC5-01 - Line item under €25 does not require a receipt
    Given a line item with amount "€24.99" and no receipt attached
    When the employee submits the report
    Then submission succeeds

  @P1 @negative @AC5
  Scenario: EXP-AC5-02 - Line item at or above €25 without a receipt blocks submission
    Given a line item with amount "€25.00" and no receipt attached
    When the employee attempts to submit the report
    Then submission is blocked
    And an error indicates a receipt is required for line items of €25 or more

  @P1 @positive @AC5
  Scenario: EXP-AC5-03 - Line item at exactly €25 with a receipt attached is accepted
    Given a line item with amount "€25.00" and a receipt attached
    When the employee submits the report
    Then submission succeeds

  @P2 @negative @AC5
  Scenario: EXP-AC5-04 - Report with a mix of lines is blocked if any single qualifying line lacks a receipt
    Given a report with a "€10.00" line without a receipt and a "€30.00" line without a receipt
    When the employee attempts to submit the report
    Then submission is blocked
    And the error identifies the "€30.00" line as missing its required receipt

  @P3 @edge @AC5
  Scenario: EXP-AC5-05 - Foreign-currency line at or above €25 after conversion requires a receipt
    # See AMBIG-4: assumes the €25 threshold is evaluated on the converted
    # EUR amount, not the original currency amount.
    Given a line item of "$27.00 USD" that converts to "€25.50" and has no receipt attached
    When the employee attempts to submit the report
    Then submission is blocked
    And an error indicates a receipt is required based on the converted amount

  # ---------------------------------------------------------------------------
  # AC6 — Currency conversion drives the approval threshold
  # ---------------------------------------------------------------------------

  @P1 @positive @AC6
  Scenario: EXP-AC6-01 - Non-EUR line items are converted using the expense date's rate
    Given a line item of "$100.00 USD" dated "2026-03-01" with a known exchange rate on that date
    When the report is submitted
    Then the line item's converted EUR amount uses the exchange rate for "2026-03-01"

  @P1 @positive @AC6
  Scenario: EXP-AC6-02 - Converted total determines the approval chain, not the original-currency total
    Given a report with foreign-currency line items whose original amounts sum below €500
    And the same line items convert to a EUR total of "€600.00"
    When the employee submits the report
    Then the required approval chain is "manager, finance"

  @P2 @positive @AC6
  Scenario: EXP-AC6-03 - Multi-currency report sums all converted lines for the threshold check
    Given a report with one "€100.00" line, one "$50.00 USD" line converting to "€46.00", and one "£30.00 GBP" line converting to "€35.00"
    When the employee submits the report
    Then the converted total used for threshold evaluation is "€181.00"

  @P3 @edge @AC6
  Scenario: EXP-AC6-04 - Exchange rate unavailable for the expense date blocks submission
    Given a line item in a foreign currency dated on a day with no published exchange rate
    When the employee attempts to submit the report
    Then submission is blocked
    And an error indicates the exchange rate could not be resolved for that date

  # ---------------------------------------------------------------------------
  # AC7 — Rejected reports are terminal
  # ---------------------------------------------------------------------------

  @P1 @negative @AC7
  Scenario: EXP-AC7-01 - Rejected report cannot be edited
    Given an expense report "R-3001" is in state "rejected"
    When the employee attempts to edit a line item on report "R-3001"
    Then the action is refused
    And an error indicates rejected reports cannot be edited

  @P1 @negative @AC7
  Scenario: EXP-AC7-02 - Rejected report cannot be re-submitted
    Given an expense report "R-3002" is in state "rejected"
    When the employee attempts to re-submit report "R-3002"
    Then the action is refused
    And an error indicates a new report must be created instead

  @P2 @positive @AC7
  Scenario: EXP-AC7-03 - Employee creates a new report after a rejection
    Given an expense report "R-3003" is in state "rejected"
    When the employee creates a new report "R-3004" covering the same expenses
    Then report "R-3004" starts in state "draft" independently of "R-3003"

  @P3 @edge @AC7
  Scenario: EXP-AC7-04 - Changes-requested report cannot be directly rejected without re-submission
    # See AMBIG-6: assumes rejection is only reachable from "submitted",
    # per the AC1 transition list.
    Given an expense report "R-3005" is in state "changes-requested"
    When an approver attempts to reject report "R-3005" directly
    Then the action is refused
    And an error indicates the report must be re-submitted before it can be rejected

  # ---------------------------------------------------------------------------
  # AC8 — Audit trail on every transition; mandatory comment for reject/changes-requested
  # ---------------------------------------------------------------------------

  @P1 @positive @AC8
  Scenario: EXP-AC8-01 - Every state transition records who and when
    Given an expense report "R-4001" is in state "submitted"
    When an approver approves report "R-4001"
    Then the audit trail records the acting user, a timestamp, and the resulting state "approved"

  @P1 @positive @AC8
  Scenario: EXP-AC8-02 - Rejection with a sufficiently long comment succeeds
    Given an expense report "R-4002" is in state "submitted"
    When the approver rejects report "R-4002" with comment "Duplicate of report R-3999"
    Then the report state is "rejected"
    And the audit trail records the comment "Duplicate of report R-3999"

  @P1 @negative @AC8
  Scenario: EXP-AC8-03 - Rejection without a comment is refused
    Given an expense report "R-4003" is in state "submitted"
    When the approver attempts to reject report "R-4003" with no comment
    Then the action is refused
    And an error indicates a comment of at least 10 characters is required

  @P1 @negative @AC8
  Scenario: EXP-AC8-04 - Rejection with a comment under 10 characters is refused
    Given an expense report "R-4004" is in state "submitted"
    When the approver attempts to reject report "R-4004" with comment "Too short"
    Then the action is refused
    And an error indicates the comment must be at least 10 characters

  @P1 @negative @AC8
  Scenario: EXP-AC8-05 - Changes-requested without a comment is refused
    Given an expense report "R-4005" is in state "submitted"
    When the approver attempts to request changes on report "R-4005" with no comment
    Then the action is refused
    And an error indicates a comment of at least 10 characters is required

  @P2 @positive @AC8
  Scenario: EXP-AC8-06 - Comment of exactly 10 characters is accepted
    Given an expense report "R-4006" is in state "submitted"
    When the approver rejects report "R-4006" with comment "1234567890"
    Then the report state is "rejected"

  @P2 @positive @AC8
  Scenario: EXP-AC8-07 - Approval does not require a comment
    Given an expense report "R-4007" is in state "submitted"
    When the approver approves report "R-4007" with no comment
    Then the report state is "approved"

  @P3 @edge @AC8
  Scenario: EXP-AC8-08 - Whitespace-padded comment under the effective length is refused
    # See AMBIG-7: assumes the comment length check is applied to the
    # trimmed string, not the raw character count.
    Given an expense report "R-4008" is in state "submitted"
    When the approver attempts to reject report "R-4008" with comment "   short   "
    Then the action is refused
    And an error indicates the comment must be at least 10 characters after trimming whitespace

  @P3 @edge @AC8
  Scenario: EXP-AC8-09 - Full audit history is preserved across a changes-requested round trip
    Given an expense report "R-4009" is in state "submitted"
    And the approver requests changes with comment "Line 3 needs a valid receipt attached"
    And the employee edits the report and re-submits it
    And the approver subsequently approves the re-submitted report
    Then the audit trail contains, in order, the submission, the changes-requested event with its comment, the re-submission, and the approval
