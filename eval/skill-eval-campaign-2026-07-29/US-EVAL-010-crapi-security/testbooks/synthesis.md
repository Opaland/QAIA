# Synthesis — US-EVAL-010 (crAPI: vehicle-location BOLA hardening, Challenge 1)

**Scope**: P1+P2 conditions only (5/6 conditions, default scope per `prioritize`'s Q22 quota
trade-off — the 1 P3 condition, `AC1-C1`, is listed in `state/04-priorities.md`, not generated
here, a human call deferred non-interactively).
**Scenarios**: 5 atomic blocks, 0 outlines (each in-scope condition is a single case), + 0 smoke
journey. A `@smoke` scenario would need to start from the owner happy path (`AC1-C1`) as its
baseline step — which is exactly the condition this run's P1+P2 scope deferred — so adding one
anyway would silently re-introduce a P3-deferred condition through the back door; skipped and
flagged rather than done quietly.
**Negative ratio**: 5/5 blocks tagged `@negative` = **100 %** (target ≥ 40 %, exceeded). Every
in-scope condition is a refusal/denial path (cross-owner leak prevention, authentication
enforcement, not-found convergence) — the mirror image of `US-EVAL-006`'s honest 0 %, and equally
unmassaged: this book has no happy-path condition in scope to pad the *other* direction with.
**Coverage**: AC2 2/2 (of the P1+P2 subset), AC3 2/2, AC4 1/1 — 5/5 in-scope conditions covered, 0
waived within scope. AC1 has 0/1 in-scope scenarios (its one condition is P3-deferred) — a real,
disclosed gap, not silently absent.
**Knowledge base**: absent for this campaign directory (recorded per shared-contract rule 8 and
`03-design.md` 3d) — this skill's own record, not only relying on the upstream checkpoint's note.

## Open / assumption / low-confidence list (full, per shared contract)

- **Q1** `[assumption]`, `@low-confidence` on `QAIA-US-EVAL-010-002` — **human arbitration welcome,
  not blocking**: should a cross-owner denial return `404` (adopted default, anti-disclosure) or
  `403` (exists, forbidden)? The underlying requirement (`QAIA-US-EVAL-010-001`, no data leak) does
  not depend on this answer.
- **Q2** `[assumption]` — "current location" is treated as an opaque per-vehicle attribute
  (presence/ownership-scoping asserted), not a live-GPS freshness guarantee; no scenario asserts
  real-time behavior. Does not gate any P1/P2 scenario directly (it shapes phrasing, not a distinct
  condition).
- **Q3** `[assumption]`, `@low-confidence` on `QAIA-US-EVAL-010-005` — a nonexistent `vehicleId`
  converges on the same `404` as `Q1`'s cross-owner default; both share the same open question about
  the exact status code.

## Ratio explainer

**Not needed** — the negative ratio (100 %) is well above the 40 % target; this is the shape a
security-authorization US-slice honestly produces (see `state/03-design.md`'s negative-pressure
section: the ratio's inverse, `US-EVAL-006`'s honest 0 %, is the other extreme this campaign has
now sampled from the same skill).

## Out-of-slice dependencies

- `docs/challenges.md` Challenges 2-18 (mechanic-report BOLA, password reset, unauthenticated
  endpoint discovery [Challenge 14 — a *different*, unrelated endpoint from this US's AC3], JWT
  forgery, mass assignment, SSRF, injection, LLM prompt injection) — same target, separate
  challenges, not designed here (see `state/00-source.md` dependencies).

## Review order

`@low-confidence` first (`QAIA-US-EVAL-010-002` [Q1], `QAIA-US-EVAL-010-005` [Q3]), then P1 → P2:
`001`, `003` (P1), then `002`, `004`, `005` (P2).

## By-technique table

| Technique | ACs | Scenarios | Justification |
|---|---|---|---|
| `@decision-table` | AC2 | `001`, `002` | The authentication × ownership-relation decision table in `03-design.md`, cross-tenant-access (IDOR) cells. |
| `@ep` | AC3 | `003`, `004` | Two invalid-authentication equivalence classes (absent vs invalid/expired token). |
| `@error-guessing` | AC4 | `005` | Classic BOLA/IDOR error-guessing catalog item, applied to the "nonexistent ID" partition. |

## Priority rationale (full — copied from `04-priorities.md` per the deliverable rule)

See `coverage-matrix.md`'s Rationale column for the one-line risk driver behind every scored
condition in scope. **Human arbitration welcome**: `QAIA-US-EVAL-010-002`/`Q1` and
`QAIA-US-EVAL-010-005`/`Q3` — the exact denial status code rests on an `[assumption]`, not a
literal source statement; `QAIA-US-EVAL-010-003`'s P1 rank (AC3-C1) also flagged in
`04-priorities.md` as a probability call deliberately not inflated to match AC2-C1's fully-confirmed
score, worth a second human look.

## Coverage matrix

See `testbooks/coverage-matrix.md` (linked, not duplicated here).

## Changelog

None — initial generation, no prior book existed for this US-ID.

## Sourcing honesty note

Grounded in **primary source** (`docs/challenges.md`'s Challenge 1, quoted verbatim, plus
`README.md`/`docs/overview.md`, all fetched directly from `OWASP/crAPI`'s own repo) for the
vulnerability class and its self-hosting story. The **concrete endpoint path**
(`/identity/api/v2/vehicle/{vehicleId}/location`) and response shape (latitude/longitude) are
`[secondary-source]`-flagged (corroborating third-party write-ups, not OWASP's own docs text) —
confidence on the vulnerability class itself is source-grade; confidence on the exact path/shape
and on the three `[assumption]`-flagged questions (Q1, Q2, Q3) is explicitly lower and not blended
into the rest. **No live execution occurred against any crAPI instance in this run** — see
`reports/testbook-validate-report.md`'s explicit limitation note; nothing here is a simulated scan
result.
