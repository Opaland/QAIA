---
stepsCompleted: [00-ingest, 01-review]
lastStep: 01-review
lastSaved: 2026-07-30
---

# 01-extraction — US-EVAL-011

## Story

**As a** QuickPizza visitor (via the UI's "Pizza, Please!" action, or a direct API caller),
**I want** to request a pizza recommendation against a set of dietary/topping restrictions,
**so that** I receive a valid suggestion quickly, including when many callers request one at the
same time.

*(`[reconstructed]` — the fetched sources are a README, a Go route table and k6 example scripts,
not a written user story; per `us-review` step 1, "no story phrasing found but a real capability
is described → reconstruct it and mark it `[reconstructed]`".)*

## Acceptance criteria (numbered, stable — AC1..AC3)

- **AC1.** A caller supplying a structurally valid `Restrictions` object (`maxCaloriesPerSlice`,
  `mustBeVegetarian`, `excludedIngredients`, `excludedTools`, `maxNumberOfToppings`,
  `minNumberOfToppings`, `customName`) to `POST /api/pizza` receives `HTTP 200` and a
  `PizzaRecommendation` response (`pizza`, `calories`, `vegetarian`).
- **AC2 (performance).** Under a concurrent load profile, `POST /api/pizza` keeps the 95th
  percentile response time under 500ms and the 99th percentile under 1000ms, with an HTTP error
  rate under 1% — the exact thresholds the project's own `k6/foundations/05.thresholds.js` example
  asserts against this same endpoint (`http_req_duration: p(95)<500, p(99)<1000`,
  `http_req_failed: rate<0.01`).
- **AC3.** A request whose `Restrictions` values are structurally invalid or self-contradictory
  (e.g. `minNumberOfToppings` greater than `maxNumberOfToppings`, a negative
  `maxCaloriesPerSlice`) is refused rather than silently accepted or silently defaulted.

## Business rules / constraints found outside the AC list

- `maxCaloriesPerSlice` defaults to 1000, `maxNumberOfToppings` defaults to 5,
  `minNumberOfToppings` defaults to 3 when the caller omits them (`pkg/http/http.go` field
  defaults) — a caller sending an empty/partial `Restrictions` object is not the same as an invalid
  one.
- `customName` is bounded by a `MaxPizzaNameLength` constant whose numeric value was not quoted by
  any fetched source.
- The project ships its **own worked k6 threshold example** (`05.thresholds.js`) against this exact
  endpoint — this is why AC2's numbers are grounded rather than invented, but the source does not
  state whether those numbers are an official SLO for the app or merely illustrative teaching
  values (flagged below, `need-understanding`).
- Authentication: `01.basic.js` and `17.login-action.js` both send an `Authorization: token <t>`
  header (obtained via `POST /api/users/token/login`, default demo creds `default`/`12345678`) when
  calling `/api/pizza`, but no fetched source states whether the header is *required* or merely
  used by these particular example scripts.

## Referenced artifacts not analyzed

- The full OpenAPI/Swagger spec for the API, if one exists in the repo — not located by any fetch
  performed; only the Go route source (`pkg/http/http.go`) and the k6 example scripts were read.
- The `k6/browser/` and `k6/extensions/` script folders — only `foundations/` scripts were fetched,
  since `05.thresholds.js` (the concrete threshold example) lives there.
- The microservices deployment manifests (`public-api`, `catalog`, `recommendations`, `config`,
  `copy`, `ws` services) — the README distinguishes monolithic vs microservices modes but neither
  mode's internals were fetched beyond the README's own summary.

## Present but not classifiable

- None.

## What was NOT found

- No formal AC numbering in the source (a README + Go source + k6 scripts, not a written ticket) —
  numbering above is this skill's own reconstruction.
- No statement of whether `05.thresholds.js`'s numbers are an official performance SLO vs. a
  teaching example, whether `/api/pizza` requires authentication, what the exact validation
  response looks like for AC3, or `MaxPizzaNameLength`'s numeric value — all carried to
  `need-understanding` as open points, none invented here.

## Journey

| Step | Status |
|---|---|
| 00-ingest | done |
| 01-review | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run, no human reviewer at this micro-step; only the pre-automation gate is a hard human stop per the campaign prompt) |

## Skill evaluation — `us-review`

- **Skill evaluated**: `plugins/qaia-core/skills/us-review/SKILL.md`.
- **Input**: `00-source.md` above (project README + Go route source + k6 example scripts, no
  story phrasing, no AC numbering, several unconfirmed behaviors already flagged at ingest).
- **Output**: this file.
- **Verdict**: **CONFORME.**
- **Evidence**: `SKILL.md` line 13 requires that when no story is present but a real capability is
  described, it be "reconstruct[ed]... mark[ed] `[reconstructed]`" — done verbatim in the Story
  section above. Step 2's "show the diff mentality... explicitly list what you did NOT find" (line
  18) is satisfied by the "What was NOT found" section, which lists both structural absences (no
  AC numbering) and content absences (SLO-vs-example ambiguity, auth requirement, validation
  response shape, `MaxPizzaNameLength`) without inventing any of them — correctly deferred to
  `need-understanding` per line 24 ("resolving it is the next skill's job, with the user").
- **Modification proposed**: none.
