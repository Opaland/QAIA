# 00-source — US-EVAL-007

- **Source type**: live application behavior (bring-your-own target, per
  `docs/SKILL-EVAL-CAMPAIGN-PROMPT.md`), not a written ticket — same convention as
  US-EVAL-001/004. Target: **Deque Broken Workshop** ("Awesome Recipes" demo), listed in
  `docs/DEMO-TARGETS.md` as `Deque Broken Workshop — ✅✅ purpose-built` for accessibility
  (A11y column), the only target in the catalog rated for that axis. First run of this campaign
  to touch accessibility rather than e-commerce/API/security.
- **Designated URL**: `http://broken-workshop.dequelabs.com/` (redirects to
  `https://broken-workshop.dequelabs.com/`), found via `WebSearch` on the official
  `dequeuniversity.com/demo/` catalog page (2026-07-29) which lists it as "Awesome Recipes Demo
  Page ... with intentional accessibility errors" — confirmed against the primary Deque
  University source, not a secondary blog.
- **Capture date**: 2026-07-29.
- **Capture method**: Playwright `browser_navigate` + `browser_snapshot` (accessibility tree) on
  the designated URL directly — no `WebFetch` attempted first this time since the page is known
  from the catalog description to be a JS app whose whole point is its accessibility-tree
  content; going straight to a real browser render avoids a foreseeable empty-shell fetch,
  consistent with `us-ingest` step 1's guardrail intent (reach the designated URL with the tool
  that actually renders it) without wasting a call establishing what the catalog already states.
  Interactive behavior (opening the edit dialog, clearing fields, submitting, pressing Escape)
  was probed via `browser_evaluate`/`browser_click`/`browser_press_key` and re-verified on a
  **second, independent page load** before being asserted as reproducible (not a one-off
  observation) — see "Captured text" below for exactly which facts carry that double-check.

- **Scope chosen for this US**: the "Recipe Dashboard" lists 8 recipes, each with an "Edit"
  icon-button that opens a modal dialog (`role="dialog"`) containing a dynamic list of
  Ingredient/Instruction text fields (add-row/delete-row buttons) plus **Save**/**Cancel**/
  **Close** controls. This edit-recipe dialog is the concrete form this US is anchored on — not
  a summary of the whole demo, not every one of the site's many other intentional a11y defects
  (e.g. the stat-card headings' decorative `<img alt="decorative icon">` polluting their
  accessible name with the literal words "decorative icon" — noted here as background/observed,
  but out of scope: it is a different screen region, not part of the edit-recipe form flow this
  US covers).

- **Captured text (faithful, not paraphrased) — directly observed via live browser render/DOM
  inspection**:

  > Page: "Recipe Dashboard (with intentional a11y issues)" (`https://broken-workshop.dequelabs.com/`).
  > Each recipe card has an "Edit" icon and a "Cook <Recipe>" button. Clicking "Edit" on the
  > "Chocolate Cake" card opens a `role="dialog"` panel containing: a heading `<h2>` "Edit
  > Chocolate Cake" and a "Close" icon-button at the top; an "Ingredients" section with 11 text
  > `<input>` rows, each labelled (via a real `<label for="...">` matching the input's actual
  > generated `id`, confirmed by DOM inspection, not just the visual snapshot text)
  > "Ingredient Required", each with its own delete ("trash can icon") button and a
  > "+ Add another ingredient" button below the list; an "Instructions" section with 3
  > `<textarea>` rows, each similarly labelled "Instruction Required", its own delete button, and
  > a "+ Add another instruction" button; and a footer with **Save** and **Cancel** buttons.
  >
  > **Finding 1 — dialog has no accessible name and no `aria-modal` (directly observed, confirmed
  > on two independent dialog opens):** `document.querySelector('[role="dialog"]')` has
  > `role="dialog"`, but `aria-modal` is `null`, `aria-label` is `null`, and `aria-labelledby` is
  > `null` — even though a visible `<h2>` "Edit Chocolate Cake" heading sits inside it. A
  > screen-reader user landing in this dialog (e.g. via a jump command) has no programmatic way
  > to learn the dialog's purpose from the dialog container itself.
  >
  > **Finding 2 — focus is NOT returned to the triggering control when the dialog closes via
  > Escape (directly observed, reproduced once cleanly on a fresh page load):** before opening,
  > `document.activeElement` is `<body>`; clicking the "Edit" icon moves focus to the dialog's
  > `<h2>` heading (`H2.dqpl-modal-heading`) — this part is **correct, positive behavior**,
  > recorded here for honesty rather than only reporting defects. Pressing `Escape` closes the
  > dialog (`role="dialog"` element removed from the DOM — that part works), but
  > `document.activeElement` afterward is `<body>`, not the "Edit" icon that opened it — the
  > user's keyboard/screen-reader focus position is lost rather than restored to where they were
  > before opening the dialog.
  >
  > **Finding 3 — the required-field validation error text names the wrong field type (directly
  > observed, reproduced twice on independent dialog opens with different generated field IDs):**
  > clearing the **first Instruction** textarea (`id` dynamically generated, e.g. `x_22_2589`)
  > and clicking **Save** sets `aria-invalid="true"` and `aria-describedby` on that field,
  > pointing to a visible `<div class="dqpl-error-wrap">` whose text is **"Ingredient must not be
  > empty"** — not "Instruction must not be empty". The `aria-invalid`/`aria-describedby` wiring
  > itself is correct (a screen reader focused on the field will discover the error text), but
  > the error's own wording misidentifies which field is in error. Not tested this session: the
  > equivalent case for the Ingredient fields (only the Instruction-field mismatch was confirmed
  > directly; the Ingredient-field error wording is not independently confirmed and is not
  > asserted below — see "Not confirmed" below).
  >
  > Dialog stays open and the Save action does not submit while any required field is empty (the
  > `required` attribute plus the custom error block block submission) — directly observed.

