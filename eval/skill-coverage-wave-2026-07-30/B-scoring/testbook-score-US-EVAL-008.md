# testbook-score — US-EVAL-008 (DemoBlaze cart/checkout)

Skill exercised: `plugins/qaia-score/skills/testbook-score/SKILL.md` (+ its embedded `rubric.md`).
Input: `eval/skill-eval-campaign-2026-07-29/US-EVAL-008-demoblaze/` (testbook, US, matrix,
synthesis, manifest).

**Fresh-eyes protocol (SKILL step 1):** honored — this session did **not** generate this test
book and never loaded the generation session's reasoning. It did read the upstream state files
(`00-source.md` … `04-priorities.md`) as *source/oracle*, which step 0's sniffer note explicitly
requires ("always feed it the source, never run it blind").

---

## Step 0 — deterministic structural pass (run for real, not simulated)

Command, verbatim:

```
python eval/tools/structural_score.py \
  eval/skill-eval-campaign-2026-07-29/US-EVAL-008-demoblaze/testbooks/cart-checkout.feature \
  --acs AC1,AC2,AC3,AC4,AC5,AC6,AC7,AC8,AC9 \
  --source eval/skill-eval-campaign-2026-07-29/US-EVAL-008-demoblaze/state/01-extraction.md
```

Raw output: `evidence/structural_score-US-EVAL-008.json` — **score 78/100, gate CONCERNS,
`forced_stop: false`**, one −9 redundancy finding (the 3-way `001`/`002`/`003` group),
`markers: 0`, `sniffer: 0`, `negative_ratio_recomputed_pct: 30.0`.

This reproduces byte-for-byte the numbers in the pre-existing
`reports/testbook-validate-report.md` (independent re-run, not a copy). **No forced STOP**, so
the verdict is not capped at FAIL by step 0 — it is capped by the LLM rubric instead (below).

The two numbers are kept separate per step 0: **structural 78/100** and **rubric 13/20**.

## Step 3 — independent literal verification (not trusting the book's own assertion)

| Literal | Book | Recomputed against `state/00-source.md` | Verdict |
|---|---|---|---|
| `1150` = 360 + 790 (scenario `005`) | "the displayed total equals 1150" | 360+790 = **1150** | correct |
| `Amount: 0 USD` on an empty cart (`010`) | asserted | `cart.js` line 5 `var total = 0;`, never reset; `swal` text is `"Amount: " + total + " USD"` | correct |
| 4 alert strings (`001`-`004`) | verbatim | identical to `00-source.md` lines 46-49 / 55, incl. the `"Product added."` / `"Product added"` period asymmetry | correct |
| "**the current date**" (`007`) | "…the entered Name, and the current date" | source line 134: `date.getDate() + "/" + date.getMonth() + "/" + date.getFullYear()` — **JS `getMonth()` is 0-indexed**, so the dialog renders the month **off by one** (e.g. 31/6/2026 on 31 July 2026) | **wrong-as-asserted** → dim 5 hit |
| `$360` / `$790` (`005` Given) | fixture prices | **do not appear anywhere in `00-source.md`** (grep: no hit) — untraceable technical literals the sniffer did not flag | see defect S-2 below |

---

## The 10-dimension rubric (0/1/2, default to the lower score)

