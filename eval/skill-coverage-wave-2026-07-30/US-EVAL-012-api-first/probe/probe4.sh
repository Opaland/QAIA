#!/usr/bin/env bash
# contract-probe part 4 — final isolation of the non-ASCII 400, and TLS header check.
OUT="$(dirname "$0")"
{
echo "PROBE PART 4 $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo
echo "===== P35 non-ASCII sent as a pure-ASCII \\u00e0 JSON escape, Content-Type WITHOUT charset"
printf '{"name":"QAIA escaped","data":{"k":"v\\u00e0leur"}}' > /tmp/esc.json
echo "--- exact wire bytes sent:"
cat /tmp/esc.json; echo
curl -s -S -o /tmp/b4.txt -w 'HTTP_STATUS=%{http_code}\n' -X POST \
  https://api.restful-api.dev/objects -H 'Content-Type: application/json' \
  --data-binary @/tmp/esc.json
echo "--- body:"; cat /tmp/b4.txt; echo
echo
echo "===== P36 full HTTPS response headers (is Strict-Transport-Security present?)"
curl -s -S -D - -o /dev/null https://api.restful-api.dev/objects/7
} > "$OUT/probe-part4.log" 2>&1
echo part4 done
