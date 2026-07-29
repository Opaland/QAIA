---
stepsCompleted: [00-ingest, 01-review]
lastStep: 01-review
lastSaved: 2026-07-29
---

# 01-extraction — US-007

Prerequisite `00-source.md` present. Confirmed structure below.

## Story

**As a** course manager,
**I want** to require a payment before a student can access a course,
**so that** the institution is paid before course content is unlocked.

## Acceptance criteria (stable numbering — never renumbered downstream)

- **AC1** — A course manager can add a "payment required" enrolment method to a course, configuring a payment account, a fee amount, and a currency.
- **AC2** — A logged-in student who is not yet enrolled and visits a course requiring payment sees a clear prompt stating that payment is required, showing the exact fee amount, before any course content is shown to them.
- **AC3** — From that prompt, the student can choose a payment method from those enabled on the configured payment account, and can also cancel out of the payment flow without being enrolled or charged.
- **AC4** — An anonymous visitor (guest, not logged in) who reaches a course requiring payment sees the same fee-required messaging as a logged-in student, but is also prompted to log in — a guest is never shown a way to pay directly without first authenticating.
- **AC5** — A course manager can give the payment-required enrolment method a custom display name and description, distinct from the default method name. Once customized, students see only the custom name; the default name must not appear anywhere a student can see it for that course, though the manager can still see it was built from the default method in the management view.

## Business rules/constraints found outside the numbered AC list

- BR-a: content is gated strictly on payment success — "before course content is unlocked" (story) and "before any course content is shown to them" (AC2) state the gate twice, in the story and in AC2; treated as one rule, not two.
- BR-b: the fee amount shown must be exact (AC2: "showing the exact fee amount") — no rounding/approximation language permitted downstream.

## Referenced artifacts not analyzed

None.

## Content present but not classifiable

None — every sentence of the source maps to the story, an AC, or one of the two business rules above.

## What was NOT found (explicitly listed, not invented)

- No stated behavior for a **failed/declined** payment.
- No stated behavior for **multiple** payment-required methods on the same course.
- No stated retention/visibility rule for a **cancelled/abandoned** payment attempt (is it recorded anywhere?).
- No stated currency/amount validation rules (min/max, decimals, zero/negative).
- No stated behavior for what a guest sees/does **after** logging in (resume vs. restart).
- No stated behavior when the configured payment account has **zero** enabled payment methods.

⚠ VALIDATION (non-interactive run): `simulated: accepted-as-is` — extraction confirmed as complete and correctly split; the "not found" list above is carried forward as-is into `need-understanding`.
