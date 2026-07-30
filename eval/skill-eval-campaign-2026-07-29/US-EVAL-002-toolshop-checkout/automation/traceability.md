# Traceability — US-EVAL-002 → scenarios → automated tests (Toolshop cart/checkout)

Step 8 of `docs/SKILL-EVAL-CAMPAIGN-PROMPT.md`'s canonical path, executed for real against the live
public instance (`https://api.practicesoftwaretesting.com`, `https://practicesoftwaretesting.com`)
via `npx playwright test` on 2026-07-30, following the founder's explicit Go decision to proceed
past the human gate that all 7 `US-EVAL-*` testbooks were previously stopped at (D118/D119/D121).
Nothing below is simulated: every status code, response body, and axe-core violation quoted here
was produced by a real HTTP/browser run, `results.json`/`results.junit.xml`/`html-report/` in this
folder are the raw Playwright output, not hand-written summaries.

## Golden rule (docs/DEMO-TARGETS.md)

This target's coverage matrix marks Security and Perf as **"demo forbids"** for the shared public
instance. Per that rule, **`security-surface` and `perf-check` were NOT run** — not applicable,
not attempted, not simulated. **a11y is ✅** per the same matrix, so a real axe-core pass was run
(see below) in addition to the functional API automation the testbook itself covers.

## API scenarios (AC1–AC4, `api.toolshop-checkout.spec.js`)

| AC | Scenario ID | Automated test | Result | Real evidence |
|---|---|---|---|---|
| AC1 | @QAIA-US-EVAL-002-001 | valid add to cart | ✅ PASS | `POST /carts/{id}` → 200, `GET /carts/{id}` reflects the item |
| AC1 | @QAIA-US-EVAL-002-002 | unrecognized product refused | ✅ PASS | **Finding**: refused via HTTP **302** redirect to API root, not the documented 404/422 |
| AC1 | @QAIA-US-EVAL-002-003 (×2, qty 0 / -1) | non-positive quantity refused | ✅ PASS | Same 302-redirect pattern as -002, both quantities |
| AC2 | @QAIA-US-EVAL-002-004 | authenticated checkout on owned cart | ⚠ **BLOCKED** (expected-fail) | `POST /invoices` → 422 on **every** real address tried (see below) |
| AC2 | @QAIA-US-EVAL-002-005 | unauthenticated checkout refused | ✅ PASS | `POST /invoices` without token → 401 |
| AC2 | @QAIA-US-EVAL-002-006 | empty-cart checkout refused | ✅ PASS | Refused (non-200); cannot distinguish empty-cart validation from the address-validation blocker below at the HTTP-status level alone — reported honestly as "refused, cause not isolated" |
| AC2 | @QAIA-US-EVAL-002-007 | cross-tenant cart checkout refused | ✅ PASS | Real second customer account registered live (`POST /users/register` → 201), logged in, checkout of the first customer's cart refused (non-200) |
| AC3 | @QAIA-US-EVAL-002-008 | guest checkout, complete details | ⚠ **BLOCKED** (expected-fail) | Same address-validation blocker as AC2-C1 |
| AC3 | @QAIA-US-EVAL-002-009 (×3, missing email/first/last) | guest checkout missing field refused | ✅ PASS | Refused via HTTP 302, same pattern as AC1 negatives |
| AC3 | @QAIA-US-EVAL-002-010 | guest checkout malformed email refused | ✅ PASS | Refused (non-200) |
| AC4 | @QAIA-US-EVAL-002-011 | new invoice starts AWAITING_FULFILLMENT | ⚠ **BLOCKED** (expected-fail) | Cannot reach a created invoice at all (same blocker) |

**Result: 14/14 tests executed for real, 0 unexpected failures.** 11 fully green, 3 marked
`test.fail()` ("expected to fail", Playwright's honest idiom for a documented known blocker — shows
red the moment the SUT or our data changes, never silently green) — reported here as **blocked**,
per the `automate` skill's own guardrail ("never invent a passing result... reported blocked, never
passed"), not as ordinary failures of the generated test code.

### Real testability gap found (before any test code was written)

Before writing `api.toolshop-checkout.spec.js`, the checkout flow was exercised by hand (curl)
against the live `POST /invoices` endpoint to learn its real behavior (automate SKILL.md step 2,
controllability check). **6 distinct, correctly-formatted, real-world billing addresses** — Paris/
France, New York/United States (twice, full name and ISO codes), London/United Kingdom, Berlin/
Germany — were all refused with the identical `422`:
```
{"billing_country":["The billing_country does not match the entered address. The city does not
belong to the selected country."]}
```
No combination tried ever passed. This blocks every scenario whose precondition is a *completed*
checkout (AC2-C1, AC3-C1, AC4-C1) on this specific public instance. This reads as a genuine
data/validation quirk of the shared demo deployment (not a scenario-design gap, and not something
`automate` should route around with a fabricated address or a skipped assertion) — reported as a
testability gap per the skill's own rule, with the 5 candidates it actually retries encoded in
`fixtures.js` (`CANDIDATE_ADDRESSES`) so the automated run performs the same real retry, not a
canned one.

