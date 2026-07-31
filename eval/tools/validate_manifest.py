#!/usr/bin/env python3
"""Validates a QAIA run manifest against docs/schemas/output-contract-v1.schema.json.

Origin: Gemini external audit (2026-07-28, plan d'action Phase 1 -- "Formaliser les schemas
de validation ... permettant de valider programmatiquement les sorties via un linter CI local
avant tout commit"). D104. Complements structural_score.py (which scores .feature content);
this validates the manifest.json envelope itself (docs/OUTPUT-CONTRACT.md, D39).

NO LLM, NO network, NO third-party package (mirrors structural_score.py/second_judge.py:
stdlib only, maintainer eval tooling, not shipped to installers) -- deliberately hand-rolled
against the documented contract rather than a generic JSON Schema engine, since the contract
itself already lives as prose in docs/OUTPUT-CONTRACT.md; this is a second, executable copy of
the same rules, not a new source of truth.

Usage: python3 validate_manifest.py <manifest.json> [<manifest2.json> ...]
       python3 validate_manifest.py --batch <dir>   # recursively finds manifest.json files
"""
import sys, os, json, glob, re

ISO_DATETIME_RE = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?(Z|[+-]\d{2}:\d{2})$")

TOP_REQUIRED = ["contract", "usId", "title", "status", "generatedAt", "base", "producers", "artifacts"]
STATUS_ENUM = {"draft", "review", "validated"}
# "flakiness" added 2026-07-31: `flaky-detect` emits a flakiness artifact and a `flakiness`
# section that `aptitude-gate` reads as a CONCERNS signal (D80), but neither the enum nor
# docs/OUTPUT-CONTRACT.md ever declared the kind -- so the skill's own shipped fixture was
# out of contract from the day it was written (wave A, pattern P1/P2).
# "trafficReplay" likewise: `traffic-replay` (D88) emits HAR-derived regression conditions and
# its own fixture declared this kind, undeclared anywhere. Found by the CI job added in the
# same pass -- the skill-eval wave itself had only named the flaky-detect case.
ARTIFACT_KIND_ENUM = {"feature", "synthesis", "matrix", "execution", "export", "validation",
                      "flakiness", "trafficReplay"}
ARBITRATION_KIND_ENUM = {"open", "assumption", "simulated"}
GATE_VERDICT_ENUM = {"PASS", "CONCERNS", "FAIL", "WAIVED"}

DESIGN_REQUIRED = ["scenarios", "coverage", "confidence", "techniques", "oracles", "knowledgeApplied"]
EXECUTION_REQUIRED = ["total", "passed", "failed", "blocked", "byType", "traceability"]
GATE_REQUIRED = ["verdict", "score", "max", "scoredBy", "at", "dimensions", "reasons", "waiver"]


def err(errors, path, msg):
    errors.append(f"{path}: {msg}")


def check_str(v, path, errors, allow_empty=False):
    if not isinstance(v, str):
        err(errors, path, f"expected string, got {type(v).__name__}")
    elif not allow_empty and v == "":
        err(errors, path, "expected non-empty string")


def check_int(v, path, errors, minimum=None):
    if not isinstance(v, int) or isinstance(v, bool):
        err(errors, path, f"expected integer, got {type(v).__name__}")
    elif minimum is not None and v < minimum:
        err(errors, path, f"expected >= {minimum}, got {v}")


def check_datetime(v, path, errors):
    check_str(v, path, errors)
    if isinstance(v, str) and not ISO_DATETIME_RE.match(v):
        err(errors, path, f"expected ISO 8601 date-time, got {v!r}")


def check_enum(v, path, errors, allowed):
    if v not in allowed:
        err(errors, path, f"expected one of {sorted(allowed)}, got {v!r}")


def validate_producers(producers, errors):
    if not isinstance(producers, list):
        return err(errors, "producers", "expected array")
    for i, p in enumerate(producers):
        path = f"producers[{i}]"
        if not isinstance(p, dict):
            err(errors, path, "expected object"); continue
        for field in ("plugin", "version", "skill"):
            check_str(p.get(field), f"{path}.{field}", errors)
        check_datetime(p.get("at"), f"{path}.at", errors)


def validate_artifacts(artifacts, errors, base_dir=None):
    if not isinstance(artifacts, list):
        return err(errors, "artifacts", "expected array")
    for i, a in enumerate(artifacts):
        path = f"artifacts[{i}]"
        if not isinstance(a, dict):
            err(errors, path, "expected object"); continue
        check_enum(a.get("kind"), f"{path}.kind", errors, ARTIFACT_KIND_ENUM)
        check_str(a.get("format"), f"{path}.format", errors)
        check_str(a.get("path"), f"{path}.path", errors)
        # An artifacts[].path pointing at nothing used to validate (wave A, pattern P2): the
        # manifest could claim deliverables that were never written. Only checked when a base
        # directory is given (--check-paths), because a manifest is often validated away from
        # the tree it describes.
        if base_dir and isinstance(a.get("path"), str):
            candidate = os.path.join(base_dir, a["path"].replace("\\", os.sep).replace("/", os.sep))
            if not os.path.exists(candidate):
                err(errors, f"{path}.path",
                    f"declared artifact does not exist on disk: {a['path']!r} "
                    f"(resolved against {base_dir})")


