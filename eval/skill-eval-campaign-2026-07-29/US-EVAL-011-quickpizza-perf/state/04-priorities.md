---
stepsCompleted: [00-ingest, 01-review, 02-understanding, 03-design, 04-priorities]
lastStep: 04-priorities
lastSaved: 2026-07-30
---

# 04-priorities — US-EVAL-011

| Condition | Impact | Probability | Priority | Rationale |
|---|---|---|---|---|
| AC1-C1 | 2 | 1 | **P3** (2) | The happy-path recommendation is simple, well-documented input handling (fields and defaults are explicitly listed in `pkg/http/http.go`) — probability 1. Impact 2 (a demo app's primary interaction breaking is visible immediately, but no regulated data sits behind it, capped below 3). |
| AC1-C2 | 2 | 1 | **P3** (2) | Same reasoning as AC1-C1, applied to the defaults-applied partition — the defaults themselves are documented, not inferred. |
| AC1-C3 (Q1) | 2 | 3 | **P1** (6) | Impact 2 — an auth-boundary miss on a public demo app with no PII/health/money behind it is a real but non-regulated-data risk, capped below 3. Probability bumped to 3 per this skill's own rule that `[open]`-flagged conditions score higher — **flag: this rank rests on an unconfirmed proposed default (accepted); real behavior could be the opposite (refused), human arbitration required.** |
| AC2-C1 | 3 | 2 | **P1** (6) | Impact 3 — this US exists specifically to exercise QuickPizza as a load-test target; a latency regression silently passing functional tests while breaching the project's own stated p95 threshold is the exact failure mode this target was picked to catch. Probability 2 — a real, plausible risk class for any web service under load, not exotic. |
| AC2-C2 | 3 | 2 | **P1** (6) | Same reasoning as AC2-C1, applied to the p99 tail-latency threshold — tail-latency regressions are a distinct and common failure mode from median/p95 regressions. |
| AC2-C3 | 3 | 2 | **P1** (6) | Impact 3 — a rising error rate under load (timeouts, 5xxs) is a service-availability failure, the single most direct signal a load test exists to catch. Probability 2. |
| AC3-C1 (Q4) | 2 | 2 | **P2** (4) | Impact 2 — a data-integrity/usability gap (an inverted toppings range), not a security or availability path. Built on an `[assumption]`, probability 2. |
| AC3-C2 (Q5) | 2 | 2 | **P2** (4) | Same class as AC3-C1, applied to a negative calorie cap. `[assumption]`, probability 2. |
| AC3-C3 (Q6) | 2 | 3 | **P1** (6) | Impact 2 — an over-length name is a data-integrity/storage-hygiene gap, not itself a security path (capped below 3). Probability bumped to 3 per the `[open]`-flag rule — **flag: this rank rests on an unconfirmed proposed default (refused) and an unknown numeric bound; human arbitration required.** |

⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) — no human override
recorded. The AC1-C3/Q1 and AC3-C3/Q6 flags above are carried forward as-is into
`testbook-generate` rather than silently resolved. **This run's condition set lands 5 of 9
conditions at P1** (AC1-C3, AC2-C1, AC2-C2, AC2-C3, AC3-C3) — a P1-heavy distribution driven by two
structurally distinct forces: (a) AC2's three performance-threshold conditions are impact-3 by this
US's own reason for existing (a load-test target's whole point is that a latency/error-rate
regression matters), and (b) two `[open]`-flagged conditions (Q1, Q6) get the probability bump this
skill's own rule requires — not a scoring inflation, a direct, cited application of the rule to a
condition set that happens to carry more open items than the AC1/AC3 rows.

## Journey

| Step | Status |
|---|---|
| 04-priorities | done — scores above proposed, not yet arbitrated by a human |

## Skill evaluation — `prioritize`

- **Skill evaluated**: `plugins/qaia-core/skills/prioritize/SKILL.md`.
- **Input**: `03-design.md` above (9 test conditions across 3 ACs, one AC entirely performance-typed).
- **Output**: this file.
- **Verdict**: **CONFORME.**
- **Evidence**: `SKILL.md` line 17 requires flagging "every score based on an `[assumption]` or
  `[open]` item" — every condition row whose design-time tag included `[assumption]`/`[open]`
  carries a rationale sentence naming that basis, and the two `[open]` rows (AC1-C3, AC3-C3) each
  carry an explicit human-arbitration flag matching line 14's "`[open]`-flagged conditions score
  higher" rule. AC2's three performance conditions are consistently scored impact 3 with a
  rationale tied directly to this US's own stated purpose (a load-test-catalog target), not a
  reflexive default. No git-history signal was used (line 15) — correctly absent, no target repo
  path was named for this session.
- **Modification proposed**: none.
