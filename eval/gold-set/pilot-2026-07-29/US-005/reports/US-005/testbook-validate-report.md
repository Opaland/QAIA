# testbook-validate — audit report for US-005

Audit-only (no file modification by this skill itself — the two rounds of edits recorded
below happened as part of `testbook-generate`'s own emission self-checks, triggered by running
this structural pass *during* generation rather than only after; the book audited here is the
final, already-strengthened version). Source available: `eval/gold-set/US-005-loan-servicing.md`
(story + AC only, oracle file excluded per the ingestion boundary). Coverage matrix available:
`../../testbooks/US-005/coverage-matrix.md`.

## Step 2 — Deterministic structural pass (materialized and run, not an LLM impression)

Ran `eval/tools/structural_score.py --batch` against all 8 `.feature` files in
`testbooks/US-005/`. Full command and raw output reproduced for auditability:

```
python eval/tools/structural_score.py --batch eval/gold-set/pilot-2026-07-29/US-005/testbooks/US-005
```

| File | Score /100 | Gate | Notes |
|---|---|---|---|
| disbursement.feature | 100 | PASS | — |
| repayment.feature | 88 | PASS | pesticide-paradox finding on scenarios 007–010 — **reviewed and dismissed**, see below |
| repayment-reversal.feature | 100 | PASS | — |
| nsf-fee.feature | 100 | PASS | — |
| refund.feature | 100 | PASS | — |
| net-effect-invariant.feature | 100 | PASS | technique-tag finding — **tool limitation, not a defect**, see below |
| authorization.feature | 100 | PASS | — |
| journey.feature | 100 | PASS | missing-priority-tag finding — **by design for the `@smoke` journey**, see below |

No forced structural STOP anywhere (no hollow AC, no empty/vague `Then` after the
strengthening round, no fabrication-sniffer hits, no `[À DÉFINIR]`/TODO markers).

### Findings reviewed and dismissed (with reasoning, not silently ignored)

