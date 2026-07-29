# 04-priorities — US-EVAL-001

| Condition | Impact | Probability | Priority | Rationale |
|---|---|---|---|---|
| AC1-C1 | 3 | 1 | **P2** (3) | If the core login gate rejects valid credentials, the entire storefront is unreachable — total-service-loss blast radius justifies impact 3 despite this being simple, mature, well-understood logic (probability 1). |
| AC2-C1 | 3 | 2 | **P1** (6) | A locked account reaching the catalog is an access-control failure, not a cosmetic bug — impact 3. State-check logic (locked vs. active) is more complex than a plain credential match, probability 2. |
| AC3-C1 | 3 | 2 | **P1** (6) | An unknown username being let through is an auth-bypass-class failure — impact 3. Decision-table logic (username-match branch) carries more surface for bugs than the single happy path, probability 2. |
| AC3-C2 | 3 | 2 | **P1** (6) | Same reasoning as AC3-C1, for the password-mismatch branch of the same decision table. |
| AC3-C3 (Q2) | 2 | 2 | **P2** (4) | Impact capped at 2 (a UX/validation gap, not a confirmed auth-bypass path) since this condition is built on an `[assumption]` — flagged, not a security-critical path on its own. |
| AC2-C2 (Q3) | 3 | 3 | **P1** (9) | Impact 3 (potential auth-bypass/information-disclosure ambiguity). Probability bumped to 3 because this condition is `[open]`, per this skill's own rule that open-flagged conditions score higher — **flag: this P1 rank rests on an unconfirmed proposed default, human arbitration is what actually decides whether this is even the right behavior to assert.** |

⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) — no human override recorded;
the AC2-C2/Q3 flag above is carried forward as-is into `testbook-generate` rather than silently
resolved.

## Journey

| Step | Status |
|---|---|
| 04-priorities | done — scores above proposed, not yet arbitrated by a human |
