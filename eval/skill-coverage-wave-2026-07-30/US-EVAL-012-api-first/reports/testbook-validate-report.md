# testbook-validate — audit report, RAD-PUBOBJ

Skill: `plugins/qaia-core/skills/testbook-validate/SKILL.md`
Audited: `testbooks/restful-api-dev-public-objects.feature` (27 scenario blocks)
Source fed: `state/00-source.md` · ACs fed: `AC1..AC11`
Date: 2026-07-30

---

## Step 2 — Deterministic structural pass (RUN, not simulated)

**Command actually executed** (from the repo root of the worktree):

```
python eval/tools/structural_score.py \
  eval/skill-coverage-wave-2026-07-30/US-EVAL-012-api-first/testbooks/restful-api-dev-public-objects.feature \
  --source eval/skill-coverage-wave-2026-07-30/US-EVAL-012-api-first/state/00-source.md \
  --acs AC1,AC2,AC3,AC4,AC5,AC6,AC7,AC8,AC9,AC10,AC11
```

**Raw JSON output, pasted verbatim:**

```json
{
  "file": "restful-api-dev-public-objects.feature",
  "scenarios": 27,
  "readability": 25.0,
  "completeness": 21.8,
  "coherence": 20.0,
  "traceability": 25.0,
  "penalties": {
    "markers": 0,
    "sniffer": 0,
    "redundancy": 0
  },
  "score": 92,
  "gate": "PASS",
  "forced_stop": false,
  "findings": [],
  "tag_audit": {
    "missing_priority_tag": [],
    "technique_tag_violations": [],
    "negative_scenarios": 9,
    "non_smoke_scenarios": 26,
    "negative_ratio_recomputed_pct": 34.6
  }
}
```

**The sniffer was NOT run blind.** `--source` and `--acs` were both passed (the skill requires the
command be recorded, and requires the report to say so when they are omitted — they were not).
`sniffer: 0` is therefore a source-checked zero: no technical literal in the book is untraceable to
the captured contract.

### Reading the numbers honestly

- **`completeness` 21.8 / 30 = 8 of 11 ACs.** Not 9. AC9 and AC11 are unmistakably uncovered (P3,
  deliberately deferred). The **third** miss is **AC10**: its only scenario,
  `@QAIA-RAD-PUBOBJ-026`, fails the script's `covers()` test because its `Then` — *"no API payload
  is served over the unencrypted connection"* — is a pure **absence** assertion carrying no status
  code, value or state literal for the detector to latch onto. I verified this by reading
  `structural_score.py` lines 219-231 rather than guessing at the arithmetic.
  This is a **real weakness in the scenario**, not a script artefact: and `contract-probe` went on
  to prove that scenario is not merely weakly-worded but **factually wrong** (see below).
- **Negative ratio 34.6 %** — independently recomputed by the script from the file itself, and it
  matches both my own `grep -c '@negative'` (9) and the generator's self-reported figure in
  `coverage-matrix.md`. The **tag-vs-ratio audit passes**: 9 literal tags, 9 counted.
- **34.6 % is below the 40 % D20 target.** Per the shared contract this is a *reported bias signal*,
  never a threshold to pad toward. Ratio explainer: the refusal paths on this contract live in AC3,
  AC4, AC6, AC7, AC8 and AC10 — all six carry `@negative` scenarios. AC1, AC2 and AC5 are read and
  round-trip promises with **no refusal path to test**, and AC5 alone contributes 2 positive
  Outline blocks. Padding to 40 % would require inventing refusals the source does not describe.
  **The blocking gate is coverage, and it passes 9/9 `[req-neg]`.**

---

## Step 3 — Eight-dimension checklist

