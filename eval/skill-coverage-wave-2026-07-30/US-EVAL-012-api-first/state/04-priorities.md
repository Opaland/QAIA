---
stepsCompleted: [00-ingest, 02-understanding, 03-design]
lastStep: 04-priorities
lastSaved: 2026-07-30
usId: RAD-PUBOBJ
arbitration: NOT ARBITRATED — proposed scores only
---

# 04-priorities — RAD-PUBOBJ

Skill: `plugins/qaia-core/skills/prioritize/SKILL.md`
Prerequisite: `03-design.md` ✔ (34 conditions)

> ## ⚠ STATUS: **PROPOSED BUT NOT ARBITRATED**
>
> Per `prioritize` step 3, corrected 2026-07-30: this is a **non-interactive** run with no user
> available. Auto-acceptance is **not** arbitration and is not recorded as such. Every score below
> is the skill's *proposal*.
>
> **These priorities are unsuitable for a production Go/No-Go until a human reviews them.**
>
> No `simulated: accepted-as-is` note is written here — the corrected clause names that exact
> pattern as the defect. `journey.md` carries `04-prioritize = pending-validation`.

## Inputs used

- **Knowledge base:** absent (`ls .qaia` → `No such file or directory`). No criticality notes, no
  anomaly history. Recorded, not substituted.
- **Git-history signal:** **not used.** The user designated no target repo path for this session,
  and the target is a closed hosted service with no source repository at all. Per the guardrail
  the signal is silently skipped — and, also per the guardrail, **the absence of history data is
  not treated as evidence of low risk**: no condition's probability was lowered for lack of data.
- **Impact anchor:** this is a *developer-facing teaching/prototyping API*. Nothing here is
  safety-, money- or health-critical, so impact 3 is reserved for **contract falsification** —
  behaviour that teaches a consumer a wrong model and silently corrupts their code — rather than
  for physical or financial harm. Stated up front so the whole column is readable against one
  yardstick (D2's regulated-context default is **not** applied: this project is not in the
  regulated niche).

## Proposed scores

Priority = impact × probability → **P1 (≥6) / P2 (3-4) / P3 (≤2)**.

| Condition | I | P | Prio | One-line risk rationale | Flags |
|---|---|---|---|---|---|
| AC1-C1 | 3 | 1 | **P2** | The list shape is the contract every consumer parses first; but it is the most-exercised path on the service, so a latent defect is improbable. | — |
| AC1-C2 | 2 | 2 | **P2** | `data: null` is a classic serializer casualty (dropped or coerced to `{}`); the source's own example set contains one, so the case is real, not hypothetical. | — |
| AC1-C3 | 2 | 2 | **P2** | The catalogue is shared mutable state open to anonymous writes — set instability between two calls is plausible, and it would make every list assertion flaky for everyone. | — |
| AC1-C4 | 3 | 2 | **P1** | If the reserved demo objects are publicly mutable, one anonymous user can corrupt the reference data every other learner tests against — the highest blast radius on this surface. | `[open] Q2` |
| AC2-C1 | 3 | 2 | **P1** | "Includes only the specified objects and **excludes all others**" is the one exclusion promise the docs make explicitly; a leak here is a silent over-return every consumer would trust. | — |
| AC2-C2 | 2 | 1 | **P3** | Multiplicity-1 is the degenerate case of a documented, simple filter — low consequence, low likelihood. | — |
| AC2-C3 | 2 | 3 | **P1** | The 100 %-filtered-out response *shape* is undocumented; a `404` where a consumer loops over an array is an immediate client crash, and undocumented paths are where defects concentrate. | `[assumption] Q7` |
| AC2-C4 | 2 | 3 | **P1** | Ids are typed `string[]` but every example is numeric — a parser assuming integers is a live `5xx` risk on a trivially reachable input. | `[assumption] Q8` |
| AC3-C1 | 3 | 1 | **P2** | Core read path, fully documented with a worked example, constantly exercised. | — |
| AC3-C2 | 3 | 3 | **P1** | The not-found path of a CRUD API is the single most-coded-against error, and this contract documents **no status code at all** — maximum uncertainty on a maximum-usage path. | **`[req-neg]`**, `[assumption] Q1` |
| AC3-C3 | 2 | 3 | **P1** | Same undocumented territory as AC2-C4, on the path parameter rather than the query string. | `[assumption] Q8` |
| AC4-C1 | 3 | 2 | **P1** | Creation is the gateway to every mutation scenario; if `id`/`createdAt` are not returned as documented, nothing downstream is testable. | — |
| AC4-C2 | 3 | 3 | **P1** | Required-ness of the only named field is undocumented; a silent accept of a nameless object teaches consumers there is no validation at all. | **`[req-neg]`**, `[assumption] Q3` |
| AC4-C3 | 3 | 3 | **P1** | A `5xx` on malformed client JSON is a genuine defect class regardless of which `4xx` the vendor picks — and unparsed-body handling is where hosted APIs most often leak a stack trace. | **`[req-neg]`**, `@oracle:rfc9110` |
| AC4-C4 | 2 | 3 | **P1** | Content-type negotiation is undocumented here and is a common source of accidental `5xx` or silent misparse. | **`[req-neg]`** |
| AC5-C1 | 3 | 2 | **P1** | "The data field accepts **any** valid JSON structure" is the source's single most emphasised promise (`<strong><u>`); an array payload is the cheapest way to falsify it. | — |
| AC5-C2 | 3 | 2 | **P1** | Same headline promise at depth — nesting is where flattening/serialization defects hide. | — |
| AC5-C3 | 2 | 2 | **P2** | Spaced and non-ASCII keys: the docs' own examples use `"CPU model"`, so spaced keys are proven; non-ASCII is the extrapolation, hence a notch lower. | — |
| AC5-C4 | 2 | 2 | **P2** | Scalar/`null` `data` is demonstrated by the reserved set itself, so acceptance is near-certain; the risk is round-trip fidelity, not rejection. | — |
| AC6-C1 | 3 | 2 | **P1** | Removal-by-omission **is** the meaning of "completely replaces"; if it does not hold, `PUT` is secretly a `PATCH` and every consumer's replace semantics are wrong. | — |
| AC6-C2 | 1 | 2 | **P3** | `updatedAt` is response metadata — its absence is cosmetic for correctness, though it is documented. | `@oracle:iso-8601` |
| AC6-C3 | 2 | 2 | **P2** | Shape-changing replacement is an extrapolation from AC5 onto AC6; moderate consequence, moderate likelihood. | `[assumption]` |
| AC6-C4 | 3 | 3 | **P1** | Upsert-vs-refuse on `PUT` is the classic REST fork, **undocumented**, and both behaviours are defensible — a consumer that guesses wrong silently creates orphan objects. | **`[req-neg]`**, `[open] Q4` |
| AC7-C1 | 3 | 2 | **P1** | Preservation of the untouched `data` block is what makes `PATCH` a patch; a defect here silently destroys consumer data. | — |
| AC7-C2 | 2 | 1 | **P3** | Sequencing `PATCH` after `PUT` is not itself ambiguous; it guards a compositional regression only. | — |
| AC7-C3 | 3 | 3 | **P1** | The merge **depth** for a supplied `data` key is the one disambiguating case the documentation avoids showing — plausible-but-wrong risk at its highest, on a data-destroying operation. | `[assumption] Q9` |
| AC7-C4 | 2 | 3 | **P1** | `PATCH` on an absent id: undocumented, and a silent success would be a phantom write. | **`[req-neg]`**, `[assumption] Q1` |
| AC8-C1 | 3 | 1 | **P2** | Delete is documented down to its exact response message, so the happy path is well specified; consequence high, likelihood low. | — |
| AC8-C2 | 3 | 2 | **P1** | "Removes permanently" is only verifiable by the follow-up read; a resurrected object would falsify the strongest word in the delete contract. | **`[req-neg]`**, `[assumption] Q1` |
| AC8-C3 | 3 | 3 | **P1** | Terminal-state re-entrance: a second `DELETE` answering `{"message":"… has been deleted."}` would report success for an operation that did nothing — an undocumented cell of the state table and a textbook idempotency-vs-honesty trap. | **`[req-neg]`**, `[assumption] Q1` |
| AC9-C1 | 2 | 1 | **P3** | CORS is a headline feature of a browser-facing demo API and is almost certainly configured; consequence is limited to browser consumers. | — |
| AC10-C1 | 3 | 1 | **P2** | "SSL/TLS for **all** endpoints" is a security-shaped promise (impact 3), but HTTPS-only enforcement on a modern hosted API is near-universal (probability 1). | **`[req-neg]`** |
| AC11-C1 | 1 | 2 | **P3** | Observational only — whether the quota is surfaced in headers is a usability nicety; **the limit is deliberately never exhausted**, so this can never be more than an observation. | `[open] Q5` |
| JRN-C1 | 3 | 1 | **P2** | The end-to-end lifecycle is the smoke signal for the whole surface, but every leg is already covered atomically, so its independent defect-finding power is low. | `@smoke` |

