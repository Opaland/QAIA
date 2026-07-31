---
stepsCompleted: [00-ingest, 02-understanding]
lastStep: 02-understanding
lastSaved: 2026-07-30
usId: RAD-PUBOBJ
upstreamGate: 01-review = pending-validation (extraction unconfirmed)
knowledgeBase: absent
---

# 02-understanding — RAD-PUBOBJ

Skill: `plugins/qaia-core/skills/need-understanding/SKILL.md`
Prerequisite: `01-extraction.md` ✔ (read with status `unconfirmed` — see header)

**Knowledge retrieval:** `knowledge/index.md` sought at the output root and at the repo root —
**knowledge base absent** (`ls .qaia` → `No such file or directory`). Proceeding on the source
alone; nothing about its content invented. `design.knowledgeApplied` will be empty, and that is a
signal about the base, not about the domain.

## Step 0 — Nothing-to-understand check

**Passes.** `01-extraction.md` carries 11 ACs describing concrete, observable HTTP behaviour
(methods, URLs, response shapes, a quota). This is a real capability, not a design doc. Proceed.

## Step 1 — Reformulation

A developer needs a live, zero-signup REST backend to practise against. `restful-api.dev` offers a
public `/objects` surface: a fixed demonstration catalogue that can be listed, filtered by id and
read, plus full create/replace/patch/delete on free-form JSON objects, all over HTTPS with CORS
open to any origin, capped at 50 requests per day per user.

The point of the product is *fidelity*: it claims to behave "much like working with a production
backend". So the risk that matters is **not** that the service goes down — it is that it behaves
*differently from what it documents*, silently. A learner or a demo app calibrates its own error
handling on this API's answers; if `PATCH` actually replaces instead of merging, if a delete
returns a success message for an object that never existed, or if an error path answers `200`,
then every downstream consumer learns a wrong model of REST from a service that exists precisely
to teach it. Secondary risk: the entire error half of the contract is undocumented, so any
consumer's error handling is written against guesses.

## Step 2/3 — Adversarial pass (by AC type)

Mandatory trace. Each AC classified by shape, then run against its type checklist.

| AC | Shape | Checklist applied | Findings |
|---|---|---|---|
| AC1 | list/collection view | sort · filter · empty-list · pagination bounds · persistence | **No ordering documented** (no sort key, no stability claim) → feeds Q7-adjacent, and drives condition AC1-C3. **No pagination** on the public list at all while the authenticated twin has `limit`/`offset` → asymmetry noted, not a defect per se. Empty-list not reachable on AC1 (the reserved set is fixed and non-empty by construction) — the empty *shape* question moves to AC2 where a filter can legitimately empty it. |
| AC2 | sorting/pagination + filtering | tie-break · out-of-range · **filters remove 100 % of results (empty response shape)** | The 100 %-removal case is undefined → **Q7** (mandatory per the checklist, not optional). Out-of-range analogue = an id outside the reserved set → **Q7**. Malformed id value → **Q8**. |
| AC3 | read by key | unknown key · malformed key | Unknown id → **Q1**. |
| AC4 / AC5 | data rules / creation | required-ness · formats · limits · uniqueness | `name` required-ness → **Q3**. "Any valid JSON structure" has no stated size/depth ceiling — the *ceiling* is left as a probe target, not a fabricated number (condition AC5-C4 asserts structural preservation, never a specific byte limit). Uniqueness: none claimed, none assumed. |
| AC6 / AC7 | state-changing update | idempotency · absent target · replace-vs-merge depth | `PUT` on absent id → **Q4** (create-or-fail, the classic REST fork). `PATCH` merge depth → **Q9**. |
| AC8 | lifecycle / terminal state | re-entrance · terminal state · forbidden transitions | **Re-entrance explicitly checked** (checklist item "can a state be reached more than once"): deleting an already-deleted object is a second entry into the same terminal state — undefined → folded into **Q1** (unknown id) with its own dedicated condition AC8-C3, because a delete of an absent id and a re-delete are the same observable case here. Terminal state: `deleted` has no documented exit (no restore/undelete endpoint) — no forbidden-transition table needed, the machine is `exists → deleted` with one edge. |
| AC1 vs AC8 | protected/reserved state | permissibility of mutation | AC1's "reserved […] for demonstration purposes" vs BR6's "you can use POST, PUT, PATCH, DELETE […] on both public and authenticated APIs" → **Q2**, `[open]`. |
| AC9 | cross-origin policy | preflight vs simple request | Docs promise CORS "for all domains" but say nothing about `OPTIONS` preflight or `Access-Control-Allow-Methods` — the promise is checkable only at the header level → condition AC9-C1 asserts the header, not a browser outcome. |
| AC10 | transport | protocol downgrade | "SSL/TLS for **all** API endpoints" is checkable: plain-HTTP request must not serve content. |
| AC11 | threshold / quantity | **inclusive vs exclusive** · units · **reference clock** | "50 daily requests" — is the 50th allowed or refused? What clock anchors "daily"? Who is "each user"? → **Q5**. Mandatory per the "every duration or deadline: measured against which clock" rule, attached to AC11 (the AC doing the computation), not to any display. |
| **auth/token** | — | — | **Not applicable, no matching pattern**: this slice has no authentication by construction (S3 is out of slice). The access-boundary rule ("question, never assumption") is nonetheless honoured: the source *does* state public endpoints are "open and accessible to anyone", so public read/write is **sourced**, not assumed — no `@low-confidence` guessed-auth scenario is generated. |
| **decision table / roles** | — | — | **Not applicable**: one anonymous role only in this slice. |

