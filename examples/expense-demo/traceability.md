# Traceability — US-004 → scenarios → automated tests (ExpenseFlow)

Continuous chain: requirement (acceptance criterion) → QAIA Gherkin scenario (stable ID,
`.qaia/testbooks/US-004/*.feature`) → executable Playwright test. All tests run green against
the live SUT (40/40, re-run twice, deterministic).

| AC | Requirement | Scenario ID | Automated test | Type | Result |
|---|---|---|---|---|---|
| AC1,AC2,AC8 | End-to-end journey | @QAIA-US-004-001 | e2e smoke journey | E2E | PASS |
| AC1 | draft → submitted | @QAIA-US-004-002 | e2e complete draft submitted | E2E | PASS |
| AC1 | submitted → changes-requested → draft | @QAIA-US-004-003 | e2e changes-requested loop | E2E | PASS |
| AC1 | edit + re-submit after changes-requested | @QAIA-US-004-004 | e2e edit & re-submit | E2E | PASS |
| AC1 | submit a non-draft refused | @QAIA-US-004-005 | api double-submit → 409 | API | PASS |
| AC1 | edit a non-draft refused | @QAIA-US-004-006 | api edit-submitted → 409 | API | PASS |
| AC1,AC7 | reject direct from looped draft refused (Q3) | @QAIA-US-004-007 | api reject-from-draft → 409 | API | PASS |
| AC2 | just under €500 → manager only | @QAIA-US-004-008 | api boundary | API | PASS |
| AC2 | exactly €500.00 → manager+finance (Q1) | @QAIA-US-004-009 | api boundary | API | PASS |
| AC2 | exactly €5000.00 → manager+finance (Q1) | @QAIA-US-004-010 | api boundary | API | PASS |
| AC2 | just above €5000 → +director | @QAIA-US-004-011 | api boundary, full chain | API | PASS |
| AC2 | out-of-order approver refused | @QAIA-US-004-012 | api chain-order → 403 | API | PASS |
| AC3 | self-approval refused | @QAIA-US-004-013 | api self-approve → 403 | API | PASS |
| AC3 | manager's small report escalates (Q2) | @QAIA-US-004-014 | api escalation | API | PASS |
| AC3 | manager's large report drops manager step (Q2) | @QAIA-US-004-015 | api escalation | API | PASS |
| AC3 | finance's large report escalates to director (Q8) | @QAIA-US-004-016 | api escalation | API | PASS |
| AC4 | missing field refused | @QAIA-US-004-017 | api incomplete line → 422 | API | PASS |
| AC4 | exactly 90 days accepted (Q5) | @QAIA-US-004-018 | api boundary | API | PASS |
| AC4 | 91 days blocked with message | @QAIA-US-004-019 | api boundary → 422 | API | PASS |
| AC5 | just under €25 no receipt OK | @QAIA-US-004-020 | api boundary | API | PASS |
| AC5 | exactly €25 no receipt refused | @QAIA-US-004-021 | api boundary → 422 | API | PASS |
| AC5 | €25 with receipt OK | @QAIA-US-004-022 | api positive case | API | PASS |
| AC5,AC6 | non-EUR line crossing €25 EUR-equiv. refused (Q6) | @QAIA-US-004-023 | api boundary → 422 | API | PASS |
| AC6 | non-EUR total drives band | @QAIA-US-004-024 | api conversion | API | PASS |
| AC6 | unresolvable currency refused (Q4) | @QAIA-US-004-025 | api → 422 | API | PASS |
| AC6 | weekend rate gap → stale fallback (Q4) | @QAIA-US-004-026 | api stale flag | API | PASS |
| AC2,AC3,AC6 | stale total drives band + escalation (Q7) | @QAIA-US-004-027 | api triple intersection | API | PASS |
| AC7 | rejected cannot be edited | @QAIA-US-004-028 | api edit-rejected → 409 | API | PASS |
| AC7 | rejected cannot be re-submitted | @QAIA-US-004-029 | api submit-rejected → 409 | API | PASS |
| AC8 | reject without sufficient comment refused | @QAIA-US-004-030 | api → 422 | API | PASS |
| AC8 | changes-requested without sufficient comment refused | @QAIA-US-004-031 | api → 422 | API | PASS |
| AC8 | comment of exactly 10 chars accepted | @QAIA-US-004-032 | api boundary | API | PASS |
| AC8 | approve needs no comment | @QAIA-US-004-033 | api positive case | API | PASS |
| AC8 | audit trail records who/when | @QAIA-US-004-034 | api audit contains submit+approve | API | PASS |
| (auth) | unauthenticated create refused | @QAIA-US-004-035 | api → 401 | API | PASS |
| (auth) | unauthenticated decide refused | @QAIA-US-004-036 | api → 401 | API | PASS |
| (auth) | cross-tenant edit refused, no disclosure (IDOR) | @QAIA-US-004-037 | api → 404 | API | PASS |
| (list) | empty "My reports" state | @QAIA-US-004-038 | e2e empty list | E2E | PASS |
| (a11y) | no serious/critical WCAG 2 A/AA violations | @QAIA-A11Y-US004-001/002 | axe-core login + reports screen | A11y | PASS |

**Coverage**: all 8 AC have ≥ 2 automated tests; every `[req-neg]` condition from
`.qaia/testbooks/US-004/03-design.md` has a covering `@negative` test (17/17); every
`@low-confidence` scenario (9, one per open/assumption question Q1-Q9 except Q9 which needed
none) is traceable to its question ID inline in both the `.feature` files and the test titles
above. Requirement → scenario → test is navigable in both directions via the
`@QAIA-US-004-xxx` / `@ACn` tags, matching the convention established in
`examples/medibook/traceability.md`.

**Not covered by automation** (recorded honestly, not hidden): the three gaps flagged in
`.qaia/testbooks/US-004/coverage-matrix.md` (draft delete/discard, list sort/filter/pagination,
notifications) were never generated as scenarios in the first place (ceiling rule 3c — the
source doesn't name them), so there is nothing to automate for them either.
