---
name: locator-repair
description: Diagnose a Playwright test failing on a broken locator (getByRole/getByTestId not found or timed out) and propose a candidate fix as a reviewable diff with evidence-based justification -- never applied automatically. Use after a test fails with a locator-not-found/timeout error, ideally with the current DOM or ARIA snapshot available.
---

# locator-repair — diagnose a broken selector, propose a diff, never apply it

Deliberately adopts the failure-diagnosis idea popularized by "self-healing" test tools
(Shiplight AI, Playwright Test Agents) **without** their auto-application stance: a tool that
silently rewrites a selector to make a suite go green can convert a genuine UI regression into a
passing test, and the human never learns the control disappeared. QAIA therefore never runs or
edits a test file on its own initiative — same "AI proposes, human arbitrates" posture as
`prioritize` and `flaky-detect`.

Reference fixture: `fixture/` in this skill folder — three real, executed Playwright failures
against a purpose-built page (independent of `examples/medibook`/`examples/expense-demo`),
produced by writing tests against one HTML page, then editing that HTML to break them for
real. See `fixture/VALIDATION.md` for the worked example: one clean high-confidence fix, one
hedged medium-confidence fix, and one honest gap where no fix is proposed.

## Prerequisites

- A Playwright test that actually failed with a **locator-not-found / timeout** error on
  `getByRole`/`getByTestId` (or another Playwright locator). Not for assertion failures, app
  errors, or network issues — those are out of scope (see Guardrails).
- The **page object** (`pages/*.js`) that owns the broken selector. QAIA's automation convention
  is POM-as-fixtures: one page object per screen, exposed as a Playwright fixture, holding
  selectors only — assertions live in the tests, never in the page object.
  Without it, a diff can still be described but not placed precisely.

## Input

- The failing test's **error output**: which locator, which engine (`getByRole`/`getByTestId`/
  etc.), and Playwright's call log — from a real run (`run-report`'s JUnit/HTML output carries
  this, or raw `npx playwright test` console output).
- The **current DOM or ARIA snapshot**, if available:
  - Playwright's auto-captured `error-context.md` (a YAML page snapshot of roles/names) —
    sufficient to diagnose `getByRole` breaks, **not** `getByTestId` breaks (the ARIA snapshot
    does not carry `data-testid` attributes).
  - A raw DOM capture (`page.content()`, or the trace's DOM snapshot) — needed for
    `getByTestId` breaks.
- **Without at least one of these, the skill cannot diagnose** — it says so and stops rather
  than guessing from the selector text alone.

## Method

1. **Parse the failure.** Extract the selector engine and its arguments (e.g.
   `getByTestId('login-btn')`, `getByRole('button', { name: 'Remove item' })`) from the call
   log. Confirm the failure mode is genuinely locator-not-found/timeout — a real app error, a
   network failure, or an assertion mismatch is a different problem; say so rather than
   reinterpreting it as a selector break.
2. **Search the current DOM/ARIA snapshot for candidates**, using only what the broken locator
   itself constrains: same role (if role-based), same tag/context implied by the test, same
   visible text/label neighborhood. Count how many elements in the current DOM plausibly
   correspond to what the locator was targeting.
3. **Classify by evidence strength — never blur the three:**
   - **Zero candidates** (nothing in the current DOM shares role/structure/text with the
     missing target) → **gap**. No diff is proposed. State plainly that the DOM gives no basis
     for a fix and that a human needs to say what replaced the control (redesigned, relocated,
     removed).
   - **Exactly one plausible candidate**, differing from the broken locator only in the
     attribute that changed (same tag/id/text/position, only `data-testid` or the role name
     differs) → **high confidence**. Propose the diff.
   - **Multiple structurally-identical candidates** (e.g. a label rename applied uniformly
     across a list, tie broken by `.first()`/`.nth()` in the original test) → **medium
     confidence**. Propose the diff that preserves the test's own existing disambiguation, but
     say explicitly that the correspondence rests on DOM order, not a stronger identity signal
     — and flag it if a more stable attribute (e.g. an untouched `data-testid`) is visible on
     the candidates that the test could pin to instead.
   Never present medium or gap as high. **Never invent a selector with no visible match in the
   supplied DOM/ARIA snapshot** — a plausible-looking guess is not evidence (honest recall over
   fabrication).
4. **Draft the diff.** Target the page object: old locator line vs. new
   locator line, plus a short justification citing the exact evidence used (the DOM/ARIA
   snapshot excerpt that grounds the proposed value). The replacement selector stays
   `getByRole`/`getByTestId` — the project's selector policy is role/test-id first, positional
   XPath forbidden — never fall back to a positional/XPath selector to make a fix land.
5. **Never apply it.** Output the diff as a reviewable block only. Do not write it to the page
   object file, do not re-run the test to "confirm" it. Applying, re-running, and committing
   are the human's next action — identical discipline to `prioritize` (skill proposes, human
   decides) and `flaky-detect` (flag with evidence, never auto-fix).

## Output

For each broken locator, a finding with: the `@QAIA-*` test ID, the broken locator (engine +
args), the confidence tier (`high` / `medium` / `gap`), the DOM/ARIA evidence used, the target
file, and either a proposed diff or — for a gap — an explicit "no fix proposed" with the
reason. Markdown for human review, plus the same data as JSON. No verdict, no gate — this
skill only ever proposes.

## Steps

1. Collect the failing test's error output plus whatever DOM/ARIA snapshot is available (from
   a `run-report` run, a local `npx playwright test`, or Playwright's own `test-results/*`
   artifacts — `error-context.md` and/or a captured `page.content()`).
2. Apply the Method above, per broken locator.
3. Present the findings (diffs and gaps) for review. **Stop there.** Applying a diff, re-running
   the test, or committing the change is the user's explicit next action, never this skill's.

## Guardrails

- **Never apply a fix.** This skill's only output is a proposed diff (or a gap) for human
  review — no file write, no auto-retry, no auto-commit. Same posture as `prioritize` and
  `flaky-detect`.
- **Never invent a selector without DOM/ARIA evidence.** No snapshot, or a snapshot with no
  plausible candidate → report a gap, not a guess dressed up as a fix.
- **Scope discipline**: only locator-not-found/timeout failures. A test failing on a real
  assertion, an app error, or a network issue is out of scope — say so rather than
  reinterpreting an unrelated failure as a selector problem.
- **Selectors stay in page objects** (POM-as-fixtures): a proposed diff targets
  `pages/*.js`, never a test file's assertions.
- **No fallback to XPath/positional selectors** to make a fix land — the replacement must still
  be `getByRole`/`getByTestId`, even when that means reporting a gap instead of a weaker
  selector. A positional selector buys a green run today and breaks on the next DOM reshuffle,
  which is exactly the failure this skill was invoked to diagnose.
- **Distinguish confidence honestly**: high (one exact structural match) vs. medium (correct
  candidate, but disambiguation relies on order/position — flagged as such) vs. gap (no
  evidence) — never round medium or gap up to high.
