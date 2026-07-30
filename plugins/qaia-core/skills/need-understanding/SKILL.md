---
name: need-understanding
description: Analyze a validated user story extraction - reformulate the need, detect ambiguities, contradictions and missing rules, ask the user targeted questions, and record answers or explicit assumptions. Third step of the QAIA journey.
---

# need-understanding — ambiguity hunt

Follow the shared contract in `../README.md`. Prerequisite: `01-extraction.md` (else offer `us-review`). Load relevant knowledge via `knowledge/index.md` — project rules may already answer some questions.

## Steps

0. **Nothing-to-understand check.** If `01-extraction.md` has no capability/behavior to test (a design doc, an RFC process, an empty template, a title with no ACs), do not fabricate requirements: say what the source actually is, and either ask the user for the missing acceptance criteria or stop. A reformulation of nothing is a defect.
1. **Reformulate.** State the need in 3-5 sentences: who, what, why, main risk if it misbehaves. This is the understanding the whole test design will rest on.
2. **Hunt ambiguities.** Systematically inspect each AC and rule for:
   - undefined terms and units ("soon", "recent", inclusive/exclusive thresholds)
   - **every duration or deadline: "measured against which clock/referential?"** (user timezone vs server vs counterpart — attach the question to the AC doing the *computation*, not the one doing the display)
   - contradictions between ACs, or between ACs and knowledge-base rules
   - missing behavior (error paths, empty states, concurrency, permissions)
   - unspecified data rules (formats, rounding, limits, uniqueness)
3. **Adversarial pass by AC type (mandatory — C1 fix).** Before the cross-AC pass, run the type-specific checklist on every AC:
   - **state machine / lifecycle** → re-entrance (can a state be reached **more than once** — e.g. `corrected` → `corrected` again, a chain of corrections?), and for any "supersedes/references predecessor" rule ask whether it points to the **immediate** predecessor or the **whole chain**; forbidden transitions; terminal states;
   - **auth / tokens / permissions** → revocation vs expiration, scope change mid-session, indistinguishability rules under every response path;
   - **sorting / pagination** → tie-break on equal keys, out-of-range pages, degenerate case where filters remove 100 % of results (empty response *shape*);
   - **thresholds / quantities** → inclusive vs exclusive at every bound, rounding, units, reference clock.
   **Hard rule (C2 fix): any test-data choice that sidesteps an undefined case is forbidden without a Q-item** — if you pick distinct dates to avoid an unspecified tie-break, the tie-break becomes a numbered question first.
   - **access boundary → question, never assumption**: when the US does not state whether an action needs authentication or is public, it is `[open]`. Never assert "unauthenticated → redirect to sign-in" when the source implies public read access — that is a scenario contradicting real behavior. Generate the guessed side only as `@low-confidence` citing the question.
