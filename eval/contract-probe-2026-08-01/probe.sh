#!/usr/bin/env bash
# contract-probe run against examples/expense-demo (self-hosted, in-repo -> authorization (a)).
# Bounded and non-destructive: single requests, no load shape, in-memory SUT reset at the start.
# Every probe targets ONE documented promise from AC1-AC8 (see contract-source.md).
#
# Disclosure discipline: each probe prints the state it actually reached before the assertion
# request, so a probe that failed to construct is visible in the output and therefore in the
# report. RUN 1 of this script was misconstructed exactly this way -- see the header of
# probe-run.txt.
set -u
B=http://localhost:4500

echo "=== SETUP: reset + logins ==="
curl -s -X POST $B/api/reset -o /dev/null -w 'reset:%{http_code}\n'

login() {
  curl -s -X POST $B/api/login -H 'Content-Type: application/json' \
       -d "{\"email\":\"$1\",\"password\":\"demo1234\"}" \
    | python -c "import json,sys; print(json.load(sys.stdin).get('token',''))"
}
EMP=$(login employee@demo); MGR=$(login manager@demo); FIN=$(login finance@demo)
echo "EMP=${EMP:-EMPTY} MGR=${MGR:-EMPTY} FIN=${FIN:-EMPTY}"
if [ -z "$EMP" ] || [ -z "$MGR" ] || [ -z "$FIN" ]; then
  echo "!! DISCLOSURE: a token is empty -- probes are NOT valid as designed. Stopping."; exit 2
fi

TODAY=$(python -c "import datetime;print(datetime.date(2026,8,1).isoformat())")
OLD=$(python -c "import datetime;print((datetime.date(2026,8,1)-datetime.timedelta(days=200)).isoformat())")

jqid() { python -c "import json,sys; d=json.load(sys.stdin); print((d.get('report') or {}).get('id',''))"; }

req() { # req <label> <method> <path> <token> [body]
  local label=$1 m=$2 p=$3 t=$4 body=${5:-} out code bodyout
  if [ -n "$body" ]; then
    out=$(curl -s -X "$m" "$B$p" -H "Authorization: Bearer $t" -H 'Content-Type: application/json' -d "$body" -w '\n<<%{http_code}>>')
  else
    out=$(curl -s -X "$m" "$B$p" -H "Authorization: Bearer $t" -w '\n<<%{http_code}>>')
  fi
  code=${out##*<<}; code=${code%%>>*}; bodyout=${out%$'\n'<<*}
  printf -- '--- %s\n    %s %s -> HTTP %s\n    %s\n' "$label" "$m" "$p" "$code" "${bodyout:0:340}"
}

# draft <token> <lines-json>  -> creates a draft AND puts the lines on it (POST ignores lines).
# Echoes the id, and echoes DRAFT-FAILED if the lines did not land -- the check RUN 1 lacked.
draft() {
  local tok=$1 lines=$2 id put n
  id=$(curl -s -X POST $B/api/reports -H "Authorization: Bearer $tok" -H 'Content-Type: application/json' -d '{}' | jqid)
  if [ -z "$id" ]; then echo "DRAFT-FAILED-NOID"; return; fi
  put=$(curl -s -X PUT "$B/api/reports/$id" -H "Authorization: Bearer $tok" -H 'Content-Type: application/json' -d "{\"lines\":$lines}")
  n=$(printf '%s' "$put" | python -c "import json,sys
try: print(len((json.load(sys.stdin).get('report') or {}).get('lines') or []))
except Exception: print(0)")
  if [ "$n" = "0" ]; then echo "DRAFT-FAILED-NOLINES:$id"; else echo "$id"; fi
}

echo
echo "=== P1 (AC4): a line dated outside 90 days is blocked at submission with a message ==="
R=$(draft "$EMP" "[{\"category\":\"travel\",\"amount\":10,\"date\":\"$OLD\",\"receipt\":false}]")
echo "    draft state: $R"
case $R in DRAFT-FAILED*) echo "    !! probe invalid, not counted";; *) req "P1 submit 200-day-old line" POST "/api/reports/$R/submit" "$EMP" '{}';; esac

echo
echo "=== P2 (AC5): a single line >= EUR25 with no receipt is refused ==="
R=$(draft "$EMP" "[{\"category\":\"meal\",\"amount\":25,\"date\":\"$TODAY\",\"receipt\":false}]")
echo "    draft state: $R"
case $R in DRAFT-FAILED*) echo "    !! probe invalid";; *) req "P2 submit 25EUR no receipt" POST "/api/reports/$R/submit" "$EMP" '{}';; esac
R=$(draft "$EMP" "[{\"category\":\"meal\",\"amount\":24.99,\"date\":\"$TODAY\",\"receipt\":false}]")
echo "    boundary draft state: $R"
case $R in DRAFT-FAILED*) echo "    !! probe invalid";; *) req "P2b submit 24.99EUR no receipt (below threshold, must PASS)" POST "/api/reports/$R/submit" "$EMP" '{}';; esac

echo
echo "=== P3 (AC3): an approver cannot approve their own report ==="
R=$(draft "$MGR" "[{\"category\":\"meal\",\"amount\":10,\"date\":\"$TODAY\",\"receipt\":true}]")
echo "    manager's own draft: $R"
case $R in DRAFT-FAILED*) echo "    !! probe invalid";; *)
  req "P3a manager submits own report" POST "/api/reports/$R/submit" "$MGR" '{}'
  req "P3b manager decides own report" POST "/api/reports/$R/decide" "$MGR" '{"decision":"approve","comment":"approving my own"}' ;;
