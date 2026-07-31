---
stepsCompleted: [00-ingest]
lastStep: 05-testbook-generate
lastSaved: 2026-07-31
upstreamStatus: extraction unconfirmed; priorities proposed-but-not-arbitrated
---

# synthesis — US-EVAL-013 · Swag Labs catalogue navigation on a phone viewport

**US-ID**: `US-EVAL-013` · **Date**: 2026-07-31 · **Book**: `saucedemo-mobile-navigation.feature`

> **Provenance warning, carried from upstream and not softened**: the extraction is `unconfirmed`
> (`us-review` step 3 never got a human), and the priorities are **proposed but not arbitrated**
> (`prioritize` step 3 likewise). Nothing in this book is suitable for a production Go/No-Go until
> a human works the arbitration list below.

## Counts

| Metric | Value |
|---|---|
| Scenario blocks emitted | **17** (2 `Scenario Outline` with 2 rows each + 1 with 2 rows, 14 plain `Scenario`) |
| P1 | 11 blocks (`-001, -002, -004, -006, -007, -008, -011, -012, -013, -016, -017`) |
| P2 | 6 blocks (`-003, -005, -009, -010, -014, -015`) |
| P3 | 0 (7 conditions deferred — listed in `coverage-matrix.md`) |
| `@smoke` journey | 1 (`-017`, excluded from atomicity accounting and from the ratio) |
| `@low-confidence` | 5 blocks (`-001, -002, -003, -014, -016`) |
| Conditions covered | 19 of 26 (P1+P2 in full) |

## Negative-path coverage (ADR 0001 — the gate) and the raw ratio (a signal only)

- **Required-negative coverage: 4 / 4 = 100 %.** Every `[req-neg]` condition of `03-design.md` has
  a covering `@negative` scenario: AC3-C1 → `-004`, AC5-C2 → `-011`, AC5-C3 → `-012`,
  AC5-C4 → `-013`. **The blocking gate passes.**
- **Raw negative ratio: 4 / 16 = 25.0 %**, below the 40 % target. **Tag-vs-ratio audit performed on
  the file actually written**: `grep -c "@negative"` on the emitted `.feature` returns **4**, and
  `grep -c "^  Scenario"` returns **17**, minus the one `@smoke` block = 16. The numerator is a
  literal tag count, not a semantic recount.
- **Ratio explainer (required when coverage passes but the ratio is low)**: the headline of this US
  is a **measurement**, not a rule that can refuse. AC1, AC2, AC6 and AC7 are all "at width W this
  element renders at size S" — a rendered dimension has no refusal path to test, so no honest
  `@negative` exists for them. Every refusal in this story lives in **AC5** (three guarded-route
  denials) and **AC3** (a denied interaction). **The shortfall was not padded**: reaching 40 %
  would have required inventing error cases with no grounding in the source, which
  `testbook-generate`'s own rule forbids.

## Open ambiguities — the full numbered list, inline (the reviewer never sees the state files)

| ID | Question | Status | Reaches the book as |
|---|---|---|---|
| **Q1** | Is the 480/481 drawer breakpoint intended, and is 480 inclusive on the phone side? | `[assumption]` (proposed default applied) | `-001, -002, -003` all `@low-confidence`, `# open: Q1` |
| **Q1b** | What happens at a fractional viewport width (480.5 px)? | `[open]` | **no scenario** — deliberately not defaulted |
| **Q2** | Is the 40 × 30 px sort stub below 900 px intended, or a degradation? | `[open]` | `-014` `@low-confidence`, `# open: Q2` |
| **Q3** | Is a 20 × 20 CSS px burger — the sole phone navigation control — an accepted target size? | `[open]` | `-016` `@low-confidence`, `# open: Q3`, `@oracle:wcag-2.2-2.5.8` |
| **Q4** | The drawer has no scrim: is "closes only via its own ✕" intended, or is tap-outside-to-dismiss missing? | `[assumption]` | informs `-007`; no separate scenario asserts a tap-outside behaviour |
| **Q5** | Does the app react to an **orientation change** at all, or only to width? | `[open]` | **no scenario** — never observed, so never guessed |
| **Q6** | Is the single-column grid holding to 1060 px (not just on phones) intended? | `[assumption]` | not scenarised (BR1, outside the P1/P2 condition set) |
| **Q7** | Is the post-logout refusal viewport-independent? | `[assumption]` | `-011`/`-012` written once, not per descriptor |
| **Q8** | At ≥ 481 px with the drawer open, is the catalogue meant to be interactive or modal-blocked? | `[open]` | **no scenario at 481** — the decision table uses 1280 for the wide class |
| **Q9** | If the session ends while the drawer is open on a phone, is the refusal rendered *behind* the full-screen drawer? | `[open]` | **no scenario** — carried here as an open arbitration, not guessed |

