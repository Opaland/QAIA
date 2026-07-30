# 03-design — US-EVAL-006

## AC → technique map

- **AC1/AC4** (initial DOM state per example) → **Equivalence partitioning** (one representative
  of the "idle" state per example — the two examples are two distinct partitions, not one).
- **AC2/AC5** (click → immediate loading state) → **State Transition Testing** — the
  `idle → loading` edge of the state × event table below.
- **AC3/AC6** (timer-elapse → revealed state) → **State Transition Testing** (the `loading →
  revealed` edge) + **Boundary Value Analysis** on the 5000ms threshold (Q2: lower-bound
  semantics, not an exact instant).
- **AC7** (cross-example consistency of the delay value and final text) → **Metamorphic Testing**
  — the exact literal values are already known (5000ms, "Hello World!"), so this is not a
  "can't state the expected output directly" case in the classic sense, but the *relation itself*
  ("both examples converge on the identical observable outcome despite different DOM-mutation
  mechanisms") is the property under test, which is exactly what Metamorphic Testing checks: a
  known relation between two related executions, not a value fabricated from nothing.

## State × event table (CT-MBT discipline, built before deriving conditions)

Both examples share the same 3-state machine; they differ only in **when** `#finish` is created.

| State \ Event | `click` (on `#start button`) | `timer-elapse` (5000ms after click) |
|---|---|---|
| **S0 idle** (`#start` visible, no `#loading`) | → **S1 loading** (valid, AC2/AC5) | not applicable — no timer is pending in S0 |
| **S1 loading** (`#start` hidden, `#loading` visible) | **forbidden through the real UI** (button unreachable — `#start` hidden); **undefined if forced programmatically** (Q1, `[assumption]`, out of scope) | → **S2 revealed** (valid, AC3/AC6) |
| **S2 revealed** (`#loading` hidden, `#finish` visible) | **forbidden through the real UI** (same reason); **undefined if forced** (Q1) | not applicable — no timer is pending in S2 |

Only the two **valid** transitions (`S0→S1`, `S1→S2`) are covered by scenarios below, per real
pointer-reachable paths. The two **forbidden/undefined** cells (Q1) are not asserted with a
specific outcome — see the negative-pressure section below for why no scenario is generated for
them.

## Test conditions

### AC1 — Example 1 initial state
- **AC1-C1** `[ep]` — page load, before any click: `#start` visible with a "Start" button,
  `#finish` present in the DOM with `display:none` (not visible, but present).

### AC2 — Example 1, click → loading (S0→S1)
- **AC2-C1** `[state-transition]` — clicking "Start": `#start` becomes not visible; a "Loading..."
  indicator (with spinner image) becomes visible in its place, with no delay.

### AC3 — Example 1, timer-elapse → revealed (S1→S2)
- **AC3-C1** `[state-transition]` `[bva]` (Q2) — before 5000ms have elapsed since the click:
  "Hello World!" (`#finish`) is still not visible (loading indicator still visible).
- **AC3-C2** `[state-transition]` `[bva]` (Q2) — after waiting past 5000ms: the loading indicator
  is no longer visible, and `#finish` ("Hello World!") is now visible.

### AC4 — Example 2 initial state
- **AC4-C1** `[ep]` — page load, before any click: `#start` visible with a "Start" button, **no
  `#finish` element anywhere in the DOM** (stricter than AC1-C1's "present but hidden").

### AC5 — Example 2, click → loading (S0→S1)
- **AC5-C1** `[state-transition]` — clicking "Start": `#start` becomes not visible; the same
  "Loading..." indicator becomes visible, with no delay (mirrors AC2-C1, distinct example — kept
  as its own condition per AC, not merged, since the two examples are the deliberate axis of this
  feature per `01-extraction.md`'s business rule).

### AC6 — Example 2, timer-elapse → revealed (S1→S2)
- **AC6-C1** `[state-transition]` `[bva]` (Q2) — before 5000ms have elapsed: **no `#finish`
  element exists in the DOM at all** (not merely "not visible" — this is the condition that
  actually distinguishes this example from AC3-C1, and the one a presence-only wait strategy gets
  wrong).
- **AC6-C2** `[state-transition]` `[bva]` (Q2) — after waiting past 5000ms: the loading indicator
  is no longer visible, a **new** `#finish` element now exists in the DOM, and it is visible,
  displaying "Hello World!".

### AC7 — cross-example consistency
- **AC7-C1** `[metamorphic]` — the delay measured from click to reveal and the final revealed text
  are identical between Example 1 and Example 2, despite the two examples using different
  DOM-mutation mechanisms (toggle-visibility vs create-then-show) to get there — the relation
  "same observable outcome, different internal path" holds.

## Negative pressure (ADR 0001) — honest zero

No rule in this AC set refuses, errors, or denies anything — this is a pure timing/DOM-mutation
demo page with no validation, no auth, no business rule that can reject an input. **Zero `[req-neg]`
conditions apply.** `AC3-C1` and `AC6-C1` are shaped like negative assertions (they assert an
*absence* — not-yet-visible, not-yet-present) but they are not a refusal/error/deny path in ADR
0001's sense (there is no request being rejected); they are recorded as `@negative`-taggable at
`testbook-generate` time on their own separate merits (asserting a negative/absence outcome), not
because this step's gate requires it. This honestly-zero finding is flagged here rather than
inventing a refusal path to satisfy the gate — `istqb-design`'s own guardrail line 102 makes an
unjustified technique a rubric defect, and a fabricated `[req-neg]` here would be exactly that
kind of unjustified addition. **Downstream effect flagged for `prioritize`/`testbook-generate`**:
the 40% negative-ratio target may be hard to reach without treating `AC3-C1`/`AC6-C1` as
`@negative`; this must not be padded with invented refusal scenarios if the ratio falls short (per
`testbook-generate`'s own guardrail, "never pad the negative ratio with invented cases").

## 3b — Standardized domains → oracle (`oracle-generate`)

**Not applicable.** No AC in this slice touches a standardized domain (no email, date/ISO 8601,
currency, HTTP status, card/Luhn, IBAN) — the entire feature is DOM-visibility/timing state, which
has no matching entry in the oracle library. Not forced into an oracle it doesn't have.

## 3c — Systematic coverage expansion (each pattern's outcome stated, none silently absent)

- **List/collection view**: not applicable — no set of items, no sort/filter/pagination surface.
- **Full CRUD lifecycle**: not applicable — no persisted entity with create/read/update/delete;
  the "Hello World!" node's creation (Example 2) is a one-shot DOM mutation, not an entity
  lifecycle.
- **Conditional behavior (decision table over variation axes)**: **applied, via the state × event
  table above** rather than a classic decision table — the two real axes here (which example;
  before/after the timer) are already fully crossed there, and a separate decision table would
  duplicate it without adding a distinct axis (no config/role/visibility dimension exists on this
  page).
- **Authorization & server-side enforcement**: not applicable — no auth, no ownership model, no
  server-side rule at all (client-only JS timer); this entire pattern's trigger (an action gated
  by identity/permission) does not match a page with no login.
- **Enumerate every list/aggregation view**: not applicable, same reason as "list/collection view."
- **Sibling collections of a named entity**: not applicable — no entity described as "a collection
  of X" on this page.
- **Account & auth recovery path**: not applicable — not an authentication/account feature; no
  login, password, or recovery concept exists here.

## 3d — Knowledge-driven conditions

`.qaia/knowledge/` does not exist for this campaign directory — recorded per shared-contract rule
8, proceeding on the source alone (no `BR-KB-nnn` rules applied; `design.knowledgeApplied` will be
empty in the manifest).

## Journey

| Step | Status |
|---|---|
| 03-design | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) |

## Skill evaluation — `istqb-design` (`plugins/qaia-core/skills/istqb-design/SKILL.md`)

**Verdict: CONFORME.**

**Evidence**: Step 5's checkpoint rule (line 98, reinforced by the guardrail footnote on line 103
from the 2026-07-29 campaign, which found a 3c pattern silently skipped without a trace on a prior
run) requires every sub-step of 3b/3c/3d to appear with its stated outcome. This checkpoint states
an outcome for all seven 3c patterns (six "not applicable" with a stated reason, one "applied" —
folded into the state × event table with an explicit justification for why a separate decision
table would be redundant), plus 3b (not applicable, reasoned) and 3d (absent, stated plainly). The
State Transition Testing technique's own "build the explicit state × event table first... never
pick transition pairs opportunistically" instruction (palette line 43) was followed literally —
the table above enumerates every state × event cell, including the two forbidden/undefined ones,
before any condition was derived from it, and the `[assumption]` vs `[open]` distinction for the
undeclared-transition cells (Q1) correctly applies the default-deny-is-legitimate-for-non-
dangerous-but-still-undeclared reflex from line 80's own caveat: since neither cell describes a
dangerous action (delete, payment, permission escalation), and the transition is genuinely
undeclared with no safety-obvious default either way, it is correctly kept as `[assumption]`/
out-of-scope rather than forced into a specific asserted outcome. Step 3's negative-pressure gate
(line 75) was run honestly to a **zero** result rather than padded — this is itself the correct
application of the same guardrail line 102 ("an unjustified technique is a rubric defect") applied
to conditions, not just techniques: inventing a `[req-neg]` condition here to satisfy the gate
would have been the actual defect. No deviation found. **Modification proposed: none.**
