# 01-extraction — US-EVAL-004

## Story

**As a** registered OWASP Juice Shop user who has forgotten my password,
**I want** to prove ownership of my account by answering my pre-configured security question and
then set a new password,
**so that** I can regain access without administrator help, while someone who does not know my
security answer cannot take over my account through this flow.

*(Not explicitly phrased as a story anywhere in the source — `[reconstructed]` from the captured
form fields and flow order, per `us-review` step 1's explicit license for a real-capability
capture with no story phrasing.)*

## Acceptance criteria (numbered, stable — AC1..AC4)

- **AC1.** Entering a registered account's email on the "Forgot Password" page triggers an
  unauthenticated lookup (`GET /rest/user/security-question?email=...`, directly observed) meant
  to surface that account's own security question for the user to answer. *(The lookup firing is
  confirmed live; its response content was not — see `00-source.md`.)*
- **AC2.** Submitting the **correct** answer to the displayed security question, together with a
  **New Password** and **Repeat New Password** that match and are 5-40 characters, changes the
  account's password (the "Change" action succeeds).
- **AC3.** Submitting an **incorrect** answer to the security question is refused; the account's
  password is not changed. *(Exact refusal message/status not confirmed by any source found —
  open point.)*
- **AC4.** The "Change" submit control stays disabled, and a validation message ("Password must
  be 5-40 characters long.") is shown, until New Password and Repeat New Password are both
  non-empty, within 5-40 characters, and identical to each other. *(Directly observed: the
  disabled state and the exact helper-text string.)*

## Business rules / constraints found outside the AC list

- The security-question lookup endpoint is called **unauthenticated**, for any syntactically
  valid email typed into the field — directly observed in the network log. Whether this is an
  intentional, necessary-for-the-flow design point (the user isn't logged in yet, so the lookup
  can't require auth) or an information-disclosure surface (does it distinguish "email exists" vs
  "doesn't", and if so does the response shape/timing differ?) is exactly the kind of
  security-relevant ambiguity flagged for `need-understanding`, not resolved here.
- A historical, publicly-tracked issue (GitHub #1634) describes accounts that originally shipped
  with **no security question configured** and an internal API that let an attacker set an
  arbitrary one — a distinct precondition from AC2/AC3 (which assume a question already exists)
  and out of scope for this slice (see `dependencies` in `00-source.md`).

## Referenced artifacts not analyzed

- None (no attachments/mockups; the source is the live rendered form itself).

## Present but not classifiable

- None.

## What was NOT found

- No formal AC numbering in the source (none existed — a live-app capture, not a written
  ticket): the numbering above is this skill's own reconstruction.
- No confirmed behavior for: an unregistered email against the security-question lookup, the
  exact wrong-answer refusal (message/status/whether the question field clears), and any
  rate-limiting on repeated wrong answers. All three carried to `need-understanding` as open
  points, not invented here.

## Journey

| Step | Status |
|---|---|
| 00-ingest | done |
| 01-review | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run, no human reviewer at this micro-step; only the pre-automation gate is a hard human stop per the campaign prompt) |

## Skill evaluation — `us-review` (`plugins/qaia-core/skills/us-review/SKILL.md`)

- **Verdict**: `CONFORME`.
- **Preuve**: step 1 (`SKILL.md` line 13) requires — for a source with no story phrasing but a
  real capability described — that the story be "reconstruct[ed] and mark[ed] `[reconstructed]`."
  This checkpoint's Story section does exactly that: the As-a/I-want/So-that block is followed
  immediately by an explicit `[reconstructed]` tag and a one-line justification, not silently
  presented as if quoted. Step 1's list ordering (story → numbered AC → business rules →
  referenced artifacts → not-classifiable) is also followed exactly as headed above.
- **Modification concrète proposée**: aucune.
