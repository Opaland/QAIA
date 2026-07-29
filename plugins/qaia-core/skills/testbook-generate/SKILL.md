---
name: testbook-generate
description: Generate the atomic Gherkin test book from prioritized test conditions - stable scenario IDs, coverage matrix, negative-ratio check, confidence marking - or regenerate by scenario-level diff when the US evolved, preserving human edits. Sixth step of the QAIA journey.
---

# testbook-generate — the test book

Follow the shared contract in `../README.md`. Prerequisites: `03-design.md` and `04-priorities.md` (else offer the missing step). Output directory: `.qaia/testbooks/<US-ID>/`.

## Generation rules (non negotiable)

- **Gherkin, English keywords** (D11): `Feature / Background / Scenario / Scenario Outline / Given / When / Then / And / But`. Scenario content in the project language.
- **Atomic** (Q35): one scenario verifies exactly one behavior. No UI-step chains covering several cases. **Exactly one `When` (the action) per scenario; outcomes live only in `Then`** — never bury the action in a `Given` or the outcome in the `When`. `Background` for shared *state* setup only; `Scenario Outline` + `Examples` for partitions/boundaries of the *same* behavior, **merged only when all example rows share the same priority and confidence** — otherwise split.
- **Journey exception**: at most one end-to-end scenario per US (use-case technique), tagged `@smoke`, single journey-level `Then`, excluded from atomicity accounting — see `istqb-design`.
- **Preconditions are declarative** ("Given a patient with 3 upcoming appointments"), never a click-path — data seeding is the automation layer's concern (T3/T4).
- **Stable IDs** (D18): every scenario is tagged `@QAIA-<US-ID>-<NNN>` (NNN never reused, even after deletion). Plus tags: `@AC<n>` (traceability), `@P1/@P2/@P3` (priority), `@negative` where applicable, exactly one technique tag from the closed list `@ep @boundary @domain-analysis @decision-table @state-transition @use-case @pairwise @crud @metamorphic @ai-feature @error-guessing` (istqb-design D95 — technique palette extended with Domain Analysis, CRUD, Metamorphic testing and AI/ML-feature testing), and `@low-confidence` when built on an `[assumption]` or `[open]` item.
- **Every scenario cites its condition** (`AC2-C3`) in a comment line — full chain US → AC → condition → scenario.
- **Negative ratio (D20) — single definition**: numerator = scenario blocks tagged `@negative`; denominator = all generated scenario blocks (an Outline counts as 1 block; the `@smoke` journey is excluded). Target ≥ 40 %. Boundary coverage is reported separately in the synthesis, never blended into this ratio.
- **Generating on `[open]` items — explicit rule**: a covered condition flagged `[open]` still gets its scenario, written with the *proposed safe default* from `02-understanding.md`, tagged `@low-confidence`, with an inline comment citing the question ID (`# open: Q5`). Never invent a different behavior, never skip silently — waiving instead of generating is allowed only with the user's recorded approval. **Never pad the negative ratio with invented cases**: if reaching 40 % requires error-guessing scenarios not grounded in the source or knowledge base, flag the shortfall to the user instead of fabricating.

## Steps — initial generation