esac

echo
echo "=== P4 (AC8): rejection requires a mandatory comment of >= 10 characters ==="
R=$(draft "$EMP" "[{\"category\":\"meal\",\"amount\":10,\"date\":\"$TODAY\",\"receipt\":true}]")
echo "    draft state: $R"
case $R in DRAFT-FAILED*) echo "    !! probe invalid";; *)
  req "P4a submit" POST "/api/reports/$R/submit" "$EMP" '{}'
  req "P4b reject, 2-char comment" POST "/api/reports/$R/decide" "$MGR" '{"decision":"reject","comment":"no"}'
  req "P4c reject, NO comment field" POST "/api/reports/$R/decide" "$MGR" '{"decision":"reject"}'
  req "P4d changes-requested, NO comment" POST "/api/reports/$R/decide" "$MGR" '{"decision":"changes-requested"}' ;;
esac

echo
echo "=== P5 (AC7): a rejected report is terminal -- no edit, no re-submit ==="
R=$(draft "$EMP" "[{\"category\":\"meal\",\"amount\":10,\"date\":\"$TODAY\",\"receipt\":true}]")
echo "    draft state: $R"
case $R in DRAFT-FAILED*) echo "    !! probe invalid";; *)
  req "P5a submit" POST "/api/reports/$R/submit" "$EMP" '{}'
  req "P5b reject with a valid comment" POST "/api/reports/$R/decide" "$MGR" '{"decision":"reject","comment":"insufficient justification"}'
  req "P5c EDIT the rejected report" PUT "/api/reports/$R" "$EMP" "{\"lines\":[{\"category\":\"meal\",\"amount\":11,\"date\":\"$TODAY\",\"receipt\":true}]}"
  req "P5d RE-SUBMIT the rejected report" POST "/api/reports/$R/submit" "$EMP" '{}' ;;
esac

echo
echo "=== P6 (AC4): each line must have a category, an amount and a date ==="
for L in "[{\"amount\":10,\"date\":\"$TODAY\",\"receipt\":true}]" \
         "[{\"category\":\"meal\",\"date\":\"$TODAY\",\"receipt\":true}]" \
         "[{\"category\":\"meal\",\"amount\":10,\"receipt\":true}]"; do
  R=$(draft "$EMP" "$L")
  echo "    draft ($L) -> $R"
  case $R in DRAFT-FAILED*) echo "    !! probe invalid";; *) req "P6 submit incomplete line" POST "/api/reports/$R/submit" "$EMP" '{}';; esac
done

echo
echo "=== P7 (adversarial types on a documented numeric field) ==="
for V in '"10"' '-100' 'null' '1e309'; do
  R=$(draft "$EMP" "[{\"category\":\"meal\",\"amount\":$V,\"date\":\"$TODAY\",\"receipt\":true}]")
  echo "    amount=$V -> $R"
  case $R in DRAFT-FAILED*) echo "    !! probe invalid";; *) req "P7 submit amount=$V" POST "/api/reports/$R/submit" "$EMP" '{}';; esac
done

echo
echo "=== P8 (authz): cross-user access to another user's draft (IDOR) ==="
R=$(draft "$EMP" "[{\"category\":\"meal\",\"amount\":10,\"date\":\"$TODAY\",\"receipt\":true}]")
echo "    employee draft: $R"
case $R in DRAFT-FAILED*) echo "    !! probe invalid";; *)
  req "P8a finance READS employee draft" GET "/api/reports/$R" "$FIN"
  req "P8b finance EDITS employee draft" PUT "/api/reports/$R" "$FIN" "{\"lines\":[{\"category\":\"meal\",\"amount\":9999,\"date\":\"$TODAY\",\"receipt\":true}]}"
  req "P8c finance DECIDES employee draft" POST "/api/reports/$R/decide" "$FIN" '{"decision":"approve","comment":"not mine to approve"}' ;;
esac

echo
echo "=== P9 (robustness): malformed body and wrong content-type ==="
printf -- '--- P9a truncated JSON\n    '
curl -s -X POST $B/api/reports -H "Authorization: Bearer $EMP" -H 'Content-Type: application/json' -d '{"lines":[{"category":"meal"' -w ' -> HTTP %{http_code}\n' | head -3
printf -- '--- P9b form body labelled application/json\n    '
curl -s -X POST $B/api/reports -H "Authorization: Bearer $EMP" -H 'Content-Type: application/json' -d 'lines=1&category=meal' -w ' -> HTTP %{http_code}\n' | head -3
printf -- '--- P9c 1MB string in a text field\n    '
BIG=$(python -c "print('x'*1000000)")
curl -s -X POST $B/api/reports -H "Authorization: Bearer $EMP" -H 'Content-Type: application/json' -d "{\"note\":\"$BIG\"}" -w ' -> HTTP %{http_code}\n' -o /dev/null

echo
echo "=== P10 (authz): no token on a protected endpoint ==="
printf '    '
curl -s $B/api/reports -w ' -> HTTP %{http_code}\n' | head -2

echo
echo "=== P11 (protocol): wrong method on a valid path ==="
printf '    DELETE /api/reports '
curl -s -X DELETE $B/api/reports -H "Authorization: Bearer $EMP" -w '-> HTTP %{http_code}\n' -o /dev/null

echo
echo "=== DONE ==="
