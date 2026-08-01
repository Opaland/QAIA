---
name: testbook-generate
description: Generate the atomic Gherkin test book from prioritized test conditions - stable scenario IDs, coverage matrix, negative-ratio check, confidence marking - or regenerate by scenario-level diff when the US evolved, preserving human edits. Use when asked to write test cases or scenarios from a specification, to produce a test book or feature files, or to refresh an existing one after the requirement changed without losing hand-written edits. Sixth step of the QAIA journey.
---

# testbook-generate — the test book

Follow the shared contract in `../README.md`. Prerequisites: `03-design.md` and
`04-priorities.md` (else offer the missing step). Output directory: `.qaia/testbooks/<US-ID>/`.

## Generation rules (non negotiable)

- **Gherkin, English keywords**: `Feature / Background / Scenario / Scenario Outline / Given /
  When / Then / And / But`. Scenario content in the project language.
- **Atomic** — one scenario verifies exactly one behavior. No UI-step chains covering several
  cases. **Exactly one `When` (the action) per scenario; outcomes live only in `Then`** — never
  bury the action in a `Given` or the outcome in the `When`.
  `Background` is for shared *state* setup only. `Scenario Outline` + `Examples` covers
  partitions or boundaries of the *same* behavior, **merged only when all example rows share
  the same priority and confidence** — otherwise split.
- **Journey exception**: at most one end-to-end scenario per US (use-case technique), tagged
  `@smoke`, single journey-level `Then`, excluded from atomicity accounting — see
  `istqb-design`.
- **Preconditions are declarative** ("Given a patient with 3 upcoming appointments"), never a
  click-path. Data seeding belongs to the automation layer: generated tests must run standalone
  outside the session, and environment or credential details never enter the test book.
- **Stable IDs** — every scenario tagged `@QAIA-<US-ID>-<NNN>`, NNN never reused even after
  deletion. Plus: `@AC<n>` (traceability), `@P1/@P2/@P3` (priority), `@negative` where
  applicable, and **exactly one** technique tag from the closed list:
  `@ep @boundary @domain-analysis @decision-table @state-transition @pairwise @crud
  @metamorphic @ai-feature @error-guessing`.
  The single journey scenario carries `@smoke` instead of a technique tag. `@use-case` is
  retired — the technique it named no longer exists in the reference taxonomy `istqb-design`
  follows, so it must not be emitted. Add `@low-confidence` when the scenario rests on an
  `[assumption]` or `[open]` item.
- **Every scenario cites its condition** (`AC2-C3`) in a comment line — the full chain
  US → AC → condition → scenario.
- **Negative coverage**: the blocking rule is the `[req-neg]` checklist of ADR 0001 (the
  negative-path coverage gate) — every refusal, error or denial path has a scenario. The
  **negative ratio is reported as context, never a gate.** Full doctrine, and why this is
  laboured: `references/negative-ratio.md`.
- **Generating on `[open]` items.** A covered condition flagged `[open]` still gets its
  scenario, written with the *proposed safe default* from `02-understanding.md`, tagged
  `@low-confidence`, with an inline comment citing the question ID (`# open: Q5`). Never invent
  a different behavior, never skip silently. Waiving instead of generating is allowed only with
  the user's recorded approval. **Never pad the negative ratio with invented cases** — if
  reaching a target would need error-guessing scenarios not grounded in the source or knowledge
  base, flag the shortfall instead of fabricating.

## Steps — initial generation

1. **Scope check.** Confirm target coverage with the user: P1+P2 by default, P3 on request
   (quota trade-off).
2. **Duplicate scan.** Scan the project's committed `.feature` files (`.qaia/testbooks/` and any
   test directories the user designates — nothing outside the project). List any scenario
   already covering a condition and propose reuse. ⚠ VALIDATION on the reuse list.

   **Always record the scan's outcome** in `coverage-matrix.md`'s "Reuse notes" column,
   including "no duplicates found". A clean scan that leaves no trace is indistinguishable,
   afterwards, from a scan that never ran — the negative result is as much a deliverable as the
   positive one.
