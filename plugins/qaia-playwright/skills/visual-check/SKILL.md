---
name: visual-check
description: Generate and run visual regression tests (Playwright screenshot snapshots) against a running app, per key screen, with baselines and a tolerance threshold. Use for visual/design coverage of a test book or an app.
---

# visual-check — visual regression

References, two independent domains: [`examples/medibook/tests/visual.booking.spec.js`](https://github.com/QAIA-Project/QAIA/blob/main/examples/medibook/tests/visual.booking.spec.js)
(login + booking baselines) and [`examples/expense-demo/tests/visual.expense.spec.js`](https://github.com/QAIA-Project/QAIA/blob/main/examples/expense-demo/tests/visual.expense.spec.js)
(6 screens, mutation-verified: a button-colour change kills 5 snapshots, a 3-pixel padding
shift kills the 2 that scope card lists, and no snapshot outside the mutated element's scope
reacts). Generating the second suite surfaced a defect no functional or a11y test had: a
sign-in error written into a region that is still `hidden` at that moment — invisible, and
its `aria-live` announcement made inside a hidden subtree.
Completes the 7-type coverage: E2E, API, mobile-emulation, a11y, perf, security, **visual**.

## Steps

1. **Generate a snapshot test per key screen** the test book covers, plus any the user names.
   Navigate to a **stable** state — data reset or seeded so pixels are deterministic — then:

   ```js
   await expect(locator).toHaveScreenshot('<screen>.png', { maxDiffPixelRatio: 0.002 });
   ```

   **That tolerance is the number that decides pass or fail, so it is stated rather than left
   blank.** `0.002` (0.2 % of pixels) absorbs anti-aliasing and font-hinting differences between
   runs on the same machine without hiding a real change: a moved button, a wrong colour or a
   shifted layout each move far more than 0.2 % of a screen's pixels.

   Raise it only with a stated reason — a target rendering text differently across OS versions,
   say — and **never to make a failing test pass.** Prefer masking the unstable region (step 3).
   If a screen genuinely needs a different tolerance, record which screen and why in the report.

2. **The first run creates the baselines** (`*-snapshots/`), which the user commits; later runs
   diff against them. **State this explicitly — a first run is never a "pass", it is baseline
   creation.**

3. **Scope each snapshot to a stable region** — a container, not the whole viewport — to avoid
   flaky diffs from dynamic content such as dates and counters. Mask or freeze dynamic areas.

4. **Tag each test `@QAIA-VIS-<NNN>`** for traceability, run against the app, and report real
   diffs. Hand execution results to `run-report`, which merges them into the manifest's
   `execution.byType.visual`.

## Guardrails

- **Determinism first.** Seed data and freeze or mask dynamic content before snapshotting — a
  flaky visual test is worse than none. Set `workers: 1` against a shared mutable SUT.
- **Unmasked dynamic content is not only a flake risk — it silently eats the tolerance budget.**
  An unmasked clock changes real pixels on every run and can still stay under
  `maxDiffPixelRatio` and pass: not by protection, by luck of the margin. A masked or frozen
  region gives an exact, provable diff of 0 pixels; an unmasked "dynamic but small" region passes
  today and absorbs the budget a real regression would need to trip the threshold tomorrow.
  **Mask or freeze — do not rely on tolerance to average it out.**
- **Baselines are platform-specific** (`*-linux.png`). Generate them in the same environment the
  CI runs, or the diff is meaningless.
- **Never suppress a real visual diff to force green.** A diff is a finding for a human to accept
  or reject.
- **Web-first**, like the rest of the plugin: mobile visuals are browser-emulation screenshots
  (Playwright device descriptors), never native-app captures. Report them as such — a
  device-emulated screenshot is not evidence about a native app.
