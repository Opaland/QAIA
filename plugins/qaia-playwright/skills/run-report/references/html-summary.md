# The self-contained HTML summary

## Why this exists next to Playwright's own HTML report

Playwright's built-in report is a debugging tool for whoever wrote the tests: it is organised by
spec file, it needs a web server (`npx playwright show-report`), and it knows nothing about
acceptance criteria. This one is organised by **requirement**, opens by double-click, and answers
the question a product owner or an auditor actually asks: *which acceptance criteria are covered,
and what did they do on the last run?*

Both should ship. This one does not replace the Playwright report; it links to it.

## Self-contained means self-contained

One `.html` file. No CDN script, no external stylesheet, no remote font, no network fetch. Inline
the CSS and any JS; embed screenshots as `data:` URIs or link them relatively.

The reason is not aesthetic: this file gets emailed, attached to a compliance record, and opened
years later from an archive. A report whose layout depends on a CDN is a report that renders as
unstyled text exactly when someone needs it as evidence.

Keep it under a few hundred KB — embed failure screenshots only, not every trace.

## Required sections, in order

1. **Header** — US id and title, run date (ISO 8601, with timezone), commit SHA, environment
   name, Playwright version, and the retry setting used. A result without the commit it ran
   against cannot be reproduced.
2. **Totals** — `total / passed / failed / blocked`, plus flake count. Same numbers as the
   manifest's `execution` block; if they differ, one of the two is wrong and neither ships.
3. **Per-type breakdown** — e2e-desktop / e2e-mobile / api / a11y / perf / security, from the
   Playwright project names.
4. **Traceability table** — the section that justifies the file:

   | AC | Scenario ID | Test | Result | Evidence |
   |---|---|---|---|---|
   | AC1 | QAIA-US-001-001 | `e2e.login.spec.js` "…" | PASS | — |
   | AC2 | QAIA-US-001-002 | `e2e.login.spec.js` "…" | **FAIL** | screenshot, trace |
   | AC3 | QAIA-US-001-007 | — | **NOT AUTOMATED** | — |

   **Rows with no test are the point of the table.** A scenario in the test book with no
   corresponding test appears as `NOT AUTOMATED`, not omitted — a traceability table that only
   lists what exists shows 100 % coverage of itself and hides the gap it was built to expose.
5. **Failures** — one block per failure: scenario id, expected vs actual, error message, links to
   screenshot and trace. Verbatim, never summarised into "assertion error".
6. **Blocked / skipped** — with the reason for each. "Skipped" with no reason is a hole.
7. **Open arbitrations** — carried over from the manifest's `openArbitrations`, so a reader sees
   which results rest on an unconfirmed assumption. A green run on a scenario whose expected
   value was a guess is not the same evidence as a green run on a confirmed one, and the reader
   cannot know that unless the report says it.

## Colour is a second channel, never the only one

Pass/fail must be readable without colour perception: use a text label (`PASS` / `FAIL`) or a
shape, with colour reinforcing it. A report about quality that a colour-blind reader cannot
parse is an odd artifact to ship, and this one is often read by the same people who commissioned
the a11y audit.

## What it must not contain

- No secrets, no tokens, no full environment URLs with credentials embedded.
- No PII from test data — including in embedded screenshots. A screenshot of a form filled with
  production-shaped personal data is a data leak with a long shelf life.
- No verdict. The HTML reports execution; the PASS/CONCERNS/FAIL gate belongs to `qaia-score`
  and appears here only as a reference if it already exists.
