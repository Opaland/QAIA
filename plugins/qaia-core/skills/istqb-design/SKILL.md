---
name: istqb-design
description: Choose and justify ISTQB test design techniques (Foundation + CTAL-TA v4.0 + CT-AI) per acceptance criterion of an understood user story - equivalence partitioning, boundary values, decision tables, state transitions, scenario-based testing, combinatorial testing, domain testing, metamorphic testing, CRUD, AI/ML-feature testing. Fourth step of the QAIA journey.
---

# istqb-design — technique selection, justified

Follow the shared contract in `../README.md`. Prerequisite: `02-understanding.md` (else offer `need-understanding`).

**Scope: black-box only, by design (D110, #54).** No structure-based/white-box technique
(statement/branch/decision/MC-DC coverage) is in this palette or planned — QAIA proposes from
the spec (the acceptance criteria), never from the target application's implementation, which
it never reads. This is an assumed exclusion, not an oversight: see D110 for the full rationale.
Exploratory/session-based testing is a separate, also-assumed exclusion (D111, #55).

## Technique palette (D24 — Foundation + Test Analyst + CT-AI, extended D95, reorganized D109)

Grouped by the **official CTAL-TA v4.0 chapter 3 classification** (verified against the primary
syllabus PDF, `astqb.org`, 2026-07-28 — not a secondary summary, #50/D109). Foundation-level
(CTFL) techniques are listed first: CTAL-TA v4.0's own chapter 3 does **not** re-classify them
(equivalence partitioning, boundary value analysis and error guessing are prerequisite CTFL
knowledge, not part of this syllabus's own data/behavior/rule/experience scheme) — naming that
honestly rather than forcing them into a v4.0 category they don't officially belong to.

### Foundation Level (CTFL) — prerequisite, not part of CTAL-TA v4.0's own ch.3 taxonomy

| Technique | Fits when the AC involves |
|---|---|
| Equivalence partitioning | input/state classes treated the same way |
| Boundary value analysis | thresholds, limits, sizes, dates (test the exact wording: inclusive/exclusive — use the answers from step 02) |

### Data-Based Test Techniques (CTAL-TA v4.0 §3.1)

| Technique | Fits when the AC involves |
|---|---|
| Domain Testing (§3.1.1) | **several related variables each carrying their own boundaries, needing combined coverage** — not each variable's boundaries tested in isolation (plain BVA), but the worst-case/best-case/single-variable-boundary combinations across the set (e.g. a shipping cost driven jointly by weight AND distance bands, each with its own thresholds). Renamed from "Domain analysis" (D109) — the syllabus's own term is "Domain Testing" |
| Combinatorial Testing (§3.1.2, includes pairwise) | many independent parameters where full combination explodes |

### Behavior-Based Test Techniques (CTAL-TA v4.0 §3.2)

| Technique | Fits when the AC involves |
|---|---|
| State Transition Testing (§3.2.2) | lifecycle rules (statuses, allowed/forbidden transitions, events) — **build the explicit state × event table first** (CT-MBT discipline, D95): list every declared state × every declared event, mark each cell valid-target or forbidden, *then* derive conditions from the completed table — never pick transition pairs opportunistically straight from AC prose, which is how gaps like #43's state-machine over-generalization happen |
| Scenario-Based Testing (§3.2.3) | end-to-end user goals crossing several rules — **constrained**: at most one journey scenario per US, tagged `@smoke`, whose `Then` asserts the single journey-level outcome (never re-verifying behaviors already covered atomically); excluded from atomicity accounting. Renamed from "Use case / scenario" (D109) — v4.0 explicitly retired the term "use case testing" (syllabus Appendix C) |
| CRUD Testing (§3.2.1) | full entity lifecycle (create/read/update/delete + inverses) — already derived by the 3c reflex pattern below; tag `@crud` when the technique driving the scenario *is* the lifecycle pattern itself, distinct from a plain state-transition on a single status field |

### Rule-Based Test Techniques (CTAL-TA v4.0 §3.3)

| Technique | Fits when the AC involves |
|---|---|
| Decision Table Testing (§3.3.1) | combinations of conditions → actions (roles × flags × states) |
| Metamorphic Testing (§3.3.2, also CT-AI) | **the exact expected output can't be stated directly** — it depends on an external or unsourced parameter (an exchange rate, a ranking score, a model output) — but a **relation** between two related inputs/outputs is known and checkable without knowing that parameter (double the input amount → the converted total is ~double; the same input submitted twice → the same classification; reordering independent inputs → an unchanged aggregate). Use this **instead of** asserting a fabricated precise value (the exact defect closed in #46) whenever the AC's real requirement is the *relationship*, not a specific number |

### Experience-Based Testing (CTAL-TA v4.0 §3.4)

| Technique | Fits when the AC involves |
|---|---|
| Error guessing / checklist (§3.4.2 sibling, CTFL-level) | error handling, empty states, concurrency — anchored on the ambiguity log |

### CT-AI (separate syllabus, not CTAL-TA — never conflated)

| Technique | Fits when the AC involves |
|---|---|
| AI/ML feature under test (CT-AI v2.0) | the AC describes a feature **in the target application** backed by an AI/ML/GenAI model (recommendation, classification, scoring, generation, ranking) — never QAIA testing itself, always the SUT's own AI feature. Derive, as ordinary Gherkin scenarios (never a live attack, never executed against anything but the self-hosted target): **adversarial-input robustness** (malformed/perturbed input degrades gracefully — a documented fallback/error, not a silent wrong answer), **consistency / back-to-back** (the same input stays within a stated tolerance across re-runs or model versions), and the **metamorphic relations** above. Drift/monitoring needs are flagged as an operational gap for the user, never fabricated as a test assertion (D38) |

**Not adopted from CTAL-TA v4.0 §3.1.3/§3.4.1/§3.4.3** (Random Testing, Test Charters/Session-Based
Testing, Crowd Testing) — confirmed to exist in the official syllabus but out of scope here,
named explicitly rather than silently omitted (same discipline as D95's CTAL-TM/CT-MAT
exclusions). Session-based/exploratory testing scope is tracked separately (#55).

## Steps

1. **Map AC → techniques.** For each AC from `01-extraction.md`, select the applicable technique(s) and write a one-sentence justification tied to the AC's shape ("AC2 sets a time threshold → boundary value analysis on the 2h limit, inclusive per decision Q3-answer").
2. **Derive the test conditions.** Per AC × technique, list the concrete conditions to cover: partitions with representative values, boundaries (value, value±1), decision-table columns, transition pairs (valid + at least one invalid). This list is the input contract of `testbook-generate` — conditions, not scenarios yet.
3. **Negative pressure (ADR 0001).** For every rule that can refuse, error, or deny, mark the corresponding condition as a **required-negative** (tag `[req-neg]` in `03-design.md`). These are the conditions the coverage gate enforces downstream — not a percentage, but a checklist: every refusal/error/denial path must end up with a scenario.
3b. **Standardized domains → oracle (optional).** If an AC touches a standardized domain (card/Luhn, dates/ISO 8601, HTTP status, email/RFC 5322, currency/ISO 4217, IBAN…), invoke `oracle-generate` to add grounded edge-case conditions with their correct expected results, rather than guessing them. Oracle conditions are tagged `@oracle:<standard>` and cited — they strengthen negative-path coverage without fabrication.
3c. **Systematic coverage expansion (recall — do not skip).** Beyond the ACs literally written, derive the conditions a mature tester adds by reflex. Apply each pattern whose trigger the feature matches; each derived condition still cites its technique and, if beyond the source, carries `[assumption]`/`@low-confidence`:
   - **List / collection view** (any screen showing a set of items) → **sort** by each column/criterion, **filter** by each displayed attribute, **empty-list** state, **pagination** bounds, and **state persistence** of sort/filter across navigation away-and-back.
   - **Any entity → full CRUD lifecycle, not just create** → read/**update/delete**; **lifecycle state transitions and their inverses** (open→close→reopen, submit→accept/reject, enable→disable); **cancel mid-operation** (abandon an edit); and the forbidden transitions. **When the source doesn't specify the exact delete/inverse mechanism, tag the derived scenario `@low-confidence`/`[assumption]` — never assert one specific mechanism with full confidence** (#24 gap-harness finding: three independent runs on the same real hard case each *confidently* invented the same plausible-but-wrong mechanism — "reset to a default value" — for an unspecified deletion, none flagging it as an assumption; a converged, confident fabrication is worse than random variance because it reads as certain and can pass a shallow review).
     **`[assumption]` vs `[open]` for an undeclared transition (#43, expense-demo finding) — don't conflate the two.** "Mechanism unspecified" (`[assumption]`, e.g. *how* a delete cascades) is different from "**permissibility** unspecified with no safety-obvious default" (`[open]`). A default-deny reflex is legitimate for destructive/dangerous actions (delete, payment capture, permission escalation) — those get `[assumption]`/`@low-confidence` with "forbidden unless stated" as the safe default. But when the transition is not obviously dangerous either way (e.g. "can a record in status X be rejected directly, or must it go through Y first?") the reflex "undeclared = forbidden" is itself an unstated **business-policy** answer, not a neutral placeholder — that case must be `[open]`, prompting human arbitration, not silently resolved via the state-machine's own default-deny convention.
   - **Conditional behavior (decision table over the variation axes)** → cross the system's real axes: **config/feature flag** on/off, **visibility** private/public, **ownership/role** owner vs member vs admin vs anonymous. Generate the cell for each combination that changes behavior.
   - **Authorization & server-side enforcement (the most common miss)** → for every action: **unauthenticated** access, **permission denied** (wrong role), **cross-tenant** access to another user's resource (IDOR), **uniqueness/constraint** violation, and **UI-bypass** (the rule holds even when the request is sent directly, not through the UI).
   - **Enumerate EVERY list/aggregation view, not just the primary one** → a screen often exposes several distinct collections (e.g. a dashboard with separate issues, merge-requests and groups lists; a profile with several tabs). Each distinct list gets the sort/filter/persistence treatment above — do not stop at the first/most obvious list.
   - **Sibling collections of a named entity (#24 gap-harness finding, mode 1)** → when an AC describes an entity as "a collection/group of X" (e.g. a group is a collection of projects), explicitly ask — and surface as a gap if the source is silent — whether **X itself carries sub-collections or attributes that would naturally roll up here** (e.g. a project has issues, merge requests, an archived flag; a group dashboard commonly aggregates those too). Measured failure: three independent runs on a real hard case each recalled the entity's *own* fields (name, activity) but silently missed every roll-up of the child entity's sub-collections, without flagging that more might exist — do not stop at what the source names for the primary entity only.
   - **Rendering surface (any AC with a visible UI)** *(added 2026-07-31, wave A pattern P6)* → the same behavior on a narrow viewport is not the same test. Derive conditions for: **breakpoint boundaries** (the layout switches at a width — that is a boundary value like any other, test width, width±1), **navigation collapsed into a menu** (an action reachable directly on desktop may need an extra step), **touch-target size** (WCAG 2.5.8, 24×24 CSS px minimum — a real refusal condition, so `[req-neg]`), **occlusion** (a sticky header/footer or on-screen keyboard hiding the element the AC acts on), and **orientation** where the content reflows. Where the source names no breakpoint, tag the derived condition `[assumption]`/`@low-confidence` and say which width you assumed — never assert a project's breakpoints.
     **Scope, stated rather than implied (D100)**: QAIA is web-first and "mobile" means **browser device emulation** (Playwright device descriptors); native iOS/Android is explicitly out of scope for v1. Derive the emulation conditions, and if the AC genuinely requires native behavior (push notifications, biometrics, app lifecycle), surface it as out of scope rather than pretending an emulated equivalent covers it.
     *Why this bullet exists: a grep for `mobile|viewport|responsive|touch|breakpoint|orientation` across all 15 `qaia-core` SKILL.md files returned **7 lines, every one a lexical false positive** ("touches a standardized domain", "human-set status untouched"). The first mobile journey ever run produced these conditions only by the producer's own initiative, never because a skill asked for them — a real product gap, not a non-event.*
   - **Account & auth features → include the recovery path** → beyond the authenticated happy path (change password while logged in), derive the **forgot/reset/recovery** flow when the feature implies it: request reset, email token, invalid new value, unknown account. Recovery is a distinct flow, not a variant of the authenticated change.
   These are `[req-neg]` where they refuse/deny. This step exists because real human test suites cover these by reflex and generation-from-AC-alone systematically misses them (measured: recall gap classes A-D).

   **Ceiling — do not hallucinate to chase recall.** Two families are legitimately *not* inferable from a thin US and must NOT be invented: (a) **config/feature-flag-driven behavior** (what a button does when payments are off, a community is private, a custom field is enabled) — this depends on the project's configuration and belongs to the **knowledge base** (`rag-build`), not to guessing; and (b) **rich domain-specific interactions the US never mentions** (a merge request's inline diff comments, a Markdown preview) — if the source does not imply them, generating them is fabrication, not coverage. When you detect such a family, surface it as a gap ("this feature likely has config-driven / detail-page behavior not described in the US — provide it or the knowledge base") rather than inventing scenarios. Honest recall < fabricated recall.
3d. **Knowledge-driven conditions (the RAG in use — breaks the D38 ceiling).** Follow the shared retrieval protocol (`../README.md`, "Knowledge retrieval & citation"). Route through `knowledge/index.md`, match the current AC's entities/domain/verbs, and open only the matched files.
   **Decompose composite rules first (issue #45 finding — do not skip).** Before deriving conditions from a matched entry, check whether it is *composite*: a single numbered item in `business-rules.md` that bundles several distinct sub-facts under one heading (a per-tier/per-category table folded into prose, an enumeration of thresholds each attached to a different case, several independent properties of the same entity). If it is, **write out each sub-fact as its own clause first** (e.g. for a tiered-allowance rule: "Basic: 8 credits/month", "Basic: no rollover", "Premium: 20 credits/month", "Premium: rollover capped at 10", "Premium: rollover beyond 10 forfeited", "Unlimited: uncapped credits", "Unlimited: 1 active booking/day cap" — 7 clauses, not 1) — then derive conditions per clause, not per rule item. Measured failure this closes: `eval/baselines/rag-recall-gain.md` — `BR-KB-203` bundles 7 tier sub-facts in one paragraph; an unguided pass derived conditions only for the two most boundary-shaped sub-facts (the rollover cap, the daily cap) and silently dropped the four flatter baseline grants/properties, even though the rule was matched, open, and cited.
   For every applicable entry — and every sub-clause of a composite entry — (a role that may not perform the action, a config/feature flag that changes the outcome, a threshold or rounding the US left implicit, an anomaly from `anomaly-history.md` worth a regression condition), **derive a concrete test condition** — this is precisely the config-driven coverage a thin US cannot yield (the honest-recall ceiling of 3c). **One condition per sub-clause, not one condition per rule item**: a composite rule with N distinct sub-facts should yield N cited conditions unless a sub-fact is genuinely not independently observable (see below). Each such condition:
   - cites its source rule (`# rule: BR-KB-nnn`) and is numbered like any condition (`AC3-C5`); when several conditions come from sub-clauses of the same composite item, each still gets its own ID and its own citation — never collapse them into one fourre-tout condition;
   - is `[req-neg]` when the rule denies/refuses; inherits `[assumption]`/`@low-confidence` only if the rule itself is uncertain (a promoted, human-validated rule is *not* an assumption — it is project truth);
   - if it **contradicts** the source, is raised as a question for `need-understanding` instead of being applied silently (the US wins unless the user says otherwise);
   - if a sub-clause genuinely cannot be exercised independently of another (its only observable effect is inside a combined scenario), it may share a condition with that other sub-clause — but say so explicitly ("sub-clauses X and Y are not independently observable, tested together") rather than defaulting to it. Don't inflate the count by fabricating a condition for a sub-fact with no observable behavior of its own, and don't deflate it by folding testable sub-facts together for convenience — honest recall over fabricated recall (D38) cuts both ways here.
   Record the applied rule IDs so `report` can populate `design.knowledgeApplied`. Knowledge base absent → record "knowledge base absent" and proceed on the source alone (do not invent its content — that would be the fabrication 3c forbids).
4. ⚠ VALIDATION: present the AC → technique map with justifications; the user amends or approves.
5. **Checkpoint.** Write `03-design.md`: the approved map + derived test conditions, each condition numbered (`AC2-C3`), with the applied `BR-KB-nnn` rule IDs listed. **Each of sub-steps 3b/3c/3d must appear in the checkpoint with its outcome** — applied (with what it derived), or explicitly waived ("pattern X of 3c not triggered by this US: reason") — never silently absent. Update `journey.md`. Next step: `prioritize`.

## Guardrails

- Every technique choice must cite its justification — an unjustified technique is a rubric defect (dim. 4).
- **A sub-step of 3c with no mention at all in `03-design.md` is a defect, not a non-event** — found by running this skill on a real auth/login US (2026-07-29 skill-eval campaign): 3b and 3d were both explicitly recorded as correctly not applicable, but 3c's own most directly-triggered pattern ("account & auth features → include the recovery path") was skipped without a trace, on the one US type it names by example.
- Conditions marked on `[open]` ambiguities inherit an `[open]` flag — they will surface in the confidence report rather than silently asserting behavior.