| Dimension | Score | Evidence |
|---|---|---|
| **Atomicity** | 2 | Every scenario has exactly one `When`; outcomes only in `Then`. The two `Scenario Outline`s merge rows of identical priority *and* confidence, as the rule requires. The `@smoke` journey (027) is the single permitted end-to-end block. |
| **Coverage** | 1 | 9 of 11 ACs have a scenario; AC9 and AC11 are uncovered — but both are **P3 with a recorded reason** in `coverage-matrix.md`, i.e. a standing priority-scoped waiver, not a silent gap. Scored 1 not 2 because the delivered book genuinely does not exercise them. |
| **Negative-path coverage** | 2 | All 9 `[req-neg]` conditions carry a `@negative` scenario (verified by literal grep, not by trusting the matrix). Raw ratio 34.6 % reported as a bias signal only. |
| **Technique fit** | 2 | Exactly one technique tag per non-smoke scenario (`technique_tag_violations: []`). `@metamorphic` on AC1-C3 is a genuinely apt choice: no ordering or size is promised, so a set-stability relation is the only non-fabricating oracle. |
| **Business correctness** | **0** | **See below — this is the failing dimension.** |
| **Ambiguity honesty** | 2 | 13 `@low-confidence` tags, each with an inline `# open:`/`# assumption:` comment naming the question ID. `[open]` items were not downgraded to `[assumption]` to ease generation. |
| **Traceability** | 2 | 25.0/25 from the script. IDs 001-027 contiguous, no gaps, no duplicates; every scenario carries `@QAIA-`, `@AC<n>`, a priority and a condition comment. |
| **Gherkin form** | 2 | Parses; English keywords (D11); `Background` holds one genuine invariant (no credentials sent) true of all 27 scenarios. |

### Why Business correctness is 0

`contract-probe` executed the book's assertions against the live API and **falsified three of them**
(`reports/contract-probe-report.md` §5):

| Scenario | Asserts | Reality |
|---|---|---|
| `@QAIA-RAD-PUBOBJ-026` | plain HTTP serves no API content | plain HTTP returns `200` **with the full payload** |
| `@QAIA-RAD-PUBOBJ-012` | nameless `POST` is refused | it succeeds, `200`, `"name":null` |
| `@QAIA-RAD-PUBOBJ-011` | `createdAt` in ISO-8601 form | it is an epoch-millis **number** |

The dimension is defined as "no scenario contradicts the source; extrapolations flagged". All three
were flagged as extrapolations at generation time — 012 carries `@low-confidence` + `# assumption: Q3`
and 011's ISO-8601 claim came from the documented *example*. But 026 is the hard case: it is tagged
**neither** `@low-confidence` **nor** assumption-bearing, because the generator read
*"SSL/TLS for all API endpoints"* as a firm promise. It asserted, with full confidence, behaviour the
target does not have. Per the checklist's own instruction to **default to the lower score when
hesitating**, and per the rubric's "plausible-but-wrong is the worst defect", this is a 0.

*Note on fairness:* a spec-first generator cannot know the vendor breaks its own promise, and
faithfully encoding a documented promise is exactly the right behaviour. The **book** is still wrong
as a delivered artifact, which is what this dimension measures. This is a defect of the target, not
proof the generator misbehaved — recorded here so the two are not conflated.

---

## Step 4 — Gate decision

- Checklist total: **13 / 16**.
- Thresholds: PASS = ≥14 **and** no dimension < 1. **Business correctness = 0 → FAIL** on the
  any-dimension-at-0 rule, independently of the total.
- No dimension was marked `not assessable` (a source *was* available and *was* fed), so no rescaling.
- Structural pass: `PASS` (92), `forced_stop: false` — it does **not** upgrade anything.
  **Two gates, the stricter wins.**

### 🚦 GATE: **FAIL**

Reported as **two distinct numbers**, never averaged: **structural 92/100 (PASS)** ·
**checklist 13/16 (FAIL)**.

The book is structurally excellent and factually wrong in three places. That combination is precisely
why these two gates are kept separate.

---

## Three highest-impact fixes

1. **`@QAIA-RAD-PUBOBJ-026` (AC10-C1)** — rewrite to assert the *observed* reality and reclassify the
   TLS promise as a confirmed contract defect (`@QAIA-CP-001`). Its `Then` also needs a concrete
   assertion (a status code), which is what made the structural detector miss it.
2. **`@QAIA-RAD-PUBOBJ-012` (AC4-C2)** — Q3 is now **answered by evidence**: `name` is *not* required.
   The scenario asserts the opposite and must be inverted, and Q3 closed in `02-understanding.md`.
3. **`@QAIA-RAD-PUBOBJ-011` (AC4-C1)** — drop the `@oracle:iso-8601` claim on `createdAt`; assert the
   *presence* of the field and log the format deviation as `@QAIA-CP-002`.

Also worth doing (not top-3): Q1 and Q7 are now empirically answered (404, and `200 []`), so
`@QAIA-RAD-PUBOBJ-009` and `-006` can drop `@low-confidence`.

---

## Offer (step 5)

This book is QAIA-managed, so regeneration is available.

> **Would you like me to apply these fixes via `testbook-generate`'s regeneration mode?**

Nothing has been applied. This skill audits and never rewrites — no file was modified by this step,
and the three fixes above stay proposals until you answer.
