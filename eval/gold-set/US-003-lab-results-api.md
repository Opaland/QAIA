# US-003 — Lab results REST API

> Gold set item. Original synthetic content (clean-room), MIT-licensed. Domain: health interoperability, API. Exercises role-based access, state transitions, and API-level test design.
> Deliberate ambiguities listed at the bottom for judge reference only.

## User story

**As an** authorized third-party application,
**I want** to retrieve a patient's laboratory results through a REST API,
**so that** practitioners using my application can consult results without switching systems.

## Acceptance criteria

1. `GET /patients/{id}/lab-results` requires a valid OAuth2 bearer token; requests without a token or with an expired token receive `401`.
2. Tokens carry a scope: `results:read:own` limits access to patients under the requesting practitioner's care; `results:read:org` grants access to all patients of the organization. Out-of-scope access receives `403`.
3. A result document goes through states: `pending` → `partial` → `final` → possibly `corrected`. Only `final` and `corrected` results are returned by default; `partial` results are included only with the query parameter `include=preliminary`.
4. Results marked with the confidentiality flag `restricted` are never returned to `results:read:org` tokens — only to the patient's own practitioner (`results:read:own`), and each such access is written to the audit trail.
5. The response is paginated (default 20, maximum 100 items per page) and sorted by sampling date descending; an out-of-range page returns an empty list, not an error.
6. Requesting a patient id that does not exist or is not visible to the token's scope returns `404` (indistinguishable, to avoid patient-existence disclosure).
7. When a `corrected` result is returned, the response must reference the identifier of the result it supersedes.
8. The endpoint answers within 800 ms at the 95th percentile for pages of 20 results (informative, non-blocking for functional tests).

## Judge reference — planted ambiguities (do not feed to skills)

- AC3: can a result move from `final` to `corrected` more than once (chain of corrections)? Not specified.
- AC4: does the patient-existence-disclosure rule of AC6 also apply when ALL of a patient's results are `restricted` and the token is `org`-scoped — empty list or 404? Contradiction left open between AC4, AC5 and AC6.
- AC1/2: token *revocation* (as opposed to expiry) is never mentioned.
- AC5: sort order for identical sampling dates is unspecified.