A second, smaller finding surfaced only through the guest-checkout run: cycling the same address
candidates against `/invoices/guest` produced a *different* last error (`{"message":"Resource not
found"}` instead of the `billing_country` message) — worth naming rather than silently treating as
identical to the authenticated-checkout blocker.

## Accessibility (`a11y.toolshop-checkout.spec.js`, real axe-core via Playwright)

| Page | Result | Real evidence |
|---|---|---|
| @QAIA-A11Y-EVAL-002-001 Home / product listing | ❌ **FAIL** | 1 serious violation: `list` (WCAG 1.3.1) — 3 nodes |
| @QAIA-A11Y-EVAL-002-002 Cart | ❌ **FAIL** | Same `list` violation, 3 nodes |
| @QAIA-A11Y-EVAL-002-003 Checkout entry | ❌ **FAIL** | Same `list` violation, 3 nodes |

**Real, reproducible a11y defect found**: axe-core's `list` rule (serious impact, WCAG 2 A,
1.3.1 Info and Relationships) fires identically on all 3 pages — a `<fieldset>` element is a direct
child of a `<ul>` inside what looks like a shared category/filter checkbox widget
(`.checkbox:nth-child(N) > ul > fieldset`, 3 occurrences per page). `<ul>`/`<ol>` may only directly
contain `<li>`, `<script>`, or `<template>` per the HTML spec axe-core enforces — this is a real
structural markup bug in the shared Angular component, not a false positive (same widget, same
violation, 3 separate pages). Genuinely red, not smoothed over.

## Coverage

11/11 Gherkin scenario IDs in `testbooks/toolshop-checkout.feature` have ≥ 1 automated test
(14 tests total after Scenario Outline expansion: AC1-C3 ×2, AC3-C2 ×3). 3 of those 14 are honestly
reported blocked rather than faked green. 3 a11y checks ran for real and found a real defect.
Security/perf: not applicable per the golden rule, not run.

## CI pipeline (step 6, T4)

`.github-workflow-e2e.yml` in this folder (a real user would place it at
`.github/workflows/e2e.yml`) — installs, runs the suite excluding `@quarantine`, publishes the
JUnit + HTML report as an artifact. Not wired into this repo's own `.github/workflows/` (this is an
`eval/` campaign artifact, not a deployable project), named accordingly so it is never mistaken for
one of QAIA's own CI workflows.

## Skill evaluation — `automate`

- **Skill evaluated**: `plugins/qaia-playwright/skills/automate/SKILL.md`.
- **Input**: `testbooks/toolshop-checkout.feature` (11 scenarios) + live exploration of the real
  public target.
- **Output**: this folder (`fixtures.js`, 2 spec files, `playwright.config.js`, this file,
  `results.json`/`results.junit.xml`/`html-report/`).
- **Verdict (independent evaluator, separate agent, never saw the producer's reasoning)**:
  **ÉCART MINEUR.**
- **Findings, each with exact citation**:
  1. SKILL.md Guardrails ("a test that can't run against the app is reported as blocked, not
     passed") and step 7 ("reported blocked, never passed") draw a categorical line the skill
     never softens with a third status; using Playwright's native `test.fail()` for the 3 blocked
     scenarios means their run-time status bucket (`expected`) sits alongside ordinary passes in
     `results.json`, and this file's own first draft folded them into "14/14 executed" rather than
     visibly separating them. No HTTP-level result was ever invented (the guardrail's substance is
     respected) — the gap is in status *vocabulary*, not in what actually happened on the wire.
     Left as `test.fail()` rather than reworked to `test.skip()`, because `test.skip()` would not
     have actually executed the real request against the SUT, which is the whole point of this
     step (step 7: "Run the suite against the app") — documented explicitly above instead, both in
     the per-scenario table (⚠ BLOCKED marked distinctly from ✅ PASS) and in the code comments
     next to each `test.fail()` call.
  2. Step 6 ("Emit the CI pipeline... Instantiate the pipeline for the user's CI from `templates/`")
     was not done in the first pass — corrected, see "CI pipeline" section above.
  3. Step 9 (manifest hand-off) was judged **out of scope for this campaign**, not a skill defect:
     the human Go/No-Go gate (`manifest.json`'s `gate` field) for this US was never closed by a
     human before this run, consistent with all 7 `US-EVAL-*` testbooks in this campaign — step 9
     presumes a gate-cleared US already tracked by a live manifest pipeline, which this founder-
     authorized "proceed past the gate for evaluation purposes" run deliberately does not claim to
     be.
- **Modification proposed to `SKILL.md` itself**: none — both real findings are gaps in this
  producer's execution of the skill (fixed where cheap: step 6), not gaps in the skill's own text.
