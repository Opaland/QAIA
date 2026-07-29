---
stepsCompleted: [testbook-generate]
lastStep: testbook-generate
lastSaved: 2026-07-29
---

# Synthesis — US-007: Paid course enrolment

**Date:** 2026-07-29
**Scenarios:** 31 total = 30 atomic + 1 `@smoke` journey. By priority (atomic only): **P1: 11, P2: 9, P3: 10**.
**AC coverage:** 5/5 ACs covered.
**Required-negative coverage (ADR 0001, the blocking gate):** **11/11 covered** — every rule that can refuse/deny/error has a scenario.
**Negative ratio (D20 signal, reported only, never a gate):** 11/30 = **36.7 %** — see ratio explainer below.
**Open ambiguities:** 2 genuinely open/out-of-slice (Q3, Q10); 8 accepted assumptions (Q1, Q2, Q4, Q6, Q7, Q9 + AC1-C9/C10 mechanism assumptions folded under the same "unspecified mechanism" pattern); 2 answered directly from the source (Q5, Q8).

## Full numbered question list (from `need-understanding`)

1. **Q1** — Can the fee amount be zero or negative? → **assumption**: reject ≤ 0.
2. **Q2** — What happens on a failed/declined payment? → **assumption**: not enrolled, not charged, error shown, retry allowed.
3. **Q3** — Does cancelling/failing leave a visible trace for the manager? → **open** — no scenario asserts manager-side visibility beyond this flag.
4. **Q4** — Can a course have more than one payment-required method? → **assumption**: yes, independently configurable.
5. **Q5** — Does an already-enrolled student still see the fee prompt? → **answered**: no (AC2's own "not yet enrolled" wording).
6. **Q6** — Does a guest resume the fee prompt after logging in? → **assumption**: yes, resumes the same course's prompt.
7. **Q7** — Is a renamed method's display name a live property or a snapshot? → **assumption**: live property.
8. **Q8** — Does AC5's "custom name only" rule also apply to the AC4 guest view? → **answered** (triple-AC read of AC4 × AC5).
9. **Q9** — What happens when the payment account has zero enabled methods? → **assumption** (`@low-confidence` on the exact message, not on the fail-closed principle).
10. **Q10** — Is payment-account/gateway configuration in scope of this US? → **out-of-slice** — see dependencies below.

## Ratio explainer (36.7 % < ~40 %, coverage gate still passes)

The book's required-negative coverage is complete (11/11) despite the raw ratio sitting below 40 %. Reading which ACs actually carry refusal paths explains why: **AC1** (configuration validation) is the most negative-heavy AC (5/10 blocks) because it's the only AC with hard input validation; **AC5** (custom naming) legitimately carries **zero** negative scenarios — it is a display-scoping rule (who sees which name), not a refusal/denial rule, so there is nothing to refuse. **AC2** and **AC4** each carry exactly the negative paths their bypass-prevention conditions require (1/4 and 2/4 respectively) — the remaining scenarios are deliberately positive "is the right thing shown" checks, which the atomicity rule forbids merging into the negative ones. A low ratio on a book with full required-negative coverage is normal here, not a defect.

## Out-of-slice dependencies

- **Q3** (pending/cancelled-attempt visibility) and **Q10** (payment-account/gateway configuration) both point outside this ingested slice. Per `00-source.md`'s recorded `dependencies:`, the payment-account/gateway administration is likely defined in a sibling story not provided to this run; no scenario in this book invents that mechanism — it is always treated as a given precondition (a payment account "available with N enabled methods").

## Review order

`@low-confidence` first: **007, 009, 010, 018, 022, 024, 030** (7 scenarios, each citing its assumption/question ID) — then **P1 → P2 → P3**.

## By-technique table

| Technique | ACs | Scenarios | Justification |
|---|---|---|---|
| Equivalence Partitioning (`@ep`) | AC1, AC2, AC3, AC4, AC5 | 001, 004, 006, 011, 012, 015, 018, 019, 020, 025, 026 | Input/state classes treated alike (valid config, prompt content, method list, messaging parity). |
| Boundary Value Analysis (`@boundary`) | AC1 | 002, 003, 005 | Fee-amount and currency-minor-unit thresholds. |
| Decision Table (`@decision-table`) | AC1, AC4, AC5 | 008, 016, 027, 028, 029 | Role × configuration-state combinations (manager/non-manager, guest/student, default/customized). |
| State Transition (`@state-transition`) | AC2, AC3, AC5 | 013, 021, 022, 023, 030 | Enrolment-state visibility and payment-lifecycle transitions (cancel/decline/retry re-entrance); naming as a live-state property. |
| Error Guessing (`@error-guessing`) | AC2, AC3, AC4 | 014, 017, 024 | Server-side bypass and degenerate zero-methods misconfiguration — reflex patterns beyond literal AC text. |
| CRUD Testing (`@crud`) | AC1 | 007, 009, 010 | Full method lifecycle beyond create: a second instance, update, removal. |
| Use-case / Scenario-Based (`@use-case`, `@smoke`) | AC1-AC4 | 031 | Single end-to-end journey, excluded from atomicity/negative-ratio accounting. |
| Oracle: ISO 4217 (`@oracle:iso4217`) | AC1 | 004, 005 | Currency-code and minor-unit correctness grounded in the standard, not guessed; each also carries its own closed-list technique tag (`@ep`/`@boundary`). |

## Priority rationale (summary; full one-liners in `coverage-matrix.md`)

11 P1 scenarios cluster on: input validation that guards the paid-content boundary (AC1), the content-gating guarantee itself (AC2/AC4), and the two outcomes of a payment attempt succeeding or failing (AC3). **Assignments needing human arbitration** (all `simulated: accepted-as-is` in this non-interactive run, none yet reviewed by a person): every score in `04-priorities.md`, and in particular the P1 assignments resting on an `[assumption]` (022, 024) — these are the highest-value targets for a human priority review.

## Coverage matrix

See `coverage-matrix.md` (same directory) — AC → condition → scenario ID → priority → rationale → confidence, inline.

## Changelog

None — this is the initial generation (no prior book existed for US-007).
