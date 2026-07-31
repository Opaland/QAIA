# testbook-validate report — US-EVAL-013 (mobile)

Book audited: `testbooks/saucedemo-mobile-navigation.feature` (17 scenarios).
Audit-only: **no file was modified by this step** (`testbook-validate` guardrail line 36).

---

## Step 2 — deterministic structural pass (real script execution, not simulated)

### Run A — the canonical invocation (`--source` = the reviewed extraction)

Every prior campaign run pointed `--source` at the `01-*` extraction checkpoint. Same choice here:

```
python eval/tools/structural_score.py \
  eval/skill-coverage-wave-2026-07-30/US-EVAL-013-mobile/testbooks/saucedemo-mobile-navigation.feature \
  --acs AC1,AC2,AC3,AC4,AC5,AC6,AC7 \
  --source eval/skill-coverage-wave-2026-07-30/US-EVAL-013-mobile/state/01-extraction.md
```

Verbatim output:

```json
{
  "file": "saucedemo-mobile-navigation.feature",
  "scenarios": 17,
  "readability": 25.0,
  "completeness": 30.0,
  "coherence": 20.0,
  "traceability": 25.0,
  "penalties": {
    "markers": 0,
    "sniffer": 25,
    "redundancy": 6
  },
  "score": 69,
  "gate": "FAIL",
  "forced_stop": true,
  "findings": [
    "fabrication sniffer: 7 untraceable technical literal(s): [('Signing out from the drawer returns the shopper to the login page', 'https://www.saucedemo.com/'), ('After signing out, requesting the catalogue URL directly is refused', 'https://www.saucedemo.com/inventory.html'), ('After signing out, requesting the catalogue URL directly is refused', 'https://www.saucedemo.com/')]",
    "pesticide paradox: 1 near-duplicate group(s) (same Given/When shape) → -6: [['At the top edge of the phone class the drawer covers the whole viewport', 'Anywhere inside the phone class the drawer covers the whole viewport']]"
  ],
  "tag_audit": {
    "missing_priority_tag": [],
    "technique_tag_violations": [],
    "negative_scenarios": 4,
    "non_smoke_scenarios": 16,
    "negative_ratio_recomputed_pct": 25.0
  }
}
```

### Run B — the same book, the same command, only `--source` = the raw capture

```
python eval/tools/structural_score.py \
  eval/skill-coverage-wave-2026-07-30/US-EVAL-013-mobile/testbooks/saucedemo-mobile-navigation.feature \
  --acs AC1,AC2,AC3,AC4,AC5,AC6,AC7 \
  --source eval/skill-coverage-wave-2026-07-30/US-EVAL-013-mobile/state/00-source.md
```

Verbatim output:

```json
{
  "file": "saucedemo-mobile-navigation.feature",
  "scenarios": 17,
  "readability": 25.0,
  "completeness": 30.0,
  "coherence": 20.0,
  "traceability": 25.0,
  "penalties": {
    "markers": 0,
    "sniffer": 5,
    "redundancy": 6
  },
  "score": 89,
  "gate": "PASS",
  "forced_stop": false,
  "findings": [
    "fabrication sniffer: 1 untraceable technical literal(s): [('A shopper with no session cannot reach any other guarded page either', 'https://www.saucedemo.com/<path>')]",
    "pesticide paradox: 1 near-duplicate group(s) (same Given/When shape) → -6: [['At the top edge of the phone class the drawer covers the whole viewport', 'Anywhere inside the phone class the drawer covers the whole viewport']]"
  ],
  "tag_audit": {
    "missing_priority_tag": [],
    "technique_tag_violations": [],
    "negative_scenarios": 4,
    "non_smoke_scenarios": 16,
    "negative_ratio_recomputed_pct": 25.0
  }
}
```

### Reading these two runs honestly

**`FAIL` / forced STOP versus `PASS` 89, from the same book and the same command, differing only in
which checkpoint file was handed to `--source`.** This is not a judgement call about the book — it
is the same defect US-EVAL-009 raised on 2026-07-29 (report line 55: *"a genuine ambiguity in
`testbook-validate` step 2's own instruction … it never specifies **which** checkpoint counts as
'the source'"*), except that there it cost −10 and here it forces a **STOP**. Recorded as
`SKILL-FINDING-A` below.

Which reading is factually right is checkable, and I checked it:

- `https://www.saucedemo.com/` and `https://www.saucedemo.com/inventory.html` are **real, live,
  observed literals**, captured verbatim in `state/00-source.md` lines 13 and 117-119
  (`After tapping it: URL becomes https://www.saucedemo.com/`).
- They are absent from `01-extraction.md` only because that file writes ACs in relative form
  (`/inventory.html`) and never quotes the absolute URL — `grep saucedemo` on it returns exactly
  one line, and it is about the out-of-scope native app.
- **Nothing was fabricated.** Run A's forced STOP is a **false positive**, traceable to an
  under-specified instruction, not to the book.

Run B's single remaining hit is a **second, distinct defect** in the tool: the literal it flags is
`https://www.saucedemo.com/<path>` — a `Scenario Outline` placeholder. `structural_score.py` never
substitutes `Examples` rows before running the sniffer, so **any parameterised URL is untraceable
by construction**. Recorded as `SKILL-FINDING-B`.

The redundancy finding is a **true positive at the shape level and a false alarm at the intent
level**, which is exactly what the detector's own docstring says it is (lines 12-16: *"reported for
human judgment, not auto-failed"*). `-001` (479/480 — the boundary) and `-003` (320/390 —
equivalence-partition representatives) do share a `Given`/`When` shape; they are two different ISTQB
techniques applied to the same rule, which `03-design.md` derives separately. Merging them would
lose the boundary/EP distinction. Reported, not "fixed".

