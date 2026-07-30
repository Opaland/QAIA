---
stepsCompleted: [00-ingest, 01-review, 02-understanding, 03-design]
lastStep: 03-design
lastSaved: 2026-07-29
---

# 03-design — US-EVAL-005

## AC → technique map

- **AC1** (create with valid fields, field-content correctness) → **Equivalence partitioning**
  (valid-fields class vs. invalid-content classes) extended by **Boundary Value Analysis** on
  `pc_duration` (the ≤0 boundary, Q5) and on `pc_eventDate` (the past/future boundary, Q4).
- **AC2** (authentication/authorization) → **Decision Table Testing** — token presence (missing /
  expired-or-revoked / valid) × `pid` scope (in-scope / out-of-scope, Q6) × request field validity
  (valid / invalid, Q9) crossed against one "created / refused" action is a genuine multi-axis
  combination, not opportunistic pair-picking.
- **AC3** (structural field validation) → **Equivalence partitioning** (complete-and-well-formed
  class vs. missing-field / nonexistent-reference / malformed-format classes) plus a
  **standardized-domain oracle** (ISO 8601) on `pc_eventDate`/`pc_startTime`'s format.

## Sub-step 3b — standardized domain → oracle (applied)

`pc_eventDate` (`YYYY-MM-DD`) and `pc_startTime` (`HH:MM:SS`) are both **ISO 8601**-shaped fields
→ `oracle-generate` (built-in library, no network/no project file needed) invoked. Applied: two
grounded negative conditions (`AC3-C4` malformed date, `AC3-C5` malformed time) tagged
`@oracle:iso8601`, using the standard's own invalid-corpus cases (a non-existent calendar date
like `2024-02-30`, an out-of-range month/day like `2024-13-01`, a malformed separator) rather than
guessing what "malformed" means. No other AC field matches a standardized domain: `pc_catid`,
`pc_title`, `pc_facility` and `pid` are project-internal identifiers, not a public standard, and
`pc_duration` is covered by plain boundary analysis (Q5), not a standardized-format oracle.

## Sub-step 3c — systematic coverage expansion (applied where triggered, waived elsewhere)

- **List/collection view** — not triggered: this US's slice is the create action only; the `s`
  (Search) permission's list/query behavior is a sibling capability, out-of-slice per
  `00-source.md` dependencies. Waived.
- **Entity → full CRUD lifecycle** — triggered on the `appointment` entity (the documented `crus`
  permission set implies create/read/update/search all exist), but only **create** is in this
  US's slice; read/update/search are out-of-slice, and **delete/cancel is not even a documented
  permission** for this resource (Q8) — **waived**, recorded as a dependency, not silently
  dropped.
- **Conditional behavior (decision table over variation axes)** — triggered: this *is* AC2's
  decision table (token state × `pid` scope × field validity).
- **Authorization & server-side enforcement** — triggered: unauthenticated access (`AC2-C1`) and
  cross-tenant/IDOR access to a `pid` outside the caller's scope (`AC2-C3`, Q6) are both derived
  here, exactly the pattern this sub-step names by example.
- **Enumerate every list/aggregation view** — not applicable, no list view exists in scope (same
  reasoning as the first bullet). Waived.
- **Sibling collections of a named entity** — not triggered: an `appointment` is not itself
  described as "a collection of X" with an implied child entity carrying its own sub-collections
  the source doesn't name. Waived.
- **Account & auth features → recovery path** — not triggered: this US is a scheduling capability,
  not an account/credential feature; no login/password/recovery flow is implied here (same
  reasoning US-EVAL-002 applied, correctly distinct from the campaign's earlier login-US run where
  this bullet *was* the directly-triggered one). Waived.

## Sub-step 3d — knowledge-driven conditions

No `knowledge/index.md` exists for this campaign directory (no team knowledge base was ever
initialized here). Recorded per shared-contract rule 8 (degraded mode): proceeding on the source
alone, nothing invented to compensate.

## Test conditions

