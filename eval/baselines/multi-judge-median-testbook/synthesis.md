# Synthesis — US-001 test book

24 scenario blocks (23 atomic + 1 `@smoke` journey). All 8 acceptance criteria covered.
Negative ratio 39.1 % (9/23, just under the 40 % indicative target — reported honestly, not
padded with an invented case).

## Open questions (never silently resolved)

- **Q1** (AC2, `@QAIA-US001-006`): is the 2-hour lead time computed in the patient's or the
  practitioner's timezone? Generated on the proposed default (patient's local time),
  `@low-confidence`.
- **Q2** (AC3, `@QAIA-US001-009`): does a cancellation immediately free a slot in the
  upcoming-appointment count? Generated on the proposed default (immediate decrement),
  `@low-confidence`.
- **Q3** (AC2 × AC6 interaction, `@QAIA-US001-018`): a slot legally freed by an on-time
  cancellation can end up with < 2h remaining before its original start — is it then
  unbookable by anyone (AC2's own rule) or a special case? Generated on the proposed default
  (stays unbookable), `@low-confidence`. Flagged as a genuine cross-AC tension, not a
  fabricated edge case.
- **Q4** (AC7, `@QAIA-US001-021`): what happens when a minor patient has no guardian contact
  on file? Generated on the proposed default (booking blocked pending guardian info),
  `@low-confidence`.

## Gaps (ceiling clause — see `coverage-matrix.md` for the full list)

Slot-list sort/filter beyond specialty, multi-specialty practitioner display, reschedule
capability, audit-log immutability — none implied strongly enough by the source to generate
without fabricating; flagged as gaps for the user/knowledge base instead.

## Review order (by risk)

1. AC4 concurrency scenarios (010-012) — the trickiest correctness guarantee in the US.
2. AC7 minor-safety scenarios (019-021), especially the Q4 default.
3. The two cross-cutting `[open]` scenarios (Q1/Q3 timezone and cross-AC interaction) —
   these are the ones most likely to need a real product decision before ship.
4. Remaining P1/P2 scenarios.
5. `@low-confidence` P3 scenarios last.
