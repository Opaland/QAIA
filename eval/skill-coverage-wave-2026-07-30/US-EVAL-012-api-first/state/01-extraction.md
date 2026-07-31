---
stepsCompleted: [00-ingest]
lastStep: 01-review
lastSaved: 2026-07-30
usId: RAD-PUBOBJ
status: unconfirmed
gate: pending-validation
---

# 01-extraction — RAD-PUBOBJ (status: **unconfirmed**)

Skill: `plugins/qaia-core/skills/us-review/SKILL.md`
Prerequisite read: `00-source.md` ✔

> **Status `unconfirmed` / gate `pending-validation`** — per `us-review` step 3: this run is
> non-interactive, no human is available to confirm the extraction. This file is therefore
> **not** a "confirmed structure" and `journey.md` carries `01-review = pending-validation`,
> not `done`. See `reports/skill-findings.md` **F2** for the contradiction this creates with
> step 4 and with the shared contract's rule 3, and the reason this run continued past it.

## 1. Story

**`[reconstructed]`** — the source is API reference documentation and contains no
As-a/I-want/So-that phrasing anywhere. It *does* describe a real capability, so per step 1 the
story is reconstructed and marked:

> **As a** developer building or learning against a REST backend,
> **I want** to create, read, replace, partially update and delete free-form JSON objects through
> a public HTTP API without registering,
> **So that** I can prototype, demo or practise API testing against a service that behaves like a
> real production backend.

Grounding for "without registering": *"Public endpoints are open and accessible to anyone for quick
testing and experimentation with the API"* (FAQ).
Grounding for "behaves like a real production backend": *"a fully functional service backed by a
real database […] providing an experience much like working with a production backend"* (Intro).

## 2. Acceptance criteria

Numbers `AC1`…`AC11` are stable from here on (guardrail: never renumbered).

| ID | Acceptance criterion | Source |
|---|---|---|
| **AC1** | `GET /objects` returns **a predefined, reserved selection** of sample objects — *not* all objects stored by any user. Documented response shape: a JSON array of `{id, name, data}`, `id` a **string**, `data` a free-form object that **may be `null`** (example row `id:"2"` has `data: null`). | endpoint `Pp[1]`; response constant `bp` |
| **AC2** | `GET /objects?id=<a>&id=<b>` returns **only the specified objects and excludes all others**. The parameter is `string[]`, optional, and **repeated** in the query string (documented example `?id=3&id=5&id=10`). | endpoint `Pp[1]`, parameter `id` |
| **AC3** | `GET /objects/{id}` returns **detailed information for the single object** with that id. `id` is a **required path** parameter. Documented response: `{"id":"7","name":"Apple MacBook Pro 16","data":{…}}`. | endpoint `Pp[2]`; constant `xp` |
| **AC4** | `POST /objects` with a body carrying `name` and `data` **creates and stores** a new object. The documented response echoes `name` and `data` and **adds** an `id` and a `createdAt` timestamp. | endpoint `Pp[3]`; constants `wp` (request) / `Sp` (response) |
| **AC5** | On `POST /objects`, **"the data field accepts any valid JSON structure — objects, arrays, or key-value pairs"** (emphasised in the source with `<strong><u>`). | endpoint `Pp[3]`, description |
| **AC6** | `PUT /objects/{id}` **completely replaces** the data of the existing object with the new information. Documented response adds an `updatedAt` timestamp (no `createdAt`). | endpoint `Pp[4]`; constants `jp` / `Cp` |
| **AC7** | `PATCH /objects/{id}` **applies partial modifications, updating only the fields provided in the request body**. Documented example: body `{"name":"… (Updated Name)"}` → response keeps the full pre-existing `data` block unchanged and adds `updatedAt`. | endpoint `Pp[5]`; constants `kp` / `Tp` |
| **AC8** | `DELETE /objects/{id}` **removes the object permanently**. Documented response body: `{"message":"Object with id = 6, has been deleted."}` — i.e. a message string embedding the deleted id. | endpoint `Pp[6]`; constant `Ep` |
| **AC9** | **"CORS enabled for all domains"** — requests can be made "from any domain, including from your browser-based applications and localhost". | feature grid; FAQ "Does the API support CORS?" |
| **AC10** | **"Secure connections via SSL/TLS for all API endpoints."** | feature grid |
| **AC11** | Each user gets **50 daily requests for the Public API**, reset every 24 hours. | FAQ "Is this API free to use?" |

