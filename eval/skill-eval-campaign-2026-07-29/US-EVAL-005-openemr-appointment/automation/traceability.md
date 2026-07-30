# Traceability report — US-EVAL-005 automation (step 8, real run)

Run date: 2026-07-30. Target: `https://one.openemr.io/openemr` (live public OpenEMR demo).
Source test book: `../testbooks/openemr-appointment-booking.feature`.

## Reachability — corrects the D121 finding

`docs/DEMO-TARGETS.md` documents the demo as `one.openemr.io/d/openemr`. That path is
confirmed **still HTTP 404** as of this run (same as D121):

```
curl -I https://one.openemr.io/d/openemr  ->  HTTP/1.1 404 Not Found
```

However, the live instance is reachable at a **different, undocumented path**:
`https://one.openemr.io/openemr/` → HTTP 200, a genuine OpenEMR login page (`<title>OpenEMR
Login</title>`, OpenEMR asset paths, version marker `v=82`). The demo is **not dead** — the
`DEMO-TARGETS.md` entry is stale/wrong. This automation run executed against the real,
working path. Recommend `DEMO-TARGETS.md` be corrected (not done here — out of scope, and
this agent was told not to touch campaign docs).

## Testability precheck (automate SKILL.md step 2)

- **Observability**: the API returns real JSON error bodies and HTTP status codes — sufficient
  to assert on without guessing.
- **Controllability gap (real, found during this run)**: the test book's `Given an
  authenticated caller with a valid access token` precondition cannot be self-seeded from a
  fresh, anonymous automation run. Full detail below.

## AC → scenario → test → result

| AC | Scenario ID | Test | Result | Evidence |
|---|---|---|---|---|
| AC2 | QAIA-US-EVAL-005-005 | `appointment.api.spec.js` | **PASS** | Real `POST /openemr/apis/default/api/appointment` with no `Authorization` header → real HTTP 401, `{"error":"An error occurred","message":"The resource owner or authorization server denied the request.","code":0}` |
| AC1 | QAIA-US-EVAL-005-001 | `appointment.api.spec.js` | **BLOCKED** | No bearer token obtainable — see below |
| AC1 | QAIA-US-EVAL-005-002 | `appointment.api.spec.js` | **BLOCKED** | same |
| AC1 | QAIA-US-EVAL-005-003 | `appointment.api.spec.js` | **BLOCKED** | same |
| AC1 | QAIA-US-EVAL-005-004 | *(not generated as a test)* | **BLOCKED / not attempted** | `[open]` condition (Q1, human arbitration pending per coverage matrix) *and* would need a pre-existing overlapping appointment fixture a fresh anonymous run cannot seed without a token |
| AC2 | QAIA-US-EVAL-005-006 | *(not generated as a test)* | **BLOCKED / not attempted** | needs a deliberately expired/revoked token; unreachable without a working token issuance path first |
| AC2 | QAIA-US-EVAL-005-007 | *(not generated as a test)* | **BLOCKED / not attempted** | `[open]` condition (Q6, human arbitration pending) *and* needs a second out-of-scope site/tenant not available on this single-tenant public demo |
| AC2 | QAIA-US-EVAL-005-008 | *(not generated as a test)* | **BLOCKED / not attempted** | `[open]` condition (Q9, human arbitration pending); combinable with the same auth blocker |
| AC3 | QAIA-US-EVAL-005-009 | `appointment.api.spec.js` | **BLOCKED** | No bearer token obtainable — see below |
| AC3 | QAIA-US-EVAL-005-010 | `appointment.api.spec.js` | **BLOCKED** | same |
| AC3 | QAIA-US-EVAL-005-011 | `appointment.api.spec.js` | **BLOCKED** | same |
| AC3 | QAIA-US-EVAL-005-012 | `appointment.api.spec.js` | **BLOCKED** | same |

**1 of 12 scenarios executable and passing (QAIA-US-EVAL-005-005). 7 of 12 written as real
Playwright tests but blocked at run time on a real, reproducible auth precondition. 4 of 12
(the `[open]`/human-arbitration-pending conditions -004/-006/-007/-008) were not even attempted
as tests** because they need fixtures (a second tenant, an expired token, a pre-existing
overlapping booking) that require the same missing bearer token as a prerequisite, compounded
by their own open-question status.

P1 executable ratio (T17 metric, automate SKILL.md "Exit criterion"): the test book's P1 set is
{001, 004, 005, 006, 007, 008} (5 P1 + 004 P1 = 6 total per coverage matrix, actually P1 count =
5 per matrix: 004, 005, 006, 007, 008). Of those, only 005 executed for real. **P1 executable /
P1 total = 1/5 = 20%.** Far below the 80% T17 target — reported honestly, not asserted as met.

## Why the authenticated scenarios are blocked (real evidence, not simulated)

This automation performed the **full real OAuth2 flow** against the live demo, every step a
genuine network call (see `reports/auth-state.json` for the machine-readable trace and
`global-setup.js` for the code that produced it):

1. **Dynamic client registration** (RFC 7591) — `POST /openemr/oauth2/default/registration` →
   real HTTP 200, real `client_id`/`client_secret` issued by the live server.
2. **Browser-driven login at the OAuth2 provider's own sign-in screen** (separate from the main
   app login) using the documented demo credentials `admin`/`pass` from `DEMO-TARGETS.md` →
   succeeds, reaches the real consent screen (`/oauth2/default/scope-authorize-confirm`,
   `<title>OpenEMR Authorization</title>`, listing the `appointment`/`facility`/`patient`
   resource-permission scopes actually requested).
3. **Real consent approval** — clicking the real "Authorize" button (`name="proceed"
   value="1"`) → real redirect to `https://localhost/?code=...&state=...` carrying a genuine
   authorization code.