## Arbitration list (needs a human before any Go/No-Go)

1. **The entire priority table** — proposed, never arbitrated (`04-priorities.md`).
2. **The extraction itself** — `unconfirmed`; all 7 ACs are `[reconstructed]` from measurement,
   since the target has no written spec.
3. **`-016` scored P1** — an accessibility gap ranked joint-highest risk of the story on an `[open]`
   question. The single most contestable call in the run.
4. **Q2's effect on `-014`** — if a human rules the 40 px stub intended, both rows drop to P3.
5. **Q1's effect on `-001`/`-002`/`-003`** — confirming inclusivity would drop the whole Q1 cluster
   a band and remove three `@low-confidence` tags.
6. **The four `[open]` questions with no scenario at all** (Q1b, Q5, Q8, Q9) — each is a genuine
   behavioural gap, not an oversight; a human must decide whether to specify or to accept them.
7. **The D19 reuse list** — scan ran, 0 reuses proposed, `pending-validation`.

## Out-of-slice dependencies (the book is complete *for the ingested slice*)

From `00-source.md`'s `dependencies:` — no sibling story exists in this repository to hold their
answers (the target is a live app, not a backlog):

- **Checkout / payment on a phone viewport** — a separate US; this slice stops at the catalogue and
  the drawer.
- **Per-user variants** (`problem_user`, `visual_user`, `performance_glitch_user`) — a separate US;
  this is exactly the config-driven family `istqb-design`'s 3c ceiling reserves for the knowledge
  base rather than invention.
- **Sort *semantics*** (does "Price low to high" really sort?) — a separate, viewport-independent
  US. This book covers only the sort control's rendered footprint and its state persistence.
