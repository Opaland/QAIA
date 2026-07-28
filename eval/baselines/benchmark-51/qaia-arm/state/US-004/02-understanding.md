---
stepsCompleted: [00-ingest, 01-review, 02-understanding]
lastStep: 02-understanding
lastSaved: 2026-07-28
---

# 02-understanding — US-004

## Reformulation

An employee needs to submit an expense report so it is reviewed by the right chain of
approvers and reimbursed. The system must route each report through manager, finance and
director approval depending on its (currency-converted) amount, prevent anyone from approving
their own report, enforce data-quality rules on individual expense lines (recent date,
mandatory fields, receipts above a value threshold), and keep a complete, tamper-evident audit
trail of every decision. The main risk if this misbehaves: money is reimbursed without a valid
approval chain (financial control failure), or a legitimate report is stuck/blocked incorrectly
(employee friction) — both are audit and compliance-relevant, since the story's own "so that"
names both reimbursement correctness and an auditable trail as the goals.

## State × event table (adversarial pass, CT-MBT discipline — built before deriving conditions)

States: `draft`, `submitted`, `approved`, `rejected`, `changes-requested`.
Events: `submit`, `approve` (final required level), `reject`, `request-changes`, `edit-resubmit`.

| State \ Event | submit | approve | reject | request-changes | edit-resubmit |
|---|---|---|---|---|---|
| draft | → submitted | forbidden | forbidden | forbidden | n/a |
| submitted | forbidden (already submitted) | → approved | → rejected | → changes-requested | forbidden |
| approved | forbidden | forbidden | forbidden | forbidden | forbidden (terminal — see Q9) |
| rejected | forbidden | forbidden | forbidden | forbidden | forbidden (terminal, AC7) |
| changes-requested | forbidden | forbidden | forbidden | forbidden | → draft |

Gap surfaced by the table itself: `submitted` is a **single** state even though AC2 requires up
to three sequential human approvals (manager → finance → director) inside it. The table above
cannot represent "which approver is currently pending" — that gap is Q5 below.

## Ambiguity hunt — questions

Numbered, gap-free, most impactful first. Each carries: why it matters, my proposed default,
and its classification per the mandatory decision tree (rule cited in brackets).

**Q1 [AC2, AC6] — Threshold boundary inclusivity at exactly €500.00 and exactly €5000.00.**
"under €500" (strict <500) and "€500–€5000" and "above €5000" (strict >5000) are complementary
in prose but the AC never states which band owns the boundary value itself. Matters because a
report of exactly €500.00 or exactly €5000.00 picks a different approval chain length.
Proposed default: complementary reading — the middle band is inclusive at both ends (€500.00
and €5000.00 both route through manager+finance, not the single-approval or director tier).
Classification: **`[open]`** — money-policy boundary (decision tree step 2: money/billing,
source silent on the exact case).

**Q2 [AC3] — "Skip to the next level up" for a manager-submitter: skip only the manager step, or
something broader?** AC3 only says the report "skips straight to the next level up" without
saying whether finance/director steps (if the amount requires them) still happen normally.
Matters because it changes how many approvals a manager's own large report gets. Proposed
default: only the manager step is skipped; finance and/or director steps proceed exactly as
AC2's amount tier would otherwise require. Classification: **`[open]`** — money/process policy,
source silent.