## 3. Business rules and constraints found outside the AC list

| ID | Rule | Source |
|---|---|---|
| **BR1** | The public list is explicitly *not* a full store view: *"a limited, reserved selection available for demonstration purposes - not all stored objects created by you or others"*. | `Pp[1]` description |
| **BR2** | The `status` response-override parameter is documented **only for authenticated endpoints** ("Authenticated endpoints include an optional feature…"), and is absent from every public `/objects` parameter list. | feature grid; FAQ; `Pp` vs `Ip` parameter arrays |
| **BR3** | Same for `auth-type`: attached to authenticated endpoint definitions only (constant `Mp`), absent from all six public `/objects` definitions. | `Pp` vs `Ip` |
| **BR4** | *"99.9% uptime"*, *"ready to handle your HTTP requests 24/7"*. | feature grid; hero |
| **BR5** | Object ids are **strings** in every documented response (`"id":"7"`), including in the list where the documented `bp` rows use `id:"1"`…`"13"`. | constants `bp`, `xp`, `Sp`, `Cp`, `Tp` |
| **BR6** | Mutating methods are explicitly permitted on the public API: *"you can use POST, PUT, PATCH, and DELETE methods […] supported on both public and authenticated APIs"*. | FAQ |

## 4. Referenced artifacts not analyzed

- Stripe "Support Us" buy-button script (`js.stripe.com/v3/buy-button.js`).
- `/manifest.json` (PWA manifest).
- Footer pages: `Home`, `About`, `Contact`, `Privacy Policy`, `Rest Fundamentals`, `Support Us` — not fetched.
- The authenticated surface (`/collections/*`, `/register`, `/login`) — read but **deliberately out of slice** (S2/S3/S4 in `00-source.md`).

## 5. Present in the source but not classifiable

- *"Design any data structures and relationships using nested JSON objects for complete flexibility"* — the words **"and relationships"** promise something (inter-object relationships) that no endpoint, parameter or response field in the whole document supports. Kept visible here rather than dropped; feeds Q6.
- *"Free Real REST API"* / *"much like working with a production backend"* — positioning prose, not checkable.

## 6. Diff mentality — what I did **NOT** find (step 2)

This is the load-bearing half of this extraction. The source is a *happy-path-only* contract.

1. **No error contract whatsoever.** Not one status code is documented for any public endpoint —
   no `200`, no `201`, no `404`, no `400`, no `405`, no `415`, no `429`. The only status code
   literal anywhere on the page is inside the *authenticated* `?status=401` example. The `// 200 OK`
   comment in the hero code sample is decoration on one illustrative snippet, not part of any
   endpoint definition.
2. **No required/optional marking on request bodies.** `POST` shows `name` and `data` in an example;
   nothing states whether either is mandatory, or what happens if `name` is missing/empty/non-string.
3. **No validation rules at all** — no max length on `name`, no max depth/size on `data`, no
   character-set rule, no uniqueness rule.
4. **No behaviour for a non-existent id** on `GET`, `PUT`, `PATCH` or `DELETE`.
5. **No behaviour for a malformed body** (invalid JSON, wrong `Content-Type`).
6. **No rate-limit response contract** — AC11 gives a number (50/day) and nothing else: no status
   code, no headers, no body, no definition of "each user" (IP? API key? browser?), no reset anchor
   (rolling 24 h vs calendar day).
7. **No AC numbering in the source** — every AC number above is QAIA's, not the vendor's.
8. **No versioning** — no API version, no changelog, no `/v1` prefix, no date on the contract.
9. **No statement about whether the reserved objects 1-13 are mutable** by the public API, even
   though BR6 permits mutation and AC1 says the list is "reserved […] for demonstration purposes".
10. **No pagination** on the public list (`limit`/`offset` exist only on the authenticated
    collection endpoint) — and no statement of the list's size or ordering.
11. **No `PUT`-on-absent-id semantics** (create-or-fail), the classic REST divergence.
12. **No lifetime/retention statement** for objects created via the public API.

Nothing was invented to fill any of these — each becomes a question in `02-understanding.md`.

## 7. ⚠ VALIDATION (step 3)

**NOT marked done.** Non-interactive context, no user available. Per `us-review` step 3 the
extraction is left `unconfirmed`, `01-review` stays `pending-validation` in `journey.md`, and no
`simulated: accepted` shortcut is recorded here — the corrected clause forbids exactly that.
Carried into the arbitration list of `testbooks/synthesis.md`.