def validate_design(design, errors):
    path = "design"
    if not isinstance(design, dict):
        return err(errors, path, "expected object")
    for field in DESIGN_REQUIRED:
        if field not in design:
            err(errors, path, f"missing required field {field!r}")
    sc = design.get("scenarios", {})
    for field in ("total", "negative", "smoke", "outlines"):
        check_int(sc.get(field), f"{path}.scenarios.{field}", errors, minimum=0)
    by_pri = sc.get("byPriority", {})
    for pri in ("P1", "P2", "P3"):
        check_int(by_pri.get(pri), f"{path}.scenarios.byPriority.{pri}", errors, minimum=0)
    cov = design.get("coverage", {})
    for field in ("acTotal", "acCovered", "reqNegTotal", "reqNegCovered"):
        check_int(cov.get(field), f"{path}.coverage.{field}", errors, minimum=0)
    ratio = cov.get("negativeRatio")
    if not isinstance(ratio, (int, float)) or isinstance(ratio, bool) or not (0 <= ratio <= 1):
        err(errors, f"{path}.coverage.negativeRatio", f"expected number in [0,1], got {ratio!r}")
    conf = design.get("confidence", {})
    for field in ("lowConfidence", "openQuestions", "assumptions", "simulated"):
        check_int(conf.get(field), f"{path}.confidence.{field}", errors, minimum=0)
    for field in ("techniques", "oracles", "knowledgeApplied"):
        if not isinstance(design.get(field), list):
            err(errors, f"{path}.{field}", "expected array")


def validate_execution(execution, errors):
    path = "execution"
    if not isinstance(execution, dict):
        return err(errors, path, "expected object")
    for field in EXECUTION_REQUIRED:
        if field not in execution:
            err(errors, path, f"missing required field {field!r}")
    for field in ("total", "passed", "failed", "blocked"):
        check_int(execution.get(field), f"{path}.{field}", errors, minimum=0)
    trace = execution.get("traceability", {})
    for field in ("scenariosAutomated", "scenariosTotal"):
        check_int(trace.get(field), f"{path}.traceability.{field}", errors, minimum=0)


def validate_open_arbitrations(items, errors):
    path = "openArbitrations"
    if not isinstance(items, list):
        return err(errors, path, "expected array")
    for i, a in enumerate(items):
        p = f"{path}[{i}]"
        if not isinstance(a, dict):
            err(errors, p, "expected object"); continue
        check_str(a.get("id"), f"{p}.id", errors)
        check_enum(a.get("kind"), f"{p}.kind", errors, ARBITRATION_KIND_ENUM)
        check_str(a.get("about"), f"{p}.about", errors)
        check_str(a.get("sourceCheckpoint"), f"{p}.sourceCheckpoint", errors)


def validate_gate(gate, errors):
    path = "gate"
    if not isinstance(gate, dict):
        return err(errors, path, "expected object")
    for field in GATE_REQUIRED:
        if field not in gate:
            err(errors, path, f"missing required field {field!r}")
    check_enum(gate.get("verdict"), f"{path}.verdict", errors, GATE_VERDICT_ENUM)
    check_int(gate.get("score"), f"{path}.score", errors, minimum=0)
    check_int(gate.get("max"), f"{path}.max", errors, minimum=0)
    check_str(gate.get("scoredBy"), f"{path}.scoredBy", errors)
    check_datetime(gate.get("at"), f"{path}.at", errors)
    waiver = gate.get("waiver")
    # A WAIVED verdict with no waiver object used to PASS with exit 0 (verified 2026-07-31,
    # skill-eval wave A, pattern P2): the "WAIVED is never self-granted" rule in
    # aptitude-gate was adossed to nothing mechanical. A waiver must name who granted it.
    if gate.get("verdict") == "WAIVED" and not isinstance(waiver, dict):
        err(errors, f"{path}.waiver",
            "verdict is WAIVED but no waiver object is present — a waiver must be granted "
            "explicitly and name its grantor; it is never self-granted")
    if waiver is not None and not isinstance(waiver, dict):
        err(errors, f"{path}.waiver", "expected object or null")
    elif isinstance(waiver, dict):
        for field in ("by", "reason", "at"):
            if field not in waiver:
                err(errors, f"{path}.waiver", f"missing required field {field!r}")


STRUCTURAL_GATE_ENUM = {"PASS", "CONCERNS", "FAIL"}
STRUCTURAL_REQUIRED = ["score", "max", "gate", "forcedStop", "scoredBy", "at"]


