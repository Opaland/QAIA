---
stepsCompleted: [00-ingest, 01-review, 02-understanding, 03-design, 04-priorities]
lastStep: 04-priorities
lastSaved: 2026-07-29
---

# 04-priorities — US-EVAL-005

| Condition | Impact | Probability | Priority | Rationale |
|---|---|---|---|---|
| AC1-C1 | 3 | 1 | **P2** (3) | If appointment creation itself is broken, no scheduling can happen at all — total-service-loss blast radius (impact 3) despite this being simple, mature CRUD (probability 1). |
| AC1-C2 | 2 | 2 | **P2** (4) | A duration-boundary gap is a workflow/data-integrity defect, not an access/safety failure — impact 2. Built on an `[assumption]`, probability 2. |
| AC1-C3 | 2 | 2 | **P2** (4) | Same impact class as AC1-C2 (a scheduling-data-integrity gap). Built on an `[assumption]` with a plausible legitimate exception (staff backfill), probability 2. |
| AC1-C4 (Q1) | 3 | 3 | **P1** (9) | Impact 3 — a silently double-booked provider is a real clinical-scheduling-safety risk (two patients competing for one slot, missed/delayed care), not merely cosmetic. Probability bumped to 3 per this skill's own rule that `[open]`-flagged conditions score higher — **flag: this P1 rank rests on an unconfirmed proposed default (refused); real EHR practice often intentionally allows overbooking, so human arbitration is what actually decides correct behavior here.** |
| AC2-C1 | 3 | 2 | **P1** (6) | An unauthenticated caller creating an appointment is an auth-bypass-class failure on a health-record system — impact 3. Probability 2, directly-documented decision-table surface. |
| AC2-C2 (Q7) | 3 | 2 | **P1** (6) | Same auth-bypass class as AC2-C1 (an expired/revoked token behaving as if valid) — impact 3. Probability 2; built on an `[assumption]` of standard OAuth2 behavior, not independently confirmed for this endpoint. |
| AC2-C3 (Q6) | 3 | 3 | **P1** (9) | Impact 3 — a cross-site/cross-tenant booking against a patient record outside the caller's authorized scope is a health-data access-control breach (IDOR-class), among the most severe failure modes in a medical-record system. Probability bumped to 3 per the `[open]`-flag rule — **flag: this P1 rank rests on an unconfirmed proposed default (refused); whether site-scoping is even enforced at all is genuinely open, human arbitration required.** |
| AC2-C4 (Q9) | 2 | 3 | **P1** (6) | Impact 2 — an information-disclosure nuance (which check's detail leaks when both auth and validation fail together), not itself an unauthorized-creation event, so capped below AC2-C3's impact. Probability bumped to 3 per the `[open]`-flag rule — **flag: rests on an unconfirmed proposed default (401 wins, no disclosure); human arbitration required.** |
| AC3-C2 | 2 | 1 | **P3** (2) | A validation-refusal gap on a missing required field — impact 2 (a data-integrity/usability gap, not a security path). Probability 1: this behavior is **directly stated by the source** (`validationErrors` is the documented error channel for exactly this case), not an inferred `[assumption]`, so the defect risk is low — the documentation, not guesswork, already pins the expected behavior. |
| AC3-C3 (Q3) | 2 | 2 | **P2** (4) | A reference-validation gap (nonexistent facility) — impact 2. Built on an `[assumption]`, probability 2. |
| AC3-C4 (Q2) | 2 | 2 | **P2** (4) | Same class as AC3-C3, applied to a nonexistent patient reference — impact 2, probability 2, `[assumption]`. |
| AC3-C5 | 2 | 2 | **P2** (4) | A format-validation gap on `pc_eventDate` — impact 2 (grounded by the ISO 8601 oracle, not a fabricated case, but still not itself a security-critical path). Probability 2 — new validation surface, backed by a cited standard rather than guesswork. |
| AC3-C6 | 2 | 2 | **P2** (4) | Same reasoning as AC3-C5, applied to `pc_startTime`'s format. |

⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) — no human override
recorded; the AC1-C4/Q1, AC2-C3/Q6 and AC2-C4/Q9 flags above are carried forward as-is into
`testbook-generate` rather than silently resolved. **AC3-C2 lands at P3** (default scope excludes
it from the generated book below) — this is a deliberately different outcome from every prior run
in this campaign (all of which had every `[req-neg]` condition at P1/P2): it exercises
`testbook-generate`'s own rule that a `[req-neg]` condition deferred to P3 by the default scope is
a standing, cited waiver, not a silent gate violation, provided it still appears in the coverage
matrix — the exact distinction D119 (US-EVAL-003) found and fixed a real gap in.

## Journey

| Step | Status |
|---|---|
| 04-priorities | done — scores above proposed, not yet arbitrated by a human |

## Skill evaluation — `prioritize`

- **Skill evaluated**: `plugins/qaia-core/skills/prioritize/SKILL.md`.
- **Input**: `03-design.md` above (13 test conditions across 3 ACs).
- **Output**: this file.
- **Verdict**: **CONFORME.**
- **Evidence**: `SKILL.md` line 17 requires flagging "every score based on an `[assumption]` or
  `[open]` item" — every condition row above whose design-time tag included `[assumption]`/`[open]`
  carries a rationale sentence naming that basis, and the three `[open]` rows (AC1-C4, AC2-C3,
  AC2-C4) each carry an explicit human-arbitration flag matching line 14's "`[open]`-flagged
  conditions score higher" rule. AC3-C2's probability 1 (rather than a reflexive 2) is explicitly
  justified by line 14's own distinction between an `[assumption]` and a directly-source-stated
  behavior — a case this run's condition set happens to contain that the prior four runs did not,
  correctly reasoned rather than defaulted. No git-history signal was used (line 15) — correctly
  absent, since no target repo path was named for this session.
- **Modification proposed**: none.
