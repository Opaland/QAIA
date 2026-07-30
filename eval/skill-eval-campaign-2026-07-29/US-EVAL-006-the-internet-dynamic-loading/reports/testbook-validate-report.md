# testbook-validate report — US-EVAL-006

## Deterministic structural pass (real script execution, not simulated)

Ran, for real:

```
python eval/tools/structural_score.py \
  eval/skill-eval-campaign-2026-07-29/US-EVAL-006-the-internet-dynamic-loading/testbooks/dynamic-loading.feature \
  --acs AC1,AC2,AC3,AC4,AC5,AC6,AC7 \
  --source eval/skill-eval-campaign-2026-07-29/US-EVAL-006-the-internet-dynamic-loading/state/01-extraction.md
```

(source fed explicitly per this skill's own step 2/line 19 requirement — not run blind — so
`completeness`/`sniffer` below are source-checked, not defaulted. All seven declared ACs are
passed, not only the three actually in-scope this run, matching `US-EVAL-003`'s own convention of
feeding the full declared AC set from `01-extraction.md`.)

**Result (raw tool output, unedited):**

```json
{
  "file": "dynamic-loading.feature",
  "scenarios": 4,
  "readability": 25.0,
  "completeness": 12.9,
  "coherence": 20.0,
  "traceability": 25.0,
  "penalties": { "markers": 0, "sniffer": 0, "redundancy": 6 },
  "score": 77,
  "gate": "CONCERNS",
  "forced_stop": false,
  "findings": [
    "pesticide paradox: 1 near-duplicate group(s) (same Given/When shape) -> -6: [[\"Example 1's pre-existing hidden element is not yet visible before the delay elapses\", \"Example 2's Hello World element still does not exist in the DOM before the delay elapses\"]]"
  ],
  "tag_audit": {
    "missing_priority_tag": [],
    "technique_tag_violations": [],
    "negative_scenarios": 0,
    "non_smoke_scenarios": 4,
    "negative_ratio_recomputed_pct": 0.0
  }
}
```

**No Gherkin-form defect found this run** — unlike `US-EVAL-003` (which caught and fixed a
wrapped-line truncation), `coherence` here is a clean 20/20 and no step was reported truncated.
`dynamic-loading.feature` is unmodified by this audit.

**Completeness (12.9/30) is genuinely below the model runs, honestly** — not a script quirk: only
3 of the 7 declared ACs (`AC3`, `AC4`, `AC6`) have any scenario at all in this P1+P2-scope book;
`AC1`, `AC2`, `AC5`, `AC7` are entirely P3-deferred (every one of their conditions scored P3 in
`04-priorities.md`), so they contribute zero covered ACs to the 30-point completeness budget —
3/7 × 30 ≈ 12.9, matching the tool's own output exactly.

