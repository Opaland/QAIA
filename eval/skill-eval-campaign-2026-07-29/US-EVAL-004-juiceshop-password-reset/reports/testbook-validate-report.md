# testbook-validate report — US-EVAL-004

## Deterministic structural pass (real script execution, not simulated)

Ran, for real (subprocess, not a mental simulation):

```
python eval/tools/structural_score.py eval/skill-eval-campaign-2026-07-29/US-EVAL-004-juiceshop-password-reset/testbooks/password-reset.feature --acs AC1,AC2,AC3,AC4 --source eval/skill-eval-campaign-2026-07-29/US-EVAL-004-juiceshop-password-reset/state/00-source.md
```

**First run** (`--acs`/`--source` both passed, per `testbook-validate` step 2's sniffer-feeding
rule) returned `completeness: 22.5/30` — one of the four declared ACs (AC2) had **no scenario
whose `Then` the scorer recognized as a concrete assertion**: scenario `003`'s original wording,
"a confirmation **is displayed**" (passive), does not match the scorer's `displays?` assertion
pattern (which only matches the active "display"/"displays", not "is displayed" — a real,
reproducible gap between how a human reads that sentence as an obvious assertion and what the
deterministic detector recognizes). This is a genuine finding from actually running the tool, not
a hand-picked example: **fixed at the source** — the scenario was reworded to "the system
**displays** a confirmation" (same meaning, assertion-detectable phrasing) and `state/
generated.snapshot.md`'s hash for scenario `003` was updated to match — then **re-run**:

```
score: 94/100 -- gate: PASS
readability 25/25, completeness 30/30, coherence 20/20, traceability 25/25
penalties: markers 0, sniffer 0, redundancy 6
finding: pesticide paradox -- 1 near-duplicate group (same Given/When shape): scenarios 006/007
```

The redundancy finding is expected and not a defect: scenarios `006` (accepted-boundary Outline)
and `007` (rejected-boundary Outline) intentionally share the identical `Given`/`When` shape (the
same "submit a new password of `<length>` characters" action) with a different `Then` per boundary
side — exactly the case `structural_score.py`'s own documentation says is "reported for human
judgment, not auto-failed." Flagged for a human to confirm, not silently dismissed.

Sniffer ran **fed** (both `--acs` and `--source` passed, not blind) and found 0 untraceable
technical literals — the one quoted literal string asserted (`"Password must be 5-40 characters
long."`) was directly observed live (`00-source.md`) and traces to the source file passed to the
sniffer.

## 8-dimension checklist

| Dimension | Score | Evidence |
|---|---|---|
| Atomicity | 2 | One `When` (the submission action) per scenario; outcomes only in `Then`; both Outlines (`006`, `007`) correctly merge example rows sharing priority (`P2`) and confidence (`full`). |
| Coverage | 2 | AC1 2/2, AC2 1/1, AC3 2/2, AC4 5/6 (1 waived, P3, `AC4-C5`, per `04-priorities.md`'s quota trade-off) — all 4 ACs have ≥1 scenario. |
| Negative-path coverage (ADR 0001) | 2 | Every `[req-neg]` condition in `03-design.md` (`AC3-C1`, `AC3-C2`, `AC4-C1`, `AC4-C4`, `AC4-C6`) has a covering `@negative` scenario, except `AC4-C5` which carries an explicit, recorded waiver (`synthesis.md`) rather than a silent gap — satisfies the "covered or explicit waiver" rule. |
| Technique fit | 2 | `@ep` for the account-registered class, `@decision-table` for the three-condition cross, `@boundary` for the 5/40-char threshold, `@error-guessing` for the two security-reflex conditions (rate-limiting facet, UI-bypass facet) not derivable from plain partitioning. |
| Business correctness | 1 | Three of eight scenario blocks (`002`/Q1, `005`/Q3, `008`/Q4) assert a **proposed default**, not a confirmed behavior — the live API never returned a non-503 response this session (`00-source.md`), so the account-existence-disclosure, rate-limiting, and backend-re-validation facts are unconfirmed. Flagged honestly (`@low-confidence`, "(proposed default, unconfirmed)" in the scenario titles), but that is real unconfirmed surface, not full-confidence business correctness. |
| Ambiguity honesty | 2 | Q1-Q4 all visible in `synthesis.md`'s open/assumption list, none silently resolved — every open-item scenario is explicitly titled "(proposed default, unconfirmed)". |
| Traceability | 2 | Stable `@QAIA-US-EVAL-004-NNN` IDs, `# condition:` comment on every scenario, matrix consistent with the book. |
| Gherkin form | 2 | Valid keywords, correct `Scenario Outline`/`Examples` use, no `Background` needed (no invariant holds across all 8 scenarios — `008` bypasses the UI entirely, so a UI-page `Given` would be false for it). |

**Total: 15/16.** Per the gate rule, a total ≥14 with **business correctness at 1** forces
**CONCERNS**, not PASS, regardless of the total.

## Gate decision

Two gates, stricter wins: structural = **PASS** (94/100), checklist = **CONCERNS** →
**overall: CONCERNS**.

## Three highest-impact fixes

1. **Arbitrate Q1 for real** (`AC1-C2`, scenario `002`) — this is the highest-security-relevance
   item in the book (does the recovery flow leak account existence?) and currently rests on an
   unconfirmed proposed default. This is exactly the item the campaign prompt's human Go/No-Go
   gate exists to catch, on a target whose whole point is this class of question.
2. **Re-observe the live demo when its backend is stable** to confirm Q1/Q3/Q4 directly (the
   `/rest/user/security-question` endpoint returned 503 on every attempt this session) rather than
   leaving three of eight scenarios on proposed defaults.
3. **Human-eyeball the `006`/`007` redundancy pair** — confirm the shared Given/When shape between
   the accepted- and rejected-boundary Outlines is the intended atomic split, not a case that
   should be merged into one Outline with an extra column.

No file was modified by this audit beyond the wording fix to scenario `003` and its snapshot hash
(both are `testbook-generate`-owned artifacts, corrected here because the structural pass is a
real, iterative gate per the campaign prompt — not the audit silently rewriting the book without
recording why).

## Skill evaluation — `testbook-validate` (`plugins/qaia-core/skills/testbook-validate/SKILL.md`)

- **Verdict**: `CONFORME`.
- **Preuve**: step 2's sniffer-feeding rule (`SKILL.md` line 19, added after the US-EVAL-001 run)
  requires the deterministic pass to be fed `--source`/`--acs` explicitly "when available," and
  says the report must say so "never report `sniffer 0`/a completeness score as if they were
  source-checked" if it wasn't. This report's command line above shows both flags passed, and
  explicitly states "Sniffer ran **fed**... not blind" rather than leaving that implicit — the gap
  that footnote closes did not recur here.
- **Modification concrète proposée**: aucune.
