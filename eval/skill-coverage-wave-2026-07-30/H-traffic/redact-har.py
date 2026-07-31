#!/usr/bin/env python3
"""Redact the captured HAR before it is written as evidence.

IMPORTANT: this script is NOT part of the traffic-replay skill. The skill masks its
*output artifacts*; it says nothing about redacting the *input HAR*. The raw HAR
captured for this evaluation (capture/demoblaze-login.har, 12.8 MB) contains the
signup/login credential and the session token in clear text, so it is deliberately
not delivered. This produces a delivered, redacted, content-stripped copy.
"""
import json, os, re, sys

SECRET_KEYS = re.compile(r"password|passwd|pwd|secret|token|api.?key|cookie", re.I)
NAME_KEYS = re.compile(r"name|assignee|author|owner|contact", re.I)
# Exact literals to scrub, supplied at run time (never hardcoded in a delivered file):
#   QAIA_REDACT_LITERALS="<user>,<password>,<b64password>,<token>" python redact-har.py in.har out.har
LITERALS = [s for s in os.environ.get("QAIA_REDACT_LITERALS", "").split(",") if s]


def scrub_text(t):
    if not isinstance(t, str):
        return t
    for lit in LITERALS:
        t = t.replace(lit, "[REDACTED:eval-credential]")
    return t


def scrub_json(key, v):
    if isinstance(v, str):
        if key and SECRET_KEYS.search(key):
            return "[REDACTED:secret]"
        if key and NAME_KEYS.search(key):
            return "[REDACTED:name]"
        return scrub_text(v)
    if isinstance(v, dict):
        return {k: scrub_json(k, x) for k, x in v.items()}
    if isinstance(v, list):
        return [scrub_json(key, x) for x in v]
    return v


def scrub_body(d):
    if not d:
        return d
    t = d.get("text")
    if not t:
        return d
    mt = d.get("mimeType") or ""
    if "json" in mt:
        try:
            d["text"] = json.dumps(scrub_json(None, json.loads(t)))
            return d
        except ValueError:
            pass
    # non-JSON: drop the body entirely (static assets, base64 images) and note the size
    d["text"] = f"[STRIPPED-FOR-EVIDENCE: {mt or 'unknown'}, {len(t)} chars]"
    return d


src, dst = sys.argv[1], sys.argv[2]
har = json.load(open(src, encoding="utf-8"))
for e in har["log"]["entries"]:
    for h in e["request"]["headers"] + e["response"]["headers"]:
        if h["name"].lower() in ("cookie", "set-cookie", "authorization"):
            h["value"] = "[REDACTED]"
        else:
            h["value"] = scrub_text(h["value"])
    e["request"]["url"] = scrub_text(e["request"]["url"])
    for q in e["request"].get("queryString", []):
        q["value"] = scrub_text(q["value"])
    if e["request"].get("postData"):
        e["request"]["postData"] = scrub_body(e["request"]["postData"])
    if e["response"].get("content"):
        e["response"]["content"] = scrub_body(e["response"]["content"])
    for c in e["request"].get("cookies", []) + e["response"].get("cookies", []):
        c["value"] = "[REDACTED]"
json.dump(har, open(dst, "w", encoding="utf-8"), indent=1)
print(f"redacted HAR -> {dst} ({len(har['log']['entries'])} entries)")
