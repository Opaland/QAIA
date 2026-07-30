# 04-priorities — US-EVAL-006

| Condition | Impact | Probability | Priority | Rationale |
|---|---|---|---|---|
| AC1-C1 | 1 | 1 | P3 (1) | Static markup check (button + hidden `#finish` present at load) — cosmetic-severity, trivial to get right. |
| AC2-C1 | 1 | 1 | P3 (1) | Immediate show/hide toggle on click — simplest code path in the page, low complexity. |
| AC3-C1 | 2 | 2 | **P2** (4) | Impact 2: a false-early "visible" read here is the exact defect class (presence-vs-visibility confusion) this feature exists to catch, though less severe than AC6-C1 since the element is present all along (a naive "wait for present" strategy still happens to work here). Probability 2: timing-boundary assertions (Q2) are a classic source of flaky/incorrect test authoring. |
| AC3-C2 | 1 | 1 | P3 (1) | Happy-path completion once AC3-C1 holds — low marginal risk, simple `.show()` call. |
| AC4-C1 | 2 | 2 | **P2** (4) | Impact 2: establishes the premise that makes AC6-C1's defect class possible (no `#finish` at load). Probability 2: a real, common test-authoring mistake is asserting "not visible" (`.not.toBeVisible()`) instead of "not present" (`.not.toBeInTheDom()`/no matching selector) for this exact case — the two are not interchangeable here, unlike AC1-C1's simpler presence check. |
| AC5-C1 | 1 | 1 | P3 (1) | Same reasoning as AC2-C1, mirrored on Example 2. |
| AC6-C1 | 3 | 3 | **P1** (9) | Impact 3: this is the single condition that most directly embodies the feature's own stated purpose (index page: "the element is not on the page and gets added in") — a test suite that only waits for visibility and never checks presence will silently pass here even when it shouldn't, hiding exactly the automation defect this demo page is built to expose. Probability bumped to 3 because this condition rests on `[assumption]` Q2 (lower-bound timing semantics), per this skill's own rule that assumption-flagged conditions score higher — **flag: the precise moment at which "not present" must be re-checked (immediately vs. polled) is a timing-sensitive assertion, human arbitration welcome on the wait strategy used downstream in automation.** |
| AC6-C2 | 2 | 2 | **P2** (4) | Impact 2: happy-path completion of Example 2's create-then-show mechanism — a real, distinct code path from AC3-C2 (node creation, not just `.show()`). Probability 2: timing-dependent, same class as AC3-C1/AC6-C1. |
| AC7-C1 | 1 | 1 | P3 (1) | Cross-example consistency (metamorphic) — a nice-to-have regression signal; both examples hardcode the identical literal in source, so divergence is unlikely (low probability), and impact is cosmetic (a documentation/consistency signal, not a functional break) if it ever did diverge. |

⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) — no human override recorded;
the AC6-C1/Q2 flag above is carried forward as-is into `testbook-generate` rather than silently
resolved.

**Scope decision for `testbook-generate` (Q22 quota trade-off)**: default scope is **P1 + P2 in
full** (4 conditions: 1 P1, 3 P2); the 5 P3 conditions are listed above with their rationale but
**not** generated into scenarios in this run — a human call per this skill's own step 4, deferred
here since no human is available to override the default (same convention as `US-EVAL-003`). This
US-slice's P1+P2 subset is small (4 of 9 conditions) because the page itself is genuinely
low-impact outside its one signature edge case (`AC6-C1`) — a small in-scope set here is an honest
reflection of the target's actual risk profile, not a shortcut.

## Journey

| Step | Status |
|---|---|
| 04-priorities | done — scores above proposed, not yet arbitrated by a human |

## Skill evaluation — `prioritize` (`plugins/qaia-core/skills/prioritize/SKILL.md`)

**Verdict: CONFORME.**

**Evidence**: Step 1 (lines 12-16) requires an impact/probability/priority triple with a rationale
for every condition from `03-design.md` — all 9 conditions are scored above, none skipped. Step
2's flag rule (line 17: "flag every score based on an `[assumption]` or `[open]` item") is applied
to `AC6-C1` (Q2), naming which assumption bumped its probability, matching the "probability
bumped... per this skill's own rule" phrasing the rubric expects to be traceable back to this exact
instruction — `AC3-C1`/`AC6-C2` also cite the same Q2-driven timing-flakiness class in their
probability rationale, without inflating their score past what their own lower impact already
caps. The git-history signal (line 15) was correctly not invoked — no target repo path was named
for *this* session (the campaign brief only designated the public demo's live pages, not a local
working copy for `git log --stat`), and the guardrail (line 29) requires it be skipped silently
rather than faked when unavailable, which is what happened (no `@history(...)` citation anywhere
above). Step 4's scope-deferral note (line 19, "P3 coverage is their call") is recorded explicitly
rather than silently generating or silently dropping the P3 set. No deviation found.
**Modification proposed: none.**