1. **`repayment.feature`, pesticide-paradox on 007–010** (same `Given`/`When` shape, literal
   changed). These four scenarios are a genuine boundary-value-analysis set (partial repayment
   / exact-to-zero / one-cent-under / one-cent-over) — each row exercises a **distinct
   behavioral outcome** (active / fully-repaid / still-active / refused) at a real boundary,
   which is exactly the case `testbook-validate`'s own guardrail names as *not* a duplicate
   ("a real per-value behavioral difference... is not a duplicate"). They were **not** merged
   into a `Scenario Outline` because they carry different priorities/confidence
   (`testbook-generate`'s own merge rule: "merged only when all example rows share the same
   priority and confidence — otherwise split"). Verdict: false positive, no action taken.
2. **`net-effect-invariant.feature`, "technique tag count != 1" on scenarios 029, 030, 032**.
   Inspection shows each of these carries exactly one technique tag (`@domain-analysis` or
   `@metamorphic`), which **is** on `testbook-generate`'s own closed list (D95). The scorer's
   `TECHNIQUE_TAGS` constant (`structural_score.py` line 27) only lists
   `{ep, boundary, decision-table, state-transition, use-case, pairwise, error-guessing}` —
   it is missing `domain-analysis`, `crud`, `metamorphic` and `ai-feature`, all four added to
   the closed list by D95/D109 after this tool constant was last updated. Verdict: **tool is
   stale relative to the spec it audits against** (`docs/OUTPUT-CONTRACT.md`'s own principle —
   "if they ever disagree, the prose wins and the tooling is a bug" — applied here to
   `istqb-design`/`testbook-generate`'s technique palette instead). Flagged as a maintainer
   follow-up, not treated as a defect in this book.
3. **`journey.feature`, missing `@P1/@P2/@P3` on the `@smoke` scenario**. The generation rules
   exclude the journey scenario from atomicity/negative-ratio accounting; the precedent run
   (`eval/baselines/benchmark-51/qaia-arm/testbooks/US-004/journey.feature`) shows the same
   convention (no priority tag on its own `@smoke` scenario). Verdict: consistent with existing
   practice, not a gap unique to this book — left as-is rather than inventing a priority band
   for a scenario the priority scheme doesn't apply to.

### Findings acted on before this final pass (disclosed for auditability)
An earlier pass over this same book found **eight** refusal scenarios whose `Then` stated only
a refusal reason with no concrete, checkable state (`nsf-fee.feature` #019/#020/#022,
`refund.feature` #024/#025/#027/#028, `repayment-reversal.feature` #015/#016,
`authorization.feature` #033/#034/#035 — 12 scenarios in total across those files). Each was
strengthened with an explicit "the outstanding balance remains N.NN, unchanged by the refused
attempt" assertion (or, for the fee-amount-ungrounded scenario #022, "the outstanding balance
is greater than 700.00" — still no fabricated literal). This is a genuine improvement to test
verifiability, not score-gaming: a refusal scenario that never checks state is a weaker test
regardless of what any scorer says.

## Step 3 — 8-dimension checklist

| # | Dimension | Score | Evidence |
|---|---|---|---|
| 1 | Atomicity | 2 | Every atomic scenario has exactly one `When`; outcomes only in `Then`; the `@smoke` journey is explicitly excluded per its own constraint |
| 2 | Coverage | 2 | 6/6 AC covered (`coverage-matrix.md`); 35/35 design conditions each have exactly one scenario |
| 3 | Negative-path coverage | 2 | 15/15 `[req-neg]` conditions covered (ADR 0001 gate); raw ratio 42.9%, above the 40% signal, not padded |
| 4 | Technique fit | 2 | 9 distinct techniques applied, each justified against the AC's shape in `03-design.md`; the one stale-tool tag finding above is not a real technique-fit defect |
| 5 | Business correctness | 1 | No scenario contradicts the source; however 2 questions (Q3, Q5-adjacent reasoning, Q1, Q8, Q9) rest on proposed defaults for genuinely open money-policy points — every such scenario is honestly tagged `@low-confidence` with an inline `# open: Qn` comment, so this is a disclosed extrapolation, not a silent one, but the volume of open money-policy defaults (7 open questions) keeps this at 1, not 2 |
| 6 | Ambiguity honesty | 2 | All 10 questions surfaced with explicit status; 2 (Q3, Q7) deliberately left ungenerated rather than defaulted; every `[open]`/`[assumption]` scenario is tagged `@low-confidence` and cites its question ID |
| 7 | Traceability | 2 | Every scenario has a stable `@QAIA-US-005-NNN` ID, an `@ACn` tag, and a `# condition: ACn-Cm` comment; matrix is consistent with the `.feature` files (cross-checked by hand) |
| 8 | Gherkin form | 2 | Consistent English keywords; no `Background` misuse (none used, since no invariant held across every scenario in any file once edge cases were included); vocabulary consistent across files |

**Total: 15/16.**

## Step 4 — Gate decision

Checklist total 15 ≥ 14, no dimension < 1 → **PASS** on the 8-dimension checklist. The
structural pass (step 2) shows no forced STOP on any file. **Combined gate: PASS.**

Three highest-impact fixes for a human reviewer to prioritize (none blocking):
1. Arbitrate the 7 open money-policy questions (Q1, Q5, Q6, Q7, Q8, Q9, and Q3's
   permissibility gap) — these cap dimension 5 at 1 and drive all 14 `@low-confidence`
   scenarios.
2. Decide Q3 (repayment un-reversal) and Q7 (fee reversibility) explicitly — currently no
   scenario exists for either because no safe default was available; a decision either way
   should add exactly one scenario per question.
3. File the stale-`TECHNIQUE_TAGS` finding against `eval/tools/structural_score.py` (add
   `domain-analysis`, `crud`, `metamorphic`, `ai-feature` to match D95's palette).

This book is QAIA-managed; regeneration mode could apply human answers to the above via
`testbook-generate`, offered but not applied here (audit only).
