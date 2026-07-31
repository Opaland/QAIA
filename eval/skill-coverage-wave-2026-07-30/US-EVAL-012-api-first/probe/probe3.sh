#!/usr/bin/env bash
# contract-probe part 3 — REDO of the lifecycle (part 2's P16-P23 were invalid: the id
# variable was empty because Windows Python could not resolve the Git Bash /tmp path, so
# those requests hit /objects/ instead of /objects/<id>. Discarded, not reported.)
# Plus: charset isolation of the P15 400.
API=https://api.restful-api.dev
OUT="$(dirname "$0")"

req() {
  local label="$1"; shift
  echo "===== $label"
  echo "--- request: curl $*"
  curl -s -S -o /tmp/b3.txt -w 'HTTP_STATUS=%{http_code}\n' "$@"
  echo "--- body:"; head -c 900 /tmp/b3.txt; echo; echo
}

{
echo "PROBE RUN PART 3 $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo

# ---- Charset isolation: same character, but sent as a pure-ASCII \u escape on the wire
req "P25 non-ASCII as JSON \\u escape (wire bytes are pure ASCII)" -X POST "$API/objects" \
  -H 'Content-Type: application/json' -d '{"name":"QAIA esc","data":{"k":"vàleur"}}'

# ---- Same character as raw UTF-8 bytes, with charset declared explicitly
printf '{"name":"QAIA utf8","data":{"k":"v\xc3\xa0leur"}}' > /tmp/utf8.json
req "P26 raw UTF-8 bytes + charset=utf-8 declared" -X POST "$API/objects" \
  -H 'Content-Type: application/json; charset=utf-8' --data-binary @/tmp/utf8.json

# ---- Lifecycle, this time with a real id
echo "===== P27 POST create lifecycle object"
curl -s -S -o /tmp/created3.json -w 'HTTP_STATUS=%{http_code}\n' -X POST "$API/objects" \
  -H 'Content-Type: application/json' \
  -d '{"name":"QAIA lifecycle","data":{"year":2026,"price":10.5,"keep":"me"}}'
cat /tmp/created3.json; echo
ID=$(sed -n 's/.*"id":"\([^"]*\)".*/\1/p' /tmp/created3.json)
echo "CREATED_ID=[$ID]"
echo
if [ -z "$ID" ]; then echo "FATAL: id extraction failed, aborting lifecycle"; exit 1; fi

req "P28 GET /objects?id=$ID  (documented: ?id= reaches objects you created)" "$API/objects?id=$ID"

req "P29 PUT /objects/$ID  data={price} only  (promise: COMPLETELY replaces)" -X PUT "$API/objects/$ID" \
  -H 'Content-Type: application/json' -d '{"name":"QAIA lifecycle","data":{"price":99.9}}'

req "P30 GET /objects/$ID  (did year/keep disappear?)" "$API/objects/$ID"

req "P31 PATCH /objects/$ID  name only (promise: only supplied fields change)" -X PATCH "$API/objects/$ID" \
  -H 'Content-Type: application/json' -d '{"name":"QAIA lifecycle patched"}'

req "P32 DELETE /objects/$ID  (promise: message naming the id)" -X DELETE "$API/objects/$ID"

req "P33 GET /objects/$ID  after DELETE (promise: removes PERMANENTLY)" "$API/objects/$ID"

req "P34 DELETE /objects/$ID  second time (terminal-state re-entrance)" -X DELETE "$API/objects/$ID"
} > "$OUT/probe-part3.log" 2>&1

echo part3 done
