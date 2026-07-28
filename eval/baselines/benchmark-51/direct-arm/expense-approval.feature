# =============================================================================
# Feature: Expense report approval workflow (US-004)
#
# As an employee, I want to submit an expense report and have it approved
# through the right chain, so that I get reimbursed correctly and the
# company keeps an auditable trail.
#
# Traceability: every scenario is tagged with @AC<n> for the acceptance
# criterion (AC1-AC8) it verifies, and carries a stable ID in its title
# (US004-AC<n>-<seq>) so it can be mapped back to the AC table in the user
# story. Priority tags (@P1/@P2/@P3) reflect business risk: P1 = incorrect
# behaviour causes wrong reimbursement, broken audit trail, or a control
# bypass (e.g. self-approval, skipped approval level); P2 = incorrect
# behaviour causes user friction or bad data but no financial/control
# breach; P3 = minor/cosmetic or very low-likelihood edge case.
#
# -----------------------------------------------------------------------
# AMBIGUITIES / UNDERSPECIFIED AREAS FLAGGED DURING TEST DESIGN
# (raised rather than silently guessed; each is also called out again as
# an inline comment next to the scenario(s) it affects, and the scenario
# is additionally tagged @needs-clarification so it can be filtered/found)
#
# 1. AC2/AC6 - boundary inclusivity: "under €500" and "€500-€5000" do not
#    state whether the €500.00 and €5000.00 boundaries themselves belong
#    to the lower or upper band. The scenarios below ASSUME "under €500"
#    is strictly < 500 (so exactly €500 requires manager+finance) and
#    "above €5000" is strictly > 5000 (so exactly €5000 requires only
#    manager+finance, not director). This is a guess made explicit here,
#    not a verified rule - it should be confirmed with product/finance
#    before these boundary scenarios are treated as ground truth.
#
# 2. AC3 - when the submitter is themselves a manager AND the report is
#    above €5000 (i.e. would normally need manager + finance + director),
#    it is not specified whether "skip straight to the next level up"
#    means (a) skip only the manager approval and keep finance + director,
#    or (b) skip both manager and finance and go straight to director, or
#    (c) something else entirely (e.g. skip to the manager's own manager
#    as an approval step). The scenario below assumes interpretation (a)
#    and is tagged @needs-clarification.
#
# 3. AC1 x AC7 interaction - a report that went submitted -> changes-
#    requested -> draft: can that draft, once re-submitted, subsequently
#    be REJECTED (making it terminal per AC7), or does "changes-requested"
#    permanently exclude the report from ever being rejected? The AC text
#    doesn't say. Scenario below assumes rejection remains possible after
#    a changes-requested round-trip, tagged @needs-clarification.
#
# 4. AC6 - no rate source is named, and it's unspecified what happens when
#    the expense date has no published rate (e.g. a weekend/bank holiday
#    for a currency pair that only publishes on business days). Scenario
#    below assumes a "fall back to the most recent prior business day's
#    rate" behaviour purely as a placeholder to make the scenario
#    executable - this is NOT confirmed and is tagged @needs-clarification.
#
# Additional gap noticed but not in the AC list at all: AC4 requires a
# line-item date to be "within the last 90 days" but never addresses a
# line-item date in the FUTURE. A future-dated line is included below as
# an extra edge case under AC4 with a comment flagging that it is not
# covered by the AC text.
# -----------------------------------------------------------------------
Feature: Expense report approval workflow

  Rule: A report moves through draft -> submitted -> approved|rejected|changes-requested (AC1)

    @AC1 @P1 @positive
    Scenario: US004-AC1-01 - Submitting a draft moves it to the submitted state
      Given an expense report "ER-1001" is in "draft" state with valid line items
      When the employee submits the report
      Then the report state becomes "submitted"
      And the state transition is recorded with who submitted it and when

    @AC1 @P1 @positive
    Scenario: US004-AC1-02 - A fully approved report reaches the approved state
      Given an expense report "ER-1002" is "submitted" and requires only manager approval
      When the manager approves the report
      Then the report state becomes "approved"

    @AC1 @P1 @positive
    Scenario: US004-AC1-03 - A rejected report reaches the rejected state
      Given an expense report "ER-1003" is "submitted"
      When the manager rejects the report with comment "Missing cost centre code"
      Then the report state becomes "rejected"

    @AC1 @P1 @positive
    Scenario: US004-AC1-04 - Changes-requested returns the report to draft for editing
      Given an expense report "ER-1004" is "submitted"
      When the manager requests changes with comment "Please attach the missing receipt"
      Then the report state becomes "draft"
      And the report remains editable by the employee

    @AC1 @P1 @positive
    Scenario: US004-AC1-05 - A report edited after changes-requested can be re-submitted
      Given an expense report "ER-1005" is in "draft" state after a changes-requested round trip
      When the employee updates the report and re-submits it
      Then the report state becomes "submitted"
      And the approval chain restarts from the first required approver

    @AC1 @P2 @negative
    Scenario: US004-AC1-06 - A report already in submitted state cannot be re-submitted
      Given an expense report "ER-1006" is already "submitted"
      When the employee attempts to submit the report again
      Then the submission is rejected with an error indicating the report is already submitted
      And the report state remains "submitted"

    @AC1 @P2 @negative
    Scenario: US004-AC1-07 - A draft report cannot be approved directly
      Given an expense report "ER-1007" is in "draft" state
      When an approver attempts to approve the report
      Then the action is rejected with an error indicating the report has not been submitted
      And the report state remains "draft"

  Rule: Approval chain depth is driven by the report total (AC2)

    @AC2 @P1 @positive
    Scenario: US004-AC2-01 - A report under 500 EUR needs only the direct manager
      Given an expense report totalling "499.99" EUR
      When the report is submitted
      Then the required approval chain is exactly ["manager"]

    @AC2 @P1 @positive
    Scenario: US004-AC2-02 - A report in the 500-5000 EUR band needs manager then finance
      Given an expense report totalling "2500.00" EUR
      When the report is submitted
      Then the required approval chain is exactly ["manager", "finance"]

    @AC2 @P1 @positive
    Scenario: US004-AC2-03 - A report above 5000 EUR needs manager, finance, then director
      Given an expense report totalling "5000.01" EUR
      When the report is submitted
      Then the required approval chain is exactly ["manager", "finance", "director"]

    # Ambiguity #1 (see file header): boundary inclusivity of 500.00 is not
    # specified by AC2. Assuming "under 500" is strictly-less-than, so an
    # exact 500.00 total falls into the manager+finance band.
    @AC2 @P1 @boundary @needs-clarification
    Scenario: US004-AC2-04 - A report totalling exactly 500.00 EUR (boundary, interpretation assumed)
      Given an expense report totalling "500.00" EUR
      When the report is submitted
      Then the required approval chain is exactly ["manager", "finance"]

    # Ambiguity #1: boundary inclusivity of 5000.00 is not specified by AC2.
    # Assuming exactly 5000.00 stays in the manager+finance band and does
    # NOT require the director.
    @AC2 @P1 @boundary @needs-clarification
    Scenario: US004-AC2-05 - A report totalling exactly 5000.00 EUR (boundary, interpretation assumed)
      Given an expense report totalling "5000.00" EUR
      When the report is submitted
      Then the required approval chain is exactly ["manager", "finance"]
      And the director is not required to approve

    @AC2 @P1 @negative
    Scenario: US004-AC2-06 - Finance cannot approve before the manager has approved
      Given an expense report totalling "2500.00" EUR is "submitted" and awaiting manager approval
      When finance attempts to approve the report before the manager has approved it
      Then the action is rejected with an error indicating it is out of approval order
      And the report state remains "submitted"

    @AC2 @P1 @negative
    Scenario: US004-AC2-07 - A report above 5000 EUR cannot become approved without director sign-off
      Given an expense report totalling "8000.00" EUR has been approved by the manager and finance
      When an attempt is made to mark the report as fully approved without director approval
      Then the action is rejected with an error indicating director approval is still required
      And the report state remains "submitted"

  Rule: An approver cannot approve their own report; manager-submitters skip a level (AC3)

    @AC3 @P1 @positive
    Scenario: US004-AC3-01 - An approver cannot approve a report they submitted themselves
      Given an employee who is also a manager submits their own expense report totalling "300.00" EUR
      When that same person attempts to approve their own report
      Then the approval attempt is rejected with an error indicating self-approval is not allowed
      And the report state remains "submitted"

    @AC3 @P1 @positive
    Scenario: US004-AC3-02 - A manager's own report skips their own approval level
      Given a manager submits their own expense report totalling "300.00" EUR
      When the report is submitted
      Then the required approval chain is exactly ["manager's manager"]
      And the submitter's own manager-level approval step is skipped

    # Ambiguity #2 (see file header): AC3 does not say which levels are
    # skipped when a manager-submitter's report is ALSO above 5000 EUR.
    # Assuming only the manager step is skipped and finance + director
    # still apply, per interpretation (a) in the header note.
    @AC3 @P1 @needs-clarification
    Scenario: US004-AC3-03 - A manager's own high-value report (interpretation assumed)
      Given a manager submits their own expense report totalling "6000.00" EUR
      When the report is submitted
      Then the required approval chain is exactly ["finance", "director"]

  Rule: Line items must have category, amount, and a date within 90 days (AC4)

    @AC4 @P1 @positive
    Scenario: US004-AC4-01 - A report where every line item has category, amount and a recent date submits successfully
      Given all line items on report "ER-2001" have a category, an amount, and a date within the last 90 days
      When the employee submits the report
      Then the submission succeeds

    @AC4 @P2 @negative
    Scenario: US004-AC4-02 - Submission is blocked when a line item has no category
      Given report "ER-2002" has a line item with no category set
      When the employee submits the report
      Then the submission is refused with a message indicating the category is required

    @AC4 @P2 @negative
    Scenario: US004-AC4-03 - Submission is blocked when a line item has no amount
      Given report "ER-2003" has a line item with no amount set
      When the employee submits the report
      Then the submission is refused with a message indicating the amount is required

    @AC4 @P1 @negative
    Scenario: US004-AC4-04 - Submission is blocked when a line item is older than 90 days
      Given report "ER-2004" has a line item dated 95 days ago
      When the employee submits the report
      Then the submission is refused with an explanatory message stating the line is outside the 90-day window

    @AC4 @P2 @boundary
    Scenario: US004-AC4-05 - A line item dated exactly 90 days ago is accepted
      Given report "ER-2005" has a line item dated exactly 90 days ago
      When the employee submits the report
      Then the submission succeeds

    # Not covered by AC4 text at all (gap noted in header): future-dated
    # line items aren't addressed. Included as a sensible extra edge case.
    @AC4 @P3 @negative @gap-not-in-ac
    Scenario: US004-AC4-06 - Submission is blocked when a line item is dated in the future
      Given report "ER-2006" has a line item dated 1 day in the future
      When the employee submits the report
      Then the submission is refused with a message indicating the date cannot be in the future

  Rule: Receipts are mandatory for any single line >= 25 EUR (AC5)

    @AC5 @P1 @positive
    Scenario: US004-AC5-01 - A line of exactly 25 EUR with a receipt attached submits successfully
      Given report "ER-3001" has a line item of "25.00" EUR with a receipt attached
      When the employee submits the report
      Then the submission succeeds

    @AC5 @P2 @positive
    Scenario: US004-AC5-02 - A line under 25 EUR without a receipt submits successfully
      Given report "ER-3002" has a line item of "24.99" EUR with no receipt attached
      When the employee submits the report
      Then the submission succeeds

    @AC5 @P1 @negative @boundary
    Scenario: US004-AC5-03 - A line of exactly 25 EUR without a receipt is refused
      Given report "ER-3003" has a line item of "25.00" EUR with no receipt attached
      When the employee submits the report
      Then the submission is refused with a message indicating a receipt is required for that line

    @AC5 @P2 @negative
    Scenario: US004-AC5-04 - A line above 25 EUR without a receipt is refused
      Given report "ER-3004" has a line item of "150.00" EUR with no receipt attached
      When the employee submits the report
      Then the submission is refused with a message indicating a receipt is required for that line

    @AC5 @P3 @negative
    Scenario: US004-AC5-05 - A report with several lines is refused if any single qualifying line lacks a receipt
      Given report "ER-3005" has one line of "10.00" EUR with no receipt and one line of "40.00" EUR with no receipt
      When the employee submits the report
      Then the submission is refused listing the "40.00" EUR line as missing its required receipt

  Rule: Non-EUR currency is converted at the expense-date rate and drives the threshold (AC6)

    @AC6 @P1 @positive
    Scenario: US004-AC6-01 - A USD line is converted at the expense date's rate and the EUR total drives the approval chain
      Given report "ER-4001" has a single line of "600.00" USD dated "2026-03-10" where the published rate for that date converts it to "550.00" EUR
      When the employee submits the report
      Then the report's converted total used for routing is "550.00" EUR
      And the required approval chain is exactly ["manager", "finance"]

    @AC6 @P2 @positive
    Scenario: US004-AC6-02 - Mixed-currency line items are each converted individually before the total is summed
      Given report "ER-4002" has one line of "100.00" USD and one line of "100.00" GBP, each converted using its own expense date's rate
      When the employee submits the report
      Then the report's converted total is the EUR-equivalent sum of both converted lines

    @AC6 @P3 @negative
    Scenario: US004-AC6-03 - Submission is blocked for an unsupported currency code
      Given report "ER-4003" has a line item in an unsupported currency code "XXX"
      When the employee submits the report
      Then the submission is refused with a message indicating the currency is not supported

    # Ambiguity #4 (see file header): no rate source is named and the
    # behaviour for a date with no published rate is unspecified. The
    # fallback below (use the most recent prior business day's rate) is
    # an assumption made purely to keep the scenario executable and must
    # be confirmed with product/finance.
    @AC6 @P1 @needs-clarification
    Scenario: US004-AC6-04 - Expense dated on a day with no published exchange rate (behaviour assumed)
      Given report "ER-4004" has a line item in "USD" dated on a bank holiday with no published rate for that date
      When the employee submits the report
      Then the system falls back to the most recent prior business day's published rate to convert the line

  Rule: A rejected report is terminal (AC7)

    @AC7 @P1 @positive
    Scenario: US004-AC7-01 - A rejected report cannot be edited
      Given an expense report "ER-5001" is in "rejected" state
      When the employee attempts to edit a line item on the report
      Then the edit is refused with a message indicating rejected reports cannot be edited

    @AC7 @P1 @positive
    Scenario: US004-AC7-02 - A rejected report cannot be re-submitted
      Given an expense report "ER-5002" is in "rejected" state
      When the employee attempts to re-submit the report
      Then the submission is refused with a message indicating a new report must be created instead
      And the report state remains "rejected"

    # Ambiguity #3 (see file header): the interaction between AC1's
    # changes-requested -> draft loop and AC7's "rejected is terminal"
    # rule is not specified - can a report that went through a
    # changes-requested round trip still later be rejected? Assuming yes.
    @AC1 @AC7 @P2 @needs-clarification
    Scenario: US004-AC7-03 - A report can still be rejected after a changes-requested round trip (interpretation assumed)
      Given report "ER-5003" went "submitted" -> "changes-requested" -> "draft" -> re-"submitted"
      When the manager rejects the re-submitted report with comment "Amount still doesn't match the receipt"
      Then the report state becomes "rejected"
      And the report becomes terminal per AC7

  Rule: Every state transition records who, when, and a comment where required (AC8)

    @AC8 @P1 @positive
    Scenario: US004-AC8-01 - An approval records the approver and timestamp
      Given report "ER-6001" is "submitted" and awaiting manager approval
      When the manager approves the report
      Then the audit trail records the approver's identity and the approval timestamp

    @AC8 @P1 @positive
    Scenario: US004-AC8-02 - A rejection with a 10+ character comment is recorded
      Given report "ER-6002" is "submitted"
      When the manager rejects it with comment "Duplicate of ER-5999"
      Then the report state becomes "rejected"
      And the audit trail records who rejected it, when, and the comment text

    @AC8 @P1 @negative
    Scenario: US004-AC8-03 - A rejection with a comment shorter than 10 characters is blocked
      Given report "ER-6003" is "submitted"
      When the manager attempts to reject it with comment "Too short"
      Then the rejection is refused with a message indicating a comment of at least 10 characters is required
      And the report state remains "submitted"

    @AC8 @P2 @negative
    Scenario: US004-AC8-04 - A rejection with an empty comment is blocked
      Given report "ER-6004" is "submitted"
      When the manager attempts to reject it with an empty comment
      Then the rejection is refused with a message indicating a comment is required
      And the report state remains "submitted"

    @AC8 @P2 @negative
    Scenario: US004-AC8-05 - A changes-requested transition with a comment shorter than 10 characters is blocked
      Given report "ER-6005" is "submitted"
      When the manager attempts to request changes with comment "Fix this"
      Then the action is refused with a message indicating a comment of at least 10 characters is required
      And the report state remains "submitted"

    @AC8 @P2 @positive
    Scenario: US004-AC8-06 - Approval does not require a comment
      Given report "ER-6006" is "submitted" and awaiting manager approval
      When the manager approves the report without providing any comment
      Then the approval succeeds
      And the report state becomes "approved"

    @AC8 @P3 @boundary @positive
    Scenario: US004-AC8-07 - A rejection comment of exactly 10 characters is accepted
      Given report "ER-6007" is "submitted"
      When the manager rejects it with comment "1234567890"
      Then the report state becomes "rejected"
      And the audit trail records the comment text
