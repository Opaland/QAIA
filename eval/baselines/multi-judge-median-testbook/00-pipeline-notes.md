# US-001 — single generation run, pipeline notes (support material for `multi-judge-median.md`)

*This is the one generation the 3 judges score. Produced by applying `us-ingest` →
`need-understanding` (implicit prerequisite of `istqb-design`) → `istqb-design` →
`prioritize` (implicit prerequisite of `testbook-generate`) → `testbook-generate`, condensed
into a single authoring pass (same convention as `gap-harness-24.md`: "règles condensées mais
fidèles"). Only `us-ingest` / `istqb-design` / `testbook-generate` are named in the mission —
the two intermediate steps are unavoidable prerequisites (`istqb-design` requires
`02-understanding.md`; `testbook-generate` requires `03-design.md` **and**
`04-priorities.md`) and are run in abbreviated form, not skipped.

## us-ingest

Source: `eval/gold-set/US-001-appointment-booking.md`, section "User story" +
"Acceptance criteria" only — the "Judge reference — planted ambiguities" section is **not**
fed to the generation (as the gold-set file itself instructs: "NOT part of the US text given
to the skills"). No PII in the source (synthetic). No triage gate fires (clean, testable US,
single story, ~250 tokens). US-ID = `US-001`.

## need-understanding (condensed)

Ambiguities found independently (before looking at the gold-set's planted list):
- **Q1** — AC2's "2 hours in the future": no timezone specified (patient vs practitioner).
  Proposed default: patient's local timezone (patient-facing feature) → `[assumption]`.
- **Q2** — AC3's "upcoming appointments": does a cancelled appointment immediately free a
  slot in the count, or only after some grace period? Proposed default: immediate decrement
  (plain reading of "upcoming") → `[assumption]`.
- **Q3** — Cross-AC interaction AC2 × AC6: a slot freed by an on-time cancellation
  (≥ 4h before start, so legal under AC6) can still end up with < 2h remaining before its
  start. Is it then rebookable by another patient (contradicts AC2's own spirit) or
  permanently withdrawn? Not obviously dangerous either way → **`[open]`**, not
  `[assumption]` (per `istqb-design` 3c's open-vs-assumption nuance).
- **Q4** — AC7's guardian contact: what happens if no guardian contact is on file for a
  minor patient? Blocking a minor from booking at all is a safety-adjacent default, but it
  is not obviously the *only* correct one (could also mean "book but flag for staff
  follow-up") → **`[open]`**.

Both `[open]` items (Q3, Q4) get a `@low-confidence` scenario built on the proposed safe
default, cited inline (`# open: Qn`) — never silently resolved, never skipped.

## istqb-design (condensed)

| AC | Technique(s) | Justification |
|---|---|---|
| AC1 | Equivalence partitioning | Specialty filter partitions the slot set into match/non-match |
| AC2 | Boundary value analysis | "at least 2 hours" is a threshold |
| AC3 | Boundary value analysis | "no more than 3" is a count threshold |
| AC4 | Error guessing (concurrency) | Race condition is not a simple partition/boundary — anchored on the described concurrent-booking rule |
| AC5 | Equivalence partitioning | Single class: successful booking → confirmation content |
| AC6 | Boundary value analysis | "up to 4 hours" is a threshold |
| AC7 | Decision table | Minor-status × practitioner-authorization crossed |
| AC8 | Equivalence partitioning | Audit trail presence on the two event classes (booking, cancellation) |

Systematic expansion (3c) applied: authorization/IDOR/unauthenticated conditions added on
every mutating action (book, cancel) as `[req-neg]`; UI-bypass condition added for AC4
(direct API booking of an already-taken slot). **Ceiling respected**: slot-list
sort/filter/pagination and appointment "reschedule" are not implied by the US text — flagged
as gaps in `synthesis.md`, not invented into scenarios (per the ceiling clause, honest
recall < fabricated recall).

## prioritize (condensed)

P1: AC2, AC4, AC6 negative paths, AC7 (safety-relevant: minors) — high risk if wrong.
P2: AC1, AC3, AC5, AC6 positive path, AC8 — standard functional risk.
P3: the two `@low-confidence` assumption/open-question scenarios (Q1, Q2 minor cases) — kept
low priority because they rest on an unconfirmed default, not because the underlying AC is
unimportant.

## testbook-generate

Output: `booking.feature` (AC1, AC2, AC3, AC4, AC5, AC7, AC8-booking, `@smoke` journey) and
`cancellation.feature` (AC6, AC8-cancellation) — two functional areas per the "one file per
functional area" rule. 24 scenario blocks total (23 atomic + 1 `@smoke`, excluded from
atomicity/ratio accounting). Negative ratio (D20 definition: `@negative` blocks / all blocks
excl. `@smoke`) = 9/23 ≈ 39.1 % — reported honestly as slightly under the 40 % indicative
target rather than padded with an invented case (per the explicit anti-padding rule).

See `coverage-matrix.md` and `synthesis.md` in this directory for the full deliverable.
