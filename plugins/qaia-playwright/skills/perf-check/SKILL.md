---
name: perf-check
description: Generate and run performance checks (latency budgets, concurrency integrity) against a self-hosted app, with k6 for real load. Use for performance coverage. Self-hosted targets only.
---

# perf-check — performance

Reference: `examples/medibook/tests/perf.slots.spec.js` (p95 latency + no-oversell under contention). Real load uses **k6** (T6); a lightweight Playwright-request version covers latency/concurrency without extra tooling.

## Steps

1. **Latency budget**: fire N concurrent requests at a key endpoint, assert p95 < budget; log p50/p95/max.
2. **Concurrency integrity**: race N clients on a limited resource (e.g. one bookable slot), assert exactly one succeeds — no oversell/double-spend.
3. For serious load, generate a **k6 script** (stages, thresholds) and run it against the self-hosted target.
4. Tag `@QAIA-PERF-<NNN>`; report real numbers.

## Guardrails

- **Self-hosted targets only** (D35): load testing a shared public demo is forbidden and often against its terms. Refuse a public shared target; require a self-hosted URL (Docker/VPS/local).
- Report measured latencies; never assert a budget you did not actually measure.
