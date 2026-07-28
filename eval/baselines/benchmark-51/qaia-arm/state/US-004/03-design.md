---
stepsCompleted: [00-ingest, 01-review, 02-understanding, 03-design]
lastStep: 03-design
lastSaved: 2026-07-28
---

# 03-design — US-004

Knowledge base: **absent** (no `knowledge/index.md` for this project's own `.qaia/`-equivalent
base was found; `examples/*/knowledge` and `eval/baselines/rag-recall-gain/knowledge` belong to
other fixtures, not this run). Degraded mode recorded per shared-contract rule 8 — proceeding on
the source + understanding checkpoint alone. `design.knowledgeApplied = []`.

## AC → technique map

- **AC1** (report lifecycle) → **State transition**. Explicit state × event table built in
  `02-understanding.md` first (CT-MBT/D95 discipline), conditions derived from the completed
  table, not picked opportunistically from prose.
- **AC2** (amount-tiered approval chain) → **Boundary value analysis** on the €500/€5000
  thresholds (exact wording, using Q1's proposed default) + **Decision table** for which roles
  approve at which tier.
- **AC3** (no self-approval / skip-to-next-level) → **Decision table** (submitter role × pending
  approver role) combined with AC2's tiers — **Domain analysis**, since amount-tier and
  submitter-role are two related variables each carrying their own partitions that need combined
  coverage, not independently tested.
- **AC4** (line-item mandatory fields + 90-day window) → **Equivalence partitioning** (missing
  field classes) + **Boundary value analysis** (day 90 vs day 91 from the reference clock fixed
  by Q6).
- **AC5** (receipt mandatory ≥ €25) → **Boundary value analysis** (€24.99/€25.00/€25.01, the
  stated boundary is explicit and inclusive) + a **Decision table** cell for the AC5×AC6
  currency-timing interaction (Q7).
- **AC6** (currency conversion drives AC2's threshold) → **Equivalence partitioning** (EUR vs
  non-EUR) + **Metamorphic testing** (the exact converted total depends on an unsourced rate —
  Q8 — so the checkable property is the *relation* "double the input amount → ~double the
  converted total," not a fabricated precise figure) + **Error guessing** (unsupported currency
  code, per the systematic-expansion reflex, anchored on the Q8 gap).
- **AC7** (rejected is terminal) → **State transition** (forbidden transitions out of `rejected`).
- **AC8** (audit trail + mandatory comment) → **Boundary value analysis** (comment length 9 vs 10
  chars) + **Equivalence partitioning** (which transition kinds require a comment).

## Systematic coverage expansion (3c reflex, mandatory)

- **CRUD reflex on the `report` entity**: the source only describes create→submit→approve/
  reject/changes-requested. It never states whether a `draft` report can be deleted/cancelled
  before submission. Derived condition `EXP-1`, tagged `[assumption]`/`@low-confidence`
  ("draft delete allowed" is the safe low-risk default for a non-destructive-to-others action).
- **Authorization & server-side enforcement reflex** (the most commonly missed class): the
  source never states who may submit/approve, so two conditions are derived by reflex:
  `EXP-2` — a non-approver role attempting to approve someone else's report (IDOR-style
  cross-tenant access) is blocked; `EXP-3` — an unauthenticated/no-session attempt to
  submit/approve is blocked, enforced server-side even bypassing any UI. Both `[req-neg]`,
  `[assumption]`/`@low-confidence` since the source never names a role/auth model explicitly,
  but "deny by default" is the standard safe default for a destructive/sensitive action
  (approval/money movement), consistent with the istqb-design guardrail on default-deny for
  dangerous actions.
- **Ceiling — explicitly NOT generated** (per the "do not hallucinate to chase recall" guardrail):
  whether the manager/finance/director role chain is configurable per department, cost-center or
  region is config/feature-flag-driven behavior this thin US cannot answer — flagged as a gap for
  the user/knowledge base, not invented as a scenario.

## Derived test conditions

Numbered `ACn-Cm`; `[req-neg]` = required-negative (ADR 0001 gate); `[open:Qn]` /
`[assumption:Qn]` = inherits the cited question's status and confidence per the shared contract.

### AC1 — lifecycle (state transition)
- AC1-C1 draft → submitted (happy path)
- AC1-C2 submitted → approved (final required level reached)
- AC1-C3 submitted → rejected `[req-neg]`
- AC1-C4 submitted → changes-requested
- AC1-C5 changes-requested → draft (return for editing)
- AC1-C6 draft (post changes-requested) → submitted (re-submission)
- AC1-C7 forbidden: draft → approved directly (skipping submitted) `[req-neg]`
- AC1-C8 forbidden: approved → any further transition `[req-neg]` `[assumption:Q9]`
  `@low-confidence`
- AC1-C9 forbidden: an approver whose level already signed off acts again on the same report
  `[req-neg]` `[open:Q5]` `@low-confidence`

### AC7 — terminal rejection (state transition)
- AC7-C1 forbidden: edit a rejected report `[req-neg]`
- AC7-C2 forbidden: re-submit a rejected report `[req-neg]`
- AC7-C3 a new report can be created after a rejection (distinct entity, happy path)

