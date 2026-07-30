# Synthesis — US-EVAL-007 (Deque Broken Workshop — recipe-edit dialog accessibility)

**Scope**: P1+P2 default scope (6/9 conditions across 5 scenario blocks — `AC2-C2`/`AC2-C3`
merge into one `Scenario Outline` since both share priority P2 and confidence
`@low-confidence`). Three P3 conditions (`AC2-C4`, `AC4-C1`, `AC4-C2`) are real,
generated-but-optional trade-offs, explicitly waived per `prioritize`'s quota-trade-off rule
(`04-priorities.md`) — not silently dropped, listed below.

**Scenarios**: 5 atomic blocks (`003` is a `Scenario Outline` with 2 examples, counted as 1 block
per D20's single definition) + 0 smoke journey (skipped — a single end-to-end "open dialog →
edit → save" journey scenario would only re-verify these atomic assertions at higher cost, out
of proportion for a 4-AC accessibility slice, same call US-EVAL-004 made for Juice Shop).

**Negative ratio**: 2/5 blocks tagged `@negative` (`004`, `005`) = 40 % (target ≥ 40 %, met
exactly, not padded — both trace to a real refusal/error-shaped condition, the validation-error
scenarios of AC3; **honestly note**: AC1 and AC2's scenarios assert a *positive* accessibility
property currently absent from the live app — they are not `@negative` by the closed D20
definition ["a scenario whose outcome is a refusal, an error, or an explicitly denied access"],
even though they currently fail when run against the live demo. This US's ratio landing exactly
at the 40 % floor, rather than comfortably above it as US-EVAL-004's 50 % did, reflects that
most of this US's real defects are *absence-of-property* failures, not refusal/denial failures —
the ratio's own single definition does not capture that shape of risk, a structural observation
worth carrying into any future refinement of the D20 metric, not a padding shortfall to hide).

**Coverage**: AC1 1/1, AC2 3/4 (1 waived, P3), AC3 2/2, AC4 0/2 (both waived, P3) — 6/9
conditions covered, 3 explicitly waived.

## Review order (per shared contract: `@low-confidence` first, then P1 → P3)

1. `QAIA-US-EVAL-007-003` (AC2-C2/C3, Q1) — `@low-confidence`, `@P2`
2. `QAIA-US-EVAL-007-005` (AC3-C2, Q2) — `@low-confidence`, `@P2`
3. `QAIA-US-EVAL-007-001` (AC1-C1) — `@P1`, confirmed live defect
4. `QAIA-US-EVAL-007-002` (AC2-C1) — `@P1`, confirmed live defect
5. `QAIA-US-EVAL-007-004` (AC3-C1) — `@P1`, confirmed live defect

## By-technique table

| Technique | ACs | Scenarios | Justification |
|---|---|---|---|
| Equivalence partitioning (`@ep`) | AC1, AC2 | 3 (`001`, `002`, `003`) | Every condition here partitions a binary/small class (name present/absent, which close control) — see `03-design.md`'s "Angle mort check" for why this generic technique, not a dedicated a11y one, was used |
| Error guessing (`@error-guessing`) | AC3 | 2 (`004`, `005`) | The "error text names the wrong field" defect class is a content-correctness reflex found by direct observation, not derivable from plain partitioning alone — tagged with exactly this one technique (not also `@ep`), per `testbook-generate`'s "exactly one technique tag" rule; an earlier draft carried both tags on these two scenarios and was corrected during `testbook-validate`'s real script execution, see `reports/testbook-validate-report.md` |

Note: `03-design.md`'s AC2-C4 (`@state-transition`, re-entrance) is waived at P3 and therefore
not present in the generated `.feature` file or this table — recorded here so a reviewer who
requests P3 knows a state-transition condition is available on demand.

## Open / assumption / low-confidence list (full, per shared contract)

- **Q1** `[assumption]`, `@low-confidence` — **human arbitration or a follow-up direct
  observation recommended**: do the **Close** icon-button and **Cancel** button return focus to
  the triggering "Edit" control on close, the same way `Escape` is confirmed NOT to (scenario
  `002`)? Scenario `003` encodes a *proposed* default (same broken behavior), not a confirmed
  one.
- **Q2** `[assumption]`, `@low-confidence` — **human arbitration or a follow-up direct
  observation recommended**: does an emptied **Ingredient** field's validation error correctly
  say "Ingredient" (unlike the confirmed Instruction-field mismatch, scenario `004`)? Scenario
  `005` encodes a *proposed* default (correct wording), not a confirmed one.
