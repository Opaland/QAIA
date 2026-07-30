# 04-priorities — US-EVAL-008

| Condition | Impact | Probability | Priority | Rationale |
|---|---|---|---|---|
| AC1-C1 | 1 | 1 | P3 (1) | Internal request-shape detail (guest cookie field), not directly user-visible. |
| AC1-C2 | 1 | 1 | P3 (1) | Same, logged-in branch — simple, stable cookie-read logic. |
| AC2-C1 | 2 | 2 | **P2** (4) | Impact 2: a wrong/missing error alert on a genuinely expired token misleads the user about why "add to cart" didn't work. Probability 2: one branch of a 4-way decision table — more surface for a copy/branch mix-up than a single-path check. |
| AC2-C2 | 2 | 2 | **P2** (4) | Same reasoning as AC2-C1, sibling branch of the same decision table. |
| AC2-C3 | 2 | 2 | **P2** (4) | Same reasoning as AC2-C1, sibling branch of the same decision table. |
| AC2-C4 | 1 | 1 | P3 (1) | Happy-path confirmation alert — simplest branch, `else` fallthrough. |
| AC3-C1 | 3 | 2 | **P1** (6) | Impact 3: this is the reformulation's named highest risk — a guest add-to-cart failure is silently reported as success, exactly the false-positive class that hides real defects from both users and shallow test suites. Probability bumped to 2 per this skill's own rule for `[assumption]`-flagged conditions (**Q1**): the scenario can only assert the observable success case, leaving the "never differentiates" claim itself unverified live — that residual uncertainty is the probability driver, not the (deterministic, source-confirmed) code path itself. |
| AC4-C1 | 1 | 1 | P3 (1) | Single-item display — the simplest case of the accumulation logic. |
| AC4-C2 | 2 | 2 | **P2** (4) | Impact 2: a wrong multi-item total is a wrong displayed charge amount — directly visible and directly consequential to the shopper's purchase decision. Probability 2: the accumulation runs across N independent async `/view` resolutions (`00-source.md`) — genuine concurrency-adjacent complexity, not a single deterministic call. |
| AC4-C3 | 1 | 1 | P3 (1) | Empty-list display — a static, simple state (3c reflex pattern, low complexity to implement correctly). |
| AC5-C1 | 2 | 1 | P3 (2) | Impact 2: an incorrect delete (wrong row, or a total that doesn't recompute) misleads the shopper about cart contents. Probability 1: the delete-then-reload mechanism is simple and the reload path re-derives the total from scratch (`00-source.md`), leaving little room for a stale-total defect specifically. |
| AC6-C1 | 1 | 1 | P3 (1) | Static modal-field presence check — cosmetic-severity. |
| AC6-C2 | 1 | 2 | P3 (2) | Impact 1: the four unread fields carry no financial or functional consequence if mishandled (confirmed by source: never sent, never shown). Probability 2 per the `[assumption]` flag — though the *current* code confirms non-effect, a future change reintroducing these fields without validation is exactly the kind of latent-defect class regression testing exists to catch. |
| AC7-C1 | 2 | 1 | P3 (2) | Impact 2: blocking an invalid order (empty name) protects order data quality. Probability 1: the validation logic is a single, simple `||` boolean check, well inside straightforward-to-implement territory. **`[req-neg]` — standing P3-scoped waiver, see scope note below.** |
| AC7-C2 | 2 | 1 | P3 (2) | Symmetric to AC7-C1 (empty credit card branch of the same `||` check). **`[req-neg]` — standing P3-scoped waiver, see scope note below.** |
| AC7-C3 | 2 | 2 | **P2** (4) | Impact 2: a whitespace-only "credit card" value silently passing validation lets a shopper "place an order" with garbage payment data — a real order-integrity gap. Probability 2: this is exactly the class of boundary a naive equality check misses and a naive test suite (asserting only clearly-empty vs clearly-filled) would also miss — an edge condition with a real, non-obvious discovery cost. |
| AC8-C1 | 3 | 1 | **P2** (3) | Impact 3: this is the core conversion action of the whole flow — if the happy-path purchase silently breaks, the storefront cannot sell anything. Probability 1: the code path itself is straightforward (id generation, one `deletecart` call, one dialog construction) — well-understood, not novel or concurrent logic on its own. |
| AC8-C2 | 2 | 2 | **P2** (4) | Impact 2: a stale Amount is a real but bounded-severity display defect within a single session (no evidence of an actual double-charge — this is a demo with no live payment capture). Probability 2 per the `[assumption]` flag (**Q2**): the un-awaited-async shape is confirmed by source, but this scenario is scoped to the single-session case, leaving the multi-tab race itself untested — the residual uncertainty, same driver pattern as AC3-C1. |
| AC8-C3 | 3 | 3 | **P1** (9) | Impact 3: whether unauthenticated checkout is permitted is a genuine access-control/business-policy question on a monetary action — if the intended policy is "login required" and the code doesn't enforce it, that is a real authorization gap, not a cosmetic one. Probability bumped to 3, the maximum, because this condition rests on **`[open]` Q3** — per this skill's own rule, an open item (no safe default exists, genuine product-policy silence) carries the highest residual uncertainty of any condition in this design. **Flag: human arbitration explicitly requested on whether guest checkout is the intended policy — this P1 rank reflects the stakes of getting the *policy* answer wrong, not a confirmed defect in the code.** |
| AC8-C4 | 2 | 2 | **P2** (4) | Impact 2: an order placed against an empty cart produces a bogus `$0` order record — a real data-integrity gap, though not a financial-loss one (no money changes hands on a $0 order). Probability 2: this is an edge case (empty-cart checkout) a typical manual test pass on the "happy path" would not naturally exercise, raising the odds it ships unnoticed. |
| AC9-C1 | 1 | 1 | P3 (1) | Simple, unconditional redirect on dialog confirmation. |

⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) — no human override
recorded; the **AC8-C3/Q3** flag above (human arbitration explicitly requested) is carried forward
as-is into `testbook-generate` rather than silently resolved either way.

