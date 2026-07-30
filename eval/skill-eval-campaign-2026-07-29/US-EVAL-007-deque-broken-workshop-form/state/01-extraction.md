# 01-extraction — US-EVAL-007

## Story

**As a** keyboard-only or screen-reader user managing my recipes on the Awesome Recipes
dashboard,
**I want** the "Edit Recipe" dialog to expose its purpose and state to assistive technology,
keep my keyboard focus predictable when I open and close it, and tell me accurately which field
I left empty when validation fails,
**so that** I can edit and save a recipe's ingredients and instructions without losing my place
in the page or being told the wrong thing is wrong.

*(Not phrased as a story anywhere in the source — a live-app capture, not a written ticket.
`[reconstructed]` from the captured dialog behavior and DOM structure, per `us-review` step 1's
explicit license for a real-capability capture with no story phrasing — same pattern
US-EVAL-001/004 used.)*

## Acceptance criteria (numbered, stable — AC1..AC4)

- **AC1.** When the "Edit `<Recipe>`" dialog is open, the dialog element exposes an accessible
  name (via `aria-label` or `aria-labelledby`, pointing at or matching its visible `<h2>`
  heading) and is marked `aria-modal="true"`. *(Directly observed to currently fail: `role`
  is set but `aria-modal`/`aria-label`/`aria-labelledby` are all `null` — see `00-source.md`
  Finding 1.)*
- **AC2.** Closing the dialog returns keyboard focus to the "Edit" control that opened it.
  *(Directly observed for the `Escape` path to currently fail: focus lands on `<body>`, not the
  triggering "Edit" icon — see `00-source.md` Finding 2. The `Close`/`Cancel` button paths are
  not confirmed either way — open point.)*
- **AC3.** Leaving a required Ingredient or Instruction field empty and clicking **Save** shows a
  validation error message that correctly names the field type that is actually empty
  (Ingredient vs. Instruction). *(Directly observed for the Instruction-field case to currently
  fail: the shown text is "Ingredient must not be empty" for an emptied Instruction field — see
  `00-source.md` Finding 3. The Ingredient-field case is not independently confirmed — open
  point.)*
- **AC4.** Each Ingredient and Instruction field's visible label is programmatically associated
  with its own input (a real `<label for="...">` matching the input's actual `id`), so its
  accessible name matches what is visibly labelled. *(Directly observed to currently **pass** —
  the only one of these four ACs the live demo already satisfies, per `00-source.md`'s "Captured
  text" paragraph on labelling — kept in scope as an acceptance criterion in its own right, not
  only as a defect list, so the book is not 100 % negative-path by construction.)*

## Business rules / constraints found outside the AC list

- The **Save** action is blocked (dialog stays open, no submission) while any required field is
  empty — directly observed, applies uniformly to all 11 Ingredient and 3 Instruction fields of
  the Chocolate Cake recipe examined. Not itself an accessibility property (it is functional
  validation), but it is the precondition every AC1-AC4 scenario below opens the dialog under.
- The dialog's `Escape`-to-close and focus-move-to-heading-on-open behaviors are correct/working
  — recorded as constraints the AC2 scenarios must not contradict (only the focus-*return*
  half is asserted as broken).

## Referenced artifacts not analyzed

- None (no attachments/mockups; the source is the live rendered dialog itself).

## Present but not classifiable

- The dashboard's stat-card headings (`heading "decorative icon 9 Eggs used"`) carry a decorative
  `<img alt="decorative icon">` whose alt text pollutes the heading's accessible name — a real,
  directly-observed defect, but on a different screen region (the dashboard summary cards, not
  the edit-recipe dialog this US scopes) — listed here as present-but-out-of-slice, not silently
  dropped, not turned into an AC.

## What was NOT found

- No formal AC numbering in the source (none existed — a live-app capture): the numbering above
  is this skill's own reconstruction.
- No confirmed behavior for: the Ingredient-field validation-error wording (only Instruction was
  tested), and the `Close`/`Cancel` button focus-return paths (only `Escape` was tested). Both
  carried to `need-understanding` as open points, not invented here.

## Journey

| Step | Status |
|---|---|
| 00-ingest | done |
| 01-review | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run, no human reviewer at this micro-step; only the pre-automation gate is a hard human stop per the campaign prompt) |

## Skill evaluation — `us-review` (`plugins/qaia-core/skills/us-review/SKILL.md`)

- **Verdict**: `CONFORME`.
- **Preuve**: step 1 (`SKILL.md` line 13) requires, for a source with no story phrasing but a
  real capability described, that the story be "reconstruct[ed] and mark[ed] `[reconstructed]`."
  The Story section above does exactly that. Step 2's "diff mentality" (line 18, "explicitly
  list what you did NOT find") is honored by the "What was NOT found" and "Present but not
  classifiable" sections, and — new relative to the US-EVAL-004 precedent — this run's AC4 is a
  case where the extraction records a criterion the live app **already satisfies** rather than
  only defects; nothing in step 1's ordering (story → numbered AC → business rules → referenced
  artifacts → not-classifiable) required that distinction to be flagged specially, and it wasn't
  — treated as an ordinary AC, which is the correct reading of the rule.
- **Modification concrète proposée**: aucune.
