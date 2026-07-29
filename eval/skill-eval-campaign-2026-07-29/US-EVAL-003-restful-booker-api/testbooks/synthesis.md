# Synthesis — US-EVAL-003 (Restful-Booker-Platform: POST /booking/ creation)

**Scope**: P1+P2 conditions only (13/24 conditions, default scope per `prioritize`'s Q22 quota
trade-off — the 11 P3 conditions are listed in `state/04-priorities.md`, not generated here, a
human call deferred non-interactively).
**Scenarios**: 9 atomic blocks (`003` is a `Scenario Outline` with 5 examples, counted as 1 block
per D20's single definition) + 0 smoke journey (skipped — a single-endpoint creation slice has no
multi-step journey worth a `@smoke` scenario).
**Negative ratio**: 7/9 blocks tagged `@negative` = 77.8 % (target ≥ 40 %, met without padding —
every negative here traces to a real refusal condition from `03-design.md`, none invented to hit
the ratio).
**Coverage**: AC1 2/2 (of the P1+P2 subset), AC2 7/7, AC3 2/2, AC4 1/1, plus the cross-cutting
`AC-DT-1` — 13/13 in-scope conditions covered, 0 waived within scope.
**Knowledge base**: absent for this campaign directory (recorded per shared-contract rule 8 and
`03-design.md` 3d) — this skill's own record, not only relying on the upstream checkpoint's note.

## Open / assumption / low-confidence list (full, per shared contract)

- **Q1** `[assumption]`, `@low-confidence` — **human arbitration required**: does the booking
  service validate that `roomid` refers to a real room? Scenario `QAIA-US-EVAL-003-002` encodes a
  *proposed* default (existence not checked), not a confirmed behavior — the booking
  microservice's own source has no cross-service call to confirm.
- **Q2** `[assumption]` — the exact validation-error message text for `roomid`/`depositpaid`
  violations is not asserted verbatim (no `message=` literal exists for these two constraints in
  source); scenarios `QAIA-US-EVAL-003-003`/`004` assert only that the field is named in
  `fieldErrors`, not the exact string.
- **Q3** `[assumption]`, `@low-confidence` — **human arbitration required**: when a field-shape
  violation and an invalid date range both apply to the same request, does the client see 400 or
  409? Scenario `QAIA-US-EVAL-003-009` encodes a *proposed* default (field-shape/400 wins, per
  standard Spring `@Valid` framework semantics) — not literally stated in
  `Booking.java`/`BookingController.java` themselves.

## Ratio explainer

Not needed — the negative ratio (77.8 %) is well above the 40 % target; this AC set is
refusal-heavy by construction (2 of 4 in-scope ACs are pure rejection paths).

## Out-of-slice dependencies

- `GET /booking/`, `GET /booking/{id}`, `PUT /booking/{id}`, `DELETE /booking/{id}`,
  `GET /unavailable`, `GET /summary` — same controller, separate concerns, not designed here (see
  `00-source.md` dependencies).
- The platform's `room`, `auth`, and `message` microservices — separate services entirely.

## Review order

`@low-confidence` first (`QAIA-US-EVAL-003-002` [Q1], `QAIA-US-EVAL-003-009` [Q3]), then P1 →
P2: `006`, `007`, `008` (P1, no open flag), then `001`, `003`, `004`, `005` (P2).

## By-technique table

| Technique | ACs | Scenarios | Justification |
|---|---|---|---|
| `@ep` | AC1, AC2 | `001`, `002`, `004`, `005` | Representative-class happy path and whole-field-absent negatives — a partition, not a threshold. |
| `@boundary` | AC2, AC3 | `003` (5 examples), `006`, `007` | Every field-shape constraint and the `checkin < checkout` rule are literal, sized/dated thresholds in source. |
| `@decision-table` | AC4, AC2×AC3 | `008`, `009` | Room-conflict and the field-shape-vs-date-range ordering are genuine multi-axis combinations, not opportunistic pairs — see the decision table in `03-design.md`. |

## Priority rationale (full — copied from `04-priorities.md` per the deliverable rule)

See `coverage-matrix.md`'s Rationale column for the one-line risk driver behind every scored
condition in scope. **Human arbitration needed**: `AC1-C5`/Q1 and `AC-DT-1`/Q3 — both P1 ranks
rest on an `[assumption]`, not a literal source statement.

## Coverage matrix

See `testbooks/coverage-matrix.md` (linked, not duplicated here).

## Changelog

None — initial generation, no prior book existed for this US-ID.

## Sourcing honesty note

Grounded in **primary source** (the booking microservice's own Java implementation on
`mwinteringham/restful-booker-platform`, branch `trunk`), not a secondary write-up — see
`00-source.md` for the exact files read. Confidence on field constraints, status codes, and the
double-booking/date-validity logic is source-grade; confidence on the two `[assumption]` points
above (Q1, Q3) is explicitly lower and flagged for human arbitration, not blended into the rest.
