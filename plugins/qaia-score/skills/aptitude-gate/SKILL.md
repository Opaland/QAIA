---
name: aptitude-gate
description: Decide release readiness of a QAIA test book or run - PASS / CONCERNS / FAIL / WAIVED - from the rubric score, hard coverage gates (AC, ADR 0001 negative-path), pending human arbitrations, and any execution results, recording the verdict and reasons in the standardized run manifest. Scores only - it judges readiness, it never edits test content. Use to gate a candidate before hand-off or CI.
---

# aptitude-gate — release-readiness verdict (A5)

Turns evidence into a single decision — **PASS / CONCERNS / FAIL / WAIVED** — and writes it to
the `gate` block of the standardized run manifest (`docs/OUTPUT-CONTRACT.md`, D39). It combines
the quality score (`testbook-score`), the hard coverage gates, the pending human arbitrations,
and — when present — the execution results. It **scores only**: it decides readiness and names
what blocks it; it never edits a scenario (guardrails in `../README.md`).

## Prerequisite

`.qaia/reports/<US-ID>/manifest.json`. Ideally the `gate.score` is already filled by
`testbook-score`; if not, run that first (or score inline using its rubric) — a verdict without
a quality score is only a hard-gate check, and the skill says so.

## Verdict rules (deterministic — apply in order)

Evaluate top to bottom; the **first** matching band is the verdict.

1. **FAIL** — any hard gate is broken (release-blocking):
   - an acceptance criterion is uncovered (`design.coverage.acCovered < acTotal`, rubric dim 2 = 0);
   - a **required** negative condition is uncovered (`reqNegCovered < reqNegTotal`, ADR 0001, dim 3 = 0);
   - a scenario contradicts the source US (dim 5 = 0 — plausible-but-wrong);
   - invalid Gherkin (dim 8 = 0) or no stable IDs / broken traceability (dim 7 = 0);
   - **any** rubric dimension scored 0;
   - an execution suite reports `failed > 0` while being presented as green.
2. **CONCERNS** — nothing blocks, but the candidate is not clean:
   - rubric total `< 16` (below the release gate) with no dimension at 0;
   - unresolved `openArbitrations` — `[open]` questions or `simulated` defaults still pending
     human decision (these **always** cap the verdict at CONCERNS until resolved);
   - a dimension dropped ≥ 1 versus a provided baseline (regression signal);
   - execution present with `blocked > 0`, or automation coverage materially below the book
     (`traceability.scenariosAutomated` ≪ `scenariosTotal`) when a run was expected.
3. **PASS** — rubric total `≥ 16`, no dimension at 0, all hard gates met, no pending
   arbitration, and (if execution is present) `failed = 0` and `blocked = 0`.
4. **WAIVED** — a human explicitly accepts a CONCERNS or FAIL candidate. **Never self-granted**:
   only a recorded human decision produces it. The underlying reasons stay listed; the waiver
   sits on top.

## Steps

1. **Read the manifest** — `design`, `execution` (if any), `gate.score`/`dimensions`, and
   `openArbitrations`. Note the `contract` major version; treat any absent field as absent, not
   as a failure (degraded mode).
2. **Apply the verdict rules** above, in order. Collect the concrete `reasons` — one line each,
   each citing the evidence (`"AC4 uncovered (matrix row 4)"`, `"Q5 open: cancellation < 4h"`,
   `"dim 3 = 1: req-neg AC4-C2 uncovered"`). A PASS lists the gates it cleared.
3. **Handle a waiver only on explicit human input.** If — and only if — the user states they
   accept the candidate despite the reasons, set `verdict: "WAIVED"` and record
   `waiver: { by, reason, at }`. Absent that, never write WAIVED. Never turn a FAIL into PASS.
4. **Write `gate`** into the manifest (merge, contract rule 2): `verdict`, keep `score`/
   `dimensions` from `testbook-score`, `reasons`, `waiver` (or `null`), `scoredBy:
   "qaia-score/aptitude-gate"`, `at`. Do **not** touch `design`, `execution`, or the
   human-owned `status`. A gate verdict never flips `status` — only a human validation does.
5. **Report** the verdict, the reasons, and the single most valuable next action (which fix
   clears the gate, or which arbitration to resolve) — then stop. The verdict is advice to a
   human, not an automatic release.

## Guardrails

- **The gate never releases anything.** It records a verdict; a human (or a CI rule they
  configured) acts on it. PASS is not a merge, WAIVED is not an approval — both are recorded
  judgments a person owns.
- **No self-waiver, no inflation, default low.** When the evidence is between two bands, choose
  the stricter one and say why. Pending `simulated`/`[open]` items keep it at CONCERNS.
- **Read-only over test content**; the only write is the manifest `gate` block. Name the
  blocking fix — hand it to `qaia-core`, never apply it.
- **Portable** — markdown + JSON in, JSON out; no network, no API key. Without file tooling,
  emit the `gate` object as a fenced block for the user to save.
