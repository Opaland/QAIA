---
name: perf-check
description: Generate and run performance checks (latency budgets, concurrency integrity, named CT-PT test types - load/stress/spike/soak/scalability) against a self-hosted app, with k6 for real load. Use for performance coverage. Self-hosted targets only.
---

# perf-check — performance

Reference: `examples/medibook/tests/perf.slots.spec.js` (p95 latency + no-oversell under contention). Real load uses **k6** (T6); a lightweight Playwright-request version covers latency/concurrency without extra tooling.

## Steps

1. **Latency budget**: fire N concurrent requests at a key endpoint, assert p95 < budget; log p50/p95/max.
2. **Concurrency integrity**: race N clients on a limited resource (e.g. one bookable slot), assert exactly one succeeds — no oversell/double-spend.
3. **Named performance test type (CT-PT, D95)** — ask the user which type(s) apply (default: load only, the cheapest and most broadly relevant); generate a **k6 script** matching the requested type's shape, never a one-size-fits-all script:
   - **Load** — realistic expected concurrency, steady stage; asserts the latency budget holds under normal traffic.
   - **Stress** — ramp stages beyond the expected peak until something degrades; goal is finding the breaking point and how it fails (graceful 5xx/backpressure vs. crash/hang), not passing a fixed threshold.
   - **Spike** — a short, extreme step-increase from baseline then back down; asserts the system recovers (no lingering errors/latency) after the spike passes, not just that it survives during it.
   - **Soak / endurance** — a long, steady stage (minutes-to-hours, scoped to what's practical in-session); watches for degradation over time (rising latency, memory growth via repeated measurement) that a short run can't reveal — flag honestly if the session can only run a short proxy of a real soak window.
   - **Scalability / capacity** — repeat the load stage at increasing concurrency levels and report where the budget first breaks, rather than asserting a single pass/fail — a capacity curve, not a gate.
   - Volume, configuration, and baseline testing (CT-PT) are named but not separately scripted here — volume folds into the concurrency-integrity check above (large N), configuration/baseline are a documentation concern (record the environment the numbers were measured against), not a distinct k6 shape.
   - `k6/load.js` (this skill's directory) is a real, executable **load**-type template (#52,
     D105) — `BASE_URL`/`LATENCY_BUDGET_MS`/`VUS`/`DURATION` are the only parts a generated
     test needs to change to point at a different self-hosted target. Use it as the starting
     shape for load; stress/spike/soak/scalability still need their own script per the forms
     above (none scripted yet — extend from `load.js`'s structure, not from scratch).
4. Tag `@QAIA-PERF-<NNN>`, plus the CT-PT type tag `@perf:load` / `@perf:stress` / `@perf:spike` / `@perf:soak` / `@perf:scalability`; report real numbers, never a budget you did not actually measure.

## Guardrails

- **Self-hosted targets only** (D35): load testing a shared public demo is forbidden and often against its terms. Refuse a public shared target; require a self-hosted URL (Docker/VPS/local).
- Report measured latencies; never assert a budget you did not actually measure.
