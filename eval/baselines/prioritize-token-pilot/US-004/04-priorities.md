---
stepsCompleted: [00-ingest, 01-review, 02-understanding, 03-design, 04-priorities]
lastStep: 04-priorities
lastSaved: 2026-07-25
---

# 04-priorities — US-004 (risk-based, human-arbitrated)

Prerequisite: `03-design.md` (37 test conditions across AC1-AC8 + 2 cross-cutting groups, 17
`[req-neg]`) — present, used as the sole input to this step together with
`02-understanding.md` for the `[open]`/`[assumption]` classification of each cited question.

## Guardrails applied before scoring

- **Regulated-context default (D2) — deliberately NOT applied.** The `prioritize` guardrail says
  a regulated-context project treats traceability-relevant conditions as impact 3 by default.
  `00-source.md` explicitly flags this slice as "Domain: finance/HR, **non-medical**", and QAIA's
  documented niche v1 (D2) is medical/regulated software — this project is outside that niche.
  Impact 3 is still assigned to a number of conditions below (approval-chain integrity,
  self-approval, IDOR, audit-trail completeness), but on each condition's **own** financial-control
  merits (unauthorized-approval / data-loss-of-compliance-record risk), not as a blanket
  regulated-project default. Said so here per the guardrail's instruction to disclose when (and,
  symmetrically, when not) it is applied.
- **Git-history signal — not used.** No target repo path was named by the user for this session
  (shared-contract/skill rule: never scan or infer a repo the user did not name). No `@history(...)`
  citation appears anywhere below; every probability score rests only on the condition's own
  complexity/ambiguity as read from `03-design.md` / `02-understanding.md`. Absence of this signal
  is not treated as evidence of low risk on any condition.

## Scores

Legend — Impact: 1 cosmetic / 2 degraded service / 3 safety-regulatory-data-loss (interpreted here
as "financial-control or audit-record integrity failure", the closest fit in a non-regulated
finance/HR domain). Probability: 1 stable & well-understood / 2 boundary-prone or structurally
complex / 3 new/complex logic **or** built on an `[open]` question. Priority = impact × probability
→ **P1 ≥ 6 / P2 3-4 / P3 ≤ 2**. `@low-conf(Qn)` reproduces the `03-design.md` tag when the score
(almost always probability) is raised because the condition is built on an `02-understanding.md`
question; `[open]` questions push probability to 3, `[assumption]` questions to 2 (open = genuine
unresolved product ambiguity, higher defect odds than a standard practitioner default).

