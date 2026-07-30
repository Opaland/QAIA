---
stepsCompleted: [00-ingest, 01-review, 02-understanding, 03-design, 04-priorities]
lastStep: 04-priorities
lastSaved: 2026-07-30
---

# 04-priorities — US-EVAL-009

| Condition | Impact | Probability | Priority | Rationale |
|---|---|---|---|---|
| AC1-C1 | 3 | 1 | **P2** (3) | If a single add doesn't compute the correct row total, nothing downstream (subtotal, checkout) can be trusted — money-correctness impact 3. Probability 1: simple, well-understood classic e-commerce path. |
| AC1-C2 (Q1) | 3 | 2 | **P1** (6) | A wrongly-modeled repeat add (duplicate row summed correctly by coincidence, but the row model itself wrong) is a silent money-correctness defect — impact 3. Probability 2, built on an `[assumption]`. |
| AC2-C1 | 1 | 1 | **P3** (1) | The empty-cart message/subtotal is directly stated by the source (observed live, not inferred) — cosmetic/informational impact 1, probability 1: lowest-risk condition in this set precisely because it is the one most directly confirmed. |
| AC2-C2 | 3 | 1 | **P2** (3) | Multi-item subtotal arithmetic is the core money-correctness guarantee of the whole cart — impact 3. Probability 1: plain addition over two confirmed prices, low complexity. |
| AC2-C4 (Q6) | 2 | 2 | **P2** (4) | A currency-format/rounding gap is a display/data-integrity issue, not itself an access/safety failure — impact 2. Probability 2, `[assumption]`, no source price forces a real rounding edge case. |
| AC2-C5 | 2 | 2 | **P2** (4) | Cart contents vanishing on navigation is a workflow-breaking data-loss gap for the shopper — impact 2. Probability 2, `[assumption]`. |
| AC3-C1 | 3 | 1 | **P2** (3) | Removing one row must not corrupt the money total of what remains — impact 3 (same class as AC2-C2). Probability 1: mirror of the addition case, comparable complexity. |
| AC3-C2 (Q5) | 1 | 1 | **P3** (1) | Convergence to the already-tested empty state — impact 1, probability 1, lowest-risk of the state-transition conditions. |
| AC3-C3 (Q4) | 1 | 2 | **P3** (2) | An idempotent no-op edge case (double-submit) — impact 1 (robustness/UX, not money or access), probability 2, `[assumption]`. |
| AC3-C4 (Q3) | 2 | 3 | **P1** (6) | Impact 2 — letting an out-of-stock item reach checkout is an inventory/business-policy integrity risk (overselling), not itself an access-control breach, so capped below the impact-3 access-boundary conditions. Probability bumped to 3 per this skill's own rule that `[open]`-flagged conditions score higher — **flag: this P1 rank rests on an unconfirmed proposed default (checkout stays available); the opposite (checkout blocked for out-of-stock items) is an equally plausible real e-commerce policy, human arbitration required.** |
| AC3-C5 (Q7) | 3 | 3 | **P1** (9) | Impact 3 — one shopper's cart being visible or mutable from a second, unrelated guest session is a cross-session access-control breach (IDOR-class), the most severe failure mode this US can exhibit. Probability bumped to 3 per the `[open]`-flag rule — **flag: this P1 rank rests on an unconfirmed proposed default (session isolation enforced); the exact session-binding mechanism was never independently confirmed live, human arbitration required.** |

⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) — no human override
recorded; the AC3-C4/Q3 and AC3-C5/Q7 flags above are carried forward as-is into
`testbook-generate` rather than silently resolved. **AC2-C1, AC3-C2 and AC3-C3 land at P3**
(default scope excludes them from the generated book below) — none of the three is a `[req-neg]`
condition (per `03-design.md`'s corrected tagging: none of their proposed outcomes is a
refusal/error/denial), so none of them exercises `testbook-generate`'s P3-`[req-neg]`-waiver rule
directly; they are ordinary P3 deferrals under the default P1+P2 scope, cited here and in the
coverage matrix rather than silently dropped.

## Journey

| Step | Status |
|---|---|
| 04-priorities | done — scores above proposed, not yet arbitrated by a human |

## Skill evaluation — `prioritize`

- **Skill evaluated**: `plugins/qaia-core/skills/prioritize/SKILL.md`.
- **Input**: `03-design.md` above (11 test conditions across 3 ACs).
- **Output**: this file.
- **Verdict**: **CONFORME.**
- **Evidence**: `SKILL.md` line 17 requires flagging "every score based on an `[assumption]` or
  `[open]` item" — every condition row above whose design-time tag included `[assumption]`/`[open]`
  carries a rationale sentence naming that basis, and the two `[open]` rows (AC3-C4, AC3-C5) each
  carry an explicit human-arbitration flag matching line 14's "`[open]`-flagged conditions score
  higher" rule. AC2-C1's probability 1 is explicitly justified by line 14's own distinction between
  an `[assumption]` and a directly-source-stated behavior (the empty-cart state was observed live,
  not inferred) — the same reasoning pattern US-EVAL-005's AC3-C2 established, correctly reapplied
  here to a structurally different condition rather than copied mechanically. No git-history signal
  was used (line 15) — correctly absent, since no target repo path was named for this session (the
  target is a shared public demo, not a local repository).
- **Modification proposed**: none.
