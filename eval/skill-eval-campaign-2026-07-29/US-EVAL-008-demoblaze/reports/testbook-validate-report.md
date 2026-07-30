# testbook-validate report — US-EVAL-008

## Deterministic structural pass (real script execution, not simulated)

Ran, for real:

```
python eval/tools/structural_score.py \
  eval/skill-eval-campaign-2026-07-29/US-EVAL-008-demoblaze/testbooks/cart-checkout.feature \
  --acs AC1,AC2,AC3,AC4,AC5,AC6,AC7,AC8,AC9 \
  --source eval/skill-eval-campaign-2026-07-29/US-EVAL-008-demoblaze/state/01-extraction.md
```

(source fed explicitly per this skill's own step 2/line 19 requirement — not run blind — so
`completeness`/`sniffer` below are source-checked, not defaulted. All nine declared ACs are
passed, not only the five actually in-scope this run.)

**Result (raw tool output, unedited):**

```json
{
  "file": "cart-checkout.feature",
  "scenarios": 10,
  "readability": 25.0,
  "completeness": 16.7,
  "coherence": 20.0,
  "traceability": 25.0,
  "penalties": { "markers": 0, "sniffer": 0, "redundancy": 9 },
  "score": 78,
  "gate": "CONCERNS",
  "forced_stop": false,
  "findings": [
    "pesticide paradox: 1 near-duplicate group(s) (same Given/When shape) -> -9: [[\"Logged-in add-to-cart surfaces an expired-token error verbatim\", \"Logged-in add-to-cart surfaces a malformed-token error verbatim\", \"Logged-in add-to-cart surfaces a flag-incorrect error verbatim\"]]"
  ],
  "tag_audit": {
    "missing_priority_tag": [],
    "technique_tag_violations": [],
    "negative_scenarios": 3,
    "non_smoke_scenarios": 10,
    "negative_ratio_recomputed_pct": 30.0
  }
}
```

**No Gherkin-form defect found this run** — `coherence` is a clean 20/20, no step reported
truncated. `cart-checkout.feature` is unmodified by this audit.

**Completeness (16.7/30) is genuinely below the model runs, honestly** — not a script quirk: only
5 of the 9 declared ACs (`AC2`, `AC3`, `AC4`, `AC7`, `AC8`) have any scenario at all in this
P1+P2-scope book; `AC1`, `AC5`, `AC6`, `AC9` are entirely P3-deferred (every one of their
conditions scored P3 in `04-priorities.md`), contributing zero to the 30-point completeness
budget — 5/9 × 30 ≈ 16.7, matching the tool's own output exactly.

**Redundancy finding (`-9`, one 3-way group) is a false-flag on inspection, not a real
duplicate** — same discipline as `US-EVAL-006`'s single flagged group. Scenarios `001`, `002`,
`003` share a `Given`/`When` shape only because the detector normalizes literal strings (the
"Add to cart" click action and the "logged-in shopper" precondition are structurally identical
across all three) — but they are the three columns of `03-design.md`'s decision table over the
*single* `errorMessage` variable, each asserting a genuinely different literal input
(`"Token has expired"` / `"Bad parameter, token malformed."` / `"Bad parameter, flag is
incorrect."`) **and** a genuinely different literal `Then` output (the matching alert text) — a
real per-value behavioral difference, exactly the carve-out the scorer's own docstring names
("only steps are compared... reported for human judgment, not auto-failed"). Flagged here for a
human to confirm, not silently dismissed — and it is a 3-way group here (vs. `US-EVAL-006`'s
2-way group), a genuinely different shape than any prior campaign run's redundancy finding, worth
a human's independent look precisely because a 3-way decision-table cluster is a more plausible
place for real duplication to hide than a 2-way one.

## 8-dimension checklist

