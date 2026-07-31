---
stepsCompleted: [00-ingest, 02-understanding, 03-design, 05-generate]
lastStep: 05-generate
lastSaved: 2026-07-31
usId: RAD-PUBOBJ
---

# coverage-matrix — RAD-PUBOBJ

Chain: US → AC → condition → scenario → priority → **rationale** → confidence → reuse notes.
Rationale column carries `prioritize`'s one-line risk driver (deliverable rule, rubric dim. 9).

**Reuse / duplicate scan (testbook-generate step 2) — outcome recorded for every row, including
the clean ones.** Scan actually run: `find . -name "*.feature"` → **71 committed feature files**
in the repo; `grep -ril "restful-api.dev|api.restful|/objects" --include=*.feature .` → **0 hits**.
The nearest neighbour, `eval/skill-eval-campaign-2026-07-29/US-EVAL-003-restful-booker-api/`, is a
**different product** (Restful-Booker, a booking API) despite the similar name — checked, not
assumed. **No duplicate found; nothing reused.** Every row below therefore reads
"no duplicate found", which is the required trace of a clean scan, not an omission.

| AC | Condition | Scenario | Prio | Risk rationale (from 04-priorities) | Confidence | Reuse notes |
|---|---|---|---|---|---|---|
| AC1 | AC1-C1 | @QAIA-RAD-PUBOBJ-001 | P2 | List shape is the first thing every consumer parses; heavily exercised, so a latent defect is improbable. | full | no duplicate found |
| AC1 | AC1-C2 | @QAIA-RAD-PUBOBJ-002 | P2 | `data: null` is a classic serializer casualty, and the source's own example set contains one. | full | no duplicate found |
| AC1 | AC1-C3 | @QAIA-RAD-PUBOBJ-003 | P2 | Shared mutable state open to anonymous writes makes set instability plausible and would make every list assertion flaky. | full | no duplicate found |
| AC1 | AC1-C4 | @QAIA-RAD-PUBOBJ-004 | P1 | Publicly mutable demo objects = one anonymous user can corrupt the reference data all other learners test against. | `@low-confidence` — `[open] Q2` | no duplicate found |
| AC2 | AC2-C1 | @QAIA-RAD-PUBOBJ-005 | P1 | "Excludes all others" is the only exclusion promise in the docs; a leak is a silent over-return consumers would trust. | full | no duplicate found |
| AC2 | **AC2-C2** | **— not generated —** | **P3** | Multiplicity-1 is the degenerate case of a simple documented filter. | — | **Deferred: P3, not requested** (step 1 default scope P1+P2). Standing priority-scoped waiver, not a gate violation. |
| AC2 | AC2-C3 | @QAIA-RAD-PUBOBJ-006 | P1 | Undocumented empty-result shape; a 404 where a consumer loops over an array is an immediate client crash. | `@low-confidence` — `[assumption] Q7` | no duplicate found |
| AC2 | AC2-C4 | @QAIA-RAD-PUBOBJ-007 | P1 | Ids typed `string[]` but every example numeric — a parser assuming integers is a live 5xx risk. | `@low-confidence` — `[assumption] Q8` | no duplicate found |
| AC3 | AC3-C1 | @QAIA-RAD-PUBOBJ-008 | P2 | Core read path, fully documented with a worked example. | full | no duplicate found |
| AC3 | AC3-C2 **[req-neg]** | @QAIA-RAD-PUBOBJ-009 `@negative` | P1 | The most-coded-against error of any CRUD API, with **no status code documented at all**. | `@low-confidence` — `[assumption] Q1` | no duplicate found |
| AC3 | AC3-C3 | @QAIA-RAD-PUBOBJ-010 | P1 | Same undocumented territory as AC2-C4, on the path parameter. | `@low-confidence` — `[assumption] Q8` | no duplicate found |
| AC4 | AC4-C1 | @QAIA-RAD-PUBOBJ-011 | P1 | Creation gates every mutation scenario; without the documented `id`/`createdAt` nothing downstream is testable. | full | no duplicate found |
| AC4 | AC4-C2 **[req-neg]** | @QAIA-RAD-PUBOBJ-012 `@negative` | P1 | Required-ness of the only named field is undocumented; a silent accept teaches consumers there is no validation. | `@low-confidence` — `[assumption] Q3` | no duplicate found |
| AC4 | AC4-C3 **[req-neg]** | @QAIA-RAD-PUBOBJ-013 `@negative` | P1 | A 5xx on malformed client JSON is a real defect class, and unparsed-body handling is where hosted APIs leak traces. | full (`@oracle:rfc9110`) | no duplicate found |
| AC4 | AC4-C4 **[req-neg]** | @QAIA-RAD-PUBOBJ-014 `@negative` | P1 | Content-type negotiation is undocumented and a common source of accidental 5xx or silent misparse. | `@low-confidence` | no duplicate found |
| AC5 | AC5-C1 | @QAIA-RAD-PUBOBJ-015 (row 1) | P1 | "Any valid JSON structure" is the source's most emphasised promise; an array is the cheapest falsifier. | full | no duplicate found |
| AC5 | AC5-C2 | @QAIA-RAD-PUBOBJ-015 (row 2) | P1 | Same headline promise at depth — nesting is where flattening defects hide. | full | no duplicate found |
| AC5 | AC5-C3 | @QAIA-RAD-PUBOBJ-016 (row 1) | P2 | Spaced keys are proven by the docs' own `"CPU model"`; non-ASCII is the extrapolation. | full | no duplicate found |
| AC5 | AC5-C4 | @QAIA-RAD-PUBOBJ-016 (row 2) | P2 | Scalar/null `data` is demonstrated by the reserved set; the risk is round-trip fidelity, not rejection. | full | no duplicate found |
| AC6 | AC6-C1 | @QAIA-RAD-PUBOBJ-017 | P1 | Removal-by-omission *is* "completely replaces"; if it fails, PUT is secretly a PATCH. | full | no duplicate found |
| AC6 | **AC6-C2** | **— not generated —** | **P3** | `updatedAt` is response metadata; its absence is cosmetic for correctness. | — | **Deferred: P3, not requested.** |
| AC6 | AC6-C3 | @QAIA-RAD-PUBOBJ-018 | P2 | Shape-changing replacement extrapolates AC5 onto AC6. | `@low-confidence` — `[assumption]` | no duplicate found |
| AC6 | AC6-C4 **[req-neg]** | @QAIA-RAD-PUBOBJ-019 `@negative` | P1 | Upsert-vs-refuse is the classic REST fork, undocumented, both defensible; a wrong guess creates orphan objects. | `@low-confidence` — `[open] Q4` | no duplicate found |
| AC7 | AC7-C1 | @QAIA-RAD-PUBOBJ-020 | P1 | Preservation of the untouched `data` block is what makes PATCH a patch; a defect silently destroys consumer data. | full | no duplicate found |
| AC7 | **AC7-C2** | **— not generated —** | **P3** | Sequencing PATCH after PUT is not itself ambiguous; guards a compositional regression only. | — | **Deferred: P3, not requested.** |
| AC7 | AC7-C3 | @QAIA-RAD-PUBOBJ-021 | P1 | Merge depth is the one disambiguating case the docs avoid showing — highest plausible-but-wrong risk, on a data-destroying operation. | `@low-confidence` — `[assumption] Q9` | no duplicate found |
| AC7 | AC7-C4 **[req-neg]** | @QAIA-RAD-PUBOBJ-022 `@negative` | P1 | Undocumented not-found on PATCH; a silent success would be a phantom write. | `@low-confidence` — `[assumption] Q1` | no duplicate found |
| AC8 | AC8-C1 | @QAIA-RAD-PUBOBJ-023 | P2 | Delete is documented down to its exact response message, so the happy path is well specified. | full | no duplicate found |
| AC8 | AC8-C2 **[req-neg]** | @QAIA-RAD-PUBOBJ-024 `@negative` | P1 | "Removes permanently" is only verifiable by the follow-up read; a resurrected object falsifies the strongest word in the contract. | `@low-confidence` — `[assumption] Q1` | no duplicate found |
| AC8 | AC8-C3 **[req-neg]** | @QAIA-RAD-PUBOBJ-025 `@negative` | P1 | A second DELETE answering "has been deleted" reports success for an operation that did nothing. | `@low-confidence` — `[assumption] Q1` | no duplicate found |
| AC9 | **AC9-C1** | **— not generated —** | **P3** | CORS is a headline feature of a browser-facing demo API and is almost certainly configured. | — | **Deferred: P3, not requested.** *(Probed live anyway by `contract-probe` — see `reports/contract-probe-report.md`.)* |
| AC10 | AC10-C1 **[req-neg]** | @QAIA-RAD-PUBOBJ-026 `@negative` | P2 | Security-shaped promise (impact 3) but near-universal on a modern hosted API (probability 1). | full | no duplicate found |
| AC11 | **AC11-C1** | **— not generated —** | **P3** | Observational only; the limit is deliberately never exhausted, so this can never be more than an observation. | — | **Deferred: P3, not requested** *and* structurally unexercisable (quota exhaustion against a shared third party is forbidden). |
| — | JRN-C1 | @QAIA-RAD-PUBOBJ-027 `@smoke` | P2 | End-to-end smoke signal; every leg is covered atomically, so its independent defect-finding power is low. | full | no duplicate found |

