---
name: visual-check
description: Generate and run visual regression tests (Playwright screenshot snapshots) against a running app, per key screen, with baselines and a tolerance threshold. Use for visual/design coverage of a test book or an app.
---

# visual-check — visual regression

Reference: `examples/medibook/tests/visual.booking.spec.js` (login + booking screen baselines). Completes the 7-type coverage (E2E, API, mobile-emulation, a11y, perf, security, **visual**).

## Steps

1. For each key screen the test book covers (and any the user names), generate a snapshot test: navigate to a **stable** state (data reset/seeded so pixels are deterministic), then `expect(locator).toHaveScreenshot('<screen>.png', { maxDiffPixelRatio: <tol> })`.
2. **First run creates the baselines** (`*-snapshots/`), which the user commits; later runs diff against them. State this explicitly — a first run is never a "pass", it's baseline creation.
3. Scope each snapshot to a **stable region** (a container), not the whole viewport, to avoid flaky diffs from dynamic content (dates, counters). Mask or freeze dynamic areas.
4. Tag each test `@QAIA-VIS-<NNN>` for traceability; run against the app and report real diffs. Hand execution results to `run-report` (merged into the manifest's `execution.byType.visual`).

## Guardrails

- **Determinism first**: seed data and freeze/mask dynamic content before snapshotting — a flaky visual test is worse than none (real lesson from the medibook flake hunt). Set `workers: 1` against a shared mutable SUT.
- **Unmasked dynamic content isn't just a flake risk — it can silently eat the tolerance budget.** Audit finding (#40): an unmasked clock changed real pixels on every run yet stayed under `maxDiffPixelRatio` and passed — not by protection, by luck of the tolerance margin. A masked/frozen region gives an exact, provable diff (0 pixels); an unmasked "dynamic but small" region can pass today and silently absorb the budget a real regression would need to trip the threshold tomorrow. Mask/freeze, don't just rely on tolerance to average it out.
- Baselines are platform-specific (`*-linux.png`): generate them in the same environment the CI runs, or the diff is meaningless.
- Never suppress a real visual diff to force green; a diff is a finding for the human to accept or reject.
- Web-first, like the rest of the plugin (D100): mobile visuals are browser-emulation screenshots, not native.