3. **Generate per AC.** In Claude Code you may parallelize with one sub-agent per AC, each given
   only: the AC, its conditions, relevant knowledge entries, and these generation rules. Each
   sub-agent writes structured JSON to a temp file; only the aggregation enters the main
   context — the sub-agents exist to keep raw material out of the main context, not merely to go
   faster. Elsewhere, generate sequentially against the same output contract.
4. **Consolidation pass** (mandatory, even sequential): unify vocabulary against
   `knowledge/glossary.md` where it exists, merge redundant scenarios across ACs, factor a
   common `Background`, verify every ID unique and every condition covered or explicitly waived.

   If the knowledge base is absent, unify internally and **record "knowledge base absent" in
   this skill's own `synthesis.md`**, not only by relying on an upstream checkpoint's note. The
   redundancy is deliberate: each deliverable stands on its own, and someone reading this
   synthesis alone would otherwise never learn the vocabulary was unified against nothing.
5. **Emission lints — run before showing anything.** Eleven checks, one of them blocking. Full
   list with the reasoning: `references/emission-lints.md`. In short: the ADR 0001 negative-path
   gate blocks emission; one `When` per scenario; no compound `Then`; every asserted literal
   computed and grounded; `Background` holds only universal invariants; no silent ID gaps; the
   reported ratio matches a literal tag count in the emitted file.

   Then **write `state/<US-ID>/generated.snapshot.md`** — scenario IDs plus a content hash per
   scenario. This is the regeneration baseline; without it, regeneration cannot tell a
   hand-written correction from its own previous output.
6. **Write outputs.** `*.feature` (one per functional area); `coverage-matrix.md` (AC →
   condition → scenario ID → priority → **rationale** → confidence, the rationale column
   carrying `prioritize`'s one-line risk drivers); `synthesis.md` per the shared contract's
   deliverable section (`../README.md`), including the full inline question list and the
   arbitration list. All artifacts carry resume frontmatter (shared-contract rule 10).
7. ⚠ VALIDATION: present the **synthesis**, not the raw dump — counts, ratio, coverage gaps, and
   the `@low-confidence` list to review first. Update `journey.md`.
8. **Project the standardized manifest.** Run `report` (or its logic) to write or refresh
   `.qaia/reports/<US-ID>/manifest.json`, the shared output contract every plugin reads. Counts
   come from this generation, never re-estimated.

## Steps — regeneration mode (a test book is never write-once)

Trigger: the US changed, or the user asks to regenerate. The existing book may contain human
edits — **they win by default.**

1. **Detect human edits first.** Compare the current book against
   `state/<US-ID>/generated.snapshot.md` by hash; scenarios differing from the snapshot are
   human-edited. Snapshot absent (pre-0.1.2 book): treat **every** scenario as potentially
   human-edited, and say so.

   Re-run ingestion→design deltas as needed, writing new questions and conditions back into the
   `00-04` checkpoints — a regeneration that leaves the checkpoints describing the old
   requirement makes every later step work from a stale picture. Then compute a scenario-level
   diff: `unchanged / modified (show old vs new) / new / obsolete`.

   **Scan the whole book**, not just the ACs that visibly changed: a threshold change can touch
   scenarios tagged on other ACs, and a scoped diff misses them.
2. ⚠ VALIDATION per conflict: for each `modified` scenario that was human-edited, and each
   `obsolete` proposal, the user arbitrates. Never delete or overwrite a human-edited scenario
   without explicit approval.
3. Retired IDs are never reused. Matrix and synthesis are regenerated, and a `CHANGELOG` section
   in `synthesis.md` records the diff decisions.

## Guardrails

- A scenario must never assert behavior the source contradicts. When the source is silent, tag
  `@low-confidence` and record the assumption — plausible-but-wrong is the worst defect
  (rubric dim. 5).
- Respect the token budget: sub-agents receive digests from checkpoints, never the raw source or
  the full knowledge base.
