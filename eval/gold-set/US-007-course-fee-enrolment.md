# US-007 — Paid course enrolment

> Gold set item, sourced from a real product (Moodle, `moodle/moodle`, GPLv3,
> `public/enrol/fee/tests/behat/fee.feature`). Domain: education / LMS course enrolment,
> non-medical. The AC below are a faithful business-language derivation from reading the real
> scenario, not a copy of its Gherkin steps or test data. Original raw oracle kept at
> `eval/gold-set/oracle-2026-07-29/moodle-fee-raw.feature` for post-hoc comparison — NOT given
> to any generation skill.

## User story

**As a** course manager,
**I want** to require a payment before a student can access a course,
**so that** the institution is paid before course content is unlocked.

## Acceptance criteria

1. A course manager can add a "payment required" enrolment method to a course, configuring a
   payment account, a fee amount, and a currency.
2. A logged-in student who is not yet enrolled and visits a course requiring payment sees a
   clear prompt stating that payment is required, showing the exact fee amount, before any
   course content is shown to them.
3. From that prompt, the student can choose a payment method from those enabled on the
   configured payment account (e.g. a specific payment gateway), and can also cancel out of the
   payment flow without being enrolled or charged.
4. An anonymous visitor (guest, not logged in) who reaches a course requiring payment sees the
   same fee-required messaging as a logged-in student, but is also prompted to log in — a guest
   is never shown a way to pay directly without first authenticating.
5. A course manager can give the payment-required enrolment method a custom display name and
   description, distinct from the default method name. Once customized, students see only the
   custom name — the generic default method name must no longer appear anywhere a student can
   see it for that course, though the manager can still see it was built from the default method
   in the management view.
