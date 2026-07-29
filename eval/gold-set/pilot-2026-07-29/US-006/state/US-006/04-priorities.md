---
stepsCompleted: [00-ingest, 01-review, 02-understanding, 03-design, 04-priorities]
lastStep: 04-priorities
lastSaved: 2026-07-29
---

# 04-priorities — risk-based scoring, US-006

Impact scale: **3** = unauthorized disclosure/destructive action (privacy/security breach in a
civic-tech reporting context — a real safety concern for reporters/sources), **2** = wrongful
denial of legitimate access or a core-but-non-sensitive function, **1** = cosmetic/low-stakes.
Probability scale: **2** = default (moderate role x status crossing logic), **3** = an `[open]`
item bumps probability of the design intent itself being wrong (per `prioritize` guardrail: only
`[open]`, not every `[assumption]`, is bumped), **1** = simple, single-condition, low-complexity
rule. Priority = impact x probability -> **P1 >= 6 / P2 = 3-4 / P3 <= 2**. No git-history signal
used (no target repo path was named for this session — guardrail respected: skipped, not
defaulted to zero-risk).

| Condition | Impact | Prob. | Score | Priority | Rationale |
|---|---|---|---|---|---|
| AC2-C1 | 2 | 1 | 2 | P3 | Baseline positive (published post visible to anonymous) — core function but a single, simple, clearly-stated rule with no crossing logic — waived from default generation scope. |
| AC2-C2 | 3 | 2 | 6 | P1 | Unauthorized disclosure of a non-public report to an anonymous viewer. |
| AC2-C3 | 3 | 2 | 6 | P1 | Same, for an unrelated basic-user viewer. |
| AC2-C4/C5/C6 (merged) | 2 | 2 | 4 | P2 | Wrongful denial to legitimate viewers (owner/manager/admin) — functional, not a breach. |
| AC2-C7 | 2 | 1 | 2 | P3 | Core creation path, but simple, single rule, no role-crossing complexity — waived from default generation scope. |
| AC2-C8 | 3 | 2 | 6 | P1 | Same disclosure risk as C2/C3, generalized to any non-published status (`@low-confidence`, Q8). |
| AC2-C9a | 3 | 3 | 9 | P1 | Disclosure risk + `[open]` Q1 bumps probability (design intent itself uncertain). |
| AC2-C9b | 3 | 3 | 9 | P1 | Same, list-exclusion side of Q1. |
| AC3-C1 | 3 | 2 | 6 | P1 | Field-level disclosure of a specifically locked (presumably sensitive) field. |
| AC3-C2/C3 (merged) | 2 | 2 | 4 | P2 | Legitimate manager/admin access to locked fields — functional correctness. |
| AC4-C1/C2 (merged) | 3 | 2 | 6 | P1 | Identity disclosure (real name/email) — the AC's own headline privacy concern. |
| AC4-C3/C4 (merged) | 2 | 2 | 4 | P2 | Legitimate manager/admin identity access. |
| AC4-C5 | 2 | 2 | 4 | P2 | Self-view exception (`@low-confidence`, Q4) — informational correctness, not a breach if wrong (worst case: owner sees own data, already theirs). |
| AC5-C1 | 3 | 2 | 6 | P1 | Private-mode anonymous list-access breach. |
| AC5-C2 | 3 | 2 | 6 | P1 | Private-mode anonymous view-access breach. |
| AC5-C3 | 3 | 2 | 6 | P1 | Private-mode anonymous registration breach. |
| AC5-C4 | 3 | 2 | 6 | P1 | Private-mode anonymous creation breach (`@low-confidence`, Q5). |
| AC5-C5 | 2 | 2 | 4 | P2 | Authenticated-role access retained under private mode (`@low-confidence`, Q10) — functional regression risk, not a breach. |
| AC5-C6 | 2 | 2 | 4 | P2 | Registration-toggle self-service block — functional, moderate crossing logic. |
| AC5-C7 | 2 | 3 | 6 | P1 | `[open]` Q9 bumps probability — genuine uncertainty on admin-created-account exception. |
| AC6-C1 | 1 | 1 | 1 | P3 | Single-condition ownership check, no crossing logic, no disclosure risk — waived from default generation scope. |
| AC6-C2/C3 (merged) | 3 | 2 | 6 | P1 | Unauthorized destructive action — irrecoverable media loss for the true owner or for an unidentified uploader with no recourse. |
| AC6-C4 | 2 | 2 | 4 | P2 | Admin capability over unowned media — functional correctness of the documented exception. |
| AC6-C5 | 2 | 2 | 4 | P2 | Admin capability over any owned media (`@low-confidence`, Q7) — functional, not a breach (admin is already fully privileged per AC1). |
| AC6-C6 | 3 | 2 | 6 | P1 | Unauthorized destructive action by a manager beyond their stated permission scope (`@low-confidence`, Q6). |

**P1: 14 conditions/blocks. P2: 8 conditions/blocks. P3 (waived from default generation scope):
3 conditions (AC2-C1, AC2-C7, AC6-C1).**

## Arbitration record

⚠ VALIDATION: `simulated: accepted-as-is` for every row above — no human override this pass (a
genuine first pilot run, no prior arbitration history to diverge from). Every score built on an
`[assumption]`/`[open]` item is flagged in the Rationale column and carries `@low-confidence`
downstream, per the deliverable rule (rubric dim. 9) — this table's one-line rationale is copied
verbatim into `testbooks/US-006/coverage-matrix.md`.

No regulated-context (D2) override applied — this is a civic-tech deployment, not a
formally-regulated domain, though the impact-3 assignments already reflect its real
safety-adjacent stakes without needing that override.

## Checkpoint

Step `04-priorities` = done. Next step: `testbook-generate` — scope will default to P1+P2 in
full; the 3 P3 conditions above are waived and listed, not silently dropped.
