# contract-probe — restful-api.dev public `/objects` surface

Skill: `plugins/qaia-playwright/skills/contract-probe/SKILL.md`
Target: `https://api.restful-api.dev` · Documentation: `https://restful-api.dev/`
Run date: 2026-07-30 · Evidence: `probe/probe-part1.log` … `probe/probe-part4.log`
Requests consumed: **37** of the documented 50/day public quota (budgeted deliberately; quota never exhausted).

---

## 0. Authorization posture — read this first

`contract-probe`'s guardrail says: *"**Self-hosted, authorized targets only** (D35/D26, identical to
`security-surface`) — never a third party you do not own **or are not explicitly authorized to test**."*

restful-api.dev is a third party, **not** self-hosted. The run proceeded on the second limb of that
sentence — explicit owner authorization, quoted from the target's own FAQ:

> "Yes, you can freely use our API for development, testing, and learning."
> "Yes, you can use POST, PUT, PATCH, and DELETE methods to create, update, and delete objects.
> This functionality is supported on both public and authenticated APIs that we provide."

Self-imposed bounds, all honoured:

| Bound | How it was respected |
|---|---|
| No load / DoS shape | 37 sequential requests, no concurrency, no loops |
| No destruction of real data | every mutation targeted an object **this run created**; reserved ids 1-13 were only ever **read** |
| No quota exhaustion | 37 / 50; the rate limit was never probed to its boundary (that would be the DoS shape) |
| No reading third-party data | Q7b (cross-tenant read via `?id=`) deliberately **not** probed |

**This is nonetheless a genuine tension in the SKILL.md, not a settled reading — see finding S1 in
`reports/skill-findings.md`.** The parenthetical "identical to `security-surface`" pulls toward
self-host-only, while the sentence's own text permits explicit authorization. I proceeded, and I am
flagging the ambiguity rather than pretending the guardrail is unambiguous.

---

## 1. Extracted contract (step 1) — checkable promises only

Vague marketing claims were skipped per step 1. "99.9% uptime" and "24/7" are **not** checkable by a
bounded functional probe and were dropped, not faked.

| # | Promise (verbatim) | Source |
|---|---|---|
| C1 | "Support all major HTTP methods: GET, POST, PUT, PATCH and DELETE." | feature grid |
| C2 | "Secure connections via SSL/TLS for **all** API endpoints." | feature grid, "HTTPS Support" |
| C3 | "CORS enabled for all domains" | feature grid / FAQ |
| C4 | list returns `{id,name,data}` with **string** `id`; `data` may be `null` | endpoint `Pp[1]`, constant `bp` |
| C5 | `?id=a&id=b` "includes only the specified objects and **excludes all others**" | `Pp[1]`, param `id` |
| C6 | `?id=` is how you "access multiple objects that **you've created**" | `Pp[1]` description |
| C7 | POST response echoes `name`/`data` and **adds** `id` + `createdAt`, the latter shown as `"2022-11-21T20:06:23.986Z"` | `Pp[3]`, constant `Sp` |
| C8 | "**The data field accepts any valid JSON structure** - objects, arrays, or key-value pairs" | `Pp[3]` (emphasised `<strong><u>`) |
| C9 | PUT "**Completely replaces** the data of an existing object"; response adds `updatedAt` as `"2022-12-25T21:08:41.986Z"` | `Pp[4]`, constant `Cp` |
| C10 | PATCH "applies partial modifications, updating **only** specific fields provided"; documented example leaves `data` untouched | `Pp[5]`, constants `kp`/`Tp` |
| C11 | DELETE "removes an object **permanently**"; response `{"message":"Object with id = 6, has been deleted."}` | `Pp[6]`, constant `Ep` |
| C12 | the `?status=` override is an **authenticated-endpoint** feature (i.e. public endpoints should ignore it) | feature grid, FAQ, `Pp` vs `Ip` param arrays |

---

## 2. Results table (step 6) — one row per probed promise, clean passes included

