---
stepsCompleted: [00-ingest, 01-review, 02-understanding, 03-design, 04-priorities]
lastStep: 04-priorities
lastSaved: 2026-07-25
---

# 04-priorities — US-004

Regulated-context note: this US is finance/HR with an explicit audit-trail requirement (AC8) —
per the `prioritize` skill's guardrail, traceability/control-relevant conditions default to
**impact 3** even when the underlying logic is simple, because a silent control failure here is
a compliance failure, not a cosmetic one. `[open]`/`[assumption]`-flagged conditions (Q1, Q2,
Q4, Q6, Q7, Q8) score **probability 3** — an under-specified rule is exactly where a real
defect is likely to hide.

| Condition | Impact | Prob. | Priority | Rationale |
|---|---|---|---|---|
| AC1-C1 | 3 | 1 | P2 | Core transition, foundational to every other scenario; simple logic. |
| AC1-C2 | 2 | 2 | P2 | Re-entrant loop adds state complexity beyond a linear flow. |
| AC1-C3 | 2 | 2 | P2 | Edit-then-resubmit exercises the loop's exit path. |
| AC1-C4 [req-neg] | 3 | 1 | P2 | Guards against double-submission; simple status check. |
| AC1-C5 [req-neg] | 3 | 1 | P2 | Guards against editing in-flight reports; simple status check. |
| AC1-C6 [req-neg] | 3 | 3 | **P1** | Q3-flagged interaction; wrong behavior here silently breaks AC7's terminality guarantee. |
| AC2-C1 | 3 | 2 | **P1** | Financial-control boundary; drives who signs off. |
| AC2-C2 [req-neg-adjacent] | 3 | 3 | **P1** | Q1-flagged; exact-€500 is the deliberately ambiguous boundary. |
| AC2-C3 | 3 | 3 | **P1** | Q1-flagged; exact-€5000 boundary, same risk class as AC2-C2. |
| AC2-C4 | 3 | 2 | **P1** | Full 3-level chain; highest-stakes band. |
| AC2-C5 [req-neg] | 3 | 2 | **P1** | Out-of-order approval would break chain integrity. |
| AC3-C1 [req-neg] | 3 | 2 | **P1** | Classic internal-control defect class (self-approval). |
| AC3-C2 | 3 | 3 | **P1** | Q2-flagged escalation semantics; wrong default = a real approval-bypass risk. |
| AC3-C3 | 3 | 3 | **P1** | Q2-flagged, larger-band variant of the same open question. |
| AC3-C4 | 3 | 2 | **P1** | Q8-flagged generalization beyond the named example. |
| AC4-C1 [req-neg] | 2 | 1 | P3 | Basic input-completeness validation, low complexity. |
| AC4-C2 | 2 | 2 | P2 | Q5-flagged clock reference; boundary logic. |
| AC4-C3 [req-neg] | 2 | 2 | P2 | Boundary logic, moderate complexity (date arithmetic). |
| AC5-C1 | 2 | 2 | P2 | Boundary just below the receipt threshold. |
| AC5-C2 [req-neg] | 3 | 2 | **P1** | Financial-control boundary (receipt mandatory) at the exact threshold. |
| AC5-C3 | 2 | 1 | P3 | Straightforward positive case. |
| AC5-C4 [req-neg] | 3 | 3 | **P1** | Q6-flagged cross-AC basis (EUR-equivalent vs face value); real bypass risk if wrong. |
| AC6-C1 | 3 | 2 | **P1** | Currency conversion feeds AC2's threshold directly — high blast radius if wrong. |
| AC6-C2 [req-neg] | 3 | 3 | **P1** | Q4-flagged (rate source); undefined external dependency. |
| AC6-C3 | 3 | 3 | **P1** | Q4-flagged (fallback); silently wrong total would mis-route approval. |
| AC6-C4 | 3 | 3 | **P1** | Q7-flagged triple intersection; highest combined complexity in the book. |
| AC7-C1 [req-neg] | 3 | 1 | P2 | Terminal-state guard, simple check but compliance-relevant. |
| AC7-C2 [req-neg] | 3 | 1 | P2 | Same class as AC7-C1. |
| AC8-C1 [req-neg] | 3 | 1 | P2 | Compliance evidence requirement, simple length check. |
| AC8-C2 [req-neg] | 3 | 1 | P2 | Same class as AC8-C1. |
| AC8-C3 | 2 | 2 | P2 | Exact boundary at the 10-character minimum. |
| AC8-C4 | 1 | 1 | P3 | Confirms an absence of a constraint — low risk either way. |
| AC8-C5 | 3 | 2 | **P1** | Audit-trail completeness across multiple event types — the AC8 core promise. |
| AC-auth-C1 [req-neg] | 3 | 1 | P2 | Standard auth gate, low logic complexity. |
| AC-auth-C2 [req-neg] | 3 | 1 | P2 | Same class as AC-auth-C1. |
| AC-auth-C3 [req-neg] | 3 | 2 | **P1** | IDOR class; IDs are IDOR-guessable (`r1`, `r2`…) in this demo SUT, raising real exposure. |
| AC-list-C1 | 1 | 1 | P3 | Cosmetic empty state. |

## Scope decision (quota trade-off, Q22)

Default scope is P1+P2 (33/37 conditions). For this cross-domain demonstration the maintainer
asked for the same exhaustiveness standard as `examples/medibook` (all 8 AC covered, not just
the highest-risk subset) — so the 4 P3 conditions (AC4-C1, AC5-C3, AC8-C4, AC-list-C1) are
**also** generated. This is recorded as an explicit scope decision, not a silent quota breach:
`simulated: P1+P2+P3 all generated, full-breadth demo scope`.

⚠ VALIDATION: non-interactive mode — `simulated: scores accepted as proposed, scope decision
recorded above`.

## Journey checkpoint

- Step `04-priorities`: **done**. 18 P1 / 15 P2 / 4 P3; all 37 generated (full-breadth scope).
- Next step: `testbook-generate`.
