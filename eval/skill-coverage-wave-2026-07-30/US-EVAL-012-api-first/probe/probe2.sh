#!/usr/bin/env bash
# contract-probe part 2 — lifecycle promises + minimal isolation of the P7 400.
# Non-destructive: every mutation below targets an object created by this script.
API=https://api.restful-api.dev
OUT="$(dirname "$0")"

req() {
  local label="$1"; shift
  echo "===== $label"
  echo "--- request: curl $*"
  curl -s -S -o /tmp/b2.txt -w 'HTTP_STATUS=%{http_code}\n' "$@"
  echo "--- body:"; head -c 900 /tmp/b2.txt; echo; echo
}

{
echo "PROBE RUN PART 2 $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo

# ---- Isolate the P7 400: three single-variable probes (depth / spaced key / non-ASCII)
req "P13 depth-4 nesting, pure ASCII keys" -X POST "$API/objects" -H 'Content-Type: application/json' \
  -d '{"name":"QAIA depth","data":{"l1":{"l2":{"l3":{"l4":"v"}}}}}'

req "P14 spaced key (docs use 'CPU model')" -X POST "$API/objects" -H 'Content-Type: application/json' \
  -d '{"name":"QAIA spaced","data":{"deep key":"value"}}'

req "P15 non-ASCII VALUE, escaped \\u00e0" -X POST "$API/objects" -H 'Content-Type: application/json' \
  -d '{"name":"QAIA nonascii","data":{"k":"vàleur"}}'

# ---- Lifecycle on an object this script creates
echo "===== P16 POST create lifecycle object"
curl -s -S -o /tmp/created.json -w 'HTTP_STATUS=%{http_code}\n' -X POST "$API/objects" \
  -H 'Content-Type: application/json' \
  -d '{"name":"QAIA lifecycle","data":{"year":2026,"price":10.5,"keep":"me"}}'
cat /tmp/created.json; echo
ID=$(python -c "import json;print(json.load(open('/tmp/created.json'))['id'])")
echo "CREATED_ID=$ID"
echo

# ---- documented promise: ?id= is how you access objects you've created
req "P17 GET /objects?id=$ID (created object via filter)" "$API/objects?id=$ID"

# ---- AC6-C1: "Completely replaces" -> a key omitted from the PUT body must disappear
req "P18 PUT $ID replacing data with only {price}" -X PUT "$API/objects/$ID" \
  -H 'Content-Type: application/json' \
  -d '{"name":"QAIA lifecycle","data":{"price":99.9}}'

req "P19 GET $ID after PUT (did 'year'/'keep' disappear?)" "$API/objects/$ID"

# ---- AC7-C1: PATCH name only -> data block must be untouched
req "P20 PATCH $ID name only" -X PATCH "$API/objects/$ID" \
  -H 'Content-Type: application/json' -d '{"name":"QAIA lifecycle patched"}'

# ---- AC8-C1: DELETE returns a message naming the id
req "P21 DELETE $ID" -X DELETE "$API/objects/$ID"

# ---- AC8-C2: "removes permanently" -> follow-up read
req "P22 GET $ID after DELETE" "$API/objects/$ID"

# ---- AC8-C3: terminal-state re-entrance -> second DELETE
req "P23 DELETE $ID a second time" -X DELETE "$API/objects/$ID"

# ---- Q7: filter matching nothing -> empty array or error?
req "P24 GET /objects?id=999999999 (filter matches nothing)" "$API/objects?id=999999999"
} > "$OUT/probe-part2.log" 2>&1

echo part2 done
