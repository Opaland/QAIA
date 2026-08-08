---
name: impact-select
description: From a diff and an existing Playwright suite, work out which tests to re-run, which may break, and what the change leaves uncovered - stating whether the answer is grounded in coverage data or is a declared hypothesis. Use on a pull request, before a targeted re-run, or when asked what a change puts at risk.
---

# impact-select — what a change puts at risk

The chain's other entry points start from a requirement. This one starts from **a diff**, which is
what a developer has every day — a user story arrives once a sprint. That asymmetry, not the
technique, is why this skill exists.

## The rule that keeps it honest

**Say which of two questions you answered.**

- *Grounded*: coverage data exists from a real instrumented run, so "these tests exercise this
  line" is a **fact**.
- *Hypothesis*: no coverage data, so the answer comes from reading imports, fixtures and names. It
  is a **reading**, and it must be labelled as one on every line of the output.

A selection presented as fact when it is a reading is the failure mode here: it tells a team it is
safe to skip tests, on the strength of a guess. When in doubt, **over-select**. A test run for
nothing costs seconds; a defect shipped because its test was deselected costs the trust that made
anyone use the tool.

## The two questions to answer, in order

1. **What must be re-run?** The tests that touch the changed code, directly or transitively.
2. **What does the change leave uncovered?** The changed code that **no** test reaches. This is the
   output with the most value and the one nobody asks for.

## The dependency chain, and the step everyone forgets

A Playwright suite reaches production code through three hops, and the middle one is where naive
analysis fails:

```
spec file  →  fixtures  →  page objects / helpers  →  the application
```

**A spec that never names a page object still depends on it**, through a fixture. In the reference
measurement below, the specs that failed the most were precisely those that never mention the
changed file by name.

So the walk must be transitive over `require`/`import`, through fixtures, and it must include
whatever a fixture constructs — not just what a spec names.

## Measured, not asserted

Protocol: change one file, predict the impacted tests **from the diff alone**, then break that file
for real and run the whole suite. What actually fails is the ground truth.

Target: `examples/expense-demo`, 56 tests, 4 projects. Changed file: `pages/LoginPage.js`
(`signIn`). Raw measurement in `eval/impact-select-2026-08-08/`.

| Approach | Predicted | Actually failed | Missed | Over-selected |
|---|---|---|---|---|
| Naive — specs naming `LoginPage` | 6 | 10 | **6** | 2 |
| Transitive — through `fixtures.js` | 13 | 10 | **0** | 3 |

The naive reading over-selects too: it predicts all six `visual` tests and only four of them fail.
It is not more precise, it is merely smaller — which is the trap.

Read the `Missed` column. The naive reading **misses 6 of the 10 impacted tests** — every e2e test
and one accessibility test, none of which names `LoginPage` anywhere. They reach it through the
`employee` and `openActor` fixtures. A team that trusted that reading would have skipped the tests
that broke.

The transitive reading misses nothing and over-selects 3. The three are explicable, which matters
more than the number: two visual tests exercise the sign-in *screen* without ever signing in
successfully, and one accessibility test checks the login page itself. **None of the 43 API tests
was selected, and none failed.**

Recall 10/10, precision 10/13. **Recall is the metric to protect** — precision costs seconds,
recall costs defects.

## Steps

1. **Get the diff.** `git diff <base>...<head> --name-only` plus per-file hunks. Note the base:
   a selection is only true against a stated pair of revisions.
2. **Classify each changed file.** Application code, page object, fixture, spec, config,
   documentation. A change to a fixture or to the config reaches **everything** downstream — say so
   rather than computing a list that looks precise.
3. **Walk the dependency graph transitively**, spec → fixture → page object → application. Include
   what fixtures construct.
4. **Say which question you answered.** Grounded or hypothesis. If coverage data exists, use it and
   say where it came from, including its date — coverage from a stale run is a hypothesis wearing
   a fact's clothes.
5. **Find the uncovered change.** Changed code that nothing reaches. Name it; do not soften it.
6. **Emit** the re-run set, the at-risk set with a reason per entry, and the uncovered set.

## What this skill must refuse

- **Presenting a hypothesis as a fact.** Every line of a non-grounded output carries its basis.
- **Recommending a deselection when the changed file is a fixture, a config or a shared helper.**
  The blast radius is the whole suite; the honest answer is "run everything".
- **Claiming a change is uncovered without checking the transitive path.** That is the naive
  reading, and it was measured wrong above — 6 misses out of 10.
- **Ranking by file-name similarity.** `LoginPage.js` and `login.spec.js` looking alike is not a
  dependency. It is a coincidence that happens to be right often enough to be dangerous.