**Redundancy finding (`-6`, one group) is a false-flag on inspection, not a real duplicate** —
same discipline as `US-EVAL-003`'s two redundancy groups. Scenarios `001`
("Example 1's pre-existing hidden element is not yet visible...") and `003` ("Example 2's Hello
World element still does not exist in the DOM...") share a `Given`/`When` shape only because the
detector normalizes digits (`normalize_step`'s `\d+ → <num>` substitution collapses
`/dynamic_loading/1` and `/dynamic_loading/2` to the same shape) — but they target the two
*different* example pages this feature's own index copy explicitly frames as distinct (see
`00-source.md`), and their `Then` steps assert genuinely different rules (`001`: "not visible" —
the element is present, merely hidden; `003`: "no element... exists" — the element is not in the
DOM at all). This is exactly the per-value-behavioral-difference carve-out the scorer's own
docstring names ("a real per-value behavioral difference... is NOT flagged [as auto-fail]... only
steps are compared... reported for human judgment, not auto-failed") — flagged here for a human to
confirm, not silently dismissed.

## 8-dimension checklist

| Dimension | Score | Evidence |
|---|---|---|
| Atomicity | 2 | One `When` per scenario; outcomes only in `Then`; no compound assertions about a second behavior. |
| Coverage | 1 | `AC3` 1/1, `AC4` 1/1, `AC6` 2/2 of the in-scope conditions — but **`AC1`, `AC2`, `AC5`, `AC7` have zero scenarios** in this book (all their conditions are P3, deferred by the default P1+P2 scope, per `04-priorities.md`). A real 4/7 ACs with zero covering scenarios caps this dimension at 1, not 2, even though the gap is deliberate and disclosed — same honest-gap reasoning `US-EVAL-003` applied to its single zero-coverage AC, more pronounced here because this US's risk profile is genuinely concentrated in fewer ACs. |
| Negative-path coverage (ADR 0001) | 2 | `03-design.md`'s own negative-pressure step found **zero** `[req-neg]` conditions in this AC set (no rule in this page refuses/errors/denies anything) — with nothing to cover, the gate is vacuously satisfied, not a hidden gap. Distinct from `US-EVAL-003`'s case (real `[req-neg]` conditions existed and were P3-deferred): here there are none to defer in the first place. |
| Technique fit | 2 | `@ep` for the one representative initial-state check; `@state-transition`+`@bva` for every timing-edge condition, matching the state × event table in `03-design.md` exactly — no opportunistic tag. |
| Business correctness | 2 | Every asserted literal (`5000`, `"Hello World!"`, selector behavior) traces to **primary source** (the two example pages' own served HTML + inline JS, read directly). The one extrapolation (`Q2`, timing lower-bound semantics) is explicitly flagged `@low-confidence` on scenario `003`, not asserted with full confidence. |
| Ambiguity honesty | 2 | `Q1`/`Q2` both visible in `synthesis.md`'s open/assumption list; scenario `003` is the only `@low-confidence` scenario and cites `Q2` inline, none silently resolved. |
| Traceability | 2 | Stable `@QAIA-US-EVAL-006-NNN` IDs (`001`-`004`, no gap), `# condition:` comment on every scenario, matrix consistent with the book. |
| Gherkin form | 2 | Valid keywords, no `Background` needed (no invariant shared by all 4 scenarios — the target URL itself differs per scenario), no truncated step (confirmed by the structural pass's clean 20/20 coherence). |

**Total: 15/16.** Per the gate rule (line 31), total ≥14 with no dimension <1 and neither
traceability nor business-correctness at 1 → checklist verdict **PASS**.

## Gate decision

Two gates, stricter wins: structural = **CONCERNS** (77/100, below the 80 threshold, driven
almost entirely by the 4 deliberately-deferred P3 ACs' zero completeness contribution), checklist
= **PASS** (15/16) → **overall: CONCERNS**. This is a genuinely different result from every prior
campaign run (`US-EVAL-001`..`005`, all structural PASS) — reported as found, not adjusted to
match the pattern of prior runs; the real driver is this US's unusually concentrated risk profile
(most conditions are honestly P3) rather than any authoring defect in the book itself.

## Three highest-impact fixes

1. **Generate scenarios for the 4 P3-deferred ACs (`AC1`, `AC2`, `AC5`, `AC7`), or get an explicit
   human waiver naming them** — this is the actual gap behind both the structural CONCERNS and the
   checklist Coverage=1 score; a human should confirm this page's low-impact ACs are truly
   safe to leave uncovered rather than infer it from the priority table alone.
2. **Arbitrate `Q2` for real** (scenario `003`'s `@low-confidence` tag) — only observing the live
   page's actual timer behavior (or the target automation framework's own wait-strategy
   convention) confirms whether "lower bound, not exact instant" is the right assertion shape for
   the automation layer that will eventually execute these scenarios.
3. **Human-eyeball the one flagged redundancy group** (`001`/`003`) — confirm, as analyzed above,
   that they test the two deliberately-distinct examples this feature exists to contrast (they
   do), before accepting the structural finding as a non-issue rather than a real duplicate.

## Files modified by this audit

- None. `testbooks/dynamic-loading.feature` had no Gherkin-form defect this run; `testbook-validate`
  audits, it never rewrites test intent.

## Skill evaluation — `testbook-validate` (`plugins/qaia-core/skills/testbook-validate/SKILL.md`)

**Verdict: CONFORME.**

**Evidence**: Step 2's already-amended rule (line 19, from the 2026-07-29 campaign's prior fix)
was followed — the source (`01-extraction.md`) and the full declared AC set were passed via
`--source`/`--acs` for real, and this report states so explicitly. Step 2's requirement to
actually run the script "for true determinism" (line 14) was honored — a real subprocess call,
raw JSON output pasted above verbatim, not a mental simulation; the result (CONCERNS, not PASS)
was accepted and reported as-is rather than reframed to look more favorable, which is the harder
case for this guardrail than a clean PASS (line 21's "never averaged together" and the "two gates,
stricter wins" rule were both applied exactly, producing an overall CONCERNS even though the
checklist alone would have read PASS). Step 4's gate-decision thresholds (line 31) were applied
literally to the checklist. Step 5's three-highest-impact-fixes deliverable (line 32) is present.
No deviation between the skill's literal text and this output found. **Modification proposed:
none.**
