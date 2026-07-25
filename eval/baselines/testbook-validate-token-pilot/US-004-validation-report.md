# testbook-validate — audit report

**Book audited**: `examples/expense-demo/qaia-journey/testbooks/US-004/` (4 `.feature`
files, `coverage-matrix.md`). **Source US**: `eval/gold-set/US-004-expense-approval.md`
(story + 8 numbered ACs; the "Judge reference — planted ambiguities" section was excluded
from the source text fed to this audit, per that file's own instruction that it is "NOT
part of the US text given to the skills"). **Skill applied**: `testbook-validate`
(`plugins/qaia-core/skills/testbook-validate/SKILL.md`), steps 1-5, no shortcut.

## Step 1 — Collect the pieces

- 4 `.feature` files: `approval-chain.feature` (13 scenarios), `audit-and-auth.feature` (9),
  `line-items.feature` (7), `workflow-state-machine.feature` (9) — 38 total.
- Source US available (`eval/gold-set/US-004-expense-approval.md`, 8 ACs) → coverage and
  business-correctness are assessable, not `not assessable`.
- Coverage matrix available (`coverage-matrix.md`) → traceability cross-check possible.

## Step 2 — Deterministic structural pass (script executed, not an LLM impression)

Ran `eval/tools/structural_score.py` once per `.feature` file with
`--acs AC1,AC2,AC3,AC4,AC5,AC6,AC7,AC8` and `--source` pointed at the US-004 story+AC text
(fabrication sniffer active). Full raw output and full (untruncated) finding lists:
`eval/baselines/testbook-validate-token-pilot/structural-score-raw.txt`.

| File | Score /100 | Gate | Forced STOP | Key findings |
|---|---|---|---|---|
| `approval-chain.feature` | **41** | **FAIL** | **yes** | sniffer: 11 untraceable EUR-amount literals (-25, capped); pesticide paradox: 3 near-duplicate Given/When groups (-15) |
| `audit-and-auth.feature` | 69 | CONCERNS | no | sniffer: 1 untraceable literal (`499.99 EUR`) |
| `line-items.feature` | 75 | CONCERNS | no | pesticide paradox: 1 near-duplicate group (-6) |
| `workflow-state-machine.feature` | 79 | CONCERNS | no | pesticide paradox: 1 near-duplicate group (-6) |

**Book-wide structural gate: FAIL** — `approval-chain.feature` trips the sniffer's forced
STOP (≥3 untraceable technical literals; it has 11), and per SKILL.md step 4 "the structural
pass can override toward FAIL... two gates, the stricter wins."

**Read carefully before treating this as 11 fabricated numbers** (evidence, not a
downgrade of the mechanical result — the deterministic score stands as computed):

- **9 of the 11 hits are boundary-value literals derived directly from the source's stated
  thresholds** (€500, €5000) via standard boundary-value analysis: `499.99`, `500.00`,
  `5000.00`, `5000.01` EUR, plus one mid-band value `100.00` EUR. The sniffer does exact
  string matching against the source text; it has no notion of "derived from a stated
  threshold by ±0.01," so every one of these is flagged even though none of them is
  invented data — a known class of limitation already documented in
  `eval/baselines/structural-score.md` ("heuristic regex... a verifiable Then formulated
  exotically can slip through" — the converse also holds: a legitimate derived value can
  get flagged). This is not being silently corrected in the script; it is called out here
  as an honest read of a mechanical result, exactly as the tool's own documentation does
  for its own known gaps.
- **2 of the 11 hits are a genuinely different, more substantive concern**: the converted
  totals `500.10 EUR` (from 543.00 USD) and `91.90 EUR` (from a "stale rate" fallback) in
  `approval-chain.feature`'s AC6 scenarios. AC6 says currency is "converted at the rate of
  the expense date," but **no rate source is cited anywhere** — not in the `.feature` file
  (no `# oracle:`-style provenance comment), not in `coverage-matrix.md`. These two
  scenarios are already tagged `@low-confidence` with an inline `open: Q4` comment
  acknowledging "rate source undefined" — so the *interpretation* is honestly flagged —
  but the *specific numeric literal* asserted to the cent (`500.10`, `91.90`) is not
  traceable to any cited source. This is the more actionable of the two sniffer signals
  (see Fix #1 below) and independently corroborates a gap the book's own authors already
  suspected (Q4 in `coverage-matrix.md`).
- The **pesticide-paradox findings are real and not false positives**: the flagged groups
  share an identical `Given`/`When` shape with only a literal changed, and — checked
  manually against the rule that a genuinely distinct `Then` is not a duplicate — in all 4
  flagged groups across the book the `Then` outcomes ARE genuinely different per scenario
  (different approval routing, different final status). So these are legitimate signals for
  human judgment (per the detector's own design, redundancy alone never forces STOP) rather
  than defects: they read as intentional decision-table/boundary coverage, not copy-paste
  filler, but are reported because the detector's step-shape heuristic cannot distinguish
  the two automatically.

**Independent recomputations** (not trusted from the book's own self-reported numbers, per
the tool's "no producer scores/validates itself" rule):
- **Negative ratio, book-wide**: 17/37 = **45.9%**, recomputed directly from the `.feature`
  files. Matches `coverage-matrix.md`'s claimed 45.9% exactly — ADR 0001's ≥40% threshold
  is independently confirmed met, not just self-reported.
- **AC coverage, book-wide** (per-file `--acs` runs above understate this by construction,
  since each file only holds a subset of the 8 ACs): **8/8 ACs** have at least one scenario
  with a real, concrete `Then`-assertion. Full detail in `structural-score-raw.txt`.
- Tag hygiene (`tag_audit`): 0 scenarios missing a priority tag, 0 technique-tag-count
  violations, across all 4 files.

## Step 3 — 8-dimension checklist

| # | Dimension | Score | Evidence |
|---|---|---|---|
| 1 | Atomicity | **1** | Two scenarios chain multiple approval actions inside a single `When` clause: `AC2-C3`/`@QAIA-US-004-010` ("`When "manager@demo" approves report "R" and "finance@demo" approves report "R"`") and `AC2-C4`/`@QAIA-US-004-011` (3 chained approvals). The remaining 36/38 scenarios are single-action. Isolated but a real "one `When`" violation, not hypothetical. |
| 2 | Coverage | **2** | 8/8 ACs independently confirmed covered by ≥1 scenario with a real assertion (book-wide recomputation above); matches `coverage-matrix.md`'s "all 8 AC have ≥2 scenarios each" claim on spot-check (e.g. AC4: scenarios 017/018/019). |
| 3 | Negative-path coverage (ADR 0001) | **2** | All 17 `[req-neg]` conditions listed in `coverage-matrix.md` have a matching `@negative`-tagged scenario (spot-checked: AC1-C4/005, AC1-C5/006, AC2-C5/012, AC3-C1/013, AC5-C2/021, AC6-C2/025, AC7-C1/028, AC7-C2/029, AC8-C1/030, AC8-C2/031, AC-auth-C1/035, AC-auth-C2/036, AC-auth-C3/037 — 13+ checked, none missing); ratio independently recomputed at 45.9%, ≥40% target met. |
| 4 | Technique fit | **2** | Tags match requirement shape: `@state-transition` on the lifecycle FSM (AC1/AC7), `@decision-table` on the approval-chain/self-approval matrix (AC2/AC3), `@boundary` on the €500/€5000/90-day/€25 thresholds, `@ep`/`@error-guessing` on currency and input-completeness conditions. 0 technique-tag-count violations (tag_audit). |
| 5 | Business correctness | **1** | No scenario contradicts the source. The AC6 currency-conversion scenarios are the one soft spot: the *interpretation* is flagged (`@low-confidence`, `open: Q4`), but the *specific converted amounts* (`500.10 EUR`, `91.90 EUR`) are asserted to the cent with no cited rate source anywhere in the book — an extrapolation that is flagged as uncertain in kind but not sourced in magnitude (contrast with `oracle-generate`'s convention of a `# oracle:` provenance comment citing the exact source used). Everything else reads as correct against the source. |
| 6 | Ambiguity honesty | **2** | Standout strength: 9 scenarios carry `@low-confidence` with an inline `open: QN (...)` comment naming the exact interpretive choice made (Q1 €500/€5000 inclusivity, Q2 self-approval skip semantics, Q3 reject-from-returned-draft, Q4 FX rate/fallback ×2, Q5 90-day clock reference, Q6 receipt threshold on converted vs. face value, Q7 triple-intersection, Q8 generalization beyond the named example) — matching the 4 ambiguities the source itself plants for judge reference. No silent resolution found. |
| 7 | Traceability | **2** | Stable unique IDs `@QAIA-US-004-001`..`038`, no gaps (confirmed by direct read of all 4 files, not just trusting the matrix's "no gaps" claim); every scenario's AC tag(s) match its `coverage-matrix.md` row on every spot-check performed (e.g. `@QAIA-US-004-027` tagged `@AC2 @AC3 @AC6` = matrix row "AC2,AC3,AC6"). |
| 8 | Gherkin form | **2** | Valid `Given`/`When`/`Then`/`And` keywords throughout; `Background` used consistently and appropriately per file (SUT reset, role hierarchy, signed-in actor); no `Scenario Outline` used anywhere, but none of the tested conditions actually calls for a parameterized table over the discrete boundary/EP cases chosen — not a gap. |

**Total: 14/16.**

## Step 4 — Gate decision

- Checklist alone: total = 14 (≥14) but **Business correctness = 1** → per SKILL.md step 4
  this is **CONCERNS**, not PASS ("total ≥ 14 with any traceability/business-correctness
  dimension at 1").
- Structural pass (step 2): **FAIL**, forced STOP on `approval-chain.feature`.
- **Final gate: FAIL** — "two gates, the stricter wins"; the structural forced STOP caps the
  book at FAIL regardless of the checklist's 14/16.

## Step 5 — Three highest-impact fixes

1. **Cite the FX rate source used for the two converted-total assertions** in
   `approval-chain.feature` (`@QAIA-US-004-024` → `500.10 EUR` from 543.00 USD;
   `@QAIA-US-004-026` → `91.90 EUR` via the stale-rate fallback). Add a provenance comment
   (same convention as `oracle-generate`'s `# oracle:` tag) or explicitly mark the numeric
   literal itself as illustrative pending Q4's resolution, so a reader can't mistake "the
   interpretation is flagged" for "the number is sourced." Resolves the sniffer's one
   substantive hit and tightens Business correctness from 1 to 2.
2. **Split the two multi-approval `When` chains** (`@QAIA-US-004-010`, `@QAIA-US-004-011`)
   into a `Given` precondition ("a report already approved by the manager [and finance]")
   plus a single final `When` action, restoring one-`When`-per-scenario atomicity without
   losing the boundary coverage.
3. **Human-adjudicate the 3 flagged near-duplicate groups in `approval-chain.feature`**
   (same `Given`/`When` shape, different `Then`) — this audit's manual check found the
   outcomes genuinely distinct in all 3, so likely no rewrite is needed, but the pattern is
   dense enough in this one file (3 of 13 scenarios) to warrant an explicit "reviewed, kept"
   note in the matrix rather than leaving it as an open structural finding.

## Offer

`US-004`'s test book is QAIA-managed (`examples/expense-demo/qaia-journey/`). Per this
skill's guardrails, no file was modified by this audit — it is offered, not applied: fixes
1-2 above are mechanical enough to run through `testbook-generate`'s diff-based
regeneration mode if the maintainer wants them applied; fix 3 is a documentation call for a
human, not a regeneration.
