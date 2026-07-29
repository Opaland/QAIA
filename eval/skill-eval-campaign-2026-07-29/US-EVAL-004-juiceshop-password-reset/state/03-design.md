# 03-design — US-EVAL-004

## AC → technique map

- **AC1** (email → security-question lookup) → **Equivalence partitioning** (registered vs. an
  email that is not a registered account), extended into the decision table below since the
  "unregistered" side crosses with the disclosure question (Q1).
- **AC2** (correct answer + valid new password → success) → **Decision Table Testing** — the
  natural technique once "account registered", "answer correct" and "password shape valid" are
  treated as independent condition columns feeding one outcome, not picked as opportunistic pairs.
- **AC3** (wrong answer → refused) → **Decision Table Testing** (same table, wrong-answer branch)
  plus **Error guessing** for the repeated-attempts / rate-limiting facet (Q3), which is not a
  data-partition but a behavioral-security guess.
- **AC4** (password shape: 5-40 chars, must match) → **Boundary Value Analysis** on the length
  threshold (4/5/40/41), plus **Equivalence partitioning** on the match/mismatch axis of the two
  password fields.

## Decision table (account-registered × answer-correct × password-shape-valid)

| Account registered? | Answer correct (if registered)? | Password shape valid (5-40, matching)? | Outcome | Condition |
|---|---|---|---|---|
| Yes | Yes | Yes | Password changed, "Change" succeeds | AC2-C1 |
| Yes | No | Yes | Refused, password unchanged (generic refusal — Q2 assumption) | AC3-C1 |
| Yes | No (5x consecutive) | Yes | Each attempt individually refused; **whether a further attempt is ever blocked is `[open]` (Q3)** | AC3-C2 |
| No | — | — | **Response shape `[open]` (Q1)** — proposed default below: indistinguishable from the registered-account lookup, no account-existence disclosure | AC1-C2 |
| Yes | (n/a — form never becomes submittable) | No | "Change" stays disabled, validation message shown, no submission occurs | AC4-C1..C5 (below) |

## Test conditions

- **AC1-C1** `[ep]` — a registered account's email (`admin@juice-sh.op`, the project's own
  documented seeded account) is entered → the unauthenticated security-question lookup fires
  (directly observed request shape in `00-source.md`); the account's own question is expected to
  be surfaced for the user to answer (the exact question text is not asserted — not confirmed
  live, per `00-source.md`; the scenario asserts the field becomes usable, not a specific string).
- **AC1-C2** `[decision-table]` `[open]` `@low-confidence` (Q1) — an email that is **not** a
  registered account is entered → **proposed default** (the safer security posture, and the only
  one this run can defend without a live observation): the response gives **no distinguishable
  signal** that the account doesn't exist (no error message naming "unknown account", no HTTP
  status difference asserted) — genuinely open, human arbitration needed; this is the
  highest-security-relevance item in this book, mirroring US-EVAL-001's AC2-C2/Q3 pattern of
  generating the proposed default rather than skipping.
- **AC2-C1** `[decision-table]` — registered account, correct security-question answer, New
  Password/Repeat New Password matching and 5-40 chars → password changed, "Change" succeeds.
- **AC3-C1** `[decision-table]` `[req-neg]` — registered account, **incorrect** answer, otherwise
  valid password fields → refused, password not changed. Refusal asserted qualitatively only
  (Q2 assumption — no specific message/status sourced).
- **AC3-C2** `[error-guessing]` `[req-neg]` `[open]` `@low-confidence` (Q3) — registered account,
  5 consecutive wrong answers submitted → each individually refused (this much is asserted with
  confidence, since it follows directly from AC3-C1 repeated); **whether a 6th/Nth attempt is
  ever throttled/blocked is explicitly not asserted either way** — open, flagged for human
  arbitration rather than guessed.
- **AC4-C1** `[boundary]` `[req-neg]` — New Password 4 characters (min−1) → "Change" stays
  disabled, "Password must be 5-40 characters long." shown.
- **AC4-C2** `[boundary]` — New Password exactly 5 characters (min), matching repeat → valid,
  combines with AC2-C1's flow.
- **AC4-C3** `[boundary]` — New Password exactly 40 characters (max), matching repeat → valid.
- **AC4-C4** `[boundary]` `[req-neg]` — New Password 41 characters (max+1) → "Change" stays
  disabled, same validation message.
- **AC4-C5** `[ep]` `[req-neg]` — New Password and Repeat New Password both individually valid
  length but **not equal to each other** → "Change" stays disabled, no submission occurs.
- **AC4-C6** `[error-guessing]` `[req-neg]` `[open]` `@low-confidence` (Q4, UI-bypass reflex,
  istqb-design 3c "Authorization & server-side enforcement") — the client-side length/match rule
  is submitted directly against the backend, bypassing the disabled UI control → **proposed
  default**: the backend independently re-enforces the same rule (defense-in-depth is the safer
  assumed default for an auth-adjacent endpoint) — unconfirmed this session, open.

## Sub-step trace (3b/3c/3d — each recorded, never silently absent)

- **3b (oracle-generate, standardized domain)**: not applicable — this US touches no standardized
  domain from the trigger list (card/Luhn, ISO 8601 dates, HTTP status codes as a *tested* value,
  RFC 5322 email as a *tested* value, currency, IBAN); the email field is used as an input, not
  itself validated against RFC 5322 by any AC here. Correctly a no-op, recorded not silently
  skipped.
- **3c (systematic coverage expansion)**: applied. This whole US instantiates the **"Account &
  auth features → include the recovery path"** trigger itself (istqb-design line 85) — it *is*
  that derived pattern, not a feature that additionally needs it. Beyond that: the
  **"Authorization & server-side enforcement"** trigger applied directly, yielding AC1-C2 (does
  the unauthenticated lookup disclose account existence — the enumeration facet) and AC4-C6 (does
  the backend re-enforce the client-side password-shape rule, the UI-bypass facet). The
  **list/collection view**, **conditional behavior over config/role axes**, and **CRUD lifecycle**
  triggers do not match this US's shape (no list, no role/config axis, no entity lifecycle beyond
  the password value itself) — explicitly not triggered, not silently skipped.
- **3d (knowledge-driven conditions)**: not applicable — no `.qaia/knowledge/` exists for this
  campaign directory (recorded in `02-understanding.md`); proceeding on the source alone, per the
  shared contract's degraded-mode rule (no knowledge content invented).

## Journey

| Step | Status |
|---|---|
| 03-design | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) |

## Skill evaluation — `istqb-design` (`plugins/qaia-core/skills/istqb-design/SKILL.md`)

- **Verdict**: `CONFORME`.
- **Preuve**: the guardrail added after the US-EVAL-001 run (`SKILL.md` line 103) flags that a 3c
  sub-pattern with no trace at all in `03-design.md` is a defect — specifically calling out that
  the "account & auth features → recovery path" pattern is the one most likely to be silently
  skipped "on the one US type it names by example." This run's US **is** that exact US type (an
  account-recovery flow), and the "Sub-step trace" section above explicitly names that pattern and
  states it is instantiated by the whole US rather than silently omitting the mention — the precise
  gap that footnote was written to prevent did not recur.
- **Modification concrète proposée**: aucune.