| Condition | Impact | Prob. | Priority | Rationale |
|---|---|---|---|---|
| AC1-C1 | 2 | 1 | **P3** | Core happy path (draft→submitted) — catastrophic if broken, but the simplest, most-exercised path in any test pass; low defect odds. |
| AC1-C2 | 2 | 2 | **P2** | Re-entrant loop (`changes-requested→draft`, repeatable) — structurally more complex than a linear transition. |
| AC1-C3 | 2 | 2 | **P2** | Re-submit after loop-back — same re-entrancy risk class as AC1-C2. |
| AC1-C4 | 2 | 2 | **P2** | `[req-neg]` guard against re-submitting a non-draft report — state-guard omission is a common real-world defect. |
| AC1-C5 | 3 | 2 | **P1** | `[req-neg]` guard against editing a non-draft report — a missed guard lets a submitter alter amounts after an approver has already reviewed them, a fraud/control vector, not just a UX slip. |
| AC1-C6 | 1 | 2 | **P3** | `[req-neg]` reject-only-from-`submitted` guard. `@low-conf(Q3)` — built on an `[assumption]` (undeclared `draft→rejected` transition read as forbidden); low real-world consequence even if wrong (a process-ordering oddity, not a control bypass). |
| AC2-C1 | 3 | 2 | **P1** | Just-under-€500 boundary → 1 approval. Wrong band = wrong approver set, a control failure; boundary values are a classic off-by-one defect class. |
| AC2-C2 | 3 | 3 | **P1** | Exactly €500.00 → 2 approvals. `@low-conf(Q1)` — built on an `[open]` question (inclusive/exclusive reading at the literal band edge); same control stakes as AC2-C1, higher defect odds because the spec itself is unconfirmed. |
| AC2-C3 | 3 | 3 | **P1** | Exactly €5000.00 → 2 approvals (band B upper end). `@low-conf(Q1)` — same open threshold question, opposite edge. |
| AC2-C4 | 3 | 2 | **P1** | Just-above-€5000 boundary → 3 approvals, drives to `approved`. Control-critical band edge, no open question but boundary-prone. |
| AC2-C5 | 3 | 2 | **P1** | `[req-neg]` out-of-order/wrong-role approver refused — an unenforced chain-order check lets an approval happen out of sequence, i.e. a bypass of the control the whole AC exists for. |
| AC3-C1 | 3 | 2 | **P1** | `[req-neg]` self-approval refused regardless of role/band — the textbook fraud vector this AC targets; the check itself is simple but easy to get subtly wrong across roles. |
| AC3-C2 | 3 | 3 | **P1** | Manager `<€500` self-submit → step replaced by finance. `@low-conf(Q2)` — built on an `[open]` question (does "skip" narrow or escalate the chain); getting this wrong in the narrowing direction reopens the exact self-approval loophole AC3 forbids. |
| AC3-C3 | 3 | 3 | **P1** | Manager `>€5000` self-submit → manager step dropped, finance/director remain. `@low-conf(Q2)` — same open question, larger-band case. |
| AC3-C4 | 3 | 2 | **P1** | Finance self-submit generalizes the skip rule. `@low-conf(Q8)` — built on an `[assumption]` (generalizing the named manager example to every role); same control stakes as AC3-C1-C3, one notch lower probability since the generalization is the safer, more constrained default (not a genuinely open policy question). |
| AC4-C1 | 2 | 1 | **P3** | `[req-neg]` line missing category/amount/date refused — plain required-field validation, well-understood, stable. |
| AC4-C2 | 2 | 2 | **P2** | Line dated exactly 90 days ago accepted (inclusive boundary). `@low-conf(Q5)` — built on an `[assumption]` (server/UTC clock reference); boundary-prone regardless. |
| AC4-C3 | 2 | 2 | **P2** | `[req-neg]` line dated 91 days ago blocked — boundary edge one day past AC4-C2, same off-by-one risk class. |
| AC5-C1 | 2 | 2 | **P2** | Line just under €25-equivalent, no receipt, accepted — boundary-prone threshold enforcement. |
| AC5-C2 | 2 | 2 | **P2** | `[req-neg]` line at exactly €25-equivalent, no receipt, refused — same boundary, negative side. |
| AC5-C3 | 1 | 1 | **P3** | Line ≥€25 with receipt attached accepted — simple positive path once the threshold logic above is covered. |
| AC5-C4 | 2 | 3 | **P1** | `[req-neg]` non-EUR line, face value <25 but EUR-equivalent ≥25, no receipt, refused. `@low-conf(Q6)` — built on an `[open]` question (face-value vs EUR-converted comparison basis) found only by crossing AC5×AC6; genuinely new cross-cutting logic, not just a boundary restatement. |
| AC6-C1 | 3 | 2 | **P1** | Non-EUR total converted correctly, converted total drives AC2's band — feeds directly into the approval-chain control; a conversion defect silently mis-routes the same way a wrong boundary would. |
| AC6-C2 | 3 | 3 | **P1** | `[req-neg]` currency/date pair with no resolvable rate refused at submission. `@low-conf(Q4)` — built on the `[open]` half of Q4 (authoritative rate source unspecified in the source); if the guard silently falls through instead of refusing, an undefined rate could drive a wrong band — same severity class as the approval-chain conditions above. |
| AC6-C3 | 2 | 2 | **P2** | Weekend/holiday gap accepted using last available prior rate, report flagged `rateStale`. `@low-conf(Q4)` — built on the `[assumption]` half of Q4 (fallback policy); lower probability than AC6-C2 because the assumption is a constrained, low-risk practitioner default rather than an open policy call. |
| AC6-C4 | 3 | 3 | **P1** | Manager's foreign-currency report, stale-fallback total near a band boundary, still drives both band and self-approval escalation. `@low-conf(Q7)` — built on the `[open]` triple-intersection question (AC2×AC3×AC6); the single most complex condition in the set (three rules composed under uncertainty) feeding a control-critical decision. |
| AC7-C1 | 2 | 1 | **P3** | `[req-neg]` a `rejected` report cannot be edited — simple immutability guard, well understood; supports the audit-trail integrity goal but doesn't itself move money. |
| AC7-C2 | 2 | 1 | **P3** | `[req-neg]` a `rejected` report cannot be re-submitted — same guard class as AC7-C1. |
| AC8-C1 | 2 | 2 | **P2** | `[req-neg]` rejecting without a comment, or under 10 characters, refused — supports the explicit "auditable trail" story goal; boundary-prone length check. |
| AC8-C2 | 2 | 2 | **P2** | `[req-neg]` requesting changes without a comment, or under 10 characters, refused — same class as AC8-C1. |
| AC8-C3 | 1 | 2 | **P3** | Comment of exactly 10 characters accepted — once the gate above works, this is a minor edge (a false rejection is an annoyance, not a control failure); still boundary-prone. |
| AC8-C4 | 1 | 1 | **P3** | Approving a report does not require a comment — negative-of-a-negative, simple to implement correctly. |
| AC8-C5 | 3 | 2 | **P1** | Every transition (create, submit, approve, reject, changes-requested) recorded with who/when — this **is** the story's explicit "auditable trail" promise; a missing record on any one code path is a real data-loss-of-compliance-record risk, and cross-cutting logic is easy to miss on one of several paths. |
| AC-auth-C1 | 3 | 1 | **P2** | `[req-neg]` creating a report without authentication refused (401) — authentication bypass is severe, but this class of check is typically enforced generically by framework/middleware, well understood, low defect odds. |
| AC-auth-C2 | 3 | 1 | **P2** | `[req-neg]` deciding on a report without authentication refused (401) — same reasoning as AC-auth-C1. |
| AC-auth-C3 | 3 | 3 | **P1** | `[req-neg]` an employee editing another employee's draft refused without disclosing existence (404, not 403) — object-level authorization (IDOR) is a well-known, easy-to-miss defect class, and the specific 404-vs-403 nuance adds further odds of an incomplete implementation; the underlying data is financial. |
| AC-list-C1 | 1 | 1 | **P3** | Employee with no reports sees an explicit empty state — cosmetic UX, trivial to implement correctly. |