| Promise | Probe input | Observed | Verdict | Scenario |
|---|---|---|---|---|
| **C1** | GET/POST/PUT/PATCH/DELETE exercised across P1-P35 | all five verbs served | **kept** | — |
| **C2** | `GET http://api.restful-api.dev/objects/7` (P11) | **`HTTP/1.1 200 OK`, full JSON body served in clear**; no redirect; no HSTS header (P36) | **BROKEN** | `@QAIA-CP-001` |
| **C3** | `GET /objects/7` with `Origin: https://example.com` (P10) | `Access-Control-Allow-Origin: *` present | **kept** | — |
| **C4** | `GET /objects` (P1) | array; `"id":"1"` string ids; `id:"2"` carries `"data":null` exactly as documented | **kept** | — |
| **C5** | `GET /objects?id=3&id=5&id=10` (P2) | exactly ids 3, 5, 10 and nothing else | **kept** | — |
| **C6** | `GET /objects?id=<id created at P27>` (P28) | the created object returned | **kept** | — |
| **C7a** | `POST /objects` valid body (P5) | `id` and `createdAt` both added; `name`/`data` echoed | **kept** | — |
| **C7b** | same response, `createdAt` **format** | **`"createdAt":1785452985631`** — epoch-millis *number*, not the documented ISO-8601 *string*. Reproduced on all 8 creations. | **BROKEN** | `@QAIA-CP-002` |
| **C8** | non-ASCII value as raw UTF-8 under `application/json` (P7, P25) | **`400 {"error":"Invalid request body"}`** on well-formed JSON | **BROKEN** (conditional) | `@QAIA-CP-004` |
| **C8** | array / depth-4 / spaced-key payloads (P6, P13, P14) | all `200`, round-tripped structurally identical | **kept** | — |
| **C9a** | `PUT` with `data` omitting `year` and `keep` (P29, P30) | both keys **gone**; `data` == `{"price":99.9}` | **kept** | — |
| **C9b** | `updatedAt` **format** (P29, P31) | `1785453084842` / `1785453085399` — epoch-millis numbers | **BROKEN** | `@QAIA-CP-003` |
| **C10** | `PATCH` with only `name` (P31) | `name` changed, `data` byte-identical | **kept** | — |
| **C11a** | `DELETE` created object (P32) | `{"message":"Object with id = ff80…50ff has been deleted."}` — exactly the documented shape | **kept** | — |
| **C11b** | `GET` after delete (P33) | `404 {"error":"Object with id=… was not found."}` — permanence holds | **kept** | — |
| **C12** | `GET /objects/7?status=401` (P12) | `200` — the override is ignored on the public endpoint, as documented | **kept** | — |

**Score: 12 promises kept, 4 broken.**

---

## 3. Confirmed defects (step 4 — each reproduced, none a one-off)

### D1 — `@QAIA-CP-001` · TLS promise broken · **highest impact**

The docs promise TLS on **all** endpoints; plain HTTP serves the full payload with `200`.
Ranked first because it is the only finding with a security consequence (passive interception of
API traffic) and it contradicts a promise the vendor puts in its own feature grid.
Evidence: `probe-part1.log` P11; absence of HSTS confirmed `probe-part4.log` P36.

### D2 — `@QAIA-CP-002` / `@QAIA-CP-003` · timestamp format contradicts the documented example

`createdAt` / `updatedAt` are documented as ISO-8601 strings and returned as epoch-millis numbers.
A consumer coding against the published example gets a **type error**, not a formatting nuance.
Reproduced on all 8 creations and both updates in this run.

### D3 — `@QAIA-CP-004` · "any valid JSON structure" broken for raw UTF-8

Single-variable isolation (this is why it is a defect and not a guess):

| Probe | Wire bytes | `Content-Type` | Result |
|---|---|---|---|
| P13 | depth-4 nesting, ASCII | `application/json` | **200** |
| P14 | spaced key `"deep key"` | `application/json` | **200** |
| P7, P25 | `"vàleur"` as raw UTF-8 | `application/json` | **400** |
| P26 | `"vàleur"` as raw UTF-8 | `application/json; charset=utf-8` | **200** |
| P35 | `"vàleur"` ASCII escape | `application/json` | **200** |

