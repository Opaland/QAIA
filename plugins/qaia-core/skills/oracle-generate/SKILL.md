---
name: oracle-generate
description: Use known standards as test oracles to generate grounded test cases and their correct expected results - Luhn for card numbers, ISO 8601 dates, HTTP status codes, RFC 5322 email, ISO 4217 currencies, IBAN - plus an opt-in project oracle that derives endpoint conditions and expected statuses from a user-designated OpenAPI/Swagger or JSON Schema file. Feeds istqb-design and testbook-generate. Bounded, provenance-tagged. Use when a US touches a standardized domain or has an API contract.
---

# oracle-generate — standards as generation oracles

When a requirement touches a **standardized domain**, do not guess the edge cases or the expected results — derive them from the standard (the *oracle*). The oracle supplies both **test conditions** (for `istqb-design`) and **correct `Then` values** (for `testbook-generate`), grounded and cited — never invented.

## Built-in oracle library (no network — encoded knowledge)

Load the reference file `oracles/library.md` in this skill directory. It defines, per standard, the canonical valid/invalid cases and expected outcomes:

| Domain trigger in the US | Oracle | Supplies |
|---|---|---|
| card / PAN / payment number | **Luhn** | valid test PANs, invalid checksums, per-network lengths → valid/invalid + expected result |
| date / deadline / expiry | **ISO 8601** | leap years, 29 Feb, 30/31 boundaries, timezones, week dates |
| email address | **RFC 5322** | canonical valid + invalid corpus |
| HTTP / REST / status code | **HTTP semantics** | correct status per condition (400/401/403/404/409/422…) as expected `Then` |
| currency code | **ISO 4217** | valid codes, invalid, minor-unit rules |
| country code | **ISO 3166** | alpha-2/alpha-3 valid/invalid |
| IBAN / bank account | **IBAN mod-97** | valid/invalid checksums, per-country length |

## Project oracle — OpenAPI / JSON Schema (bounded, opt-in) — issue #16

For project-specific truth, the user may designate **ONE** source — an OpenAPI/Swagger document
(`.yaml`/`.json`) or a JSON Schema. Its **documented** contract becomes the oracle for those
endpoints: the expected results come from the spec, not from extrapolation. The full extraction
mapping is in `oracles/openapi.md` (load it when a project oracle is in play).

**Before extracting anything (issue #25 — measured on 3 real specs, 2 degenerated silently):**
resolve every internal `$ref` first (an unresolved `$ref` reads as "no constraints", silently
dropping required-field negatives — never fetch external `$ref`s or the live API, only follow
pointers within the same document); then check the spec's overall health — if it documents
**zero** 4xx/5xx responses anywhere, or declares mutating operations
(`POST`/`PUT`/`PATCH`/`DELETE`) with **zero** declared auth anywhere, say so explicitly to the
user as an **under-documented spec** before presenting the (near-empty) result — a near-zero
oracle output must never silently read as "passed, your API is covered."

In short, per operation (`path` + method):

- **Documented responses → expected `Then` status.** Each status in `responses` is an oracle
  (`200/201/400/401/403/404/409/422/429…`). A negative condition asserts the documented error
  status for its trigger. **An error path the spec does not document stays `[open]`** — never
  invent a status the contract does not declare.
- **`requestBody.required[]` → missing-field negatives.** Each required field omitted → the
  documented rejection status (usually `400`/`422`). One condition per required field.
- **Schema constraints → boundaries & partitions.** `enum` (an out-of-enum value → rejection),
  `minLength/maxLength`, `minimum/maximum`/`exclusive*` (boundary value ±1), `pattern`
  (matching/non-matching) — each a grounded condition with the spec's expected outcome.
- **`format` chains into the built-in oracles.** `format: date-time` → the ISO 8601 case set;
  `format: email` → RFC 5322; `format: uuid`, etc. The project oracle supplies the endpoint and
  status; the built-in oracle supplies the value edge cases — cited together.
- **`security` present on an operation → unauthenticated → `401`** condition (and a scope
  mismatch → `403` when scopes are declared).

**Bounds (non negotiable):** only the single user-designated file is read — never arbitrary web,
never a `$ref` to an external URL (an external `$ref` that cannot be resolved from the local file
is reported, not fetched). Every derived case is tagged `@oracle:openapi` with a
`# oracle: openapi <operationId|path+method> <field/status>` comment. If the spec is silent on a
point, it stays `[open]`; if the spec **contradicts** the US, surface it as a question — the US
wins on business intent, the spec grounds the API shape.

## Steps

1. **Detect** standardized domains in `01-extraction.md` / `03-design.md`. For each, name the applicable oracle.
2. ⚠ VALIDATION: propose the oracle-derived cases to the user (e.g. "for card validation I can add the Luhn valid/invalid test set — accept?"). The oracle *proposes*; the human arbitrates.
3. **Emit** the accepted cases into the design conditions and, at generation, into scenarios — each tagged `@oracle:<standard>` and carrying a `# oracle: <ref>` comment. The expected result comes from the standard, not from extrapolation.
4. **Record** provenance in `03-design.md` and the synthesis ("negative cases X, Y grounded in Luhn, not fabricated") — this raises negative-path coverage (ADR 0001) without fabrication.

## Guardrails

- **Never invent.** If no oracle covers a point, it stays `[open]` — an oracle is a citation, not a guess.
- **Provenance mandatory.** Every oracle-derived case cites its standard; it is never presented as a requirement of the US itself.
- **Bounded network.** Built-in oracles need no network. A project oracle reads only the single user-designated source. No arbitrary web access.
- Oracle-derived cases still respect atomicity, priority and confidence rules like any scenario.
