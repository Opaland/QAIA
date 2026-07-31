"""Operator-side redaction of the captured HARs BEFORE they are written as evidence.
NOT part of the traffic-replay skill: the skill never rewrites the input HAR (see report).
Also trims embedded binary/asset bodies so the evidence file stays small.
"""
import json, sys, re

# DELIVERED COPY -- the literal values below were the real ones when this script was run;
# they are shown here as placeholders so this evidence file itself carries no credential.
SECRETS = [
    "<base64 password sent by demoblaze>",
    "<same password in clear>",
    "<demoblaze tokenp_ session token>",
    "<demoblaze user cookie uuid>",
    "<throwaway account name qaia_eval_...>",
    "<saucedemo password>",
    "<saucedemo username>",
]

def scrub(s):
    for sec in SECRETS:
        s = s.replace(sec, "[REDACTED-BY-OPERATOR]")
    return s

src, dst = sys.argv[1], sys.argv[2]
har = json.load(open(src, encoding="utf-8"))
for e in har["log"]["entries"]:
    c = e["response"].get("content") or {}
    mt = (c.get("mimeType") or "")
    if c.get("text") and not mt.startswith(("application/json", "text/html", "text/plain")):
        c["text"] = f"<body stripped for evidence: {mt}, {c.get('size')} bytes>"
        c.pop("encoding", None)
    elif c.get("text") and len(c["text"]) > 4000:
        c["text"] = c["text"][:4000] + "...<truncated for evidence>"
out = scrub(json.dumps(har, indent=1))
open(dst, "w", encoding="utf-8").write(out + "\n")
remaining = [s for s in SECRETS if s in out]
print(f"{dst}: written, {len(out)} chars; secrets still present: {remaining or 'NONE'}")
