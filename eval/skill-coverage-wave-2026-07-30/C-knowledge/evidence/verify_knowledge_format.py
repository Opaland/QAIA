#!/usr/bin/env python3
"""Real format check of the rag-build output against the documented layout.

Checks (from plugins/qaia-core/skills/rag-build/SKILL.md + skills/README.md):
 - knowledge/index.md exists
 - every *.md file (except index.md) has exactly one row in the index table
 - every indexed row has the 3 documented columns: path | topic | tags
 - every file is <= ~2k tokens (approximated at 4 chars/token, budget 2048)
 - every rule heading (## BR-KB-nnn) is followed by a provenance line (_Provenance: ...)
 - no obvious secret/credential pattern
"""
import os
import re
import sys

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
KB = os.path.join(BASE, "knowledge")
fail = []
info = []

index_path = os.path.join(KB, "index.md")
if not os.path.isfile(index_path):
    print("FAIL: knowledge/index.md missing (rag-build: 'master index, mandatory')")
    sys.exit(1)

index = open(index_path, encoding="utf-8").read()
rows = re.findall(r"^\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*$",
                  index, flags=re.M)
rows = [r for r in rows if r[0] not in ("path",) and not set(r[0]) <= set("-: ")]
indexed = {r[0] for r in rows}
info.append("indexed rows: %s" % sorted(indexed))

files = sorted(f for f in os.listdir(KB) if f.endswith(".md") and f != "index.md")
info.append("files present: %s" % files)

for f in files:
    if f not in indexed:
        fail.append("file %s absent from index.md -> invisible (D21)" % f)
for p in indexed:
    if p not in files:
        fail.append("index row %s points at a missing file" % p)

for f in files + ["index.md"]:
    txt = open(os.path.join(KB, f), encoding="utf-8").read()
    approx = len(txt) / 4
    info.append("%s: %d chars ~= %d tokens (budget 2048)" % (f, len(txt), approx))
    if approx > 2048:
        fail.append("%s exceeds the ~2k token budget (~%d)" % (f, approx))

for f in files:
    txt = open(os.path.join(KB, f), encoding="utf-8").read()
    blocks = re.split(r"^## ", txt, flags=re.M)[1:]
    for b in blocks:
        head = b.splitlines()[0].strip()
        if not head.startswith("BR-KB-"):
            continue
        if "_Provenance:" not in b:
            fail.append("%s / '%s' has no provenance line (mandatory)" % (f, head))
        else:
            info.append("%s / %s: provenance OK" % (f, head.split(" ")[0]))

SECRET = re.compile(r"(password|api[_-]?key|secret|token|Bearer |localhost:|10\.\d+\.\d+\.\d+)", re.I)
for f in files + ["index.md"]:
    txt = open(os.path.join(KB, f), encoding="utf-8").read()
    for m in SECRET.finditer(txt):
        fail.append("%s: possible secret/internal-env pattern %r" % (f, m.group(0)))

print("=== INFO ===")
for i in info:
    print(" -", i)
print("=== RESULT ===")
if fail:
    for x in fail:
        print(" FAIL:", x)
    sys.exit(1)
print(" PASS: knowledge base conforms to the documented rag-build layout")
