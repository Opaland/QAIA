# The first suites in the corpus to prove their assertions can fail (2026-08-08)

Until today, **`mutation.status` was `skipped` on every suite this project had ever scored.** Five
blank-context judges each had to write the same sentence: *the suite's assertions have not been
shown to be load-bearing, and no rubric score substitutes for that.*

That gap is now closed for the two showcase suites — the ones a visitor reads first.

| Suite | Mutations | Killed | Survivors | Static |
|---|---|---|---|---|
| `examples/expense-demo` (API) | **75** | **75** | **0** | 95.3/100 |
| `examples/medibook` (API) | **32** | **32** | **0** | 95.2/100 |
| **Total** | **107** | **107** | **0** | — |

Raw tool output kept next to this file: `expense-demo-api.json`, `medibook-api.json`.

## What a mutation run does, and what it does not

The tool inverts the expected value of each assertion in turn — a status becomes a different
status, an expected string gets a marker appended — and re-runs the test. **An assertion that
survives its own inversion is decorative**: the test passes whether or not the application does
the thing.

107 mutations, 107 killed means every assertion in both suites is sensitive to its own expected
value.

**It does not mean the assertions check the right thing.** Mutating the *test* proves an assertion
is load-bearing; it says nothing about whether the expectation matches the requirement. That is
the semantic judge's question, and the two numbers are never summed — same reason the structural
score and the LLM rubric stay apart at the test-book level.

## The cap, and why the first run was thrown away

The first run was capped at 25 mutations. It returned 25/25 — **and it hit the cap**, so it said
nothing about the remaining 82. Reporting "25/25, no survivors" from a run that stopped at its own
ceiling would have been a silent truncation: a number that reads as complete because nothing in it
says otherwise.

Re-run uncapped (`--max-mutations 0`). The numbers above are the full sweep.

## Scope, stated

- **API suites only.** The E2E, a11y and visual projects were not mutated: they need a browser per
  mutation and the run time grows accordingly. Their assertions remain unproven in this sense.
- **The campaign corpus is still unproven.** `US-EVAL-001` through `013` all carry
  `mutation.status: skipped`, and nothing here changes that. These are the *showcase* suites, not
  the evaluation corpus.
- **Two suites out of the project's total.** The claim is exactly: *the two suites a visitor is
  most likely to read have assertions that can fail.* Not more.

## Why this run was worth doing at all

Every one of the five judge reports contained the sentence about load-bearing assertions, and each
time it was true and unresolved. A project whose argument is *our numbers are checkable* was
carrying, in five published reports, a mandatory disclaimer that its own examples had never
answered.

They answer it now.
