# testbook-validate report — US-EVAL-010

## Deterministic structural pass (real script execution, not simulated)

Ran, for real:

```
python eval/tools/structural_score.py \
  eval/skill-eval-campaign-2026-07-29/US-EVAL-010-crapi-security/testbooks/vehicle-location-bola.feature \
  --acs AC1,AC2,AC3,AC4 \
  --source eval/skill-eval-campaign-2026-07-29/US-EVAL-010-crapi-security/state/01-extraction.md
```

(source fed explicitly per this skill's own step 2/line 19 requirement — not run blind — so
`completeness`/`sniffer` below are source-checked, not defaulted.)

**Result (raw tool output, unedited):**

```json
{
  "file": "vehicle-location-bola.feature",
  "scenarios": 5,
  "readability": 25.0,
  "completeness": 22.5,
  "coherence": 20.0,
  "traceability": 25.0,
  "penalties": { "markers": 0, "sniffer": 0, "redundancy": 6 },
  "score": 86,
  "gate": "PASS",
  "forced_stop": false,
  "findings": [
    "pesticide paradox: 1 near-duplicate group(s) (same Given/When shape) -> -6: [[\"A cross-owner request never returns another user's vehicle location\", \"A cross-owner request is denied with a not-found status, not a leak-confirming status\"]]"
  ],
  "tag_audit": {
    "missing_priority_tag": [],
    "technique_tag_violations": [],
    "negative_scenarios": 0,
    "non_smoke_scenarios": 5,
    "negative_ratio_recomputed_pct": 0.0
  }
}
```

## Real defect caught by the tool, not by re-reading the book (the whole point of step 2)

**`tag_audit.negative_scenarios: 0` and `negative_ratio_recomputed_pct: 0.0` contradict
`testbooks/synthesis.md`'s own claim of "5/5 blocks tagged `@negative` = 100 %".** Inspecting
`vehicle-location-bola.feature` confirms the tool is right and the synthesis is wrong: **none of
the five scenarios actually carries the `@negative` tag** — `testbook-generate`'s own generation
rules require it ("Plus tags: ... `@negative` where applicable") and every scenario in this book is
a refusal/denial path, so it applies to all five, yet the tag itself was never written into the
`.feature` file's tag lines (only `@AC<n>`, `@P<n>`, and the technique tag were emitted). This is a
genuine authoring defect in this run's `testbook-generate` output, caught precisely because the
structural pass recomputes the ratio from the file's actual tags rather than trusting the
synthesis's prose claim — exactly the discipline step 2 exists to enforce (real script execution
over LLM self-report). **Not silently fixed here**: per this skill's own guardrail ("Audit only: no
file modification, ever"), `vehicle-location-bola.feature` is left as generated; this is flagged as
the top fix for a human-approved regeneration pass, not patched in place during validation.

## Redundancy finding (`-6`, one group) — a legitimate near-duplicate this time, not a false-flag

Unlike prior campaign runs' redundancy findings (`US-EVAL-003`, `US-EVAL-006`), this one is **not**
a false-flag from digit-normalization: scenarios `001` and `002` share an **identical** `Given`/
`When` shape *by design* — both exercise the exact same cross-owner request
(`user A requests .../{vehicleId}/location for user B's vehicleId`), split into two scenarios only
because they carry different priorities and confidence levels (`001` is P1/full-confidence "no
data leak"; `002` is P2/`@low-confidence` "specific status code", per `state/02-understanding.md`'s
Q1). This is the correct application of `testbook-generate`'s own merge rule ("`Scenario Outline`...
merged only when all example rows share the same priority and confidence — otherwise split") — the
split is right, but it does produce a real, expected near-duplicate `Given`/`When` pair. Flagged
for human confirmation, not auto-dismissed, per the scorer's own documented human-judgment
carve-out — but this case is genuinely closer to "yes, a real structural duplicate," just one this
skill's own generation rules require anyway (different priority/confidence bars a merge into one
Outline).

## 8-dimension checklist

