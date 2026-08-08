# The automation rubric, applied by blank-context judges for the first time (2026-08-08)

Issue #63, last open checkbox: *« la rubrique LLM n'a jamais été appliquée par un agent. Elle est
écrite, pas validée. Tant qu'un juge à contexte vide ne l'a pas passée sur une vraie suite, elle
ne vaut rien de plus qu'une intention. »*

Two independent judges, dispatched with no generation context, on two suites **neither of them
nor this session had edited** — deliberately not `US-EVAL-001`, whose suite was modified on
2026-08-01, and whose scoring carried a declared conflict for exactly that reason.

| Suite | Total | Gate |
|---|---|---|
| `US-EVAL-002` toolshop checkout | **3 / 12** — three dimensions at 0 | **not met** |
| `US-EVAL-006` the-internet dynamic loading | **8 / 10 judgeable** (dimension 3 `n/a`) | not computable as written — see below |

## The limit of this run, stated first

These judges are agents dispatched by the project. They had **no generation context** — that
specific conflict, the one D136 declared, is removed. They are not independent of the project
itself, and no arrangement of subagents makes them so. What this run establishes is narrower than
"the rubric is validated": **the rubric discriminates, and applying it found more defects in the
rubric than in the code.**

Both judges also disclosed, unprompted, that they hit producer self-grading sections (`## Skill
evaluation — … Verdict: CONFORME`) inside files the rubric requires them to read, and stopped at
the heading. That the rubric's own required inputs contain verdicts a blank-context judge must
avoid is a finding in itself.

## What the judges found in the code

**`US-EVAL-002` — six negative tests that would pass against an app doing the forbidden thing.**
Verified independently before publishing: the file contains **6 `not.toBe(200)` assertions and
zero calls to `GET /invoices`**. Every negative scenario whose `Then` says *"and no invoice is
created"* asserts only that the response was not a 200 — on an endpoint this instance refuses
unconditionally for an unrelated reason (a rejected address). So the assertion is green whether or
not the validation under test exists. Ship an API that accepts a missing `guest_email` and creates
the invoice with a 201, and the suite still reports ✅ PASS.

The judge's sharpest point is not the assertion, it is the missing control: **a negative test
whose positive control is red proves nothing**, and three of these sit next to a `test.fail`-marked
positive.

**`US-EVAL-006` — an assertion that cannot detect the defect its scenario exists for.** Scenario
001's subject is *"Example 1's **pre-existing** hidden element"*, and the coverage matrix gives its
rationale as the *presence-vs-visibility defect class*. The code asserts `toBeHidden()`, which in
Playwright **passes on zero elements**. If Example 1 silently became Example 2 — element created
later instead of pre-existing — the test stays green and the feature's headline distinction becomes
unfalsifiable.

Worth being precise about where the fault lies, because it is the same pattern D136 found: the
scenario's `Then` says only *"Hello World! is not visible"*. **The code is faithful to the `Then`;
the `Then` is weaker than the scenario's stated purpose.** The judge scored fidelity 2 and
assertion-strength 1, which is the correct split — and it means the defect is in the test book
first, inherited by the code.

## What the judges found in the rubric — the larger result

Eight distinct defects across the two runs, several hit independently by both. All are now fixed
in `eval/AUTOMATION-RUBRIC.md`:

| Defect | Fix applied |
|---|---|
| No `n/a`, but a fixed /12 denominator: a book honestly declaring zero negative scenarios makes the gate arithmetically unreachable | `n/a` allowed; gate rescales to ≥ 75 % of judgeable points |
| No aggregation rule — level wordings mix "one test…" and "each scenario…" | **Worst-instance**, stated. Both judges had adopted it independently |
| One defect satisfies the level-0 wording of dimensions 1, 3 and 5 at once — up to a 4-point swing on the judge's discretion | Charge it to the dimension whose *subject* it is, name it once elsewhere, and say which |
| Dimension 3 keyed on the `@negative` tag, so an untagged scenario claiming absence escapes it | Rewritten tag-independent: *assertions that would survive an inert app* |
| Dimension 3 said nothing about positive controls | A negative with a red positive control cannot score 2 |
| Dimension 4 gave no rule for a flag carried on the wrong scenario, nor for `test.fail` | Flag must be on the flagged scenario; `test.fail` does not excuse an unflagged assertion |
| `mutation.status = "skipped"` unhandled — the guardrail only scripted `blocked` | Any non-completed mutation state triggers the same mandatory sentence; `skipped` named as the weaker state |
| The judge/tool boundary is blurrier than "don't re-score what a machine counts": `not.toBe(200)` is a real assertion by static count and vacuous against the spec | Written down: the tool judges assertion **shape**, the judge judges assertion **vacuity against the specification** |

