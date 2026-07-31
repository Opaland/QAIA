# traffic-replay findings -- fixture/demo-traffic.har

Entries parsed: 111 | Conditions derived: 45

## PII/secret masking summary (type -> placeholder -> count, no ledger, D37)

| Type | Placeholder | Count |
|---|---|---|
| auth-header | `[REDACTED:auth-header]` | 58 |
| card | `[REDACTED:card]` | 3 |
| cookie | `[REDACTED:cookie]` | 27 |
| email | `[REDACTED:email]` | 4 |
| name | `[REDACTED:name]` | 5 |
| phone | `[REDACTED:phone]` | 1115 |
| secret | `[REDACTED:secret]` | 8 |

## Conditions

| ID | Method | Path | Query params | Samples | Status(es) | Response shape (keys:type) | Timing (ms) |
|---|---|---|---|---|---|---|---|
| @QAIA-TRAFFIC-001 | GET | / | - | 2 | 200 (2/2) | non-json | 2957.404, 143.011 |
| @QAIA-TRAFFIC-002 | GET | /node_modules/bootstrap/dist/css/bootstrap.min.css | - | 4 | 200 (3/4), 304 (1/4) | non-json | 158.39100000000002, 1.047, 137.717, 1.041 |
| @QAIA-TRAFFIC-003 | GET | /node_modules/video.js/dist/video-js.min.css | - | 4 | 200 (3/4), 304 (1/4) | non-json | 132.641, 1.022, 138.285, 1.02 |
| @QAIA-TRAFFIC-004 | GET | /css/latofonts.css | - | 4 | 200 (3/4), 304 (1/4) | non-json | 168.953, 1.018, 144.15699999999998, 1.014 |
| @QAIA-TRAFFIC-005 | GET | /css/latostyle.css | - | 4 | 200 (3/4), 304 (1/4) | non-json | 150.108, 1.014, 137.42999999999998, 1.012 |
| @QAIA-TRAFFIC-006 | GET | /imgs/front.jpg | - | 4 | 200 (3/4), 304 (1/4) | non-json | 150.167, 1.022, 145.95399999999998, 1.016 |
| @QAIA-TRAFFIC-007 | GET | /blazemeter-favicon-512x512.png | - | 4 | 200 (3/4), 304 (1/4) | non-json | 164.06900000000002, 1.016, 133.327, 1.014 |
| @QAIA-TRAFFIC-008 | GET | /Samsung1.jpg | - | 2 | 200 (2/2) | non-json | 150.178, 1.018 |
| @QAIA-TRAFFIC-009 | GET | /nexus1.jpg | - | 2 | 200 (2/2) | non-json | 180.03099999999998, 1.016 |
| @QAIA-TRAFFIC-010 | GET | /iphone1.jpg | - | 2 | 200 (2/2) | non-json | 163.897, 1.014 |
| @QAIA-TRAFFIC-011 | GET | /node_modules/jquery/dist/jquery.min.js | - | 4 | 200 (3/4), 304 (1/4) | non-json | 166.90699999999998, 1.018, 144.88899999999998, 1.016 |
| @QAIA-TRAFFIC-012 | GET | /node_modules/video.js/dist/video.min.js | - | 4 | 200 (3/4), 304 (1/4) | non-json | 179.888, 1.018, 137.533, 1.014 |
| @QAIA-TRAFFIC-013 | GET | /node_modules/videojs-contrib-hls/dist/videojs-contrib-hls.min.js | - | 4 | 200 (3/4), 304 (1/4) | non-json | 177.82, 1.016, 147.94199999999998, 1.016 |
| @QAIA-TRAFFIC-014 | GET | /node_modules/tether/dist/js/tether.min.js | - | 4 | 200 (3/4), 304 (1/4) | non-json | 164.918, 1.024, 137.86599999999999, 1.012 |
| @QAIA-TRAFFIC-015 | GET | /node_modules/bootstrap/dist/js/bootstrap.min.js | - | 4 | 200 (3/4), 304 (1/4) | non-json | 167.605, 1.02, 146.797, 1.016 |
| @QAIA-TRAFFIC-016 | GET | /js/index.js | - | 2 | 200 (2/2) | non-json | 173.22500000000002, 1.02 |
| @QAIA-TRAFFIC-017 | GET | /css/fonts/Lato-Regular.woff2 | - | 4 | 200 (4/4) | non-json | 150.458, 1.045, 1.069, 1.06 |
| @QAIA-TRAFFIC-018 | GET | blob:https://www.demoblaze.com/77afbe94-248e-44b8-9e9b-0cb59a4f0bbf | - | 1 *(single sample)* | -1 (1/1) | (no body) | -1 |
| @QAIA-TRAFFIC-019 | GET | /config.json | - | 4 | 200 (4/4) | API_URL:string, HLS_URL:string | 127.186, 0.39499999999999996, 127.35, 0.418 |
| @QAIA-TRAFFIC-020 | GET | /entries | - | 2 | 200 (2/2) | Items:array, LastEvaluatedKey:object | 281.33299999999997, 158.69799999999998 |
| @QAIA-TRAFFIC-021 | GET | /index.m3u8 | - | 4 | 206 (4/4) | non-json | 337.04800000000006, 0.289, 0.262, 0.332 |
| @QAIA-TRAFFIC-022 | GET | /imgs/galaxy_s6.jpg | - | 3 | 200 (2/3), 304 (1/3) | non-json | 147.94, 1.216, 165.69799999999998 |
| @QAIA-TRAFFIC-023 | GET | /imgs/Lumia_1520.jpg | - | 2 | 200 (2/2) | non-json | 154.37199999999999, 1.037 |
| @QAIA-TRAFFIC-024 | GET | /imgs/Nexus_6.jpg | - | 2 | 200 (2/2) | non-json | 162.30599999999998, 1.037 |
| @QAIA-TRAFFIC-025 | GET | /imgs/iphone_6.jpg | - | 2 | 200 (2/2) | non-json | 154.09199999999998, 1.027 |
| @QAIA-TRAFFIC-026 | GET | /imgs/xperia_z5.jpg | - | 2 | 200 (2/2) | non-json | 161.73899999999998, 1.029 |
| @QAIA-TRAFFIC-027 | GET | /imgs/HTC_M9.jpg | - | 2 | 200 (2/2) | non-json | 150.90900000000002, 1.027 |
| @QAIA-TRAFFIC-028 | GET | /imgs/sony_vaio_5.jpg | - | 2 | 200 (2/2) | non-json | 139.04500000000002, 1.027 |
| @QAIA-TRAFFIC-029 | GET | /about_demo_hls_600k.m3u8 | - | 4 | 206 (4/4) | non-json | 227.737, 0.23500000000000001, 0.253, 0.32699999999999996 |
| @QAIA-TRAFFIC-030 | GET | /about_demo_hls_600k00000.ts | - | 4 | 206 (4/4) | non-json | 286.975, 0.40299999999999997, 0.583, 0.45 |
| @QAIA-TRAFFIC-031 | POST | /signup | - | 1 *(single sample)* | 200 (1/1) | json-scalar | 389.656 |
| @QAIA-TRAFFIC-032 | POST | /login | - | 1 *(single sample)* | 200 (1/1) | (no body) | 319.55600000000004 |
| @QAIA-TRAFFIC-033 | GET | blob:https://www.demoblaze.com/cb3d39c7-cb0f-48d4-85b6-c517ad7e0ecc | - | 1 *(single sample)* | -1 (1/1) | (no body) | -1 |
| @QAIA-TRAFFIC-034 | POST | /check | - | 3 | 200 (3/3) | Item:object | 307.087, 158.549, 308.86199999999997 |
| @QAIA-TRAFFIC-035 | GET | /about_demo_hls_2M.m3u8 | - | 3 | 206 (3/3) | non-json | 218.784, 0.475, 0.40399999999999997 |
| @QAIA-TRAFFIC-036 | GET | /prod.html | idp_ | 1 *(single sample)* | 200 (1/1) | non-json | 141.827 |
| @QAIA-TRAFFIC-037 | GET | /js/prod.js | - | 1 *(single sample)* | 200 (1/1) | non-json | 148.181 |
| @QAIA-TRAFFIC-038 | GET | blob:https://www.demoblaze.com/5bbceab1-4833-4086-8761-4c31bd5c7d12 | - | 1 *(single sample)* | -1 (1/1) | (no body) | -1 |
| @QAIA-TRAFFIC-039 | POST | /view | - | 1 *(single sample)* | 200 (1/1) | cat:string, desc:string, id:number, img:string, price:number, title:string | 308.432 |
| @QAIA-TRAFFIC-040 | GET | /cart.html | - | 1 *(single sample)* | 200 (1/1) | non-json | 138.03 |
| @QAIA-TRAFFIC-041 | GET | /node_modules/bootstrap-sweetalert/dist/sweetalert.css | - | 1 *(single sample)* | 200 (1/1) | non-json | 135.917 |
| @QAIA-TRAFFIC-042 | GET | /node_modules/bootstrap-sweetalert/dist/sweetalert.min.js | - | 1 *(single sample)* | 200 (1/1) | non-json | 127.006 |
| @QAIA-TRAFFIC-043 | GET | /js/cart.js | - | 1 *(single sample)* | 200 (1/1) | non-json | 128.645 |
| @QAIA-TRAFFIC-044 | GET | blob:https://www.demoblaze.com/52754b98-d008-4d93-8393-c593ceaf111f | - | 1 *(single sample)* | -1 (1/1) | (no body) | -1 |
| @QAIA-TRAFFIC-045 | POST | /viewcart | - | 1 *(single sample)* | 200 (1/1) | Items:array | 354.397 |

## Known limitations of this run (stated, not hidden)
- Name detection is heuristic and key-based only; a name outside a matched JSON key is not caught.
- Card detection is Luhn-checksum + digit-length based; edge cases are possible (see SKILL.md Guardrails).
- National ID / SSN patterns are not covered in v1.
- Path-template inference (`/api/tasks/{id}`) is deliberately not performed (see SKILL.md Method step 3) -- each literal path is its own signature.
