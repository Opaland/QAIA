---
name: automate
description: Generate native Playwright tests (Page Object Model as fixtures) from a QAIA Gherkin test book, preserving requirement traceability, plus a ready-to-run CI pipeline (GitHub Actions / GitLab CI / Jenkins) so the suite runs autonomously in the user's CI. E2E web and API. Web-first. Use when the user wants to automate an existing test book against a running app.
---

# automate — Gherkin test book → native Playwright (POM-as-fixtures)

Turns `.feature` scenarios into executable Playwright tests, following the reference proven in
`examples/medibook/` (24 tests green).

Two architectural choices are fixed, not renegotiated per run:

- **Native Playwright, no Cucumber layer.** The test book stays Gherkin; each generated
  test carries its scenario's stable ID instead of re-parsing the `.feature` at runtime.
- **Page objects exposed as Playwright fixtures**, not a classic inheritance-based POM.

## Prerequisites

- A QAIA test book (`.feature` files with stable `@QAIA-<US-ID>-<NNN>` tags) — from `qaia-core:testbook-generate`.
- A running target app the user designates (URL). Automation needs a real environment; say so if none is provided.

## Rules (non negotiable — from the medibook reference)

- **POM as fixtures** — one page object per screen under `pages/`, selectors by role or
  `data-testid` only, **no assertions inside page objects**: assertions live in tests. Page
  objects are exposed as Playwright fixtures so each test gets fresh instances.
- **Traceability** — every generated test title carries its source scenario ID and AC tag
  (`@QAIA-US-001-003 @AC5`), the same IDs the test book uses. Requirement → scenario →
  automated test stays one continuous chain.
- **Atomic preconditions** — each test seeds its own state declaratively (API seeding or
  fixtures), never a UI-chained setup. This is the automation counterpart of the atomic-scenario
  rule; data seeding is this layer's job, not the Gherkin's.
- **Selectors** — `getByRole`/`getByTestId` first. Positional XPath forbidden.
- **Retry policy: `retries: 0`, stated here rather than deferred to a document.** A rule that
  only promises "a policy is documented somewhere" is not a policy and leaves each run to invent
  its own. Generated `playwright.config.js` sets it explicitly, with a comment naming why:
  masking instability behind automatic retries hides exactly the signal `flaky-detect` exists to
  surface. This project chooses to see failures rather than paper over them.
- **Quarantine** — tagging a scenario `@quarantine` once `flaky-detect` has flagged it *with
  evidence*. Never silent, always a human decision recorded in the tag itself. CI templates
  exclude `@quarantine` from the blocking run (`--grep-invert "@quarantine"`) while still
  executing and reporting it in a separate non-blocking step, so a flagged-flaky test stays
  visible instead of disappearing from the suite.
- **Secrets and environments** — never in the session, never committed. `.env` + Playwright
  fixtures pattern.
- **Shared mutable SUT** → serialize (`workers: 1`) or isolate per test — a real lesson from the
  medibook flake hunt.
- **No trivial assertions** — every `expect(...)` must check real SUT state. Full lint, its four
  defect classes and the contract boundary it must not cross: `references/self-review-lint.md`.

## Steps

1. **Map** each scenario to a test: parse its `Given/When/Then`, its tags, its `# condition` comment. One `When` = one action.
2. **Testability precheck (CTAL-TAE) — before generating anything.** Assess the SUT's own
   testability rather than silently generating against whatever is there:

   - **Observability** — can the test read back enough state to assert on (API responses,
     visible DOM state, status/audit fields), or would an assertion have to guess?
   - **Controllability** — can the test set up its own preconditions declaratively (an API or
     seed mode, fixtures), or is the only path a multi-step UI chain, which the
     atomic-preconditions rule already forbids?

   Concretely: are `data-testid` or accessible-role attributes present on the interactive
   elements the scenarios touch; is there an API or seed endpoint for state setup; is there any
   way to observe an async operation's completion (a status field, a `role="status"` region)
   rather than guessing a wait.

   **On a gap, do not route around it.** Falling back to a forbidden pattern — positional XPath,
   UI-chained setup — hides the gap and produces a test that will flake later. Report the
   specific gap against the specific scenarios it blocks, and let the user decide (add a
   `data-testid`, expose a seed endpoint). Same honesty posture as a blocked-for-assertion
   scenario.
