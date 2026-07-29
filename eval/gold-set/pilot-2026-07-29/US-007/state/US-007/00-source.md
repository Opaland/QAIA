---
stepsCompleted: [00-ingest]
lastStep: 00-ingest
lastSaved: 2026-07-29
---

# 00-source — US-007

**Source type:** file, read exactly and only from the path the tester designated.
**Location:** `eval/gold-set/US-007-course-fee-enrolment.md`
**Capture date:** 2026-07-29
**Output root (rebased, shared-contract rule 9):** `eval/gold-set/pilot-2026-07-29/US-007/` replaces the default `.qaia/` root for this pilot run. All paths below are relative to this base.

## Triage gates

- **Empty/whitespace-only:** not fired — the source is a populated user story with a title, story statement and 5 acceptance criteria.
- **Not-a-testable-requirement gate:** not fired — describes a concrete capability (a paid enrolment method) with observable, testable behavior.
- **Abuse/illegality gate:** not fired — the feature is a legitimate paid-access control; nothing in the source frames unauthorized access, credential theft, or anti-abuse bypass.

## Sensitive-data scan

No direct personal/sensitive data found (no national IDs, card numbers, health data, real addresses/phone/email of real individuals). No redaction applied. No control characters or bidirectional-override characters detected — no sanitization needed.

## Captured text (faithful, verbatim)

> # US-007 — Paid course enrolment
>
> **As a** course manager,
> **I want** to require a payment before a student can access a course,
> **so that** the institution is paid before course content is unlocked.
>
> 1. A course manager can add a "payment required" enrolment method to a course, configuring a payment account, a fee amount, and a currency.
> 2. A logged-in student who is not yet enrolled and visits a course requiring payment sees a clear prompt stating that payment is required, showing the exact fee amount, before any course content is shown to them.
> 3. From that prompt, the student can choose a payment method from those enabled on the configured payment account (e.g. a specific payment gateway), and can also cancel out of the payment flow without being enrolled or charged.
> 4. An anonymous visitor (guest, not logged in) who reaches a course requiring payment sees the same fee-required messaging as a logged-in student, but is also prompted to log in — a guest is never shown a way to pay directly without first authenticating.
> 5. A course manager can give the payment-required enrolment method a custom display name and description, distinct from the default method name. Once customized, students see only the custom name — the generic default method name must no longer appear anywhere a student can see it for that course, though the manager can still see it was built from the default method in the management view.

Note: the gold-set header framing ("sourced from Moodle...", "faithful business-language derivation") and the pointer to the held-out raw oracle feature file were present above the story in the source file but are provenance metadata, not requirement text — they are recorded here for traceability only and were not used to derive any test condition. The referenced raw oracle file was **not opened**.

## Referenced artifacts not analyzed

None — no attachments, mockups or links in the source.

## Dependencies (out-of-slice terms/sibling stories)

- **"payment account"** — configuring a payment account (which payment gateways exist, how they are enabled/credentialed) is referenced but not defined in this slice. Likely lives in a sibling "payment gateway administration" story. Flagged out-of-slice.
- **"payment methods enabled on the configured payment account"** (AC3) — the set of available gateways per account is external configuration, not defined here.

## US-ID

Proposed: `US-007` (matches the gold-set file's own numbering; no external tracker key present).

⚠ VALIDATION (non-interactive run): `simulated: accepted-as-is` — US-ID `US-007` confirmed.
⚠ VALIDATION (non-interactive run): `simulated: accepted-as-is` — captured document confirmed as the right source/version (single read of the designated file, nothing else opened).

## Gates & redaction summary

- Gates fired: none.
- Redaction: none needed, 0 items masked.