- **AC1-C1** `[ep]` — authenticated caller, all required fields valid (`pc_catid`, `pc_title`,
  `pc_duration=1800`, a future `pc_eventDate`, well-formed `pc_startTime`, valid `pc_facility`,
  valid `pid` in-scope) → appointment created, returned in `data`. (Also the AC3 "complete and
  well-formed" happy-path class — one scenario covers both, not duplicated.)
- **AC1-C2** `[boundary]` `[req-neg]` `[assumption]` `@low-confidence` (Q5) — `pc_duration: 0` (or
  negative) → creation refused.
- **AC1-C3** `[boundary]` `[req-neg]` `[assumption]` `@low-confidence` (Q4) — `pc_eventDate` in
  the past → creation refused.
- **AC1-C4** `[decision-table]` `[req-neg]` `[open]` `@low-confidence` (Q1) — a new appointment
  request overlaps an existing appointment for the same `pc_facility` and time window →
  **proposed default**: refused; real EHR practice often allows intentional overbooking, so this
  is genuinely open, human arbitration needed before trusting this assertion.
- **AC2-C1** `[decision-table]` `[req-neg]` — no `Authorization: Bearer` header supplied →
  creation refused.
- **AC2-C2** `[decision-table]` `[req-neg]` `[assumption]` `@low-confidence` (Q7) — an
  expired/revoked Bearer token supplied → creation refused (standard OAuth2 behavior assumed for
  this endpoint, not independently confirmed).
- **AC2-C3** `[decision-table]` `[req-neg]` `[open]` `@low-confidence` (Q6) — authenticated with a
  valid token, but `pid` references a patient outside the caller's authorized
  site/facility scope → **proposed default**: refused; the exact error shape and whether scoping
  is even enforced is genuinely open, human arbitration needed.
- **AC2-C4** `[decision-table]` `[req-neg]` `[open]` `@low-confidence` (Q9) — a request that is
  **both** unauthenticated **and** structurally invalid (e.g. missing `pid`) → **proposed
  default**: the 401 (auth failure) wins and no field-validation detail is disclosed; genuinely
  open, human arbitration needed before trusting which check runs first.
- **AC3-C2** `[ep]` `[req-neg]` — `pid` omitted entirely from the request body → creation refused
  via `validationErrors` (directly stated by the source's documented error channel, not an
  inferred default).
- **AC3-C3** `[ep]` `[req-neg]` `[assumption]` (Q3) — `pc_facility` references a facility ID that
  does not exist → creation refused via `validationErrors`.
- **AC3-C4** `[ep]` `[req-neg]` `[assumption]` (Q2) — `pid` is well-formed but references no
  existing patient record → creation refused via `validationErrors`.
- **AC3-C5** `[ep]` `[req-neg]` `@oracle:iso8601` — `pc_eventDate` is not a valid ISO 8601 calendar
  date (e.g. `2024-02-30`, a non-existent day) → creation refused via `validationErrors`.
- **AC3-C6** `[ep]` `[req-neg]` `@oracle:iso8601` — `pc_startTime` is not a valid ISO 8601 time
  (e.g. `25:00:00`, an out-of-range hour) → creation refused via `validationErrors`.

## Journey

| Step | Status |
|---|---|
| 03-design | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) |

## Skill evaluation — `istqb-design`

- **Skill evaluated**: `plugins/qaia-core/skills/istqb-design/SKILL.md`.
- **Input**: `02-understanding.md` above (3 ACs, 9 logged questions).
- **Output**: this file.
- **Verdict**: **CONFORME.**
- **Evidence**: `SKILL.md` line 103's own guardrail flags that a 3c sub-step with no mention at
  all is a defect, specifically citing the "account & auth recovery path" bullet as the one
  historically missed. This run's `## Sub-step 3c` section addresses every named bullet explicitly,
  including that exact recovery-path bullet — correctly marked "not triggered" with a stated
  reason (this is a scheduling capability, not an account/credential feature) rather than omitted.
  Line 98 requires 3b/3c/3d to each "appear in the checkpoint with its outcome... never silently
  absent" — all three sub-steps have their own headed section with per-bullet outcomes above. The
  ISO 8601 oracle invocation (line 76, "sub-step 3b") correctly triggers only on the two fields
  that are genuinely standardized-format (dates/times per that line's own example list), not on
  `pc_catid`/`pid`/`pc_facility`, which are project-internal identifiers with no public standard to
  cite — avoiding the opposite failure mode of over-applying an oracle where none grounds it.
- **Modification proposed**: none.