1. **Scope check.** Confirm target coverage with the user (P1+P2 by default; P3 on request — quota trade-off).
2. **Duplicate scan** (D19): scan the project's committed `.feature` files (`.qaia/testbooks/` and any test directories the user designates — nothing outside the project); list any scenario that already covers a condition and propose reuse instead of regeneration. ⚠ VALIDATION on the reuse list.
3. **Generate per AC.** In Claude Code, you may parallelize with one sub-agent per AC, each given only: the AC, its conditions, relevant knowledge entries, and these generation rules (D30). Each sub-agent writes structured JSON to a temp file; only the aggregation enters the main context (BMAD pattern A7). Elsewhere, generate sequentially — same output contract.
4. **Consolidation pass (mandatory, even sequential):** unify vocabulary (against `knowledge/glossary.md` when it exists — if the knowledge base is absent, unify internally and **record "knowledge base absent" in this skill's own `synthesis.md`, not only by relying on an upstream checkpoint's note** — found redundant-but-required by running this skill for real, 2026-07-29 skill-eval campaign: `03-design.md` had recorded it, but this skill's own deliverable had not, which is what this step requires), merge redundant scenarios across ACs, factor common `Background`, verify every ID unique, every condition covered or explicitly waived.
5. **Self-checks before showing anything (emission lints, 0.1.2):**
   - **negative-path coverage gate (ADR 0001)**: every `[req-neg]` condition from `03-design.md` has a covering `@negative` scenario, or an explicit user-approved waiver — this is the blocking check, not a ratio; every P1/P2 condition covered; Gherkin parses;
   - the negative ratio is still **computed and reported** in the synthesis as a happy-path-bias signal (single definition above), but it is never a threshold and must never be padded toward;
   - one `When` per scenario; **no compound `Then` verifying a second behavior** (an "and no X happened" assertion about another rule → separate scenario);
   - **every literal value you assert is verified by computation before emission** (string lengths, sums, boundary ±1 — count the characters, do the arithmetic);
   - **a computed value is only as grounded as its inputs (#46)**: if the computation depends on an external parameter not stated in the source/design/knowledge base (an exchange rate, a tax rate, a discount table…), do not assert the resulting precise literal as if it were sourced — either keep the assertion qualitative (state the structural fact the AC actually requires, e.g. "the converted total falls in the band above €500", not a fabricated exact figure), or, if a concrete number is needed for boundary testing, invent the input-side value instead and mark the derived parameter explicitly as a test fixture with an inline `# rate-assumption: …` (or equivalent) comment — never a bare precise result with no traceable origin;
   - **`Background` contains only invariants true for 100 % of the file's scenarios** — anything contradicted by even one scenario moves to local `Given`s;
   - `@negative` closed definition: a scenario whose outcome is a refusal, an error, or an explicitly denied access; list-exclusion/filtering scenarios are **not** `@negative`.
   - **ID continuity**: scenario NNN sequence has no gap unless a `# retired: NNN` changelog line explains it — a silent gap is an emission error;
   - **re-check the negative ratio after any scenario merge**: the D20 ratio is measured on the final block set, so a human/consolidation merge that drops below 40 % must add negatives or be flagged, never shipped under-threshold.
   After generation, **write `state/<US-ID>/generated.snapshot.md`**: scenario IDs + content hash per scenario — the regeneration mode's baseline for detecting human edits (C3 fix).
6. **Write outputs:** `*.feature` (one per functional area), `coverage-matrix.md` (AC → condition → scenario ID → priority → **rationale** → confidence — the rationale column carries `prioritize`'s one-line risk drivers), `synthesis.md` per the **shared contract's deliverable section** (`../README.md`) — including the full inline question list and the arbitration list. All artifacts carry resume frontmatter (shared-contract rule 10).
7. ⚠ VALIDATION: present the synthesis (not the raw dump): counts, ratio, coverage gaps, and the `@low-confidence` list to review first. Update `journey.md`.
8. **Project the standardized manifest.** Run `report` (or its logic) to write/refresh `.qaia/reports/<US-ID>/manifest.json` — the shared output contract (D39) every plugin reads. Counts come from this generation, never re-estimated.

## Steps — regeneration mode (D17: never write-once)

Trigger: the US changed, or the user asks to regenerate. The existing test book may contain human edits — **they win by default**.
1. **Detect human edits first**: compare the current book against `state/<US-ID>/generated.snapshot.md` (hashes) — scenarios differing from the snapshot are human-edited. Snapshot absent (pre-0.1.2 book): treat **every** scenario as potentially human-edited and say so. Re-run ingestion→design deltas as needed — **new questions/conditions are written back into the `00-04` checkpoints** (incremental update, M7 fix), then compute a **scenario-level diff**: `unchanged / modified (show old vs new) / new / obsolete`. **Scan the whole book** for values tied to the changed requirement (a threshold change can touch scenarios tagged on other ACs — M3 fix).
2. ⚠ VALIDATION per conflict: for each `modified` scenario that was human-edited, and each `obsolete` proposal, the user arbitrates. Never delete or overwrite a human-edited scenario without explicit approval.
3. Retired IDs are never reused; matrix and synthesis are regenerated; a `CHANGELOG` section in `synthesis.md` records the diff decisions.

## Guardrails

- A scenario must never assert behavior the source contradicts; when the source is silent, tag `@low-confidence` and record the assumption — plausible-but-wrong is the worst defect (rubric dim. 5).
- Respect the token budget: sub-agents receive digests from checkpoints, never the raw source or the full knowledge base.
