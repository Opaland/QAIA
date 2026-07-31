#!/usr/bin/env python3
"""run-report skill, step 3 -- merge the `execution` section into an existing manifest.json.

Contract rule 2 (D39, docs/OUTPUT-CONTRACT.md): merge, never clobber. This script loads the
existing manifest, replaces ONLY `execution`, appends run-report to `producers[]`, adds the
JUnit/Cucumber/HTML files to `artifacts[]` (idempotent on path), and leaves `design`, `gate`,
`status` and `openArbitrations` byte-identical.

Guardrail enforced in code: the script refuses to write a `gate` block (owned by qaia-score).

Usage: python merge_execution.py <manifest.json> <execution-section.json> <scenariosTotal>
"""
import sys, json, datetime, copy

ARTIFACTS = [
    {"kind": "execution", "format": "junit-xml", "path": "eval/skill-coverage-wave-2026-07-30/F-runartifacts/run-report/results.junit.xml"},
    {"kind": "execution", "format": "cucumber-json", "path": "eval/skill-coverage-wave-2026-07-30/F-runartifacts/run-report/results.cucumber.json"},
    {"kind": "execution", "format": "html", "path": "eval/skill-coverage-wave-2026-07-30/F-runartifacts/run-report/execution-report.html"},
]


def main(argv):
    manifest_path, execution_path, scenarios_total = argv[0], argv[1], int(argv[2])
    manifest = json.load(open(manifest_path, encoding="utf-8"))
    before = copy.deepcopy(manifest)
    execution = json.load(open(execution_path, encoding="utf-8"))
    execution["traceability"]["scenariosTotal"] = scenarios_total

    manifest["execution"] = execution  # replace ONLY this section

    at = datetime.datetime.now(datetime.timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
    manifest.setdefault("producers", []).append(
        {"plugin": "qaia-playwright", "version": "0.1.12", "skill": "run-report", "at": at})

    existing_paths = {a.get("path") for a in manifest.setdefault("artifacts", [])}
    for a in ARTIFACTS:
        if a["path"] not in existing_paths:
            manifest["artifacts"].append(a)

    assert "gate" not in manifest, "run-report must never write a gate block"
    for key in ("design", "status", "openArbitrations"):
        if key in before:
            assert manifest[key] == before[key], f"{key} must be left untouched"

    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)
        f.write("\n")
    print(f"merged execution into {manifest_path}")
    print(f"  design untouched: {manifest.get('design') == before.get('design')}")
    print(f"  status untouched: {manifest.get('status')!r} (was {before.get('status')!r})")
    print(f"  openArbitrations untouched: {manifest.get('openArbitrations') == before.get('openArbitrations')}")
    print(f"  gate present: {'gate' in manifest}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
