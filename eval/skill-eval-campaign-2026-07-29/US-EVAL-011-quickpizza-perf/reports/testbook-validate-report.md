# testbook-validate report — US-EVAL-011

## Deterministic structural pass (real script execution, not simulated)

Ran (Git Bash, real subprocess, no simulation):

```
python eval/tools/structural_score.py eval/skill-eval-campaign-2026-07-29/US-EVAL-011-quickpizza-perf/testbooks/quickpizza-recommendation.feature --acs AC1,AC2,AC3 --source eval/skill-eval-campaign-2026-07-29/US-EVAL-011-quickpizza-perf/state/01-extraction.md
```

`--source`/`--acs` were passed per this skill's own rule (line 19: "If a source/matrix exists in
the inputs but was not passed, the report must say the sniffer/completeness ran blind") — it did
not run blind here.

**Result** (real output, verbatim):

```json
{
  "file": "quickpizza-recommendation.feature",
  "scenarios": 7,
  "readability": 25.0,
  "completeness": 10.0,
  "coherence": 20.0,
  "traceability": 25.0,
  "penalties": { "markers": 0, "sniffer": 0, "redundancy": 9 },
  "score": 71,
  "gate": "CONCERNS",
  "forced_stop": false,
  "findings": [
    "pesticide paradox: 1 near-duplicate group(s) (same Given/When shape) -> -9: [[\"The 95th percentile response time stays under the project's own published threshold under sustained concurrent load\", \"The 99th percentile response time stays under the project's own published threshold under sustained concurrent load\", \"The HTTP error rate stays under the project's own published threshold under sustained concurrent load\"]]"
  ],
  "tag_audit": {
    "missing_priority_tag": [],
    "technique_tag_violations": [],
    "negative_scenarios": 4,
    "non_smoke_scenarios": 7,
    "negative_ratio_recomputed_pct": 57.1
  }
}
```

### Finding 1 — real defect in the producer's own artifact, found by this audit (not a skill defect)

The script's `tag_audit.negative_scenarios: 4` **contradicts `synthesis.md`'s own claim of 3/7
(42.9%)**. Re-inspecting the `.feature` file line by line: scenario `001` (`AC1-C3`, the
missing-`Authorization`-header condition) is tagged `@negative` on its own tag line
(`@QAIA-US-EVAL-011-001 @AC1 @P1 @negative @ep @open @low-confidence`), **despite its `Then`
asserting a positive outcome** ("the request is not rejected solely for missing authentication")
and despite `synthesis.md`'s "Tagging nuance" section explicitly claiming "scenario `001`...
[is] correctly **not** `@negative`." **This is a real, self-inconsistent defect in the artifact
this run produced** — the `.feature` file's tag was never actually corrected to match the
reasoning written in `synthesis.md` and `coverage-matrix.md`. Per `testbook-validate`'s own
audit-only guardrail ("no file modification, ever"), this report does **not** silently fix it —
it is recorded here for human arbitration/regeneration, exactly the D38 discipline this campaign
requires. The script's `57.1%` is the **real, verified** negative ratio of the artifact as it
exists on disk; `synthesis.md`'s `42.9%` claim is wrong and should be corrected by a human-approved
regeneration pass, not by this report.

### Finding 2 — redundancy penalty, likely a scorer false-positive on genuinely distinct metrics

