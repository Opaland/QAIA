# Synthesis — US-001 (fixture M2, deliberately near the PASS/CONCERNS threshold)

- **Scenarios**: 12 total across 1 feature file.
- **Priority split**: 5 `@P1` / 5 `@P2` / 2 `@P3`. Priority is assigned per scenario but the
  rationale is not individually justified beyond "standard case" / "important case" — see
  coverage matrix.
- **Coverage**: all 8 AC have at least one scenario. AC7 has both a positive case (minor +
  authorized practitioner) and a negative case (minor + unauthorized practitioner refused).
  The guardian-contact-missing edge case is not covered — it was treated as "guardian contact is
  always on file" without flagging it as an assumption.
- **Negative-path coverage**: AC2, AC3, AC4, AC6, AC7 required-negative conditions are all
  covered (5/5).

## Review order

P1 first, then P2, then P3. (No scenario is flagged `@low-confidence`; the guardian-contact gap
above is not surfaced as a question anywhere in this synthesis — it is only visible by reading
the coverage matrix gap note.)

## Coverage matrix

See `coverage-matrix.md` (same directory).
