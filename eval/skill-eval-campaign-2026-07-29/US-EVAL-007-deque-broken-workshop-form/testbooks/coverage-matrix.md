# Coverage matrix — US-EVAL-007

| AC | Condition | Scenario ID | Priority | Rationale | Confidence |
|---|---|---|---|---|---|
| AC1 | AC1-C1 | QAIA-US-EVAL-007-001 | P1 | WCAG 4.1.2-class exclusion if the dialog has no accessible name; probability 3 because the defect is directly confirmed present (not a speculative bump) | full — confirmed live defect |
| AC2 | AC2-C1 | QAIA-US-EVAL-007-002 | P1 | Every keyboard/screen-reader close-via-Escape loses the user's place; probability 3, confirmed present | full — confirmed live defect |
| AC2 | AC2-C2, AC2-C3 (Q1) | QAIA-US-EVAL-007-003 | P2 | Same exclusion class as AC2-C1 if it also fails; probability held at 1 since this is `[assumption]` not `[open]` (not auto-bumped) | low (`@low-confidence`, `[assumption]`) — **human arbitration/direct observation pending** |
| AC3 | AC3-C1 | QAIA-US-EVAL-007-004 | P1 | A wrong-field error text can actively misdirect a user hunting for the real problem; probability 3, confirmed present | full — confirmed live defect |
| AC3 | AC3-C2 (Q2) | QAIA-US-EVAL-007-005 | P2 | Same misdirection class if the Ingredient-field wording also mismatches; probability held at 1, `[assumption]` not `[open]` | low (`@low-confidence`, `[assumption]`) — **human arbitration/direct observation pending** |
| AC2 | AC2-C4 (Q4) | — (waived) | P3 | Below default P1+P2 generation threshold — see `synthesis.md` | full (not generated, quota trade-off) |
| AC4 | AC4-C1 | — (waived) | P3 | Confirmed-passing regression guard, below default P1+P2 threshold — see `synthesis.md` | full (not generated, quota trade-off) |
| AC4 | AC4-C2 | — (waived) | P3 | Same as AC4-C1, Instruction-field side | full (not generated, quota trade-off) |

6/9 conditions covered by 5 generated scenario blocks (P1+P2 default scope; `AC2-C2`/`AC2-C3`
share one `Scenario Outline`, per `testbook-generate`'s same-priority/same-confidence merge
rule). 3 conditions waived (all P3: `AC2-C4`, `AC4-C1`, `AC4-C2`) — not a gap, a recorded
quota trade-off.
