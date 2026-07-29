# journey — US-EVAL-004 (OWASP Juice Shop — password reset via security question)

| Step | Status | Note |
|---|---|---|
| 00-ingest | done | gates checked, sourced via Playwright render of the designated URL (after a `WebFetch` 503), WebSearch used only as corroboration, per `docs/DEMO-TARGETS.md`'s Juice Shop entry |
| 01-review | done | ⚠ simulated: accepted-as-is |
| 02-understanding | done | ⚠ simulated: accepted-as-is — Q1/Q3/Q4 open, Q2 assumption |
| 03-design | done | ⚠ simulated: accepted-as-is |
| 04-priorities | done | not yet human-arbitrated |
| 05-testbook-generate | done | 8 scenarios, P1+P2 scope (10/11 conditions; `AC4-C5` waived, P3), negative ratio 50% |
| 06-report | done | `reports/manifest.json` written, validated with `eval/tools/validate_manifest.py` (PASS) |
| 07-testbook-validate | done | real script execution — CONCERNS overall (structural 94/100 PASS, checklist 15/16 CONCERNS on business correctness) |

**⚠ ARRÊT — next step is the human Go/No-Go gate before any automation (step 8 of the campaign
prompt), per `docs/SKILL-EVAL-CAMPAIGN-PROMPT.md`. Not simulated. Awaiting the user.**

## Skill evaluation — `report` (`plugins/qaia-core/skills/report/SKILL.md`)

- **Verdict**: `CONFORME`.
- **Preuve**: guardrail line 58 ("Counts must match the book... the artifacts win: stop and
  surface the discrepancy rather than writing numbers that lie") and step 2 ("do not estimate...
  every number in the manifest must equal what the artifacts contain"). `reports/manifest.json`'s
  `design.scenarios.total` (8), `byPriority` (P1:5/P2:3/P3:0), `negative` (4) and `outlines` (2)
  were counted directly from `testbooks/password-reset.feature`'s tags (not re-estimated), and
  independently cross-checked against `eval/tools/structural_score.py`'s own
  `tag_audit.negative_ratio_recomputed_pct` (50.0%, matching `negativeRatio: 0.5` in the
  manifest) — the manifest's self-reported counts agree with the tool's independent recount, which
  is exactly the cross-check this rule exists to make possible. `gate` was correctly omitted
  entirely (contract rule: "no producer ever scores itself" — this run's `qaia-score` step was not
  invoked, consistent with the campaign prompt stopping before automation).
- **Modification concrète proposée**: aucune.
