---
stepsCompleted: [00-ingest, 01-review, 02-understanding, 03-design, 04-priorities, 05-generate]
lastStep: 05-generate
lastSaved: 2026-07-29
---

# Synthesis — US-006: Role-based post visibility and field locking

**Date**: 2026-07-29. **Mode**: non-interactive pilot run — every `⚠ VALIDATION` checkpoint is
recorded as `simulated: accepted-as-is`.

## Headline counts

- **Scenarios**: 23 blocks total (22 atomic + 1 `@smoke` journey). By priority: **P1 = 14, P2 = 8**
  (P3 = 0 generated, 3 waived — see below).
- **Negative-path coverage (ADR 0001)**: **16 / 16** required-negative conditions covered — the
  blocking gate is met.
- **Raw negative ratio (D20 signal, not a gate)**: 14/22 = **63.6 %**.
- **Open ambiguities**: 10 questions raised in `need-understanding` (Q1-Q10); **2 remain
  `[open]`** (Q1, Q9), **8 resolved to `[assumption]`** with a recorded safe default.
- **AC coverage**: 6/6 (AC1 covered compositionally — see the technique table).

## Full numbered question list (from `state/US-006/02-understanding.md`)

1. **`[open]`** — Does refusing a non-published post to an unauthorized viewer mean an explicit
   refusal on direct view, silent exclusion from list results, or both? *Generated both sides
   (@QAIA-US-006-005, -006) as `@low-confidence`, citing Q1.*
2. **`[assumption]`** — Post-level visibility gates before field-level locks apply. *Structural,
   not separately scenario'd — assumed throughout.*
3. **`[gap]`** — The field-lock configuration mechanism (per-post vs per-schema) is not described
   — a config-driven family `istqb-design` explicitly forbids inventing; scenarios assert a lock
   as a given precondition without asserting its configuration origin.
4. **`[assumption]`** — A post's owner sees their own author-identity fields on their own post.
   *@QAIA-US-006-011, `@low-confidence`.*
5. **`[assumption]`** — Private mode's block on anonymous post-creation overrides AC2's general
   allowance, for anonymous users only. *@QAIA-US-006-015, `@low-confidence`.*
6. **`[assumption]`** — A manager cannot delete media owned by another user (default-deny for a
   destructive action). *@QAIA-US-006-022, `@low-confidence`.*
7. **`[assumption]`** — An admin can delete any media regardless of ownership (AC1's "full
   access"). *@QAIA-US-006-021, `@low-confidence`.*
8. **`[assumption]`** — The unnamed "other non-public status" is treated as one generic
   not-published partition. *@QAIA-US-006-004, `@low-confidence`.*
9. **`[open]`** — Does the registration-disabled toggle also block an admin's direct,
   out-of-band account creation? *Generated the proposed default (@QAIA-US-006-018,
   `@low-confidence`), citing Q9.*
10. **`[assumption]`** — Private mode restricts anonymous users only; other roles keep normal
    access. *@QAIA-US-006-016, `@low-confidence`.*

## Ratio explainer

The 63.6 % negative ratio is high, not marginal, so no explainer is strictly needed for a
below-threshold case — but for calibration: AC2 and AC5 (post-status and private-deployment
gating) carry almost all the refusal paths (10 of the 16 required-negatives), because this US is,
by nature, an access-control feature where "who is refused" is the headline behavior. AC4's
positive identity-access scenarios (010, 011) and AC3/AC6's admin-capability scenarios (008, 020,
021) are the deliberate happy-path counterweight, not padding.

## Out-of-slice dependencies

None recorded — `00-source.md`'s dependency scan found no sibling-story references. The three
referenced-but-undefined terms (unnamed non-public status, field-lock configuration mechanism,
full "manage posts" permission set) are **within-slice underspecification**, not out-of-slice
answers living in another story — they are handled as `[assumption]`/`[gap]` items above, not
deferred to a sibling.

## Review order

`@low-confidence` first: 004, 005, 006, 011, 015, 016, 018, 021, 022 — then **P1 -> P2 -> P3**
among the rest: 001, 002, 007, 009, 012, 013, 014, 019 (remaining P1), then 003, 008, 010, 017,
020 (P2), then the `@smoke` journey (023) last, then the 3 waived P3 conditions (informational
only, not generated).

## By-technique table

| Technique | ACs | Scenario count | Justification |
|---|---|---|---|
| State Transition Testing | AC2 | 6 (001, 002, 003, 004, 005, 006) | Post status (draft/published/other) drives a visibility decision — transition pairs (owner/non-owner x status) tested including one forbidden-state view. |
| Decision Table Testing | AC3, AC4, AC5 | 12 (007, 008, 009, 010, 011, 012, 013, 014, 015, 016, 017, 018) | Role x field-lock, role x identity-field, and private-flag x role x action are all combinations-of-conditions-to-actions — the canonical decision-table shape. |
| CRUD Testing (`@crud`) | AC6 | 4 (019, 020, 021, 022) | Media deletion is the delete leg of a full lifecycle, driven by an ownership check — the lifecycle pattern itself, not a plain state field. |
| Error Guessing | AC2 | 2 (005, 006) | Anchored on the ambiguity log (Q1) — the two competing refusal shapes a mature tester would probe when the source is silent on request-shape-specific behavior. |
| Scenario-Based Testing (`@use-case`) | AC2, AC3, AC4, AC6 | 1 (023, `@smoke`) | The single allowed end-to-end journey scenario, excluded from atomicity/negative-ratio accounting. |
| Equivalence Partitioning | AC1 (foundational, no dedicated scenario) | 0 dedicated | Defines the role/config partitions every scenario above varies over — covered compositely. |

**Oracle-generate**: invoked, found no applicable standardized domain (email in AC4 is an
exposure concern, not a format-validation one; no API contract designated) — `design.oracles = []`,
a documented "not applicable" outcome.

**Knowledge base**: absent this run — `design.knowledgeApplied = []`, recorded per degraded-mode
rule 8, not silently omitted.

## Priority rationale + arbitration list

The full one-line rationale per assignment lives in `coverage-matrix.md` (copied verbatim from
`state/US-006/04-priorities.md`, rubric dim. 9). **Every row this pilot pass is
`simulated: accepted-as-is`** — no human score override occurred (first pass, nothing to
diverge from). The 9 `@low-confidence` scenarios (004, 005, 006, 011, 015, 016, 018, 021, 022)
are the full list needing human arbitration before this book is treated as fully validated.

## Coverage matrix

See `coverage-matrix.md` (linked, not duplicated here).

## Changelog

None — this is the initial generation, no regeneration has occurred yet.
