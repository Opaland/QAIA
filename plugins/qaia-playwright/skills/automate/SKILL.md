---
name: automate
description: Generate native Playwright tests (Page Object Model as fixtures) from a QAIA Gherkin test book, preserving requirement traceability, plus a ready-to-run CI pipeline (GitHub Actions / GitLab CI / Jenkins) so the suite runs autonomously in the user's CI. E2E web and API. Web-first. Use when the user wants to automate an existing test book against a running app.
---

# automate — Gherkin test book → native Playwright (POM-as-fixtures)

Turns `.feature` scenarios into executable Playwright tests. Follows the reference proven in `examples/medibook/` (24 tests green). Decision D5 (native Playwright, no Cucumber layer) and D34 (POM as fixtures).

Step 5's self-review (trivial-assertion lint, issue #41) is validated against a purpose-built case in `fixture/` (`fixture/scenarios.feature`, `fixture/generated-before.spec.js` with three deliberately injected violations, `fixture/generated-after.spec.js` with the self-review applied) — see `fixture/VALIDATION.md` for the worked example and how each fix was mechanically checked.

## Prerequisites

- A QAIA test book (`.feature` files with stable `@QAIA-<US-ID>-<NNN>` tags) — from `qaia-core:testbook-generate`.
- A running target app the user designates (URL). Automation needs a real environment; say so if none is provided.

## Rules (non negotiable — from the medibook reference)

