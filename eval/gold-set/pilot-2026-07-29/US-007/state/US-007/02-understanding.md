---
stepsCompleted: [00-ingest, 01-review, 02-understanding]
lastStep: 02-understanding
lastSaved: 2026-07-29
---

# 02-understanding — US-007

Prerequisite `01-extraction.md` present. Knowledge base: **absent at the start of this run** (`.qaia`-equivalent `knowledge/` did not exist yet) — recorded per shared-contract rule 8; `rag-build` is run right after this step to seed it, so this pass proceeds on the source alone.

## Reformulation

A course manager can turn a course into paid access by attaching a "payment required" enrolment method (a payment account, a fee, a currency, optionally a custom name/description). Any student who is not yet enrolled — logged in or anonymous — must see the fee clearly stated before any course content leaks through; an anonymous visitor is additionally routed to log in first, never straight to payment. The student picks among the account's enabled payment methods or backs out for free. The main risk if this misbehaves: content leaking to a non-paying user (a security/business defect), or a user being charged/enrolled without a completed, deliberate payment (a trust defect) — so both directions of the gate (no pay → no content; no completed pay → no enrolment/charge) matter equally.

## Ambiguity hunt — adversarial pass by AC type

- **State machine (enrolment lifecycle: not-enrolled → pending-payment → enrolled):** re-entrance — can a student cancel and retry the payment prompt repeatedly (pending re-entered many times)? Forbidden transition — can `pending-payment` reach `enrolled` without a successful payment confirmation event?
- **Auth/permissions (AC2 vs AC4):** the boundary between "logged-in student" and "guest" is explicit and stated (not an open access-boundary question) — good, no gap there. But server-side enforcement of "guest never shown a way to pay directly" against a direct request (UI-bypass) is not addressed.
- **Thresholds/quantities (fee amount, currency):** inclusive/exclusive bounds on the fee amount (can it be zero? negative?) and currency-specific decimal precision are not stated.

## Questions (numbered, complete, most impactful first)

**Q1 — Can the fee amount be zero or negative?**
Why it matters: a zero/negative "payment required" method is a contradiction in terms; needs a boundary rule for AC1 validation and downstream negative scenarios.
Proposed default: reject amounts ≤ 0 at configuration time.
Classification: money-adjacent but **mechanically forced** (a "payment required" method demanding no/negative payment is absurd, not a policy choice) → **[assumption]** (step 3 of the decision tree).
Status: **assumption** — accepted default recorded (non-interactive run).

**Q2 — What happens on a failed or declined payment (gateway declines, timeout, error)?**
Why it matters: determines whether AC3's "cancel without being enrolled or charged" guarantee also covers the failure path, not just voluntary cancellation.
Proposed default: a failed/declined payment leaves the student not enrolled and not charged, shown an error, and free to retry.
Classification: money-adjacent, but the opposite (granting access on a failed charge) is absurd → **mechanically forced** → **[assumption]**.
Status: **assumption**.

**Q3 — Does cancelling or failing a payment leave any visible trace (a pending/abandoned attempt record) for the manager?**
Why it matters: affects whether "pending" is an observable state anywhere, or purely ephemeral.
Classification: a genuine reporting/audit **policy** choice, not mechanically forced, source silent → **[open]** (step 2 of the tree — money/audit-adjacent, silent).
Status: **open** — caps confidence of any scenario asserting manager-side visibility of abandoned attempts; none generated for this point beyond flagging it.

**Q4 — Can a course have more than one "payment required" enrolment method active at once (e.g., different fee/currency tiers), each independently customizable per AC5?**
Why it matters: changes whether AC1/AC5 conditions are "per course" (singular) or "per method instance" (plural, unbounded).
Proposed default: yes — the source describes the properties of *a* method instance, not a "one per course" cardinality limit, and nothing forbids multiple instances (consistent with enrolment methods generally being instantiable more than once).
Classification: not money/protected-population/compliance; a reasonable practitioner default exists → **[assumption]**.
Status: **assumption**.

**Q5 — Does an already-enrolled student (enrolled through some other route) still see the fee prompt when visiting the course?**
Why it matters: AC2 already scopes itself to "not yet enrolled" — but this closes the loophole of a returning already-enrolled student.
Proposed default: no — AC2's own "not yet enrolled" clause mechanically excludes them.
Classification: **answered** by the source's own wording of AC2 (cited literally, not extrapolated).
Status: **answered**.

