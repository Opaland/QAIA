# flaky-detect — origin and evidence trail

Project history, not part of the skill's instructions. Read this only if you need to know where
the skill came from or how the claim "this defect class is real, not hypothetical" is supported —
nothing here changes how the skill is run.

## Why the skill exists

Flaky detection was an identified gap versus the competitive landscape
(`docs/COMPETITIVE-ANALYSIS.md`, issue #34, priority P1). It is also a defect class QAIA's own
automation has hit for real:

- `examples/medibook/` — 1 finding: shared mutable state raced by parallel workers, fixed with
  `workers: 1`.
- `examples/expense-demo/` — a 2nd instance (decision D68).

## Accuracy correction (external audit, 2026-07-26)

An earlier version of this note overstated the medibook count as "3 findings". The flake-hunt
session did surface 3 distinct defects (`docs/KANBAN.md`, Sprint 5 entry), but only the
shared-state race is an instance of *this skill's* defect class — pass/fail variance across runs
of unchanged code. The other two (a hardcoded Chromium path, a visual-baseline tolerance gap) are
different defect classes entirely, found in the same session but not flakiness.

Reported accurately rather than inflated. The value of catching this class is proven either way.
