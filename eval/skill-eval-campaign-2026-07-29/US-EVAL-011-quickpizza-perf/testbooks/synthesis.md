---
stepsCompleted: [testbook-generate]
lastStep: testbook-generate
lastSaved: 2026-07-30
---

# Synthesis — US-EVAL-011 (QuickPizza pizza recommendation)

**Scope**: pizza recommendation (`POST /api/pizza`) — authentication boundary, performance under
load (the project's own published k6 threshold example), structural field validation (7 conditions
generated, P1+P2 default scope; 2 conditions, AC1-C1/AC1-C2, deferred to P3 and not generated —
see waiver note below).
**Scenarios**: 7 atomic blocks, no `Scenario Outline`, + 0 `@smoke` journey (deliberately not
added — see "Coverage note" below).
**Negative ratio**: 3/7 blocks tagged `@negative` = 42.9 % (target ≥ 40 %, met without padding —
every negative traces to a real refusal condition from `03-design.md`; not blended with the three
`@boundary`-only performance scenarios (AC2-C1..C3) or with `001` (AC1-C3), whose proposed default
resolves to acceptance, not refusal — see "Tagging nuance" below for why those four are correctly
excluded from the `@negative` count despite two of them (`001`, `004`) carrying a `[req-neg]` tag
at the design stage).
**Coverage**: AC1 1/3 (2 deferred to P3 by default scope), AC2 3/3, AC3 3/3 — 7/9 conditions
generated.

## Tagging nuance — `[req-neg]` at design time vs. `@negative` at generation time

Two design-stage `[req-neg]` conditions did **not** become `@negative` scenarios, and this is
called out explicitly rather than silently smoothed over:

- **AC2-C3** (HTTP error rate < 1% under load) was tagged `[req-neg]` at `istqb-design` because it
  is "a rule that can... deny" service in the sense that failures are possible — but the condition
  itself, and its `Then`, assert the **positive** "stays within bound" outcome, not a refusal. Per
  `testbook-generate`'s own closed `@negative` definition ("a scenario whose outcome is a refusal,
  an error, or an explicitly denied access"), scenario `004` is correctly **not** tagged
  `@negative`. This is a real tag-mismatch between the design-stage `[req-neg]` marker and the
  generation-stage `@negative` tag's own closed definition — flagged here for human arbitration on
  whether `istqb-design`'s `[req-neg]` guidance should be worded more precisely for
  threshold-style (vs. refusal-style) conditions, not fixed silently in this run.
- **AC1-C3** (missing `Authorization` header) was also tagged `[req-neg]` at design time as an
  auth-boundary probe, but its proposed default (per Q1, `02-understanding.md`) is **acceptance**,
  not refusal — the same "generate the guessed side only as `@low-confidence` citing the question"
  rule `need-understanding` itself states for access-boundary questions. Scenario `001`'s `Then`
  therefore asserts non-rejection, and is correctly **not** `@negative` either.

## Coverage note — no happy-path scenario in this book

`AC1-C1` (fully-specified valid request) and `AC1-C2` (defaults-applied request) both land at P3
in `04-priorities.md` and are excluded by the default P1+P2 scope. Unlike US-EVAL-005's AC3-C2
precedent (a `[req-neg]` condition deferred to P3), these two are **not** `[req-neg]` — the
negative-path gate (ADR 0001) never applied to them, so their absence is a plain scope waiver, not
a gate exception. The practical consequence: **this book contains zero happy-path/positive-outcome
functional scenarios** — every generated scenario is either a performance-boundary assertion (AC2)
or a refusal/boundary probe (AC1-C3, AC3-C1..C3). A `@smoke` end-to-end journey scenario (the
"Journey exception" `istqb-design` and `testbook-generate` both describe, "at most one end-to-end
scenario per US... excluded from atomicity accounting") was considered but **not added**:
`istqb-design`'s own AC1 → technique map in `03-design.md` selected Equivalence Partitioning only,
never Scenario-Based Testing (§3.2.3) — adding a smoke journey now would generate coverage design
never authorized, exceeding what steps 1-4 actually posed (campaign protocol step 6: "Aucune
anticipation au-delà de ce que 1-4 ont posé"). This is flagged here as a real, worth-arbitrating
gap for the human gate, not silently patched by inventing a smoke scenario at generation time.

## By-technique table

| Technique | ACs | Scenarios | Justification |
|---|---|---|---|
| `@ep` | AC1, AC3 | `001` (+`006`) | Auth-boundary probe (equivalence class: missing-header); single-variable invalid class (negative calories) |
| `@boundary` | AC2 | `002, 003, 004` | The project's own published p95/p99/error-rate thresholds treated as boundary values under test (repurposed BVA, see `03-design.md`'s "Palette fit note") |
| `@domain-analysis` | AC3 | `005` | `minNumberOfToppings`/`maxNumberOfToppings`, two related variables with combined-coverage boundaries |

## Open / assumption / low-confidence list (full, per shared contract)

- **Q1** `[open]`, `@low-confidence` — **human arbitration required**: does `POST /api/pizza`
  require authentication at all? `001` encodes a *proposed* default (accepted without auth), not a
  confirmed behavior — every fetched k6 example script sends a token anyway, a signal this proposed
  default does not fully reconcile.
- **Q2** `[assumption]`, `@low-confidence` — the p95/p99/error-rate numbers in `002`, `003`, `004`
  are the project's own worked `05.thresholds.js` example against this exact endpoint, adopted as
  the working target because no separate official-SLO document was found — not confirmed as a
  contractual performance requirement by any source.
- **Q4** `[assumption]`, `@low-confidence` — `minNumberOfToppings > maxNumberOfToppings` is refused
  (`005`); a silent auto-swap is also plausible and not ruled out.
- **Q5** `[assumption]`, `@low-confidence` — negative `maxCaloriesPerSlice` is refused (`006`).
- **Q6** `[open]`, `@low-confidence` — **human arbitration required**: is an over-length
  `customName` refused or silently truncated, and what is `MaxPizzaNameLength`'s actual numeric
  value? `007` encodes a *proposed* default (refused) using an arbitrary large probe value, not the
  real (unknown) boundary.
- **Q3, Q7, Q8** — not directly generated as scenarios: Q3 (exact validation-error shape) has no
  concrete literal to assert given no source confirms it, so `005`/`006`/`007`'s `Then` steps stay
  qualitative ("the recommendation request is refused") rather than asserting a fabricated status
  code; Q7 (deployment mode) is an implicit precondition of AC2's scenarios, not a separate
  scenario; Q8 (concurrency-correctness) was explicitly waived at `istqb-design` as a black-box-scope
  gap, not designed here (see `03-design.md`, "Waived / not designed as a concrete condition").

## Deferred / waived conditions

- **AC1-C1, AC1-C2** — `P3` by `04-priorities.md`'s scoring (well-documented, low-probability
  input handling). Excluded from this book by the default P1+P2 scope — a standing, cited waiver,
  not a silent gap; still listed in `coverage-matrix.md`, with the resulting "no happy-path
  scenario" consequence flagged explicitly above.

