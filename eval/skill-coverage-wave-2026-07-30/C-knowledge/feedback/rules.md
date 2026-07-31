---
stepsCompleted: [collect, classify, store-examples, propose-promotions, prune, close-the-loop]
lastStep: close-the-loop
lastSaved: 2026-07-30
nextRuleId: BR-KB-001
---

# Feedback rules — US-EVAL-009 (OctoPerf Pet Store cart)

**Zero rules promoted this run.** This file exists to carry the counter and to record *why*
nothing was promoted, not to display an empty result as a success.

## Step 4 — proposed promotions: NONE

`feedback/SKILL.md` step 4: promotion requires "the same pattern appears in **≥ 2** stored
examples, or the user explicitly asks for immediate promotion".

- Stored examples this run: 2 (`examples/US-EVAL-009-001.md`, `examples/US-EVAL-009-002.md`).
- Recurring pattern across them: **none** — one is about unconfirmed `[open]` defaults asserted
  at P1, the other about a fixture literal untraceable to the file passed as `--source`. Two
  different patterns, one instance each. Threshold not met.
- Immediate-promotion request: **none** — no human is present in this run (see
  `collect-blocker.md`), and the skill's shortcut requires the *user* to ask. An agent asking
  itself would be a simulated validation, which this run is forbidden to perform.

Both examples additionally carry machine-audit provenance rather than a human tester correction,
so even a recurrence between them would not have been promotable without a human first accepting
them as corrections. ⚠ VALIDATION: **pending-validation**.

## Step 5 — prune

Nothing to mark `promoted` (no promotion). No example in this store is older than ~6 months
(store created 2026-07-30), so the archive offer does not apply. Counter untouched:
`nextRuleId: BR-KB-001`.

## Step 6 — close the loop

No promoted rule will affect any future generation from this run: the honest statement is that
**this run changed nothing about future test books**. Per the skill's own step 6, the effect of
promoted rules is *measured, not guaranteed*, via the gold set (T13/Q41) — there is nothing to
measure here.

## Counter-collision note (real, not hypothetical)

This file starts its counter at `BR-KB-001`, and `eval/baselines/feedback-token-pilot/US-004/
feedback/rules.md` also starts at `BR-KB-001` (`nextRuleId: BR-KB-003` after two promotions).
Separately, the `rag-build` output of this same wave
(`../knowledge/business-rules.md`) allocated `BR-KB-001`..`BR-KB-006` on its own authority,
because `rag-build/SKILL.md` never mentions the `BR-KB-nnn` scheme or where its counter lives —
only `feedback/SKILL.md` step 4 does ("counter persisted in `rules.md` frontmatter"), and
`rules.md` lives under `feedback/`, which a knowledge-only project does not have. Two independent
`BR-KB-001`s now exist in this wave's output directory. Documented, not fixed.
