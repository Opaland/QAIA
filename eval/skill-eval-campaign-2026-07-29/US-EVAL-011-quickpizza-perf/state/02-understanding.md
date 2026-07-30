---
stepsCompleted: [00-ingest, 01-review, 02-understanding]
lastStep: 02-understanding
lastSaved: 2026-07-30
---

# 02-understanding — US-EVAL-011

## Reformulation

Who: any caller of QuickPizza's recommendation API — the UI's "Pizza, Please!" button, or a direct
API/load-test client. What: `POST /api/pizza` must accept a structurally valid `Restrictions`
object and return a `PizzaRecommendation` promptly, must keep doing so within the project's own
documented latency/error-rate envelope when many callers request one concurrently, and must refuse
a structurally invalid `Restrictions` object rather than silently accepting or defaulting it. Why:
this is QuickPizza's single primary interaction and the exact endpoint the project built its own
k6 teaching examples around — a regression here (slow, erroring, or silently wrong under load) is
both a functional and a performance defect at once, and is the whole reason this target exists in
the catalog (`docs/DEMO-TARGETS.md`'s "self-hosted load-test demo" framing). Main risk if it
misbehaves: under load, a slow or failing recommendation endpoint is the textbook case k6 exists to
catch before it reaches production — a silent latency regression that stays under the functional
happy-path's radar (still returns 200, just slower) is worse than an obvious crash, because
functional testing alone would never catch it.

## Ambiguity hunt

**Q1 — is authentication required for `POST /api/pizza`?** `01.basic.js` and `05.thresholds.js`
both send an `Authorization: token <t>` header; `17.login-action.js` shows how to obtain that
token, but no fetched source states whether the endpoint rejects an unauthenticated call, or
merely accepts it either way (with the token only used for personalization/rate-limiting/rating
linkage elsewhere in the app).
- Classification: step 3, this is an access-boundary question — per `need-understanding`'s own
  rule ("access boundary → question, never assumption... never assert 'unauthenticated → refused'
  when the source implies public access") → **`[open]`**. The example scripts' use of a token is
  not proof the token is *required*.

**Q2 — are `05.thresholds.js`'s numbers (p95<500ms, p99<1000ms, error rate<1%) an official
performance SLO for the app, or purely illustrative teaching values for the k6 syntax lesson?** No
separate performance-requirements document was located.
- Classification: step 3, no protected-domain trigger (not money/health/minors/compliance), and a
  reasonable-practitioner default exists: **use the project's own published, worked example against
  this exact endpoint as the working target** — it is the only concrete number available and is not
  an arbitrary invention, but it is worth flagging that the project itself may not intend these as
  a contractual SLO → **`[assumption]`**, `@low-confidence`.

**Q3 — exact HTTP status and response body for a `Restrictions` validation violation.** No fetched
source shows a validation-error example for this endpoint (unlike OpenEMR's `validationErrors`
channel in US-EVAL-005, no analogous documented error-response shape was found for QuickPizza).
- Classification: step 3, safe default exists (reject with a 4xx status, no `PizzaRecommendation`
  in the body) → **`[assumption]`**.

**Q4 — `minNumberOfToppings` > `maxNumberOfToppings` specifically: refused, silently swapped, or
silently clamped?** No source states this self-contradictory-range case.
- Classification: step 3, safe default (reject) is the more conservative interpretation of AC3's
  "structurally invalid or self-contradictory" wording → **`[assumption]`**, `@low-confidence`
  (a silent auto-swap is also plausible product behavior for a playful demo app, not ruled out).

**Q5 — negative `maxCaloriesPerSlice`: refused or silently clamped to 0/default?** Same reasoning
class as Q4.
- Classification: step 3, safe default (reject) → **`[assumption]`**, `@low-confidence`.

**Q6 — `customName` exceeding `MaxPizzaNameLength`: refused, or silently truncated?** The numeric
limit itself was never quoted by any fetched source, so neither the boundary value nor the
behavior at that boundary is known.
- Classification: step 3/4 — no safe default is obvious between "reject" and "truncate" for a
  cosmetic field on a demo app, **and** the boundary's own numeric value is unknown, so no
  concrete boundary test could be written with confidence even if a behavior were assumed →
  **`[open]`**.

**Q7 — which deployment mode (monolithic single-container vs. microservices) does AC2's
performance envelope apply to?** The README documents both; the fetched k6 scripts only address a
single `BASE_URL`, not which topology backs it.
- Classification: step 3, safe default exists — the README's own quickest-start Docker command
  (`ghcr.io/grafana/quickpizza-local:latest`, a single container) is the natural default target for
  a load-test demo run, and is the interpretation this US's scope should assume → **`[assumption]`**.

**Q8 — concurrency-correctness of the recommendation itself (not just latency): under concurrent
load, can two simultaneous requests ever receive a corrupted/cross-contaminated response (e.g. one
caller's `excludedIngredients` leaking into another caller's result via shared mutable state)?** No
source discusses internal state handling; this is the mandatory adversarial-pass question for a
load-relevant AC (see below).
- Classification: step 3, no safe default — "no cross-contamination occurs" is an assumption about
  implementation internals QAIA never reads (D110, black-box only), and asserting it with
  confidence would be exactly the kind of implementation-level guess the technique palette
  excludes → **`[open]`**.

## Adversarial pass (by AC type — mandatory)

- **State machine / lifecycle**: not applicable — `POST /api/pizza` is a stateless recommendation
  call with no multi-state lifecycle of its own (a returned recommendation is not later
  transitioned through states in this slice; that would be the `/api/ratings` sibling capability,
  out-of-slice per `00-source.md`). No re-entrance question arises within AC1-AC3.
- **Auth / tokens / permissions**: covered by **Q1** (is a token required at all). Token
  expiration/revocation mid-load-test is not separately questioned — no source establishes a token
  is even required, so a downstream expiration question would be premature until Q1 resolves.
- **Sorting / pagination**: not applicable — `/api/pizza` returns a single recommendation object,
  not a list. Waived.
- **Thresholds / quantities (AC1, AC2, AC3)**: AC2's latency/error-rate thresholds are the load-test
  core of this US (Q2). AC1/AC3's numeric thresholds are `maxNumberOfToppings`/
  `minNumberOfToppings`/`maxCaloriesPerSlice`/`customName` length (Q4, Q5, Q6) — each inclusive/
  exclusive boundary and exact numeric limit is not fully confirmed by any source, carried forward
  above rather than guessed.
- **Concurrency-specific (added for this load-relevant US, beyond the standard four)**: **Q8** —
  the one adversarial question this AC-type checklist does not name explicitly but that a
  performance-relevant US structurally requires: does concurrent access ever corrupt a single
  request's result. Recorded here rather than silently folded into Q2's latency-only framing.

## Cross-AC interaction pass (mandatory)

AC2 (performance under load) and AC3 (structural validation) intersect at a question neither AC
alone raises: **does a validation-refusal path (AC3) meet the same latency budget as a successful
recommendation (AC2)?** No source states whether a rejected/invalid request is expected to fail
fast (likely, since less work is done) or could paradoxically be slower (e.g. an expensive
validation routine) — flagged as a design-time note rather than a numbered `Q` since no plausible
failure mode points to a real risk here (rejecting early is the standard, lower-risk assumption,
not something a load-relevant AC needs to separately contest). AC1 and AC2 intersect trivially:
AC2's load profile is built from repeated AC1-shaped requests, so AC1's correctness is a
precondition for AC2's measurement being meaningful (an endpoint returning fast 500s would pass a
naive `http_req_duration` threshold while failing `http_req_failed` — already captured by AC2's own
error-rate threshold, not a separate question).

## Triple-AC contradiction pass (mandatory)

No matching pattern in this US: the triple-AC pattern requires a *protected/restricted-state* rule,
a *scoping* rule and an *anti-disclosure/error-shape* rule meeting on the same entity (the
US-EVAL-005 calibration example: a patient's restricted results, an org-scoped token, and a
404-to-avoid-disclosure rule). QuickPizza's recommendation endpoint has no restricted-visibility
entity of this shape in this slice — there is no per-caller-scoped resource being read back, only a
stateless recommendation being generated. **Not applicable, no matching pattern in this US.**

## Q&A log

| ID | Question | Status | Resolution |
|---|---|---|---|
| Q1 | Is authentication required for `POST /api/pizza`? | `[open]` | No default asserted with confidence — human arbitration required (access-boundary rule) |
| Q2 | Are `05.thresholds.js`'s numbers an official SLO or a teaching example? | `[assumption]`, `@low-confidence` | Used as the working AC2 target (only concrete numbers available) |
| Q3 | Exact HTTP status/body for a `Restrictions` validation violation | `[assumption]` | 4xx status, no `PizzaRecommendation` body |
| Q4 | `minNumberOfToppings` > `maxNumberOfToppings` | `[assumption]`, `@low-confidence` | Refused (proposed default; silent auto-swap not ruled out) |
| Q5 | Negative `maxCaloriesPerSlice` | `[assumption]`, `@low-confidence` | Refused |
| Q6 | `customName` beyond `MaxPizzaNameLength` (value itself unknown) | `[open]` | No default asserted; human arbitration required (both the behavior and the numeric bound are unknown) |
| Q7 | Which deployment mode (monolithic vs microservices) does AC2 target? | `[assumption]` | Monolithic single-container (README's own quickest self-host path) |
| Q8 | Cross-request contamination under concurrent load (implementation-level) | `[open]` | No default asserted; out of QAIA's black-box scope to assert internals with confidence — flagged, not designed as a concrete Then-assertable condition |

## Journey

| Step | Status |
|---|---|
| 02-understanding | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) |

## Skill evaluation — `need-understanding`

- **Skill evaluated**: `plugins/qaia-core/skills/need-understanding/SKILL.md`.
- **Input**: `01-extraction.md` above (3 ACs, one perf-typed, several unconfirmed behaviors already
  flagged at extraction).
- **Output**: this file.
- **Verdict**: **CONFORME.**
- **Evidence**: both mandatory trace sections the skill's own guardrail calls out (line 48:
  "Omitting the required trace of step 3 or step 4a... is the same defect as silently resolving an
  ambiguity") are present as their own headed sections (`## Adversarial pass` and `## Triple-AC
  contradiction pass`), each stating a finding or an explicitly-reasoned "not applicable" rather
  than a bare omission — including the triple-AC pass, correctly marked not applicable with the
  calibration-example comparison spelled out (line 28's own worked example), not just a one-word
  waiver. The classification decision tree (line 30) was applied case-by-case: Q1 and Q6 land on
  `[open]` for two structurally different reasons (Q1 is a genuine access-boundary question per
  line 26's explicit rule; Q6 is open because *both* the numeric bound and the behavior at that
  bound are unknown, not just the behavior) — showing the tree was reasoned per-question, not
  applied mechanically to a template. Q8 (concurrency-correctness) was added by the mandatory
  adversarial pass even though it does not fit any of the four named AC-type checklists verbatim —
  correctly recognized as a load-relevant addition rather than silently absorbed into Q2's
  latency-only framing.
- **Modification proposed**: none.
