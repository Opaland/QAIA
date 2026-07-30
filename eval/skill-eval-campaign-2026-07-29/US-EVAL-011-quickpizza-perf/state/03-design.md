---
stepsCompleted: [00-ingest, 01-review, 02-understanding, 03-design]
lastStep: 03-design
lastSaved: 2026-07-30
---

# 03-design — US-EVAL-011

## AC → technique map

- **AC1** (valid recommendation) → **Equivalence partitioning** (fully-specified `Restrictions`
  class vs. omitted-fields/defaults-applied class — both are valid-input partitions, per
  `pkg/http/http.go`'s documented field defaults).
- **AC2** (performance under load) → **Boundary Value Analysis**, applied to the project's own
  published thresholds (`05.thresholds.js`) treated as the boundary values under test: the p95 and
  p99 latency ceilings and the error-rate ceiling are each a boundary the load run must stay under.
  This is a genuine palette limitation worth naming explicitly (see "Palette fit note" below):
  CTAL-TA v4.0's black-box functional techniques were not built for non-functional/performance ACs,
  so BVA is repurposed here on the *declared threshold values themselves*, not on a functional input
  domain — the closest legitimate fit in the current palette, not a forced match.
- **AC3** (structural validation) → **Domain Testing** (§3.1.1) for `minNumberOfToppings` vs.
  `maxNumberOfToppings` — two related variables each carrying their own boundary, needing combined
  (not isolated) coverage, exactly Domain Testing's own trigger condition — plus **Equivalence
  partitioning** for the single-variable invalid classes (`maxCaloriesPerSlice` negative,
  `customName` over-length).

## Palette fit note (transparency, not a design defect)

AC2 is a non-functional (performance) acceptance criterion. QAIA's technique palette
(`istqb-design/SKILL.md`) is explicitly black-box/functional (D110) and does not carry a dedicated
performance-testing technique — CTAL-TA v4.0's own chapter 3 taxonomy is functional too. BVA is
applied here to the *threshold numbers* (is the run's measured p95 under or at/over 500ms) rather
than to a functional input domain, which is a defensible but non-standard use of the technique.
The Gherkin scenario this produces (`testbook-generate`, below) can state the *expected outcome*
qualitatively ("the p95 stays under 500ms") but **cannot itself execute a load run** — only a real
k6/`perf-check` execution against a live instance produces the measured value the `Then` step
would check. This is recorded plainly rather than glossed over.

## Sub-step 3b — standardized domain → oracle (not triggered)

No field in AC1-AC3 matches a standardized public domain (no dates, card numbers, emails, IBANs).
`maxCaloriesPerSlice`, `maxNumberOfToppings`, `minNumberOfToppings` and the latency/error-rate
thresholds are project-internal or example-specific numbers, not a public standard to cite.
`oracle-generate` not invoked — correctly waived, not silently skipped.

## Sub-step 3c — systematic coverage expansion (applied where triggered, waived elsewhere)

- **List/collection view** — not triggered: `POST /api/pizza` returns a single recommendation
  object, not a list. Waived.
- **Entity → full CRUD lifecycle** — not triggered: a pizza recommendation is generated, not
  created/read/updated/deleted as a persistent entity in this slice (the sibling `/api/ratings`
  resource has its own CRUD lifecycle, out-of-slice per `00-source.md` dependencies). Waived.
- **Conditional behavior (decision table over variation axes)** — not triggered as a full
  multi-axis decision table: AC3's fields are validated largely independently, with the one
  genuinely combined case (`minNumberOfToppings` vs `maxNumberOfToppings`) already captured by
  Domain Testing above rather than needing a separate decision table.
- **Authorization & server-side enforcement** — **triggered**: this is exactly **Q1** from
  `02-understanding.md` (unauthenticated access to `POST /api/pizza`) — derived below as an
  `[open]` condition per the adversarial-pass rule, not silently skipped despite the conflicting
  signals in the source (README's "no auth requirements mentioned" summary vs. every fetched k6
  example sending an `Authorization` header).
- **Enumerate every list/aggregation view** — not applicable, no list view exists in scope. Waived.
- **Sibling collections of a named entity** — not triggered: a pizza recommendation is not
  described as "a collection of X" with an implied child sub-collection the source doesn't name.
  Waived.
- **Account & auth features → recovery path** — not triggered: login/registration is a sibling,
  out-of-slice capability (`00-source.md` dependencies); this US's slice is the recommendation
  action itself, not the auth feature. Waived.

## Sub-step 3d — knowledge-driven conditions

No `knowledge/index.md` exists for this campaign directory (no team knowledge base was ever
initialized here). Recorded per shared-contract rule 8 (degraded mode): proceeding on the source
alone, nothing invented to compensate.

## Test conditions

- **AC1-C1** `[ep]` — a fully-specified, valid `Restrictions` object → `HTTP 200`, a
  `PizzaRecommendation` returned respecting the stated constraints (vegetarian flag honored,
  excluded ingredients/tools absent from the result).
- **AC1-C2** `[ep]` — an empty/partial `Restrictions` object (fields omitted) → `HTTP 200`,
  documented defaults applied (`maxCaloriesPerSlice=1000`, `maxNumberOfToppings=5`,
  `minNumberOfToppings=3`), a valid `PizzaRecommendation` returned.
- **AC1-C3** `[ep]` `[req-neg]` `[open]` `@low-confidence` (Q1) — a request with no `Authorization`
  header → **proposed default**: accepted (`HTTP 200`), matching the README's own "no
  authentication requirements mentioned" summary; genuinely open because every fetched k6 example
  script sends a token anyway, and no source explicitly reconciles the two signals — human
  arbitration needed before trusting this default.
- **AC2-C1** `[boundary]` — under a sustained concurrent load run against `POST /api/pizza`, the
  measured 95th-percentile response time stays under 500ms (the project's own
  `05.thresholds.js` threshold, adopted per Q2's proposed default).
- **AC2-C2** `[boundary]` — under the same load run, the measured 99th-percentile response time
  stays under 1000ms.
- **AC2-C3** `[boundary]` `[req-neg]` — under the same load run, the HTTP error rate (non-2xx /
  failed requests) stays under 1%.
- **AC3-C1** `[domain-analysis]` `[req-neg]` `[assumption]` `@low-confidence` (Q4) —
  `minNumberOfToppings` greater than `maxNumberOfToppings` in the same request → creation refused
  (proposed default; a silent auto-swap is also plausible for a playful demo app and is not ruled
  out by any source).
- **AC3-C2** `[ep]` `[req-neg]` `[assumption]` `@low-confidence` (Q5) — `maxCaloriesPerSlice`
  negative → refused rather than silently clamped to 0/default.
- **AC3-C3** `[ep]` `[req-neg]` `[open]` (Q6) — `customName` far exceeding a plausible length
  (probe value, exact `MaxPizzaNameLength` unknown) → **proposed default**: refused; genuinely open
  because neither the numeric bound nor the behavior at that bound is confirmed by any source —
  human arbitration needed, and the probe value itself is only a stand-in for the real (unknown)
  boundary.

## Waived / not designed as a concrete condition

- **Q8** (cross-request contamination under concurrent load) — not designed as a concrete
  `Then`-assertable Gherkin condition: this is an implementation-internals question (shared mutable
  state, race conditions) that QAIA's black-box scope (D110) cannot assert with a testable
  black-box oracle from the outside without also asserting *how* the SUT is implemented. Recorded
  here as an explicit gap for the user/human arbiter, not silently dropped, and not fabricated into
  a scenario QAIA has no grounded way to write a real assertion for.

## Journey

| Step | Status |
|---|---|
| 03-design | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) |

## Skill evaluation — `istqb-design`

- **Skill evaluated**: `plugins/qaia-core/skills/istqb-design/SKILL.md`.
- **Input**: `02-understanding.md` above (3 ACs — one perf-typed — 8 logged questions).
- **Output**: this file.
- **Verdict**: **CONFORME.**
- **Evidence**: `SKILL.md` line 98 requires that "each of sub-steps 3b/3c/3d must appear in the
  checkpoint with its outcome... never silently absent" — all three have their own headed section
  above with per-bullet outcomes, including 3c's "Authorization & server-side enforcement" bullet,
  which is the one this campaign's own `SKILL.md` line 103 note flags as historically the
  most-often-missed pattern — correctly triggered here (Q1/AC1-C3) rather than skipped. Domain
  Testing (§3.1.1) is applied to exactly the case its own table row describes ("several related
  variables each carrying their own boundaries, needing combined coverage") for
  `minNumberOfToppings`/`maxNumberOfToppings`, not over-applied to single-variable fields that
  plain EP/BVA already cover — avoiding the opposite failure mode of technique over-reach. Line 102
  ("every technique choice must cite its justification") is honored, including for the
  non-standard AC2 case, where the "Palette fit note" section names the limitation explicitly
  rather than silently forcing BVA to look like a natural fit.
- **Modification proposed**: none.
