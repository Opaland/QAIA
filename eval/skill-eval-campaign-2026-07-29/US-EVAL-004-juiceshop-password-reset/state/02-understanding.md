# 02-understanding — US-EVAL-004

## Reformulation

Who: any visitor who submits an email on Juice Shop's "Forgot Password" page. What: the flow must
let the true owner of a registered account (the one who knows the account's security-question
answer) set a new password, refuse anyone who doesn't know that answer, and enforce a valid
new-password shape (5-40 chars, matching repeat) before allowing the change at all. Why: this is
an **account-recovery / auth-boundary** feature — its failure modes are asymmetric in the same way
a login gate's are (SauceDemo, US-EVAL-001): a false refusal of the real owner is an availability
annoyance, but a stranger successfully taking over an account through this flow (by guessing the
answer with no friction, or by the flow leaking which accounts exist / what their question is) is
a security failure, not a UX one. Main risk if it misbehaves: unauthenticated account takeover via
the recovery path — the single highest-impact defect this slice could hide, on a target whose
whole point (`docs/DEMO-TARGETS.md`'s ✅✅ security rating) is that this class of flaw is expected
to exist somewhere in the app.

## Knowledge base

No `.qaia/knowledge/` present for this campaign directory — recorded per shared-contract rule 8,
proceeding on the source alone (degraded mode, explicit, not silently skipped).

## Ambiguity hunt

**Q1 — unregistered-email response shape (enumeration/disclosure).** `00-source.md` confirms the
`GET /rest/user/security-question?email=...` lookup fires **unauthenticated** for any typed email,
but its response for an email that is **not** a registered account was not observable this session
(API returned 503 throughout). Does the endpoint return a distinguishable "no such account"
signal, or a uniform response indistinguishable from the "account exists" case?
- Classification: adversarial pass, auth/tokens/permissions type (step 3 of `need-understanding`,
  "indistinguishability rules under every response path") — an access-boundary point the source
  does not state → **`[open]`** per the explicit rule ("access boundary → question, never
  assumption... never assert [a specific behavior] when the source implies [otherwise]").

**Q2 — wrong-answer refusal, exact behavior.** AC3 states a refusal happens but no source (live
or documented) confirms the exact message, HTTP status, or whether the security-question field is
cleared/retained after a wrong attempt.
- Classification: step 3 of the decision tree — a safe default exists (a generic, non-specific
  refusal that does not confirm/deny the answer's correctness structure, mirroring US-EVAL-001's
  Q1 treatment of SauceDemo's invalid-credentials case) → **`[assumption]`**. Proposed default:
  refusal is asserted only qualitatively (a refusal occurs, the password is unchanged); no
  specific wording/status is asserted since none is sourced.

**Q3 — rate limiting / lockout on repeated wrong answers.** No source (live or documented) states
whether the security question can be guessed an unlimited number of times, or is throttled/locked
after N wrong attempts. Security questions are a famously low-entropy secret (the corroborating
source itself notes "In reality, there are few if any GOOD security questions") — whether brute
force is mitigated is a real security property, not a cosmetic detail.
- Classification: step 2 of the decision tree — this is exactly the "auth/tokens/permissions"
  protected-boundary case the adversarial pass calls out, and no safe default is neutral here
  (asserting "no lockout exists" is asserting a security absence; asserting "a lockout exists" —
  and any specific threshold — would be fabricating a value with no traceable origin, forbidden by
  `testbook-generate`'s literal-value rule) → **`[open]`**.

**Q4 — client-side password-shape validation.** Is the New Password/Repeat Password matching and
5-40-char length rule enforced client-side (submit control disabled, per the directly-observed
UI) before any backend call, or does the backend independently re-validate?
- Classification: step 1 of the decision tree — the client-side half is **answered** directly by
  observation (`00-source.md`: the "Change" control stays disabled and the helper text is shown
  until the fields are valid and matching). Whether the **backend** independently re-enforces the
  same rule (defense in depth) if the client check were bypassed is a distinct, unanswered
  question — folded into Q1's `[open]` family below rather than duplicated, since it is the same
  "does the server, not just the UI, enforce this boundary" question in a different guise.

## Adversarial pass (by AC type — mandatory, `need-understanding` step 3)

This US is squarely an **auth/tokens/permissions** type feature (account recovery). Applying that
checklist explicitly:
- **Revocation vs expiration**: not applicable in the form observed — Juice Shop's reset flow has
  no visible token/link step (no "check your email" step, no expiring link was ever shown; the
  whole exchange — email → question → new password — happens synchronously in one page, per the
  directly-observed UI). Recorded as "not applicable, no token/expiry concept exists in the
  observed flow" rather than silently skipped.
- **Scope change mid-session**: not applicable — this flow is pre-authentication by construction
  (its entire purpose is regaining access without being logged in); there is no session to change
  scope within.
- **Indistinguishability rules under every response path**: this is exactly **Q1** and **Q3**
  above (does "wrong answer" look different from "account doesn't exist"; is guessing throttled) —
  not duplicated here, cross-referenced.

No other adversarial-pass AC type (state-machine/lifecycle, sorting/pagination, thresholds/
quantities) matches this US's shape beyond the password-length threshold already folded into Q4/AC4.

## Cross-AC interaction pass

AC1 (email → question lookup) feeds AC2/AC3 (answer submission) at exactly the boundary Q1/Q3
describe: whatever the lookup discloses about account existence is available to an attacker
*before* they ever attempt an answer, and whatever throttling (or lack of it) applies to AC3's
wrong-answer path determines how many free guesses that same attacker gets. These are not two
separate risks — they compound (a disclosed "this email exists" plus an unthrottled answer field
is materially worse than either alone) — noted here rather than only inside Q1/Q3 individually.

## Triple-AC contradiction pass (0.1.3 — mandatory)

Candidate triple: a **protected/restricted account state** (an account with **no security
question configured at all** — the precondition named in the background-only GitHub #1634 note in
`00-source.md`, out-of-slice as a *designed* condition but real as a *state* the lookup endpoint
could encounter) × a **scoping rule** (the lookup is keyed per-email) × an **anti-disclosure
rule** (whether the response is deliberately shaped to avoid revealing account state). The
question this triple raises: does `GET /rest/user/security-question?email=...` return **three**
distinguishable shapes — (a) unregistered email, (b) registered email with a real question, (c)
registered email with **no** question configured — or does it collapse (b) and (c), or all three,
into one indistinguishable shape? This is not answerable from what was observed this session (the
endpoint never returned a non-503 response) and is not stated in any documentation source found.
- Classification: same reasoning as Q1 (auth/access-boundary, no safe default) → folded into
  **Q1** as its three-way form rather than opened as a separate numbered question (the underlying
  ambiguity — does this endpoint disclose account state — is one question with three test-relevant
  facets, not three independent ones); `03-design.md`'s decision table will reflect the two
  observable facets (registered vs unregistered) and flag the third (missing-question state) as
  out-of-slice per `00-source.md`'s dependency note, since it requires a specific seeded account
  precondition never confirmed to exist on the current live demo.

## Q&A log

| ID | Question | Status | Resolution |
|---|---|---|---|
| Q1 | Unregistered-email lookup response shape (incl. triple-AC missing-question-state facet) | `[open]` | No default generated for the "unregistered/missing-question" side; only the registered-account path (AC1/AC2/AC3) is asserted with confidence |
| Q2 | Wrong-answer refusal exact message/status | `[assumption]` | Refusal asserted qualitatively only; no specific wording/status asserted |
| Q3 | Rate limiting / lockout on repeated wrong answers | `[open]` | No scenario asserts either presence or absence of throttling |
| Q4 | Client-side password-shape enforcement | answered (client-side); backend re-validation folded into Q1's open family | Client-side disabled-until-valid behavior asserted with confidence (directly observed) |

## Journey

| Step | Status |
|---|---|
| 02-understanding | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) |

## Skill evaluation — `need-understanding` (`plugins/qaia-core/skills/need-understanding/SKILL.md`)

- **Verdict**: `CONFORME`.
- **Preuve**: the guardrail at `SKILL.md` line 48 (added after the US-EVAL-001 run) requires an
  explicit, separately-headed `## Adversarial pass (by AC type)` section and `## Triple-AC
  contradiction pass` section, each stating findings or "not applicable... with a one-line
  reason" — "omitting the required trace... is the same defect as silently resolving an
  ambiguity." This checkpoint has both as their own headed sections above, with the
  auth/tokens/permissions sub-points each explicitly marked applicable-with-finding or
  not-applicable-with-reason (e.g. "not applicable — no token/expiry concept exists in the
  observed flow"), directly following that fix rather than re-triggering the gap it was written to
  close.
- **Modification concrète proposée**: aucune.
