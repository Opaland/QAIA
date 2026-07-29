# testbook-validate report — US-EVAL-001

## Deterministic structural pass (real script execution, not simulated)

Ran `python eval/tools/structural_score.py eval/skill-eval-campaign-2026-07-29/US-EVAL-001-saucedemo-login/testbooks/login-gate.feature` for real.

**First run crashed** (`UnicodeEncodeError` on the `→` character in the script's own findings text —
Windows console defaults to `cp1252`, not UTF-8). This is a real, reproducible portability bug in
`eval/tools/structural_score.py` itself, found by actually executing it rather than by inspection —
**fixed at the root** (stdout/stderr forced to UTF-8 at the top of `main()`) and re-verified: the
script now runs clean on Windows without requiring `PYTHONIOENCODING=utf-8` set externally.

**Result** (after the fix):

```
score: 65/100 -- gate: CONCERNS
readability 25/25, completeness 10/30, coherence 20/20, traceability 25/25
penalties: markers 0, sniffer 0, redundancy 15
finding: pesticide paradox -- 2 near-duplicate groups (same Given/When shape)
```

The redundancy finding is expected and not a defect here: scenarios `001/002/005` and `004/006`
intentionally share the same `Given`/`When` step shape (same login action) with a different `Then`
per decision-table branch — exactly the case `structural_score.py`'s own documentation says is
"reported for human judgment, not auto-failed." Flagged for a human to confirm, not silently
dismissed.

## 8-dimension checklist

| Dimension | Score | Evidence |
|---|---|---|
| Atomicity | 2 | One `When` per scenario; outcomes only in `Then`; the Outline (`005`) correctly merges two examples sharing priority/confidence. |
| Coverage | 2 | AC1 1/1, AC2 2/2, AC3 3/3 — all conditions covered. |
| Negative-path coverage (ADR 0001) | 2 | All 5 `[req-neg]` conditions have a covering scenario. |
| Technique fit | 2 | `@ep` for the two happy/simple-negative classes, `@decision-table` for the credential×state cross. |
| Business correctness | 1 | The two literal strings asserted (`secret_sauce`, the locked-out message) trace only to secondary-source corroboration (`WebSearch`), not a primary SauceDemo spec — flagged honestly in `synthesis.md`, not hidden, but not full-confidence either. |
| Ambiguity honesty | 2 | Q1/Q2/Q3 all visible in `synthesis.md`'s open/assumption list, none silently resolved — `AC2-C2`'s scenario is explicitly labeled "proposed default, unconfirmed" in its own scenario title. |
| Traceability | 2 | Stable `@QAIA-US-EVAL-001-NNN` IDs, `# condition:` comment on every scenario, matrix consistent with the book. |
| Gherkin form | 2 | Valid keywords, correct `Scenario Outline`/`Examples` use, no `Background` needed (no invariant shared by all 6 scenarios). |

**Total: 15/16.** Per the gate rule, a total ≥14 with **business correctness at 1** forces
**CONCERNS**, not PASS, regardless of the total.

## Gate decision

Two gates, stricter wins: structural = **CONCERNS**, checklist = **CONCERNS** → **overall: CONCERNS**.

## Three highest-impact fixes

1. **Arbitrate Q3 for real** (`AC2-C2`, scenario `006`) — this is the highest-risk item in the
   book (P1, access-control-adjacent) and currently rests on an unconfirmed proposed default.
   This is exactly the item the campaign prompt's human Go/No-Go gate exists to catch.
2. **Confirm the two literal strings against a primary source** — actually observe
   `saucedemo.com`'s login form/error text directly (this campaign only had secondary-source
   corroboration available) before trusting `business correctness` above a 1.
3. **Human-eyeball the two redundancy groups** — confirm no real behavioral distinction was
   compressed away by the decision-table's shared step shape before accepting the CONCERNS as final.

No file was modified by this audit beyond the deterministic-script bugfix noted above (that fix
lives in the tool, not in the test book itself).