**Hard rule check (C2 — test-data choices that sidestep an undefined case).** This design
deliberately performs every mutation (AC6/AC7/AC8) on an object **it creates itself**, never on
the reserved ids 1-13. That choice sidesteps the undefined case "may the public API mutate the
reserved catalogue?" — therefore it is registered as **Q2** *before* being used, per the hard
rule. It is not silently convenient test hygiene.

## Step 4 — Cross-AC interaction pass

Every pair sharing an entity, resource or window:

| Pair | Shared thing | Interaction question | Status |
|---|---|---|---|
| AC4 × AC1 | the object store | Does an object created via `POST` appear in `GET /objects`? BR1 says the list is a *reserved* selection → probably not, which makes "created" unverifiable through the list. | **Q10** `[assumption]` |
| AC4 × AC2 | the id namespace | Can a `POST`-created id be fetched back via `?id=<newId>`? The docs say `?id=` is precisely how you "access multiple objects that you've created" — so **answered** by the source. | **answered** (`Pp[1]` description) |
| AC4 × AC3 | the id namespace | Same, single-object form. Not stated as explicitly as the `?id=` case, but it is the only read path for a created object once AC1 excludes it. | **`[assumption]`**, folded into Q10 |
| AC6 × AC7 | one object's field set | `PUT` (replace) then `PATCH` (merge) on the same object: does `PATCH` merge against the *post-PUT* state? Trivially yes — sequencing is not ambiguous. | covered (condition AC7-C2 chains them) |
| AC8 × AC3 | one object | After `DELETE`, is `GET /objects/{id}` a 404? The only documented fact is "removes permanently". | **Q1** |
| AC8 × AC8 | terminal state | Re-delete (see adversarial pass). | **Q1** |
| AC8 × AC2 | filter + deleted id | A deleted id inside a multi-id `?id=` request: silently omitted, or does it poison the whole response? | **Q7** (same empty/partial-shape family) |
| AC11 × every other AC | the daily budget | The quota is consumed by the very tests that verify the other ACs — a suite of ≥50 assertions cannot run in one day. This is a *test-strategy* consequence of AC11, **not** a requirement ambiguity. | **Not a Q-slot.** Recorded here and carried to `synthesis.md` as an execution constraint. Per step 5's corrected rule, feasibility/flakiness concerns must not consume a Q-slot. |
| AC9 × AC10 | transport | CORS headers on a plain-HTTP request — moot if AC10 holds (no plain-HTTP content served). | covered, no question |
| AC5 × AC6 | "any JSON" + "complete replacement" | Can `PUT` replace `data` with a *different JSON shape* (object → array)? AC5's "any valid JSON structure" is scoped to `POST` in the source; AC6 says "completely replaces". | **`[assumption]`**: yes, same freedom applies — folded into condition AC6-C3, tagged `@low-confidence`. |

