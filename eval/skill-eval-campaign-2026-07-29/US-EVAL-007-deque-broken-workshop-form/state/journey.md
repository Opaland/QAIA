# journey — US-EVAL-007 (Deque Broken Workshop — recipe-edit dialog accessibility)

| Step | Status | Note |
|---|---|---|
| 00-ingest | done | gates checked, sourced via Playwright render + DOM inspection of the designated URL, no `WebFetch` fallback needed, no other URL substituted, per `docs/DEMO-TARGETS.md`'s Deque Broken Workshop entry (first a11y-axis target this campaign has touched) |
| 01-review | done | ⚠ simulated: accepted-as-is |
| 02-understanding | done | ⚠ simulated: accepted-as-is — Q1/Q2/Q3/Q4 all `[assumption]` (none `[open]`: no protected/money/safety domain in this US's shape) |
| 03-design | done | ⚠ simulated: accepted-as-is — explicit "Angle mort check" on whether `istqb-design`'s palette covers an accessibility/usability technique (it does not; flagged for human arbitration, not forced) |
| 04-priorities | done | not yet human-arbitrated |
| 05-testbook-generate | done | 5 scenarios, P1+P2 scope (6/9 conditions; `AC2-C4`/`AC4-C1`/`AC4-C2` waived, P3), negative ratio 40% |
| 06-report | done | `reports/manifest.json` written |
| 07-testbook-validate | done | real script execution — 2 real findings fixed at the source (assertion-phrasing gap on 3 scenarios, technique-tag-count violation on 2 scenarios) — CONCERNS overall (structural 92/100 PASS, checklist 14/16 CONCERNS on coverage+business correctness) |

**⚠ ARRÊT — next step is the human Go/No-Go gate before any automation (step 8 of the campaign
prompt, including `a11y-audit` even though it is directly relevant here), per
`docs/SKILL-EVAL-CAMPAIGN-PROMPT.md`. Not simulated. Awaiting the user.**

## Skill evaluation — `report` (`plugins/qaia-core/skills/report/SKILL.md`)

- **Verdict**: `CONFORME`.
- **Preuve**: guardrail line 58 ("Counts must match the book... the artifacts win") and step 2
  ("do not estimate... every number in the manifest must equal what the artifacts contain").
  `reports/manifest.json`'s `design.scenarios.total` (5), `byPriority` (P1:3/P2:2/P3:0),
  `negative` (2) and `outlines` (1) were counted directly from
  `testbooks/recipe-edit-accessibility.feature`'s tags after `testbook-validate`'s real fixes
  (not before), and independently cross-checked against `eval/tools/structural_score.py`'s own
  `tag_audit.negative_ratio_recomputed_pct` (40.0%, matching `negativeRatio: 0.4` in the
  manifest) — the manifest's self-reported counts agree with the tool's independent recount.
  `gate` was correctly omitted entirely (contract rule: no producer ever scores itself — this
  run's `qaia-score` step was not invoked, consistent with the campaign prompt stopping before
  automation).
- **Modification concrète proposée**: aucune.
