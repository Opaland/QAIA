# The first suites in the corpus to prove their assertions can fail (2026-08-08)

Until today, **`mutation.status` was `skipped` on every suite this project had ever scored.** Five
blank-context judges each had to write the same sentence: *the suite's assertions have not been
shown to be load-bearing, and no rubric score substitutes for that.*

That gap is now closed for the two showcase suites — the ones a visitor reads first.

| Suite | Candidates | **Executed** | Killed | Survivors | Static |
|---|---|---|---|---|---|
| `examples/expense-demo` (api, e2e, a11y, visual) | 75 | **75** | **75** | **0** | 95.3/100 |
| `examples/medibook` (api, e2e ×2, security, perf, a11y, visual) | 32 | **32** | **32** | **0** | 95.2/100 |
| **Total** | 107 | **107** | **107** | **0** | — |

Raw tool output next to this file: `expense-demo-all-projects.json`, `medibook-all-projects.json`.

**Read the `Executed` column, not the `Candidates` column.** It exists because the first version of
this page reported the same 107/107 while 40 of those mutations were never run at all. That is the
subject of the next two sections, and it is the more useful result of the day.

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

## The first version of this page was wrong, and the number that was wrong is the headline one

It read *107 mutations, 107 killed, 0 survivors, API suites only*. The count was right; the claim
under it was not. **Of those 107, only 67 were ever executed.** The other 40 were scored as kills
without a single test running.

Two defects in `automation_score.py`, both in the half of the tool that no fixture reaches:

1. **Playwright exits 1 for "a test failed" *and* for "No tests found".** The mutation corpus is
   built from every spec under `--tests-dir`, but `--run-cmd` was `--project=api` (expense) and
   `npx playwright test api.booking.spec.js` (medibook). Every candidate outside that selection was
   run, matched nothing, exited 1, and was counted as killed. **33 mutations**: 13 e2e + 4 visual on
   expense, 16 non-api on medibook.
2. **A test title containing an apostrophe was greped with its JavaScript escape.** `test('a
   manager\'s own report …')` was captured as `manager\'s`; the runner's title is `manager's`, so
   `--grep` matched nothing — and via defect 1, that read as a kill too. **7 mutations**, all on
   `api.expense.spec.js`, including both IDOR tests (`@QAIA-US-004-037`, `-039`) and the three
   `@low-confidence` escalation tests. Those seven sat *inside* the project the run had selected:
   the first defect alone does not explain them.

How it was found: re-running the same suite with `--run-cmd "… --project=e2e-desktop"` returned
**the identical total of 75**. A suite of 5 e2e tests cannot yield the same mutation count as a
suite of 43 API tests. Then `npx playwright test --project=api --grep "@QAIA-VIS-001 sign-in
screen"` printed `Error: No tests found` and exited **1**.

`expense-demo-api.json` and `medibook-api.json` are the original runs, kept unaltered. They are
what a contaminated result looks like; nothing in them says so, which is the whole point.

### Both defects are now caught rather than remembered

- The tool classifies a `No tests found` mutation as **`not_run`**, never as a kill, and reports
  `exercised` alongside `total`. A non-empty `not_run` list is **blocking**: a run that reports
  *n/n killed* while some assertions were never executed is exactly the silent truncation this
  project refuses to publish.
- Titles are unescaped before they reach `--grep`.
- `eval/tools/selfcheck_automation_score.py` asserts both invariants and runs in CI. It was checked
  in both directions: reverting the title fix makes it fail, restoring it makes it pass.

## A real survivor, and the page object it exposed

The first honest run — every project, nothing filtered — produced **one survivor**:
`visual.expense.spec.js:41`, `await expect(login.error).toBeVisible()` inverted to `toBeHidden()`,
test still green. Reproduced in isolation before touching anything.

The cause was in `pages/LoginPage.js`, not in the test. `signIn()` returned as soon as the click was
dispatched, so the message region was present-but-empty — that is, *hidden* — for a few
milliseconds. `toBeHidden()` passed on its first poll. **An assertion whose negation is satisfied by
the state before the action proves nothing about the action.**

The original `toBeVisible()` was not decorative: it auto-retries, so it does wait for the message
and would fail if it never came. What the mutant exposed is that it was doing the page object's
synchronisation work. `signIn()` now awaits the `/api/login` response. Baseline still 56/56 green;
the mutant is now killed; `expense-demo-defect-evidence.json` is the run that found it.

## Scope, stated

- **All projects, both suites.** api, e2e, a11y and visual on expense-demo; api, e2e desktop and
  mobile, security, perf, a11y and visual on medibook. The `--project` limit stated in the first
  version of this page is gone — it was the cause of defect 1, not merely a scope note.
- **Assertions the operators do not mutate are still out of reach.** `toHaveScreenshot` has no
  inverted expected value, so visual baselines are covered by the per-mutation SUT experiment in
  `eval/visual-check-2026-08-08/`, not here.
- **The campaign corpus is still unproven.** `US-EVAL-001` through `013` carry
  `mutation.status: skipped`, and nothing here changes that.
- **`US-EVAL-001`'s old 8/8 and 12/12 cannot be re-verified.** Both used an unfiltered
  `npx playwright test`, so defect 1 does not touch them; defect 2 cannot be ruled out, because the
  suite lived in a previous session's scratchpad and is no longer on disk. Treat those two figures
  as unconfirmed rather than as either sound or refuted.
- **Two suites out of the project's total.** The claim is exactly: *the two suites a visitor is
  most likely to read have assertions that can fail.* Not more.

## Why this run was worth doing at all

Every one of the five judge reports contained the sentence about load-bearing assertions, and each
time it was true and unresolved. A project whose argument is *our numbers are checkable* was
carrying, in five published reports, a mandatory disclaimer that its own examples had never
answered.

They answer it now — and the day's real lesson is that the first answer was false in the direction
that flattered us, in a tool written by this project to catch exactly that. It was not caught by
review; it was caught by running the same thing twice and noticing that two different questions had
returned the same number.
