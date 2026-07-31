#!/usr/bin/env python3
"""flaky-detect skill, Output/Steps step 3 -- merge the `flakiness` section into a manifest.

Contract D39 rule 2: replace ONLY `flakiness`, never touch `execution`, `design`, `gate`,
`status`. Appends flaky-detect to `producers[]` and the findings file to `artifacts[]`.
Refuses to write a `gate` block (contract rule 3, no producer scores itself).

Manifest section shape follows SKILL.md lines 65-75 (plain test-ID strings for
`allPassNoFlakinessObserved` / `consistentFailures`), matching fixture/output/manifest-after.json.

Usage: python merge_flakiness.py <manifest.json> <flakiness-findings.json>
"""
import sys, json, copy, datetime


def main(argv):
    manifest_path, findings_path = argv[0], argv[1]
    manifest = json.load(open(manifest_path, encoding="utf-8"))
    before = copy.deepcopy(manifest)
    findings = json.load(open(findings_path, encoding="utf-8"))

    manifest["flakiness"] = {
        "runsAnalyzed": findings["runsAnalyzed"],
        "codeChangeControlled": findings["codeChangeControlled"],
        "flaky": findings["flaky"],
        "allPassNoFlakinessObserved": findings["allPassNoFlakinessObserved"],
        "consistentFailures": findings["consistentFailures"],
    }

    at = datetime.datetime.now(datetime.timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
    manifest.setdefault("producers", []).append(
        {"plugin": "qaia-playwright", "version": "0.1.12", "skill": "flaky-detect", "at": at})
    findings_artifact = {"kind": "execution", "format": "json",
                         "path": "eval/skill-coverage-wave-2026-07-30/F-runartifacts/flaky-detect/flakiness-findings.json"}
    if findings_artifact["path"] not in {a.get("path") for a in manifest.setdefault("artifacts", [])}:
        manifest["artifacts"].append(findings_artifact)

    assert "gate" not in manifest, "flaky-detect must never write a gate block"
    for key in ("execution", "design", "status", "openArbitrations"):
        if key in before:
            assert manifest[key] == before[key], f"{key} must be left untouched"

    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)
        f.write("\n")
    print(f"merged flakiness into {manifest_path}")
    for key in ("execution", "design", "status", "openArbitrations"):
        print(f"  {key} untouched: {manifest.get(key) == before.get(key)}")
    print(f"  gate present: {'gate' in manifest}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