3. **Derive page objects** from the UI the scenarios touch. In Claude Code, use Playwright MCP to
   explore the running app and build reliable selectors, within documented exploration limits
   (how many pages, how deep, how snapshots are filtered). API-only scenarios use Playwright's
   request context — no page object.
4. **Generate** `pages/*.js`, `fixtures.js`, `*.spec.js`, `playwright.config.js`, mirroring the
   proven `examples/medibook/tests/` structure: POM-as-fixtures, projects split by type
   (e2e-desktop / e2e-mobile emulation / api), `getByRole`/`getByTestId` selectors, `workers`
   set per the shared-SUT rule. One spec block per Gherkin scenario, its title carrying the
   scenario ID + AC tag.
5. **Self-review before writing** — a mechanical anti-sycophancy lint on the generator's own
   output, run before each spec reaches disk. It catches tautological comparisons, contentless
   `expect()` calls, weak-by-construction matchers on lazy locators, and scenarios whose `Then`
   produced zero assertions. Full protocol, and the contract boundary it must not cross:
   `references/self-review-lint.md`. Silent when clean.
6. **Emit the CI pipeline** — this is what makes the generated suite autonomous outside the
   session. Instantiate it from `templates/` (`github-actions.yml`, `gitlab-ci.yml` or
   `Jenkinsfile`): it installs, runs the suite, and publishes JUnit + the HTML report + the run
   manifest. Secrets and URLs come from CI variables, never committed. The result runs in the
   user's CI with **zero dependency on QAIA or a Claude session**.

   The GitHub Actions template is proven by execution — a generated suite runs green on a real
   runner (`eval/ci-proof-2026-08-01/`). The GitLab and Jenkins templates are **not** yet proven
   by a run; their Docker image tag must match the `@playwright/test` version in `package.json`
   or every test fails at launch.
7. **Run** the suite against the app; report pass/fail per scenario ID. Do not claim green without a real run. A scenario that cannot execute against the app is reported **blocked**, never passed.
8. **Traceability report**: emit a table AC → scenario ID → test → result (see `examples/medibook/traceability.md`); include any scenario left blocked-for-assertion by step 5, and any testability gap flagged by step 2.
9. **Hand off to reporting.** Run `run-report` to merge the `execution` section into `.qaia/reports/<US-ID>/manifest.json` (the standardized output contract every QAIA plugin writes to, `docs/OUTPUT-CONTRACT.md`) — pass/fail/blocked, `byType`, and `scenariosAutomated`/`scenariosTotal`. `qaia-score` then reads the same manifest to gate the run.

## Exit criterion — honest gate

The automation milestone's real exit criterion is **≥ 80 % of the P1 scenarios executable without
manual rework, measured on a real pilot application**. A public demo app is only an intermediate
development target and is never evidence for it.

This skill **reports the ratio it actually achieved** (`P1 executable / P1 total`, from the run)
and surfaces every blocked P1 with its reason. It never asserts the criterion is met: clearing it
is a pilot/human gate — a running pilot app plus a tester confirming the ratio — not something
the skill can self-certify, consistent with the shared rule that a skill never self-validates.

## Guardrails

- **Web-first.** Mobile means browser emulation (device descriptors). Native iOS/Android is out
  of scope — reaching it would mean a different driver stack (Appium), an architecture change
  rather than an addition. Say so, don't fake it.
- **Never invent a passing result.** A test that cannot run against the app is reported as
  blocked, not passed.
- **Generated tests must be autonomous outside the Claude session** — they run in the user's CI,
  with no dependency on QAIA at runtime.
- **Never let a trivial assertion reach disk** (step 5). A spec file is not "done generating"
  until its assertions have been re-scanned and each one either fixed or explicitly marked
  blocked-for-assertion.
- **Never route around a testability gap** (step 2). A missing `data-testid` or seed endpoint is
  reported, never silently patched over with a positional selector or a UI-chained setup that
  the rules above already forbid.
