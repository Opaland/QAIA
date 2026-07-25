# Derived test conditions — US-alone vs US + RAG (excerpt of `03-design.md`)

Illustrative projection of what `istqb-design` writes for SHOP-412, showing step 3d's effect.
Condition IDs follow the `ACn-Cm` convention; knowledge-derived ones cite their rule.

## From the ACs alone (steps 1–3c)

| ID | Condition | Technique | Kind |
|---|---|---|---|
| AC1-C1 | Valid code reduces total by its configured amount | EP | positive |
| AC1-C2 | Discount never makes the total negative (floor at 0) | boundary | `[req-neg]` |
| AC2-C1 | Expired code rejected with message | EP | `[req-neg]` |
| AC2-C2 | Unknown code rejected with message | EP | `[req-neg]` |
| AC2-C3 | Empty / whitespace-only code rejected | error-guessing | `[req-neg]` |
| AC3-C1 | Discounted total shown before payment confirmation | use-case | positive |

## Added by step 3d — retrieved from `knowledge/business-rules.md`

| ID | Condition | Technique | Rule | Kind |
|---|---|---|---|---|
| AC1-C3 | Re-applying an already-redeemed code is rejected (`code already used`) | state-transition | `BR-KB-004` | `[req-neg]` |
| AC1-C4 | Applying a second code replaces the first (stacking off) | decision-table | `BR-KB-007` | functional |
| AC1-C5 | With `checkout.stacking = true`, both codes apply | decision-table | `BR-KB-007` | functional, `@low-confidence` |
| AC1-C6 | B2B customer below €20 cart: accepted; retail below €20: rejected | decision-table | `BR-KB-011` | `[req-neg]` (retail leg) |
| AC1-C7 | `  save10 ` matches `SAVE10` (trim + case-insensitive) | boundary/EP | `BR-KB-014` | positive |

**Effect:** +5 conditions, of which 2 are required-negative paths the ADR 0001 gate now
enforces — none of them inferable from the US text. `knowledgeApplied` =
`[BR-KB-004, BR-KB-007, BR-KB-011, BR-KB-014]`.
