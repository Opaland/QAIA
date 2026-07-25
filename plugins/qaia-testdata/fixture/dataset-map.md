# dataset-map — US-002 (prescription dosage validation)

Coverage matrix for `US-002-dosage-dataset.json`, mirroring the AC → scenario → status pattern
`testbook-generate` uses for `.feature` files (D18), applied here to dataset cases instead.

| Case | AC(s) | Entities | Expected | Assumptions | Notes |
|---|---|---|---|---|---|
| C-001 | AC1, AC2 | D-001, P-001, PHY-001 | pass | ASM-1 | dosage == min (boundary) |
| C-002 | AC2 | D-001, P-001, PHY-001 | warning, overridable | — | dosage == min − 1 |
| C-003 | AC1, AC3 | D-001, P-001, PHY-001 | pass | ASM-1 | dosage == max (boundary) |
| C-004 | AC3 | D-001, P-001, PHY-001 | blocked | — | dosage == max + 1 |
| C-005 | AC4 | D-001, P-007, PHY-001 | pass | ASM-1, ASM-2 | 3 intakes / 24h summing to exactly max cumulative |
| C-006 | AC4 | D-001, P-008, PHY-001 | blocked (3rd intake) | ASM-2 | 3 intakes / 24h summing to max cumulative + 1 |
| C-007 | AC5 | D-001, P-005, PHY-003 | pass | ASM-1 | age == age floor (boundary) |
| C-008 | AC5 | D-001, P-006, PHY-003 | blocked | — | age == floor − 1, general physician |
| C-009 | AC5, AC7 | D-001, P-006, PHY-002 | warning, overridable | — | same patient, pediatric specialist, justified |
| C-010 | AC6 | D-001, P-002, PHY-003 | blocked | ASM-1 | dosage == renal-reduced max + 1 |
| C-011 | AC1, AC6 | D-001, P-002, PHY-003 | pass | ASM-1 | dosage == renal-reduced max (boundary) |
| C-012 | AC2, AC7 | D-001, P-009, PHY-003 | warning, override valid | — | justification length == 20 (boundary, valid) |
| C-013 | AC2, AC7 | D-001, P-009, PHY-003 | warning, override rejected | — | justification length == 19 (boundary, invalid) |
| C-014 | AC1, AC8 | D-002, P-010, PHY-003 | pass | — | baseline nominal, second drug |
| C-015 | AC2, AC6 | D-001, P-002, PHY-003 | **[open]** | ASM-3 | AC6 reduction-on-minimum ambiguity, not resolved |
| C-016 | AC1, AC5 | D-003, P-003, PHY-002 | pass | — | pediatric drug, low age floor, nominal |
| C-017 | AC1, AC8 | D-004, P-011, PHY-003 | pass | — | fourth drug, keeps every reference drug exercised |

## AC coverage summary

| AC | Covered by |
|---|---|
| AC1 (reference record) | C-001, C-003, C-011, C-014, C-016, C-017 (+ every drug entity itself) |
| AC2 (below-min warning) | C-001, C-002, C-012, C-013, C-015 |
| AC3 (above-max blocked) | C-003, C-004 |
| AC4 (cumulative 24h) | C-005, C-006 |
| AC5 (age floor + specialist override) | C-007, C-008, C-009, C-016 |
| AC6 (renal 50% reduction) | C-010, C-011, C-015 |
| AC7 (override audit trail, ≥20 chars) | C-009, C-012, C-013 |
| AC8 (result returned inline) | every case's `expectedResult`; C-014 is the canonical shape reference |

All 8 acceptance criteria have at least one covering case; boundary values are exercised
explicitly (±1 around every threshold this fixture asserts) rather than only mid-range values.
Verified mechanically — not just asserted — by `dataset.spec.js` (see `VALIDATION.md`).
