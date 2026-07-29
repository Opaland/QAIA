# 04-priorities — US-EVAL-004

| Condition | Impact | Probability | Priority | Rationale |
|---|---|---|---|---|
| AC1-C1 | 3 | 1 | **P2** (3) | If the lookup that surfaces the account's own question breaks, the entire recovery flow is unusable for everyone — impact 3 (total-feature-loss blast radius, same reasoning as US-EVAL-001's AC1-C1). Probability 1: a simple, mature `GET` lookup. |
| AC1-C2 (Q1) | 3 | 3 | **P1** (9) | Impact 3: an account-existence/question disclosure is a genuine information-leak class of defect on a security-rated target. Probability bumped to 3 because this condition is `[open]`, per this skill's own rule that open-flagged conditions score higher — **flag: rests on an unconfirmed proposed default; human arbitration decides whether the assumed "no disclosure" default is even the right behavior to assert against the real app.** |
| AC2-C1 | 3 | 2 | **P1** (6) | Impact 3: this is the feature's core success path — if broken, no legitimate user can ever recover their account. Probability 2: decision-table logic (three crossed conditions) carries more surface than a single check. |
| AC3-C1 | 3 | 2 | **P1** (6) | Impact 3: a wrong answer being accepted is an auth-bypass-class failure (account takeover), not a cosmetic bug. Probability 2: same decision-table surface as AC2-C1. |
| AC3-C2 (Q3) | 3 | 3 | **P1** (9) | Impact 3: unthrottled guessing directly enables brute-forcing a low-entropy security-question answer into a full account takeover. Probability bumped to 3 — `[open]`, per this skill's own rule. **Flag: no default was proposed either way (per `03-design.md`); this P1 rank reflects the risk of the *unknown*, not a confirmed defect — human arbitration needed.** |
| AC4-C1 | 2 | 2 | **P2** (4) | Impact capped at 2 — a rejected too-short password is a validation-strength issue, not itself an account-takeover path. Probability 2: off-by-one boundary bugs are a common, real defect class. |
| AC4-C2 | 2 | 2 | **P2** (4) | Same reasoning as AC4-C1, minimum-boundary accept side. |
| AC4-C3 | 2 | 2 | **P2** (4) | Same reasoning, maximum-boundary accept side. |
| AC4-C4 | 2 | 2 | **P2** (4) | Same reasoning, maximum-boundary reject side. |
| AC4-C5 | 2 | 1 | **P3** (2) | Impact 2 (a rejected mismatched-password submission is a UX/validation issue, not a security bypass on its own). Probability 1: simple, mature client-side equality check. Below the P1/P2 default-generation threshold — a real, generated-but-optional trade-off, not silently dropped (see `testbooks/synthesis.md`). |
| AC4-C6 (Q4) | 3 | 3 | **P1** (9) | Impact 3: if the backend does not independently re-enforce the password-shape rule, a UI-bypassing attacker could set a password outside the intended policy (a defense-in-depth gap on an auth-adjacent endpoint). Probability bumped to 3 — `[open]`, per this skill's own rule. **Flag: rests on the "backend re-validates" proposed default from `03-design.md`; unconfirmed, human arbitration needed.** |

⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) — no human override recorded;
all three `[open]`-driven P1 flags above (AC1-C2/Q1, AC3-C2/Q3, AC4-C6/Q4) are carried forward
as-is into `testbook-generate` rather than silently resolved or downgraded.

## Journey

| Step | Status |
|---|---|
| 04-priorities | done — scores above proposed, not yet arbitrated by a human |

## Skill evaluation — `prioritize` (`plugins/qaia-core/skills/prioritize/SKILL.md`)

- **Verdict**: `CONFORME`.
- **Preuve**: `SKILL.md` line 14 requires probability to score higher for "`[open]`-flagged
  conditions"; the table above bumps probability to 3 for exactly the three `[open]` conditions
  (AC1-C2, AC3-C2, AC4-C6) and only those, while non-open conditions (e.g. AC2-C1, AC3-C1) use a
  probability grounded in structural complexity (decision-table crossing), not open-status — the
  distinction the rule draws is preserved, not blurred. The Deliverable rule (line 23, "the
  one-line risk rationale... must reach the delivered book") is honored: every rationale above is
  written to survive verbatim into `testbook-generate`'s coverage matrix, not left as an internal
  note only this file would show.
- **Modification concrète proposée**: aucune.
