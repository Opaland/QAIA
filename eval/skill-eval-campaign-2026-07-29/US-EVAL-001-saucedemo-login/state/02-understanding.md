# 02-understanding — US-EVAL-001

## Reformulation

Who: any visitor submitting credentials on the SauceDemo login page. What: the login gate must
let through exactly the holders of valid, non-locked credentials (`standard_user`), refuse a
valid-but-locked account (`locked_out_user`) with a specific message, and refuse any credentials
that don't match a known account. Why: the whole storefront (catalog, cart, checkout) sits behind
this gate — a leak here (locked account let through, or a working account wrongly refused) is the
single highest-impact defect this US-slice could hide. Main risk if it misbehaves: `locked_out_user`
reaching the catalog (an access-control bypass) is worse than a false refusal of `standard_user`
(an availability bug) — asymmetric severity, feeds `prioritize`.

## Ambiguity hunt

**Q1 — invalid-credentials refusal, exact behavior.** AC3 states a refusal happens but no source
confirms the exact message or whether it distinguishes "unknown username" from "wrong password
for a known username."
- Classification: step 3 of the decision tree — a safe default exists (generic, non-enumerating
  refusal is standard login-security practice; a login form confirming *which* field was wrong is
  itself a defect, not the safe default) → **`[assumption]`**. Proposed default: the refusal is
  generic and does not confirm which of username/password was incorrect; the exact wording is
  **not asserted** in the generated scenario (kept qualitative) since no source confirms it.

**Q2 — empty username/password field.** No source states whether an empty submission is blocked
client-side with a distinct message or falls through to the same path as AC3.
- Classification: step 3, safe default exists (folding into AC3's refusal path is the
  lower-risk assumption than inventing a distinct message) → **`[assumption]`**, `@low-confidence`.

**Q3 — check ordering for a locked account with a wrong password.** If `locked_out_user` is
submitted with an incorrect password (not `secret_sauce`), does the system report "locked out"
(account-state checked first) or a generic invalid-credentials refusal (credential match checked
first)? Both orders are plausible implementations; no source confirms either, and this is exactly
the kind of auth-boundary detail the `need-understanding` adversarial pass calls out ("auth/tokens/
permissions → revocation vs expiration... indistinguishability rules under every response path").
No safe default is obviously lower-risk than the other (an information-disclosure argument could
favor either the locked-out message or the generic one, depending on whether "locked out" itself
already discloses the account exists).
- Classification: step 4 (no safe default without escalation) → **`[open]`**.

## Cross-AC interaction pass

AC1 × AC2 × AC3 interaction is exactly Q3 above (documented there, not duplicated).

## Q&A log

| ID | Question | Status | Resolution |
|---|---|---|---|
| Q1 | Invalid-credentials exact refusal behavior | `[assumption]` | Generic, non-enumerating refusal; exact wording not asserted |
| Q2 | Empty-field submission behavior | `[assumption]`, `@low-confidence` | Folded into AC3's refusal path |
| Q3 | Locked account + wrong password: which check wins | `[open]` | No default generated for the "wrong order" side; only the confirmed `locked_out_user`/`secret_sauce` (AC2) and `standard_user` (AC1) combinations are asserted with confidence |

## Journey

| Step | Status |
|---|---|
| 02-understanding | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) |