## Priority summary

**16 P1 / 12 P2 / 9 P3** (37 total, matching `03-design.md`'s condition count).

`[req-neg]` conditions (17 total) skew toward P1/P2 as expected (control/guard failures carry
higher impact than their positive-path counterparts), but not uniformly — three req-neg conditions
landed P3 (AC1-C6, AC4-C1, AC7-C1/C2 at P3 too) where the guard itself is simple and the failure
mode's consequence is process-level rather than a financial-control bypass. This asymmetry is the
point of risk-based scoring: `[req-neg]` tagging (ADR 0001 gate) guarantees the condition is
*generated*, not that it is automatically P1.

## ⚠ VALIDATION

Non-interactive evaluation mode — no live user available to arbitrate. Every score above is
recorded as `simulated: default applied` (shared-contract rule 3, first-class status) rather than
a human-adjusted table. No override reasons to record (no human arbitration occurred in this run);
all 37 rows are carried into `testbook-generate` as-proposed, and are surfaced as **pending human
review** in the eventual synthesis's arbitration list per rule 3.

## Journey checkpoint

- Step `04-priorities`: **done**. 16 P1 / 12 P2 / 9 P3. Scope: full-breadth (all 37 `03-design.md`
  conditions scored — none deferred).
- Every P1/P2 rationale above is written to survive into `testbook-generate`'s coverage-matrix
  rationale column and synthesis, per the `prioritize` skill's deliverable rule (rubric dim. 9) —
  none of this reasoning lives only in this internal state file.
- Next step: `testbook-generate`. Tell the user generation will cover P1 (16) and P2 (12) fully;
  P3 (9) coverage is their call (quota trade-off, Q22).