## Step 4a — Triple-AC contradiction pass

Looking for a *protected/restricted-state* rule × a *filtering/scoping* rule × an
*anti-disclosure/error-shape* rule meeting on the same entity.

**One genuine triplet found:**

> **AC1/BR1** (the public list is a *reserved, restricted* selection — "not all stored objects
> created by you or others") × **AC2** (the `?id=` filter, which explicitly *scopes* into objects
> "you've created") × **AC8/Q1** (the undocumented not-found error shape).

At their intersection: **what does `GET /objects?id=<an id belonging to another user's private
object>` return?** BR1 asserts the list deliberately hides other users' objects — a restriction —
while AC2's filter is documented as the escape hatch into user-created objects, and no error shape
is documented to distinguish "does not exist" from "exists but is not yours". The three rules give
three different answers (hide → `[]`; scope → return it; anti-disclosure → indistinguishable
404/empty), and the source picks none. This is a **confidentiality** question, not a formatting
one — the FAQ itself markets the authenticated API as the way to hold objects "in a secure and
controlled environment that is accessible only to you", implying the public one is not.

→ **Q7b**, classified `[open]` (step-2 branch: a user-visible disclosure policy; any default is a
product decision). **Deliberately not probed** — verifying it would require attempting to read
another user's object, which is out of the authorized, non-destructive posture. Recorded as an
`[open]` requiring the vendor's answer, and carried to `synthesis.md`.

**Second triplet examined and dismissed:** AC11 (quota) × AC2 (filter) × error shape — a
quota-exhausted response is undefined (Q5), but there is no *restriction* rule in the triplet, so
it collapses into the pair already covered by Q5. Not a genuine triple.

## Step 5 / 5a / 6 — Questions

Numbering is complete and gap-free: **Q1…Q10, plus Q7b**. Highest impact first.
Each carries: why it matters, the proposed default, and the classification with the decision-tree
branch that produced it.

---

**Q1 — What does a request against a non-existent object id return (status code and body), on `GET`, `PUT`, `PATCH` and `DELETE`?**
*Why it matters:* it is the single most-used error path of any CRUD API, and the source documents
**zero** status codes. Every consumer's error handling depends on it. It also decides the
re-delete case (deleting an already-deleted object) and the post-delete read.
*Proposed default:* `404` with a JSON error body.
*Classification:* **`[assumption]`** — tree step 3 (a safe default a reasonable practitioner
accepts without escalation). The *body shape* stays unknown, so scenarios assert the **status
code and the absence of a success payload**, never a fabricated error-message literal.

**Q2 — May the public API mutate or delete the reserved demonstration objects (ids 1-13)?**
*Why it matters:* AC1 calls them "reserved […] for demonstration purposes" while BR6 says
POST/PUT/PATCH/DELETE are "supported on both public and authenticated APIs". If they are mutable,
the public catalogue is shared mutable state and every other user's tests are affected; if they
are not, there must be a refusal path that is documented nowhere.
*Proposed default:* treat as **forbidden unless stated** and never target them.
*Classification:* **`[open]`** — tree step 4. This is *permissibility* unspecified on a
destructive action against shared state, with no safety-obvious answer: "undeclared = forbidden"
would itself be an unstated business-policy answer (the vendor may well intend them mutable, since
the docs advertise mutation on the public API). Requires the vendor's arbitration.
*Consequence:* no scenario in this book mutates ids 1-13. A read-only observation of whether they
are still intact is generated instead (AC1-C4, `@low-confidence`, `# open: Q2`).