## Distribution (counted, not estimated)

| Band | Count | Conditions |
|---|---|---|
| **P1** | 19 | AC1-C4, AC2-C1, AC2-C3, AC2-C4, AC3-C2, AC3-C3, AC4-C1, AC4-C2, AC4-C3, AC4-C4, AC5-C1, AC5-C2, AC6-C1, AC6-C4, AC7-C1, AC7-C3, AC7-C4, AC8-C2, AC8-C3 |
| **P2** | 10 | AC1-C1, AC1-C2, AC1-C3, AC3-C1, AC5-C3, AC5-C4, AC6-C3, AC8-C1, AC10-C1, JRN-C1 |
| **P3** | 5 | AC2-C2, AC6-C2, AC7-C2, AC9-C1, AC11-C1 |
| **Total** | **34** | — |

**All 9 `[req-neg]` conditions land in P1 or P2** (8 × P1, AC10-C1 × P2). There is therefore **no
priority-scoped `[req-neg]` waiver** in this run: the negative-path gate must be satisfied in full
by `testbook-generate`, with no "deferred, P3" exemption available.

## Assignments needing human arbitration (all 34, plus these specifically)

Every row above is unarbitrated. The ones where a human's business knowledge would most plausibly
*move* the score:

1. **AC1-C4** — is corrupting the shared demo catalogue really the top risk, or is it the vendor's
   accepted operating model? Depends on the answer to `[open] Q2`.
2. **AC10-C1 / AC9-C1** — a security-minded reviewer may raise both probabilities; a reviewer who
   trusts the hosting platform may drop AC10-C1 to P3.
3. **AC6-C2** — impact 1 on a *documented* response field is arguable; a strict contract reading
   would put it at 2 (→ P2).
4. **AC11-C1** — kept at P3 partly *because* the condition is unexercisable by design; a reviewer
   may prefer it be dropped entirely rather than shipped as an observation.
5. **The impact anchor itself** (impact 3 = contract falsification, not harm) is a judgement call
   that recalibrates the entire column if rejected.

## Next step

`testbook-generate` — default scope **P1 + P2** (29 conditions). **P3 (5 conditions) is the user's
call** and is *not* generated by default (quota trade-off, Q22); the five deferred conditions must
still appear in the coverage matrix with the reason, never vanish from the count.
