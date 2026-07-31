---
stepsCompleted: [00-ingest]
lastStep: 00-ingest
lastSaved: 2026-07-30
usId: RAD-PUBOBJ
outputRoot: eval/skill-coverage-wave-2026-07-30/US-EVAL-012-api-first/
---

# 00-source — RAD-PUBOBJ

Skill: `plugins/qaia-core/skills/us-ingest/SKILL.md`

## Source identification (step 1)

| Field | Value |
|---|---|
| Source type | URL (public API documentation site) |
| Designated location | `https://restful-api.dev` |
| Capture date | 2026-07-30 |
| Capture method | `curl -s https://restful-api.dev/` (HTTP 200, 232 854 bytes) + `curl -s https://restful-api.dev/static/js/main.d176a2fe.js` (HTTP 200, 1 071 076 bytes) |
| Reachability check | `curl -s -o /dev/null -w "HTTP %{http_code}"` on `https://api.restful-api.dev/objects` → **HTTP 200**, 0.31 s |

### Why a second fetch on the same origin (traceability, not a substitution)

`restful-api.dev` is a client-rendered React SPA. The server-delivered HTML pre-renders only the
**Authenticated** tab of the "Available Endpoints" section; the **Public** tab — the part this
journey is about — exists only inside the site's own JS bundle
(`/static/js/main.d176a2fe.js`, referenced by `<script src>` in the delivered HTML).

`us-ingest` step 1 forbids substituting or supplementing a JS-rendered source with **other URLs**
("a web search, a different page"). The bundle is **not another source**: it is the same
designated origin's own asset, linked from the designated page, containing the same document's
missing half. No third-party, no search engine, no corroborating blog post was fetched.
This is recorded here so a reviewer can judge the call rather than discover it. See
`reports/skill-findings.md` finding **F1** — the SKILL.md's wording does not cover this case
explicitly, and the honest reading is ambiguous.

## Triage gates (step 2)

| Gate | Result |
|---|---|
| Empty / whitespace only | **Not fired** — 1 484 non-empty text lines extracted. |
| Not a testable requirement | **Not fired** — the source states concrete, checkable behavioral promises per endpoint (method, URL, parameters, response shape, response example, quotas). This is an API specification, i.e. a testable requirement document, not a design doc/RFC/recipe. |
| Abuse / illegality | **Not fired** — target is a public API whose own FAQ states "you can freely use our API for development, testing, and learning" and "you can use POST, PUT, PATCH, and DELETE methods to create, update, and delete objects […] supported on both public and authenticated APIs". Owner-stated authorization to exercise, including mutating methods. |

## Sensitive-data redaction (step 3)

Scan performed on the extracted text.

| Field type | Placeholder | Count |
|---|---|---|
| email | `[REDACTED:email]` | 1 |

Notes:
- The single hit is a **support/contact address of the operating company**, not a real
  individual's personal address. It was masked anyway (conservative reading of rule 5).
- The raw value was **never in hand**: Cloudflare's email obfuscation delivers the string
  already replaced in the served HTML. No mapping original→placeholder is stored anywhere
  (no redaction ledger).
- No national IDs, payment cards, health status, addresses or phone numbers found.
- Sanitization: the extracted text contained U+202F (narrow no-break space) inside
  "3600 seconds". Character preserved, noted here rather than dropped. No control characters
  (U+0000-U+001F) and no bidirectional overrides (U+202A-U+202E, U+2066-U+2069) found.

## Scale / decomposition gate (guardrail)

**Fired.** The source is not one story: it documents two API surfaces.

Constituent stories identified:

| # | Story | In this slice? |
|---|---|---|
| S1 | **Public `/objects` CRUD** — list, list-by-ids, read, create, replace, patch, delete | **YES** |
| S2 | Authenticated `/collections` management (list collections, CRUD objects inside a named collection, `x-api-key`) | no |
| S3 | Authentication — `POST /register`, `POST /login`, JWT, `?auth-type=jwt`, `?expires-in` | no |
| S4 | Response-status override (`?status=401` / `?status=NOT_FOUND`) — documented **only** on authenticated endpoints | no |
| S5 | Quotas / plans (50 public req/day, 100 authenticated req/day, Pro plans) | cross-cutting — kept as a **constraint**, not a story |