Two further defects are **recorded and not fixed**, because they are scope decisions rather than
wording:

- **Tests that trace to no scenario are outside every dimension.** `a11y.toolshop-checkout.spec.js`
  contributes 3 of 14 tests and no dimension covers them; the tool reported
  `testbook_scenarios: 0`. Neither judge nor machine looked at a fifth of the suite.
- **Dimension 2's ladder has a hole**: level 0 needs a literal that contradicts the source *or* an
  assumption encoded as a requirement; level 1 needs one that is *plausible **and** harmless*. An
  unsourced-but-plausible literal that is load-bearing for six other tests is neither. One judge
  went to 0 and said another would defensibly say 1 — a one-point swing on wording alone.

## What this does not settle

- The campaign suites were **not modified**. They are evaluation evidence; correcting them would
  destroy the record of what the generator produced. The findings are recorded here and belong in
  the generator's next pass, not in a retrofit.
- Neither judge ran the code. Both said so. `mutation.status` is `skipped` on both suites, so
  **neither suite's assertions have been shown to be load-bearing** — the rubric now forces that
  sentence into every output where it applies.
- Two suites, not the four the issue names. `US-EVAL-013` and the rest are unjudged.

---

## Third judge, same day: `US-EVAL-008` — 2 / 12

Dispatched *after* the revision, to put the freshly written rules under load. It applied them —
and broke one.

**The heaviest finding, verified by hand before publishing.** `e2e.cart-checkout.spec.js:33` and
`:60` assert `expect(alertText.length).toBeGreaterThan(0)` for a scenario whose `Then` requires
the alert *"Your token has expired, please login again."* **and** the absence of *"Product
added."*. The string `Product added` has a length greater than zero, so **the test passes against
the exact behaviour it exists to forbid.** A regression that removed the error branch entirely
would leave 8/8 green and the traceability table reporting PASS.

Two more of the same shape: `expect(confirmText).toContain('Amount:')` for a scenario whose
purpose is catching a *wrong computed amount* — it passes on `Amount: 0 USD` with a loaded cart —
and a `Then` clause (`and a request to clear the cart is sent`) dropped from both the code and the
run report while the row is reported as passed.

**Three further rubric defects, all fixed the same day:**

1. **"Count a defect once" did not say what happens to the *other* dimension.** Its levels are
   written as universals ("*every* test asserts…"), so after charging a defect elsewhere it is
   unclear whether the dimension may still claim the universal. The judge documented both
   readings and the one-point gap between them — precisely the variance the revision existed to
   remove. Settled: the dimension is scored on its remaining instances and **may still reach 2**.
2. **The "green positive control" clause was unverifiable** with the inputs the protocol hands
   the judge — neither the book, nor the code, nor the static JSON contains a run result. Fixed
   in both directions: run results join the judge's inputs when they exist, and failing that the
   judge must say the control's *existence* was checked and its *result* was not.
3. **The run report is simultaneously a required input and a self-assessment document.** All
   three judges hit a producer self-grading section and disclosed it unprompted. The protocol now
   says: read the run report, stop at the first heading that grades the producer.

## Where three applications leave it

| Suite | Total | Gate |
|---|---|---|
| `US-EVAL-002` | 3 / 12 | not met |
| `US-EVAL-006` | 8 / 10 judgeable | not met once rescaled |
| `US-EVAL-008` | 2 / 12 | not met |

**Three suites judged, none passes the gate — and eleven defects found in the rubric against five
in the code.** That ratio is the result. An instrument nobody has applied measures mostly the
confidence placed in it, and the first three applications of this one spent most of their effort
correcting the instrument.

One consequence worth stating plainly: the deterministic tool reported `blocking.failed: false`
on all three suites. It counts shapes, and all three are shapely. **A suite can be shapely and
vacuous**, which is exactly why the two scores are never summed and why the rubric's gate — not
the tool's — decides whether a run ships.

---

## Fourth judge: `US-EVAL-013-mobile` — 5 / 12

