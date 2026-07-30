# 03-design — US-EVAL-007

## Angle mort check (per campaign instruction — explicit, honest)

The campaign prompt for this run asks to verify whether `istqb-design`'s official technique
palette (`plugins/qaia-core/skills/istqb-design/SKILL.md`, "Technique palette" section) covers an
accessibility/usability axis, or whether that is a blind spot. Reading the palette top to bottom:
CTFL prerequisites (Equivalence Partitioning, Boundary Value Analysis), Data-Based (Domain
Testing, Combinatorial), Behavior-Based (State Transition, Scenario-Based, CRUD), Rule-Based
(Decision Table, Metamorphic), Experience-Based (Error guessing), and the separate CT-AI syllabus
for AI/ML features — **no technique named "Accessibility Testing" or "Usability Testing" appears
anywhere in this palette.** This is confirmed as **a real angle mort, not a defect to silently
route around**: ISTQB does publish a separate syllabus for this (CT-UT, Usability Testing), and
`istqb-design`'s own header explicitly scopes itself to "Foundation + Test Analyst + CT-AI" (D24)
— CT-UT was never adopted, the same way Random Testing/Session-Based Testing are named as
knowingly-excluded rather than silently absent. Practically, this means every AC in this US had
to be mapped onto a **generic** technique (Equivalence Partitioning treating "conformant DOM
wiring" vs "non-conformant DOM wiring" as the two classes; Error guessing for the
content-correctness reflex on AC3's error text) rather than a technique purpose-built for
accessibility conditions (e.g. a WCAG success-criterion-keyed checklist, which is how real a11y
practice — and QAIA's own `usability-heuristic-review`/`a11y-audit` plugin skills, both living
in the *automation* layer, not the design-technique palette — actually structure this work).
**Flagged honestly for human arbitration: whether CTAL-TA's official absence of an
accessibility/usability design technique is an acceptable, intentional scope boundary for
`istqb-design` (mirroring its CT-UT exclusion) or a real gap worth a dedicated technique/pattern
entry** — not resolved here, not forced into an existing technique that doesn't quite fit.

## AC → technique map

- **AC1** (dialog accessible name + `aria-modal`) → **Equivalence partitioning** — two classes
  (dialog markup that programmatically exposes its name+modal state vs. one that doesn't), one
  representative condition tested against the live, directly-observed markup.
- **AC2** (focus returns to the triggering control on close) → **Equivalence partitioning** on
  the close-mechanism axis (`Escape` key / `Close` icon-button / `Cancel` button — three distinct
  triggers of the same underlying behavior, each its own condition since only one is confirmed),
  plus **State Transition Testing** (§3.2.2) for the re-entrance facet (Q4: does closing and
  reopening reset lingering state) — a genuine lifecycle question (closed → open → closed →
  open-again), not a data partition.
- **AC3** (validation-error text names the correct field type) → **Equivalence partitioning** on
  field-type (Ingredient vs. Instruction), plus **Error guessing** for the specific
  "field-in-error is named wrong" defect class — not derivable from plain partitioning; it is
  the direct-observation-driven reflex check this US's Finding 3 already surfaced.
- **AC4** (label correctly associated per field type — the one AC the live demo already
  satisfies) → **Equivalence partitioning** on field-type, one representative condition per
  class, kept as a genuine acceptance criterion (regression guard), not merely a defect list.

No **Decision Table** technique is used: unlike US-EVAL-004's three-crossed-condition password
reset, none of this US's ACs cross two or more independent conditions into a shared outcome —
each AC's conditions vary along a single axis (name-present/absent, which close control, which
field type). Naming this explicitly rather than forcing a table that would have only one column.

## Test conditions

- **AC1-C1** `[ep]` — the "Edit Chocolate Cake" dialog is opened → **currently confirmed
  failing**: `role="dialog"` carries no `aria-modal`, `aria-label`, or `aria-labelledby` (directly
  observed, `00-source.md` Finding 1, reproduced on two independent opens). The scenario asserts
  the AC's *target* behavior (a real DOM assertion), not the current buggy state — exactly what a
  test book on an intentionally-broken training demo is for.
- **AC2-C1** `[ep]` — the dialog is closed via the **Escape** key → **currently confirmed
  failing**: focus lands on `<body>`, not the triggering "Edit" icon (Finding 2, reproduced once
  on a fresh load).
- **AC2-C2** `[ep]` `[assumption]` `@low-confidence` (Q1) — the dialog is closed via the **Close**
  icon-button → not directly tested; **proposed default** (same broken behavior as `Escape`,
  per Q1) — open to correction on human arbitration or a follow-up direct observation.
- **AC2-C3** `[ep]` `[assumption]` `@low-confidence` (Q1) — the dialog is closed via the
  **Cancel** button → same proposed default and same caveat as AC2-C2.
- **AC2-C4** `[state-transition]` `[assumption]` `@low-confidence` (Q4) — a dialog closed while a
  field is in its error state is reopened for the **same** recipe → **proposed default**: the
  reopened dialog shows the recipe's original values with no lingering error (no source confirms
  this; not tested this session). **Below the default P1+P2 generation threshold (P3) — waived,
  not generated, see `04-priorities.md`/`synthesis.md`.**