**Q3 [AC1 × AC2 × AC3, triple interaction] — A manager submits their own report under €500 (the
single-approval tier).** AC2's only required approval at this tier is "the employee's direct
manager"; AC3 says a manager-submitter's report "skips to the next level up." At this tier there
is no level above manager. Does the report then require **zero** human approvals (effectively
auto-approved), or is there an implicit fallback approver this US never names? This is a real
gap only visible where all three ACs meet — not caught by reading any single AC. Proposed
default: none confidently proposable without inventing a fallback-approver rule the source never
states; if forced to generate, the safe default is "route to the next-lowest uninvolved level
(finance) even below €500," but this is genuinely a product decision. Classification:
**`[open]`** — compliance-relevant (a report reimbursed without any human check is exactly the
class of gap AC8's audit-trail goal exists to prevent).

**Q4 [AC1 × AC7] — Can a report that returns to `draft` via `changes-requested` and is
re-submitted subsequently be rejected (becoming terminal at that point)?** AC1's transition rule
`submitted → (approved | rejected | changes-requested)` is stated generally, and the
`changes-requested → draft → re-submit` loop re-enters `submitted` with no stated restriction on
which of the three outcomes can occur on a later cycle. Reading AC1 and AC7 together, AC7 says a
*rejected* report is terminal — it does not say a *previously changes-requested* report is exempt
from ever reaching `rejected`. Classification: **answered** (cited: AC1's general transition rule
applies on every entry into `submitted`, and AC7 only restricts what happens *after* rejection,
not before it) — not a citation-of-the-wrong-case per the M1 caution, because the general rule
does literally cover this exact case, it doesn't need a symmetric extension.

**Q5 [AC1 × AC2] — How is partial approval progress tracked inside the single `submitted` state,
and can any approver in the chain (not just the last one) trigger `reject`/`changes-requested`?**
The state table above cannot express "manager approved, awaiting finance." Matters directly for
testability: a finance-level reject and a manager-level reject may need to be distinguishable in
the audit trail (AC8), and it's unclear whether an approver whose level already signed off can
act again. Proposed default: only the currently-pending level's approver may act; a
prior-approved level is locked and cannot re-act. Classification: **`[open]`** — no safe,
uncontestable default (this is a real state-model design gap, not a matter of picking a plausible
value).

**Q6 [AC4] — Reference clock for "within the last 90 days."** Every duration must be pinned to a
clock (rule from the skill's checklist). Matters for a line dated exactly at the boundary near
midnight in different timezones. Proposed default: measured as server-side UTC calendar date at
submission time (not the line's creation time, not the employee's local timezone), day-level
granularity. Classification: **`[assumption]`** — technical/mechanical, a reasonable practitioner
default, not a policy choice.

**Q7 [AC5 × AC6, cross-AC interaction] — Is the €25 receipt-mandatory threshold applied to the
original line currency amount, or to the EUR-converted amount?** Matters for non-EUR lines near
the boundary — a line could sit on opposite sides of €25 depending on which amount is tested.
Proposed default: apply to the original line-currency amount (receipts are typically collected
at entry time, before any conversion is computed for approval routing). Classification:
**`[open]`** — money policy, materially changes which lines are refused, source silent on the
interaction.

**Q8 [AC6] — Which rate source, and what happens for a weekend/holiday expense date with no
published rate?** Matters because it changes the exact converted total (and therefore the AC2
tier) for any non-EUR report near a boundary. Proposed default: ECB daily reference rate; if
none exists for the expense date, use the most recent prior business day's rate. Classification:
**`[open]`** — money/data-rule policy, no uncontestable default, source completely silent.

**Q9 [AC1] — Is `approved` terminal like `rejected` (AC7 states terminality only for
`rejected`)?** Matters for whether an approved report can later be corrected/reversed (e.g. an
audit correction). Proposed default: `approved` is also terminal for this workflow (no further
edits) — consistent with reimbursement having been triggered; AC7's explicitness about
`rejected` reads as clarifying the one non-obvious case (a rejection looking recoverable),
not as implying `approved` is reversible by omission. Classification: **`[assumption]`** — a
reasonable practitioner default, not a genuine open policy question.

**Q10 [AC3] — Does the self-approval-skip rule generalize to every level (finance, director), or
is it scoped to the manager case the AC exemplifies?** AC3's own rationale ("an approver cannot
approve their own report") is stated as a general principle before the manager example.
Proposed default: the rule generalizes — whenever the submitter holds the role that would
approve at the pending level, that level is skipped in favor of the next one up.
Classification: **`[assumption]`** — the general principle is explicit in the AC's first
clause; only the *example* is manager-specific, so generalizing is a low-risk, well-grounded
default rather than a bare guess.

## Summary
- Total questions: 10 (bounded at the ~10/pass guardrail).
- answered: 1 (Q4)
- assumption: 3 (Q6, Q9, Q10)
- open: 6 (Q1, Q2, Q3, Q5, Q7, Q8)
- ACs touched by at least one `[open]` question: **AC1, AC2, AC3, AC5, AC6** (5 of 8).
  AC4 carries only an `[assumption]`; AC7 carries only an `answered` interaction; AC8 raised no
  question in this pass.

⚠ VALIDATION per question: `simulated: accepted-as-is` (assumptions accepted as working
assumptions; open items remain open — their proposed defaults are carried forward so
`testbook-generate` can still emit `@low-confidence` scenarios per its documented rule for
`[open]` items, rather than blocking generation).
