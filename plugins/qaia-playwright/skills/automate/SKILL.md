---
name: automate
description: Generate native Playwright tests (Page Object Model as fixtures) from a QAIA Gherkin test book, preserving requirement traceability, plus a ready-to-run CI pipeline (GitHub Actions / GitLab CI / Jenkins) so the suite runs autonomously in the user's CI. E2E web and API. Web-first. Use when the user wants to automate an existing test book against a running app.
---

# automate — Gherkin test book → native Playwright (POM-as-fixtures)

Turns `.feature` scenarios into executable Playwright tests. Follows the reference proven in `examples/medibook/` (24 tests green). Decision D5 (native Playwright, no Cucumber layer) and D34 (POM as fixtures).

## Prerequisites

- A QAIA test book (`.feature` files with stable `@QAIA-<US-ID>-<NNN>` tags) — from `qaia-core:testbook-generate`.
- A running target app the user designates (URL). Automation needs a real environment; say so if none is provided.

## Rules (non negotiable — from the medibook reference)

- **POM as fixtures**: one page object per screen under `pages/`, selectors by role / `data-testid` only (T2), **no assertions inside page objects** — assertions live in tests. Page objects are exposed as Playwright fixtures so each test gets fresh instances.
- **Traceability**: every generated test title carries its source scenario ID and AC tag (`@QAIA-US-001-003 @AC5`) — the same IDs the test book uses. Requirement → scenario → automated test stays one continuous chain.
- **Atomic preconditions**: each test resets/seeds its own state declaratively (API seeding or fixtures), never a UI-chained setup — the automation counterpart of the atomic-scenario rule. Data seeding is this layer's job (T3/T4), not the Gherkin's.
- **Selectors**: `getByRole`/`getByTestId` first; positional XPath forbidden; document a retry + quarantine policy for flaky tests.
- **Secrets/environments**: never in the session or committed; `.env` + Playwright fixtures pattern (T3).
- **Shared mutable SUT** → serialize (`workers: 1`) or isolate per test (real lesson from the medibook flake hunt).

## Steps

1. **Map** each scenario to a test: parse its `Given/When/Then`, its tags, its `# condition` comment. One `When` = one action.
2. **Derive page objects** from the UI the scenarios touch (in Claude Code, use Playwright MCP to explore the running app and build reliable selectors — bounded per T5). API-only scenarios use Playwright's request context, no page object.
3. **Generate** `pages/*.js`, `fixtures.js`, `*.spec.js`, `playwright.config.js` — mirroring the proven `examples/medibook/tests/` structure (the canonical scaffold: POM-as-fixtures, projects split by type e2e-desktop / e2e-mobile emulation / api, `getByRole`/`getByTestId` selectors, `workers` set per the shared-SUT rule). One spec block per Gherkin scenario, its title carrying the scenario ID + AC tag.
4. **Emit the CI pipeline (T4 — autonomy outside the session).** Instantiate the pipeline for the user's CI from `templates/` (`github-actions.yml`, `gitlab-ci.yml`, or `Jenkinsfile`): it installs, runs the suite, and publishes JUnit + the HTML report + the run manifest. Secrets/URLs come from CI variables, never committed (T3). This is what makes the generated tests run in the user's CI with **zero dependency on QAIA or a Claude session**.
5. **Run** the suite against the app; report pass/fail per scenario ID. Do not claim green without a real run. A scenario that cannot execute against the app is reported **blocked**, never passed.
6. **Traceability report**: emit a table AC → scenario ID → test → result (see `examples/medibook/traceability.md`).
7. **Hand off to reporting.** Run `run-report` to merge the `execution` section into `.qaia/reports/<US-ID>/manifest.json` (the standardized output contract, D39) — pass/fail/blocked, `byType`, and `scenariosAutomated`/`scenariosTotal`. `qaia-score` then reads the same manifest to gate the run.

## Exit criterion (T17) — honest gate

M3's real exit criterion is **≥ 80 % of the P1 scenarios executable without manual rework, measured on a real pilot application** (T17) — the public demo app is only an intermediate development target. This skill **reports the ratio it actually achieved** (`P1 executable / P1 total`, from the run) and surfaces every blocked P1 with why; it never asserts T17 is met. Clearing T17 is a **pilot/human gate** (a running pilot app + a tester confirming the ratio), not something the skill can self-certify — consistent with the shared rule that a skill never self-validates.

## Guardrails

- **Web-first**: mobile = browser emulation (device descriptors). Native iOS/Android is out of scope (D50) — say so, don't fake it.
- Never invent a passing result; a test that can't run against the app is reported as blocked, not passed.
- Generated tests must be **autonomous outside the Claude session** (they run in the user's CI) — no dependency on QAIA at runtime.