**Q6 — After a guest logs in from the AC4 prompt, do they resume the fee/payment prompt for the course they were trying to reach, or land elsewhere and have to re-navigate?**
Why it matters: a broken resume path would contradict the "same fee-required messaging" continuity AC4 implies.
Proposed default: resume — the guest is returned to the same course's fee prompt (now as a logged-in student, i.e. AC2/AC3 apply) after authenticating.
Classification: a UX-continuity point, not a money/compliance policy; safe default exists → **[assumption]**.
Status: **assumption**.

**Q7 — When a manager changes the enrolment method's custom name/description (AC5), does the change apply retroactively to what all students see going forward, or only to future configurations/new enrolments?**
Why it matters: determines whether AC5's "students see only the custom name" is a live, always-current property or a point-in-time snapshot.
Proposed default: live property — a rename is not a versioned/snapshotted fact, it changes what every future view shows, for all students, immediately.
Classification: mechanically forced by what "custom display name" ordinarily means (a name is not usually snapshotted per viewer without the source saying so) → **[assumption]**.
Status: **assumption**.

**Q8 — Does the AC5 "students see only the custom name, never the default" rule also apply to the AC4 guest-facing prompt, or only to the AC2/AC3 logged-in-student views?**
Why it matters: this is a genuine three-AC intersection (AC4's guest messaging × AC5's naming rule × the "anywhere a student can see it" scope) — exactly the kind of point a pairwise-only pass would miss.
Resolution: AC4 states the guest sees "the same fee-required messaging as a logged-in student", and AC5 states the default name "must no longer appear anywhere a student can see it for that course" (unqualified by login state). Read together, the guest-facing prompt is in scope of AC5's naming rule.
Classification: **answered** — by combining the literal wording of AC4 and AC5 (a triple-AC read, not a single-AC citation), not an extrapolation beyond either.
Status: **answered**.

**Q9 — What is shown if the configured payment account has zero payment methods enabled (a manager misconfiguration)?**
Why it matters: AC3 assumes at least one enabled method; the empty case is unaddressed.
Proposed default: the student sees the fee prompt but no selectable payment method, with a message that no payment option is currently available (fail closed — no content, no silent fallback).
Classification: an empty/degenerate-state gap, not obviously a money-policy question, but no explicit safe-default UX is stated in the source either — a wrong guess here (e.g. inventing which exact message) would be a fabrication risk → **[assumption]**, flagged `@low-confidence` given the mechanism (exact message/UI) is unspecified even though the fail-closed *principle* is safe.
Status: **assumption** (`@low-confidence` on the exact presentation, not on the fail-closed principle).

**Q10 — Is "payment account" configuration (which gateways exist, how they're credentialed) in scope of this US, or defined by a sibling story?**
Why it matters: bounds AC1/AC3 test conditions — this US tests *selecting from* enabled methods, not *how gateways get enabled*.
Classification: **[out-of-slice]** per `00-source.md`'s recorded dependency — plausibly answered in a sibling "payment gateway administration" story, not this ingested slice.
Status: **out-of-slice** — AC1/AC3 conditions treat "payment account with N enabled methods" as a given precondition, never generating the gateway-configuration mechanics themselves.

## Cross-AC interaction summary

| Interaction | Resolution |
|---|---|
| AC2 boundary vs. returning enrolled student | answered (Q5) |
| AC3 cancel/fail vs. AC1 charge guarantee | assumption (Q2) |
| AC4 guest login vs. AC2/AC3 resume | assumption (Q6) |
| AC5 rename vs. AC2/AC3/AC4 display (triple-AC) | answered (Q8) |
| AC1 account config vs. AC3 method list (empty case) | assumption/low-confidence (Q9) |

⚠ VALIDATION (non-interactive run): `simulated: accepted-as-is` for every question above — each recorded status (answered / assumption / open / out-of-slice) is the accepted outcome for this run; Q3 and Q10 remain genuinely open/out-of-slice and are **not** defaulted into a scenario beyond flagging.

## Knowledge capture handed to `rag-build`

- From Q1/Q2 (money-mechanical, generalizable beyond this US): "a payment-required flow must never grant access or record a charge on a failed, declined or cancelled payment; a required fee must be > 0."
- From Q7 (naming convention, generalizable): "a configurable display name on an enrolment/product method is a live property — renaming changes all future views, it is not versioned per prior viewer."