| Dimension | Score | Evidence |
|---|---|---|
| Atomicity | 2 | One `When` per scenario; outcomes only in `Then`; the multi-clause `Then`s in `007`/`009` (order id + Amount + Card Number + Name + Date) are all components of the *same* single purchase-confirmation outcome, not a second unrelated behavior. |
| Coverage | 1 | `AC2` 3/3, `AC3` 1/1, `AC4` 1/1, `AC7` 1/1, `AC8` 4/4 of the in-scope conditions — but **`AC1`, `AC5`, `AC6`, `AC9` have zero scenarios** in this book (all their conditions are P3, deferred by the default P1+P2 scope). A real 4/9 ACs with zero covering scenarios caps this dimension at 1, not 2, even though the gap is deliberate and disclosed (`04-priorities.md`) — same honest-gap reasoning `US-EVAL-006` applied to its own zero-coverage ACs. |
| Negative-path coverage (ADR 0001) | 2 | All three P1/P2 `[req-neg]` conditions (`AC2-C1`..`C3`) are covered by scenarios `001`-`003`; the two remaining `[req-neg]` conditions (`AC7-C1`/`AC7-C2`) are P3-deferred with a stated reason in `04-priorities.md`/`coverage-matrix.md`, a disclosed standing waiver, not a hidden gap. |
| Technique fit | 2 | `@decision-table` for the `errorMessage` axis, `@ep` for representative-partition checks, `@boundary` for the sum-accumulation and whitespace-card edges, `@state-transition` for the empty-cart-checkout edge — matches `03-design.md`'s AC → technique map exactly, no opportunistic tag. |
| Business correctness | 2 | Every asserted literal (`1150` as the two-item sum, `0 USD` for the empty-cart order, the four verbatim alert strings) traces to **primary source** (the captured `cart.js`/`prod.js`). The three extrapolations (`Q1`, `Q2`, `Q3`) are explicitly flagged `@low-confidence` on scenarios `004`, `008`, `009`, not asserted with full confidence. |
| Ambiguity honesty | 2 | `Q1`/`Q2`/`Q3` all visible in `synthesis.md`'s open/assumption list; the three `@low-confidence` scenarios each cite their question ID inline (`# assumption: Q1` / `# assumption: Q2` / `# open: Q3`), none silently resolved. |
| Traceability | 2 | Stable `@QAIA-US-EVAL-008-NNN` IDs (`001`-`010`, no gap), `# condition:` comment on every scenario, matrix consistent with the book. |
| Gherkin form | 2 | Valid keywords, no `Background` needed (no invariant shared by all 10 scenarios — session-state and cart-content preconditions differ per scenario), no truncated step (confirmed by the structural pass's clean 20/20 coherence). |

**Total: 15/16.** Per the gate rule, total ≥14 with no dimension <1 and neither traceability nor
business-correctness at 1 → checklist verdict **PASS**.

## Gate decision

Two gates, stricter wins: structural = **CONCERNS** (78/100, below the 80 threshold, driven
almost entirely by the 4 deliberately-deferred P3 ACs' zero completeness contribution), checklist
= **PASS** (15/16) → **overall: CONCERNS**. Same pattern as `US-EVAL-006`'s result (structural
CONCERNS, checklist PASS, overall CONCERNS) — reported as found, not adjusted to look more or
less favorable; the real driver here is the deliberately narrow P1+P2 default scope leaving 4 of
9 ACs at zero scenarios, disclosed throughout rather than hidden.

## Three highest-impact fixes

1. **Arbitrate `Q3` for real (`AC8-C3`, scenario `009`)** — this is the one `[open]` item in the
   whole book: is unauthenticated checkout the intended DemoBlaze policy, or a gap? The P1 rank
   and the scenario's very shape (asserting the no-gate behavior as correct) both hinge on this
   answer; a human should confirm before this scenario is trusted as "this is how it should work"
   rather than "this is how it currently, possibly-wrongly, works."
2. **Generate scenarios for the 4 P3-deferred ACs (`AC1`, `AC5`, `AC6`, `AC9`), or get an
   explicit human waiver naming them** — the actual gap behind both the structural CONCERNS score
   and the checklist Coverage=1 score; in particular `AC5` (delete) and `AC9` (redirect) are
   simple but real user-facing behaviors currently entirely untested in this book.
3. **Human-eyeball the flagged 3-way redundancy group** (`001`/`002`/`003`) — confirm, as
   analyzed above, that these are the three genuinely distinct columns of the `errorMessage`
   decision table (they are) before accepting the structural finding as a non-issue; a 3-way
   cluster carries more real-duplication risk than the 2-way case `US-EVAL-006` cleared.

## Files modified by this audit

- None. `testbooks/cart-checkout.feature` had no Gherkin-form defect this run; `testbook-validate`
  audits, it never rewrites test intent.

## Skill evaluation — `testbook-validate` (`plugins/qaia-core/skills/testbook-validate/SKILL.md`)

**Verdict: CONFORME.**

**Evidence**: Step 2's rule (line 19) to actually run the script "for true determinism" was
honored — a real subprocess call, raw JSON output pasted above verbatim, not a mental simulation;
the source and full declared AC set were passed via `--source`/`--acs` for real, and this report
states so explicitly. The result (CONCERNS, not PASS) was accepted and reported as-is rather than
reframed to look more favorable — the harder case for this guardrail than a clean PASS, since the
checklist alone would have read PASS (line 21's "never averaged together" and the "two gates,
stricter wins" rule were both applied exactly, producing an overall CONCERNS even though 8 of 8
checklist dimensions scored ≥1). Step 4's gate-decision thresholds (line 31) were applied
literally to the checklist (15/16, no dimension <1, traceability and business-correctness both at
2 → PASS by the literal rule, not downgraded or upgraded). Step 5's three-highest-impact-fixes
deliverable (line 32) is present, ranked by actual leverage (the one `[open]` item first, since
resolving it could change a scenario's asserted behavior, not just its coverage count). No
deviation between the skill's literal text and this output found. **Modification proposed:
none.**
