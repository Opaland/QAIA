---
stepsCompleted: [00-ingest, 02-understanding, 03-design]
lastStep: 03-design
lastSaved: 2026-07-30
usId: RAD-PUBOBJ
knowledgeApplied: []
knowledgeBase: absent
---

# 03-design — RAD-PUBOBJ

Skill: `plugins/qaia-core/skills/istqb-design/SKILL.md`
Prerequisite: `02-understanding.md` ✔

Scope reminder (D110/D111): black-box only, from the ACs. QAIA never reads the target's
implementation — here it could not anyway, the target is a closed hosted service.

## Step 1 — AC → technique map, justified

| AC | Shape of the AC | Technique(s) | Justification |
|---|---|---|---|
| AC1 | a fixed reserved catalogue with a documented element shape, one element carrying `data: null` | **Equivalence partitioning** + **Metamorphic testing** | The elements fall into two classes treated identically by the contract (`data` populated / `data: null`) → EP. No ordering, no count and no sort key is promised (see `02-understanding` adversarial pass), so the exact list content cannot be asserted as a literal without fabricating a promise — but the **relation** "the same request twice yields the same set" is checkable without knowing the set → metamorphic, exactly the §3.3.2 case "the exact expected output can't be stated directly […] but a relation between two related inputs/outputs is known". |
| AC2 | an optional repeated filter parameter over the id key | **Equivalence partitioning** + **Boundary value analysis** | Classes: all-ids-known / some-known / none-known / malformed → EP. The *repetition count* of the parameter is a genuine dimension with boundaries: 1 (minimum meaningful), 3 (the documented example), 0 (absent → AC1's unfiltered behaviour) → BVA on the multiplicity, per the documented `?id=3&id=5&id=10`. |
| AC3 | read-by-key | **Equivalence partitioning** + **Error guessing** | Existing / non-existent / malformed key are the three classes. The last two are error paths the source documents not at all, so they are anchored on the ambiguity log (Q1, Q8) — the §3.4.2 checklist use, not free invention. |
| AC4 | creation with a response contract that **adds** fields (`id`, `createdAt`) | **CRUD testing** + **Equivalence partitioning** | The `C` of the full lifecycle pattern → `@crud`. Valid / missing-required / malformed-body / wrong-media-type are the input classes → EP. |
| AC5 | one field (`data`) explicitly promised to accept **any valid JSON structure** | **Domain testing** + **Metamorphic testing** | Several related variables (JSON *type*, nesting *depth*, key *character set*) each carrying their own boundaries and needing combined coverage rather than isolated BVA → Domain Testing (§3.1.1). And the only assertable oracle for "any structure is accepted" is the **round-trip identity relation** (what goes in comes back structurally identical) — a metamorphic relation, since no specific literal is promised for an arbitrary payload. |
| AC6 | complete replacement of an entity's state | **CRUD testing** + **State transition testing** | The `U`(replace) of the lifecycle. The discriminating property is *removal by omission* (a key present before and absent from the `PUT` body must disappear) — a state-to-state transition on the object, not a value check. |
| AC7 | partial modification, preserving what is not supplied | **CRUD testing** + **State transition testing** | The `U`(merge) of the lifecycle; the transition's defining property is what is *preserved*, which only a before/after state comparison can assert. |
| AC8 | permanent removal, with a terminal state | **State transition testing** + **CRUD testing** | `exists → deleted` is a one-edge state machine with a terminal state; the interesting conditions are the *re-entrance* of the terminal state and the transitions forbidden from it. Explicit state × event table built below **before** deriving any condition (CT-MBT discipline, D95). |
| AC9 | a header-level cross-origin promise | **Error guessing / checklist** | Not a data-driven rule; the only checkable form of "CORS enabled for all domains" is the presence of the response header. Checklist item, honestly scoped. |
| AC10 | a transport invariant over *all* endpoints | **Boundary value analysis** | The boundary is the protocol itself: `https` (inside) vs `http` (outside). "All endpoints" makes the negative side the meaningful test. |
| AC11 | a numeric threshold with a time window | **Boundary value analysis** — **derived but deliberately not exercised** | BVA is the right technique (50 / 51, window edges), and it is named here rather than pretended inapplicable. It is **not turned into an executable scenario**: exhausting a shared third party's quota is a DoS-shaped probe forbidden by the shared contract's posture (rule 6, and `contract-probe`/`security-surface`'s bounded-and-non-destructive guardrail). Only an *observational* condition is derived. |

**Techniques from the palette deliberately not used, named rather than silently omitted:**
`@decision-table` (no combination of conditions → actions in this slice: one anonymous role, no
flags — the flags live on the out-of-slice authenticated surface, BR2/BR3), `@pairwise` (no set of
independent parameters large enough to explode; the only multi-valued parameter is `?id=`),
`@use-case` (a journey scenario **is** generated — the `@smoke` CRUD round-trip — and is tagged
`@crud` because the technique actually driving it is the lifecycle pattern; per the palette,
`@use-case`/Scenario-Based is reserved for a journey crossing several *rules*, which this one does
by construction, so both fit — one technique tag is mandatory, `@crud` chosen and justified here),
`@ai-feature` (no AI/ML feature in the target).

## Step 2 — State × event table for AC8 (built first, per D95)

Entity: one public object. Declared states: `absent` (never created / id unknown), `exists`,
`deleted`. Declared events: the five documented methods.

| state \ event | `POST /objects` | `GET /objects/{id}` | `PUT /objects/{id}` | `PATCH /objects/{id}` | `DELETE /objects/{id}` |
|---|---|---|---|---|---|
| **absent** | → `exists` (**documented**, AC4) | **undefined** (Q1) | **undefined** (Q4 — upsert or refuse) | **undefined** (Q1) | **undefined** (Q1) |
| **exists** | n/a (no id in the request) | stays `exists` (**documented**, AC3) | stays `exists`, state replaced (**documented**, AC6) | stays `exists`, state merged (**documented**, AC7) | → `deleted` (**documented**, AC8) |
| **deleted** | n/a | **undefined** (Q1) | **undefined** (Q4) | **undefined** (Q1) | **undefined** (Q1 — terminal re-entrance) |

Reading of the completed table: **6 of the 15 meaningful cells are documented; 9 are undefined.**
The undefined cells are not filled with a convention — each maps to a numbered question, and the
conditions derived from them inherit `[open]`/`[assumption]` accordingly. `deleted` has **no
documented exit edge**: there is no undelete/restore endpoint anywhere in the source, so the
inverse of `DELETE` is a **gap surfaced to the user**, not an invented endpoint.

## Step 3 — Negative pressure (ADR 0001): required-negative conditions

Every rule that can refuse, error or deny → `[req-neg]`. On this contract the refusal paths are
*all* undocumented, which is itself the headline finding: the `[req-neg]` set is derived from the
**shape** of the operations (a keyed operation can always be given a bad key; a body-taking
operation can always be given a bad body), never from a fabricated documented error.

`[req-neg]`: **AC3-C2, AC4-C2, AC4-C3, AC4-C4, AC6-C4, AC7-C4, AC8-C2, AC8-C3, AC10-C1.**

## Step 3b — Standardized domains → oracle

**Applied (inline, oracle-generate not separately invoked).** Two standardized domains are touched:

- **ISO 8601 / RFC 3339 timestamps** — `createdAt` (AC4) and `updatedAt` (AC6/AC7) are documented
  only through examples (`"2022-11-21T20:06:23.986Z"`). The oracle gives the grounded expected
  *form* (date-time, `T` separator, `Z` or numeric offset, optional fractional seconds) without
  fabricating a value. Conditions **AC4-C1** and **AC6-C2** carry `@oracle:iso-8601`.
- **HTTP status codes (RFC 9110)** — used to ground the *classes* asserted on error paths
  (`4xx` = client fault, `5xx` = server fault), which is what lets the negative conditions assert
  something real despite Q1 leaving the exact code open: "a 5xx on a malformed client request is a
  defect regardless of which 4xx is chosen" is a standards-grounded assertion, not a guess.
  Conditions **AC4-C3**, **AC4-C4**, **AC3-C2** carry `@oracle:rfc9110`.

*Honesty note:* `oracle-generate` is a real skill (`plugins/qaia-core/skills/oracle-generate/SKILL.md`)
but was **not** in this run's designated skill list, so its logic was applied inline rather than by
delegation. Recorded so the trace is not misread as a delegated call.

## Step 3c — Systematic coverage expansion (every pattern, applied or waived)

| Pattern | Outcome |
|---|---|
| **List / collection view** — sort | **Applied as a constraint, not as a fabricated sort.** No sort key, no ordering and no size is promised anywhere for `GET /objects`, and the authenticated twin's `limit`/`offset` are explicitly absent from the public definition. Asserting an order would invent a promise. Derived instead: **AC1-C3**, a metamorphic set-stability condition. |
| **List / collection view** — filter | **Applied** → AC2-C1…AC2-C4. |
| **List / collection view** — empty-list state | **Applied** → **AC2-C3** (the 100 %-filtered-out shape, mandated by `02-understanding`'s adversarial pass). |
| **List / collection view** — pagination bounds | **Waived — honest-recall ceiling.** The public list has no pagination parameter. Deriving `?limit=`/`?offset=` conditions here would be inventing an endpoint feature the source assigns to a different (authenticated) surface. Surfaced as a **gap** in `synthesis.md`, not as a scenario. |
| **List / collection view** — state persistence of sort/filter | **Not applicable**: stateless HTTP API, no navigation, no session. |
| **Full CRUD lifecycle beyond create** | **Applied** → AC6 (replace), AC7 (merge), AC8 (delete), plus the `@smoke` round-trip. |
| **Lifecycle inverses (open→close→reopen)** | **Applied, and the inverse is a gap**: `DELETE` has no documented inverse (no undelete). Recorded as a gap; **no restore scenario invented** — this is precisely the #24 "confidently invented mechanism" failure mode the skill warns about. |
| **Cancel mid-operation** | **Not applicable**: single-request operations, no multi-step edit to abandon. |
| **Forbidden transitions** | **Applied** → AC8-C3 (re-entrance of the terminal `deleted` state), derived *from the completed table above*, not opportunistically from prose. |
| **Conditional behaviour (config/feature flag, visibility, ownership)** | **Waived — honest-recall ceiling (a).** The only real flags on this API (`?status=`, `?auth-type=`) are documented **exclusively** on the authenticated surface (BR2, BR3). Generating public scenarios for them would fabricate behaviour. Surfaced as a **gap**; also handed to `contract-probe` as a *probe* target (does the public surface silently honour `?status=`?) — a probe of undocumented behaviour is legitimate there, a generated Gherkin scenario here would not be. |
| **Authorization / server-side enforcement — unauthenticated access** | **Applied, and it is the sourced happy path**: the FAQ states public endpoints are "open and accessible to anyone", so anonymous access is the documented normal mode, not a violation. No `@low-confidence` guessed-auth scenario generated (the access-boundary rule of `need-understanding` step 3). |
| **Authorization — permission denied (wrong role)** | **Not applicable**: exactly one anonymous role in this slice. |
| **Authorization — cross-tenant / IDOR** | **Pattern hit, deliberately not generated.** This is **Q7b** from the triple-AC pass: whether `?id=` exposes another user's object. Confirming it would mean reading a third party's data — outside the authorized, non-destructive posture. Left as an `[open]` question in `synthesis.md`. Recorded rather than silently skipped, because a silent skip on the pattern the skill calls "the most common miss" would be indistinguishable from an oversight. |
| **Authorization — uniqueness/constraint violation** | **Not applicable**: no uniqueness constraint documented on any field (`bp` even shows two objects both named "Apple iPad Mini 5th Gen", ids 10 and 11 — the source itself demonstrates names are not unique). |
| **Authorization — UI bypass** | **Not applicable**: there is no UI; the API *is* the surface. |
| **Enumerate EVERY list/aggregation view** | **Applied**: the public surface exposes exactly one collection (`GET /objects`). The other lists in the document (`GET /collections`, `GET /collections/{name}/objects`) belong to out-of-slice story S2. Checked, not assumed. |
| **Sibling collections of a named entity** | **Applied → gap surfaced.** An object's `data` is free-form and may itself contain arrays (AC5), but the source documents no sub-collection, no child resource and no roll-up for a public object. The "collection" grouping concept exists only on the authenticated surface. Flagged as a boundary of the slice rather than invented here. |
| **Account & auth features → recovery path** | **Not triggered**: this slice has no account, no credential and no session (S3 is out of slice). Named explicitly because the SKILL.md's own guardrail cites this pattern as the one historically skipped without a trace. |

## Step 3d — Knowledge-driven conditions

`knowledge/index.md` sought at the output root and repo root → **knowledge base absent**
(`ls .qaia` → `No such file or directory`). No `BR-KB-nnn` rule retrieved, none invented.
`design.knowledgeApplied` = `[]`. Per the shared contract this is a visible signal that the base is
empty, not that the domain is simple — a project knowledge base would be exactly where "our
consumers must tolerate a 404 body of shape X" would live.

## Step 5 — Derived test conditions

Legend: `[req-neg]` = required negative · `[open]`/`[assumption]` inherited from `02-understanding`.

### AC1 — reserved catalogue listing
| ID | Condition | Technique | Flags |
|---|---|---|---|
| AC1-C1 | `GET /objects` answers `200` with a JSON **array**, every element carrying a **string** `id` and a `name` | `@ep` | — |
| AC1-C2 | an element whose `data` is `null` is returned with `data: null`, not omitted and not coerced to `{}` | `@ep` | — |
| AC1-C3 | two consecutive identical `GET /objects` calls return **the same set of ids** (relation asserted, not the literal set — no ordering or size is promised) | `@metamorphic` | — |
| AC1-C4 | the documented reserved ids remain readable and are not silently mutated by public traffic | `@ep` | `[open] Q2`, `@low-confidence` |

### AC2 — multi-id filtering
| ID | Condition | Technique | Flags |
|---|---|---|---|
| AC2-C1 | `?id=3&id=5&id=10` returns **exactly** those three and **excludes all others** | `@ep` | — |
| AC2-C2 | a single `?id=<n>` returns an array of exactly one element (multiplicity boundary = 1) | `@boundary` | — |
| AC2-C3 | a filter matching **nothing** returns the empty-collection *shape* (`200` + `[]`), not an error | `@boundary` | `[assumption] Q7`, `@low-confidence` |
| AC2-C4 | a malformed id value (`?id=abc`) does not return `5xx` and does not return unrelated objects | `@error-guessing` | `[assumption] Q8`, `@low-confidence` |

### AC3 — single read
| ID | Condition | Technique | Flags |
|---|---|---|---|
| AC3-C1 | `GET /objects/{existing}` returns `200` with `id`, `name`, `data` for that id | `@ep` | — |
| AC3-C2 | `GET /objects/{non-existent}` is **refused** with a client-error status and no object payload | `@error-guessing` | **`[req-neg]`**, `[assumption] Q1`, `@oracle:rfc9110`, `@low-confidence` |
| AC3-C3 | `GET /objects/{malformed}` yields a client-side outcome, never a `5xx` | `@error-guessing` | `[assumption] Q8`, `@low-confidence` |

### AC4 — creation
| ID | Condition | Technique | Flags |
|---|---|---|---|
| AC4-C1 | `POST` with `{name, data}` returns a success status, echoes `name` and `data`, and **adds** a `id` and an ISO-8601 `createdAt` | `@crud` | `@oracle:iso-8601` |
| AC4-C2 | `POST` with **no `name`** is refused with a client-error status | `@crud` | **`[req-neg]`**, `[assumption] Q3`, `@low-confidence` |
| AC4-C3 | `POST` with a **syntactically invalid JSON** body is refused with a **`4xx`, never a `5xx`** | `@error-guessing` | **`[req-neg]`**, `@oracle:rfc9110` |
| AC4-C4 | `POST` with a non-JSON `Content-Type` is refused with a client-error status | `@error-guessing` | **`[req-neg]`**, `@low-confidence` |

### AC5 — "data accepts any valid JSON structure"
| ID | Condition | Technique | Flags |
|---|---|---|---|
| AC5-C1 | `data` as a JSON **array** round-trips structurally identical | `@domain-analysis` | — |
| AC5-C2 | `data` as a **deeply nested** object (depth ≥ 3) round-trips structurally identical | `@domain-analysis` | — |
| AC5-C3 | `data` keys containing spaces / non-ASCII characters round-trip unchanged (the source's own examples already use `"CPU model"`, a spaced key) | `@domain-analysis` | — |
| AC5-C4 | `data` as a **scalar or `null`** is accepted (the reserved set itself contains `data: null`) | `@boundary` | — |

### AC6 — full replacement
| ID | Condition | Technique | Flags |
|---|---|---|---|
| AC6-C1 | after `PUT`, a `data` key that existed before and is **absent from the PUT body is gone** (this is what "completely replaces" means, and the only assertion that distinguishes AC6 from AC7) | `@state-transition` | — |
| AC6-C2 | the `PUT` response carries an ISO-8601 `updatedAt` | `@crud` | `@oracle:iso-8601` |
| AC6-C3 | `PUT` may change `data`'s JSON **shape** (object → array) | `@state-transition` | `[assumption]` (AC5×AC6 cross-pass), `@low-confidence` |
| AC6-C4 | `PUT` on a **non-existent** id: refused rather than silently creating | `@state-transition` | **`[req-neg]`**, `[open] Q4`, `@low-confidence` |

### AC7 — partial modification
| ID | Condition | Technique | Flags |
|---|---|---|---|
| AC7-C1 | `PATCH {"name": …}` changes `name` and leaves the **entire `data` block byte-identical** | `@state-transition` | — |
| AC7-C2 | `PATCH` applied after a `PUT` merges against the **post-PUT** state | `@state-transition` | — |
| AC7-C3 | `PATCH` carrying a `data` key replaces the whole `data` object (depth-1 merge) rather than deep-merging | `@state-transition` | `[assumption] Q9`, `@low-confidence` |
| AC7-C4 | `PATCH` on a **non-existent** id is refused | `@error-guessing` | **`[req-neg]`**, `[assumption] Q1`, `@low-confidence` |

### AC8 — permanent deletion
| ID | Condition | Technique | Flags |
|---|---|---|---|
| AC8-C1 | `DELETE` on an existing object succeeds and returns a message **embedding that object's id** | `@crud` | — |
| AC8-C2 | after `DELETE`, `GET` on the same id is **refused** ("removes permanently") | `@state-transition` | **`[req-neg]`**, `[assumption] Q1`, `@low-confidence` |
| AC8-C3 | a **second** `DELETE` on the same id (terminal-state re-entrance, cell `deleted × DELETE`) is refused, **not** answered with a success message | `@state-transition` | **`[req-neg]`**, `[assumption] Q1`, `@low-confidence` |

*Fold note (anti-inflation, per step 3d's closing rule):* "DELETE on an id that never existed" is
**not** given its own condition — it is not independently observable from AC8-C3 (the `absent ×
DELETE` and `deleted × DELETE` cells are indistinguishable to a client once the object is gone).
Said explicitly rather than defaulted to.

### AC9 / AC10 / AC11 — cross-cutting promises
| ID | Condition | Technique | Flags |
|---|---|---|---|
| AC9-C1 | a cross-origin request carries an `Access-Control-Allow-Origin` response header permitting the caller | `@error-guessing` | — |
| AC10-C1 | a plain-`http://` request to an API endpoint does **not** serve API content (redirected or refused) | `@boundary` | **`[req-neg]`** |
| AC11-C1 | the remaining daily quota is **observable** by the client (rate-limit headers present) — *observational only; the limit is never exhausted on purpose* | `@boundary` | `[open] Q5`, `@low-confidence` |

### Journey
| ID | Condition | Technique | Flags |
|---|---|---|---|
| JRN-C1 | a full public lifecycle — create → read → replace → patch → delete — completes end to end | `@crud` + `@smoke` | excluded from atomicity accounting |

**Totals (counted literally from the tables above, not estimated): 33 atomic conditions + 1 journey
condition = 34.** Of these: **9 `[req-neg]`** (AC3-C2, AC4-C2, AC4-C3, AC4-C4, AC6-C4, AC7-C4,
AC8-C2, AC8-C3, AC10-C1), **3 carrying `[open]`** (AC1-C4/Q2, AC6-C4/Q4, AC11-C1/Q5), **10
carrying `[assumption]`** (AC2-C3, AC2-C4, AC3-C2, AC3-C3, AC4-C2, AC4-C4, AC6-C3, AC7-C3, AC7-C4,
AC8-C2 — AC8-C3 shares Q1 with AC8-C2 and is counted once at the question level).
Per-AC breakdown: AC1=4, AC2=4, AC3=3, AC4=4, AC5=4, AC6=4, AC7=4, AC8=3, AC9=1, AC10=1, AC11=1,
JRN=1.

## Step 4 — ⚠ VALIDATION

**`simulated: map presented, no human amendment available`** — non-interactive run. The AC →
technique map and the 27 conditions are proposed, not approved. Carried to the arbitration list.

## Conditions inheriting `[open]`

AC1-C4 (Q2) · AC6-C4 (Q4) · AC11-C1 (Q5) — **3 conditions**. Q7b (cross-tenant read) has **no
condition by design** (probing it would read a third party's data) and appears in `synthesis.md`
as an open gap instead; it is therefore not counted among the three.
