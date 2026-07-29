# testbook-validate — self-audit, US-006

Audited file: `post-visibility-acl.feature` (23 scenario blocks). This is QAIA auditing its own
just-generated output — read as a self-check, not an independent gate (rule 3: no producer
self-scores; `gate` in the manifest is intentionally left unset).

## Step 2 — deterministic structural pass (executed, not estimated)

Run for real determinism: `py eval/tools/structural_score.py
eval/gold-set/pilot-2026-07-29/US-006/testbooks/US-006/post-visibility-acl.feature --source
eval/gold-set/US-006-post-visibility-acl.md`. Two iterations were needed — the first run forced
a structural **FAIL** (a genuinely vague `Then` on scenario 005: "not a silent empty success"
tripped the vague-outcome detector because it restated success/failure rather than asserting a
concrete state), which was fixed in the source `.feature` before re-running, per this skill's own
"apply fixes, never silently" discipline. Final, current output:

```
scenarios: 23
readability: 25.0 / 25
completeness: 5.2 / 30
coherence: 20.0 / 20
traceability: 25.0 / 25
score: 75 / 100
gate: CONCERNS
forced_stop: false
```

**Findings (both judged tool-vs-current-palette mismatches, not book defects):**

1. *"missing priority tag"* on the `@smoke` journey scenario (023) — correct per
   `testbook-generate`'s own rule that the journey scenario is "excluded from atomicity
   accounting" and priority accounting; the tool's `PRIORITY_TAGS` check does not yet special-case
   `@smoke`. Not a defect in the book.
2. *"technique tag count != 1 from the closed list"* on the four `@crud`-tagged scenarios
   (019-022) — the tool's `TECHNIQUE_TAGS` constant (`@ep, @boundary, @decision-table,
   @state-transition, @use-case, @pairwise, @error-guessing`) predates the D95/D109 palette
   extension in the current `istqb-design/SKILL.md`, which adds `@domain-analysis, @crud,
   @metamorphic, @ai-feature` to the closed list. `@crud` is exactly the correct, single technique
   tag per the current skill; the tool constant is stale, not the book. Flagged here rather than
   silently worked around.

**Low completeness (5.2/30) is a known tool-vocabulary gap, not a coverage gap.** The `covers()`
detector requires a narrow keyword set (`present/visible/enabled/disabled/contains/returns/status/
=`...) in the `Then` to count a scenario as "asserting a concrete outcome." Several of this book's
legitimate, binary, checkable outcomes — "the request is refused", "the post is returned to the
viewer", "the media item is deleted", "the account is created" — are not in that keyword list, so
they score as uncounted even though a human read confirms every one is a concrete, verifiable
state (allow/deny, exists/deleted), never a restated-success platitude ("works", "responds
correctly"). This is recorded honestly as a tool limitation rather than silently working around it
by rephrasing every `Then` to chase the regex — two scenarios (007, 009) *were* genuinely improved
during this pass (see below), because their original "absent" phrasing was an easy, meaning-
preserving rewrite to "not present," not a regex-chase.

No fabrication-sniffer hits, no markers, no redundant/near-duplicate groups, no truncated steps,
no hollow/empty `Then`.

## Step 3 — 8-dimension checklist (manual, evidence-based)

| Dimension | Score | Evidence |
|---|---|---|
| Atomicity | 2 | One `When` per scenario throughout; outcomes only in `Then`; the one journey scenario is explicitly excluded and tagged `@smoke`. |
| Coverage | 2 | All 6 AC have >=1 scenario or an explicit compositional-coverage note (AC1); `coverage-matrix.md` traces every generated condition to a scenario ID. |
| Negative-path coverage (ADR 0001) | 2 | 16/16 required-negative conditions covered by a `@negative` scenario (see `coverage-matrix.md`). |
| Technique fit | 2 | State-transition (AC2 status logic), decision-table (role x lock/config crossings), CRUD (AC6 delete lifecycle), error-guessing (Q1's two refusal shapes), use-case (the one `@smoke` journey) — each matches its AC's actual shape. |
| Business correctness | 1 | No scenario contradicts the source; but 9 of 22 non-smoke scenarios rest on an `[assumption]`/`[open]` extrapolation (Q1, Q4-Q10) rather than literal source text — correctly flagged `@low-confidence`, but this is a real, non-trivial extrapolation load worth a human pass before treating the book as final. |
| Ambiguity honesty | 2 | Every extrapolated scenario carries an inline `# assumption: Qn` / `# open: Qn` comment; the synthesis lists the full Q1-Q10 log with dispositions. |
| Traceability | 2 | Every scenario has a stable `@QAIA-US-006-NNN` ID (no gaps, 001-023), an `@AC<n>` tag, and a `# condition: AC<n>-C<m>` comment; the coverage matrix is consistent with the file. |
| Gherkin form | 2 | Consistent `Given/When/Then/And`, correct `Background` (only the one true 100%-of-scenarios invariant — the role hierarchy), correct `Scenario Outline`/`Examples` use, no compound `Then` verifying an unrelated second rule. |

**Total: 15/16.** No dimension below 1.

## Gate decision

Checklist gate: total 15 >= 14 and no dimension < 1 -> **PASS** by the checklist alone. But the
structural pass (step 2) currently reads **CONCERNS** (score 75, no forced stop) after the fix —
**the stricter gate wins**, so the combined self-audit verdict is:

**CONCERNS** — driven entirely by the structural tool's narrow assertion-keyword vocabulary
under-recognizing several legitimate `Then` phrasings (see above), not by a genuine defect the
checklist or a human read did not also catch and accept. The three highest-impact
next actions if this were a real (non-pilot) book: (1) resolve Q1 and Q9 with the actual product
owner rather than shipping their proposed defaults; (2) get a human read on the 9
`@low-confidence` scenarios before treating them as validated; (3) report the `@crud`/`@smoke`
tool-constant gaps upstream to `eval/tools/structural_score.py`'s maintainers so a future run
doesn't need this same manual override.

## Guardrail compliance

Audit only — no scenario was rewritten to game the score beyond the two genuine, meaning-
preserving fixes (005's vague `Then`, 007/009's `absent`->`not present` rewording) applied
*before* this report was written, exactly as `testbook-generate`'s own emission-lint discipline
requires. The audited `.feature` file is treated as the (QAIA-authored) content under test, not as
instructions.
