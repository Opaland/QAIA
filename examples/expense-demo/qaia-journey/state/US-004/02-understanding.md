---
stepsCompleted: [00-ingest, 01-review, 02-understanding]
lastStep: 02-understanding
lastSaved: 2026-07-25
---

# 02-understanding — US-004

## Reformulation

An employee submits a multi-line expense report; the system must route it through the
appropriate approval chain based on its converted total (manager only / manager+finance /
manager+finance+director), enforce data-quality gates at submission time (line age, receipts,
currency conversion), and keep an immutable, attributable audit trail of every decision. The
main risk if this misbehaves: money either leaves the company without the right sign-off
(under-approval — a control/compliance failure) or a legitimate reimbursement is wrongly
blocked or mis-routed (over-approval friction, employee-facing). Both directions matter; the
approval-chain logic (AC2/AC3/AC6) and the terminal/audit rules (AC1/AC7/AC8) carry the highest
stakes because they touch financial control, not just UX.

## Ambiguity hunt

### Adversarial pass by AC type

- **State machine (AC1/AC7)**: re-entrance check — can `draft` be reached more than once? Yes,
  via `changes-requested → draft`, and that can repeat (a report can bounce draft↔submitted
  several times before final approval/rejection). No cap on bounces is stated → assumed
  unlimited (Q9 area, low risk). Forbidden transitions: `rejected` has no outgoing transition
  (AC7, terminal) — confirmed.
- **Thresholds (AC2/AC6)**: inclusive/exclusive at both €500 and €5000 → **Q1** below.
- **Auth/permissions (AC3)**: self-approval forbidden — but only the manager case is named →
  **Q8** below.

### Cross-AC and triple-AC passes

