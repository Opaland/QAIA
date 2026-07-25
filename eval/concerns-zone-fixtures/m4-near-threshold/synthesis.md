# Synthesis — US-001 (fixture M4, deliberately near the PASS/CONCERNS threshold)

- **Scenarios**: 13 total across 1 feature file.
- **Priority split**: 5 `@P1` / 6 `@P2` / 2 `@P3`.
- **Coverage**: all 8 AC have at least one scenario. AC5's confirmation scenario checks all
  three required fields (practitioner name, date/time, connection link). AC7 has both a
  positive case (minor + authorized practitioner) and a negative case (minor + unauthorized
  practitioner refused). AC8 has both a booking-audit and a cancellation-audit scenario.
- **Negative-path coverage**: all 5 identified required-negative conditions (AC2, AC3, AC4, AC6,
  AC7) are covered.
- **Techniques**: boundary values are used at the 2h/4h/3-appointment thresholds.

## Review order

P1 scenarios first, then P2, then P3.

## Coverage matrix

See `coverage-matrix.md` (same directory).