**Scope decision for `testbook-generate` (Q22 quota trade-off)**: default scope is **P1 + P2 in
full** (10 conditions: 2 P1, 8 P2); the 11 P3 conditions are listed above with their rationale but
**not** generated into scenarios in this run — a human call per this skill's own step 4, deferred
here since no human is available to override the default (same convention as prior campaign
runs). **Standing `[req-neg]` waiver note**: `AC7-C1`/`AC7-C2` are `[req-neg]` conditions that
scored P3 — per `testbook-generate`'s own gate rule (its SKILL.md, negative-path coverage gate),
this is a legitimate priority-scoped waiver, not a silent gate violation, **provided both remain
visible in the coverage matrix/synthesis with their reason** — carried forward explicitly rather
than vanishing from the count.

## Journey

| Step | Status |
|---|---|
| 04-priorities | done — scores above proposed, not yet arbitrated by a human |

## Skill evaluation — `prioritize` (`plugins/qaia-core/skills/prioritize/SKILL.md`)

**Verdict: CONFORME.**

**Evidence**: Step 1 (lines 12-16) requires an impact/probability/priority triple with a rationale
for every condition from `03-design.md` — all 21 conditions are scored above, none skipped. Step
2's flag rule (line 17: "flag every score based on an `[assumption]` or `[open]` item") is applied
distinctly to `AC3-C1`/`AC8-C2` (`[assumption]`, probability bumped to 2, not the maximum) and
`AC8-C3` (`[open]`, probability bumped to 3, the maximum) — this differentiation matches the
skill's own guidance that `[open]` carries the highest residual uncertainty, producing genuine
score variation rather than a flat bump applied identically to every flagged condition. The
git-history signal (line 15) was correctly not invoked — no target repo path was named for this
session (only the public demo's live pages were designated), and the guardrail (line 29) requires
silent skipping rather than a faked citation, which is what happened. Step 4's scope-deferral note
(line 19) is recorded explicitly, including the standing `[req-neg]`-at-P3 waiver carried forward
by name (`AC7-C1`/`AC7-C2`) rather than silently dropped from view. No deviation found.
**Modification proposed: none.**
