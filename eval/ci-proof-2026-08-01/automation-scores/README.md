# Automation judge — first run on real suites (2026-08-01, issue #63)

`eval/tools/automation_score.py` and `eval/AUTOMATION-RUBRIC.md` were built on 2026-07-31 and
validated only against a purpose-built fixture. This directory holds their **first application to
the suites the campaigns actually produced**.

## Static track — all eight suites

Run with `--skip-mutation` (no running app required). Raw JSON per suite in this directory.

| Suite | Static /100 | Assertions 30 | Selectors 25 | POM 20 | Traceability 25 |
|---|---:|---:|---:|---:|---:|
| US-EVAL-001 saucedemo-login | **100.0** | 30 | 25 | 20 | 25 |
| US-EVAL-002 toolshop-checkout | 80.0 | 30 | 25 | 0 | 25 |
| US-EVAL-005 openemr-appointment | 80.0 | 30 | 25 | 0 | 25 |
| US-EVAL-013 mobile | 80.0 | 30 | 25 | 0 | 25 |
| US-EVAL-006 the-internet-dynamic-loading | 75.0 | 30 | 25 | 0 | 20 |
| US-EVAL-008 demoblaze | 55.0 | 30 | 0 | 0 | 25 |
| US-EVAL-009 octoperf-petstore | 55.0 | 30 | 0 | 0 | 25 |
| US-EVAL-004 juiceshop-password-reset | **48.8** | 30 | 0 | 0 | 18.8 |

**No blocking finding in any of the eight.** Every suite has at least one real assertion per test
— the hollow-assertion class is genuinely absent from this corpus.

**What the spread actually shows.** The tool independently reproduces a defect the 2026-07-30
campaign had reported by hand: `US-EVAL-008` and `US-EVAL-009` bypass page-objects-as-fixtures
(20/23 and 20/20 raw selectors, POM 0/20). It also surfaces `US-EVAL-004` as the weakest suite in
the corpus — 4 raw selectors, no page objects, and 6 of 8 tests tagged rather than 8.

That is the point of the tool: those are the two defect classes `automate`'s self-review, being
the producer, was never going to report about itself.

## Mutation track — US-EVAL-001 only

The only campaign suite with dependencies installed and a reachable target.

| | Before the rubric pass | After |
|---|---|---|
| total | 8 | 12 |
| killed | 8 | 12 |
| survived | **0** | **0** |

Every assertion is load-bearing: inverting any one turns its test red. **The seven other suites
have never had their mutation track run** — their assertions have *not* been shown to be
load-bearing, and their static scores must not be read as if they had.

## Rubric track — US-EVAL-001 only, and not by a valid judge

`US-EVAL-001-rubric.md`. Scored **10/12**, and the result carries a declared conflict: I had
edited the suite earlier the same day and held the full generation context, both of which the
rubric explicitly excludes. It is recorded because the finding it produced is real and checkable
by anyone; it is **not** evidence that the suite scores 10/12.

**The finding**: scenarios `003` and `004` asserted only that *an* error was visible, where the
requirement says a **generic** message — so both passed against an application answering
"No such user" to one and "Wrong password" to the other, i.e. against the user-enumeration defect
the word exists to forbid. The weakness was in the test book first; the code inherited it.

Fixed and verified the same day, including a new scenario `007` asserting the two refusals are
identical **to each other** — the requirement no per-scenario assertion could express.

## What remains open (#63)

- The rubric has still **not** been applied by an independent judge in a fresh session. One
  conflicted pass is not the checkbox.
- Seven suites have **no** rubric pass and **no** mutation run.
- `qaia-score:automation-score` now exists as a product skill; it has not yet been exercised by
  an agent that was not its author.
