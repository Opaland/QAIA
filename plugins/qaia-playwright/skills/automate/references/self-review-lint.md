# Step 5 — the self-review lint, in full

## What it is, and what it is carefully not

Before each `*.spec.js` is written to disk, re-scan the assertions it is about to contain and
fix what is hollow.

This is a **proofread inside generation**, not a score and not a gate. It is the same posture
`qaia-score` takes at the Gherkin level with its hollow- and vague-assertion detectors
(`eval/tools/structural_score.py`, checks C1/C2), one layer down in the generated code — run by
the producer on its own output **before delivery**, never as a validation of already-delivered
work.

That boundary matters and is not decorative: the shared rule is that **no producer scores
itself** (`plugins/qaia-core/skills/README.md`, rule 3). So this pass never touches
`.qaia/reports/**/manifest.json`'s `gate` field, and `qaia-score` still never reads generated
`.spec.js` files. The contract boundary is unchanged — a generator is allowed to proofread
itself, never to grade itself.

It runs on every generated spec and is silent when clean.

## The four defects to flag

### D1 — Tautological / reflexive comparisons

`expect(true).toBe(true)`, `expect(1).toBe(1)`, `expect(x).toBe(x)`, or any `expect(<literal>)`
compared against that same literal.

A constant asserted against itself. No SUT state is involved, so the test cannot fail for any
reason connected to the application.

### D2 — Contentless `expect()` calls

No argument, or an argument that is a hardcoded literal rather than something read from the page
or the response: `expect(true).toBeTruthy()`, `expect("ok").toBeTruthy()`.

Nothing about the app is being checked.

### D3 — Weak-by-construction matchers

`.toBeDefined()` or `.not.toBeNull()` **on a Playwright locator handle**.

This one is worth stating precisely because it looks like a real assertion. Playwright locators
are **lazy**: `page.getByTestId('nope')` returns a perfectly valid, truthy object whether or not
that element exists anywhere in the DOM. Asserting the handle is defined asserts that
`getByTestId` returned an object — which it always does.

The real check is **state**: `toBeVisible`, `toHaveText`, `toHaveCount`, `toHaveURL`, a response
status or body.

### D4 — Silent zero-assertion blocks

A test mapped from a scenario that *had* a `Then` in step 1, but whose generated body contains
zero `expect(...)` calls.

Coverage promised by the scenario, dropped in the code. The scenario still appears in the
traceability table, still counts as automated, and verifies nothing.

## On a hit — self-correct before writing

Derive the real assertion from the scenario's `Then` text — the concrete value, status or
visible state it names — using the page object or response already in scope, and replace the
trivial assertion.

**If the `Then` itself names no concrete, assertable value, do not fabricate a plausible-looking
check to fill the gap.** Leave the marker in the file:

```js
// TODO(automate): "<Then text>" has no concrete assertable value — needs a human
```

and list the scenario as **blocked-for-assertion** in the traceability report (step 8). Same
honesty posture as a scenario that cannot run at all: a gap that is visible costs one line in a
report, a gap papered over with a plausible assertion costs the credibility of every green run
in the suite.

## Validated against a purpose-built fixture

The lint is not asserted to work — it is demonstrated on a case built for it:

- `fixture/scenarios.feature` — the source scenarios;
- `fixture/generated-before.spec.js` — three deliberately injected violations;
- `fixture/generated-after.spec.js` — the same file with the self-review applied;
- `fixture/VALIDATION.md` — the worked example, and how each fix was mechanically checked.

## The hard rule

**Never let a trivial assertion reach disk.** A spec file is not "done generating" until its
`expect(...)` calls have been re-scanned and each one either fixed or explicitly marked
blocked-for-assertion.
