---
stepsCompleted: [testbook-generate, testbook-export]
lastStep: testbook-export
lastSaved: 2026-07-29
reprojectedFrom: ../synthesis.md
---

# Synthesis — US-007: Paid course enrolment

**Date:** 2026-07-29
**Scenarios:** 31 total = 30 atomic + 1 `@smoke` journey. By priority (atomic only): **P1: 11, P2: 9, P3: 10**.
**AC coverage:** 5/5 ACs covered.
**Required-negative coverage (ADR 0001, the blocking gate):** **11/11 covered** — every rule that can refuse/deny/error has a scenario.
**Negative ratio (D20 signal, reported only, never a gate):** 11/30 = **36.7 %** — see ratio explainer below.
**Open ambiguities:** 2 genuinely open/out-of-slice (Q3, Q10); 8 accepted assumptions (Q1, Q2, Q4, Q6, Q7, Q9 + AC1-C9/C10 mechanism assumptions folded under the same "unspecified mechanism" pattern); 2 answered directly from the source (Q5, Q8).

## Full numbered question list (from `need-understanding`)

1. **Q1** — Can the fee amount be zero or negative? → **assumption**: reject <= 0.
2. **Q2** — What happens on a failed/declined payment? → **assumption**: not enrolled, not charged, error shown, retry allowed.
3. **Q3** — Does cancelling/failing leave a visible trace for the manager? → **open** — no scenario asserts manager-side visibility beyond this flag.
4. **Q4** — Can a course have more than one payment-required method? → **assumption**: yes, independently configurable.
5. **Q5** — Does an already-enrolled student still see the fee prompt? → **answered**: no (AC2's own "not yet enrolled" wording).
6. **Q6** — Does a guest resume the fee prompt after logging in? → **assumption**: yes, resumes the same course's prompt.
7. **Q7** — Is a renamed method's display name a live property or a snapshot? → **assumption**: live property.
8. **Q8** — Does AC5's "custom name only" rule also apply to the AC4 guest view? → **answered** (triple-AC read of AC4 x AC5).
9. **Q9** — What happens when the payment account has zero enabled methods? → **assumption** (`@low-confidence` on the exact message, not on the fail-closed principle).
10. **Q10** — Is payment-account/gateway configuration in scope of this US? → **out-of-slice** — see dependencies below.

## Ratio explainer (36.7 % < ~40 %, coverage gate still passes)

The book's required-negative coverage is complete (11/11) despite the raw ratio sitting below 40 %. AC1 (configuration validation) is the most negative-heavy AC (5/10 blocks) because it's the only AC with hard input validation; AC5 (custom naming) legitimately carries zero negative scenarios — it is a display-scoping rule, not a refusal/denial rule. AC2 and AC4 each carry exactly the negative paths their bypass-prevention conditions require. A low ratio on a book with full required-negative coverage is normal here, not a defect.

## Out-of-slice dependencies

- Q3 (pending/cancelled-attempt visibility) and Q10 (payment-account/gateway configuration) both point outside this ingested slice — the gateway administration mechanics are never invented, only treated as a given precondition.

## Review order

`@low-confidence` first: **007, 009, 010, 018, 022, 024, 030** — then **P1 -> P2 -> P3**.

## By-technique table

| Technique | ACs | Scenarios |
|---|---|---|
| Equivalence Partitioning (`@ep`) | AC1, AC2, AC3, AC4, AC5 | 001, 004, 006, 011, 012, 015, 018, 019, 020, 025, 026 |
| Boundary Value Analysis (`@boundary`) | AC1 | 002, 003, 005 |
| Decision Table (`@decision-table`) | AC1, AC4, AC5 | 008, 016, 027, 028, 029 |
| State Transition (`@state-transition`) | AC2, AC3, AC5 | 013, 021, 022, 023, 030 |
| Error Guessing (`@error-guessing`) | AC2, AC3, AC4 | 014, 017, 024 |
| CRUD Testing (`@crud`) | AC1 | 007, 009, 010 |
| Use-case / Scenario-Based (`@use-case`, `@smoke`) | AC1-AC4 | 031 |
| Oracle: ISO 4217 (`@oracle:iso4217`) | AC1 | 004, 005 |

## Coverage matrix

See `coverage-matrix.csv` (same directory) for the exported projection, or `../coverage-matrix.md` for the authoritative source.

## Changelog

None — this is the initial generation (no prior book existed for US-007).

---
This file is a re-projection of `../synthesis.md` (the authoritative version) for export/hand-off purposes, per `testbook-export`'s deliverable rules — any discrepancy is fixed in the source and re-exported.
