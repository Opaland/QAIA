#!/usr/bin/env bash
# contract-probe — restful-api.dev public /objects surface
# Posture: bounded (~20 requests, no concurrency, no load shape), non-destructive
# (every mutation targets an object THIS script creates; reserved ids 1-13 are never
# written to), no quota exhaustion. Owner authorization is quoted in the report.
API=https://api.restful-api.dev
OUT="$(dirname "$0")"

req() { # req <label> <curl args...>
  local label="$1"; shift
  echo "===== $label"
  echo "--- request: curl $*"
  curl -s -S -D /tmp/h.txt -o /tmp/b.txt -w 'HTTP_STATUS=%{http_code} TIME=%{time_total}s\n' "$@"
  echo "--- response headers:"; sed -n '1,12p' /tmp/h.txt
  echo "--- response body (first 900 bytes):"; head -c 900 /tmp/b.txt; echo
  echo
}

{
echo "PROBE RUN $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo

# --- P1: GET /objects  (promise: array of {id,name,data}; id is a string; data may be null)
req "P1 GET /objects" "$API/objects"

# --- P2: multi-id filter (promise: "includes only the specified objects and excludes all others")
req "P2 GET /objects?id=3&id=5&id=10" "$API/objects?id=3&id=5&id=10"

# --- P3: single read (promise: detailed info for that single object)
req "P3 GET /objects/7" "$API/objects/7"

# --- P4: non-existent id (NO documented promise — observation only)
req "P4 GET /objects/999999999" "$API/objects/999999999"

# --- P5: create (promise: echoes name+data, ADDS id and createdAt)
req "P5 POST /objects" -X POST "$API/objects" -H 'Content-Type: application/json' \
  -d '{"name":"QAIA probe object","data":{"year":2026,"price":10.5,"CPU model":"probe"}}'

# --- P6: AC5 headline promise, data = ARRAY
req "P6 POST /objects data=array" -X POST "$API/objects" -H 'Content-Type: application/json' \
  -d '{"name":"QAIA probe array","data":[1,"two",{"three":3},null]}'

# --- P7: AC5, deeply nested + spaced/non-ASCII keys
req "P7 POST /objects data=nested" -X POST "$API/objects" -H 'Content-Type: application/json' \
  -d '{"name":"QAIA probe nested","data":{"l1":{"l2":{"l3":{"deep key":"vàleur","n":[1,2,3]}}}}}'

# --- P8: POST with no name (NO documented promise — observation only)
req "P8 POST /objects no name" -X POST "$API/objects" -H 'Content-Type: application/json' \
  -d '{"data":{"a":1}}'

# --- P9: POST malformed JSON (NO documented promise — observation only)
req "P9 POST /objects malformed JSON" -X POST "$API/objects" -H 'Content-Type: application/json' \
  -d '{"name": "unterminated'

# --- P10: CORS (promise: "CORS enabled for all domains")
req "P10 GET /objects with Origin" "$API/objects/7" -H 'Origin: https://example.com'

# --- P11: TLS (promise: "Secure connections via SSL/TLS for all API endpoints")
req "P11 plain HTTP" -i "http://api.restful-api.dev/objects/7"

# --- P12: ?status= override on a PUBLIC endpoint (documented as AUTHENTICATED-only, BR2)
req "P12 GET /objects/7?status=401" "$API/objects/7?status=401"
} > "$OUT/probe-part1.log" 2>&1

echo "part1 done"
