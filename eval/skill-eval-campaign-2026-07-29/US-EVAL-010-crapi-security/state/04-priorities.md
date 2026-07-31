# 04-priorities — US-EVAL-010

| Condition | Impact | Probability | Priority | Rationale |
|---|---|---|---|---|
| AC1-C1 | 1 | 1 | P3 (1) | Owner-reads-own-vehicle happy path — the simplest, best-trodden code path on this endpoint; failure here would be a basic functional break, not a security defect. |
| AC2-C1 | 3 | 3 | **P1 (9)** | Impact 3: this is the documented, canonical BOLA/IDOR leak (crAPI's own Challenge 1) — an unauthorized user tracking another user's real-time-or-last-known physical location is a privacy/stalking-adjacent safety risk, not a cosmetic defect. Probability 3: the source itself states this behavior is *currently* the deliberately-vulnerable implementation's actual output (a `200` leak today) — this is not a speculative risk, it is a confirmed-present defect class in the un-patched target, the highest-confidence probability score this book contains. |
| AC2-C2 | 2 | 2 | **P2 (4)** | Impact 2: the specific denial status code (`404` vs `403`) is a secondary correctness question — even a "wrong" code still denies the data (AC2-C1 already covers the impactful part). Probability 2: rests on `[assumption]` Q1 (`02-understanding.md`'s Triple-AC pass) — per this skill's own rule, an assumption-flagged condition scores higher than a stable, fully-sourced one. |
| AC3-C1 | 3 | 2 | **P1 (6)** | Impact 3: a fully unauthenticated request succeeding would bypass every other control at once (strictly worse than AC2's ownership-only bypass), matching the safety class of a full BOLA leak. Probability 2 (not 3): the source confirms *a* different endpoint lacks auth entirely (Challenge 14), which is evidence this class of defect exists in the project, but does not confirm it is *this specific* endpoint — kept one notch below AC2-C1's fully-confirmed probability rather than inferring project-wide auth weakness onto an endpoint the source never names in that challenge. |
| AC3-C2 | 2 | 2 | **P2 (4)** | Impact 2: an invalid/expired (as opposed to fully absent) token bypassing the check is a narrower attack surface than AC3-C1's "no token at all," since it requires the attacker to already hold *some* stale credential material. Probability 2: same reasoning class as AC3-C1, one notch down for the narrower precondition. |
| AC4-C1 | 2 | 2 | **P2 (4)** | Impact 2: confirms the anti-disclosure convergence (a guessed/nonexistent GUID and a real other-owner's GUID must look the same to the caller) — a real hardening property, though its failure is less severe than AC2-C1's direct data leak. Probability 2: rests on `[assumption]` Q3, same bump rule as AC2-C2. |

⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) — no human override recorded;
the AC3-C1 probability call (deliberately not inflated to match AC2-C1's fully-confirmed score,
despite Challenge 14 existing as adjacent evidence) is carried forward as-is, flagged for human
review rather than silently resolved either direction.

**Scope decision for `testbook-generate` (Q22 quota trade-off)**: default scope is **P1 + P2 in
full** (5 conditions: 2 P1, 3 P2); the 1 P3 condition (`AC1-C1`) is listed above with its rationale
but **not** generated into a scenario in this run — a human call per this skill's own step 4,
deferred here since no human is available to override the default (same convention as
`US-EVAL-003`/`US-EVAL-006`). Unlike `US-EVAL-006`'s risk profile (concentrated in one AC, mostly
P3), this US-slice is concentrated at the **top**: 5 of 6 conditions clear the P1/P2 bar, an honest
reflection of a security-authorization slice where nearly every condition is a refusal path with
real consequence if it fails.

## Journey

| Step | Status |
|---|---|
| 04-priorities | done — scores above proposed, not yet arbitrated by a human |

## Skill evaluation — `prioritize` (`plugins/qaia-core/skills/prioritize/SKILL.md`)

See separate evaluator pass (spawned after this checkpoint).
