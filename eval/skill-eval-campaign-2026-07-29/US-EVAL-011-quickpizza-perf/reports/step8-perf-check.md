# Step 8 — automation attempt (`perf-check`), post human-gate

**Human Go/No-Go gate status**: the canonical path (steps 1-7) stopped at the human gate as
required by `docs/SKILL-EVAL-CAMPAIGN-PROMPT.md`, and `reports/testbook-validate-report.md`
delivered the deterministic score/gate (CONCERNS, 71/100 structural, 14/16 checklist) for that
decision. The orchestrating session subsequently relayed an explicit Go decision from its user to
proceed to step 8 across the whole campaign, including this target, with the caveat (also relayed)
that QuickPizza's step 8 would likely be a documented blocker given no Docker in this sandbox. That
turned out to be only half true: **no Docker was needed**, because the project ships a genuinely
public, explicitly-perf-test-authorized live instance.

## What was targeted

- **Endpoint**: `POST /api/pizza` on `https://quickpizza.grafana.com` — the project's own publicly
  documented instance, explicitly earmarked for this exact use in its `README.md`: *"Use this
  environment to run small-scale performance tests like the ones in the [k6 folder](./k6/)"*, with
  a worked example command (`k6 run -e BASE_URL=https://quickpizza.grafana.com 01.basic.js`).
  This is a documented, narrow exception to `docs/DEMO-TARGETS.md`'s golden rule ("run load tests
  only on self-hosted instances") — the project itself opts its own shared demo into small-scale
  perf testing, unlike every other catalog target evaluated so far in this campaign.
- **Load profile**: the project's own unmodified `k6/foundations/05.thresholds.js` (fetched
  verbatim via `curl`, saved to `k6-probe/05.thresholds.js`) — 3 stages, ramping 0→5 VUs over 5s,
  holding 5 VUs for 10s, ramping down over 5s (20s total, peak 5 concurrent VUs) — the same
  small-scale shape the README itself points readers to.
- **Thresholds under test** (AC2-C1/C2/C3 from `03-design.md`, unmodified from the source script):
  `http_req_duration: p(95)<500ms, p(99)<1000ms`; `http_req_failed: rate<1%`;
  `quickpizza_ingredients: avg<8` (non-blocking).

## What was actually run (real execution, not simulated)

```
"/c/Program Files/k6/k6.exe" run -e BASE_URL=https://quickpizza.grafana.com 05.thresholds.js
```

k6 v2.1.0 was found pre-installed in this environment (`k6.exe v2.1.0`) — this was not assumed in
advance; its presence was checked, not asserted.

**Real result** (terminal output, verbatim excerpt):

```
  █ THRESHOLDS
    http_req_duration
    ✓ 'p(95)<500' p(95)=361.86ms
    ✓ 'p(99)<1000' p(99)=705.89ms
    http_req_failed
    ✓ 'rate<0.01' rate=0.00%
    quickpizza_ingredients
    ✓ 'avg<8' avg=5.888889

    checks_total.......: 63      3.080769/s
    checks_succeeded...: 100.00% 63 out of 63
    http_reqs..........: 64      3.12967/s
    vus_max............: 5
```

**All four thresholds passed** on this real, small-scale run: `AC2-C1` (p95 361.86ms < 500ms),
`AC2-C2` (p99 705.89ms < 1000ms), `AC2-C3` (error rate 0.00% < 1%) — the three P1 performance
conditions this US's `testbooks/quickpizza-recommendation.feature` scenarios `002`/`003`/`004`
describe are, on this one real sample, **verified against real behavior**, not merely asserted on
paper. This does not retroactively upgrade the earlier `testbook-validate` gate (CONCERNS) — that
gate correctly reported the book as unverified *at the time it was audited*; this is new evidence
obtained afterward, and a single 20-second/5-VU run is not the sustained, statistically robust load
profile a real performance-acceptance decision would need (one sample, no repetition, no ramp
beyond 5 VUs, run once against a shared demo instance whose other concurrent traffic is unknown and
uncontrolled).

## A real finding that changes an earlier `[open]` item — reported, not silently back-filled

Before running the k6 script, a single manual `curl` probe was made to confirm reachability:

```
curl -X POST https://quickpizza.grafana.com/api/pizza -H "Content-Type: application/json" -d '{...}'
→ HTTP 401, body: {"error":"authentication failed"}
```

This **resolves `Q1`** (`state/02-understanding.md`, `AC1-C3`/scenario `001`): authentication *is*
required for `POST /api/pizza` on the live instance — the book's proposed default ("accepted
without auth") was the **wrong** side of the open question. This is exactly the real-world
consequence `testbook-validate`'s own report flagged as a risk under "Business correctness" (P1
scenarios resting on an `[open]` item "could resolve to the opposite of what is asserted") — here
it did. **This report does not go back and silently rewrite `state/02-understanding.md`,
`03-design.md`, or the `.feature` file** to make it look like this was known from the start; per
this campaign's own D38 discipline, it is recorded here as new, dated evidence for a human-approved
regeneration pass, the same recommendation `testbook-validate-report.md`'s fix #1 already named.
Interestingly, `05.thresholds.js` itself uses a **hardcoded, clearly-fake dummy token**
(`'token abcdef0123456789'`) and every request in the real run above still returned `200` — meaning
the live instance's `/api/pizza` requires *a non-empty `Authorization` header of the right shape*,
but does not appear to validate it against a real logged-in session for this endpoint. That nuance
was not previously knowable from any documentation source and is recorded here as a second new,
real finding, also not back-filled into earlier checkpoints.

## What was NOT run (explicit limitation, not simulated)

- **AC1's happy-path/defaults conditions (AC1-C1, AC1-C2)** and **AC3's structural-validation
  conditions (AC3-C1, AC3-C2, AC3-C3)** were never exercised by this k6 run — `05.thresholds.js`
  only exercises the single valid-request path repeatedly. No probe was made against invalid
  `Restrictions` payloads (min>max toppings, negative calories, over-length name) — doing so against
  a shared public instance beyond the one already-authorized "small-scale performance test" use
  case would exceed what the project's own README licenses, and this report does not extend the
  probe past that explicit authorization.
- **No sustained/statistically robust load campaign** was run — one 20-second, 5-VU sample is a
  smoke-level confirmation, not a performance-acceptance decision; running more or longer against a
  shared public instance without a clearer resource budget from the project maintainers was judged
  out of scope for "small-scale."
- **The microservices deployment mode** (vs. the monolithic mode `quickpizza.grafana.com` likely
  runs — not independently confirmed) was not tested; `Q7`'s assumption remains unconfirmed either
  way by this probe.