The `-9` redundancy penalty groups scenarios `002`/`003`/`004` (p95 latency, p99 latency, HTTP
error rate) as a "near-duplicate group (same `Given`/`When` shape)". Per `testbook-validate`'s own
guardrail ("a real per-value behavioral difference — a distinct validation rule, a distinct
boundary — is not a duplicate and must not be flagged as one"), these three scenarios differ by
**which metric is being asserted** (p95 vs. p99 vs. error rate), not merely by a literal value
within the same rule — arguably three distinct boundary conditions the design stage (`03-design.md`
AC2-C1/C2/C3) deliberately separated. This looks like a **scorer limitation**: the redundancy
heuristic (same `Given`/`When` text shape) cannot distinguish "same shape, same rule, different
literal" from "same shape, three different metrics under one load run." Recorded as a finding for
human arbitration on whether the scorer's redundancy heuristic needs a metric-name exception, not
silently excluded from the score.

## 8-dimension checklist

| Dimension | Score | Evidence |
|---|---|---|
| Atomicity | 2 | One `When` per scenario, outcomes only in `Then`; no `Scenario Outline`s in this book. |
| Coverage | 2 | AC1, AC2, AC3 each have ≥1 covering scenario (`001`; `002-004`; `005-007`). AC1-C1/C2 (P3, no happy-path) are a cited scope waiver, not a silent AC-level gap. |
| Negative-path coverage (ADR 0001) | 2 | All 5 `[req-neg]` design-stage conditions (AC1-C3, AC2-C3, AC3-C1/C2/C3) have a covering generated scenario with citation — though two of those covering scenarios (`001`, `004`) assert a non-refusal outcome by design (proposed defaults resolve to "accepted"/"within bound"), which is a distinct, separately-flagged issue (Finding 1), not a coverage gap. |
| Technique fit | 2 | `@ep`/`@domain-analysis` for the validation classes, `@boundary` for the performance thresholds — each justified in `03-design.md`, including an explicit note on `@boundary`'s non-standard repurposing for AC2 (the "Palette fit note"). |
| Business correctness | 1 | Every scenario in this book rests on either an `[assumption]` (Q2, Q4, Q5) or an `[open]` proposed default (Q1, Q6) — no scenario has ever been executed against a live instance (see `synthesis.md`'s sourcing honesty note), and AC2's own grounding (Q2) is itself unconfirmed as an official SLO vs. a teaching example. Two of the five P1 scenarios (`001`, `007`) additionally rest on genuinely `[open]` items that could resolve to the opposite of what is asserted. |
| Ambiguity honesty | 2 | Q1-Q8 all visible in `synthesis.md`'s open/assumption list; `001`, `007` explicitly labeled "proposed default, unconfirmed" in their own scenario titles; the "Tagging nuance" and "Coverage note" sections surface real design-vs-generation tensions rather than silently reconciling them. |
| Traceability | 1 | Stable `@QAIA-US-EVAL-011-NNN` IDs and `# condition:` comments are present and correct throughout, but Finding 1 above is exactly a traceability-consistency defect: the `001` scenario's own tag line contradicts both its `Then` and the synthesis document's stated reasoning about it — a matrix/synthesis/`.feature` mismatch, not merely a hypothetical one. |
| Gherkin form | 2 | Valid keywords; no `Background` (correctly omitted — no invariant holds across all 7 scenarios: some are unauthenticated, some load-run preconditions, some single-request preconditions). |

**Total: 14/16.** Per the gate rule, a total ≥14 with **either traceability or business correctness
at 1** forces **CONCERNS**, not PASS — here **both** land at 1, for two independently real reasons
(an artifact-level tag inconsistency this audit caught, and the wholly-unexecuted, `[open]`-heavy
grounding of the book's P1 scenarios).

## Gate decision

Two gates, stricter wins: structural = **CONCERNS** (71/100, driven by the completeness gap and
the redundancy penalty above), checklist = **CONCERNS** (14/16, business correctness and
traceability both at 1) → **overall: CONCERNS**.

## Three highest-impact fixes

1. **Fix the `001` tag/outcome inconsistency (Finding 1) via a human-approved regeneration pass** —
   either remove `@negative` from `001`'s tag line to match its actual positive-outcome `Then`
   (and correct `synthesis.md`'s ratio to the real 57.1%... after removing the mistagged scenario,
   whichever correction the human arbiter prefers), or rewrite `001`'s `Then` to a genuine refusal
   if the human arbiter decides the *other* proposed default for Q1 (auth required, refused when
   missing) is the one to ship instead. Either way, this is not fixed silently by this report.
2. **Arbitrate Q1 and Q6 for real** (`AC1-C3`/`001`, `AC3-C3`/`007`) — both are P1, both rest on
   unconfirmed proposed defaults, and Q6's own numeric boundary (`MaxPizzaNameLength`) is not even
   known, so `007`'s probe value is a stand-in, not a real boundary test.
3. **Actually execute a k6 run (or `perf-check`) against a self-hosted QuickPizza instance** — this
   is the direct, structural reason completeness is only 10.0/30 (only AC2's scenarios carry
   concrete literals an automated sniffer can verify) and, more importantly, no scenario in this
   book has ever been checked against real behavior: AC2's thresholds are the project's own
   teaching example, never confirmed as an SLO (Q2), and AC1/AC3's refusal assumptions (Q4, Q5) are
   equally unverified. This is the explicit limitation this campaign run was scoped to accept (no
   Docker/k6 in this sandboxed worktree) — flagged here, not silently worked around.

No file was modified by this audit (`testbook-validate` is audit-only, per its own guardrails) —
including the real `001` tag defect found above, which is reported, not patched.

## Skill evaluation — `testbook-validate`

- **Skill evaluated**: `plugins/qaia-core/skills/testbook-validate/SKILL.md`.
- **Input**: `quickpizza-recommendation.feature` (7 scenarios), `01-extraction.md` as `--source`.
- **Output**: this report.
- **Verdict**: **CONFORME.**
- **Evidence**: line 19's rule that a source available but not fed must be reported as a blind run
  was correctly avoided by actually passing `--source`/`--acs` in the recorded command. Line 21's
  rule that the structural pass and the checklist stay "separate... never averaged together" is
  respected: the report shows 71/100 and 14/16 as two distinct numbers, combined only at the
  gate-decision step by taking the stricter of the two (here, both landed on CONCERNS
  independently, not forced by one dominating the other). Line 38 ("be as strict with
  QAIA-generated books as with external ones... a self-indulgent validator is worthless") is
  exercised concretely: this audit did not smooth over the real `negative_scenarios` mismatch
  between the script's ground truth (4, 57.1%) and the producer's own prior claim in
  `synthesis.md` (3, 42.9%) — it named the artifact's own defect explicitly (Finding 1) rather than
  reporting the script number without reconciling it, and rather than quietly editing
  `synthesis.md` to make the discrepancy disappear (which would have violated the audit-only
  guardrail, line 36).
- **Modification proposed**: none.
