# Coverage matrix — US-004 (conversational-validation-simulated run)

| AC | Condition | Scenario ID | Priority | Rationale | Confidence | Retention status |
|---|---|---|---|---|---|---|
| AC1 | AC1-C1 draft→submitted | @QAIA-US004-001 | P2 | Core lifecycle correctness | firm | kept |
| AC1 | AC1-C2/C3/C4 review outcomes | @QAIA-US004-002 | P2 | Core lifecycle correctness | firm | kept |
| AC1 | AC1-C5/C6 changes-requested loop | @QAIA-US004-003 | P2 | Core lifecycle correctness | firm | kept |
| AC1 | AC1-C7 invalid transition [req-neg] | @QAIA-US004-004 | P1 | State-machine integrity | firm | kept |
| AC1/AC7 | AC1-C8 edit rejected [req-neg] | @QAIA-US004-005 | P1 | Terminal-state guarantee, explicit in AC7 | firm | kept |
| AC1/AC7 | AC1-C9 re-submit rejected [req-neg] | @QAIA-US004-006 | P1 | Terminal-state guarantee, explicit in AC7 | firm | kept |
| AC1 | AC1-C10 re-entrance | @QAIA-US004-007 | P2 | State-machine reflex check | firm | kept |
| AC1 | AC1-C11 approved terminal [assumption] | @QAIA-US004-008 | P3 | Rests on unconfirmed default (Q9) | low-confidence | kept |
| AC1/AC7 | AC1-C12 reject on 2nd cycle | @QAIA-US004-009 | P2 | Proves the Q3 arbitration actually shipped | firm | **added** |
| AC2 | AC2-C1/C3/C5 tier routing | @QAIA-US004-010 | P2 | Core routing correctness | firm | kept |
| AC2 | AC2-C2/C4 boundary routing | @QAIA-US004-011 | P1 | Boundary + compliance-relevant routing | firm | **rewritten** |
| AC2/AC3 | AC2-C6 self-approval at top tier | @QAIA-US004-012 | P1 | Segregation-of-duties control | firm | **rewritten** |
| AC2/AC6 | AC2-C8 currency crosses boundary | @QAIA-US004-013 | P2 | Interaction risk (routing on wrong currency basis) | firm | **added** |
| AC2/AC6 | AC2-C9 no-rate fallback [assumption] | @QAIA-US004-014 | P2 | Fallback always resolves; residual risk is FX accuracy, not routing | low-confidence | **rewritten** |
| AC3 | AC3-C1 approve own report [req-neg] | @QAIA-US004-015 | P1 | Segregation-of-duties control, explicit in AC3 | firm | kept |
| AC3 | AC3-C2 finance self-approval [assumption] | @QAIA-US004-016 | P2 | Extension of AC3's stated principle | low-confidence | **added** |
| AC4 | AC4-C1 within 90 days | @QAIA-US004-017 | P2 | Core validation correctness | firm | kept |
| AC4 | AC4-C2 >90 days [req-neg] | @QAIA-US004-018 | P2 | Core validation correctness | firm | kept |
| AC4 | AC4-C3 exactly 90 days [assumption] | @QAIA-US004-019 | P3 | Rests on unconfirmed default (Q5) | low-confidence | kept |
| AC4 | AC4-C4 missing category [req-neg] | @QAIA-US004-020 | P2 | Core validation correctness | firm | kept |
| AC4 | AC4-C5 zero amount [assumption][req-neg] | @QAIA-US004-021 | P3 | Rests on unconfirmed default | low-confidence | kept |
| AC4 | AC4-C6 partial-block [assumption] | @QAIA-US004-022 | P2 | Rests on unconfirmed default (Q10) | low-confidence | kept |
| AC5 | AC5-C1 <€25 no receipt | @QAIA-US004-023 | P2 | Core validation correctness | firm | kept |
| AC5 | AC5-C2 ≥€25 no receipt [req-neg] | @QAIA-US004-024 | P1 | Audit/anti-fraud control | firm | kept-priority-corrected |
| AC5 | AC5-C3 exactly €25 [req-neg] | @QAIA-US004-025 | P1 | Same control as AC5-C2 | firm | kept-priority-corrected |
| AC5 | AC5-C4 €24.99 accepted | @QAIA-US004-026 | P2 | Boundary correctness | firm | kept |
| AC5 | AC5-C5 ≥€25 with receipt | @QAIA-US004-027 | P2 | Core validation correctness | firm | kept |
| AC5/AC6 | AC5-C6 converted-threshold [assumption] | @QAIA-US004-028 | P2 | Rests on unconfirmed default (Q11) | low-confidence | kept |
| AC8a | AC8a-C1 audit fields (outline) | @QAIA-US004-029 | P2 | Traceability requirement | firm | kept |
| AC8b | AC8b-C2 reject w/o comment [req-neg] | @QAIA-US004-030 | P1 | Traceability requirement, explicit in AC8 | firm | kept |
| AC8b | AC8b-C3 changes w/o comment [req-neg] | @QAIA-US004-031 | P1 | Traceability requirement, explicit in AC8 | firm | kept |
| AC8b | AC8b-C4 comment = 10 chars | @QAIA-US004-032 | P2 | Boundary correctness | firm | kept |
| AC8b | AC8b-C5 comment = 9 chars [req-neg] | @QAIA-US004-033 | P2 | Boundary correctness | firm | kept |
| — | journey (use-case) | @QAIA-US004-034 | — (no priority tag, per convention) | End-to-end smoke, excluded from atomicity/ratio/priority accounting | firm | kept |

**All 8 source AC covered** (AC8 split into AC8a/AC8b during `us-review`, at the persona's
request, for traceability — no source content lost, no AC merged away).
Negative ratio (D20 definition, excl. `@smoke`): 15 `@negative` blocks / 33 total = **45.5 %**.

## Retention accounting (see `../conversational-validation-simulated.md` for the full narrative)

| Status | Count | Scenarios |
|---|---|---|
| Kept, unchanged content and priority | 26 | 001–008, 010, 015, 017–023, 026–034 |
| Kept content, priority corrected by the persona | 2 | 024, 025 |
| Rewritten (content/expected outcome changed) | 3 | 011, 012, 014 |
| Added (did not exist in the naive/auto-confirm draft) | 3 | 009, 013, 016 |

Content-level retention (no rewrite required): **28 / 34 = 82.4 %**.
Untouched by any persona intervention (content and priority both unmodified): **26 / 34 = 76.5 %**.

## Gaps flagged (ceiling clause — not generated, not invented)

- Manager submitting a report **under** €500 (does it still escalate to their own manager, or
  is no approval needed at all since the amount is below any threshold?) — a second, smaller
  self-approval edge case under AC3. Genuinely under-specified beyond what Q2 resolved; not
  generated as a full scenario, flagged here for a future pass.
- Which FX rate provider/source is used (Q4b) — flagged `[open]` in `02-understanding.md`,
  not invented.
- Multi-currency reports where different lines use different currencies and only some lines
  cross a tier boundary — not described in the source at line-item granularity; would need a
  product decision on whether conversion happens per-line or on the report total before
  summation (the source only says "the converted total drives the threshold").