⚠ VALIDATION (step 4, US-ID) — **`simulated: US-ID = RAD-PUBOBJ`** (slug from the slice; the
source carries no tracker key). Non-interactive run, no human available. Appears in the
arbitration list.

⚠ VALIDATION (guardrail, which story to process) — **`simulated: S1 (public /objects CRUD) selected`**.
Rationale: it is the only surface exercisable without an account/API key, so it is the only one
this run can also *probe* for real downstream. Appears in the arbitration list.

## dependencies: (sibling-story references, out-of-slice)

- `?status=` override semantics → **S4**. Public `/objects` docs do **not** list this parameter;
  whether it silently applies to public endpoints is undefined in this slice.
- `?auth-type=jwt` → **S3**. Not listed on the public `/objects` endpoints either.
- Object-ID namespace: the docs say the public list returns "a limited, reserved selection […]
  not all stored objects created by you or others", while `?id=` can fetch objects "you've
  created". Where user-created IDs come from and how they relate to the reserved 1-13 range is
  defined nowhere in this slice → depends on **S2**.
- Daily quota enforcement behaviour (status code, body, reset semantics) → **S5**, stated as a
  number only.

The source makes **no INVEST-style independence claim**; none to verify.

## Attachments / referenced artifacts not analyzed

- `https://js.stripe.com/v3/buy-button.js` (Stripe "Support Us" widget) — **not analyzed**, out of scope.
- `/manifest.json` (PWA manifest) — **not analyzed**, no requirement content.
- Site pages linked from the footer: `Home`, `About`, `Contact`, `Privacy Policy`,
  `Rest Fundamentals`, `Support Us` — **not fetched, not analyzed** (guardrail: only the
  designated URL).

## Captured content (redacted, faithful structure)

### Product positioning

> "Real REST API which is ready to handle your HTTP requests 24/7 for free. Can be used for your
> demo projects, testing, learning or even educating someone else"

> "Welcome to our real REST API - a fully functional service backed by a real database. It lets
> you send, store, and retrieve data through real HTTP requests […] It offers both public and
> authenticated access - the public version is open for quick exploration, while the more powerful
> authenticated version unlocks extra features, endpoints, and flexibility"

Stated capabilities (feature grid):
- "Support all major HTTP methods: GET, POST, PUT, PATCH and DELETE."
- "HTTPS Support — Secure connections via SSL/TLS for all API endpoints."
- "Cross-Origin Requests — CORS enabled for all domains, perfect for frontend development."
- "Flexible Resources Schema — Design any data structures and relationships using nested JSON objects for complete flexibility."
- "Overridable Status Codes — **Authenticated endpoints** include an optional feature that lets you override the returned HTTP status code to simulate different responses."
- "Always Available — 99.9% uptime ensures reliable access for testing anytime, anywhere."

### Public endpoint contract (verbatim from the site's own endpoint table, `main.d176a2fe.js`, array `Pp`)

**1. `GET https://api.restful-api.dev/objects` — "List of all objects"**
> "Retrieves a predefined set of sample objects from the public API. This endpoint provides a
> limited, reserved selection available for demonstration purposes - not all stored objects
> created by you or others. However, if you want to access multiple objects that you've created,
> you can use query parameters to retrieve specific objects by their IDs. Alternatively, you can
> sign up and use the authenticated API to access objects from your own collections in a more
> convenient and confidential manner"

Parameters: `id` — `string[]`, query, **optional** —
> "Optional query parameter for specifying one or more object IDs. When provided, the response
> includes only the specified objects and excludes all others. Supports multiple values by
> repeating the parameter in the query string (e.g., `?id=3&id=5&id=10`)"

Documented response example (constant `bp`): a JSON array of 13 objects, ids `"1"`…`"13"` (string
ids), each `{id, name, data}` where `data` is a free-form object — and `id:"2"` has `data: null`.

**2. `GET https://api.restful-api.dev/objects/{id}` — "Single object"**
> "Retrieves detailed information for a single object specified by its unique ID."