## Out-of-slice (not designed here)

- User registration/login (`POST /api/users`, `POST /api/users/token/login`) — a separate US;
  obtaining a token (when/if required, per Q1) is a given precondition here, not designed in this
  slice.
- Ratings CRUD (`/api/ratings*`) — a separate US.
- Ingredient/dough/tool catalog management (`/api/ingredients/{type}`, `/api/doughs`,
  `/api/tools`) — a separate admin/content US.
- Browser-level real-browser performance testing (`k6/browser/`) and gRPC/WebSocket paths — sibling
  capabilities in the same repo, not this slice's API-level load target.
- **Live execution of a k6 load run or `perf-check`** — explicitly out of scope for this campaign
  run (see `00-source.md`, "Explicit non-goal"); AC2's scenarios above are written and structurally
  validated, but never executed against a running instance in this session.

## Sourcing honesty note

This US was captured entirely from QuickPizza's own public GitHub repository (`README.md`,
`pkg/http/http.go`, and the `k6/foundations/` example scripts, especially `05.thresholds.js`, the
project's own worked k6 threshold lesson against this exact endpoint) via `WebFetch` — **no live
instance was ever stood up or reached**, by explicit design of this campaign run (this sandboxed
worktree cannot be assumed to have Docker or the ability to expose a running instance). AC2's
performance thresholds are therefore grounded in a real, primary source (the project's own
teaching example, not an invented number), but that source's own status — a worked example vs. an
official SLO — is itself unconfirmed (Q2), and no scenario in this book has ever been executed: the
gate report below is silent on whether QuickPizza *actually* meets its own published thresholds,
only on whether this book's scenarios are structurally sound.

## Skill evaluation — `testbook-generate`

- **Skill evaluated**: `plugins/qaia-core/skills/testbook-generate/SKILL.md`.
- **Input**: `03-design.md` (9 conditions) and `04-priorities.md` (5 P1, 2 P2, 2 P3) above.
- **Output**: `quickpizza-recommendation.feature`, this synthesis, `coverage-matrix.md`,
  `state/generated.snapshot.md`.
- **Verdict**: **CONFORME.**
- **Evidence**: line 28's rule that a `[req-neg]` condition left at P3 by the default scope is not
  a silent gate violation "provided it still appears (condition ID + reason) in the coverage
  matrix/synthesis rather than vanishing from the count" does not literally apply to AC1-C1/AC1-C2
  (neither is `[req-neg]`), and this run correctly does not misuse that specific rule to justify
  the deferral — instead citing the plainer scope rule (step 1, "P1+P2 by default") and going
  further than the rule requires by surfacing the resulting "no happy-path scenario" consequence as
  its own flagged coverage note, rather than only listing the two IDs in the matrix. Line 19's rule
  for `[open]` conditions ("still gets its scenario, written with the proposed safe default...
  tagged `@low-confidence`, with an inline comment citing the question ID") is followed exactly by
  `001` and `007`. The `@negative` closed definition (line 34) was applied literally rather than
  mechanically inheriting the design-stage `[req-neg]` tag onto `002`, `004` — `004` and `001`
  correctly excluded from `@negative` despite the design-time tag, with the resulting tension named
  explicitly in this file's own "Tagging nuance" section rather than silently reconciled.
- **Modification proposed**: none.
