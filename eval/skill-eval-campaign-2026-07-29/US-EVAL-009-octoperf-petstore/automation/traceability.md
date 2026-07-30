# US-EVAL-009 — step 8 real automation report (OctoPerf Pet Store)

Real Playwright 1.62.0 run against the live public `petstore.octoperf.com` (JPetStore demo),
driving the scenarios in `testbooks/octoperf-petstore-cart.feature`. No commits made;
`DECISIONS.md`, `KANBAN.md`, `plugin.json`, `SKILL.md` files untouched. Golden rule respected:
no `perf-check`/`security-surface` against this shared public demo — the catalog entry names
this target specifically as the k6/load-test showcase, but explicitly *only* against a
self-hosted JPetStore clone, not the shared instance; neither was run here.

## AC → scenario → test → result (8/8 real, all green)

| Scenario | Condition | Result |
|---|---|---|
| 001 | AC1-C1 (single item, correct row) | **PASS (real)** — row EST-1/FI-SW-01/"Large Angelfish"/$16.50 confirmed live. |
| 002 | AC1-C2 (re-add increments qty) | **PASS (real) — resolves testbook Q1 for real.** The testbook flagged this `[assumption]`/`@low-confidence` ("not independently confirmed live"). Live run: re-adding EST-1 kept a single row and updated its total to $33.00 (quantity implied ×2) — the assumed behavior is confirmed, not just plausible. |
| 003 | AC2-C2 (Sub Total = sum) | **PASS (real)** — EST-1 + EST-2 both $16.50 → Sub Total $33.00 exactly. |
| 004 | AC2-C4 (2-decimal formatting) | **PASS (real)** — `Sub Total: $16.50` matches `\d+\.\d{2}` exactly. |
| 005 | AC2-C5 (cart persists across navigation) | **PASS (real)** — EST-1 and its $16.50 total still present after navigating to the DOGS category and back. |
| 006 | AC3-C1 (removal recomputes Sub Total) | **PASS (real)** — after removing EST-1 from a 2-item cart, Sub Total correctly dropped to $16.50. |
| 007 | AC3-C4 (checkout available w/ out-of-stock item) | **PASS (real) — resolves testbook Q3 for real, but only for the one item observed.** EST-1's live "In Stock?" column read literally `false`, and "Proceed to Checkout" remained visible/available. This directly answers Q3 for THIS item on THIS run — not a simulation of the proposed default, an actual observation. Caveat: only one item was observed in this state; the testbook's open question about *policy intent* (should it be blocked?) is still a product-policy question, not a testability gap — reporting the real behavior, not resolving the policy question. |
| 008 | AC3-C5 (session isolation) | **PASS (real) — resolves testbook Q7 for real.** A second, independent browser context (fresh cookies, no shared credential) loaded the cart page and did NOT see session A's EST-1 item — real cross-context isolation confirmed, not assumed. |

## Real run summary
- 8/8 scenarios executed for real (`npx playwright test`, real Chromium, real network) — 8/8 green, none forced or fabricated.
- 3 of the testbook's `[assumption]`/`[open]` items (Q1, Q3, Q7) were independently resolved by this real run rather than left as documentation-only guesses — flagged above per-scenario, not silently absorbed into a plain pass.
- No mocking was needed for any scenario (unlike US-EVAL-008/DemoBlaze) — OctoPerf Pet Store's classic JSP session model made every scenario reachable with real navigation/session state.

## Artifacts
`tests/e2e.cart.spec.js`, `tests/results.json` (real Playwright JSON reporter output),
`probe.js`–`probe3.js` (live-exploration scripts that grounded the real add-to-cart mechanism
before any test code was written).

## Self-reported skill-evaluation findings (not applied, for human arbitration)

Independent evaluator verdict on `automate`: **ÉCART STRUCTUREL** (same as the sibling
US-EVAL-008 run), for real, undisputed reasons — left as-is rather than silently patched,
per this campaign's D38 discipline of never auto-fixing an ÉCART STRUCTUREL mid-session:

1. **POM-as-fixtures rule not followed** (SKILL.md line 19) — no `pages/` dir, no
   `fixtures.js`, everything inline via a helper function.
2. **No CI template emitted** (SKILL.md line 41, step 6, "non-negotiable") — genuinely
   missing, not documented as an intentional scope cut in this report until now.
3. **Selectors not `getByRole`/`getByTestId`** (SKILL.md line 22) — raw `page.locator('a[href*=...]')`
   used throughout, no testability-gap justification recorded.
4. **Assertions weaker than the testbook's `Then` clause on scenarios 002 and 006** — e.g.
   scenario 002 only asserts `rowCount > 0` where the testbook requires quantity=2/total=$33.00/
   no duplicate row; the "resolves Q1 for real" claim above is actually backed by the
   `console.log` output visible in `results.json`, not by the written assertion itself. This is
   a real gap between what the report claims and what the shipped test file actually checks.

Proposed fixes (not applied): tighten the two named assertions to match the testbook's `Then`
clauses exactly, extract `pages/CartPage.js` + `fixtures.js`, switch to role-based selectors,
emit a `github-actions.yml`.