| # | Dimension | Score | One-line evidence |
|---|---|---|---|
| 1 | Atomicity | **1** | `008` chains two actions in one `When` ("fills 'Name' and 'Credit card' **and clicks** 'Purchase'"), an isolated violation at the 10 % band edge — default-lower applies. |
| 2 | AC coverage | **0** | `AC1`, `AC5`, `AC6`, `AC9` have **zero** scenarios (coverage-matrix.md has no row for any of them; manifest `acCovered: 5` / `acTotal: 9`) — "multiple AC uncovered" = 0, even though the gap is disclosed. |
| 3 | Negative-path (ADR 0001) | **0** | Scored on required conditions, not the ratio (SKILL step 2): `03-design.md` declares 5 `[req-neg]`, only `AC2-C1..C3` are covered — **two** uncovered (`AC7-C1`, `AC7-C2`), which is the "several uncovered" band, not the "one uncovered" band. |
| 4 | ISTQB technique fit | **2** | Every scenario's technique tag matches `03-design.md`'s per-AC map with a stated justification (`@decision-table` on the single `errorMessage` axis, `@boundary` on the whitespace-card edge). |
| 5 | Business correctness | **1** | Scenario `007` asserts the dialog shows "the current date"; the source builds it from `date.getMonth()` (0-indexed → off-by-one month) — an unflagged extrapolation, not marked as an assumption. |
| 6 | Ambiguity handling | **2** | `Q1`/`Q2`/`Q3` are surfaced in `synthesis.md` and cited **inline** in the feature (`# assumption: Q1`, `# open: Q3`) with `@low-confidence` tags; none silently resolved. |
| 7 | Stable IDs & traceability | **2** | `@QAIA-US-EVAL-008-001` … `-010`, unique and gapless, each with an `@ACn` tag and a `# condition:` comment; the matrix's 10 rows map 1:1. |
| 8 | Gherkin form | **1** | Valid keywords throughout, but `001`/`002`/`003` push a *precondition* into the `When` ("When they click 'Add to cart' **and the backend response's errorMessage is** …") — a stubbed backend state belongs in `Given`; minor inconsistency band. |
| 9 | Prioritization | **2** | Every scenario carries `@P1`/`@P2` traced to an impact × probability score with a written rationale (`04-priorities.md`), and the arbitration point (`AC8-C3`/Q3) is named explicitly. |
| 10 | Review support | **2** | `synthesis.md` has the by-technique table, a risk-ordered review order (`@low-confidence` first), and a per-row Confidence column marking the 3 extrapolated scenarios (D31). |

**Total: 13 / 20.** (Structural pass, kept separate: 78/100.)

Caveats that cap the eventual verdict (SKILL "No inflation" guardrail): 3 `openArbitrations` of
kind `open`/`assumption` (`Q1`,`Q2`,`Q3`) and 7 of kind `simulated` are still pending human
arbitration; **every `⚠ VALIDATION` gate in the upstream state files is `simulated:
accepted-as-is`, i.e. pending-validation, never a real human Go.**

## Top-3 fixes (named, not applied — advice for `qaia-core`)

1. **Cover `AC1`, `AC5`, `AC6`, `AC9`, or record an explicit human scope waiver naming them**
   (artifact: `state/04-priorities.md` scope decision + `testbooks/cart-checkout.feature`). This
   single change moves dim 2 from 0 → 2 and lifts the hard FAIL gate; `AC5` (delete) and `AC9`
   (redirect) are trivial to write and currently entirely untested.
2. **Generate `AC7-C1`/`AC7-C2`** (the two required-field validation refusals) — artifact:
   `cart-checkout.feature` + `coverage-matrix.md`. Moves dim 3 from 0 → 2, closes the second hard
   gate, and incidentally takes the negative ratio from 30 % to ≈ 42 %.
3. **Fix scenario `007`'s date assertion** to the actual rendered shape
   (`getDate()/getMonth()/getFullYear()` — 0-indexed month, i.e. an off-by-one-month defect worth
   asserting as a *finding*, not glossed as "the current date"). Artifact:
   `cart-checkout.feature` scenario `QAIA-US-EVAL-008-007`, and `01-extraction.md`'s AC8 wording
   which is where the imprecision originates. Moves dim 5 from 1 → 2.

## Step 5 — manifest write

Written to a **copy**, never the original:
`manifest.copy.testbook-score-only.json` (gate block exactly as this skill prescribes: `score`,
`max`, `scoredBy`, `at`, `dimensions` limited to those below 2, **no `verdict`**).
See defect S-1: that prescribed shape fails the project's own contract validator.
