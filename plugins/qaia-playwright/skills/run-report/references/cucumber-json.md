# Cucumber JSON from a Playwright run — the conversion, spelled out

## The thing to know first

**Playwright's `json` reporter does not emit Cucumber JSON.** They are unrelated formats: the
Playwright reporter emits a `suites` tree of `specs` and `tests`; Cucumber JSON is a flat array
of *features*, each holding *elements* (scenarios), each holding *steps*. Feeding
`results.json` to an importer that expects Cucumber JSON fails, or worse, imports nothing and
reports success.

There is no maintained Playwright→Cucumber-JSON reporter on npm to delegate this to (checked
2026-08-01). So this is a conversion QAIA performs itself, from the native `json` reporter's
output, and this file is the specification of that conversion.

**Produce it only when something actually consumes it** — Xray in git-master mode, or a BDD
reporter. Most CI dashboards and ALMs take JUnit XML, which is native and lossless. An unread
Cucumber JSON is a file that can quietly go wrong for months.

## Where each field comes from

| Cucumber JSON | Source in the Playwright `json` report | Notes |
|---|---|---|
| `uri` | the test book's `.feature` path | Not the spec file. The importer matches on the feature. |
| `id` | slug of the feature name | lowercase, non-alphanumerics → `-` |
| `name` | `Feature:` line of the test book | |
| `keyword` | `"Feature"` | constant |
| `elements[].id` | `<feature-id>;<scenario-slug>` | |
| `elements[].name` | scenario name from the test book | |
| `elements[].keyword` | `"Scenario"` | `"Scenario Outline"` examples still emit `"Scenario"` |
| `elements[].type` | `"scenario"` | constant |
| `elements[].tags[]` | `@QAIA-<US>-<NNN>`, `@ACn`, `@Pn` from the test title | `{"name": "@AC1", "line": n}` |
| `elements[].steps[]` | the Given/When/Then of the scenario | see below |
| `steps[].result.status` | `spec.tests[].results[].status` | mapping below |
| `steps[].result.duration` | `results[].duration` × 1e6 | **nanoseconds**, not milliseconds |
| `steps[].result.error_message` | `results[].error.message` + `.stack` | failed steps only |

## Status mapping

| Playwright | Cucumber |
|---|---|
| `passed` | `passed` |
| `failed` / `timedOut` | `failed` |
| `skipped` | `skipped` |
| `interrupted` | `failed` |

Playwright's `expected` / `unexpected` live on the *spec*, not the result — map from
`results[].status`, and treat an `unexpected` pass (a `test.fail()` that passed) as `failed`,
which is what it means.

## The step problem, and the honest way to handle it

A native Playwright test is **one function**, not a sequence of Given/When/Then steps. The step
granularity Cucumber JSON expects does not exist in the run data — this is the direct consequence
of D5 (no Cucumber layer). Two options, and only these:

1. **Single synthetic step per scenario** (default). Emit one step whose `keyword` is `"*"` and
   whose `name` is the test title, carrying the scenario's real result. Honest: the importer gets
   accurate scenario-level pass/fail, and nothing pretends to know which step failed.
2. **Real steps via `test.step()`** — when the generated spec wraps each Gherkin clause in
   `test.step('Given ...', ...)`, read `results[].steps[]` and map one-to-one. `automate` can
   generate this on request; without it, option 1 applies.

**Never synthesise steps by re-parsing the `.feature` and marking them all `passed` because the
test passed.** It produces a report claiming per-step evidence that no execution produced — a
fabricated result, and the one thing step 2 of the skill forbids outright. If option 2 was not
used, the report says the granularity is scenario-level.

## Shape

```json
[
  {
    "uri": "testbooks/login-gate.feature",
    "id": "saucedemo-login-gate",
    "keyword": "Feature",
    "name": "SauceDemo login gate lets through only valid, non-locked credentials",
    "elements": [
      {
        "id": "saucedemo-login-gate;a-valid-non-locked-account-logs-in",
        "keyword": "Scenario",
        "name": "A valid, non-locked account logs in and reaches the product catalog",
        "type": "scenario",
        "tags": [
          { "name": "@QAIA-US-EVAL-001-001", "line": 5 },
          { "name": "@AC1", "line": 5 }
        ],
        "steps": [
          {
            "keyword": "*",
            "name": "QAIA-US-EVAL-001-001 @AC1 - valid non-locked account reaches the product catalog",
            "result": { "status": "passed", "duration": 505000000 }
          }
        ]
      }
    ]
  }
]
```

## Before handing it to an importer

- The file is a **top-level array**, not an object. This is the most common conversion mistake.
- `duration` is in **nanoseconds**. Milliseconds make every scenario look instantaneous and some
  importers reject the run.
- Every `elements[]` entry has at least one `steps[]` entry; an empty `steps` array imports as a
  scenario with no result in most tools.
- Scenario counts match the manifest's `execution.total`. If they disagree, the conversion
  dropped something — fix the conversion, never the count.
