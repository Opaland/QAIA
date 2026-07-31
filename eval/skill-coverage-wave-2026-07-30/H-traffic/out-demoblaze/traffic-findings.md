# traffic-replay findings -- fixture/demo-traffic.har

Entries parsed: 64 | Conditions derived: 35

## PII/secret masking summary (type -> placeholder -> count, no ledger, D37)

| Type | Placeholder | Count |
|---|---|---|
| auth-header | `[REDACTED:auth-header]` | 43 |
| card | `[REDACTED:card]` | 1 |
| cookie | `[REDACTED:cookie]` | 16 |
| email | `[REDACTED:email]` | 2 |
| name | `[REDACTED:name]` | 3 |
| phone | `[REDACTED:phone]` | 420 |
| secret | `[REDACTED:secret]` | 4 |

## Conditions

| ID | Method | Path | Query params | Samples | Status(es) | Response shape (keys:type) | Timing (ms) |
|---|---|---|---|---|---|---|---|
| @QAIA-TRAFFIC-001 | GET | / | - | 2 | 200 (2/2) | non-json | 289.08500000000004, 26.69 |
| @QAIA-TRAFFIC-002 | GET | /node_modules/bootstrap/dist/css/bootstrap.min.css | - | 2 | 200 (1/2), 304 (1/2) | non-json | 49.313, 142.55100000000002 |
| @QAIA-TRAFFIC-003 | GET | /node_modules/video.js/dist/video-js.min.css | - | 2 | 200 (1/2), 304 (1/2) | non-json | 46.894000000000005, 148.392 |
| @QAIA-TRAFFIC-004 | GET | /css/latofonts.css | - | 2 | 200 (2/2) | non-json | 153.169, 1.056 |
| @QAIA-TRAFFIC-005 | GET | /css/latostyle.css | - | 2 | 200 (1/2), 304 (1/2) | non-json | 47.14, 141.703 |
| @QAIA-TRAFFIC-006 | GET | /imgs/front.jpg | - | 2 | 200 (2/2) | non-json | 162.915, 1.046 |
| @QAIA-TRAFFIC-007 | GET | /blazemeter-favicon-512x512.png | - | 2 | 200 (2/2) | non-json | 147.90200000000002, 1.038 |
| @QAIA-TRAFFIC-008 | GET | /Samsung1.jpg | - | 2 | 200 (2/2) | non-json | 137.33499999999998, 1.04 |
| @QAIA-TRAFFIC-009 | GET | /nexus1.jpg | - | 2 | 200 (1/2), 304 (1/2) | non-json | 72.81099999999999, 142.829 |
| @QAIA-TRAFFIC-010 | GET | /iphone1.jpg | - | 2 | 200 (2/2) | non-json | 144.83700000000002, 1.05 |
| @QAIA-TRAFFIC-011 | GET | /node_modules/jquery/dist/jquery.min.js | - | 2 | 200 (1/2), 304 (1/2) | non-json | 63.663, 143.72899999999998 |
| @QAIA-TRAFFIC-012 | GET | /node_modules/video.js/dist/video.min.js | - | 2 | 200 (2/2) | non-json | 162.327, 1.086 |
| @QAIA-TRAFFIC-013 | GET | /node_modules/videojs-contrib-hls/dist/videojs-contrib-hls.min.js | - | 2 | 200 (1/2), 304 (1/2) | non-json | 74.259, 29.645 |
| @QAIA-TRAFFIC-014 | GET | /node_modules/tether/dist/js/tether.min.js | - | 2 | 200 (2/2) | non-json | 163.79, 1.223 |
| @QAIA-TRAFFIC-015 | GET | /node_modules/bootstrap/dist/js/bootstrap.min.js | - | 2 | 200 (1/2), 304 (1/2) | non-json | 76.676, 139.23 |
| @QAIA-TRAFFIC-016 | GET | /js/index.js | - | 2 | 200 (1/2), 304 (1/2) | non-json | 57.54, 145.933 |
| @QAIA-TRAFFIC-017 | GET | /css/fonts/Lato-Regular.woff2 | - | 2 | 200 (2/2) | non-json | 155.55599999999998, 1.077 |
| @QAIA-TRAFFIC-018 | GET | blob:https://www.demoblaze.com/a9821d05-c14e-4cdf-bf1b-e79b63d8d40b | - | 1 *(single sample)* | -1 (1/1) | (no body) | -1 |
| @QAIA-TRAFFIC-019 | GET | /config.json | - | 2 | 200 (2/2) | API_URL:string, HLS_URL:string | 127.519, 0.5700000000000001 |
| @QAIA-TRAFFIC-020 | GET | /entries | - | 2 | 200 (2/2) | Items:array, LastEvaluatedKey:object | 289.501, 155.82999999999998 |
| @QAIA-TRAFFIC-021 | GET | /index.m3u8 | - | 2 | 206 (2/2) | non-json | 323.16600000000005, 0.649 |
| @QAIA-TRAFFIC-022 | GET | /imgs/galaxy_s6.jpg | - | 2 | 200 (2/2) | non-json | 160.178, 1.568 |
| @QAIA-TRAFFIC-023 | GET | /imgs/Lumia_1520.jpg | - | 2 | 200 (2/2) | non-json | 147.87900000000002, 1.274 |
| @QAIA-TRAFFIC-024 | GET | /imgs/Nexus_6.jpg | - | 2 | 200 (2/2) | non-json | 35.69, 1.276 |
| @QAIA-TRAFFIC-025 | GET | /imgs/iphone_6.jpg | - | 2 | 200 (2/2) | non-json | 163.227, 1.271 |
| @QAIA-TRAFFIC-026 | GET | /imgs/xperia_z5.jpg | - | 2 | 200 (2/2) | non-json | 144.273, 1.26 |
| @QAIA-TRAFFIC-027 | GET | /imgs/HTC_M9.jpg | - | 2 | 200 (2/2) | non-json | 160.32, 1.347 |
| @QAIA-TRAFFIC-028 | GET | /imgs/sony_vaio_5.jpg | - | 2 | 200 (2/2) | non-json | 140.685, 1.295 |
| @QAIA-TRAFFIC-029 | GET | /about_demo_hls_600k.m3u8 | - | 2 | 206 (2/2) | non-json | 209.526, 0.373 |
| @QAIA-TRAFFIC-030 | GET | /about_demo_hls_600k00000.ts | - | 2 | 206 (2/2) | non-json | 281.376, 0.7190000000000001 |
| @QAIA-TRAFFIC-031 | POST | /signup | - | 1 *(single sample)* | 200 (1/1) | json-scalar | 354.26099999999997 |
| @QAIA-TRAFFIC-032 | POST | /login | - | 1 *(single sample)* | 200 (1/1) | (no body) | 319.829 |
| @QAIA-TRAFFIC-033 | GET | blob:https://www.demoblaze.com/76fdaecd-fb88-461d-821d-3636a6665ce6 | - | 1 *(single sample)* | -1 (1/1) | (no body) | -1 |
| @QAIA-TRAFFIC-034 | POST | /check | - | 1 *(single sample)* | 200 (1/1) | Item:object | 287.113 |
| @QAIA-TRAFFIC-035 | GET | /about_demo_hls_2M.m3u8 | - | 1 *(single sample)* | 206 (1/1) | non-json | 38.736999999999995 |

## Known limitations of this run (stated, not hidden)
- Name detection is heuristic and key-based only; a name outside a matched JSON key is not caught.
- Card detection is Luhn-checksum + digit-length based; edge cases are possible (see SKILL.md Guardrails).
- National ID / SSN patterns are not covered in v1.
- Path-template inference (`/api/tasks/{id}`) is deliberately not performed (see SKILL.md Method step 3) -- each literal path is its own signature.