- **AC3-C1** `[ep]` `[error-guessing]` `[req-neg]` — an **Instruction** field is left empty and
  **Save** is clicked → **currently confirmed failing**: the shown error text is "Ingredient must
  not be empty", misnaming the field type (Finding 3, reproduced twice on independent opens).
  Marked `[req-neg]` (ADR 0001, istqb-design step 3): this is a refusal path (Save is blocked,
  an error is shown) — the field-naming mismatch is the *content* defect within that refusal.
- **AC3-C2** `[ep]` `[error-guessing]` `[req-neg]` `[assumption]` `@low-confidence` (Q2) — an
  **Ingredient** field is left empty and **Save** is clicked → not directly tested; **proposed
  default**: the error correctly says "Ingredient must not be empty" (the hardcoded-string theory
  from Q2) — open to correction. Marked `[req-neg]` for the same reason as AC3-C1 (a refusal
  path).
- **AC4-C1** `[ep]` — an **Ingredient** field's visible label is inspected against its
  programmatic accessible name → **currently confirmed passing** (directly observed:
  `<label for>` matches the field's actual generated `id`). **Below the default P1+P2 generation
  threshold (P3) — waived, not generated, see `04-priorities.md`/`synthesis.md`.**
- **AC4-C2** `[ep]` — same check for an **Instruction** field → **currently confirmed passing**.
  **P3 — waived, not generated.**

## Sub-step trace (3b/3c/3d — each recorded, never silently absent)

- **3b (oracle-generate, standardized domain)**: not applicable — no AC here touches a
  standardized domain from the trigger list (card/Luhn, ISO 8601 dates, HTTP status codes,
  RFC 5322 email, currency, IBAN). Correctly a no-op, recorded not silently skipped.
- **3c (systematic coverage expansion)**: partially applied, rest explicitly deferred.
  - **"List/collection view" trigger**: the Ingredients/Instructions rows form an
    add/delete list; the **empty-list state** facet of this pattern (what happens if every
    ingredient row is deleted) genuinely matches this US's shape, but is **deliberately
    deferred** — `00-source.md`'s dependencies already name the "+ Add another
    ingredient/instruction" row-creation/deletion flow as a distinct capability not exercised
    this session, so this is a recorded, reasoned deferral, not a silent miss. Sort/filter/
    pagination facets of the same trigger do not apply (the rows carry no sortable/filterable
    attribute).
  - **"Any entity → full CRUD" trigger**: this US instantiates only the **Update** facet (editing
    an existing recipe's fields); **Create** (a brand-new recipe) and **Delete** (removing a
    whole recipe) are separate, undemonstrated capabilities — named as out-of-slice dependencies
    in `00-source.md`, matching the trigger's own guidance to flag rather than invent an
    unobserved mechanism.
  - **"Authorization & server-side enforcement" trigger**: not applicable — the demo has no
    authentication/authorization concept anywhere in the observed flow (confirmed in
    `02-understanding.md`'s adversarial pass).
  - **"Account & auth features → recovery path" trigger**: not applicable — no auth feature
    exists in this US's shape.
  - **"Conditional behavior over config/role axes" trigger**: not applicable — no
    config/feature-flag or role/ownership axis was observed anywhere in this flow.
- **3d (knowledge-driven conditions)**: not applicable — no `.qaia/knowledge/` exists for this
  campaign directory (recorded in `02-understanding.md`); proceeding on the source alone.

## Journey

| Step | Status |
|---|---|
| 03-design | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) |

## Skill evaluation — `istqb-design` (`plugins/qaia-core/skills/istqb-design/SKILL.md`)

- **Verdict**: `CONFORME`.
- **Preuve**: the skill's own header (`SKILL.md` line 10, "Scope: black-box only, by design")
  and its explicit naming of out-of-scope syllabi (line 66-69, "Not adopted from CTAL-TA v4.0...
  named explicitly rather than silently omitted") establish the pattern this run's "Angle mort
  check" section follows: the palette's lack of an accessibility/usability technique was
  identified, checked against the skill's own stated syllabus scope (CTFL + CTAL-TA + CT-AI,
  never CT-UT), and reported as an intentional-looking boundary needing human confirmation rather
  than silently patched over or forced into an ill-fitting technique. This is the same discipline
  the skill already applies to Random/Session-Based/Crowd Testing — the gap this run surfaces is
  a **candidate scope decision** (should CT-UT or an equivalent be adopted for a11y-flavored
  ACs), not a violation of any written rule in the current `SKILL.md`, so no line contradicts an
  output here.
- **Modification concrète proposée**: aucune — this is a scope question for human/product
  arbitration (add an accessibility/usability technique entry, or explicitly document the
  exclusion the way CT-UT/Random/Session-Based already are), not a textual defect in the current
  file.
