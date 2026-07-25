---
name: prioritize
description: Risk-based prioritization of derived test conditions - the skill proposes probability x impact scores, the human arbitrates. Fifth step of the QAIA journey, before test book generation.
---

# prioritize — risk-based, human-arbitrated

Follow the shared contract in `../README.md`. Prerequisite: `03-design.md` (else offer `istqb-design`). Risk-based testing needs human inputs (Q48): **the skill proposes, the user decides.**

## Steps

1. **Propose scores.** For each test condition of `03-design.md`, propose:
   - **Impact** (1-3): consequence if this behavior fails in production — safety/regulatory/data-loss = 3, degraded service = 2, cosmetic = 1. Use `knowledge/` (criticality notes, anomaly history) when available; cite what you used.
   - **Probability** (1-3): likelihood of a defect — new/complex/concurrent logic and `[open]`-flagged conditions score higher; stable well-understood rules lower.
   - Priority = impact × probability → **P1 (≥6) / P2 (3-4) / P3 (≤2)**.
2. **Show your reasoning compactly.** One table: condition, impact, probability, priority, one-line rationale. Flag every score based on an `[assumption]` or `[open]` item.
3. ⚠ VALIDATION: the user adjusts scores (their business knowledge overrides yours), or approves. Record each override with the user's stated reason — that reason is knowledge (offer `rag-build` capture when reusable).
4. **Checkpoint.** Write `04-priorities.md`: the arbitrated table. Update `journey.md`. Next step: `testbook-generate` — tell the user generation will cover P1 and P2 fully; P3 coverage is their call (quota trade-off, Q22).

## Deliverable rule (rubric dim. 9)

The **one-line risk rationale of every priority assignment must reach the delivered book** — `testbook-generate` copies it into the coverage matrix (rationale column) and the synthesis, together with the list of assignments needing human arbitration. A priority whose rationale only lives in `04-priorities.md` (an internal state file the reviewer never sees) counts as unjustified.

## Guardrails

- Never present your scores as final — the arbitration step is the point of this skill.
- A regulated-context project (project niche, D2) treats traceability-relevant conditions as impact 3 by default; say so when applying it.
