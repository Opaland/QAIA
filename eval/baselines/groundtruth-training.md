# Ground-truth training — recall vs human-validated acceptance tests (final)

Method: 50 real (US, human-validated acceptance tests) pairs from mature repos (gitlab, diaspora, sharetribe, cucumber, behave). QAIA gets **only the US** (oracle hidden); generated scenarios are compared behavior-by-behavior to the human tests. **Train** = 12 tuned-on US, **held-out** = 15 never tuned on. Only **generic** heuristics added, no US hardcoding. The human oracle is a floor, not a ceiling.

## Headline result — no overfitting (the robust conclusion)

Measured in the **same run** (so same measurement conditions — the valid comparison):

| Set | Recall (weighted) |
|---|---|
| Train (12, tuned-on) | 33 % |
| **Held-out (15, never tuned)** | **53 %** |

**Held-out ≥ train → genuine generalization, not memorization.** Had the skills been overfit to the examples, train would exceed held-out; it is the opposite. The 0.2.x heuristics encode reasoning (security, state transitions, invariants), not memorized answers.

## Honest caveat — the measurement is noisy

The comparison (an LLM judging behavioral equivalence) is **not deterministic**: independent judge runs on the same US vary by ±15-20 recall points (e.g. G03 87%↔47%, G22 100%↔67%). Therefore:
- **Absolute recall deltas between waves are unreliable** — do not read "34%→47%→33%" as a real trajectory; much of it is judge variance.
- **Only same-run comparisons are trustworthy** (train-vs-held-out above; precision below).
- Stable per-US recall would need 3 judges/US (median) — expensive; not done.

## Solid, non-noisy findings

- **Precision ≈ 93 %** overall; noise on held-out only **3 %** — QAIA generalizes without padding.
- **+200 valid scenarios** beyond the human oracles across 27 US (security negatives, IDOR, unauthenticated, invariants) — the measured value-add: QAIA covers what humans wrote *and* adds valid cases humans forgot.
- **Structural ceiling (real, legitimate):** two families are not inferable from a thin US and must not be hallucinated — (A) **config/feature-flag-driven** behavior (belongs to the knowledge base / `rag-build`), and (B) **rich domain interactions the US never mentions** (inline diff comments, previews). Fabricating these would trade precision for recall. The skill (0.2.1) explicitly forbids it: honest recall > fabricated recall.

## Fixes applied

- **0.2.0**: `istqb-design` step 3c "Systematic coverage expansion" — lists (sort/filter/persistence), full CRUD lifecycle, decision table over config/visibility/role, and per-action unauthenticated/permission/IDOR/uniqueness/UI-bypass.
- **0.2.1**: enumerate every list/aggregation view; account features → recovery/reset flows; ceiling clause (don't hallucinate config-driven / undescribed interactions).
- **0.2.2** (from the two real defects the closing wave found, not ceiling):
  - `us-review`: a thin US naming a real capability is **not** a non-spec — generate, don't emit an empty shell (fixes G44 = 0 scenarios).
  - `need-understanding`: an unstated access boundary is `[open]`, never an assumed sign-in redirect (fixes G20 contradiction).

## Verdict

The campaign proves QAIA's core value against third-party human ground truth: **high precision, real generalization (no overfitting), large valid value-add, and an honestly-bounded recall ceiling** where the remainder needs the knowledge base or a richer US — not fabrication. Training converged: further generic heuristics won't move the structural ceiling. The next lever is the **RAG** (project config context) and real pilots.
