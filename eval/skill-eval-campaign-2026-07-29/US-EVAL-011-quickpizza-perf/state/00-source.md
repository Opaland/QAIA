---
stepsCompleted: [00-ingest]
lastStep: 00-ingest
lastSaved: 2026-07-30
---

# 00-source — US-EVAL-011

- **Source type**: official project documentation (bring-your-own target, per
  `docs/SKILL-EVAL-CAMPAIGN-PROMPT.md`), captured via `WebFetch` — not a written ticket, and
  **not a live capture** (see "Explicit non-goal" below).
- **Designated target**: `QuickPizza` (`grafana/quickpizza`) — reached via `docs/DEMO-TARGETS.md`
  "GitHub lists that catalog targets" section, `grafana/awesome-k6` entry ("perf tooling +
  **QuickPizza** self-hosted load-test demo"). This is a deliberate diversification pick: every
  target this campaign has run against so far either forbids perf testing (a shared public demo)
  or has never actually had a real k6 run in this campaign at all (only D105/Sprint 24 ran k6
  once, against QAIA's own `examples/expense-demo`, not an external catalog target). QuickPizza is
  Grafana's own purpose-built self-hosted load-test demo app, closing that gap.
- **Capture date**: 2026-07-30.

## Explicit non-goal (per this run's brief)

This run does **not** stand up QuickPizza (Docker/npm) and does **not** execute a live k6 load
test — this sandboxed worktree cannot be assumed to have Docker or the ability to expose a running
instance. The US and its performance-relevant AC below are grounded entirely in QuickPizza's own
public documentation and source (its GitHub repo README and the `k6/foundations/` example scripts
it ships), never invented. Step 8 automation (`perf-check`) is reported as an explicit limitation,
not simulated — same discipline the campaign brief requires (D118: "if script execution isn't
possible, say so, never silently degrade").

## What was actually fetched

- `WebFetch https://raw.githubusercontent.com/grafana/quickpizza/main/README.md` → succeeded.
  QuickPizza is described as a demo app that "generates new and exciting pizza combinations!",
  built as an educational tool for app instrumentation/observability with the Grafana stack. Run
  locally: `docker run --rm -it -p 3333:3333 ghcr.io/grafana/quickpizza-local:latest` (serves on
  `localhost:3333`). A "Pizza, Please!" button in the UI triggers a recommendation. Includes k6
  test scripts organized in `foundations/`, `browser/`, `extensions/` folders, runnable against a
  local or public deployment via a `BASE_URL` environment variable.
- `WebFetch https://api.github.com/repos/grafana/quickpizza/contents/k6/foundations` → succeeded,
  real directory listing: `01.basic.js`, `02.stages.js`, ..., `05.thresholds.js`,
  `06.checks-with-thresholds.js`, ..., `17.login-action.js`, among others.
- `WebFetch https://raw.githubusercontent.com/grafana/quickpizza/main/pkg/http/http.go` →
  succeeded, real Go route table. Confirms `POST /api/pizza` accepts a `Restrictions` JSON object
  (`maxCaloriesPerSlice` int default 1000, `mustBeVegetarian` bool, `excludedIngredients` []string,
  `excludedTools` []string, `maxNumberOfToppings` int default 5, `minNumberOfToppings` int default
  3, `customName` string) and returns a `PizzaRecommendation` object (`pizza` — id/name/dough/
  ingredients/tool, `calories` int, `vegetarian` bool). Also confirms
  `POST /api/users/token/login`, `POST /api/users/token/logout`,
  `POST /api/users/token/authenticate`, `POST /api/users` (register), and the `/api/ratings*`
  CRUD family.
- `WebFetch https://raw.githubusercontent.com/grafana/quickpizza/main/k6/foundations/01.basic.js`
  → succeeded, real k6 script. Targets `http://localhost:3333/api/pizza` (`POST`), 5 VUs, 5s
  duration, one check (`status === 200`), sends the same `Restrictions` payload shape as above with
  an `Authorization` header carrying a bearer-style token.
- `WebFetch https://raw.githubusercontent.com/grafana/quickpizza/main/k6/foundations/05.thresholds.js`
  → succeeded, real k6 script. Defines three thresholds:
  `http_req_failed: rate<0.01` (error rate under 1%), `http_req_duration: p(95)<500` (95th
  percentile under 500ms) and `p(99)<1000` (99th percentile under 1000ms), plus a non-blocking
  custom-metric threshold on `quickpizza_ingredients` (average ingredient count under 8). Targets
  the same `POST {BASE_URL}/api/pizza`, one check (`status is 200`).
- `WebFetch https://raw.githubusercontent.com/grafana/quickpizza/main/k6/foundations/17.login-action.js`
  → succeeded, real k6 script. Calls `POST {BASE_URL}/api/users/token/login` with
  `{ username: "default", password: "12345678", csrf: res.cookies.csrf_token[0].value }`, reads
  `token = res.json().token` from the response, then calls `/api/pizza` with header
  `Authorization: token ${token}`.
- `WebFetch https://raw.githubusercontent.com/grafana/awesome-k6/main/README.md` → succeeded,
  confirms the `grafana/quickpizza` entry: "Web application used for demos and workshops with
  multiple k6 examples," listed under the Examples/Templates section of the awesome-k6 list —
  the exact entry `docs/DEMO-TARGETS.md`'s "GitHub lists" table cites.

## Captured text (faithful, not paraphrased)

> **`README.md`**: "QuickPizza is a demo web application... generates new and exciting pizza
> combinations!" / "Run it with Docker: `docker run --rm -it -p 3333:3333
> ghcr.io/grafana/quickpizza-local:latest`" / k6 scripts "can run against local or public
> deployments via `BASE_URL`".
>
> **`k6/foundations/05.thresholds.js`** (real k6 script, the project's own worked threshold
> example against its own primary API endpoint):
> ```
> thresholds: {
>   http_req_failed: ['rate<0.01'],
>   http_req_duration: ['p(95)<500', 'p(99)<1000'],
>   quickpizza_ingredients: ['avg<8'],
> }
> ```
> targeting `POST ${BASE_URL}/api/pizza`.
>
> **`pkg/http/http.go`** (real Go route/model definitions): `POST /api/pizza` request body
> (`Restrictions`) and response body (`PizzaRecommendation`) field lists as captured above.
>
> **`k6/foundations/17.login-action.js`** (real k6 script): login via
> `POST /api/users/token/login` with `username: "default"`, `password: "12345678"`, a `csrf`
> cookie value; the returned `token` is then sent as `Authorization: token <token>` on subsequent
> `/api/pizza` calls.
>
> (Sources: `WebFetch` on `raw.githubusercontent.com/grafana/quickpizza/main/README.md`,
> `.../pkg/http/http.go`, `.../k6/foundations/01.basic.js`, `.../k6/foundations/05.thresholds.js`,
> `.../k6/foundations/17.login-action.js`, and `raw.githubusercontent.com/grafana/awesome-k6/main/README.md`,
> all 2026-07-30.)

## Not confirmed by any source found

- Whether `POST /api/pizza` **requires** authentication in the monolithic Docker image this US
  targets, or is reachable anonymously — `01.basic.js` and `05.thresholds.js` both send an
  `Authorization` header, but neither script's own comments state whether the endpoint rejects an
  unauthenticated call outright or merely personalizes/logs the response when a token is present.
  `17.login-action.js` demonstrates *how* to obtain a token but the fetched content does not prove
  the token is mandatory for `/api/pizza` specifically (its own analysis note above says this
  cannot be determined from that file alone).
- The exact **HTTP status code and body** returned when `Restrictions` violates its own documented
  bounds (e.g. `minNumberOfToppings > maxNumberOfToppings`, a negative `maxCaloriesPerSlice`) — no
  fetched source shows a validation-error example for this endpoint.
- Whether the thresholds in `05.thresholds.js` (p95<500ms, p99<1000ms, error rate<1%) are
  documented anywhere as an **official target SLO for the app**, or are simply this one example
  script's own illustrative numbers for teaching k6 syntax — the script itself is the only source
  found; no separate performance-requirements document was located.
- Behavior of the **microservices deployment mode** (separate `public-api`/`catalog`/
  `recommendations`/etc. services) under load, vs. the **monolithic** single-container mode this US
  targets — the README distinguishes the two architectures but the fetched k6 scripts do not state
  which mode they assume beyond hitting a single `BASE_URL`.
- Full validation rules for `customName`'s `MaxPizzaNameLength` (the exact numeric limit was not
  quoted by any source reached).

**Not fabricated here** — every point above is carried forward as an open point to
`need-understanding`, never guessed.

## Redaction

None needed — no PII in the fetched public GitHub documentation/source. The login credentials
quoted above (`username: "default"`, `password: "12345678"`) are the project's own published
placeholder demo credentials in its own example script, not a real individual's data — recorded
verbatim per this skill's step 5 ("otherwise faithful... do not paraphrase or clean the
requirements"), same treatment US-EVAL-005 gave OpenEMR's public `admin`/`pass` demo creds.

## Dependencies (out-of-slice)

- User registration/login (`POST /api/users`, `POST /api/users/token/login`) — a separate US;
  obtaining a token is a given precondition here, not designed in this slice.
- Ratings CRUD (`/api/ratings*`) — a separate US; this slice targets the recommendation endpoint
  only.
- Ingredient/dough/tool catalog management (`/api/ingredients/{type}`, `/api/doughs`,
  `/api/tools`) — a separate admin/content US; treated as given, existing data here.
- Browser-level (real-browser) performance testing (`k6/browser/`) and gRPC/WebSocket paths
  (`k6/foundations/13`, `16`) — sibling capabilities in the same repo, not this slice's API-level
  load target.
- Live execution of `perf-check` against a running instance — explicitly out of scope for this run
  (see "Explicit non-goal" above); reported as a limitation at step 8, not simulated.

## Journey

| Step | Status |
|---|---|
| 00-ingest | done — gates checked (not empty, is a testable capability — a real load-test-relevant recommendation API with the project's own worked k6 threshold example, no abuse/illegality, no PII to redact — placeholder demo creds are the project's own public documentation, not a real individual's); US-ID confirmed non-interactively: `US-EVAL-011` |

## Skill evaluation — `us-ingest`

- **Skill evaluated**: `plugins/qaia-core/skills/us-ingest/SKILL.md`.
- **Input**: a GitHub-catalog-discovered target (`docs/DEMO-TARGETS.md` "GitHub lists" section,
  `grafana/awesome-k6` → QuickPizza), captured entirely from the target's own public repository
  (README, Go route source, k6 example scripts) — no live instance ever fetched, by design (this
  run's brief forbids standing up Docker/k6 in this sandbox).
- **Output**: this file.
- **Verdict**: **CONFORME.**
- **Evidence**: step 1's guardrail (`SKILL.md` line 12) targets the case of a designated URL that
  404s or renders empty and needs a fallback decision — not applicable here in the same shape as
  US-EVAL-005, since no live URL was ever designated as the primary source for this run (the brief
  itself directs grounding in "QuickPizza's own public documentation," not a live capture). No
  `WebSearch` call was made and no unrelated third-party target was substituted; every fetch was to
  `github.com`/`raw.githubusercontent.com` under the `grafana/quickpizza` or `grafana/awesome-k6`
  repos, i.e. the designated target's own canonical source, consistent with step 1's "fetch/read
  exactly that source — nothing else." Redaction guardrail (step 3) correctly recognized the
  quoted login credentials as the project's own published placeholder demo values, not real PII —
  same reasoning already applied to OpenEMR's `admin`/`pass` in US-EVAL-005 (state/00-source.md).
- **Modification proposed**: none.
