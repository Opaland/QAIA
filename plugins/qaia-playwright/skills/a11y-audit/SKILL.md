---
name: a11y-audit
description: Generate and run accessibility tests (axe-core via Playwright, WCAG 2 A/AA) against a running app, reporting violations by severity. Use for accessibility coverage of a test book or an app.
---

# a11y-audit — accessibility via axe-core

Reference: `examples/medibook/tests/a11y.booking.spec.js` (0 serious/critical violations). 
Tooling is fixed: **axe-core driven through Playwright** — the de-facto standard for
automated WCAG checks, and it reuses the browser context the functional tests already
run in rather than introducing a second driver stack.

## Steps

1. For each key screen the test book covers (and any the user names), generate an axe-core check: navigate, **assert a real element of that screen is visible** (client-rendered apps serve an empty shell such as `<div id="app"></div>`; auditing before paint returns 0 violations), then run `AxeBuilder({page}).withTags(['wcag2a','wcag2aa']).analyze()`.
2. Fail the test on **serious/critical** violations; list all violations (id + impact + node) in the report. Also list `results.incomplete` (axe's "needs review") separately — serious findings live there and are invisible to the fail rule. A green run is only meaningful if the audit saw the screen: assert `results.passes.length > 0` alongside the readiness locator.
3. Tag each test `@QAIA-A11Y-<NNN>` for traceability; run against the app and report real results.

## Guardrails

- Report violation ids honestly; never suppress to make a suite green.
- axe covers a subset of WCAG. Report `0 serious/critical` as *no axe-detectable* serious/critical issue on that screen, never as "accessible" or "screen X is covered".
- A11y is additive — it does not replace functional E2E; run alongside `automate`.
