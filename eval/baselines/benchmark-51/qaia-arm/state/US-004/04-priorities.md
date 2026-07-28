---
stepsCompleted: [00-ingest, 01-review, 02-understanding, 03-design, 04-priorities-lite]
lastStep: 04-priorities-lite
lastSaved: 2026-07-28
---

# 04-priorities — US-004 (lightweight, deviation)

**Deviation note**: the benchmark's assigned skill sequence is `us-ingest → us-review →
need-understanding → istqb-design → testbook-generate → report` — it does not include the
`prioritize` skill (which exists in this repo at `plugins/qaia-core/skills/prioritize/`), yet
`testbook-generate` lists `04-priorities.md` as a hard prerequisite. Per the shared contract's
rule 2 ("prerequisite missing → offer, don't fail") this file is a **directly-reasoned
risk-based assignment**, not a full `prioritize` run (no separate risk-scoring rubric, no
history-signal lookup, no user arbitration pass beyond the same `simulated: accepted-as-is`
default used everywhere else in this run). It exists only so `testbook-generate` has a real
input to read.

## Rubric applied
- **P1**: core lifecycle happy paths, the amount-tier routing core cases, self-approval
  denial, mandatory-field/90-day and receipt-threshold refusals, terminal-rejection
  enforcement, comment-length enforcement, and the two authorization reflex conditions
  (money-movement/approval is the highest-risk surface named by the story's own "so that").
- **P2**: secondary/less-central boundaries and happy paths (changes-requested branch,
  non-boundary BVA points already covered by a P1 sibling, post-rejection new-report path,
  approve-without-comment confirmation).
- **P3**: conditions carrying `[open]`/`[assumption]` with `@low-confidence` on a
  state-model gap with no safe default (AC1-C9), the currency weekend/holiday fallback
  (AC6-C4), and the CRUD-reflex draft-delete condition (EXP-1) — exploratory/edge, lowest
  confidence.

## Assignment (one line per condition — risk driver noted, feeds the coverage matrix's
rationale column)

| Condition | Priority | Risk driver |
|---|---|---|
| AC1-C1 | P1 | Core lifecycle entry |
| AC1-C2 | P1 | Core lifecycle — approval reached |
| AC1-C3 | P1 | Core lifecycle — rejection reached |
| AC1-C4 | P2 | Secondary branch |
| AC1-C5 | P1 | Loop re-entry, feeds re-submission |
| AC1-C6 | P1 | Loop re-entry, feeds re-submission |
| AC1-C7 | P2 | Forbidden-transition guard |
| AC1-C8 | P2 | Forbidden-transition guard, `@low-confidence` |
| AC1-C9 | P3 | State-model gap, `[open]`, `@low-confidence` |
| AC7-C1 | P1 | Terminal-state integrity (compliance) |
| AC7-C2 | P1 | Terminal-state integrity (compliance) |
| AC7-C3 | P2 | Downstream consequence, not the rule itself |
| AC2-C1 | P1 | Threshold routing, core |
| AC2-C2 | P2 | Boundary, `[open]`, `@low-confidence` |
| AC2-C3 | P2 | Non-boundary BVA, sibling of C1 |
| AC2-C4 | P2 | Non-boundary BVA, sibling of C6 |
| AC2-C5 | P2 | Boundary, `[open]`, `@low-confidence` |
| AC2-C6 | P1 | Threshold routing, core (top tier) |
| AC2-C7 | P2 | Baseline confirmation for AC3 deviations |
| AC3-C1 | P1 | Self-approval denial (financial control) |
| AC3-C2 | P2 | `[open]`, `@low-confidence`, narrow case |
| AC3-C3 | P2 | `[open]`, `@low-confidence` |
| AC3-C4 | P1 | Financial-control enforcement |
| AC4-C1 | P1 | Mandatory-field refusal |
| AC4-C2 | P1 | Mandatory-field refusal |
| AC4-C3 | P1 | Mandatory-field refusal |
| AC4-C4 | P2 | Boundary happy path |
| AC4-C5 | P1 | 90-day refusal, core |
| AC4-C6 | P2 | Happy path, non-boundary |
| AC4-C7 | P2 | `[assumption]`, `@low-confidence` |
| AC5-C1 | P2 | Non-boundary happy path |
| AC5-C2 | P1 | Receipt-threshold boundary, core |
| AC5-C3 | P1 | Receipt-mandatory refusal, core |
| AC5-C4 | P2 | Happy path confirmation |
| AC5-C5 | P2 | `[open]`, `@low-confidence`, narrow interaction |
| AC6-C1 | P1 | Baseline (no conversion) |
| AC6-C2 | P1 | Conversion core |
| AC6-C3 | P2 | Downstream threshold consequence |
| AC6-C4 | P3 | `[open]`, `@low-confidence`, narrow edge |
| AC6-C5 | P2 | Metamorphic relation check, secondary |
| AC6-C6 | P2 | `[assumption]`, `@low-confidence` |
| AC8-C1 | P1 | Audit-trail core (story's own "so that") |
| AC8-C2 | P1 | Comment-length enforcement, core |
| AC8-C3 | P2 | Boundary confirmation |
| AC8-C4 | P1 | Comment-length enforcement, core |
| AC8-C5 | P2 | Boundary confirmation |
| AC8-C6 | P2 | Negative confirmation (no comment required) |
| EXP-1 | P3 | `[assumption]`, `@low-confidence`, CRUD reflex |
| EXP-2 | P1 | Authorization/IDOR, high risk despite `@low-confidence` |
| EXP-3 | P1 | Authorization/unauthenticated, high risk despite `@low-confidence` |

Journey `@smoke` scenario: excluded from P-tier accounting (technique constraint).

⚠ VALIDATION (priority assignment): `simulated: accepted-as-is`.
