#!/usr/bin/env python3
"""flaky-detect Output/Step 3: merge ONLY the `flakiness` section into the manifest,
append the producer, add the findings file to artifacts[]. Never touches execution/design/
gate/status.

Usage: python merge_flakiness.py <manifest.json> <flakiness-block.json> <findings-path> <artifact-kind>
"""
import sys, json, datetime

manifest_path, block_path, findings_path, kind = sys.argv[1:5]
m = json.load(open(manifest_path, encoding="utf-8"))
block = json.load(open(block_path, encoding="utf-8"))
before = {k: json.dumps(v, sort_keys=True) for k, v in m.items()}

m["flakiness"] = block["flakiness"]
now = datetime.datetime.now(datetime.timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
m["producers"].append({"plugin": "qaia-playwright", "version": "0.2.4", "skill": "flaky-detect", "at": now})
m["artifacts"].append({"kind": kind, "format": "markdown", "path": findings_path})
m["generatedAt"] = now
json.dump(m, open(manifest_path, "w", encoding="utf-8"), indent=2, ensure_ascii=False)

for k in ("execution", "design", "status", "openArbitrations"):
    same = before.get(k) == json.dumps(m.get(k), sort_keys=True)
    print(f"{k}: {'UNCHANGED' if same else 'CHANGED'}")
print("gate present:", "gate" in m)