Parameters: `id` — `string`, path, **required**.
Documented response example (constant `xp`):
`{"id":"7","name":"Apple MacBook Pro 16","data":{"year":2019,"price":1849.99,"CPU model":"Intel Core i9","Hard disk size":"1 TB"}}`

**3. `POST https://api.restful-api.dev/objects` — "Add a new object"**
> "Creates and stores a new object using the data provided in the request body. The request body
> includes a name property and a data field. **The data field accepts any valid JSON structure**
> - objects, arrays, or key-value pairs - allowing flexible and custom data formats."

Documented request example (constant `wp`):
`{"name":"Apple MacBook Pro 16","data":{"year":2019,"price":1849.99,"CPU model":"Intel Core i9","Hard disk size":"1 TB"}}`
Documented response example (constant `Sp`): same, **plus** `"id":"7"` and
`"createdAt":"2022-11-21T20:06:23.986Z"`.

**4. `PUT https://api.restful-api.dev/objects/{id}` — "Update an object"**
> "Completely replaces the data of an existing object identified by its ID with new information."

Parameters: `id` — `string`, path, **required** — "The ID of the object to update entirely with new data."
Documented request example (constant `jp`): `{"name":"Apple MacBook Pro 16","data":{"year":2019,"price":2049.99,"CPU model":"Intel Core i9","Hard disk size":"1 TB","color":"silver"}}`
Documented response example (constant `Cp`): same, plus `"id":"7"` and `"updatedAt":"2022-12-25T21:08:41.986Z"`.

**5. `PATCH https://api.restful-api.dev/objects/{id}` — "Partially update an object"**
> "Applies partial modifications to an object by updating only specific fields provided in the
> request body."

Parameters: `id` — `string`, path, **required** — "The ID of the object to modify."
Documented request example (constant `kp`): `{"name":"Apple MacBook Pro 16 (Updated Name)"}`
Documented response example (constant `Tp`):
`{"id":"7","name":"Apple MacBook Pro 16 (Updated Name)","data":{"year":2019,"price":1849.99,"CPU model":"Intel Core i9","Hard disk size":"1 TB"},"updatedAt":"2022-12-25T21:09:46.986Z"}`

**6. `DELETE https://api.restful-api.dev/objects/{id}` — "Delete an object"**
> "Removes an object permanently by specifying its unique ID."

Parameters: `id` — `string`, path, **required**.
Documented response example (constant `Ep`): `{"message":"Object with id = 6, has been deleted."}`

**Note (contract asymmetry, faithful to the source):** the public endpoint definitions carry
**no** `status` and **no** `auth-type` parameter. Those two are attached only to the
authenticated endpoint definitions (constants `Op`, `Mp`). Reproduced as found, not harmonized.

### FAQ (verbatim, load-bearing constraints)

> "**Is this API free to use?** Yes, you can freely use our API for development, testing, and
> learning. Each user receives **50 daily requests for the Public API** and 100 daily requests for
> the Authenticated API (reset every 24 hours). For higher limits or advanced features, we also
> offer Pro plans."

> "**Can I modify or delete data?** Yes, you can use POST, PUT, PATCH, and DELETE methods to
> create, update, and delete objects. This functionality is supported on both public and
> authenticated APIs that we provide."

> "**Does the API support CORS?** Yes, the API has CORS (Cross-Origin Resource Sharing) enabled,
> which means you can make requests from any domain, including from your browser-based
> applications and localhost."

> "**Can I override the response status code?** Yes. **Authenticated endpoints** include an
> optional query parameter called `status` […]"

> "**What is the difference between public and authenticated endpoints?** Public endpoints are open
> and accessible to anyone for quick testing and experimentation with the API. In some cases, they
> return predefined data, but in others they also allow you to create and retrieve data created by
> you […]"

Contact address in the FAQ: `[REDACTED:email]`.

Footer: "© 2026 Copyright: restful-api.dev".

## ⚠ VALIDATION (step 6) — right document, right version

**`simulated: accepted`** — non-interactive run. Title "Free Real REST API – Full CRUD Support
(GET, POST, PUT, PATCH, DELETE) for Testing & Learning"; the site publishes no version number or
changelog, so "right version" is **not verifiable** — recorded as such rather than asserted.
Appears in the arbitration list.
