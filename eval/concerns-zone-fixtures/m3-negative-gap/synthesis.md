# Synthesis — US-001 (fixture M3, deliberately medium with a req-neg gap)

- **Scenarios**: 10 total across 1 feature file.
- **Priority split**: 3 `@P1` / 5 `@P2` / 2 `@P3`.
- **Coverage**: all 8 AC have at least one scenario.
- **Negative-path coverage**: AC2, AC4, AC7 required-negative conditions are covered. AC3's
  "4th appointment refused" and AC6's "<4h cancellation refused" required-negative conditions
  are **not** covered in this pass — only their positive counterparts are tested.
- **AC5**: the confirmation scenario checks the practitioner's name and date/time but never
  checks the connection link.
- **Timezone / guardian ambiguities**: not raised as questions anywhere in this synthesis.

## Coverage matrix

See `coverage-matrix.md` (same directory).

## Review order

P1 first, then P2, then P3.