- **POM as fixtures**: one page object per screen under `pages/`, selectors by role / `data-testid` only (T2), **no assertions inside page objects** — assertions live in tests. Page objects are exposed as Playwright fixtures so each test gets fresh instances.
- **Traceability**: every generated test title carries its source scenario ID and AC tag (`@QAIA-US-001-003 @AC5`) — the same IDs the test book uses. Requirement → scenario → automated test stays one continuous chain.
- **Atomic preconditions**: each test resets/seeds its own state declaratively (API seeding or fixtures), never a UI-chained setup — the automation counterpart of the atomic-scenario rule. Data seeding is this layer's job (T3/T4), not the Gherkin's.
- **Selectors**: `getByRole`/`getByTestId` first; positional XPath forbidden.
- **Retry + quarantine policy (T2, made concrete — external audit finding, 2026-07-26: this used to say "document a policy" without ever stating one).** Generated `playwright.config.js` sets `retries: 0` explicitly, with a comment naming why: masking instability behind automatic retries hides exactly the signal `flaky-detect` (#34) exists to surface, so this project chooses to see failures rather than paper over them. **Quarantine** means tagging a scenario `@quarantine` once `flaky-detect` has flagged it with evidence — never silently, always a human decision recorded in the tag itself — and the CI templates exclude `@quarantine`-tagged tests from the blocking run (`--grep-invert "@quarantine"`) while still executing and reporting them in a separate non-blocking step, so a flagged-flaky test stays visible instead of disappearing from the suite.
- **Secrets/environments**: never in the session or committed; `.env` + Playwright fixtures pattern (T3).
- **Shared mutable SUT** → serialize (`workers: 1`) or isolate per test (real lesson from the medibook flake hunt).
- **No trivial assertions**: every `expect(...)` in a generated spec must check real SUT state (see step 5's self-review). A generated test never ships with a tautological, contentless, or self-comparing assertion — that is the same defect class `qaia-score` flags at the Gherkin level (`eval/tools/structural_score.py` C1/C2), one layer down in the generated code. This is a proofread of the generator's own output before it is written, not a score or a gate (rule 3, `plugins/qaia-core/skills/README.md`: no producer validates itself) — it never touches `.qaia/reports/**/manifest.json`'s `gate` field.

## Steps

1. **Map** each scenario to a test: parse its `Given/When/Then`, its tags, its `# condition` comment. One `When` = one action.
2. **Testability precheck (CTAL-TAE, D95) — before generating anything.** Assess the SUT's own testability rather than silently generating against whatever is there: **observability** (can the test read back enough state to assert on — API responses, visible DOM state, status/audit fields — or would an assertion have to guess?) and **controllability** (can the test set up its own preconditions declaratively — an API/seed mode, fixtures — or is the only path a multi-step UI chain, which the atomic-preconditions rule already forbids?). Concretely check: are `data-testid`/accessible-role attributes present on the interactive elements the scenarios touch, is there an API or seed endpoint for state setup, is there any way to observe an async operation's completion (a status field, a `role="status"` region) rather than guessing a wait. **On a gap**, do not silently fall back to a forbidden pattern (positional XPath, UI-chained setup) to route around it — report the specific testability gap against the specific scenario(s) it blocks, same honesty posture as a blocked-for-assertion scenario (step 5), and let the user decide (add a `data-testid`, expose a seed endpoint) rather than generating a fragile test that will flake later.
3. **Derive page objects** from the UI the scenarios touch (in Claude Code, use Playwright MCP to explore the running app and build reliable selectors — bounded per T5). API-only scenarios use Playwright's request context, no page object.
4. **Generate** `pages/*.js`, `fixtures.js`, `*.spec.js`, `playwright.config.js` — mirroring the proven `examples/medibook/tests/` structure (the canonical scaffold: POM-as-fixtures, projects split by type e2e-desktop / e2e-mobile emulation / api, `getByRole`/`getByTestId` selectors, `workers` set per the shared-SUT rule). One spec block per Gherkin scenario, its title carrying the scenario ID + AC tag.
5. **Self-review before writing (mechanical, anti-sycophancy lint on the generator's own output — issue #41).** Before each `*.spec.js` is written to disk, re-scan the assertions it is about to contain. This is a proofread pass inside generation, not a score or a separate gate — the same posture `qaia-score` uses at the Gherkin level (`eval/tools/structural_score.py`'s C1/C2 hollow/vague-assertion detectors), one layer down in the generated code, run by the producer on itself *before delivery*, never as a validation of already-delivered output (rule 3, `plugins/qaia-core/skills/README.md`: no producer scores itself as a gate). Flag any of:
   - **Tautological/reflexive comparisons**: `expect(true).toBe(true)`, `expect(1).toBe(1)`, `expect(x).toBe(x)`, or any `expect(<literal>)` compared to that same literal — a constant asserted against itself, no SUT state involved.
   - **Contentless `expect()` calls**: no argument, or an argument that is a hardcoded literal rather than something read from the page/response (`expect(true).toBeTruthy()`, `expect("ok").toBeTruthy()`) — nothing about the app is actually being checked.
   - **Weak-by-construction matchers**: `.toBeDefined()` / `.not.toBeNull()` on a Playwright locator handle, which is always a truthy object even when the element does not exist in the DOM (locators are lazy) — the real check is *state* (`toBeVisible`, `toHaveText`, `toHaveCount`, `toHaveURL`, response status/body), not the mere existence of the handle.
   - **Silent zero-assertion blocks**: a test mapped from a scenario with a `Then` in step 1 but zero `expect(...)` calls in the generated body — coverage promised by the scenario, dropped in code.

   On a hit, self-correct before writing: derive the real assertion from the scenario's `Then` text (the concrete value, status, or visible state it names) using the page object/response already in scope, and replace the trivial one. If the `Then` itself names no concrete, assertable value, do not fabricate a plausible-looking check to fill the gap — leave `// TODO(automate): "<Then text>" has no concrete assertable value — needs a human` in the file and list the scenario as blocked-for-assertion in the traceability report (step 8), the same honesty posture as an unrunnable scenario (Guardrails). Runs on every generated spec, silent when clean.
6. **Emit the CI pipeline (T4 — autonomy outside the session).** Instantiate the pipeline for the user's CI from `templates/` (`github-actions.yml`, `gitlab-ci.yml`, or `Jenkinsfile`): it installs, runs the suite, and publishes JUnit + the HTML report + the run manifest. Secrets/URLs come from CI variables, never committed (T3). This is what makes the generated tests run in the user's CI with **zero dependency on QAIA or a Claude session**.
7. **Run** the suite against the app; report pass/fail per scenario ID. Do not claim green without a real run. A scenario that cannot execute against the app is reported **blocked**, never passed.
8. **Traceability report**: emit a table AC → scenario ID → test → result (see `examples/medibook/traceability.md`); include any scenario left blocked-for-assertion by step 5, and any testability gap flagged by step 2.
9. **Hand off to reporting.** Run `run-report` to merge the `execution` section into `.qaia/reports/<US-ID>/manifest.json` (the standardized output contract, D39) — pass/fail/blocked, `byType`, and `scenariosAutomated`/`scenariosTotal`. `qaia-score` then reads the same manifest to gate the run.

## Exit criterion (T17) — honest gate

M3's real exit criterion is **≥ 80 % of the P1 scenarios executable without manual rework, measured on a real pilot application** (T17) — the public demo app is only an intermediate development target. This skill **reports the ratio it actually achieved** (`P1 executable / P1 total`, from the run) and surfaces every blocked P1 with why; it never asserts T17 is met. Clearing T17 is a **pilot/human gate** (a running pilot app + a tester confirming the ratio), not something the skill can self-certify — consistent with the shared rule that a skill never self-validates.

## Guardrails

- **Web-first**: mobile = browser emulation (device descriptors). Native iOS/Android is out of scope (D100) — say so, don't fake it.
- Never invent a passing result; a test that can't run against the app is reported as blocked, not passed.
- Generated tests must be **autonomous outside the Claude session** (they run in the user's CI) — no dependency on QAIA at runtime.
- **Never let a trivial assertion reach disk** (step 5): a spec file is not "done generating" until its `expect(...)` calls have been re-scanned for tautologies/contentless checks/weak-by-construction matchers and either fixed or explicitly marked blocked-for-assertion. This is the generator proofreading its own output before delivery — it stays inside `automate` and never becomes a second scoring pass; `qaia-score` still never reads generated `.spec.js` files (contract boundary unchanged).
- **Never route around a testability gap** (step 2): a missing `data-testid`/seed endpoint is reported, never silently patched over with a positional selector or a UI-chained setup that the rules above already forbid.
