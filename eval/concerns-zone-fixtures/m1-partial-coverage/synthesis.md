# Synthesis — US-001 (fixture M1, deliberately medium quality)

- **Scenarios**: 10 total across 1 feature file.
- **Priority split**: 3 `@P1` / 5 `@P2` / 2 `@P3`.
- **Coverage**: AC1-AC6 and AC8 have scenarios. AC7 (minors / guardian contact) is not covered
  in this iteration; treated as out of scope for this pass.
- **Techniques used**: equivalence partitioning and boundary checks were used where relevant.
- **Timezone note**: the confirmation scenario (AC5) assumes the patient's local timezone
  throughout.

## Coverage matrix

See `coverage-matrix.md` (same directory).

## Review order

P1 scenarios first, then P2, then P3.
