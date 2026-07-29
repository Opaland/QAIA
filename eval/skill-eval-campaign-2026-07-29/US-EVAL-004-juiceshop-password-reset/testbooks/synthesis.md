# Synthesis — US-EVAL-004 (Juice Shop password reset via security question)

**Scope**: P1+P2 default scope (10/11 conditions); AC4-C5 (P3, mismatched-repeat-password) is a
real, generated-but-optional trade-off explicitly waived per `prioritize`'s quota-trade-off rule
(`04-priorities.md`) — not silently dropped, listed below.

**Scenarios**: 8 atomic blocks (`006` and `007` are `Scenario Outline`s with 2 examples each,
counted as 1 block per D20's single definition) + 0 smoke journey (skipped — a single end-to-end
"forgot → answer → reset" journey scenario would only re-verify AC2-C1's own steps at higher
cost, out of proportion for a 4-AC slice, same call US-EVAL-001 made for SauceDemo).

**Negative ratio**: 4/8 blocks tagged `@negative` = 50 % (target ≥ 40 %, met without padding —
every negative here traces to a real refusal/rejection condition from `03-design.md`, none
invented to hit the ratio).

**Ratio explainer**: AC1's two conditions and AC2's one condition carry no refusal path by
themselves (AC1 is a lookup, AC2 is the happy path) — every negative in this book comes from AC3
(wrong-answer refusal, twice) and AC4 (boundary rejection, UI-bypass rejection). A book this size
sitting at 50 % rather than lower reflects that the security-relevant half of this US (AC3, plus
AC4-C6's UI-bypass) is disproportionately refusal-shaped, not padding.

**Coverage**: AC1 2/2, AC2 1/1, AC3 2/2, AC4 5/6 (1 waived, P3) — 10/11 conditions covered, 1
explicitly waived.

## Review order (per shared contract: `@low-confidence` first, then P1 → P3)

1. `QAIA-US-EVAL-004-002` (AC1-C2, Q1) — `@low-confidence`, `@P1`
2. `QAIA-US-EVAL-004-005` (AC3-C2, Q3) — `@low-confidence`, `@P1`
3. `QAIA-US-EVAL-004-008` (AC4-C6, Q4) — `@low-confidence`, `@P1`
4. `QAIA-US-EVAL-004-003` (AC2-C1) — `@P1`
5. `QAIA-US-EVAL-004-004` (AC3-C1) — `@P1`
6. `QAIA-US-EVAL-004-001` (AC1-C1) — `@P2`
7. `QAIA-US-EVAL-004-006` (AC4-C2/C3) — `@P2`
8. `QAIA-US-EVAL-004-007` (AC4-C1/C4) — `@P2`

## By-technique table

| Technique | ACs | Scenarios | Justification |
|---|---|---|---|
| Equivalence partitioning (`@ep`) | AC1 | 1 (`001`) | Registered-account email class, one representative |
| Decision table (`@decision-table`) | AC1, AC2, AC3 | 3 (`002`, `003`, `004`) | account-registered × answer-correct × password-shape-valid cross |
| Error guessing (`@error-guessing`) | AC3, AC4 | 2 (`005`, `008`) | Security-adjacent reflex conditions (rate-limiting facet, UI-bypass facet) not derivable from plain data partitioning |
| Boundary value analysis (`@boundary`) | AC4 | 2 (`006`, `007`) | 5-40 character length threshold, both accept and reject sides |

## Open / assumption / low-confidence list (full, per shared contract)

- **Q1** `[open]`, `@low-confidence` — **human arbitration required**: does the unauthenticated
  security-question lookup disclose whether an email belongs to a registered account? Scenario
  `QAIA-US-EVAL-004-002` encodes a *proposed* default (no disclosure), not a confirmed behavior —
  the highest security-relevance item in this book.
- **Q2** `[assumption]` — the wrong-answer refusal (`QAIA-US-EVAL-004-004`) is asserted
  qualitatively only; no specific message/status is asserted since none is sourced.
- **Q3** `[open]`, `@low-confidence` — **human arbitration required**: is repeated wrong-answer
  guessing ever throttled/blocked? Scenario `QAIA-US-EVAL-004-005` asserts only that each of 5
  attempts is individually refused, making no claim about a lockout existing or not.
- **Q4** `[open]`, `@low-confidence` — **human arbitration required**: does the backend
  independently re-enforce the password-shape rule if the UI's disabled control is bypassed?
  Scenario `QAIA-US-EVAL-004-008` encodes a *proposed* default (backend re-validates), not a
  confirmed behavior.

## Priority rationale — assignments needing human arbitration

All four `[open]`/`[assumption]` items above feed a priority assignment in `04-priorities.md`;
the three `[open]` ones (Q1, Q3, Q4) are exactly the three `P1` (impact 3 × probability 3)
assignments whose probability was bumped for open-status rather than earned by confirmed
complexity — see `04-priorities.md` for the full one-line rationale per condition (reproduced in
`coverage-matrix.md`'s rationale column below).

## Out-of-slice (not designed here)

- Logging in with the newly-set password (a separate login US).
- Account registration / initial security-question setup at signup.
- The missing-security-question account-takeover class of defect from GitHub issue #1634 — a
  distinct precondition ("no question configured") from anything AC1-AC4 assert here; noted as
  background only in `00-source.md`, not re-verified live, not designed as a scenario.

## Waived condition (P3, quota trade-off)

- **AC4-C5** (mismatched New Password / Repeat New Password, both individually valid length) —
  P3 (impact 2 × probability 1), below the default P1+P2 generation threshold. A real, generated-
  but-optional condition, not silently dropped — recorded here per the shared contract so a
  reviewer can request it explicitly.

## Skill evaluation — `testbook-generate` (`plugins/qaia-core/skills/testbook-generate/SKILL.md`)

- **Verdict**: `CONFORME`.
- **Preuve**: the generation-rules block (`SKILL.md` line 19, "Generating on `[open]` items —
  explicit rule") requires that a covered `[open]` condition still get a scenario "written with
  the *proposed safe default*..., tagged `@low-confidence`, with an inline comment citing the
  question ID" and forbids skipping it silently. Scenarios `002`, `005`, and `008` each carry
  exactly that shape: a `@low-confidence` tag, an inline `# open: Qn --` comment stating the
  proposed default and that it is unconfirmed, and a scenario title parenthetical ("proposed
  default, unconfirmed") — mirroring the precedent US-EVAL-001 set for its own `AC2-C2`/Q3
  scenario, applied here to three items instead of one.
- **Modification concrète proposée**: aucune.

## Sourcing honesty note

This US was captured from a live application render (Playwright, after an initial `WebFetch` 503)
plus official-documentation corroboration (`help.owasp-juice.shop`/`pwning.owasp-juice.shop`), not
a primary written ticket — see `00-source.md` for exact citations and what could not be observed
this session (the `/rest/user/security-question` API never returned a non-503 response). Every
scenario built on an unobserved behavior is tagged `@low-confidence` and listed above; nothing
beyond the directly-observed form fields/labels/validation text is asserted with full confidence.