### AC2 — amount-tiered approval chain (BVA + decision table)
- AC2-C1 amount = €499.99 → manager only
- AC2-C2 amount = €500.00 (boundary) → manager + finance `[open:Q1]` `@low-confidence`
- AC2-C3 amount = €500.01 → manager + finance
- AC2-C4 amount = €4999.99 → manager + finance
- AC2-C5 amount = €5000.00 (boundary) → manager + finance `[open:Q1]` `@low-confidence`
- AC2-C6 amount = €5000.01 → manager + finance + director
- AC2-C7 decision-table cell: amount tier × ordinary (non-manager) submitter — confirms the
  baseline chain the AC3 conditions below deviate from

### AC3 — no self-approval (decision table / domain analysis, combined with AC2)
- AC3-C1 an approver attempts to approve their own report `[req-neg]`
- AC3-C2 submitter is a manager, amount < €500 (single-approval tier) → per Q3's default,
  generated qualitatively (no confident approver identity to assert) `[open:Q3]`
  `@low-confidence`
- AC3-C3 submitter is a manager, amount > €5000 → manager step skipped, finance + director
  proceed `[open:Q2]` `@low-confidence`
- AC3-C4 the manager attempts to approve at the level skipped on their own behalf `[req-neg]`

### AC4 — line-item validation (EP + BVA)
- AC4-C1 line missing category → blocked at submission `[req-neg]`
- AC4-C2 line missing amount → blocked at submission `[req-neg]`
- AC4-C3 line missing date → blocked at submission `[req-neg]`
- AC4-C4 line date = exactly 90 days before the reference clock (boundary, inclusive) → allowed
- AC4-C5 line date = 91 days before the reference clock → blocked with explanatory message
  `[req-neg]`
- AC4-C6 line date = today → allowed (happy path)
- AC4-C7 line date in the future → blocked `[req-neg]` `[assumption]` `@low-confidence`
  (source never states future dates are invalid; safe default for a "recency" rule)

### AC5 — receipt threshold (BVA)
- AC5-C1 line = €24.99 → receipt optional
- AC5-C2 line = €25.00 (boundary, inclusive per the AC's own "≥") → receipt mandatory
- AC5-C3 line ≥ €25 with no receipt attached → submission refused `[req-neg]`
- AC5-C4 line ≥ €25 with receipt attached → submission allowed
- AC5-C5 non-EUR line whose original-currency amount and converted-EUR amount fall on opposite
  sides of €25 → threshold applied per Q7's default (original currency) `[req-neg]`
  `[open:Q7]` `@low-confidence`

### AC6 — currency conversion (EP + metamorphic + error guessing)
- AC6-C1 EUR line → no conversion applied
- AC6-C2 non-EUR line → converted at the expense-date rate (qualitative: "converted total
  reflects the rate," no fabricated precise literal — Q8 is open)
- AC6-C3 non-EUR line whose converted total crosses an AC2 tier boundary → the *converted* total
  drives the tier, not the original-currency figure
- AC6-C4 expense date = weekend/holiday with no published rate → fallback per Q8's default
  (prior business day's rate) `[open:Q8]` `@low-confidence`
- AC6-C5 metamorphic relation: doubling a non-EUR line's original amount yields a converted total
  that is ~double the original conversion's result (same date/rate) — checks the relation, not a
  fabricated exact figure
- AC6-C6 unsupported/invalid currency code → submission blocked `[req-neg]` `[assumption]`
  `@low-confidence` (error-guessing reflex anchored on Q8's rate-source gap)

### AC8 — audit trail + mandatory comment (BVA + EP)
- AC8-C1 every transition records who + when (generic audit condition, checked across
  submit/approve/reject/changes-requested)
- AC8-C2 reject attempted with a comment of 9 characters → blocked `[req-neg]`
- AC8-C3 reject with a comment of exactly 10 characters → accepted (boundary)
- AC8-C4 changes-requested attempted with a comment of 9 characters → blocked `[req-neg]`
- AC8-C5 changes-requested with a comment of exactly 10 characters → accepted
- AC8-C6 approve transition with no comment supplied → accepted (comment optional on approval,
  confirms AC8 scopes the requirement to rejections/changes-requested only)

### Systematic-expansion conditions (3c)
- EXP-1 a `draft` report is deleted by its owner before submission → allowed `[assumption]`
  `@low-confidence`
- EXP-2 a non-approver (not the pending level's role holder) attempts to approve another
  employee's report → blocked `[req-neg]` `[assumption]` `@low-confidence`
- EXP-3 an unauthenticated request attempts to submit or approve a report (UI-bypass, direct
  request) → blocked `[req-neg]` `[assumption]` `@low-confidence`

## Journey scenario (use-case technique, at most one per US)
- One `@smoke` end-to-end scenario: employee submits a non-EUR report whose converted total is
  above €5000, approved in sequence by manager, finance and director. Single journey-level
  `Then`. Excluded from atomicity/negative-ratio accounting per the technique's constraint.

⚠ VALIDATION (technique map + conditions): `simulated: accepted-as-is`.
