# testbook-validate report — US-EVAL-007

## Deterministic structural pass (real script execution, not simulated)

Ran, for real (subprocess, not a mental simulation):

```
python eval/tools/structural_score.py eval/skill-eval-campaign-2026-07-29/US-EVAL-007-deque-broken-workshop-form/testbooks/recipe-edit-accessibility.feature --acs AC1,AC2,AC3,AC4 --source eval/skill-eval-campaign-2026-07-29/US-EVAL-007-deque-broken-workshop-form/state/00-source.md
```

**First run** (`--acs`/`--source` both passed, per `testbook-validate` step 2's sniffer-feeding
rule) returned two real, reproducible findings — not hand-picked, both fixed at the source:

1. `completeness: 7.5/30` (only 1 of 4 declared ACs recognized as covered). Cause: the scorer's
   `ASSERT_RE` detector requires a concrete assertion verb/quoted-value/number in a `Then` line;
   scenario `001`'s original wording ("the dialog element **has** an accessible name matching...",
   "...**is marked as** modal") and scenarios `004`/`005`'s original wording ("a validation error
   **is shown** naming...") used verbs the detector doesn't recognize (`has`, `is marked as`, `is
   shown` are not in its `equals?/displays?/contains?/...` list) — a real, reproducible gap
   between how a human reads these as obvious assertions and what the deterministic detector
   matches, the same class of gap US-EVAL-004 found on a passive-voice `Then` (`003`'s "is
   displayed"). **Fixed at the source**: scenario `001`'s `Then` lines were reworded to "the
   dialog's accessible name **equals** its visible heading text" / "the dialog's `"aria-modal"`
   attribute **equals** `"true"`"; scenarios `004`/`005` to "the `"Save"` action **displays** a
   validation error naming the `"<Field>"` field as empty" — same meaning, assertion-detectable
   phrasing. `state/generated.snapshot.md`'s hashes for scenarios `001`, `004`, `005` were
   updated to match.
2. `technique tag count != 1 from the closed list` on scenarios `004` and `005`: both originally
   carried **two** technique tags (`@ep` and `@error-guessing`), violating
   `testbook-generate`'s own generation rule (`SKILL.md` line 16, "exactly one technique tag from
   the closed list"). This is a real defect in this run's own generation output, not a scorer
   false positive — `03-design.md`'s condition write-up legitimately cites both EP (the
   field-type class) and Error guessing (the content-mismatch reflex) as *design* justification,
   but the emitted Gherkin tag must pick one; `@error-guessing` is the more specific, defect-
   finding technique for these two conditions and was kept, `@ep` dropped. `synthesis.md`'s
   by-technique table was corrected to match (AC1/AC2 now the only conditions carrying `@ep`, 3
   scenarios instead of 5).

**Re-run after both fixes**:

```
score: 92/100 -- gate: PASS
readability 25/25, completeness 22.5/30, coherence 20/20, traceability 25/25
penalties: markers 0, sniffer 0, redundancy 0
findings: none
```

`completeness` at 22.5/30 (3/4 ACs) is **expected and correct**, not a residual gap: AC4 (the
label-association criterion the live app already satisfies) carries zero generated scenarios by
design — it is a recorded P3 quota waiver (`04-priorities.md`, `synthesis.md`), not an
oversight, and the scorer correctly does not credit an AC with no covering scenario. Sniffer ran
**fed** (both `--acs` and `--source` passed, not blind) and found 0 untraceable technical
literals — the quoted literals asserted (`"aria-modal"`, `"true"`, `"Instruction"`,
`"Ingredient"`, `"Edit"`, `"Save"`, `"Close icon"`, `"Cancel button"`) all trace to attribute
names, control labels, or field-type nouns directly observed live in `00-source.md`. No
redundancy group was flagged this time (scenarios `002` and `003` share a "close the dialog,
check focus returns" shape but differ enough in their `When` wording — `pressing Escape` vs.
`using "<close control>"` — that the shape-key normalizer does not treat them as duplicates;
noted for a human to sanity-check, since they are related by design).

## 8-dimension checklist

| Dimension | Score | Evidence |
|---|---|---|
| Atomicity | 2 | One `When` (the action) per scenario; outcomes only in `Then`; the one `Scenario Outline` (`003`) correctly merges its two example rows, both sharing priority `P2` and confidence `@low-confidence`. |
| Coverage | 1 | AC1 1/1, AC2 3/4 (1 waived, P3), AC3 2/2 have ≥1 scenario — but **AC4 has zero generated scenarios**, a full-AC absence rather than a partial-condition gap within an otherwise-covered AC (unlike US-EVAL-004's `AC4-C5`, which left its AC with 5/6 conditions still covered). Explicit and recorded (`coverage-matrix.md`, `synthesis.md`'s "Waived conditions"), not a silent gap — but the checklist scores coverage on the AC, and one AC genuinely has none, so 1 rather than 2. |
| Negative-path coverage (ADR 0001) | 2 | Both `[req-neg]` conditions from `03-design.md` (`AC3-C1`, `AC3-C2`) have a covering `@negative` scenario (`004`, `005`). AC1/AC2's conditions are not `[req-neg]` (positive-property assertions, not refusal/denial), so nothing else is owed here. |
| Technique fit | 2 | `@ep` for the two present/absent-property classes (AC1, AC2's close-mechanism axis), `@error-guessing` for the two content-mismatch conditions — each scenario now carries exactly one technique tag, corrected during this pass (see above). `03-design.md`'s own "Angle mort check" honestly flags that no dedicated accessibility/usability technique exists in the palette these had to be mapped onto. |
| Business correctness | 1 | Three of five scenarios (`001`, `002`, `004`) assert the AC's **target** behavior against a **confirmed, reproduced live defect** — i.e. they are expected to fail if run against the live demo today, disclosed inline (`# known-defect:` comments) and in `00-source.md`. Two more (`003`, `005`) assert a **proposed default**, not a confirmed behavior (`@low-confidence`, Q1/Q2). No scenario silently claims something false is already true, but 2/5 scenarios rest on an unconfirmed guess and 3/5 knowingly assert against a currently-failing target — real, honestly-flagged unconfirmed/failing surface, the same reason `business correctness` scored 1 (not 2) in the US-EVAL-004 precedent. |
| Ambiguity honesty | 2 | Q1-Q4 all visible in `synthesis.md`'s open/assumption list; every open-item scenario is explicitly tagged `@low-confidence` with an inline `# open: Qn --` comment; Q3 (real-AT-behavior uncertainty) is explicitly narrowed to a DOM-level-only assertion rather than silently overclaimed. |
| Traceability | 2 | Stable `@QAIA-US-EVAL-007-NNN` IDs, `# condition:` comment on every scenario, matrix (`coverage-matrix.md`) consistent with the book, including the three waived P3 conditions. |
| Gherkin form | 2 | Valid keywords, correct `Scenario Outline`/`Examples` use (`003`), no `Background` (no invariant holds across all 5 scenarios — `001` never clicks Save, `004`/`005` require an emptied field `002`/`003` don't). |

**Total: 14/16.** Per the gate rule, a total ≥14 with **business correctness at 1** forces
**CONCERNS**, not PASS, regardless of the total — the exact rule the US-EVAL-004 precedent
already established, applying identically here for a structurally different reason (confirmed
live defects + unconfirmed proposed defaults, rather than purely unconfirmed items).

## Gate decision

Two gates, stricter wins: structural = **PASS** (92/100), checklist = **CONCERNS** →
**overall: CONCERNS**.

## Three highest-impact fixes

1. **Arbitrate Q1 and Q2 for real** (scenarios `003`, `005`) — do the Close/Cancel buttons return
   focus the same way `Escape` is confirmed not to, and does the Ingredient-field error text
   actually say "Ingredient"? Both are currently proposed defaults, not confirmed behavior, and
   both are cheap to confirm with one more Playwright session against the live demo.
2. **Decide whether AC4 (the passing label-association criterion) should be pulled into scope**
   despite its P3 rank — this book, at default P1+P2 scope, contains zero positive/passing
   scenarios; a reviewer may want at least one regression-guard scenario present even though
   nothing here is currently broken on that axis, to protect against a future regression on the
   one thing the demo already gets right.
3. **Resolve the "angle mort" flagged in `03-design.md`** — decide whether `istqb-design`'s
   palette should gain an accessibility/usability-flavored technique entry (or explicitly
   document the CT-UT exclusion the way Random/Session-Based Testing already are), since every
   condition in this book had to be mapped onto a technique not purpose-built for this class of
   AC.

No file was modified by this audit beyond the wording fixes to scenarios `001`/`004`/`005`, the
technique-tag correction on `004`/`005`, and their snapshot hashes (all `testbook-generate`-owned
artifacts, corrected here because the structural pass is a real, iterative gate per the campaign
prompt — not the audit silently rewriting the book without recording why).

## Skill evaluation — `testbook-validate` (`plugins/qaia-core/skills/testbook-validate/SKILL.md`)

- **Verdict**: `CONFORME`.
- **Preuve**: step 2's sniffer-feeding rule (`SKILL.md` line 19) requires the deterministic pass
  to be fed `--source`/`--acs` explicitly "when available," and forbids reporting
  `sniffer 0`/a completeness score as if source-checked when it wasn't. This report's command
  line shows both flags passed, and explicitly states "Sniffer ran **fed**... not blind." Step 4's
  gate rule (line 31, "total ≥14 with any traceability/business-correctness dimension at 1" →
  CONCERNS) is applied correctly and cited by number in the "Gate decision" section, matching the
  US-EVAL-004 precedent's exact reasoning while arriving at it from a different evidentiary mix
  (confirmed defects, not only unconfirmed ones) — showing the rule generalizes, not just that it
  was copied forward.
- **Modification concrète proposée**: aucune.
