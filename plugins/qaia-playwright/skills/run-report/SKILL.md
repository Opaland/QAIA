---
name: run-report
description: Produce an execution report from a Playwright run in the formats the QA profession consumes - JUnit XML, Cucumber JSON, and a self-contained HTML summary - with requirement traceability. Use after running an automated suite.
---

# run-report — execution reporting

The three reporting formats real QA toolchains actually ingest, plus requirement traceability.

## Outputs

- **JUnit XML** — for CI dashboards and most ALMs.
- **Cucumber JSON** — for import into Xray (git-master mode: the repo is the source of truth)
  and BDD reporters.
- **Self-contained HTML** — human-readable summary: pass/fail by scenario ID, per-type breakdown (e2e/api/a11y/perf/security), and the AC → scenario → test → result traceability table.
- **Standardized run manifest** — merge the results into `.qaia/reports/<US-ID>/manifest.json` per the shared output contract (`docs/OUTPUT-CONTRACT.md`), so scoring and dashboards read execution the same way they read the test book.

## Steps

1. Configure Playwright reporters (`junit`, `json`) in `playwright.config.js`; map test titles' `@QAIA-*` tags to requirement IDs.
2. After a run, transform results into the three outputs; never fabricate a result the run did not produce.
3. **Merge the `execution` section** into `.qaia/reports/<US-ID>/manifest.json` (contract 1.0): `total/passed/failed/blocked`, `byType`, and `traceability` (scenarios automated vs total). Load the existing manifest, replace **only** the `execution` section, append this skill to `producers[]`, add the JUnit/Cucumber/HTML files to `artifacts[]`, and leave `design`, `gate`, and a human-set `status` untouched (contract rule 2 — merge, never clobber). If no manifest exists yet, create one with just the shared header + `execution` and note that `qaia-core:report` will fill `design`.
4. If a publication target is configured (Xray), offer to publish — with the user's go, in git-master mode (the repo is the source of truth).

## Guardrails

- Distinguish clearly: generation report (coverage) ≠ execution report (this) ≠ requirement-coverage matrix.
- Blocked/skipped tests are reported as such, never as passed — in the HTML and in the manifest's `blocked` count alike.
- **Never write the `gate` block** — the manifest's verdict is owned by `qaia-score` (contract: no producer scores itself). The manifest carries counts and paths only: no secrets, no environment URLs, no PII.