The mobile suite, chosen deliberately: QAIA's stated position is that mobile means browser
emulation and never native, so this run tests whether the code and its report honour a claim the
project makes loudly.

**On that specific question the suite passes, and it deserves saying.** The judge found the
emulation-only position stated in the config header, repeated at the top of all three spec files
and in the run report, with the cheap version explicitly refused: *"Running both on one engine
would only be window-resizing, not mobile emulation."* No result about a native app is claimed
anywhere. **No honesty defect on the axis the project is most exposed on.**

The two failures are elsewhere, and both were verified by hand before publishing.

**Five `@low-confidence` flags in the test book, zero in the code.** `grep` over the three spec
files returns no `low-confidence`, no `open: Q`, no `test.fixme`, no `test.fail`. The most
contestable call of the whole run — *is a 20 × 20 px burger, the only phone navigation control, an
acceptable target size?*, which the book itself marks `[open]` and calls "the single most
contestable call" — is asserted in code as `toEqual({ width: 20, height: 20 })` and reported green.

The failure scenario the judge draws from it is the useful part: SauceDemo ships an accessibility
fix, the burger becomes 24 × 24, and a **P1 test with no retries** goes red on both descriptors
with the title *"the burger is 20x20 CSS px, below the 24x24 minimum"*. The on-call reader has no
signal anywhere that this red **is the answer to the open question arriving** rather than a
regression. The likeliest resolution is that someone edits the expected value to match the app —
**silently converting a WCAG finding into a WCAG specification.**

