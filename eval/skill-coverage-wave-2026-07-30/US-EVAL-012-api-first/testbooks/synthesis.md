---
stepsCompleted: [00-ingest, 02-understanding, 03-design, 04-prioritize, 05-generate]
lastStep: 05-generate
lastSaved: 2026-07-31
usId: RAD-PUBOBJ
---

# synthesis — RAD-PUBOBJ (restful-api.dev public `/objects` API)

Review aid per the shared contract (`plugins/qaia-core/skills/README.md`, deliverable section).
The reviewer sees only this file and the `.feature` — every question is inlined below.

**Knowledge base: absent.** No `knowledge/index.md` exists at the output root or the repo root
(`ls .qaia` → *No such file or directory*). No `BR-KB-nnn` rule was applied and none was invented.
Recorded here in this skill's own deliverable, not only upstream in `03-design.md`.

---

## Header counts (literal, from the emitted file)

| Metric | Value |
|---|---|
| Scenario blocks | **27** (25 `Scenario` + 2 `Scenario Outline`) |
| P1 | **18** · **P2** 9 · **P3** 0 (5 P3 conditions deferred, listed in `coverage-matrix.md`) |
| *(reconciliation)* | 18 P1 scenarios cover 19 P1 conditions, and 9 P2 scenarios cover 10 P2 conditions — the two `Scenario Outline` merges (015: AC5-C1+C2, both P1; 016: AC5-C3+C4, both P2) each fold 2 conditions into 1 block |
| `@negative` blocks (literal tags) | **9** |
| `@smoke` journey | 1 (excluded from ratio and atomicity) |
| `@low-confidence` scenarios | **13** |
| **Negative-path coverage (the gate)** | **9 / 9 `[req-neg]` conditions covered** ✅ |
| Negative ratio (D20, bias signal) | 9 / 26 = **34.6 %** |
| Open ambiguities | 11 questions: 7 `[assumption]`, 4 `[open]` |

**Tag-vs-ratio audit (mandatory):** the numerator used above is a **literal `grep -c '@negative'` of
the emitted file** = 9, matching the 9 blocks counted in the ratio. Independently recomputed by
`eval/tools/structural_score.py`, which reported `negative_scenarios: 9`, `non_smoke_scenarios: 26`,
`negative_ratio_recomputed_pct: 34.6`. Three independent counts agree.

**Ratio explainer (below 40 %, coverage still passes — this is normal, not a defect).** The ACs that
carry refusal paths (AC3, AC4, AC6, AC7, AC8, AC10) *all* have `@negative` scenarios. The ACs that
drag the ratio down have **no refusal path to test**: AC1 (read a fixed catalogue), AC2 (a filter —
and list-exclusion is explicitly *not* `@negative` by the closed definition), and AC5, whose headline
promise is "any valid JSON is *accepted*" and which contributes 2 positive Outline blocks. Reaching
40 % would require inventing refusals the source does not describe — forbidden by the no-padding rule.

*Correction to `coverage-matrix.md`:* that file states `@low-confidence` = "14 total occurrences −
… 13 distinct scenarios". The literal count is **13 tag lines, 13 scenarios**; the 14 is an
arithmetic slip in the matrix. The correct figure is 13.

---

## Review order

### 1. `@low-confidence` first (13)

`-004` (Q2, open) · `-006` (Q7) · `-007` (Q8) · `-009` (Q1) · `-010` (Q8) · `-012` (Q3) ·
`-014` · `-018` · `-019` (Q4, open) · `-021` (Q9) · `-022` (Q1) · `-024` (Q1) · `-025` (Q1)

### 2. Then P1 → P3

---

## ⚠ The book has been probed against the live API — read this before reviewing

`contract-probe` ran after generation (`reports/contract-probe-report.md`) and **falsified three
scenarios**. They are listed here so no reviewer approves a book that is already known to be wrong:

| Scenario | Status |
|---|---|
| `@QAIA-RAD-PUBOBJ-026` (TLS) | **WRONG** — plain HTTP serves the full payload with `200` |
| `@QAIA-RAD-PUBOBJ-012` (nameless POST) | **WRONG** — succeeds with `"name":null`; Q3 answered |
| `@QAIA-RAD-PUBOBJ-011` (`createdAt` ISO-8601) | **WRONG** — returns epoch millis |

Eight other scenarios were **confirmed** correct against the live API. `testbook-validate` gates this
book **FAIL** on business correctness as a result.

---

## Full question list (inline — the reviewer never sees the state files)

Numbering is complete and gap-free: Q1-Q10 plus Q7b.