- **`Reset App State`** (the drawer's 4th item, a destructive action) — a separate US.
- **Native iOS/Android** (SauceLabs *My Demo App*) — **out of product scope entirely (D100)**, not
  merely out of slice. Named so a reviewer does not read "mobile" here as "native".

## Review order

1. `@low-confidence` first: `-016` (P1, Q3), `-001` (P1, Q1), `-002` (P1, Q1), `-014` (P2, Q2),
   `-003` (P2, Q1).
2. Then P1 → P3: remaining P1 (`-004, -006, -007, -008, -011, -012, -013, -017`), then P2
   (`-005, -009, -010, -015`).

## By-technique summary

| Technique tag | ACs | Blocks | Justification (from `03-design.md`) |
|---|---|---|---|
| `@boundary` | AC1, AC2, AC6, AC7 | 4 (`-001, -002, -014, -016`) | Three exact thresholds — 480/481, 899/900, and (via the oracle) 24 CSS px — each tested at the edge, not inferred |
| `@ep` | AC1 | 1 (`-003`) | Representatives inside the phone partition, where every width behaves identically |
| `@decision-table` | AC3 | 2 (`-004, -005`) | The outcome depends on two independent conditions (viewport class × drawer state), which is §3.3.1's own trigger; the closed-drawer cell is the control that proves the blockage is the drawer's doing |
| `@state-transition` | AC4, AC5, AC6 | 6 (`-006, -007, -008, -010, -011, -015`) | Derived from the explicit state × event table built first in `03-design.md` §2 (CT-MBT discipline, D95) |
| `@error-guessing` | AC4, AC5 | 3 (`-009, -012, -013`) | Checklist enumeration: "is there another route out?", "what if I never signed in?", "what about the *other* guarded URLs?" |
| `@use-case` | AC1+AC4+AC5 | 1 (`-017`) | The single permitted journey scenario, `@smoke`, one journey-level `Then` |
| `@oracle:wcag-2.2-2.5.8` | AC7 | 1 (`-016`) | Added tag (not a technique tag): the 24 × 24 CSS px threshold is cited from WCAG 2.2 SC 2.5.8, not guessed |

## Knowledge base

**Absent.** `.qaia/knowledge/` does not exist for this evaluation run — no `index.md` to route
through, no `BR-KB-nnn` cited, `design.knowledgeApplied` empty in the manifest. Recorded here in
this skill's **own** deliverable, not only by pointing at `03-design.md`'s note
(`testbook-generate` step 4's explicit requirement).

## Self-check lints run before emission (step 5)

| Lint | Result |
|---|---|
| Negative-path gate (ADR 0001) | **pass** — 4/4 `[req-neg]` covered by a true `@negative` outcome; no P1/P2 `[req-neg]` was emitted with a positive assertion and deferred to arbitration |
| One `When` per scenario | pass — 17/17. `-015`'s open-close cycle was **rewritten before emission** from "opens the drawer and closes it again" to "performs one full open-close cycle", which is the single action the condition names |
| No compound `Then` verifying a second behaviour | pass with one deliberate call: `-004`'s two `Then` lines (where the tap landed / the cart badge is still absent) are two faces of **one** behaviour — "the tap did not reach the catalogue". Stated rather than hidden |
| Literal values verified by computation | pass — 479→479 (100 %), 480→480 (100 %), 481→300 (300/481 = 62.4 % → "62 percent"), 899→40, 900→223, 20 < 24. Every figure re-measured this session (`probe-breakpoint.js`, `probe-recall.js`), none carried over unverified |
| No unsourced computed literal (#46) | pass — no external parameter is involved; every literal is a direct rendered measurement or a cited standard threshold |
| `Background` = invariants true for 100 % of blocks | pass — reduced to "the application is available at the target URL". A "Given a signed-in shopper" `Background` was **rejected**: `-012` and `-013` require a never-authenticated session and would have contradicted it |
| `@negative` closed definition | pass — all 4 are refusals/denials; no filtering/exclusion scenario is tagged `@negative` |
| ID continuity | pass — `001`…`017`, no gap, no retired ID |
| Tag-vs-ratio audit | pass — numerator taken from `grep -c "@negative"` on the emitted file (4), not from a semantic recount |
| Gherkin parses | pass — `npx gherkin-lint@4.2.4 -c .gherkin-lintrc <file>` exited 0 with no output (the exact command the repo's CI runs; this book sits under `eval/skill-coverage-wave-2026-07-30/`, which is **not** in the CI linter's exclude list, so it is really in scope) |
| `generated.snapshot.md` written | yes — `state/generated.snapshot.md`, 17 SHA-256 block hashes |

## ⚠ VALIDATION (step 7)

`pending-validation` — no user available. This synthesis is presented, not approved.

## Skill finding — `testbook-generate` has no vocabulary for a device/viewport dimension (raised, not fixed)

- **SKILL.md line 16** fixes the tag set: *"exactly one technique tag from the closed list
  `@ep @boundary @domain-analysis @decision-table @state-transition @use-case @pairwise @crud
  @metamorphic @ai-feature @error-guessing`"*, plus `@AC<n>`, `@P1/@P2/@P3`, `@negative`,
  `@low-confidence`.
- **What this book needed and could not express**: nothing in that tag vocabulary says *which
  rendering surface a scenario runs on*. `-001` (479/480 px), `-006` (a phone descriptor) and a
  hypothetical desktop-only scenario are indistinguishable by tag — yet they must run on different
  Playwright **projects**. `automate` SKILL.md line 33 requires exactly that split ("projects split
  by type e2e-desktop / e2e-mobile emulation / api"), but **the test book carries no signal telling
  it which scenario belongs to which project**. On this run I had to recover the mapping from the
  scenario prose ("at a viewport 479 px wide", "on a phone device descriptor"), which is precisely
  the kind of implicit coupling stable tags exist to prevent.
- **Consequence, concretely**: a book generated by this skill cannot be handed to `automate` with
  its desktop/mobile split intact. Two consumers of the same closed tag list disagree — one demands
  a project split, the other provides no way to declare it.
- **Proposed diff (NOT applied)** — extend line 16's tag rules with an optional surface tag:
  `` …, and — when an AC's outcome depends on the rendering surface — exactly one surface tag from the closed list `@surface:mobile @surface:desktop @surface:any` (default `@surface:any` when omitted), which `qaia-playwright:automate` maps onto its `e2e-mobile` / `e2e-desktop` Playwright projects. ``
- Not applied; left for arbitration. (This is the same root lacuna reported against
  `istqb-design` in `03-design.md` and against `need-understanding` in `02-understanding.md`,
  surfacing here as a *tag-vocabulary* symptom rather than a *checklist* one.)