**A test project listed as "actually used" that ran nothing.** `playwright.config.js` declares an
`e2e-desktop` project scoped by `testMatch: /e2e\.desktop-.*\.spec\.js/`; the suite contains three
files, all `e2e.mobile-*`. So the "contrast project for the ≥ 481 px side" executed zero tests —
while the run report's table, headed *"Device descriptors actually used (the point of this run)"*,
lists it. The report's own arithmetic contradicts it two dozen lines later (`42 = 21 blocks × 2
descriptors`).

**Four more rubric defects, all fixed:**

1. **No tie-break between dimensions 1 and 2** when an assertion is both "something the `Then`
   never contained" and "an unsourced literal". Two points hung on the judge's choice. Settled: an
   assertion the `Then` never contained *at all* is dimension 1; a wrong or unsourced *value*
   inside an assertion the `Then` does contain is dimension 2.
2. **Dimension 3's ladder had a gap the new positive-control clause opened**: a test that asserts
   the refusal *fully*, with the right oracle, but has no positive control matched neither level 2
   nor level 1's wording. Level 1 now covers it — and two sub-questions the judge had to rule on
   alone are written down: a control may live in another test block, and a vacuous assertion
   inside an otherwise discriminating test belongs to dimension 5, not 3.
3. **Dimension 4's refinement never engaged**, because there were no misplaced flags — there were
   no flags at all. Added: a flagged scenario carrying no flag anywhere is level 0 regardless of
   what it asserts, since the next reader cannot tell a red test from a regression.
4. **The rubric never said whether a false claim in the run report is chargeable.** The report is
   offered as evidence *for* dimension 6, so it now answers to the same honesty test as the code.

## Where four applications leave it

| Suite | Total | Gate |
|---|---|---|
| `US-EVAL-002` toolshop checkout | 3 / 12 | not met |
| `US-EVAL-006` dynamic loading | 8 / 10 judgeable | not met once rescaled |
| `US-EVAL-008` demoblaze | 2 / 12 | not met |
| `US-EVAL-013` mobile | 5 / 12 | not met |

**Four suites judged, none passes the gate. Fifteen defects found in the rubric against nine in
the code.** The instrument absorbed more correction than the thing it measures, which is the
honest summary of what "the rubric had never been applied" actually meant.

Two facts that recur across all four and are not about any one suite:

- **`mutation.status` is `skipped` on every one.** No suite in this corpus has been shown to have
  load-bearing assertions. The rubric now forces that sentence, and it appeared in all four
  reports.
- **The deterministic tool reported `blocking.failed: false` on all four.** It counts shapes; all
  four are shapely. Three of the four are vacuous against their own specification in at least two
  dimensions. That gap is the entire argument for keeping a semantic judge, and it is now
  measured rather than asserted.

---

## Fifth judge: `US-EVAL-004-juiceshop-password-reset` — 4 / 12

And it found the worst defect of the corpus, by a wide margin. Verified by hand before publishing.

**The test asserts the inverse of its own `Then`.**

The book (`password-reset.feature:21`) demands, for an email that is *not* a registered account:

> Then the Security Question field **is enabled, the same as for a registered email**
> And nothing in the response identifies the email as unregistered

The generated test (`e2e.password-reset.spec.js:44`) asserts:

```js
expect(enabled).toBe(false);
```

Juice Shop's `GET /rest/user/security-question` is public and unauthenticated. The scenario exists
to check whether it leaks account existence; the book generated the safe default — *no
distinguishable signal* — and **the code asserts the opposite**.

The consequence is not academic. The day this suite runs green, it is green **because the
application leaks account existence to an anonymous caller** — a user-enumeration oracle for
harvesting valid customer emails before a credential-stuffing run. The suite has converted the
exact defect the scenario exists to detect into its pass condition, and CI will hold that line
green indefinitely. And if the application is later fixed to stop leaking, the test goes red —
with no `@low-confidence` marker anywhere — and reads as a regression to be reverted.

Second finding, smaller and now machine-checked: `pages/api-helpers.js:29` carries *"a real
finding, see automation/NOTES.md"*. `automation/NOTES.md` does not exist.

The judge also credited what the suite does well, which is worth recording: on the
refused-versus-merely-not-successful axis it is **better than typical** — it re-authenticates with
the original password to prove the account state is unchanged, a real oracle rather than a
`not.toBe(200)`. What is missing is the other half (no assertion that no reset token was issued,
no notification triggered), and the book never demanded it, so it is not chargeable.

**Four more rubric defects, all fixed:**

1. **Dimension 3 had no state for "the run report exists and says nothing ran."** This suite's
   report is unusually honest — *10/10 BLOCKED, not passed* — and the literal reading capped the
   dimension at 1, scoring an honestly blocked run the same as one whose control was observed red.
   Fixed: a report declaring everything blocked counts as *no run report*, and the level-1 cap is
   reserved for a control that actually ran and was not green.
2. **Dimension 5's "the claim" was undefined** — the `Then`, or the scenario as a whole? On one
   line, dimension 1 *rewards* a test for staying as vague as its `Then` while dimension 5 would
   punish it for the same vagueness, and "default lower when hesitating" forces a contradiction.
   Fixed: the `Then` is the contract for both, and a scenario *title* claiming more than its `Then`
   is a **test-book** defect belonging to the other rubric.
3. **"Count a defect once" was read per scenario rather than per defect.** This suite has an
   inverted assertion *and* a dropped flag on the same scenario — two independent mistakes, and
   the judge nearly declined the second charge out of fairness. Fixed: per defect, explicitly.
4. **Dimension 6 did not authorise charging a dead citation in *code*** — only in the run report.
   Fixed and generalised, and now also caught mechanically.

## Where five applications leave it

| Suite | Total | Gate |
|---|---|---|
| `US-EVAL-002` toolshop checkout | 3 / 12 | not met |
| `US-EVAL-004` juiceshop password reset | 4 / 12 | not met |
| `US-EVAL-006` dynamic loading | 8 / 10 judgeable | not met once rescaled |
| `US-EVAL-008` demoblaze | 2 / 12 | not met |
| `US-EVAL-013` mobile | 5 / 12 | not met |

**Five suites judged, none passes. Nineteen defects found in the rubric against twelve in the
code.** The instrument still absorbs more correction than the thing it measures, though the ratio
is narrowing as the rubric hardens.

## And three of those findings are now machine checks

The point of running five judges was never the five scores. It was to find out what a reading
judge sees that a static tool does not — and then to move whatever could move.

Three did: `flag-dropped` (blocking), `single-sided-evidence` and `dead-citation`, all in
`automation_score.py`, all with a fixture and all verified against the real corpus with zero false
positives on the one corrected suite. Adding the third **uncovered a real bug in the tool itself**:
it only ever looked under `--tests-dir`, so on the `automation/{tests,pages}` layout it could not
see the page objects at all — which is why `pom-missing` was being reported on suites that have
`pages/`. Two independent judges had flagged that as a probable tool bug before anyone checked.

What stays with the judge is what needed reading comprehension: an assertion inverted against its
`Then`, an assertion faithful to a `Then` that is itself weaker than its scenario's purpose, a
literal with no provenance, a project listed as used that ran nothing. That list is the honest
answer to "why keep a semantic judge at all", and it is now evidence rather than argument.