**Q3 — Is `name` required on `POST /objects`, and what happens when the body omits it, sends it empty, or sends a non-string?**
*Why it matters:* it is the only field the docs show by name, and the entire creation path hangs
on it. Undefined required-ness makes both a `201` and a `400` defensible, so no consumer can code
against it.
*Proposed default:* `name` is required; omitting it yields a `4xx` refusal.
*Classification:* **`[assumption]`** — tree step 3. Marks `[req-neg]`.

**Q4 — `PUT /objects/{id}` on an id that does not exist: create it (upsert) or refuse?**
*Why it matters:* this is the classic REST divergence — RFC 9110 permits upsert, most practical
APIs 404. Both are legitimate designs, so no default is "safe"; picking one silently would
manufacture a plausible-but-wrong scenario.
*Proposed default:* none defensible; refusal (`404`) is the *more common* choice, cited only as
the tie-break for generating a scenario at all.
*Classification:* **`[open]`** — tree step 4 (a genuine product decision, not a mechanical
consequence). Scenario generated on the tie-break default, `@low-confidence`, `# open: Q4`.

**Q5 — The 50-requests/day public quota: who is "each user", is the 50th request allowed or refused, what does an exhausted quota return, and does the 24 h window roll or align to a calendar day (in which timezone)?**
*Why it matters:* the "measured against which clock" rule applies in full. A quota is only testable
if its boundary and its refusal shape are defined; here neither is. It is also the only stated
limit on the whole public surface.
*Proposed default:* per-IP, 50 allowed and the 51st refused with `429`, rolling 24 h.
*Classification:* **`[open]`** — tree step 4. "Each user" identity on an unauthenticated API is a
user-visible policy decision, not a mechanical one; and a wrong guess here silently invalidates
every quota scenario.
*Consequence:* **no scenario in this book deliberately exhausts the quota** — that would be a
DoS-shaped probe against a third party's shared infrastructure and is forbidden by the shared
contract's posture. AC11 is covered by an *observational* condition only (is the limit surfaced in
response headers at all?).

**Q6 — "Design any data structures **and relationships**" — does the public `/objects` surface support any relationship/reference between objects?**
*Why it matters:* the phrase promises a capability; no endpoint, parameter or response field in
the entire document exposes one. Either the promise is marketing overreach (a contract-probe
finding) or an undocumented feature exists.
*Proposed default:* no relationship feature exists on the public surface; "relationships" means
only "nested JSON can express them inside `data`".
*Classification:* **`[assumption]`** — tree step 3 (low-risk, and the sentence's own second half
"using nested JSON objects" supports the reading).