| Dimension | Score | Evidence |
|---|---|---|
| Atomicity | 2 | One `When` per scenario; outcomes only in `Then`; no compound assertion about a second, unrelated rule. |
| Coverage | 1 | `AC2` 2/2, `AC3` 2/2, `AC4` 1/1 of the in-scope conditions — but **`AC1` has zero scenarios** (its one condition, the owner happy path, is P3-deferred per `04-priorities.md`). A real 3/4 ACs covered caps this at 1, same honest-gap pattern as `US-EVAL-006`. |
| Negative-path coverage (ADR 0001) | 2 | Every `[req-neg]` condition from `03-design.md` (`AC2-C1`, `AC2-C2`, `AC3-C1`, `AC3-C2`, `AC4-C1`) has a covering scenario that actually asserts the refusal — scored on real coverage, not the (broken) tag-based ratio; the missing-`@negative`-tag defect above is a **tagging/traceability** gap, not a coverage gap — the assertions themselves are present and correct. |
| Technique fit | 2 | `@decision-table` for the authentication × ownership cross (AC2), `@ep` for the two invalid-auth classes (AC3), `@error-guessing` for the nonexistent-ID BOLA/IDOR catalog case (AC4) — matches `03-design.md`'s map exactly. |
| Business correctness | 2 | Every literal traces to primary source (`docs/challenges.md` Challenge 1, quoted) or is explicitly flagged `@low-confidence` with an inline assumption comment (`002`, `005`) rather than asserted with false confidence. |
| Ambiguity honesty | 2 | `Q1`/`Q2`/`Q3` all visible in `synthesis.md`'s open/assumption list; `002` and `005` are the only `@low-confidence` scenarios and both cite their question inline. |
| Traceability | 2 | Stable `@QAIA-US-EVAL-010-NNN` IDs (`001`-`005`, no gap), `# condition:` comment on every scenario, matrix consistent with the book — the missing `@negative` tag does not break AC/condition traceability itself. |
| Gherkin form | 1 | Valid keywords, no truncated step (coherence 20/20 confirms it), no `Background` needed — but **the missing `@negative` tag on all 5 scenarios is a real closed-tag-list omission** (`testbook-generate`'s own rule: "Plus tags: ... `@negative` where applicable"), caught by the structural pass's `tag_audit`, not by inspection. This single, tool-confirmed omission caps the dimension at 1. |

**Total: 14/16.** Per the gate rule (line 31), total ≥14 with no dimension <1, and neither
traceability (2) nor business-correctness (2) at 1 → checklist verdict **PASS** — but the missing-
tag defect is real and is the report's top fix regardless of the numeric gate.

## Gate decision

Two gates, stricter wins: structural = **PASS** (86/100, no forced stop), checklist = **PASS**
(14/16) → **overall: PASS, with one flagged authoring defect requiring a regeneration pass** (the
missing `@negative` tags). Reported as found — the PASS gate is not adjusted or softened by the
defect below the numeric threshold, and the defect is not hidden by the PASS either; both are true
at once and both are stated.

## Three highest-impact fixes

1. **Add the `@negative` tag to all five scenarios** (`001`-`005`) via `testbook-generate`'s
   regeneration mode — the current omission makes the file's own tag-based negative ratio read as
   `0 %` to any tool or reviewer that trusts tags over prose, directly contradicting
   `synthesis.md`'s claim; this is the one concrete, mechanical fix a human should approve before
   this book is treated as complete.
2. **Generate a scenario for `AC1-C1` (the owner happy path), or get an explicit human waiver
   naming it** — `AC1` is the only AC with zero scenarios in this book; a security-authorization
   test book with no positive-path assertion at all cannot demonstrate the *fixed* endpoint working
   correctly, only that it correctly refuses — both are needed for a complete confidence picture.
3. **Arbitrate `Q1`/`Q3` for real** (the `404` vs `403` denial status code, scenarios `002` and
   `005`) — only reading the target's actual (or intended-fixed) implementation, or an explicit
   team convention, resolves this; both scenarios currently encode the anti-disclosure-favoring
   default without full confidence.

## Explicit limitation — no live execution against any crAPI instance

**This report validates the Gherkin test book's structure only.** Per this campaign's explicit
instruction, no Docker container was started and no live crAPI instance was reached from this
sandboxed worktree — there is no network/Docker access here, and `security-surface` (the skill
step 8 would dispatch to for this AC set) requires a genuinely self-hosted running target to be
meaningful, per `docs/DEMO-TARGETS.md`'s golden rule. **No scan result, exploit outcome, or live
HTTP response is reported anywhere in this run — simulating one would violate the same discipline
D118 already established** ("if script execution isn't possible, say so, never silently degrade").
What *was* run for real is the deterministic structural script above, over the static `.feature`
file — that is the full extent of "real execution" honestly available in this environment.

## Files modified by this audit

- None. `vehicle-location-bola.feature` had no Gherkin-form defect requiring a rewrite (the
  missing-tag defect is flagged for a human-approved regeneration, not patched here);
  `testbook-validate` audits, it never rewrites test intent.

## Skill evaluation — `testbook-validate` (`plugins/qaia-core/skills/testbook-validate/SKILL.md`)

See separate evaluator pass (spawned after this checkpoint).
