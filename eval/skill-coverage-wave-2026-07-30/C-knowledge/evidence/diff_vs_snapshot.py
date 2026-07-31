#!/usr/bin/env python3
"""feedback step 1, objective path: diff the current .feature against the generated baseline.

`testbook-generate` SKILL.md line 38 says the snapshot holds "scenario IDs + content hash per
scenario"; line 46 says scenarios differing from the snapshot are human-edited. Neither line
defines the block boundaries nor the normalization, so this script tries several plausible
definitions and reports which (if any) reproduces the recorded 12-hex prefixes.
"""
import hashlib
import re
import sys

FEATURE = ("eval/skill-eval-campaign-2026-07-29/US-EVAL-009-octoperf-petstore/"
           "testbooks/octoperf-petstore-cart.feature")
SNAP = ("eval/skill-eval-campaign-2026-07-29/US-EVAL-009-octoperf-petstore/"
        "state/generated.snapshot.md")

text = open(FEATURE, encoding="utf-8").read()
snap = dict(re.findall(r"\|\s*(QAIA-US-EVAL-009-\d+)\s*\|\s*`([0-9a-f]+)`\s*\|",
                       open(SNAP, encoding="utf-8").read()))

# split into scenario blocks: from a line containing @QAIA-... up to the next such line / EOF
lines = text.splitlines()
starts = [i for i, l in enumerate(lines) if re.search(r"@QAIA-US-EVAL-009-\d+", l)]
blocks = {}
for n, i in enumerate(starts):
    j = starts[n + 1] if n + 1 < len(starts) else len(lines)
    sid = re.search(r"(QAIA-US-EVAL-009-\d+)", lines[i]).group(1)
    blocks[sid] = lines[i:j]

VARIANTS = {
    "raw block (\\n, trailing blanks kept)": lambda b: "\n".join(b),
    "block rstripped of blank lines": lambda b: "\n".join(
        b[:max(k + 1 for k, l in enumerate(b) if l.strip())]),
    "block, comments+tags stripped": lambda b: "\n".join(
        l for l in b if l.strip() and not l.strip().startswith(("#", "@"))),
    "block, whitespace-normalized": lambda b: "\n".join(
        l.strip() for l in b if l.strip()),
    "raw block + trailing newline": lambda b: "\n".join(b) + "\n",
}

print("scenarios in feature: %d | ids in snapshot: %d" % (len(blocks), len(snap)))
print("id sets equal:", set(blocks) == set(snap))
print()
matched_variant = None
for name, fn in VARIANTS.items():
    hits = sum(1 for sid, b in blocks.items()
               if hashlib.sha256(fn(b).encode("utf-8")).hexdigest()[:12] == snap.get(sid))
    print("variant %-40s -> %d/%d ids match" % (name, hits, len(snap)))
    if hits == len(snap):
        matched_variant = name
print()
if matched_variant:
    print("RESULT: snapshot reproduced with variant %r -> 0 human-edited scenarios."
          % matched_variant)
else:
    print("RESULT: no tried variant reproduces the recorded hashes. The hashing convention is "
          "NOT specified in testbook-generate/SKILL.md (line 38 says only 'content hash per "
          "scenario'), so `feedback` step 1's diff path cannot be executed objectively here.")
    for sid, b in sorted(blocks.items()):
        print("  %s recorded=%s  raw-sha256[:12]=%s"
              % (sid, snap.get(sid),
                 hashlib.sha256("\n".join(b).encode("utf-8")).hexdigest()[:12]))
sys.exit(0)