def validate_structural(structural, errors):
    """The deterministic /100 pass. Kept separate from `gate` on purpose — see
    docs/OUTPUT-CONTRACT.md: the founding case measured one book 100/100 by machine and 58/100 by
    a human, so the two numbers answer different questions and are never merged."""
    path = "structural"
    if not isinstance(structural, dict):
        return err(errors, path, "expected object")
    for field in STRUCTURAL_REQUIRED:
        if field not in structural:
            err(errors, path, "missing required field %r" % field)
    check_int(structural.get("score"), f"{path}.score", errors, minimum=0)
    check_enum(structural.get("gate"), f"{path}.gate", errors, STRUCTURAL_GATE_ENUM)
    check_str(structural.get("scoredBy"), f"{path}.scoredBy", errors)
    check_datetime(structural.get("at"), f"{path}.at", errors)
    if structural.get("max") != 100:
        err(errors, f"{path}.max", "expected 100 (the budget is fixed: 25+30+20+25)")
    forced = structural.get("forcedStop")
    if not isinstance(forced, bool):
        err(errors, f"{path}.forcedStop", "expected boolean")

    score, gate = structural.get("score"), structural.get("gate")
    # The two coherence rules that make this block worth storing at all: a manifest that claims a
    # gate its own numbers contradict is worse than no gate, because everything downstream trusts
    # the label rather than recomputing it.
    if forced is True and gate != "FAIL":
        err(errors, f"{path}.gate",
            "forcedStop is true but gate is %r — a C1/C2/fabrication finding fails the book "
            "whatever the score" % gate)
    if forced is False and isinstance(score, int) and gate in STRUCTURAL_GATE_ENUM:
        expected = "PASS" if score >= 80 else ("CONCERNS" if score >= 60 else "FAIL")
        if gate != expected:
            err(errors, f"{path}.gate",
                "score %d puts this book in band %r, but gate says %r" % (score, expected, gate))


def validate_manifest(manifest, base_dir=None):
    errors = []
    if not isinstance(manifest, dict):
        return ["<root>: expected object"]
    for field in TOP_REQUIRED:
        if field not in manifest:
            err(errors, "<root>", f"missing required field {field!r}")
    check_str(manifest.get("contract"), "contract", errors)
    check_str(manifest.get("usId"), "usId", errors)
    check_str(manifest.get("title"), "title", errors)
    check_enum(manifest.get("status"), "status", errors, STATUS_ENUM)
    check_datetime(manifest.get("generatedAt"), "generatedAt", errors)
    check_str(manifest.get("base"), "base", errors)
    validate_producers(manifest.get("producers", []), errors)
    validate_artifacts(manifest.get("artifacts", []), errors, base_dir)
    if "design" in manifest:
        validate_design(manifest["design"], errors)
    if "execution" in manifest:
        validate_execution(manifest["execution"], errors)
    if "openArbitrations" in manifest:
        validate_open_arbitrations(manifest["openArbitrations"], errors)
    if "structural" in manifest:
        validate_structural(manifest["structural"], errors)
    if "gate" in manifest:
        validate_gate(manifest["gate"], errors)
        # A forced stop caps the release verdict regardless of the rubric: the deterministic pass
        # found a scenario that cannot be evaluated at all, and no LLM total overrides that.
        st = manifest.get("structural")
        if isinstance(st, dict) and st.get("forcedStop") is True:
            verdict = manifest["gate"].get("verdict")
            if verdict in ("PASS", "CONCERNS"):
                err(errors, "gate.verdict",
                    "structural.forcedStop is true but the release verdict is %r — a forced stop "
                    "caps the verdict at FAIL (WAIVED stays possible: a human may accept the risk)"
                    % verdict)
    return errors


def main(argv):
    if not argv:
        print(__doc__)
        return 2
    # --check-paths <root> : also require every artifacts[].path to resolve to a real file,
    # relative to <root>. Opt-in because a manifest is frequently validated away from the tree
    # it describes, and a missing file would then be a false alarm rather than a finding.
    base_dir = None
    if "--check-paths" in argv:
        i = argv.index("--check-paths")
        if i + 1 >= len(argv):
            print("--check-paths requires a root directory")
            return 2
        base_dir = argv[i + 1]
        argv = argv[:i] + argv[i + 2:]
    if not argv:
        print("no manifest given")
        return 2
    if argv[0] == "--batch":
        targets = sorted(glob.glob(os.path.join(argv[1], "**", "manifest.json"), recursive=True))
    else:
        targets = argv
    if not targets:
        print("no manifest.json found")
        return 2
    exit_code = 0
    for target in targets:
        try:
            manifest = json.load(open(target, encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as e:
            print(f"FAIL {target}: cannot read/parse -- {e}")
            exit_code = 1
            continue
        errors = validate_manifest(manifest, base_dir)
        if errors:
            print(f"FAIL {target} ({len(errors)} error(s))")
            for e in errors:
                print(f"  - {e}")
            exit_code = 1
        else:
            print(f"PASS {target}")
    return exit_code


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