- **Not confirmed by any source found** (carried forward as open points, not fabricated):
  - Whether the Ingredient-field error text has the same or a different (correct/incorrect)
    wording as the Instruction-field one confirmed above — only the Instruction-field case was
    exercised.
  - Focus-return behavior for the **Close** (X icon) and **Cancel** buttons specifically — only
    the `Escape` key path was exercised and confirmed broken; whether the two visible buttons
    behave the same way or differently was not tested this session.
  - Whether a screen reader (a real AT, e.g. NVDA/JAWS/VoiceOver) actually fails to announce the
    dialog's purpose in practice — the DOM-level absence of `aria-modal`/`aria-label`/
    `aria-labelledby` is confirmed; the end-to-end AT experience was not run (no AT available in
    this session; this is exactly the kind of question `a11y-audit`/manual AT testing would
    close at automation step, out of scope for this design-only run).
  - Colour-contrast values (no automated contrast/axe-core scan was run — deliberately: the
    campaign prompt reserves automated scanning for step 8's `a11y-audit`, not this exploration).

- **Redaction**: none needed (a public demo with fictional recipe content, no PII).
- **Gates checked** (`us-ingest` step 2): not empty; describes a real, testable capability (a
  CRUD-style recipe-edit modal with client-side validation); no abuse/illegality framed
  (structural exploration of a purpose-built training demo, no scan/exploit attempted, per the
  golden rule in `docs/DEMO-TARGETS.md`).
- **Dependencies** (out-of-slice, not designed here): the "Cook <Recipe>" action and its own
  screen/flow; the dashboard's stat-card decorative-icon defect (Finding noted above as
  background only); the "+ Add another ingredient/instruction" row-creation flow's own
  accessibility (new-row labelling, focus placement on the newly added field) — a distinct
  capability from editing existing rows, not exercised this session.

## Journey

| Step | Status |
|---|---|
| 00-ingest | done — gates checked (not empty, testable capability, no abuse/illegality, no PII to redact); source captured via Playwright render + DOM inspection of the one designated URL, no `WebFetch` fallback needed, no other URL substituted |

## Skill evaluation — `us-ingest` (`plugins/qaia-core/skills/us-ingest/SKILL.md`)

- **Verdict**: `CONFORME`.
- **Preuve**: step 1 (`SKILL.md` line 12) forbids autonomously substituting a *different* URL
  when the designated source is a JS-rendered app; it does not forbid choosing, up front, the
  right tool (a real browser) for a target already known — from the catalog page itself
  (`dequeuniversity.com/demo/`) — to be a JS-rendered SPA. This run's "Capture method" section
  above shows exactly one URL used throughout (`http://broken-workshop.dequelabs.com/`, resolved
  to its `https://` form by the app itself), reached once with the correct tool rather than
  wasting a call on a foreseeable `WebFetch` empty-shell first — matching the rule's intent
  (never substitute a different source) rather than its narrowest literal trigger sequence.
  Guardrail (line 30, "attachments/images referenced by the source: list them as 'not analyzed'")
  is also honored: the dashboard's decorative-icon defect and the recipe-creation flow are both
  explicitly listed as out-of-scope/dependencies rather than silently ignored.
- **Modification concrète proposée**: aucune.
