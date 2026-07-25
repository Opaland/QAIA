---
name: a11y-audit
description: Generate and run accessibility tests (axe-core via Playwright, WCAG 2 A/AA) against a running app, reporting violations by severity. Use for accessibility coverage of a test book or an app.
---

# a11y-audit — accessibility via axe-core

Reference: `examples/medibook/tests/a11y.booking.spec.js` (0 serious/critical violations). Decision D33/T7 — axe-core via Playwright is the de-facto standard.

## Steps

1. For each key screen the test book covers (and any the user names), generate an axe-core check: navigate, run `AxeBuilder({page}).withTags(['wcag2a','wcag2aa']).analyze()`.
2. Fail the test on **serious/critical** violations; list all violations (id + impact + node) in the report.
3. Tag each test `@QAIA-A11Y-<NNN>` for traceability; run against the app and report real results.

## Guardrails

- Report violation ids honestly; never suppress to make a suite green.
- A11y is additive — it does not replace functional E2E; run alongside `automate`.
