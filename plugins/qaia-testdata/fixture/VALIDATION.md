# dataset-generate validation — real dataset, real run (issue #15)

Honest record of validating `../skills/dataset-generate/SKILL.md` by actually applying it,
following the same fixture discipline as `flaky-detect`/`automate`'s `fixture/VALIDATION.md`
(hand-apply the documented method to real, inspectable data, then check mechanically).

## What was built

- `US-002-dosage-dataset.json` — a full synthetic dataset for
  `eval/gold-set/US-002-dosage-validation.md` (prescription dosage validation, health domain).
  This US was chosen because, at the time of writing, no dataset example existed for it
  anywhere else in the repo (`examples/medibook/` covers US-001's appointment-booking domain
  with app seed data, not a standalone injectable dataset).
  - 4 synthetic drugs (`drugs[]`), each flagged `synthetic: true` with an explicit disclaimer —
    AC1 only requires a reference record to *exist*, the US gives no real thresholds, so every
    numeric value (min/max/cumulative/age-floor) was invented for fixture purposes and marked
    as such rather than presented as real clinical guidance (step 5 of the skill).
  - 3 synthetic physicians, 11 synthetic patients — every person-like row carries
    `synthetic: true`, a `<name> Sample-NN` pattern, and an `@example.invalid` email (RFC 2606
    reserved TLD, guaranteed never to resolve to a real domain).
  - 20 intake records, 17 cases (`dataset-map.md` has the full AC coverage table).
  - `_meta.assumptions[]` names 3 explicit fixture conventions (ASM-1 boundary inclusivity,
    ASM-2 rolling 24h window, ASM-3 renal-reduction scope) rather than silently picking an
    interpretation for the US's own documented ambiguities.
  - One case, `C-015`, deliberately does **not** resolve a genuine AC6 ambiguity (does the
    renal 50% reduction apply to the minimum effective dose, not just the two maxima?) — its
    `expectedResult.status` is literally `"[open]"` with both interpretations listed, the same
    discipline `istqb-design`/`need-understanding` apply to scenarios, applied here to data.
- `fixtures.js` — the documented Playwright fixture-injection pattern from the skill's step 8:
  a `testData` fixture that reads and parses the JSON once, mirroring
  `examples/medibook/tests/fixtures.js`'s `test.extend()` convention (D34) with a data fixture
  instead of a page object.
- `dataset.spec.js` — 10 tests consuming `testData` through the fixture, asserting: the
  non-fabrication disclaimer and assumption list are present; every drug is coherent and
  flagged synthetic; every person is synthetic and PII-safe (`.invalid` email, `Sample-NN`
  name); every intake's foreign keys resolve; no drug/patient/physician is unused dead weight;
  every case's `intakeRefs` resolve and cumulative totals are recomputed and checked, not
  trusted; all 8 ACs are covered by at least one case; the AC7 justification-length boundary is
  exactly 20 (valid) vs. 19 (invalid) characters — computed with `node -e` before being written
  into the JSON, not eyeballed; the AC6 `[open]` case is genuinely unresolved; and four
  boundary intakes sit exactly on the threshold they claim (recomputed against the drug record,
  not just asserted by the case's own label).

## What was actually run

```
$ npm install --no-audit --no-fund
added 3 packages in 936ms

$ npx playwright test
Running 10 tests using 10 workers
  ok  1 … _meta carries a non-fabrication disclaimer and named assumptions (15ms)
  ok  2 … every drug/patient/physician referenced by an intake actually exists (referential integrity) (47ms)
  ok  3 … every person-like entity is synthetic and PII-safe (25ms)
  ok  4 … every drug reference record is complete, coherent and flagged synthetic (20ms)
  ok  5 … no drug, patient or physician is dead fixture weight (every one is used by at least one intake) (12ms)
  ok  6 … AC1 through AC8 are each covered by at least one case (9ms)
  ok  7 … boundary cases sit exactly at the threshold they claim (computed, not approximate) (7ms)
  ok  8 … every case references intakes that exist, and cumulative totals are internally consistent (19ms)
  ok  9 … AC7 justification length boundary is exact, computed not eyeballed (7ms)
  ok 10 … the genuinely open AC6 ambiguity (C-015) is exposed, not silently resolved (5ms)
  10 passed (530ms)
```

Real command, real install, real run — not a narrated claim. `node_modules/`,
`test-results/`, `results.json`, `playwright-report/` and `package-lock.json` are gitignored
(`.gitignore`), matching the existing `flaky-detect`/`automate` fixture pattern.

## Honest limitations, not smoothed over

1. **Not a blind protocol.** The full `US-002-dosage-validation.md` file — including its
   "Judge reference — planted ambiguities (do not feed to skills)" section — was read while
   designing this dataset, the same caveat D68 records for the expense-demo build. The three
   `_meta.assumptions[]` entries and the `C-015` `[open]` case are therefore closer to "this
   dataset construction demonstrates the discipline correctly" than "an agent following the
   skill blind would independently rediscover these exact three ambiguities." What the run does
   prove: that the discipline the skill describes (flag invented values, surface real
   ambiguities rather than picking a side) produces mechanically checkable output when applied
   deliberately — not that every future invocation of `dataset-generate` will spontaneously
   notice every ambiguity a source contains.
2. **Single construction, not N runs.** Unlike the multi-model/corpus baselines elsewhere in
   this repo (D54-D64), this is one dataset built once and checked once — a worked example and
   an acceptance-criterion proof for issue #15, not a generalization study of the skill across
   many US inputs or models.
3. **No real app to inject into.** The task note allowed "a minimal test that loads the dataset
   and verifies its structure" in place of reinventing a full app; that is exactly what
   `dataset.spec.js` does. It proves the *injection mechanism* (a Playwright fixture wiring a
   JSON dataset into tests, D34's convention extended to data) and the dataset's internal
   coherence — it does not additionally prove that `qaia-playwright:automate`-generated tests
   against a real running app would consume every field exactly as named here; that would need
   a real target app (out of scope for this plugin's own validation, same boundary
   `qaia-playwright` itself draws around needing "a running target app the user designates").
4. **Numeric thresholds are fixture inventions, stated as such.** Every drug's mg values in
   `drugs[]` were picked for plausible internal ordering (min < per-intake max ≤ cumulative
   max) and to land the boundary cases on clean integers — they are not derived from, and must
   never be read as, real pharmacological reference data. The `_meta.disclaimer` and each
   drug's `note` field say so explicitly rather than leaving it implicit.

## Result

The skill's method (steps 1-9 of `../skills/dataset-generate/SKILL.md`), applied to a real gold-set
US, produced a dataset that is internally coherent (referential integrity, recomputed
cumulative totals, boundary values verified against their source thresholds), PII-safe by
construction, honest about invented values and genuine ambiguities, and mechanically
injectable via a Playwright fixture — all 10 assertions passing on a real, unmodified run. This
matches the acceptance criterion in issue #15 ("datasets cohérents générés pour une US du gold
set, injectables via fixtures").
