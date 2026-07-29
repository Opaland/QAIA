---
stepsCompleted: [00-ingest, 01-review, 02-understanding, rag-build, 03-design]
lastStep: 03-design
lastSaved: 2026-07-29
---

# 03-design — US-007 (ISTQB technique selection + conditions)

Prerequisite `02-understanding.md` present. Knowledge base now seeded (`knowledge/business-rules.md`, `BR-KB-001..003`) — routed through `knowledge/index.md`, matched on tags `payment, fee, enrolment, naming, money-mechanical`. Black-box only (D110) — no implementation was read.

## AC → technique map

- **AC1** (configuration: account, fee, currency): Equivalence Partitioning + Boundary Value Analysis (fee amount, currency) + Decision Table (role axis: manager vs non-manager) + CRUD Testing (full method lifecycle, not just create) — justification: a config form with numeric/currency boundaries and a role-gated create action is exactly BVA+decision-table+CRUD territory.
- **AC2** (fee prompt gates content): Equivalence Partitioning + State Transition Testing (not-enrolled vs enrolled visibility) — justification: content visibility is a function of enrolment state, a two-state gate.
- **AC3** (method selection, cancel/fail): State Transition Testing (pending-payment lifecycle, re-entrance) + Equivalence Partitioning (method list) + Error Guessing (empty-methods misconfiguration) — justification: this AC is fundamentally a lifecycle (not-enrolled → pending → enrolled/cancelled) with a reflex-derived degenerate case.
- **AC4** (guest messaging + forced login): Decision Table (role axis: guest vs logged-in student) + Error Guessing (server-side UI-bypass reflex) — justification: the AC is exactly a role × behavior cell change (CTAL-TA §3.3.1 fits a two-role decision table better than plain EP alone).
- **AC5** (custom naming, scoped visibility): Decision Table (role axis: manager vs student vs guest, ×2 states default/customized) + Equivalence Partitioning — justification: "who sees which name" is a role × configuration-state matrix, the textbook decision-table shape.

## Derived test conditions

Legend: `[req-neg]` = required-negative (ADR 0001 gate). `# rule:` = knowledge-base citation. `@oracle:` = standards oracle (`oracle-generate`).

### AC1 — configure the payment-required method

- **AC1-C1** valid account + positive fee + valid currency (e.g. EUR) → method created. `[ep]`
- **AC1-C2** fee amount = 0 → rejected. `[req-neg]` `[boundary]` `# rule: BR-KB-002`
- **AC1-C3** fee amount negative (e.g. -1) → rejected. `[req-neg]` `[boundary]` `# rule: BR-KB-002`
- **AC1-C4** currency code not a valid ISO 4217 code (e.g. `XXX`) → rejected. `[req-neg]` `@oracle:iso4217`
- **AC1-C5** currency with 0 minor units (`JPY`) accepts only whole-unit fee amounts; currency with 2 minor units (`EUR`) accepts cent precision — boundary rounding per currency. `[boundary]` `@oracle:iso4217`
- **AC1-C6** no payment account selected → rejected (required field). `[req-neg]` `[ep]`
- **AC1-C7** a second, independent "payment required" method can be added to the same course with its own fee/currency. `[assumption: Q4]` `@low-confidence` `[crud]`
- **AC1-C8** a non-manager role attempting to configure the method is denied. `[req-neg]` `[decision-table]`
- **AC1-C9** manager edits the fee amount of an existing method (update). `[assumption]` `@low-confidence` `[crud]` (exact edit mechanism unspecified by source)
- **AC1-C10** manager removes/disables the payment-required method; course reverts to its other enrolment method(s). `[assumption]` `@low-confidence` `[crud]` (exact removal mechanism unspecified)

### AC2 — fee prompt gates content for the logged-in student

- **AC2-C1** logged-in, not-yet-enrolled student visits the course → sees the fee prompt with the exact configured amount; no course content is rendered. `[ep]`
- **AC2-C2** the displayed amount equals the configured amount exactly (no rounding/approximation). `[ep]`
- **AC2-C3** an already-enrolled student (enrolled via another route) visiting the course sees content directly, no fee prompt. `[answered: Q5]` `[state-transition]`
- **AC2-C4** a not-yet-enrolled student attempting to reach course content directly (bypassing the prompt, e.g. a direct content URL) is still blocked server-side. `[req-neg]` `[error-guessing]`

### AC3 — method selection and cancel/fail

- **AC3-C1** student selects an enabled payment method from the account's list → proceeds to that method. `[ep]`
- **AC3-C2** only methods enabled on the configured account are offered (not other gateways the account doesn't enable). `[ep]`
- **AC3-C3** student cancels the payment flow → not enrolled, not charged. `[req-neg]` (explicit AC) `[state-transition]`
- **AC3-C4** payment attempt fails/is declined → not enrolled, not charged, error shown, retry available. `[req-neg]` `[assumption: Q2]` `# rule: BR-KB-001` `[state-transition]`
- **AC3-C5** student cancels/fails and retries the prompt more than once (pending state re-entered) without restriction. `[assumption: Q2 cross-ref]` `[state-transition]`
- **AC3-C6** the configured account has zero enabled payment methods → student sees a fail-closed "no payment option available" state, no content, no charge. `[req-neg]` `[assumption: Q9]` `@low-confidence` `[error-guessing]`
- **AC3-C7** payment succeeds → student becomes enrolled and is charged exactly the configured fee. `[ep]`

### AC4 — guest (anonymous) visitor

- **AC4-C1** anonymous guest reaches the paid course → sees the same fee-required messaging (exact amount) as a logged-in student. `[ep]`
- **AC4-C2** the guest is prompted to log in and is never shown the payment-method selection directly. `[req-neg]` (explicit AC) `[decision-table]`
- **AC4-C3** an unauthenticated direct request to the payment/enrolment action (bypassing the UI) is rejected/redirected to authentication server-side. `[req-neg]` `[error-guessing]`
- **AC4-C4** after the guest logs in, they resume the fee/payment prompt for the same course (continuity into AC2/AC3). `[assumption: Q6]` `@low-confidence`

### AC5 — custom display name and description

- **AC5-C1** manager sets a custom display name + description distinct from the default → configuration accepted. `[ep]`
- **AC5-C2** after customization, a logged-in student (AC2/AC3 views) sees only the custom name, never the default. `[decision-table]`
- **AC5-C3** after customization, the guest-facing prompt (AC4) also shows only the custom name, never the default — the triple-AC resolution of Q8 (AC4 × AC5, both read together). `[answered: Q8]` `[decision-table]`
- **AC5-C4** the manager's management view still shows that the method was built from the default method, distinct from what students/guests see. `[decision-table]`
- **AC5-C5** a rename is applied and immediately reflected in all subsequent student/guest views (live property, not a snapshot). `[assumption: Q7]` `# rule: BR-KB-003` `[state-transition]`

## Oracle applied

`oracle-generate` invoked for the **ISO 4217** currency domain (AC1-C4, AC1-C5): valid codes `EUR`, `USD`, `JPY` (0 minor units), invalid `XXX`/`EU`, minor-unit-driven rounding boundary. ⚠ VALIDATION (non-interactive): `simulated: accepted-as-is` — oracle-derived cases accepted into the design conditions above.

⚠ VALIDATION (non-interactive run): `simulated: accepted-as-is` — AC → technique map and full condition list approved as proposed.

## Knowledge applied

`BR-KB-001`, `BR-KB-002`, `BR-KB-003` (all three, seeded this run by `rag-build` from this same US's `need-understanding` pass — cited here for traceability into `report`'s `design.knowledgeApplied`).
