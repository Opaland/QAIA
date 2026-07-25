# Test book quality rubric (LLM-judge)

Applied by an LLM-judge in a fresh session to one generated test book against its source US. Each dimension is scored 0 / 1 / 2. **Maximum: 20. Release gate: median ≥ 16, no dimension at 0, and no dimension dropping ≥ 1 vs the previous baseline.**

## Judge protocol

Give the judge: the source US, the generated test book (`.feature` files + synthesis + coverage matrix), and this rubric. Instruct it to justify every score in one sentence and to default to the **lower** score when hesitating. Do not give it the generation session's context.

## Dimensions

| # | Dimension | 2 | 1 | 0 |
|---|---|---|---|---|
| 1 | **Atomicity** | Every scenario verifies exactly one behavior; no UI-step chaining across cases. **Exemption (design decision, skills 0.1.1+):** at most one `@smoke` journey scenario per US, with a single journey-level outcome, is excluded from this dimension — a second journey, or a journey re-verifying atomically-covered behaviors, counts as a violation | Isolated violations (≤ 10 % of scenarios) | Chained or multi-behavior scenarios are common |
| 2 | **AC coverage** | Every acceptance criterion is covered by ≥ 1 scenario, and the coverage matrix proves it | One AC uncovered or the matrix has gaps | Multiple AC uncovered |
| 3 | **Negative-path coverage** (ADR 0001) | Every required negative condition (a rule that can refuse/error/deny) has a covering scenario; the negative ratio is reported as context | One required negative condition uncovered | Several uncovered (happy-path bias). *Note: the raw negative ratio is a reported signal, not a threshold — do not score on it.* |
| 4 | **ISTQB technique fit** | Techniques chosen fit the AC types and each choice is justified in the book | Techniques applied but justification weak or generic | No identifiable technique or misapplied |
| 5 | **Business correctness** | No scenario contradicts the US; extrapolations are flagged as assumptions | Minor unflagged extrapolations | A scenario asserts behavior the US contradicts (dangerous: plausible-but-wrong) |
| 6 | **Ambiguity handling** | Ambiguities in the US were surfaced as questions or flagged assumptions, not silently resolved | Some ambiguities silently resolved | Ambiguities invented into firm requirements |
| 7 | **Stable IDs & traceability** | Every scenario tagged `@QAIA-xxx`, unique, linked to its AC; matrix consistent | IDs present but gaps/duplicates | No stable IDs |
| 8 | **Gherkin form** | Valid Gherkin, English keywords, consistent vocabulary, correct `Background`/`Scenario Outline` use | Minor inconsistencies | Invalid or inconsistent Gherkin |
| 9 | **Prioritization** | Every scenario carries a risk-based priority with a stated rationale; human arbitration points identified | Priorities present without rationale | No prioritization |
| 10 | **Review support** | Synthesis by technique, review order by risk, confidence score marking extrapolated scenarios (decision D31) | Synthesis present but no confidence marking | Raw scenario dump |

## Scoring output format

The judge must output a table (dimension, score, one-line justification), the total, and a **top-3 fixes** list — the three changes that would most improve the score. The top-3 feeds the next iteration of the skills.