**Q7 — Degenerate `?id=` filtering: (a) when *some* requested ids do not exist, are they silently omitted or is the whole request refused? (b) when *none* exist — filters remove 100 % of results — is the response an empty array with `200`, or a `404`?**
*Why it matters:* mandatory per the sorting/pagination checklist ("degenerate case where filters
remove 100 % of results — empty response *shape*"). A consumer that iterates the response breaks
differently for `[]` than for a 404 body.
*Proposed default:* (a) silently omitted; (b) `200` with `[]`.
*Classification:* **`[assumption]`** — tree step 3.

**Q7b — Does `?id=` expose objects created by *other* users?** (from the triple-AC pass)
*Why it matters:* BR1 restricts the list to a reserved selection and the FAQ sells the
authenticated API as the *confidential* one, implying the public store is not — but the `?id=`
filter is documented as the way to reach "objects you've created", with no ownership scoping
stated and no error shape to hide non-ownership.
*Proposed default:* none — the three governing rules give three different answers.
*Classification:* **`[open]`** — tree step 2/4 (a disclosure/confidentiality policy).
*Consequence:* **not probed and not generated as an executable scenario** — confirming it would
mean reading another party's data. Recorded as an open question for the vendor.

**Q8 — What does a malformed id value do (`?id=abc`, `?id=`, a very long id, `GET /objects/abc`)?**
*Why it matters:* ids are documented as **strings** (BR5) yet every example is numeric — so
"malformed" is not even definable from the contract.
*Proposed default:* non-existent-id behaviour (Q1/Q7), not a distinct `400` class.
*Classification:* **`[assumption]`** — tree step 3.

**Q9 — On `PATCH`, does a supplied `data` key merge into the existing `data` object or replace it wholesale?**
*Why it matters:* it *is* the semantic difference between AC6 and AC7, and the documented example
patches only `name`, never `data` — so the one case that would disambiguate is the one the docs
avoid.
*Proposed default:* top-level field replacement (JSON-Merge-Patch at depth 1): a supplied `data`
replaces the whole `data` object; fields not supplied are preserved.
*Classification:* **`[assumption]`** — tree step 3 (the standard, widely-expected default).
Scenario tagged `@low-confidence` despite the classification, because a wrong answer here is
plausible-but-wrong in the rubric's worst sense.

**Q10 — Do objects created via the public `POST` persist, are they retrievable afterwards, and do they appear in `GET /objects`?**
*Why it matters:* AC1/BR1 exclude user objects from the list, so if `GET /objects/{newId}` also
fails, "creates and stores" (AC4) is unverifiable through the public surface.
*Proposed default:* the object is retrievable by its own id and absent from the reserved list;
retention period unspecified.
*Classification:* **`[assumption]` + `[out-of-slice]`** — tree step 1b for the retention half: the
answer plausibly lives in the authenticated/collections story **S2** (`00-source.md`
`dependencies:`), which this slice does not ingest. Not `answered` (no text in hand), not silently
defaulted.

---

### Answered outright by the source (no question needed)

| Point | Where the source answers it |
|---|---|
| Can a `POST`-created object be fetched via `?id=`? | `Pp[1]`: *"if you want to access multiple objects that you've created, you can use query parameters to retrieve specific objects by their IDs"* |
| Are mutating methods allowed on the public API? | FAQ: *"supported on both public and authenticated APIs"* |
| Is authentication needed to read/write here? | FAQ: *"Public endpoints are open and accessible to anyone"* (so the access boundary is **sourced**, not assumed) |
| Is `data` allowed to be absent/null? | `bp` row `id:"2"` has `data: null` — null is a legal stored value |

### Explicitly **not** raised as questions (and why)

- *"Is this scenario re-runnable without flakiness given the shared mutable catalogue?"* and
  *"can a 50/day quota sustain a regression suite?"* — real concerns, but **automation-design**
  concerns belonging to `automate`/`testbook-generate`, not gaps in what the source specifies.
  Per `need-understanding` step 5 they must not consume a Q-slot. Carried to `synthesis.md` as
  execution constraints instead.
- `99.9 % uptime` (BR4) — a statistical availability claim, unfalsifiable by a bounded functional
  suite. Named, not turned into a question or a scenario.

## Step 7 — Knowledge capture

No reusable business rule was *answered* by a human in this run (every item is `[assumption]` or
`[open]`), so there is nothing to promote via `rag-build`. Recorded rather than skipped.

## Question status summary

| Status | IDs | Count |
|---|---|---|
| `answered` | 4 points, table above | 4 |
| `[assumption]` | Q1, Q3, Q6, Q7, Q8, Q9, Q10 | 7 |
| `[open]` | Q2, Q4, Q5, Q7b | 4 |

⚠ VALIDATION (step 6): **`simulated: proposed defaults applied as stated above`** — non-interactive,
no human available. Every `[open]` remains open and caps the confidence of its scenarios; no
`[open]` was silently downgraded to `[assumption]` to make generation easier. All 11 questions
appear inline in `testbooks/synthesis.md` and in the arbitration list.