| ID | Question | Status | Proposed default | Now answered by probing? |
|---|---|---|---|---|
| **Q1** | What do `GET`/`PUT`/`PATCH`/`DELETE` return for a non-existent id? | `[assumption]` | `404` + JSON error | **YES — `404 {"error":"Object with id=X was not found."}`** |
| **Q2** | May the public API mutate/delete the reserved ids 1-13? | **`[open]`** | treat as forbidden; never target them | **NO — deliberately not probed** (would write to shared demo data) |
| **Q3** | Is `name` required on `POST`? | `[assumption]` | required; omission refused | **YES — and the default was WRONG: `200`, `"name":null`** |
| **Q4** | `PUT` on an absent id: upsert or refuse? | **`[open]`** | refusal (tie-break only) | not probed (would need an id guess) |
| **Q5** | The 50/day quota: who is "each user", is the 50th allowed, what does exhaustion return, which clock? | **`[open]`** | per-IP, 51st refused `429`, rolling 24 h | **NO — deliberately never exhausted** (DoS shape against a third party) |
| **Q6** | Does "structures **and relationships**" imply any inter-object relationship feature? | `[assumption]` | no such feature; nested JSON only | no endpoint exposes one — consistent with the default |
| **Q7** | Degenerate `?id=` filtering: partial misses, and 100 % filtered out? | `[assumption]` | omitted silently; `200 []` | **YES — `200 []`, default was right** |
| **Q7b** | Does `?id=` expose objects created by **other** users? | **`[open]`** | none — three rules give three answers | **NO — deliberately not probed** (would read a third party's data) |
| **Q8** | What does a malformed id value do? | `[assumption]` | same as non-existent, not a distinct `400` | partially — `404`, no `5xx` |
| **Q9** | Does `PATCH` with a `data` key merge or replace it? | `[assumption]` | depth-1 replace | not isolated in this run |
| **Q10** | Do public `POST` objects persist and appear in `GET /objects`? | `[assumption]` + **`[out-of-slice]`** | retrievable by id, absent from the reserved list | **YES — retrievable via `?id=` and by path** |

---

## Out-of-slice dependencies

The book is complete **for the ingested slice** (public `/objects`). These boundaries are explicit:

- **Q10 (retention)** → sibling story **S2** (authenticated `/collections`), not ingested.
- **`?status=` and `?auth-type=`** → stories **S4** / **S3**. Documented only for authenticated
  endpoints; the public surface was probed and **ignores `?status=`**, consistent with the docs.
- **`x-api-key` issuance** → **S2/S3**. No account was created in this run.
- **Quota mechanics** → **S5**, a number with no response contract.

---

## Open gaps NOT turned into scenarios (surfaced, not invented)

- **Q7b — cross-tenant read via `?id=`.** The `istqb-design` 3c pattern "cross-tenant access (IDOR)"
  is *hit*, and deliberately not generated: confirming it would read another party's data.
- **Q2 — mutability of the reserved catalogue.** Only a read-only observation (`-004`) is generated.
- **Q5 — quota boundary.** BVA is the right technique and is named in `03-design.md`; it is
  deliberately not exercised (exhausting a shared third party's quota is a DoS shape).
- **Pagination on the public list.** No `limit`/`offset` exists on the public surface; deriving them
  would invent a feature belonging to the authenticated one.
- **`DELETE` has no documented inverse** — no undelete endpoint anywhere in the source. Recorded as
  a gap; **no restore scenario was invented**.
- **Config/feature-flag behaviour** — the honest-recall ceiling: it lives in a knowledge base that
  does not exist here.

---

## By-technique table

| Technique | ACs | Scenarios | Justification |
|---|---|---|---|
| `@ep` | AC1, AC2, AC3 | 5 | Input/state classes the contract treats identically (populated vs `null` `data`; known/unknown ids). |
| `@boundary` | AC2, AC10 | 2 | Filter multiplicity, and the protocol boundary https/http. |
| `@metamorphic` | AC1 | 1 | No ordering or size is promised, so only the relation "same request twice → same id set" is assertable without fabricating a promise. |
| `@domain-analysis` | AC5 | 2 | JSON *type* × nesting *depth* × key *character set* — related variables needing combined coverage, not isolated BVA. |
| `@crud` | AC4, AC8, JRN | 4 | Full entity lifecycle, including the `@smoke` round-trip. |
| `@state-transition` | AC6, AC7, AC8 | 7 | Derived from the completed state × event table in `03-design.md` (6 of 15 cells documented, 9 undefined). |
| `@error-guessing` | AC2, AC3, AC4, AC7 | 6 | Error paths anchored on the ambiguity log, not free invention. |

Deliberately unused and named: `@decision-table` (one anonymous role, no flags in slice),
`@pairwise` (no parameter explosion), `@ai-feature` (no AI feature in the target).

---

## Priority rationale + arbitration list

One-line risk rationales for all 34 conditions are carried in `coverage-matrix.md`'s rationale
column (deliverable rule, rubric dim. 9).

### ⚠ Everything below needs human arbitration — nothing here is validated

| Gate | Status |
|---|---|
| `us-ingest` US-ID + right-document | `simulated` — non-interactive |
| **`us-review` extraction** | **`pending-validation`** — extraction is `unconfirmed`; the corrected clause forbids marking it done |
| `need-understanding` Q&A | `simulated: proposed defaults applied` |
| `istqb-design` technique map | `simulated` — proposed, not approved |
| **`prioritize` scores** | **`proposed but not arbitrated`** — *unsuitable for a production Go/No-Go until a human reviews them* |
| **`testbook-generate` book review** | **`pending-validation`** — this synthesis has not been accepted by anyone |
| **Campaign step-8 human gate** | **NOT PASSED** — no human Go/No-Go was given |

Scores most likely to move under arbitration: **AC1-C4** (depends on Q2), **AC10-C1 / AC9-C1**
(security-minded reviewers may raise both), **AC6-C2**, **AC11-C1**, and the **impact anchor itself**
(impact 3 = contract falsification rather than physical/financial harm), which recalibrates the whole
column if rejected.

---

## Execution constraints (not requirement ambiguities — kept out of the Q-slots on purpose)

Per `need-understanding` step 5's corrected rule, feasibility and flakiness concerns must not consume
a question slot. They are recorded here instead:

1. **The 50-requests/day public quota cannot sustain a regression suite.** This 27-scenario book
   needs well over 50 requests to run end to end. Any automation must either use the authenticated
   tier (100/day) or a self-hosted stand-in. This run itself consumed **37 of 50**.
2. **The reserved catalogue is shared mutable state open to anonymous writes** — any assertion on the
   literal content of `GET /objects` is inherently flaky for everyone. This is why AC1-C3 is a
   metamorphic set-stability relation rather than a literal list assertion.
3. **Object ids created by `POST` are 32-char hex strings**, not small integers — no test may assume
   a numeric id.