**Structural verdict used downstream: PASS 89/100 (Run B), with Run A's forced STOP recorded as a
tooling false positive and NOT hidden.** Per the skill's own posture ("be as strict with
QAIA-generated books as with external ones"), I am not choosing Run B because it is the nicer
number — I am choosing it because the literals it accepts are the ones the target really served,
and I have shown where.

---

## Step 3 — 8-dimension checklist

| Dimension | Score | Evidence |
|---|---|---|
| Atomicity | 2 | One `When` per scenario; outcomes only in `Then`; `Scenario Outline` used for the four genuinely parameterised cases (`-001`, `-003`, `-013`, `-014`). The journey `-017` is tagged `@smoke` and excluded from atomicity accounting by its own `# condition: AC-J` note. |
| Coverage | 2 | 7/7 ACs have ≥1 asserting scenario (`completeness: 30.0`, full marks, in both runs). Confirmed independently downstream: `automate` executed **17/17** scenarios, 0 blocked. |
| Negative-path coverage (ADR 0001) | 2 | All 4 `[req-neg]` conditions (`AC3-C1`, `AC5-C2`, `AC5-C3`, `AC5-C4`) have covering `@negative` scenarios (`-004`, `-011`, `-012`, `-013`). Raw negative ratio **25.0 %** — recomputed by the tool from the file, not trusted from `synthesis.md`. Below the 40 % happy-path-bias target; reported as a signal, not scored. |
| Technique fit | 2 | `technique_tag_violations: []` — every scenario carries exactly one technique tag from the closed palette. The fits are appropriate to the shapes: `@boundary` on 479/480/481 and 899/900, `@ep` on partition representatives, `@decision-table` on the drawer-open × catalogue-reachable matrix, `@state-transition` on the open/close/re-entrance machine, `@error-guessing` on the routes the AC does not name. |
| Business correctness | **1** | No scenario contradicts the source, and every literal is a live measurement — but the whole AC set is `[reconstructed]` from black-box measurement with **no written requirement anywhere**, `extraction` is `unconfirmed`, and **6 open questions remain unarbitrated** (Q1b fractional viewport, Q2 sort-stub intent, Q3 target size, Q5 orientation, Q8 ≥481 modality, Q9 refusal behind an open drawer). Q1 in particular — *is 480 px inclusive on the phone side?* — is a **proposed default** carrying two P1 scenarios. Measured behaviour ≠ intended behaviour; full-confidence business correctness cannot be claimed. |
| Ambiguity honesty | 2 | Q1-Q9 all surfaced in `synthesis.md` and `manifest.json`; 5 scenarios carry `@low-confidence`; each carries an inline `# open:`/`# condition:` comment naming its source condition. Notably, Q1b (fractional viewport width) is left with **no scenario at all** rather than being silently defaulted — the honest choice. |
| Traceability | 2 | `traceability: 25.0` (full). Stable `@QAIA-US-EVAL-013-NNN` IDs, `@ACn` link on every scenario, `missing_priority_tag: []`, `# condition:` comment throughout, matrix consistent with the book. Chain verified end-to-end downstream: the same IDs appear in every generated test title. |
| Gherkin form | 2 | Valid keywords; `Background` correctly limited to the one genuine invariant (the target URL); `Scenario Outline`/`Examples` well-formed; `coherence: 20.0` (no truncated step, no empty `Then`). |

**Total: 15/16.**

Per step 4's rule, a total ≥14 **with business correctness at 1** forces **CONCERNS**, not PASS.

---

## Step 4 — gate decision

Two gates, the stricter wins, never averaged:

- **structural** = PASS 89/100 (Run B; Run A's forced STOP is a documented tooling false positive)
- **checklist** = CONCERNS 15/16

→ **overall: CONCERNS.**

---

## Three highest-impact fixes

1. **Arbitrate Q1 (the 480/481 inclusivity) and Q3 (the 20×20 px burger).** Q1 carries two P1
   scenarios whose expected values would *invert* if the intended breakpoint is the other side of
   480. Q3 is a live WCAG 2.2 SC 2.5.8 shortfall the run **confirmed against both engines** — the
   product needs to state whether it is an accepted deviation or a defect, because the test book
   currently encodes "20×20, below the minimum" as the *expected* result.
2. **Strengthen the AC4 oracle.** `-006`/`-007`/`-008` assert `aria-hidden`. `automate`'s real run
   proved (finding F-1, `automation/traceability.md`) that `aria-hidden` flips to `"false"` while
   the drawer is still fully off-screen (`x = -412` on a 412 px viewport) — so those three
   scenarios would pass against a drawer that never finishes opening. The `Then` should assert
   rendered geometry, which is what AC1/AC2 already do.
3. **Settle which checkpoint `--source` means** (see `SKILL-FINDING-A`) before any further campaign
   run: as long as it is ambiguous, this book's deterministic gate is `FAIL` or `PASS` depending on
   a choice the skill text does not make.

**Would you like me to apply these via `testbook-generate`'s regeneration mode?** (Step 5 requires
this to be asked as a direct request for approval, not merely mentioned — asking it explicitly.)
Nothing was auto-applied, and the `.feature` file is unchanged.

