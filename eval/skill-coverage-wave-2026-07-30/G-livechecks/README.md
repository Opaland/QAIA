# G-livechecks — real exercise of `visual-check` and `usability-heuristic-review`

Wave `eval/skill-coverage-wave-2026-07-30`. Both skills had never been exercised by D118–D125.
Everything here is a real execution artifact. `node_modules/` and `test-results/` were deleted
before delivery, so the scripts need a reinstall to re-run (below).

| Skill | Target | Verdict of the run | Report |
|---|---|---|---|
| `visual-check` | SauceDemo (public, Visual = ✅ in `docs/DEMO-TARGETS.md`) | executed end to end: baselines → green diff → injected regression detected (11 419 / 31 425 px) | `visual-check/RESULTS.md` |
| `usability-heuristic-review` | MediBook, **self-hosted** `localhost:4401` | executed end to end: 8 screens, 9 findings, 1 cognitive walkthrough | `usability-review/heuristic-review.md` |

Neither `perf-check` nor `security-surface` was run. Nothing was committed, no `SKILL.md` was edited.

## Reproduce

```bash
cd visual-check
npm install @playwright/test@1.62.1
npx playwright install chromium
npx playwright test                                   # diff vs. committed baselines
INJECT_REGRESSION=1 npx playwright test               # proves detection
npx playwright test mask.proof.spec.js                # mask baselines
MUTATE=1 npx playwright test mask.proof.spec.js       # proves mask vs. tolerance
node probe-footer.js ; node probe-mask-bbox.js

# usability (SUT must be up first)
PORT=4401 node ../../../../examples/medibook/app/server.js &
cd ../usability-review
NODE_PATH=../visual-check/node_modules node explore.js
NODE_PATH=../visual-check/node_modules node probe-cancel.js
```

## Suspected skill defects (documented, NOT applied)

1. **`visual-check` SKILL.md line 20** — "A masked/frozen region gives an exact, provable diff
   (0 pixels)". Measured counter-example: masked footer still diffs by **20 px** because Playwright's
   `mask` paints the element's *bounding box* and an auto-width text node's box changes with its text
   (`textWidthDelta = -1.5625`). Full evidence + proposed diff in `visual-check/RESULTS.md`.
2. **`visual-check` SKILL.md line 21** (nit) — "Baselines are platform-specific (`*-linux.png`)";
   this run produced `*-win32.png`. Rule correct, illustrative suffix reads as normative.
3. **Brief vs. skill conflict (not a skill defect)** — the wave brief proposed SauceDemo for
   `usability-heuristic-review`; the skill's guardrail 1 forbids third-party sites. The skill won.
   Documented at the top of `usability-review/heuristic-review.md`.

## Gates not crossed
No `VALIDATION` gate exists in either SKILL.md. The campaign protocol's own human gate (before
step 8, `docs/SKILL-EVAL-CAMPAIGN-PROMPT.md` lines 55-60) is **pending-validation**: no human was in
this session, and this run deliberately exercised only the step-8 automation skills it was scoped to.
