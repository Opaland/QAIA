# traffic-replay findings -- fixture/demo-traffic.har

Entries parsed: 15 | Conditions derived: 15

## PII/secret masking summary (type -> placeholder -> count, no ledger, D37)

| Type | Placeholder | Count |
|---|---|---|
| auth-header | `[REDACTED:auth-header]` | 13 |
| cookie | `[REDACTED:cookie]` | 6 |
| name | `[REDACTED:name]` | 10 |
| phone | `[REDACTED:phone]` | 383 |
| query-token | `[REDACTED:query-token]` | 2 |

## Conditions

| ID | Method | Path | Query params | Samples | Status(es) | Response shape (keys:type) | Timing (ms) |
|---|---|---|---|---|---|---|---|
| @QAIA-TRAFFIC-001 | GET | / | - | 1 *(single sample)* | 200 (1/1) | non-json | 68.142 |
| @QAIA-TRAFFIC-002 | GET | /css2 | family,family | 1 *(single sample)* | 200 (1/1) | non-json | 135.829 |
| @QAIA-TRAFFIC-003 | GET | /assets/index-XyuNVFOR.js | - | 1 *(single sample)* | 200 (1/1) | non-json | 23.086 |
| @QAIA-TRAFFIC-004 | GET | /assets/index-Co7SA-g_.css | - | 1 *(single sample)* | 200 (1/1) | non-json | 11.065 |
| @QAIA-TRAFFIC-005 | POST | /api/unique-events/submit | token,universe | 1 *(single sample)* | 401 (1/1) | error:object | 677.745 |
| @QAIA-TRAFFIC-006 | POST | /api/summed-events/submit | token,universe | 1 *(single sample)* | 401 (1/1) | error:object | 658.5160000000001 |
| @QAIA-TRAFFIC-007 | GET | /s/dmsans/v17/rP2Yp2ywxg089UriI5-g4vlH9VoD8Cmcqbu0-K4.woff2 | - | 1 *(single sample)* | 200 (1/1) | non-json | 126.968 |
| @QAIA-TRAFFIC-008 | GET | /s/dmmono/v16/aFTU7PB1QTsUX8KYthqQBA.woff2 | - | 1 *(single sample)* | 200 (1/1) | non-json | 42.84 |
| @QAIA-TRAFFIC-009 | GET | /s/dmmono/v16/aFTR7PB1QTsUX8KYvumzEYOtbQ.woff2 | - | 1 *(single sample)* | 200 (1/1) | non-json | 46.019999999999996 |
| @QAIA-TRAFFIC-010 | GET | /assets/sauce-backpack-1200x1500-CjRW-Djj.jpg | - | 1 *(single sample)* | 200 (1/1) | non-json | 8.509 |
| @QAIA-TRAFFIC-011 | GET | /assets/bike-light-1200x1500-DxcZRFOA.jpg | - | 1 *(single sample)* | 200 (1/1) | non-json | 8.649000000000001 |
| @QAIA-TRAFFIC-012 | GET | /assets/bolt-shirt-1200x1500-mR0ldpVS.jpg | - | 1 *(single sample)* | 200 (1/1) | non-json | 8.736 |
| @QAIA-TRAFFIC-013 | GET | /assets/sauce-pullover-1200x1500-BfbI-PSd.jpg | - | 1 *(single sample)* | 200 (1/1) | non-json | 9.41 |
| @QAIA-TRAFFIC-014 | GET | /assets/red-onesie-1200x1500-BrSuq0ic.jpg | - | 1 *(single sample)* | 200 (1/1) | non-json | 9.203 |
| @QAIA-TRAFFIC-015 | GET | /assets/red-tatt-1200x1500-E-qp6aYf.jpg | - | 1 *(single sample)* | 200 (1/1) | non-json | 9.361 |

## Known limitations of this run (stated, not hidden)
- Name detection is heuristic and key-based only; a name outside a matched JSON key is not caught.
- Card detection is Luhn-checksum + digit-length based; edge cases are possible (see SKILL.md Guardrails).
- National ID / SSN patterns are not covered in v1.
- Path-template inference (`/api/tasks/{id}`) is deliberately not performed (see SKILL.md Method step 3) -- each literal path is its own signature.