Only raw-UTF-8-without-an-explicit-charset fails, which points at a server decoding the body as
ISO-8859-1 when the media type carries no charset parameter. RFC 8259 §8.1 requires JSON exchanged
between systems to be UTF-8, and `application/json` defines **no** charset parameter — so the
client's request is correct and the refusal contradicts C8.

---

## 4. Observations that are **not** findings (step 3 discipline)

Reported deliberately, because "differs from what I expected" is not a defect without a broken promise:

- **`POST` with no `name` → `200`, `"name":null`** (P8). The docs never state `name` is required.
  This **answers open question Q3** empirically (the assumption "nameless creation is refused" is
  **wrong**), but it breaks no promise. → It invalidates scenario `@QAIA-RAD-PUBOBJ-012`.
- **404 body shapes are inconsistent**: `{"error":"Object with id=X was not found."}` after a delete
  (P33) vs `{"error":"Object with id = X doesn't exist."}` on a re-delete (P34) — different spacing
  *and* different wording. No error shape is documented at all, so no promise is broken.
- **A third error envelope** appears on `/objects/` with a trailing slash:
  `{"timestamp":…,"status":405,"error":"Method Not Allowed","path":"/objects/"}` — a framework
  default leaking a different schema. Undocumented, so an observation.
- **Non-existent id → `404`** (P4) — **answers Q1**; the assumption was right.
- **Filter matching nothing → `200 []`** (P24) — **answers Q7**; the assumption was right.
- **Object ids created via POST are 32-char hex strings** (`ff8081819f7e10ae019fb54bfdc050ff`), not
  small integers — consistent with the documented `string` type (BR5), so not a defect, but worth
  knowing for any test that assumes numeric ids.

---

## 5. Effect on the spec-first test book (feedback loop)

The probe empirically resolves four items the journey had to carry as assumptions, and falsifies two
generated scenarios. **No file was silently corrected** — this is the evidence a human needs to act on:

| Scenario | Condition | Probe verdict |
|---|---|---|
| `@QAIA-RAD-PUBOBJ-026` (AC10-C1) | plain HTTP serves no API content | **FALSIFIED** — it does (D1) |
| `@QAIA-RAD-PUBOBJ-012` (AC4-C2) | nameless `POST` is refused | **FALSIFIED** — it succeeds with `name:null` |
| `@QAIA-RAD-PUBOBJ-011` (AC4-C1) | `createdAt` in ISO-8601 form | **FALSIFIED** — epoch millis (D2) |
| `@QAIA-RAD-PUBOBJ-009` (AC3-C2) | non-existent id refused `4xx` | **CONFIRMED** — 404 (Q1 answered) |
| `@QAIA-RAD-PUBOBJ-006` (AC2-C3) | empty filter → `200 []` | **CONFIRMED** — (Q7 answered) |
| `@QAIA-RAD-PUBOBJ-017` (AC6-C1) | `PUT` drops omitted keys | **CONFIRMED** |
| `@QAIA-RAD-PUBOBJ-020` (AC7-C1) | `PATCH` preserves `data` | **CONFIRMED** |
| `@QAIA-RAD-PUBOBJ-024/025` (AC8-C2/C3) | delete permanent; re-delete refused | **CONFIRMED** — both 404 |
| `@QAIA-RAD-PUBOBJ-023` (AC8-C1) | delete message names the id | **CONFIRMED** |
| `@QAIA-RAD-PUBOBJ-005` (AC2-C1) | multi-id filter excludes others | **CONFIRMED** |
| `@QAIA-RAD-PUBOBJ-015` (AC5-C1/C2) | array + nested round-trip | **CONFIRMED** |

Open question **Q2** (may the public API mutate reserved ids 1-13?) remains **`[open]`** — deliberately
not probed, because answering it would mean writing to shared demonstration data other learners rely on.

---

## 6. Posture statement

No fix was applied to the target, and none was attempted (`contract-probe` step 5 / `locator-repair`
posture). Four regression scenarios were written to
`testbooks/contract-probe-regressions.feature`; handing them to `automate` is a separate,
user-initiated step. These findings are **advisory** and feed human review — this skill is never a gate.
