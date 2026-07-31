# visual-check — real run against SauceDemo

- Skill exercised: `plugins/qaia-playwright/skills/visual-check/SKILL.md`
- Target: `https://www.saucedemo.com/` (`docs/DEMO-TARGETS.md`: SauceDemo, Visual = ✅). Creds
  `standard_user` / `secret_sauce`. No security scan, no load test was run against it.
- Playwright 1.62.1, Chromium, `workers: 1` (guardrail: *"Set `workers: 1` against a shared mutable SUT."*)

## Commands run (verbatim) and real results

### 1. Baseline creation — `npx playwright test` → `run1-baseline-creation.txt`
```
3 failed
  visual.saucedemo.spec.js:19:1 › @QAIA-VIS-001 login screen container is visually stable
  visual.saucedemo.spec.js:27:1 › @QAIA-VIS-002 inventory list is visually stable
  visual.saucedemo.spec.js:36:1 › @QAIA-VIS-003 footer (dynamic year masked) is visually stable
```
with, for each: `Error: A snapshot doesn't exist at …\footer-win32.png, writing actual.`
Exactly what SKILL step 2 states: *"a first run is never a 'pass', it's baseline creation."*
Baselines written:
```
visual.saucedemo.spec.js-snapshots/footer-win32.png            3 979 B
visual.saucedemo.spec.js-snapshots/inventory-list-win32.png  268 595 B
visual.saucedemo.spec.js-snapshots/login-screen-win32.png     23 252 B
```

### 2. Real diff against the baselines — `npx playwright test` → `run2-diff-against-baseline.txt`
```
  ok 1 @QAIA-VIS-001 login screen container is visually stable (407ms)
  ok 2 @QAIA-VIS-002 inventory list is visually stable (443ms)
  ok 3 @QAIA-VIS-003 footer (dynamic year masked) is visually stable (428ms)
  3 passed (1.6s)
```

### 3. Detection proof — injected regression — `INJECT_REGRESSION=1 npx playwright test` → `run3-injected-regression.txt`
Injection (`page.addStyleTag`): primary/inventory buttons and product names forced to `#b21f1f`.
Real numbers:

| Test | Pixels different | Ratio | Tolerance | Outcome |
|---|---|---|---|---|
| @QAIA-VIS-001 login | **11 419** | 0.02 | 0.01 | **FAIL — detected** |
| @QAIA-VIS-002 inventory | **31 425** | 0.04 | 0.01 | **FAIL — detected** |
| @QAIA-VIS-003 footer | (no diff reported — test passed) | — | 0.01 | pass — *see note* |

Note (honest, not a detection failure): VIS-003 stayed green because the injected rule targeted
`.footer_robot`, which **does not exist** on SauceDemo. Probed live — `probe-footer.js` /
`probe-footer-output.json`: `"footerRobotCount": 0`. The footer contains only the social `<ul>` and
`<div class="footer_copy">`. The injection was a no-op on that container.

### 4. Guardrail #40 proof (mask vs. tolerance) — `npx playwright test mask.proof.spec.js`, then `MUTATE=1 npx playwright test mask.proof.spec.js`
Same footer, same genuinely-dynamic line (`© 2026 Sauce Labs…`, JS-generated year — real text read
live in `probe-footer-output.json`), mutated `2026 → 2027`, `maxDiffPixelRatio: 0`:

| Test | Pixels different after the year rollover |
|---|---|
| @QAIA-VIS-004 footer **UNMASKED** | **1 614** |
| @QAIA-VIS-005 footer **MASKED** | **20** |

Masking removes 98.8 % of the noise — but **not 100 %**. See the suspected skill defect below.

## Suspected skill defect — visual-check SKILL.md line 20

`SKILL.md` line 20 asserts, without condition:
> "A masked/frozen region gives an **exact, provable diff (0 pixels)**; an unmasked 'dynamic but
> small' region can pass today and silently absorb the budget…"

My measured output contradicts the parenthetical:
```
@QAIA-VIS-005 footer MASKED …
  20 pixels (ratio 0.01 of all image pixels) are different.
```
Root cause, measured (`probe-mask-bbox.js` / `probe-mask-bbox-output.json`):
```
before: "© 2026 Sauce Labs. …"  textW = 470.34375
after:  "© 2027 Sauce Labs. …"  textW = 468.78125
textWidthDelta = -1.5625
```
Playwright's `mask` paints the **element's bounding box**. For an inline/auto-width text node, that
box is a function of the text itself, so changing the text moves the mask edge and the mask rectangle
itself diffs. "0 pixels" only holds when the masked element's box is layout-fixed.

**Proposed diff (NOT applied — for human arbitration):**

```diff
-…A masked/frozen region gives an exact, provable diff (0 pixels); an unmasked "dynamic but small" region can pass today…
+…A masked/frozen region gives a near-exact, provable diff — 0 pixels when the masked element's box is
+layout-fixed. Beware: Playwright's `mask` paints the element's *bounding box*, so masking an
+auto-width text node whose content changes still diffs at the mask edge (measured: `© 2026`→`© 2027`
+on SauceDemo's `[data-test="footer-copy"]` = 1614 px unmasked vs. 20 px masked, not 0 — the text box
+narrowed by 1.56 px). Mask a fixed-size container, or freeze the value, when a provable 0 is required.
+An unmasked "dynamic but small" region can pass today…
```

## Second, minor observation — visual-check SKILL.md line 21

`SKILL.md` line 21: *"Baselines are platform-specific (`*-linux.png`)"*. On this Windows runner
Playwright wrote `login-screen-**win32**.png`. The rule (platform-specific baselines, generate them
where CI runs) is correct and was confirmed by the run; only the illustrative suffix is presented as
if it were the suffix. Suggested wording: `` (`*-<platform>.png`, e.g. `*-linux.png` in CI, `*-win32.png` on a Windows dev box) ``.
Filing as a nit, not a structural gap.

## Files
- `playwright.config.js`, `visual.saucedemo.spec.js`, `mask.proof.spec.js`
- `probe-footer.js` + `probe-footer-output.json`, `probe-mask-bbox.js` + `probe-mask-bbox-output.json`
- `run1-baseline-creation.txt` … `run5-mask-proof.txt`
- `visual.saucedemo.spec.js-snapshots/`, `mask.proof.spec.js-snapshots/` (committed baselines)
