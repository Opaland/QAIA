# Coverage matrix — US-001

| AC | Condition | Scenario ID | Priority | Rationale | Confidence |
|---|---|---|---|---|---|
| AC1 | AC1-C1 match shown | @QAIA-US001-001 | P2 | Core filter correctness | firm |
| AC1 | AC1-C2 non-match excluded | @QAIA-US001-002 | P2 | Core filter correctness | firm |
| AC1 | AC1-C3 unauthenticated [req-neg] | @QAIA-US001-003 | P1 | Data exposure risk | firm |
| AC2 | AC2-C1 bookable ≥2h | @QAIA-US001-004 | P1 | Booking-window correctness, high user impact | firm |
| AC2 | AC2-C2 refused <2h [req-neg] | @QAIA-US001-005 | P1 | Prevents last-minute unstaffed bookings | firm |
| AC2 | AC2-C3 timezone reference | @QAIA-US001-006 | P3 | Rests on unconfirmed default (Q1) | low-confidence |
| AC3 | AC3-C1 below limit bookable | @QAIA-US001-007 | P2 | Core limit correctness | firm |
| AC3 | AC3-C2 at limit refused [req-neg] | @QAIA-US001-008 | P1 | Prevents appointment hoarding | firm |
| AC3 | AC3-C3 cancel frees count | @QAIA-US001-009 | P3 | Rests on unconfirmed default (Q2) | low-confidence |
| AC4 | AC4-C1 immediate unavailability | @QAIA-US001-010 | P1 | Double-booking is the core risk of this US | firm |
| AC4 | AC4-C2 race condition loser informed [req-neg] | @QAIA-US001-011 | P1 | Race safety, explicit in AC4 | firm |
| AC4 | AC4-C3 UI-bypass on taken slot [req-neg] | @QAIA-US001-012 | P1 | Server-side enforcement, not UI-only | firm |
| AC5 | AC5-C1 confirmation content | @QAIA-US001-013 | P1 | Wrong confirmation misleads the patient | firm |
| AC6 | AC6-C1 allowed ≥4h | @QAIA-US001-014 | P2 | Core window correctness | firm |
| AC6 | AC6-C2 refused <4h [req-neg] | @QAIA-US001-015 | P1 | Prevents late no-shows on practitioner side | firm |
| AC6 | AC6-C3 IDOR on cancel [req-neg] | @QAIA-US001-016 | P1 | Cross-patient authorization | firm |
| AC6 | AC6-C4 unauthenticated cancel [req-neg] | @QAIA-US001-017 | P2 | Baseline authentication check | firm |
| AC6 | AC6-C5 cross-AC2/AC6 interaction | @QAIA-US001-018 | P3 | Rests on unconfirmed default (Q3) | low-confidence |
| AC7 | AC7-C1 minor + unauthorized practitioner refused [req-neg] | @QAIA-US001-019 | P1 | Safety/compliance-relevant (minors) | firm |
| AC7 | AC7-C2 minor + authorized practitioner + guardian notified | @QAIA-US001-020 | P1 | Safety/compliance-relevant (minors) | firm |
| AC7 | AC7-C3 minor without guardian contact | @QAIA-US001-021 | P2 | Rests on unconfirmed default (Q4) | low-confidence |
| AC8 | AC8-C1 booking audited | @QAIA-US001-022 | P2 | Traceability requirement | firm |
| AC8 | AC8-C2 cancellation audited | @QAIA-US001-023 | P2 | Traceability requirement | firm |
| — | journey (use-case) | @QAIA-US001-024 | P1 | End-to-end smoke, excluded from atomicity/ratio | firm |

**All 8 AC covered.** Negative ratio (D20 definition, excl. `@smoke`): 9 `@negative` blocks /
23 total = **39.1 %** (target ≥ 40 %, reported as-is, not padded).

## Gaps flagged (ceiling clause — not generated, not invented)

- Slot-list sort/filter/persistence beyond the specialty filter (e.g. sort by date/time,
  pagination) — not described in the US; config/UX-driven, belongs to a richer source or the
  knowledge base.
- Practitioner registered under more than one specialty — how they appear in a
  single-specialty filter is not specified.
- Appointment "reschedule" — the US only describes book/cancel; a reschedule capability is
  not implied and is not invented.
- Audit-trail immutability/tamper-evidence — AC8 only requires entries to exist with
  who/what/when; whether the log itself is append-only/immutable is not stated.
