# 03-design — US-EVAL-001

## AC → technique map

- **AC1** (valid active credentials succeed) → **Equivalence partitioning** — a single representative
  of the "valid, non-locked account" class (`standard_user`).
- **AC2** (locked account refused with a specific message) → **Equivalence partitioning** on the
  "valid but locked" class, extended by a **Decision Table** once crossed with the credential-match
  axis (see AC3/Q3 below) — account state (active/locked) × credential match (yes/no) is a genuine
  2-axis combination, not two independent EP passes.
- **AC3** (unmatched credentials refused) → **Decision Table Testing** — the natural technique once
  "username matches a known account" and "password matches for that account" are treated as two
  independent condition columns feeding one "refused" action, rather than picking pairs opportunistically.

## Decision table (username-match × password-match × account-state)

| Username matches? | Password matches (if username matches)? | Account state | Outcome | Condition |
|---|---|---|---|---|
| Yes | Yes | Active | Login succeeds | AC1-C1 |
| Yes | Yes | Locked | Locked-out refusal (specific message) | AC2-C1 |
| No | — | — | Generic refusal | AC3-C1 |
| Yes | No | Active | Generic refusal | AC3-C2 |
| Yes | No | Locked | Refusal — **which message wins is `[open]` Q3** | AC2-C2 |
| (empty username or password) | — | — | Generic refusal (assumption Q2) | AC3-C3 |

## Test conditions

- **AC1-C1** `[ep]` — `standard_user`/`secret_sauce` → login succeeds, product catalog reached.
- **AC2-C1** `[ep]` `[req-neg]` — `locked_out_user`/`secret_sauce` → refused, locked-out message
  shown, catalog not reached.
- **AC3-C1** `[decision-table]` `[req-neg]` — unknown username, any password → refused, generic
  (non-enumerating) message.
- **AC3-C2** `[decision-table]` `[req-neg]` — `standard_user` + wrong password → refused, generic
  message.
- **AC3-C3** `[decision-table]` `[req-neg]` `[assumption]` `@low-confidence` (Q2) — empty
  username or empty password submitted → refused (folded into the generic path; exact behavior
  not confirmed by any source).
- **AC2-C2** `[decision-table]` `[req-neg]` `[open]` `@low-confidence` (Q3) — `locked_out_user` +
  wrong password → **proposed default**: the locked-out message still wins (account-state checked
  before/independently of credential match) — genuinely open, human arbitration needed before this
  is trusted; generated per `testbook-generate`'s rule that `[open]` conditions still get a
  scenario built on the proposed default, never silently skipped.

No standardized domain (card/date/HTTP/currency/IBAN) is touched — `oracle-generate` not invoked
(3b, correctly a no-op here). No knowledge base present for this campaign directory — recorded per
shared-contract rule 8, proceeding on the source alone.

## Journey

| Step | Status |
|---|---|
| 03-design | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) |
