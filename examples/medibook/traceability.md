# Traceability — US-001 → scenarios → automated tests (MediBook)

Continuous chain: requirement (acceptance criterion) → QAIA Gherkin scenario (stable ID) → executable Playwright test. All tests run green against the live SUT (24/24, deterministic).

| AC | Requirement | Scenario ID | Automated test | Type | Result |
|---|---|---|---|---|---|
| AC1 | Slots filtered by specialty | @QAIA-US-001-001 | e2e specialty filter | E2E (desktop+mobile) | ✅ |
| AC1 | Filter server-side | @QAIA-US-001-101 | api GET /slots?specialty | API | ✅ |
| AC1 | Empty specialty result | @QAIA-US-001-006 | e2e empty list | E2E | ✅ |
| AC2 | Slot <2h ahead not bookable | @QAIA-US-001-002 | e2e disabled book button | E2E | ✅ |
| AC2 | Book <2h → 422 | @QAIA-US-001-102 | api boundary | API | ✅ |
| AC3 | Max 3 upcoming appointments | @QAIA-US-001-104 | api 4th refused | API | ✅ |
| AC4 | Concurrent booking → only first wins | @QAIA-US-001-103 | api double-book → 409 | API | ✅ |
| AC5 | Confirmation with practitioner | @QAIA-US-001-003 | e2e confirmation | E2E | ✅ |
| AC6 | Cancel refused <4h before | @QAIA-US-001-004 | e2e cancel refused | E2E | ✅ |
| AC6 | Cancel allowed >4h before | @QAIA-US-001-005 | e2e cancel allowed | E2E | ✅ |
| AC7 | Minor needs authorized practitioner | @QAIA-US-001-106 | api unauthorized → 422 | API | ✅ |
| AC7 | Minor needs guardian contact | @QAIA-US-001-105 | api no-guardian → 422 | API | ✅ |
| AC8 | Booking recorded in audit trail | @QAIA-US-001-108 | api audit contains book | API | ✅ |
| (auth) | Unauthenticated booking → 401 | @QAIA-US-001-107 | api no-token → 401 | API | ✅ |
| (a11y) | No serious WCAG 2 A/AA violations | @QAIA-A11Y-001/002 | axe-core login + booking | A11y | ✅ |
| (visual) | UI matches baseline | @QAIA-VIS-001/002 | screenshot login + booking | Visual | ✅ |

**Coverage:** all 8 ACs have ≥ 1 automated test; boundaries (2h/4h/3-cap) tested at the API level; the decision-table AC (minor × authorization × guardian) split into two negative cases; cross-cutting auth, audit, accessibility and visual added. Requirement → test is navigable in both directions via the `@QAIA-US-001-xxx` / `@ACn` tags.
