---
name: feedback
description: Capture the tester's corrections on a generated test book, store them as examples, and propose validated promotion of recurring corrections into knowledge-base rules so future generations improve. Use after someone has reviewed or reworked generated tests, when the same correction keeps coming back run after run, or when asked to make QAIA learn a project's own conventions instead of repeating the same mistake. Final step of the QAIA journey.
---

# feedback — learn from corrections, honestly

Follow the shared contract in `../README.md`. "Learning" here means enriching the local knowledge base and example store (README's honest positioning) — nothing else. Promotion is **always human-validated** (D22).

## Prerequisite

A generated test book to compare against (`.qaia/testbooks/<US-ID>/`, from `testbook-generate`). If none exists — no checkpoint, no test book — say so and offer `us-ingest` to start the journey instead of asking for corrections that have nothing to be diffed against.

## Steps

1. **Collect.** Ask what the user changed or rejected in the test book (or diff the edited `.feature` files against the generated version if both exist). For each correction, capture: scenario ID, what was wrong, the corrected form, and **why** — the why is the valuable part.
2. **Classify.** Each correction is one of:
   - `business-rule` — the generation contradicted or missed a domain rule → candidate for `knowledge/`;
   - `style` — wording, structure, granularity preference → candidate for a project convention entry;
   - `one-off` — specific to this US, not generalizable → example only.
3. **Store examples.** Write each correction to `.qaia/feedback/examples/<US-ID>-<n>.md` with its classification and provenance.
4. **Propose promotions** (D22): only when the same pattern appears in **≥ 2** stored examples, or the user explicitly asks for immediate promotion (single-criterion — the "states a reusable rule" shortcut promoted everything and filtered nothing). Rules get stable IDs `BR-KB-nnn` (counter persisted in `rules.md` frontmatter); examples get `<US-ID>-<nnn>` with the counter in `examples/`. When a promoted rule shapes a generated scenario, the scenario carries a `# rule: BR-KB-nnn` comment and the coverage matrix lists applied rules — flagging sibling scenarios of the same AC for regeneration. ⚠ VALIDATION: on approval, hand the rule to `rag-build` (which handles contradiction checks and the index); record the promotion in `feedback/rules.md` with links to its source examples.
5. **Prune.** When promoting, mark source examples `promoted`; offer to archive examples older than ~6 months that never recurred (Q30 — the store must not grow unbounded).
6. **Close the loop.** Tell the user which promoted rules will affect future generations, and remind them the effect is measured — not guaranteed — via the gold set (T13/Q41: reapplication of raw examples is probabilistic; promoted rules are the reliable path).

## Guardrails

- Never promote without explicit validation, even for "obvious" corrections.
- Contradiction between a new correction and an existing rule → surface it (via `rag-build`'s arbitration), never store both silently (Q31).
- Feedback content follows knowledge rules: no secrets, no personal data, provenance mandatory.