## Counts (literal, from the emitted file)

| Metric | Value | How obtained |
|---|---|---|
| Conditions in `03-design.md` | 34 | counted per-AC in `03-design.md` |
| Conditions in scope (P1+P2) | 29 | `04-priorities.md` distribution table |
| Conditions deferred (P3) | 5 | AC2-C2, AC6-C2, AC7-C2, AC9-C1, AC11-C1 — all listed above with a reason |
| Scenario blocks emitted | **27** | `grep -cE '^\s*Scenario( Outline)?:'` |
| Merges (Outline) | 2 | AC5-C1+C2 → 015 · AC5-C3+C4 → 016 (same behaviour, same priority, same confidence) |
| Literal `@negative` tags | **9** | `grep -c '@negative'` |
| Literal `@smoke` tags | 1 | `grep -c '@smoke'` |
| `@low-confidence` scenarios | 13 | `grep -c '@low-confidence'` = 14 total occurrences − 0 non-tag mentions; 13 distinct scenarios (see synthesis) |
| **Negative ratio (D20)** | **9 / 26 = 34.6 %** | numerator = literal `@negative` blocks; denominator = 27 blocks − 1 `@smoke` |
| `[req-neg]` conditions | 9 | all P1/P2, all covered by a `@negative` scenario — **gate satisfied, 9/9** |

## Uncovered / waived

Nothing is silently uncovered. The five P3 conditions above are a **standing, priority-scoped
waiver** under step 1's default scope, and each keeps its ID, its priority and its reason in this
matrix. **Q7b** (cross-tenant read via `?id=`) has no condition at all by design — see
`synthesis.md`, "Open gaps not turned into scenarios".
