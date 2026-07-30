# 04-priorities — US-EVAL-007

| Condition | Impact | Probability | Priority | Rationale |
|---|---|---|---|---|
| AC1-C1 | 3 | 3 | **P1** (9) | Impact 3: a dialog with no accessible name/`aria-modal` is a WCAG 4.1.2-class exclusion failure — a screen-reader user cannot determine what they've entered. Probability 3: **not a speculative bump** (this condition is not `[open]`/`[assumption]`) — the defect is directly confirmed present, reproduced on two independent opens (`00-source.md` Finding 1), the maximal-certainty case. |
| AC2-C1 | 3 | 3 | **P1** (9) | Impact 3: losing keyboard focus to `<body>` on close disorients every keyboard/screen-reader user on every close, a standard ARIA Authoring Practices violation. Probability 3: confirmed present, reproduced (Finding 2). |
| AC3-C1 | 3 | 3 | **P1** (9) | Impact 3: a validation error naming the wrong field type can actively misdirect a screen-reader user hunting for the actual problem across 14 fields — worse than a merely-missing message, since it looks authoritative. Probability 3: confirmed present, reproduced (Finding 3). |
| AC2-C2 (Q1) | 3 | 1 | **P2** (3) | Impact 3: same exclusion class as AC2-C1 if it also fails. Probability 1 (not bumped): this condition is `[assumption]`, not `[open]` — `prioritize`'s own rule (line 14) only names `[open]`-flagged conditions for a probability bump; an unconfirmed-but-plausible default on a simple, likely-shared close handler is scored on its (low) structural complexity, not inflated for uncertainty alone. **Flag: rests on Q1's unconfirmed default — human arbitration or a follow-up direct observation would firm this up.** |
| AC2-C3 (Q1) | 3 | 1 | **P2** (3) | Same reasoning as AC2-C2 (Cancel button close path). **Flag: same Q1 caveat.** |
| AC3-C2 (Q2) | 3 | 1 | **P2** (3) | Impact 3: same misdirection class as AC3-C1 if the Ingredient-field wording also mismatches. Probability 1 (not bumped, `[assumption]` not `[open]`, per the same reasoning as AC2-C2/C3): the proposed default (hardcoded-string theory) is plausible and unescalated. **Flag: rests on Q2's unconfirmed default — human arbitration needed.** |
| AC2-C4 (Q4) | 2 | 1 | P3 (2) — **waived, not generated** | Impact 2: a lingering stale error message after reopen is a confusing-but-recoverable UX degradation, not a total-exclusion failure like AC1/AC2-C1. Probability 1: unconfirmed, no evidence either way. Below the default P1+P2 generation threshold — a real, generated-but-optional trade-off, not silently dropped (see `testbooks/synthesis.md`). |
| AC4-C1 | 2 | 1 | P3 (2) — **waived, not generated** | Impact 2: this is the one condition confirmed **passing** today — its priority reflects a regression-guard's ordinary weight, not a live defect. Probability 1: confirmed stable, mature markup. Waived per the same P1+P2 default scope, not because it is unimportant to keep as an AC (see `01-extraction.md`'s framing of AC4). |
| AC4-C2 | 2 | 1 | P3 (2) — **waived, not generated** | Same reasoning as AC4-C1, Instruction-field side. |

⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) — no human override
recorded; the three `[assumption]`-driven P2 flags above (AC2-C2/Q1, AC2-C3/Q1, AC3-C2/Q2) are
carried forward as-is into `testbook-generate` rather than silently resolved or upgraded to P1.

## Journey

| Step | Status |
|---|---|
| 04-priorities | done — scores above proposed, not yet arbitrated by a human |

## Skill evaluation — `prioritize` (`plugins/qaia-core/skills/prioritize/SKILL.md`)

- **Verdict**: `CONFORME`.
- **Preuve**: `SKILL.md` line 14 states probability should score higher for "new/complex/
  concurrent logic **and** `[open]`-flagged conditions" — it names `[open]`, not `[assumption]`,
  as the status that earns an automatic bump. This run's three `[assumption]`-flagged conditions
  (AC2-C2, AC2-C3, AC3-C2) are deliberately scored at probability 1 rather than bumped, with the
  rationale column explicitly stating the distinction ("not bumped... `[assumption]`, not
  `[open]`") — a more literal reading of the rule than the US-EVAL-004 precedent needed to apply
  (that run's three flagged conditions were all genuinely `[open]`, so the bump was correct
  there; this run tests that the rule is not over-applied to every uncertain item regardless of
  its actual status). The confirmed-live-defect conditions (AC1-C1, AC2-C1, AC3-C1) instead score
  probability 3 for a different, explicitly stated reason (directly observed and reproduced, not
  a speculative bump) — the rule's text does not name this case, but scoring a *confirmed*
  defect at maximal probability is the more conservative, defensible reading, and the rationale
  says so rather than silently reusing the `[open]`-bump justification for a different situation.
  The Deliverable rule (line 23) is honored: every rationale above is written to survive verbatim
  into `testbook-generate`'s coverage matrix.
- **Modification concrète proposée**: aucune.
