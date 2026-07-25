---
stepsCompleted: [detect, validate, emit, record]
lastStep: record
lastSaved: 2026-07-25
---

# oracle-generate — design conditions (US-004, pilot run)

Source: `eval/gold-set/US-004-expense-approval.md` (gold set, read directly — see note below).
Skill executed: `plugins/qaia-core/skills/oracle-generate/SKILL.md`.

## Degraded-mode note (rule 2 / rule 8, `plugins/qaia-core/skills/README.md`)

No `.qaia/state/US-004/01-extraction.md` or `03-design.md` checkpoint existed for this US in
this worktree (US-004 has not been run through `us-ingest`/`us-review`/`istqb-design` here).
Per the shared journey contract, a missing prerequisite is offered, not a hard failure: this
pilot ran `oracle-generate`'s domain-detection step (step 1) directly against the gold-set AC
text in place of a prior extraction checkpoint. This is recorded explicitly rather than silently
assumed complete.

## Step 1 — Detect standardized domains

Scanning US-004's eight ACs against the trigger table in `oracles/library.md`:

| AC | Text touching a standardized domain | Oracle |
|---|---|---|
| AC6 | "Currency other than EUR is converted at the rate of the expense date" | **ISO 4217** (currency codes, minor-unit rule) |
| AC4 | "a line item... a date within the last 90 days" | **ISO 8601** (calendar validity, leap years, date/date-time) |

No other AC touches a domain in the built-in library (no card/PAN, no email, no HTTP status
surface, no IBAN, no country code in this US) — those oracles are not invoked, per the guardrail
against inventing coverage the source does not call for.

## Step 2 — Propose (⚠ VALIDATION)

Non-interactive pilot run (evaluation context, no human in the loop) — per
`plugins/qaia-core/skills/README.md` rule 3, the validation point is recorded as
`simulated: accepted` rather than skipped or silently assumed:

- **AC6 / ISO 4217**: propose valid-currency acceptance cases (USD, JPY, BHD), invalid-code
  rejection cases (EU, EURO, US$, XXX), and a minor-unit boundary case for JPY (0 decimals) and
  BHD (3 decimals) — `simulated: accepted`.
- **AC4 / ISO 8601**: propose calendar-impossible-date rejection cases (distinct from the
  "outside 90 days" business rule), a leap-day boundary case, and a date-vs-date-time
  representation case — `simulated: accepted`.

## Step 3/4 — Emit and record provenance

6 scenarios emitted to `eval/baselines/oracle-generate-token-pilot/US-004-oracle-cases.feature`,
each tagged `@oracle:iso4217` or `@oracle:iso8601` with a `# oracle:` citation comment. Two of
the six surface a genuine `[open]` point the US does not resolve (never invented a `Then`):

- **Q1** (`@low-confidence`, AC6): the US does not say how a JPY amount with fractional minor
  units, or a BHD amount finer than its 3rd decimal, is rounded or rejected. Flagged, not guessed.
- **Q2** (`@low-confidence`, AC4): the US says "a date" but does not say whether a full ISO 8601
  date-time (with timezone offset) is accepted for a line item, or how the 90-day window is
  computed against one. Flagged, not guessed.

Provenance summary for the synthesis line this would feed (D31 style): "negative cases
QAIA-EXP-ORC-002 and QAIA-EXP-ORC-004 grounded in ISO 4217 / ISO 8601, not fabricated;
2 of 6 oracle-derived cases carry an open arbitration point (Q1, Q2)."

## Oracle values — verified, not asserted

- ISO 4217: `EUR`/`USD` are real 3-letter alpha codes; `JPY` has 0 minor units, `BHD` has 3 minor
  units (both real ISO 4217 minor-unit exceptions); `EU`/`EURO`/`US$` are not valid 3-letter
  alpha-only codes; `XXX` is the reserved "no currency" code — all taken verbatim from
  `plugins/qaia-core/skills/oracle-generate/oracles/library.md`, not invented for this pilot.
- ISO 8601: 2024 is a leap year (divisible by 4, not by 100) → 2024-02-29 is a real date; 2023 is
  not a leap year → 2023-02-29 does not exist; 2100 is divisible by 100 but not by 400 → not a
  leap year → 2100-02-29 does not exist; April has 30 days → 2023-04-31 does not exist — same
  source file, same computed facts already used by the existing `examples/oracle-demo/`.