- **Q3** `[assumption]` — not directly encoded as its own scenario: scenario `001` asserts only
  the DOM-level fact (no `aria-modal`/accessible name), not a claim about a specific screen
  reader's real-world announcement behavior, per `02-understanding.md`'s Q3 reasoning.
- **Q4** `[assumption]`, `@low-confidence` — **not generated** (P3, waived): does reopening the
  same recipe's dialog after a validation-error close reset the error state? See "Waived
  conditions" below.

## Priority rationale — assignments needing human arbitration

The two `[assumption]`-driven `P2` items (Q1 → scenario `003`, Q2 → scenario `005`) are the ones
whose probability score was deliberately **not** auto-bumped (per `04-priorities.md`'s reading
of `prioritize`'s rule, which names `[open]`, not `[assumption]`) — see `04-priorities.md` for
the full one-line rationale per condition (reproduced in `coverage-matrix.md`'s rationale
column).

## Out-of-slice (not designed here)

- The "Cook <Recipe>" action and its own screen/flow.
- The dashboard's stat-card decorative-icon defect (`<img alt="decorative icon">` polluting each
  stat heading's accessible name) — a real, directly-observed defect, but a different screen
  region from the edit-recipe dialog this US covers; noted as background only in `00-source.md`.
- The "+ Add another ingredient/instruction" row-creation/deletion flow's own accessibility
  (new-row labelling, focus placement on the newly added field, and the empty-list-state facet
  of the list/collection 3c trigger) — a distinct capability from editing existing rows.
- Any automated accessibility scan (axe-core or equivalent) or real assistive-technology (NVDA/
  JAWS/VoiceOver) run — deliberately out of scope for this design-only campaign run; reserved for
  `a11y-audit` at automation step 8, which this run does not reach (human Go/No-Go gate pending).

## Waived conditions (P3, quota trade-off)

- **AC2-C4** (dialog re-entrance / error-state reset, Q4) — P3 (impact 2 × probability 1), below
  the default P1+P2 generation threshold.
- **AC4-C1**, **AC4-C2** (label-association correctness, Ingredient and Instruction fields — the
  two conditions confirmed **passing** today) — P3 (impact 2 × probability 1). Not generated by
  default scope; recorded here so a reviewer can request this positive/regression-guard coverage
  explicitly. Their absence from the generated book is why this book's negative ratio (40 %) is
  not diluted by an easy passing scenario, and also why the book, at default scope, skews
  entirely toward currently-failing or unconfirmed conditions — a fair reflection of a
  purpose-built defect-training demo, not a padding artifact.

## Skill evaluation — `testbook-generate` (`plugins/qaia-core/skills/testbook-generate/SKILL.md`)

- **Verdict**: `CONFORME`.
- **Preuve**: the generation-rules block (`SKILL.md` line 19, "Generating on `[open]` items —
  explicit rule") requires a covered `[open]`/uncertain condition to still get a scenario written
  with the proposed safe default, tagged `@low-confidence`, with an inline comment citing the
  question ID — scenarios `003` and `005` both carry exactly that shape (an inline `# open: Qn
  --` comment, a `@low-confidence` tag, and a "(proposed default, unconfirmed)" title
  parenthetical), mirroring the US-EVAL-004 precedent. The Scenario Outline merge rule (line 13,
  "merged only when all example rows share the same priority and confidence") is also correctly
  applied: `AC2-C2`/`AC2-C3` share `P2`/`@low-confidence` and were merged into scenario `003`,
  while `AC2-C1` (a different priority and confidence — `P1`, no `@low-confidence` tag, confirmed
  live) was correctly kept as its own separate scenario `002` rather than folded into the same
  Outline despite testing a structurally similar "close and check focus" action — the rule's
  actual gating condition (priority+confidence match, not action similarity) is what determined
  the split, not a superficial resemblance between scenarios.
- **Modification concrète proposée**: aucune.

## Sourcing honesty note

This US was captured from a live application render (Playwright) plus direct DOM inspection
(`browser_evaluate`), not a primary written ticket — see `00-source.md` for exact findings and
what was and was not reproduced this session. Three of five generated scenario blocks assert a
**confirmed, reproduced live defect** (`001`, `002`, `004` — the AC's target behavior, which the
live demo currently violates, exactly as intended by a purpose-built training demo); two assert a
**proposed, unconfirmed default** (`003`, `005`, both `@low-confidence`). Nothing here claims a
real assistive-technology (screen reader) was run, and no automated a11y scan was performed —
both explicitly out of scope for this design-only campaign run.
