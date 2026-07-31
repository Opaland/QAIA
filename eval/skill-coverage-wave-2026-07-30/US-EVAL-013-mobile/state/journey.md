# journey — US-EVAL-013 (first end-to-end MOBILE run of the campaign)

Target: `https://www.saucedemo.com/` (public practice app, `docs/DEMO-TARGETS.md`).
Mobile = **browser emulation** via Playwright device descriptors (**D100**). Native iOS/Android
(Appium) is out of scope for v1 and was **not** faked. SauceDemo's React Native companion app,
named in `docs/DEMO-TARGETS.md`, was deliberately not fetched and not analysed.

| Step | Skill | Status | Note |
|---|---|---|---|
| 00 | `us-ingest` | done | Live target explored under `devices['Pixel 7']`; 18 viewport widths swept; every AC anchored on a rendered measurement. One white-box peek (the page's `@media` condition texts, read once to choose which widths to bisect) **disclosed** in `01-extraction.md` rather than hidden. |
| 01 | `us-review` | **pending-validation** | `extraction: unconfirmed` per `us-review` SKILL.md line 19. All 7 ACs `[reconstructed]` — the target has no written story. See the documented D125 conflict below. |
| 02 | `need-understanding` | **pending-validation** | Q1-Q9 traced: 4 `[assumption]` with proposed defaults, 5 `[open]`. Q1b (fractional viewport width) left with **no scenario at all** rather than defaulted. |
| 03 | `istqb-design` | **pending-validation** | 6 techniques (boundary, EP, decision table, state transition, error guessing, use case) + one published oracle (WCAG 2.2 SC 2.5.8). AC→technique map proposed, never approved. |
| 04 | `prioritize` | **pending-validation** | 11 P1 / 6 P2 / 0 P3. Scores **proposed but not arbitrated**; 0 overrides recorded because 0 arbitration occurred. |
| 05 | `testbook-generate` | done | 17 scenarios, 7/7 ACs, 4 `[req-neg]` covered, negative ratio 25 % (reported honestly, not padded to 40 %). D19 duplicate scan: 0 reuses. |
| 06 | `report` | done | `reports/manifest.json`. |
| 07 | `testbook-validate` | done | **Real script execution**, twice. Structural **PASS 89/100** with `--source 00-source.md`; **FAIL / forced STOP** with `--source 01-extraction.md` — same book, same command. Checklist **CONCERNS 15/16** (business correctness capped at 1). → overall **CONCERNS**. Two tooling defects raised (A, B). |
| — | **⚠ ARRÊT — human Go/No-Go** | **NOT crossed** | No human in this session. Step 8 below ran **under an explicit campaign instruction**, not under a human Go. Not simulated, not claimed. |
| 08 | `automate` | done | POM-as-fixtures honoured. **42/42 green** (21 blocks × 2 device descriptors) after one real fix. 0 scenarios blocked. |

## What step 8 actually ran

```
npx playwright test        →  42 passed (20.2s)
```

`devices['iPhone 13']` on **webkit** and `devices['Pixel 7']` on **chromium** — each descriptor on
its own `defaultBrowserType`, because a suite that runs both on one engine is resizing a window,
not emulating a phone. Touch input via `locator.tap()` / `page.touchscreen.tap()`, available only
because the descriptors set `hasTouch`. Full detail, testability gaps TG-1…TG-4 and the AC→test
matrix: `automation/traceability.md`.

**The first run was 40/42.** `@QAIA-US-EVAL-013-004` failed on **both** engines; diagnosis
(`probe-004-diagnosis.js`) showed `aria-hidden` flips to `"false"` while the drawer is still fully
off-screen (`x: -412` on a 412 px viewport). Fixed by waiting on rendered geometry rather than the
attribute — **not** by a `waitForTimeout`. The red run is reported, not erased.

## Findings raised, none fixed (no `SKILL.md`, `DECISIONS.md`, `KANBAN.md` or `plugin.json` touched)

| # | Where | Severity proposed | One line |
|---|---|---|---|
| **A** | `testbook-validate/SKILL.md` line 19 | ÉCART STRUCTUREL | "the source" is still undefined; here it flips the deterministic gate between FAIL/forced-STOP and PASS 89. **Repeat** of a US-EVAL-009 finding (2026-07-29) that was never applied. |
| **B** | `eval/tools/structural_score.py` lines 110 / 164-171 | tooling defect | The sniffer never expands `Examples`, so **any parameterised URL** (`.../<path>`) is untraceable by construction — it penalises the very technique `istqb-design` recommends. |
| **C** | all 15 `qaia-core` skills | product gap | **Zero** mobile/viewport/touch/orientation/breakpoint awareness anywhere in the design chain. Mobile enters QAIA only at `automate`/`visual-check`, and only as a one-line D100 scope disclaimer. |
| **D** | `saucedemo-mobile-navigation.feature` `-006`/`-007`/`-008` | book weakness (upstream of `automate`) | The AC4 `Then` asserts `aria-hidden`, which finding F-1 proves is true ~half a second before the drawer is visible. The tests are faithful to the Gherkin and green; the weakness is in the `Then`. |
| **E** | `us-review/SKILL.md` line 19 vs. `docs/SKILL-EVAL-CAMPAIGN-PROMPT.md` | conflict | "…and stop" makes the project's own evaluation campaign terminate at step 2 on every non-interactive run. Named in `01-extraction.md`, continued deliberately with the `unconfirmed` stamp propagated to every downstream artifact. |
| **F** | `docs/OUTPUT-CONTRACT.md` / `skills/README.md` rule 3 vs. D125 | contract defect | The `openArbitrations.kind` enum admits only `open\|assumption\|simulated`, and rule 3 still prescribes `simulated: <default applied>` — which the D125 fixes now forbid. The manifest's 8 gate entries are therefore `kind:"simulated"` with `PENDING-VALIDATION` in their prose. |

## Non-regression check on the D125 fixes (2026-07-30)

The six corrected skills behaved as corrected, and the corrections **bit**:

- `us-review` line 19 stopped this run from writing `status: done` — the extraction is
  `unconfirmed` and every downstream artifact carries the stamp. It also produced finding **E**,
  which is the cost of the fix, reported rather than absorbed.
- `prioritize` line 18 stopped the "0 overrides" line from reading as a silent human sign-off;
  `04-priorities.md` says **proposed but not arbitrated**.
- `testbook-validate` step 5's new "ask for approval, don't just mention it" rule is honoured — the
  report asks the regeneration question outright.
- **No `simulated: accepted-as-is` anywhere in this run.** That phrase, the thing D125 removed, does
  not appear in any artifact of US-EVAL-013.

## Producer's self-report vs. independent evaluation

Everything above is the **producer's own note**. Per D117 ("no producer ever scores itself") the
band verdicts (`CONFORME` / `ÉCART MINEUR` / `ÉCART STRUCTUREL`) for the 8 skills exercised must
come from context-isolated evaluator agents that see only each `SKILL.md`, its input and its
output — never this journey. Those passes are the parent orchestrator's to dispatch; this file
deliberately does **not** award itself a verdict.
