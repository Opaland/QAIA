# testbook-score scorecard — US-EVAL-008 (DemoBlaze cart/checkout)

Produced by applying `plugins/qaia-score/skills/testbook-score/SKILL.md` + its embedded
`rubric.md` to `eval/skill-eval-campaign-2026-07-29/US-EVAL-008-demoblaze/`.

**Fresh-eyes status (SKILL.md step 1):** this session did **not** generate the book — the book
was produced by the 2026-07-29 campaign. The generation session's reasoning was not loaded; the
only inputs read were `state/00-source.md`, `state/01-extraction.md`, `state/03-design.md`,
`testbooks/*.feature`, `testbooks/synthesis.md`, `testbooks/coverage-matrix.md` and
`reports/manifest.json`. This is a true fresh-session judge, not a self-review.

## Step 0 — deterministic structural pass (run, not simulated)

```
python eval/tools/structural_score.py \
  eval/skill-eval-campaign-2026-07-29/US-EVAL-008-demoblaze/testbooks/cart-checkout.feature \
  --acs AC1,AC2,AC3,AC4,AC5,AC6,AC7,AC8,AC9 \
  --source eval/skill-eval-campaign-2026-07-29/US-EVAL-008-demoblaze/state/00-source.md
```

Raw output: `structural-score-raw.json`. Result: **78/100, gate `CONCERNS`, `forced_stop: false`**
(readability 25/25, completeness 16.7/30, coherence 20/20, traceability 25/25, redundancy −9).
Only finding: pesticide paradox — `001`/`002`/`003` share an identical Given/When shape.
No C1 (hollow AC), no C2 (no expected result), **no sniffer hit** (see defect S-2 below — the
sniffer's literal regex does not match integer amounts, so the fabricated `$360`/`$790` in
scenario `005` escaped it).

The structural score (78/100) and the LLM rubric (12/20) are kept as **two separate numbers**,
never conflated, per SKILL.md step 0.

## Step 2/3 — the 10 rubric dimensions

| # | Dimension | Score | Evidence (one line) |
|---|---|---|---|
| 1 | Atomicity | **1** | `QAIA-US-EVAL-008-008`'s single `When` chains two UI acts ("fills 'Name' and 'Credit card' **and** clicks 'Purchase'"), and `001`–`003` fold a backend-state precondition into the `When` — isolated (≤10 % band), not systemic. |
| 2 | AC coverage | **0** | `coverage-matrix.md` has rows for AC2/AC3/AC4/AC7/AC8 only; **AC1, AC5, AC6, AC9 have no scenario at all** — the manifest itself records `acCovered: 5` / `acTotal: 9`. "Multiple AC uncovered" = 0. |
| 3 | Negative-path (ADR 0001) | **0** | `03-design.md` declares **5** `[req-neg]` conditions; `AC7-C1` and `AC7-C2` (the two required-field validation blocks) have no covering scenario — two uncovered, i.e. the rubric's "several", not its "one". Context (not scored): negative ratio 30 %, recomputed 30.0 % by the scorer. |
| 4 | ISTQB technique fit | **2** | `03-design.md`'s AC→technique map justifies each choice per AC type (decision table for AC2's `errorMessage` axis, BVA for AC7-C3's whitespace boundary), and `synthesis.md`'s by-technique table repeats the rationale per scenario; the scorer reports 0 technique-tag violations. |
| 5 | Business correctness | **1** | No scenario contradicts the source (`360 + 790 = 1150` recomputed ✔; `Product added` without the trailing period ✔ vs `Product added.` with it ✔; empty-cart `Amount: 0 USD` matches `var total = 0` ✔), **but** the `$360`/`$790` literals in `005` appear nowhere in `00-source.md` (grep: no match) and are not flagged as an assumption — an unflagged extrapolated literal. |
| 6 | Ambiguity handling | **2** | Q1/Q2/Q3 are carried as `[assumption]`/`[open]` inline in the `.feature` comments, in `synthesis.md`'s open list, and in `manifest.openArbitrations` — none silently resolved (e.g. `Q3` explicitly asks a human whether guest checkout is intended policy rather than asserting it as a requirement). |
| 7 | Stable IDs & traceability | **1** | The 10 `@QAIA-US-EVAL-008-0NN` tags are present, unique and AC-linked, and the matrix agrees — **but every checkpoint back-reference is a dangling path**: the `.feature` header cites `state/US-EVAL-008/03-design.md` and 8 `openArbitrations.sourceCheckpoint` values cite `state/US-EVAL-008/*`, while the directory is `state/` (no `US-EVAL-008/` level exists). Traceability to the design checkpoints does not resolve. |
| 8 | Gherkin form | **1** | Valid Gherkin and consistent English, but `001`–`003` express a system precondition inside `When` ("When they click 'Add to cart' **and the backend response's errorMessage is** …") instead of `Given`, and their identical Given/When shape (flagged −9 by the scorer) is a `Background`/`Scenario Outline` that was not used. |
| 9 | Prioritization | **2** | Every one of the 10 scenarios carries `@P1`/`@P2` (scorer: `missing_priority_tag: []`), the matrix's Rationale column gives the one-line risk driver per condition, and the arbitration points (`AC8-C3`/Q3) are named as "human arbitration welcome". |
| 10 | Review support | **2** | `synthesis.md` has a by-technique table, an explicit risk-ordered review order (`@low-confidence` first, then P1→P2), a confidence column in the matrix and `@low-confidence` tags on `004`/`008`/`009` (D31). |

**Total: 12 / 20.**

## Top-3 fixes (advice for `qaia-core` — named, not applied)

1. **Generate scenarios for AC1, AC5, AC6, AC9** (`testbooks/cart-checkout.feature` +
   `coverage-matrix.md`). These four ACs are entirely uncovered and alone turn dimension 2 from
   0 → 2 and lift `acCovered` 5→9, which is the single hard gate that FAILs this candidate.
   The conditions already exist in `state/03-design.md` (`AC1-C1/C2`, `AC5-C1`, `AC6-C1/C2`,
   `AC9-C1`); only the P1+P2 scope filter kept them out.
2. **Generate `AC7-C1` and `AC7-C2`** (the two `[req-neg]` required-field validation blocks) —
   dimension 3 goes 0 → 2, `reqNegCovered` 3→5 clears the second hard gate, and the negative
   ratio rises to ~5/12 ≈ 42 %, above the 40 % target, without a single mistagged scenario
   (`synthesis.md` already identifies this as the fastest lever).
3. **Repair the checkpoint paths and ground the two amounts** — replace the 9 dangling
   `state/US-EVAL-008/…` references with `state/…` in `testbooks/cart-checkout.feature` (header
   + line 80) and `reports/manifest.json` (8 `sourceCheckpoint` values), and either cite the two
   prices used in `QAIA-US-EVAL-008-005` to a real captured product or mark them
   `[assumption]` test data. Dimension 7 → 2 and dimension 5 → 2.

## Manifest write (SKILL.md step 5)

Written to **a copy** — `manifest.scored.json` — never the original. `gate` carries `score: 12`,
`max: 20`, `scoredBy: "qaia-score/testbook-score"`, `at`, and `dimensions` listing only the six
dimensions below 2. **No `verdict` was set** (step 5 reserves it for `aptitude-gate`).