---

## Skill findings (raised, NOT fixed — no `SKILL.md` was touched by this run)

### SKILL-FINDING-A — `testbook-validate/SKILL.md` line 19: "the source" is still undefined

- **SKILL.md line 19, verbatim**: *"**Feed it the source when available** — pass `--source`/`--acs`
  explicitly in the command recorded in the report; blind, it only catches markers."*
- **Output evidence**: Runs A and B above — identical book, identical `--acs`, gate `FAIL`
  (`forced_stop: true`, score 69) vs. `PASS` (score 89), the only difference being
  `--source 01-extraction.md` vs. `--source 00-source.md`.
- **Why it matters more than in US-EVAL-009**: there the same ambiguity cost −10 on a 90/100 PASS.
  Here it crosses the ≥3-hit **forced-STOP** threshold, i.e. it flips the deterministic gate
  outright. US-EVAL-009's report recommended fixing this on 2026-07-29 and the line is unchanged.
- **Proposed diff (NOT applied)** — after *"pass `--source`/`--acs` explicitly in the command
  recorded in the report"*, insert:
  > When several source checkpoints exist, `--source` means **the raw capture concatenated with the
  > reviewed extraction** (`00-source.md` + `01-extraction.md`), never one of them alone: a literal
  > observed live but paraphrased out of the extraction is not a fabrication, and a run that scores
  > the book against only the extraction must say which file it used and report the gate as
  > **provisional**.
- **Verdict proposed to the independent evaluator: ÉCART STRUCTUREL** (it changes the gate, and it
  is a documented repeat).

### SKILL-FINDING-B — `eval/tools/structural_score.py`: the sniffer never expands `Examples`

- **Tool evidence**: Run B, `('A shopper with no session cannot reach any other guarded page
  either', 'https://www.saucedemo.com/<path>')`. The step text is
  `When the shopper requests https://www.saucedemo.com/<path> directly`; `<path>` is a
  `Scenario Outline` placeholder whose `Examples` rows are `cart.html` and `checkout-step-one.html`,
  **both traceable**.
- **Cause, in code**: `parse_scenarios()` (line 110) never reads the `Examples` table, and the
  sniffer (lines 164-171) runs `TECH_LITERAL_RE` on the raw step text. Any parameterised URL is
  therefore untraceable **by construction** — a structural false positive that penalises exactly the
  scenarios that use the technique the project's own `istqb-design` recommends.
- **Proposed fix (NOT applied)**: before the sniffer loop, substitute each `Examples` row into the
  step text and treat a literal as traceable if **any** expansion is found in the source; or, at
  minimum, skip literals containing `<…>`.
- **Note**: this is maintainer tooling under `eval/`, not a shipped skill — but
  `testbook-validate/SKILL.md` line 14 names it as the reference implementation, so the defect
  propagates into every deterministic gate the skill runs.

### SKILL-FINDING-C — no `qaia-core` skill has any notion of mobile

- **Evidence (mechanical)**: `grep -iE "mobile|viewport|responsive|touch|tactile|orientation|device|breakpoint"` over all 15
  `plugins/qaia-core/skills/*/SKILL.md` + `README.md` returns **zero true hits** (the 7 matches are
  "touches a standardized domain", "untouched", …). `istqb-design`'s technique palette, its
  step-3c recall reflexes, and `testbook-generate`'s rules contain **no** viewport, orientation,
  touch-target or breakpoint prompt of any kind.
- **Consequence observed in this run**: every mobile-specific angle in this book — the 480/481
  breakpoint, the full-viewport drawer, the occlusion decision table, the WCAG 2.2 SC 2.5.8 target
  size, the deliberately-unanswered orientation question Q5 — was derived from **live measurement
  and the producer's own initiative**, not from any prompt in the skills. Nothing in the chain would
  have stopped a run from producing a desktop test book at a small width and calling it mobile.
- **Where the claim lives instead**: `automate/SKILL.md` line 52 and `visual-check/SKILL.md` line 23
  (both one-line D100 guardrails) — i.e. mobile enters QAIA's method **only at the automation
  layer**, and only as a scope disclaimer.
- **Assessment**: **the mobile claim is thinner than the documentation implies.** D100 says mobile
  is in scope as browser emulation; what is actually in scope is *the ability to execute an
  arbitrary test book under a device descriptor*. There is no mobile **test-design** capability
  anywhere in the product. Raised for arbitration; nothing edited.