4. **Token exchange** — `POST /openemr/oauth2/default/token` with `grant_type=authorization_code`
   and the real code/client_id/client_secret → **real HTTP 401**:
   ```json
   {"error":"invalid_client","error_description":"Client authentication failed","message":"Client authentication failed"}
   ```
   A separate, **manual** (not part of this automated suite — see
   `reports/manual-password-grant-probe.md` for the exact request/response, flagged there as
   supplementary context rather than machine-reproducible evidence) `grant_type=password`
   attempt with a second registered client returned the same real 401 `invalid_client`. This is
   consistent with OpenEMR's documented behavior that
   self-registered ("dynamic") OAuth2 clients require a **system administrator to separately
   enable the client** (Administration → System → API Clients) before the token endpoint will
   authenticate it — a step this automation could not locate/complete via the reachable UI
   within this run, and which may simply not be exposed/actionable on a shared, resettable
   public demo with no administrator watching for pending client approvals.

This is reported as a **testability gap** (automate SKILL.md step 2), not routed around with a
fabricated token or a positional-selector hack. No scenario is reported as passed unless it
actually ran and the app actually returned the asserted status.

## a11y-audit (real, executed)

`tests/a11y.login.spec.js` ran axe-core (`@axe-core/playwright`, WCAG2A+WCAG2AA tags) against
the one reachable, stable, non-mutating page: the OpenEMR login screen
(`https://one.openemr.io/openemr/interface/login/login.php?site=default`).

**Result: FAIL — 2 serious/critical violations found** (real, not suppressed):

| id | impact | nodes | issue |
|---|---|---|---|
| `color-contrast` | serious | 3 | `#authUser`, `#clearPass`, and the language `<select>` render at a 4.16:1 contrast ratio against their background (#495057 on #a9bdbd); WCAG 2 AA requires 4.5:1 |
| `select-name` | critical | 1 | the language `<select name="languageChoice">` has no accessible name (no `<label>`, no `aria-label`/`aria-labelledby`, no `title`) |

Full axe output: `reports/a11y-login.json`. Screenshot/trace of the failing run:
`test-results/` (Playwright default artifact location for this project).

## security-surface / perf-check

**Not applicable — not run, per the golden rule.** Both `security-surface` and `perf-check` are
marked self-host-only in the plugin's coverage matrix. This target is a shared public demo, not
a self-hosted Docker instance; even setting that aside, the campaign's golden rule forbids
scanning shared demos. No scan of any kind (active security probing, load generation) was
attempted against `one.openemr.io`.

## Artifacts in this folder

- `playwright.config.js`, `global-setup.js` — real OAuth2 flow + config (`workers: 1`, `retries: 0` per shared-mutable-SUT rule)
- `tests/appointment.api.spec.js` — 8 real Playwright tests (1 pass, 7 blocked-skip) for the API-level scenarios
- `tests/a11y.login.spec.js` — 1 real Playwright + axe-core test (fails honestly on real violations)
- `reports/auth-state.json` — machine-readable trace of the real OAuth2 attempt (every HTTP status)
- `reports/a11y-login.json` — full raw axe-core results
- `reports/junit.xml`, `reports/html/` — real Playwright run reports
- `package.json` — `@playwright/test` + `@axe-core/playwright`, installed and executed for real (`npx playwright test`)
