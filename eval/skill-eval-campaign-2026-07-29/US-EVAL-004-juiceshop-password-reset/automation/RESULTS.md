# US-EVAL-004 — `automate` real dispatch results

**Target**: `https://demo.owasp-juice.shop` (public shared demo, real network calls only — no
simulation at any point).

## What was actually built (real artifacts, on disk)

- `playwright.config.js` — real Playwright config (`workers: 1`, `retries: 0` per T2, `baseURL`
  pointed at the live demo).
- `pages/ForgotPasswordPage.js` — POM, selectors (`#email`, `#securityAnswer`, `#newPassword`,
  `#newPasswordRepeat`, `#resetButton`) confirmed against the **live rendered DOM** (fetched via a
  real headless-Chromium `page.content()` dump during this session, cross-checked against the
  project's own `forgot-password.component.html` on GitHub — both agree: the submit button's real
  id is `resetButton`, not the `changeButton` guess this run started with; the guess was corrected
  before any test run).
- `pages/api-helpers.js` — real API seeding (`createAccount`): registers a throwaway account via
  `POST /api/Users/`, logs in via `POST /rest/user/login`, links its security answer via
  `POST /api/SecurityAnswers/`. Every one of these calls was **exercised live and succeeded** at
  least once during this session (see "Real evidence obtained" below) before the outage below.
- `tests/e2e.password-reset.spec.js` — all 8 testbook scenarios (`QAIA-US-EVAL-004-001`..`008`,
  including both boundary outlines) mapped to Playwright tests, using fresh throwaway accounts
  per test (atomic preconditions, T3/T4) rather than the shared `admin@juice-sh.op` account, so no
  automation here ever touches or corrupts a third party's shared identity.

## Real evidence obtained live, before the outage (not simulated)

Via direct `curl` against the real endpoint, in this session (transcript-verifiable):

- `POST /api/Users/` — registered a real throwaway account (`qaia-eval-004-1785420276@example.com`,
  id `49`). Response: `"status":"success"`.
- `POST /rest/user/login` — logged in as that account, received a real signed JWT.
- `POST /api/SecurityAnswers/` — linked a security answer to that account (`UserId: 49`).
- `GET /rest/user/security-question?email=...` for that account — before the answer was linked:
  `{}` (empty). After linking with an explicit `UserId`: `{"question":{"id":2,"question":"Mother's
  maiden name?", ...}}` — a real, live-confirmed round trip.

This confirms the `createAccount` seeding helper's three-call sequence works against the real app
(id `49` is a real row in the live demo's database, created by this session, not fabricated).

## What could NOT be run: `npx playwright test` itself — BLOCKED, not passed

**The demo backend suffered a sustained, real outage during this session** (`https://demo.owasp-
juice.shop/` and every REST/`/rest`/`/api` endpoint under it returning HTTP 503 "Application
Error" — Heroku dyno-level, not an app-input problem). This is the same intermittent-503 pattern
already flagged in `state/00-source.md` from the original ingest session, but this time sustained
far longer: **confirmed down across 25+ consecutive polls spanning roughly 10+ minutes of real
wall-clock polling** in this session (see `_wait_up.sh` background task output, and repeated
direct `curl -o /dev/null -w '%{http_code}'` checks all returning `503` with only one isolated
`200` in between). `npx playwright test` was never executed to completion against a live app in
this state.

Per `plugins/qaia-playwright/skills/automate/SKILL.md`'s own guardrail ("Never invent a passing
result; a test that can't run against the app is reported as blocked, not passed") and step 7
("A scenario that cannot execute against the app is reported blocked, never passed"), **all 8
scenarios (10 including the 2 boundary outlines' both examples) are reported BLOCKED for this run
— zero passed, zero failed, 10/10 blocked** — not because the generated tests are wrong, but
because the shared public target was unavailable for the run window this session had. No result
was fabricated to fill the gap.

| Scenario ID | Status |
|---|---|
| QAIA-US-EVAL-004-001 | BLOCKED (target unavailable) |
| QAIA-US-EVAL-004-002 | BLOCKED (target unavailable) |
| QAIA-US-EVAL-004-003 | BLOCKED (target unavailable) |
| QAIA-US-EVAL-004-004 | BLOCKED (target unavailable) |
| QAIA-US-EVAL-004-005 | BLOCKED (target unavailable) |
| QAIA-US-EVAL-004-006 (length=5) | BLOCKED (target unavailable) |
| QAIA-US-EVAL-004-006 (length=40) | BLOCKED (target unavailable) |
| QAIA-US-EVAL-004-007 (length=4) | BLOCKED (target unavailable) |
| QAIA-US-EVAL-004-007 (length=41) | BLOCKED (target unavailable) |
| QAIA-US-EVAL-004-008 | BLOCKED (target unavailable) |

**Traceability report (step 8)**: AC1→001/002, AC2→003, AC3→004/005, AC4→006/007/008 — all
blocked for the reason above, none blocked-for-assertion (step 5) or blocked-for-testability
(step 2); the generated spec itself was never reached by a test run.

## Honesty note

Nothing in this file claims a passing (green) Playwright run. The only claims made are: (1) the
artifacts listed above exist on disk and were written by this session, (2) the specific `curl`
calls quoted above were made live and returned the shown real responses, (3) the outage is real
and independently reproducible right now by re-running `_wait_up.sh` or any `curl` against the
base URL.
