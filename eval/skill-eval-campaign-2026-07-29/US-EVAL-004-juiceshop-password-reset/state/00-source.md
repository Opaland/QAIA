# 00-source — US-EVAL-004

- **Source type**: live application behavior (bring-your-own target, per
  `docs/SKILL-EVAL-CAMPAIGN-PROMPT.md`), not a written ticket — same convention as US-EVAL-001.
  Target: `OWASP Juice Shop` (`docs/DEMO-TARGETS.md` — the only listed target that explicitly
  allows real pentesting, ✅✅, self-hostable via Docker; **this run only explores the shared
  public demo, no scan/exploit attempted**, per the campaign's golden rule).
- **Designated URL**: `https://demo.owasp-juice.shop/#/forgot-password` (the official live demo
  instance, confirmed current via `WebSearch` before use).
- **Capture date**: 2026-07-29.
- **Capture method (in order, all against the one designated URL — no other URL substituted)**:
  1. `WebFetch` on the designated URL → returned an HTTP 503 (the shared demo backend was
     intermittently unavailable during this session — confirmed transient, see below), not a
     usable render.
  2. Per `us-ingest` step 1's guardrail (a JS-rendered SPA fetch returning no usable content must
     not be silently patched over by substituting a *different* URL), the **same designated URL**
     was instead reached with a real browser (Playwright `browser_navigate` +
     `browser_snapshot`) — this is not a source substitution, it is a stronger tool against the
     identical target, which is what an SPA requires to render at all. On retry the demo was up;
     the actual rendered "Forgot Password" form was captured directly (accessibility snapshot,
     verbatim field labels/placeholders below) — not paraphrased from a secondary source.
  3. `WebSearch` was used **only to corroborate background not observable live** (the security
     questions vary per seeded user; a documented historical vulnerability), never to replace the
     directly-observed form fields or flow — same pattern `00-source.md` of US-EVAL-001 used for
     SauceDemo. Cited inline below.

- **Captured text (faithful, not paraphrased) — directly observed via live browser render**:

  > Page: "Forgot Password" (`https://demo.owasp-juice.shop/#/forgot-password`). Fields, in
  > order: **Email** (required, textbox, placeholder "Enter your email"); **Security Question**
  > (required, textbox, initially disabled, labelled "Field for the answer to the security
  > question"); **New Password** (required, initially disabled, helper text "Password must be
  > 5-40 characters long.", a live `0/20` character counter); **Repeat New Password** (required,
  > initially disabled, same counter). A "Show password advice" toggle switch sits below the
  > password fields. A single submit control, "Button to confirm the changes" (label "Change"),
  > is disabled until the form is valid.
  >
  > Typing a syntactically valid email and moving focus away triggers an unauthenticated
  > `GET https://demo.owasp-juice.shop/rest/user/security-question?email=<email>` request
  > (observed directly in the network log for a known seeded account, `admin@juice-sh.op`) —
  > this is what is expected to populate/enable the Security Question field with that specific
  > account's own question. **The endpoint's response body was not observable this session**: it
  > returned HTTP 503 on every one of 4 attempts made across ~2 minutes (the shared demo's
  > backend, not this flow specifically — the same 503 was seen on the bare app root moments
  > earlier and later recovered), so the exact security-question text, the enabled/populated
  > field state, and the response for an email that is *not* a registered account were **not
  > confirmed live**. Retrying was not pursued further to avoid hammering a shared third-party
  > demo (golden rule: explore, don't load-test).

- **Supplementary corroboration (WebSearch, not primary — cited, not substituted for the above)**:

  > Different seeded Juice Shop users have different, individually-set security questions (e.g.
  > "Your eldest siblings middle name?", "Company you first worked for as an adult?", "What's
  > your favorite place to go hiking?"). The intended flow is: email → the account's own security
  > question is shown → answer it correctly → set a new password → "Change". (Source:
  > `help.owasp-juice.shop` / `pwning.owasp-juice.shop` companion-guide pages on "Broken
  > Authentication", 2026-07-29 — the project's own official documentation site, not a random
  > blog.)
  >
  > A historical, publicly-tracked defect (`github.com/juice-shop/juice-shop` issue #1634):
  > several seeded accounts originally shipped with **no security question configured**, and an
  > internal "SecurityAnswers" API was at one point reachable without authorization, letting an
  > attacker set an arbitrary question/answer pair for such an account and then reset its
  > password. **Noted as background only** — it describes a *missing-security-question* account
  > state, a different condition from "a registered account with a question, answered
  > incorrectly," which is what this US's AC3 covers. Not re-asserted as a current-behavior fact
  > of the live demo (not re-verified this session) and not designed as a scenario here.

- **Not confirmed by any source found** (carried forward as open points, not fabricated):
  - The exact security-question text/behavior for the `admin@juice-sh.op` account (endpoint
    unavailable this session).
  - Whether `GET /rest/user/security-question?email=` returns a real question, a generic
    decoy question, or an error for an email that is **not** a registered account — this is the
    security-relevant crux (does the endpoint let an outside party learn "this email exists /
    doesn't exist" and, if it exists, its question's *phrasing*, which is itself sometimes
    identifying?). The request is confirmed to fire **unauthenticated** for any typed email
    (directly observed), but its response shape by case was not.
  - The exact refusal behavior (message, HTTP status, whether the security-question field is
    cleared) when a wrong answer is submitted.
  - Any rate-limiting/lockout on repeated wrong answers.

- **Redaction**: none needed (a public seeded demo account, `admin@juice-sh.op`, not real PII —
  this is the project's own well-known documented test account, not a discovered real identity).
- **Gates checked** (`us-ingest` step 2): not empty; describes a real, testable capability
  (password recovery via security question); no abuse/illegality framed (exploring the flow
  structurally is not an attack, and none was attempted); nothing to redact.
- **Dependencies** (out-of-slice, not designed here): logging in with the newly-set password
  (a separate login US); account registration / initial security-question setup at signup;
  the missing-security-question account-takeover class of defect from issue #1634 (a distinct
  precondition — "no question configured" — from anything this US's ACs assert).

## Journey

| Step | Status |
|---|---|
| 00-ingest | done — gates checked (not empty, testable capability, no abuse/illegality, no PII to redact); source captured via Playwright render of the one designated URL after an initial `WebFetch` 503, per step 1's substitution guardrail |

## Skill evaluation — `us-ingest` (`plugins/qaia-core/skills/us-ingest/SKILL.md`)

- **Verdict**: `CONFORME`.
- **Preuve**: step 1 (`SKILL.md` line 12) says a JS-rendered SPA fetch returning an empty/unusable
  shell must not be silently patched over by substituting a different source, but does not forbid
  reaching the *same* designated URL with a stronger tool. This run's `00-source.md` "Capture
  method" section shows exactly that: `WebFetch` failed (503) on
  `https://demo.owasp-juice.shop/#/forgot-password`, and the same URL — not a different one — was
  then rendered via Playwright. No other URL was ever substituted, and every gap left by the
  live 503s on the `/rest/user/security-question` API is recorded under "Not confirmed by any
  source found" rather than filled in — matching the rule's intent (don't autonomously paper over
  a gap) even though the letter of step 1 only anticipates the `WebFetch`-only case.
- **Modification concrète proposée**: aucune — the guardrail already generalizes correctly to a
  browser-tool retry; no rewording needed.
