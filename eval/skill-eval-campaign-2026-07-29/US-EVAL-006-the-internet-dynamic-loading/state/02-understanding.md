# 02-understanding — US-EVAL-006

## Reformulation

Who: any visitor (a human, or — realistically for this page — an automated test/scraper) of the
"Dynamically Loaded Page Elements" demo. What: clicking "Start" must always show a loading
indicator immediately, then reveal "Hello World!" after a fixed delay — but the *mechanism* that
reveals it differs by design between the two examples: Example 1 merely toggles visibility on an
element that was in the DOM all along, Example 2 creates the element only after the delay. Why:
this pair exists specifically to expose a common automation defect — a test that waits for an
element to be "present" (Example 1's `#finish` is present from load, just hidden) will falsely
pass too early if it doesn't also check visibility, while a test that only waits for "visible"
without first waiting for "present" will fail outright on Example 2 until the element is created.
Main risk if it misbehaves: a false-positive "pass" from a test that asserts on the wrong
condition (presence vs visibility) is worse than a slow/flaky test, because it hides the exact
defect class this page exists to catch — asymmetric severity, feeds `prioritize`.

Knowledge base: `.qaia/knowledge/` does not exist for this campaign directory — recorded per
shared-contract rule 8 ("degraded modes are explicit"), proceeding on the source alone.

## Ambiguity hunt

**Q1 — forced/repeated click while a timer is already pending.** Neither example's JS disables or
removes `#start button` after the first click, and nothing guards `setTimeout` against being
scheduled twice. A real pointer-driven user cannot trigger this (the button's container is hidden
after the first click), but an automation script calling `.click()`/`dispatchEvent` directly on
the still-existing DOM node could.
- Classification: step 3 of the decision tree — no protected/money/safety domain, and a safe
  default exists (scope this US-slice to the single, real, pointer-reachable click path; treat a
  forced programmatic re-click as an explicitly out-of-scope robustness question, not asserted
  either way) → **`[assumption]`**. Not generated as a scenario asserting specific stacked-timer
  behavior (that would be fabrication — the source doesn't say what happens); flagged instead as a
  named gap for a future robustness-focused US.

**Q2 — is the 5000ms delay an exact instant or a lower bound for assertion purposes?**
`setTimeout(fn, 5000)` in a browser event loop guarantees the callback fires *no earlier than*
5000ms, never exactly at it (scheduling/render/main-thread contention always add some slack) —
this is standard, well-documented JavaScript timer semantics, not a product policy choice specific
to this page.
- Classification: step 2's exception applies (mechanically forced by the runtime's own documented
  contract, like `need-understanding`'s Spring-`@Valid`-ordering calibration example) → step 3,
  **`[assumption]`**: scenarios assert "not visible/not present before 5000ms" and "visible/
  present after waiting past 5000ms" (an explicit wait, not a fixed sleep asserted as an exact
  instant), never "visible at exactly t=5000ms".

## Adversarial pass (by AC type)

- **State machine / lifecycle**: the page has a 3-state visible lifecycle (`idle` → `loading` →
  `revealed`). Re-entrance (can `loading` be entered a second time while already in it?) is
  exactly **Q1** above — logged there, not duplicated. No forbidden-transition rule beyond that is
  stated or implied by the source.
- **Auth / tokens / permissions**: not applicable — the page has no login, token, or permission
  concept; it is a static, unauthenticated demo route.
- **Sorting / pagination**: not applicable — no list/collection view on this page.
- **Thresholds / quantities (inclusive/exclusive at every bound)**: the single threshold in this
  slice is the 5000ms delay, addressed as **Q2** above — logged there, not duplicated.

## Cross-AC interaction pass

- **AC1 × AC4 (the deliberate DOM-shape difference)**: confirmed by source (index page's own
  stated intent, `00-source.md`), not ambiguous — this is the feature's whole point, not a gap.
  No question raised.
- **AC3 × AC6 (shared 5000ms literal across both examples)**: both examples' reveal timing is
  driven by the identical hardcoded value — a scenario asserting Example 1's timing and a scenario
  asserting Example 2's timing are not independent regression signals of two different values,
  they are two applications of the *same* one (AC7 already records this as a confirmed, non-
  ambiguous fact). No new question — noted so downstream design does not treat the two delays as
  independently-flagged risks.
- **AC2 × AC5 (identical loading-indicator markup across both examples)**: confirmed by source
  (AC7), not ambiguous.

## Triple-AC contradiction pass

No triplet of a *protected/restricted-state* rule, a *filtering/scoping* rule, and an
*anti-disclosure/error-shape* rule applies to this slice — this US has no protected-state entity,
no scoped filtering, and no existence-disclosure concern (a public, static, unauthenticated demo
page). **Not applicable, no matching pattern in this US** — the calibration example (patient-
results/org-scope/404-avoidance) requires a lookup-and-disclosure shape this timing/DOM-mutation
slice does not have.

## Q&A log

| ID | Question | Status | Resolution |
|---|---|---|---|
| Q1 | What happens on a forced/programmatic second click while a reveal timer is already pending? | `[assumption]` | Out of scope for this US-slice's scenarios (no pointer-reachable path to it); flagged as a named gap for a future robustness-focused US, not asserted either way |
| Q2 | Is the 5000ms delay an exact instant or a lower bound for test assertions? | `[assumption]` | Lower bound (standard `setTimeout` semantics) — scenarios assert "not yet" before 5000ms and "now" after waiting past it, never an exact-instant assertion |

## Journey

| Step | Status |
|---|---|
| 02-understanding | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign
  run) |

## Skill evaluation — `need-understanding` (`plugins/qaia-core/skills/need-understanding/SKILL.md`)

**Verdict: CONFORME.**

**Evidence**: Step 3 (line 20) and step 4a (line 28) both require an explicit, checkable section
even when "not applicable" — done above ("## Adversarial pass" and "## Triple-AC contradiction
pass" both present with an explicit "not applicable, no matching pattern" call where that is the
true finding), exactly what the 2026-07-29 footnote on guardrail line 48 requires (the defect it
documents — a mandatory pass implicitly touched on but never surfaced as its own section — is not
repeated here). Step 5a's classification tree (lines 30-36) was applied in order for both
questions, with the step-2 money/policy exception (line 33) correctly invoked for Q2 (a
mechanically-forced runtime-semantics point, not a policy choice) rather than defaulting it to
`[open]`. Step 8's checkpoint requirements (line 43) are all present. No deviation found.
**Modification proposed: none.**
