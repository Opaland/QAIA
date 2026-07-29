---
stepsCompleted: [00-ingest, 01-review, 02-understanding, 03-design, 04-priorities]
lastStep: 04-priorities
lastSaved: 2026-07-29
---

# 04-priorities — US-EVAL-002

| Condition | Impact | Probability | Priority | Rationale |
|---|---|---|---|---|
| AC1-C1 | 3 | 1 | **P2** (3) | If add-to-cart itself is broken, no purchase can ever happen — total-service-loss blast radius (impact 3) despite this being simple, mature CRUD (probability 1). |
| AC1-C2 | 2 | 2 | **P2** (4) | A bad-request-handling gap, not a security/data-loss path — impact 2. Decision-table branch on `product_id` validity carries moderate bug surface — probability 2. |
| AC1-C3 (Q3) | 2 | 2 | **P2** (4) | Same impact class as AC1-C2. Probability 2, and flagged: this condition is built on an `[assumption]` (the exact quantity floor is not confirmed). |
| AC2-C1 | 3 | 2 | **P1** (6) | The core authenticated-revenue path — impact 3. Multi-step, multi-axis decision-table logic (auth + ownership + cart state) — probability 2. |
| AC2-C2 | 3 | 2 | **P1** (6) | An unauthenticated caller creating an invoice is an auth-bypass-class failure — impact 3. Probability 2, same decision-table surface as AC2-C1. |
| AC2-C3 (Q1) | 2 | 2 | **P2** (4) | An empty-cart checkout is a data-integrity gap (a phantom/zero-line order), not by itself an access-control failure — impact capped at 2. Built on an `[assumption]`, probability 2. |
| AC2-C4 (Q6) | 3 | 3 | **P1** (9) | Impact 3 — a cross-tenant/IDOR checkout is an access-control failure with potential financial impact (charging/shipping against another customer's cart). Probability bumped to 3 per this skill's own rule that `[open]`-flagged conditions score higher — **flag: this P1 rank rests on an unconfirmed proposed default (refused, exact error shape undecided); human arbitration is what actually decides the right behavior.** |
| AC3-C1 | 3 | 2 | **P1** (6) | The core guest-revenue path — impact 3, same reasoning as AC2-C1 applied to the guest endpoint. Probability 2. |
| AC3-C2 (Q4) | 2 | 2 | **P2** (4) | A validation-refusal gap, not an access-control path — impact 2. Built on an `[assumption]`, probability 2. |
| AC3-C3 | 2 | 2 | **P2** (4) | A format-validation gap — impact 2 (grounded by the RFC 5322 oracle, not a fabricated case, but still not a security-critical path on its own). Probability 2 — new validation surface, but backed by a cited standard rather than guesswork. |
| AC4-C1 (Q5) | 2 | 3 | **P1** (6) | Impact 2 — a wrong initial status is a workflow-correctness bug, not by itself a security/money-loss event. Probability bumped to 3 per the `[open]`-flag rule — **flag: rests on an unconfirmed proposed default (`AWAITING_FULFILLMENT`); human arbitration required.** |

⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) — no human override
recorded; the AC2-C4/Q6 and AC4-C1/Q5 flags above are carried forward as-is into
`testbook-generate` rather than silently resolved.

## Journey

| Step | Status |
|---|---|
| 04-priorities | done — scores above proposed, not yet arbitrated by a human |

## Skill evaluation — `prioritize`

- **Skill evaluated**: `plugins/qaia-core/skills/prioritize/SKILL.md`.
- **Input**: `03-design.md` above (11 test conditions across 4 ACs).
- **Output**: this file.
- **Verdict**: **CONFORME.**
- **Evidence**: `SKILL.md` line 17 requires flagging "every score based on an `[assumption]` or
  `[open]` item" — every condition row above whose design-time tag included `[assumption]`/`[open]`
  carries a rationale sentence naming that basis (e.g. AC2-C4, AC4-C1 explicitly call out the
  probability bump and the pending arbitration), matching line 14's "new/complex/concurrent logic
  and `[open]`-flagged conditions score higher" rule literally applied to both `[open]` rows (Q6,
  Q5) via the bump to probability 3. No git-history signal was used (line 15) — correctly absent,
  since no target repo path was named for this session (self-hosting the app is out of scope per
  `docs/DEMO-TARGETS.md`'s license caveat) and the rule requires the user to explicitly name one.
- **Modification proposed**: none.
