# 02-understanding — US-EVAL-007

## Reformulation

Who: any user opening the "Edit Recipe" dialog on the Awesome Recipes dashboard, in particular
one relying on a keyboard and/or a screen reader. What: the dialog must announce itself (name +
modal state) to assistive technology, return keyboard focus to a predictable place when it
closes, and report validation errors that correctly name the field in error — while what is
already correct (label association, focus-move-to-heading on open) must not regress. Why: this
is an **accessibility-conformance** feature on a target whose entire purpose
(`docs/DEMO-TARGETS.md`'s ✅✅ a11y rating, "purpose-built") is to contain exactly this class of
defect for training — unlike the login/auth-boundary US's this campaign has run so far
(US-EVAL-001, US-EVAL-004), the risk here is not unauthorized access but **exclusion**: a
keyboard/screen-reader user who cannot determine the dialog's purpose, loses their place after
closing it, or is told the wrong field is empty, may be unable to complete the task at all, or
completes it with reduced confidence/trust. Main risk if it misbehaves: a user with a disability
cannot reliably edit and save a recipe, or abandons the task believing the app is broken (which,
per Findings 1-3, it demonstrably and intentionally is, for training purposes).

## Knowledge base

No `.qaia/knowledge/` present for this campaign directory — recorded per shared-contract rule 8,
proceeding on the source alone (degraded mode, explicit, not silently skipped).

## Ambiguity hunt

**Q1 — Close (X icon) and Cancel button focus-return.** `00-source.md` Finding 2 confirms the
`Escape` key path loses focus to `<body>` on close. Whether the visible **Close** icon-button and
**Cancel** button (distinct DOM elements, not the `Escape` keyboard shortcut) exhibit the same
lost-focus behavior, or restore focus correctly, was not tested this session.
- Classification: step 3 of the decision tree (a safe, low-risk default exists: all three close
  paths plausibly route through the same underlying close handler in a small demo app, so the
  same broken behavior is the reasonable default to assume without escalation) → **`[assumption]`**.
  Proposed default: Close and Cancel behave the same as Escape (focus lost to `<body>`).

**Q2 — Ingredient-field validation-error wording.** Finding 3 confirms the **Instruction**-field
case: the error text says "Ingredient must not be empty" for an emptied Instruction field. Not
tested: what text is shown when an **Ingredient** field itself is left empty — could be the
(matching, correct) "Ingredient must not be empty", could be a different mismatch, e.g. an
"Instruction"-worded message.
- Classification: step 3 (a safe default exists and this isn't a protected/money/safety domain):
  the mismatch pattern observed (Instruction field → "Ingredient" wording) suggests the error
  string is likely hardcoded/copy-pasted rather than dynamically keyed to field type, so the
  simplest default is that Ingredient fields **coincidentally** show the correct wording (since
  the hardcoded string already says "Ingredient") → **`[assumption]`**, `@low-confidence`.

**Q3 — Real assistive-technology impact of the missing dialog name.** The DOM-level absence of
`aria-modal`/`aria-label`/`aria-labelledby` (Finding 1) is confirmed directly. Whether a real
screen reader (NVDA/JAWS/VoiceOver) meaningfully fails to convey the dialog's purpose in practice
— given that focus does correctly land on the visible `<h2>` heading on open, which some screen
readers would still read aloud as the focused element's own text even without a formal
`aria-labelledby` link — was not verified with actual assistive technology this session.
- Classification: step 3 — a safe, conservative default exists (assert only the DOM-level,
  tool-verifiable fact: the dialog element itself carries no accessible name/modal marking) →
  **`[assumption]`**. The scenario below asserts the DOM-observable fact, not a claim about a
  specific screen reader's runtime behavior — narrower and defensible without live AT.

**Q4 — Re-entrance: does closing and reopening the same recipe's dialog reset its validation/
error state?** Adversarial-pass state-machine check (step 3 of `need-understanding`): the dialog
is a closed→open→closed→open-again lifecycle. If a user empties a field, triggers the Save
validation error (Finding 3), then closes (`Escape`) and reopens the **same** recipe's dialog,
does the field show the original saved value with no error (a fresh render), or does the
emptied/errored state persist?
- Classification: step 3 (a safe default exists: no source states client-side state is retained
  across a full dialog close/reopen, and re-rendering from the recipe's stored data on each open
  is the ordinary, unsurprising behavior for this class of small demo app) → **`[assumption]`**.
  Proposed default: reopening shows the original values with no lingering error.

## Adversarial pass (by AC type — mandatory, `need-understanding` step 3)

This US's ACs describe a **dialog open/close lifecycle** with **validation state**, not an
auth/permission feature, a sortable/paginated list, or a numeric-threshold rule. Applying the
four type checklists explicitly:
- **State machine / lifecycle** (closed → open → closed → open again): **applicable** — this is
  exactly **Q4** above (re-entrance: can the dialog be entered more than once, and does its
  error state carry over). No other lifecycle states exist in the observed flow (no
  "saving"/"saved" transient state was exercised, since Save was never completed successfully
  this session — out of scope for the four a11y-focused ACs, not itself an AC here).
- **Auth / tokens / permissions**: **not applicable** — the demo has no login, session, or
  permission concept anywhere in the observed flow; the dialog is reachable by anyone.
- **Sorting / pagination**: **not applicable** — the edit-recipe dialog has no list to sort or
  page through (the Ingredients/Instructions rows are an ordered add/delete list, not a
  sortable/paginated collection; row-add/delete is explicitly out-of-slice per `00-source.md`
  dependencies).
- **Thresholds / quantities**: **not applicable** — no AC here involves a numeric boundary
  (length limits, counts); AC3's "required" check is a presence/absence rule, not a threshold.

## Cross-AC interaction pass

AC1 (no accessible dialog name) and AC2 (focus lost on close) compound at the same lifecycle
boundary: a screen-reader user who cannot determine what dialog they just entered (AC1) and then
cannot tell where their focus went after leaving it (AC2) experiences two independent
disorientation failures back-to-back on the *same* interaction — opening then closing one
dialog. Neither AC's scenario alone captures this combined severity; noted here as the reason
both are prioritized independently as high-impact below rather than only their individual
technical facts.

## Triple-AC contradiction pass (0.1.3 — mandatory)

**Not applicable — no matching pattern in this US.** The triple-AC pattern requires a
*protected/restricted entity state* × a *scoping rule* × an *anti-disclosure rule* intersecting
on the same entity (the pattern's own worked example: a patient's `restricted` results ×
org-scoped token × 404-to-avoid-disclosure). This US's four ACs concern a single, unauthenticated,
non-multi-tenant recipe-editing dialog with no access-boundary, ownership-scoping, or
existence-disclosure concept anywhere in the observed flow — there is no triplet of that shape to
enumerate. Recorded explicitly rather than silently skipped, per the guardrail.

## Q&A log

| ID | Question | Status | Resolution |
|---|---|---|---|
| Q1 | Close/Cancel button focus-return vs. Escape's confirmed-broken behavior | `[assumption]` | Default: same broken behavior (focus lost to `<body>`) assumed for all three close paths |
| Q2 | Ingredient-field validation-error wording (vs. confirmed Instruction-field mismatch) | `[assumption]`, `@low-confidence` | Default: Ingredient fields coincidentally show correct wording (hardcoded string theory) |
| Q3 | Real screen-reader behavior given the missing dialog name | `[assumption]` | Scenario asserts only the DOM-level fact (no `aria-modal`/name), not a specific AT's runtime behavior |
| Q4 | Re-entrance: does closing/reopening reset validation/error state | `[assumption]` | Default: reopening re-renders original values, no lingering error |

## Journey

| Step | Status |
|---|---|
| 02-understanding | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) |

## Skill evaluation — `need-understanding` (`plugins/qaia-core/skills/need-understanding/SKILL.md`)

- **Verdict**: `CONFORME`.
- **Preuve**: the guardrail at `SKILL.md` line 48 requires an explicit, separately-headed
  `## Adversarial pass (by AC type)` section and `## Triple-AC contradiction pass` section, each
  stating findings or "not applicable... with a one-line reason." Both sections above do exactly
  that — three of the four adversarial-pass categories are explicitly marked not applicable with
  a one-line reason each, the fourth (state-machine/re-entrance) is applied and yields Q4; the
  triple-AC pass is marked not applicable with a reasoned explanation of why this US's shape
  (no protected-state/scoping/anti-disclosure triplet) does not match the pattern, rather than a
  bare "n/a". Step 5a's classification decision tree (line 30) is also followed correctly: none
  of Q1-Q4 touch a protected domain (money/minors/health/compliance), so each correctly lands at
  step 3 (`[assumption]`) rather than being over-escalated to `[open]` — a distinction this run's
  US-EVAL-004 precedent (an auth/account-recovery US) had to draw the opposite way for its own
  Q1/Q3/Q4, showing the rule is applied on the US's actual shape, not copied from the prior run.
- **Modification concrète proposée**: aucune.