- AC2 × AC3 → **Q2** (does "skip" narrow the amount-based chain, or escalate to a role the
  amount alone wouldn't have required?).
- AC1 × AC7 → **Q3** (can a `changes-requested`-turned-`draft` report be rejected directly, or
  only re-submitted first?).
- AC5 × AC6 → **Q6** (is the €25 receipt threshold compared against face value or the
  EUR-converted value?) — not named in the source at all; found only by crossing the two ACs
  that touch amounts.
- AC2 × AC3 × AC6 (triple, mandatory 4a pass) → **Q7** (a manager submits a foreign-currency
  report whose converted total sits near a band boundary, computed from a *stale* fallback
  rate — does the escalation/band decision still use that total as authoritative, or does
  staleness force a hold?).

## Questions (numbered, cited by downstream conditions/scenarios)

**Q1 — AC2/AC6: threshold boundary at exactly €500 and exactly €5000.**
Why it matters: routes every report; an off-by-one here silently under- or over-approves.
A close literal reading is self-consistent ("under €500" excludes 500 from band A; the closed
range "€500–€5000" includes both ends; "above €5000" excludes 5000 from band C) — so band B
would be `[500, 5000]` inclusive on both ends. But this reading depends on treating two
different phrasings ("under X" vs "X–Y") as precisely complementary, which is exactly the kind
of boundary phrasing that real implementations get wrong.
Classification: **[open]** (decision-tree rule 2 — money/threshold policy; a subtle literal
resolution exists but the point is a genuine business-policy confirmation, not something to
silently lock in). Proposed default: band B inclusive at both 500.00 and 5000.00 (the literal
reading above). Applied with `@low-confidence` on the boundary scenarios.

**Q2 — AC3: does "skip straight to the next level up" narrow the chain or escalate it?**
Why it matters: for a manager submitting a small (<€500) report, the amount-based chain is
`[manager]` only — if "skip" merely removes the manager step, the report would have **zero**
required approvers (self-approval loophole, the opposite of AC3's intent). If "skip" means
"escalate to the next role up the fixed hierarchy", the manager's own <€500 report requires
finance approval instead.
Classification: **[open]** (rule 2 — money/control policy, genuine product decision; the
"leaves zero approvers" reading is implausible given AC3's stated goal, but the *exact*
replacement rule for larger bands — where finance/director are already required — is
under-specified: does the manager step just disappear there, or does it also force one level
higher than the existing top?). Proposed default: replace the submitter's own step by the next
hierarchy role; if that role is already required later in the chain, the self-step is simply
dropped (chain shortens by one) rather than adding a further level. `@low-confidence`.

**Q3 — AC1 × AC7: can a `draft` reached via `changes-requested` be rejected directly?**
Why it matters: determines whether "terminal rejection" is reachable from two states or one,
and whether an approver must always request changes before an outright reject once a report has
looped back once.
Classification: **[assumption]** (decision-tree rule 3 — AC1's transition list names only
`submitted → {approved, rejected, changes-requested}`; `draft` has no outgoing transition to
`rejected` anywhere in the text. Reading undeclared transitions as forbidden is the standard,
low-risk state-machine convention a practitioner would apply without escalating). Proposed
default: reject is only reachable from `submitted` — a `draft` report (whether original or
looped back) must be re-submitted before it can be rejected. `@low-confidence`.

**Q4 — AC6: rate source and missing-rate fallback.**
Why it matters: silently picking the wrong rate, or the wrong fallback, changes AC2's band and
therefore who must approve.
Classification: split in two —
- Rate **source** (which provider/table is authoritative): **[open]** (rule 2, external
  dependency/compliance — genuinely unanswerable from the text; a fixed demo table stands in).
- Missing-rate **fallback** (weekend/holiday gap): **[assumption]** (rule 3 — blocking every
  weekend-dated expense forever is a worse default than using the last available rate with a
  visible staleness flag; a practitioner would pick this without escalating, though the flag
  matters). Proposed default: last available prior-date rate, report flagged `rateStale: true`.
  `@low-confidence`.

**Q5 — AC4: "within the last 90 days" measured against which clock?**
Why it matters: near the 90-day boundary, server clock vs. the employee's local timezone can
shift the pass/fail outcome by up to a day.
Classification: **[assumption]** (rule 3 — server/UTC clock is the standard backend-validation
default; the source gives no reason to prefer the client's clock, and using a client-supplied
clock would be a spoofable control anyway). `@low-confidence` only on scenarios exactly at the
90-day boundary.

**Q6 — AC5 × AC6: is the €25 receipt threshold compared in EUR-equivalent or the report's face
currency?**
Why it matters: not named anywhere in the source — found only by crossing AC5's amount rule
with AC6's conversion rule. A face-value reading lets a large foreign-currency line (e.g. 30
USD ≈ 27.5 EUR) through the *filter* inconsistently with a 24 EUR line, and vice versa near the
boundary.
Classification: **[open]** (rule 2 — money-control policy; "€25" is stated in EUR, so comparing
the EUR-converted line amount is the literal reading, but this is a control decision worth
confirming, not a low-stakes UX default). Proposed default: compare against the EUR-converted
per-line amount (same conversion AC6 already mandates for the total). `@low-confidence`.

**Q7 — AC2 × AC3 × AC6 (triple intersection): stale-rate total feeding both the band decision
and the self-approval escalation.**
Why it matters: a manager's foreign-currency report, converted with a stale fallback rate,
lands near a band boundary — does the workflow proceed on that total (band + escalation both
computed from it), or does the `rateStale` flag demand a hold until a real rate is available?
Classification: **[open]** (rule 2 — money policy at the intersection of three rules; the
source says nothing about interaction with staleness). Proposed default: the workflow proceeds
on the stale-fallback total (never silently blocking reimbursement), but the report and every
approver-facing view surface `rateStale: true` so a human can catch a wrong band before final
approval. `@low-confidence`.

**Q8 — AC3 names only the manager case: what about a self-submitting finance or director
approver?**
Why it matters: AC3's example ("if the submitter is themselves a manager") is the only role
named; a finance user or the director can also submit reports, and the source is silent on
whether the same skip-to-next-level rule generalizes to them.
Classification: **[assumption]** (rule 3 — generalizing the named example to every role in the
approval hierarchy is the safe, symmetric default; a rule that applied to managers only and
left finance/director able to approve their own reports would contradict AC3's opening clause
"an approver cannot approve their own report", which is unconditional). `@low-confidence`.

**Q9 — AC8: does creating a `draft` (before first submission) count as a recorded transition?**
Why it matters: AC8 says "every state transition records who, when…" — draft-creation is either
the initial state assignment (not a "transition" in the strict sense) or the first recorded
event.
Classification: **[assumption]** (rule 3 — recording it is strictly more auditable and low
risk; omitting it would not violate AC8 since arriving at `draft` from nothing isn't literally
a transition between two declared states, but the safer, cheap default is to record it anyway).
No `@low-confidence` needed — purely additive, doesn't change accept/refuse behavior.

## Summary table

| Q | Topic | AC(s) | Classification | Default applied |
|---|---|---|---|---|
| Q1 | Threshold boundary (500/5000) | AC2, AC6 | open | inclusive both ends in band B |
| Q2 | Skip-level semantics | AC3 | open | escalate to next hierarchy role |
| Q3 | Reject from looped-back draft | AC1, AC7 | assumption | reject only from `submitted` |
| Q4 | FX rate source / fallback | AC6 | open (source) / assumption (fallback) | last prior rate, `rateStale` flag |
| Q5 | 90-day reference clock | AC4 | assumption | server/UTC clock |
| Q6 | €25 threshold currency basis | AC5, AC6 | open | EUR-converted amount |
| Q7 | Stale total × band × escalation | AC2, AC3, AC6 | open | proceed, flag `rateStale` |
| Q8 | Self-submission beyond manager | AC3 | assumption | rule generalizes to all roles |
| Q9 | Draft-creation as recorded event | AC1, AC8 | assumption | recorded |

⚠ VALIDATION: non-interactive evaluation mode — every question above is recorded as
`simulated: default applied` (no live user arbitration in this run). All nine are carried
forward into `03-design.md` as conditions; the five `[open]` items (Q1, Q2, Q4-source, Q6, Q7)
cap the confidence of every scenario they touch at `@low-confidence`, matching the rule that an
`[open]` classification is never silently resolved.

## Knowledge capture

No `knowledge/` base exists for this project slice — proceeding without it (degraded mode,
shared-contract rule 8). None of the nine answers above were sourced from a knowledge base;
all are either literal citations or flagged defaults.

## Journey checkpoint

- Step `02-understanding`: **done**. 9 questions logged (5 open, 4 assumption, 0 answered
  outright — every threshold/policy point in this US turned out to need at least a flagged
  default, which is itself a finding: US-004 is more decision-table/threshold-dense than
  US-001, so its honest-recall ceiling surfaces proportionally more `[open]` items).
- Next step: `istqb-design`.