4. **Cross-AC interaction pass (mandatory).** For every pair of ACs sharing a resource, entity or time window (a slot, a counter, a document state), ask: "what happens when the outcome of rule A feeds rule B at B's boundary?" (e.g. an item freed by a cancellation rule re-entering an availability rule inside its cutoff window). Log each interaction as covered, `[assumption]`, or `[open]` — intra-AC hunting alone misses exactly these.
4a. **Triple-AC contradiction pass (0.1.3 — closes C1).** Pairs are not enough: some contradictions only appear when **three rules meet**. Explicitly enumerate triplets where a *protected/restricted state* rule, a *filtering/scoping* rule, and an *anti-disclosure/error-shape* rule apply to the same entity, and ask which wins at their intersection. Calibration example (US-003): a patient whose results are **all `restricted`** (AC4) requested by an **org-scoped** token (AC5) under the **404-to-avoid-existence-disclosure** rule (AC6) — is the answer an empty `200` list or a `404`? That is a mandatory question, never a silently chosen default.
5. **Ask, don't guess.** Present findings as numbered questions (stable IDs `Q1, Q2…` — this numbering is cited by scenarios and must be complete and gap-free in the delivered synthesis), most impactful first, each with: why it matters for testing, and your proposed default answer. **Q-slots are for requirement ambiguity only (step 2's categories), never for test-feasibility or flakiness questions** ("is this independently re-verifiable live?", "is it scenario-testable without flakiness?") — those are automation-design concerns for `automate`/`testbook-generate`, not gaps in what the US specifies (found 2026-07-30 skill-eval campaign: two Q-slots were consumed by feasibility questions while a genuine unspecified-data-rule candidate on the same US got no question at all).
5a. **Classification decision tree (M1 fix — apply in this order, stop at first match):**
   1. The source answers it literally **for the exact case at hand** → **answered** (cite the line). **A citation is not an answer when the US does not cover the symmetric/edge case**: quoting "maximum thresholds are reduced by 50 %" does not answer "does the reduction also apply to the *minimum* threshold?" — that stays a question, never `answered`.
   1b. **Out-of-slice answer (sibling story).** If the answer plausibly lives in another backlog story (per `00-source.md` `dependencies:`) but not in the ingested slice, it stays a **question tagged `[out-of-slice]`** — not `answered` (you don't have the text) and not silently defaulted. Note which sibling story likely holds it.
   2. The point touches a protected domain — minors/protected populations, money/billing, health-data access or retention, legal/compliance evidence — **and** the source is silent → **`[open]`** (any default is a product decision). *Exception (money-mechanical vs money-policy):* a money-adjacent point whose answer is mechanically forced, not a policy choice (e.g. "a fine stops growing once the item is returned" — the opposite is absurd), is `[assumption]`, not `[open]`. Reserve `[open]` for genuine money *policy* (rate, cap, rounding, grace).
   3. A safe default exists that a reasonable practitioner would accept without escalation → **`[assumption]`**.
   4. Otherwise → **`[open]`**.
   Calibration examples: "does a cancelled appointment free the counter?" → step 3, `[assumption]` (safe default: yes, flagged). "Is a refused attempt an audit event?" → compliance evidence, step 2, `[open]`. "Missing guardian contact for a minor" → protected population, step 2, `[open]`.
6. ⚠ VALIDATION: for each question the outcome is exactly one of:
   - **answered** — the user states the rule → recorded as a decision;
   - **`[assumption]`** — the user accepts your proposed default, **or answers "not specified / I don't know" AND your default is a low-risk plausible behavior** → the default becomes a flagged working assumption;
   - **`[open]`** — no answer and the point is a genuine product decision (safety, money, compliance, user-visible policy) where any default would be a guess → stays open, caps confidence of affected scenarios.
   Record which of the three applies for every question; two skills executors must classify identically.
7. **Knowledge capture.** If an answer states a reusable business rule, offer to add it to `knowledge/` via `rag-build` (do not write knowledge files yourself).
8. **Checkpoint.** Write `02-understanding.md`: reformulation, complete Q&A log with status (`answered` / `assumption` / `open`), **plus an explicit `## Adversarial pass (by AC type)` section and an explicit `## Triple-AC contradiction pass` section** — each stating either its findings or "not applicable, no matching pattern in this US" with a one-line reason. Update `journey.md`. Next step: `istqb-design`.

## Guardrails

- Never silently resolve an ambiguity — that is the defect the rubric punishes hardest (dim. 5-6).
- **Omitting the required trace of step 3 or step 4a from `02-understanding.md` is the same defect as silently resolving an ambiguity** — a mandatory pass that leaves no evidence it ran is indistinguishable from a skipped one (found by running this skill for real, 2026-07-29 skill-eval campaign: both passes were implicitly touched on inside a question's justification text but never surfaced as their own checkable section).
- Bound the interrogation: maximum ~10 questions per pass, highest impact first; offer a second pass rather than overwhelming the user.
