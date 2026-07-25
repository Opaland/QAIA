---
stepsCompleted: [00-ingest, 01-review, 02-understanding, 03-design, 04-priorities, 05-generate]
lastStep: testbook-generate
lastSaved: 2026-07-25
---

# Synthesis — US-004 (expense report approval workflow)

**Run type:** conversational validation, simulated persona (see
`../conversational-validation-simulated.md` for the full protocol, objections and honest
caveat — this is a single agent playing a demanding-tester role, not a real independent human).

## Counts

- 8 acceptance criteria, all covered (AC8 split into AC8a/AC8b at `us-review`).
- 34 scenario blocks: 33 atomic + 1 `@smoke` journey (excluded from atomicity/ratio accounting).
- Priority split (33 atomic blocks; the `@smoke` journey carries no priority tag, per
  convention): P1 = 10, P2 = 20, P3 = 3.
- `@low-confidence` scenarios: 7 total — 3 at P3 (008, 019, 021) and 4 at P2 (014, 016, 022, 028).
- Negative-path coverage (ADR 0001): every `[req-neg]` condition in `03-design.md` has a
  covering `@negative` scenario. Negative ratio (D20 definition) = 15/33 = **45.5 %**.
- Ratio explainer: the ratio clears 40 % mainly because AC1/AC7 (lifecycle guards) and AC5
  (receipt control) each carry several refusal paths; AC2's tier-routing table itself is
  mostly positive-path (routing correctness, not refusal), so its density is lower than the
  lifecycle and receipt areas.

## Open ambiguities (full inline list, per the shared deliverable contract)

| ID | Question | Status | Resolution |
|---|---|---|---|
| Q1 | Are the €500/€5000 tier boundaries inclusive or exclusive? | answered | Both boundaries fall in the *higher* tier (persona decision, corrects the skill's initial `[open]` framing) |
| Q2 | What does "skip to the next level up" mean for a manager's own report? | answered | Skip only the self-approval step; every other level the amount requires still applies (persona correction — the skill's naive default had over-read this as skipping the whole chain up to director) |
| Q3 | Can a changes-requested → draft report later be rejected, becoming terminal? | answered | Yes — it is not a protected state, it re-enters the ordinary AC2 chain (persona decision) |
| Q4 | Which rate applies when no FX rate exists for the expense date (weekend/holiday)? | assumption | Previous business day's closing rate (accepted as proposed) |
| Q4b | Which FX rate source/provider? | **open** | Not specified by the source; ECB reference rate proposed to Finance, not confirmed |
| Q5 | "Within the last 90 days" — inclusive of day 90, and against which clock? | assumption | Inclusive of day 90, server submission date (accepted as proposed) |
| Q6 | Any format/size constraint on an attached receipt? | assumption | None asserted; any attached file accepted (accepted as proposed) |
| Q7 | Does re-submission after a currency-rate change restart approval from level 1? | assumption | Yes, treated as a new submission event (accepted as proposed, `@low-confidence`) |
| Q8 | Is the mandatory comment required once per report or once per rejecting/changes-requesting action? | assumption | Once per action — every rejecting/changes-requesting decision needs its own ≥10-character comment (accepted as proposed) |
| Q9 | Is "approved" terminal like "rejected"? | assumption | Yes, no reversal mechanism described (accepted as proposed, `@low-confidence`) |
| Q10 | Does one invalid line block the whole submission, or only that line? | assumption | Whole submission blocked (accepted as proposed) |
| Q11 | Is the €25 receipt threshold evaluated pre- or post-currency-conversion? | assumption | Post-conversion (converted EUR amount), by analogy with AC6's stated rule for AC2 (accepted as proposed, `@low-confidence`) |

Out-of-slice dependencies: none identified — US-004 does not reference other backlog stories.

## Review order

`@low-confidence` first (008, 014, 016, 019, 021, 022, 028 — 7 scenarios), then P1 → P2 → P3.

## By-technique table

| Technique | ACs | Scenarios | Justification |
|---|---|---|---|
| State transition | AC1, AC7 | 9 | Lifecycle states and forbidden/valid transitions |
| Decision table | AC2, AC3, AC6 | 7 | Amount tier × self-approval × currency conversion — merged into one cross-cutting table after the persona's `istqb-design` objection |
| Equivalence partitioning + boundary | AC4 | 6 | Line-item data rules and the 90-day window |
| Equivalence partitioning + boundary | AC5, AC6 | 6 | Receipt threshold and its currency interaction |
| Equivalence partitioning + boundary | AC8a, AC8b | 5 | Audit fields and mandatory-comment enforcement |
| Use case | — | 1 | End-to-end journey, `@smoke`, excluded from accounting |

## Priority rationale (full list — see coverage matrix for the one-line-per-assignment column)

P1 assignments concentrate on: state-machine integrity (forbidden transitions, terminal-state
guards), segregation-of-duties (self-approval controls), boundary-accurate routing (wrong
tier = wrong approval chain = a compliance failure, not a cosmetic one), the receipt/anti-fraud
control (priority-corrected from the skill's initial P2), and mandatory-comment enforcement.
P2 covers standard functional correctness and interaction/assumption-based conditions where the
underlying risk is real but bounded. P3 is reserved for `@low-confidence` scenarios resting on
an unconfirmed default with genuinely low stakes (e.g. the exact-90-days boundary, the zero-amount
guard).

**Assignments needing human arbitration beyond this run:** Q4b (FX rate source) remains open;
the manager-under-€500 self-approval edge case (see coverage matrix "Gaps flagged") was not
scored or generated — it needs a first pass before it can be prioritized at all.

## Changelog

Initial generation. No prior book existed for US-004 (duplicate scan against
`.qaia/testbooks/` and `eval/gold-set/` returned no matches — nothing to reuse).
