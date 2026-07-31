#!/usr/bin/env python3
"""Writes aptitude-gate's verdict into the two SYNTHETIC flakiness probes (step 4),
so the delivered artifacts match the reasoning in aptitude-gate-US-EVAL-008.md."""
import json, os

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.dirname(HERE)

P2_LINE = ("flaky @P2 QAIA-US-EVAL-008-005 (1 fail / 5 runs) -- reported, not blocking "
           "(rule 2 flakiness bullet is P1-only)")

CASES = {
    "flakiness-probe-A.manifest.json": ("PASS", [
        "recomputed rubric total = 16 from the dimension scores (4 listed at 1, 6 implied at 2); matches gate.score=16",
        "hard gates cleared: acCovered 9/9, reqNegCovered 5/5, no dimension at 0, Gherkin valid, stable IDs present",
        "no pending arbitration: openArbitrations is empty",
        "execution present and clean: failed=0, blocked=0, scenariosAutomated 12/12",
        P2_LINE,
    ]),
    "flakiness-probe-B.manifest.json": ("CONCERNS", [
        "recomputed rubric total = 16 from the dimension scores; matches gate.score=16",
        "hard gates cleared: acCovered 9/9, reqNegCovered 5/5, no dimension at 0 -- rule 1 does not match",
        "flaky @P1 QAIA-US-EVAL-008-009 (1 fail / 5 runs) -- a P1 that sometimes fails isn't release-clean even though its last run was green (rule 2, flakiness bullet)",
        P2_LINE,
        "execution otherwise clean: failed=0, blocked=0 -- the P1 instability is the sole CONCERNS driver",
    ]),
}

for name, (verdict, reasons) in CASES.items():
    p = os.path.join(OUT, name)
    m = json.load(open(p, encoding="utf-8"))
    m["gate"].update({"verdict": verdict, "reasons": reasons, "waiver": None,
                      "scoredBy": "qaia-score/aptitude-gate", "at": "2026-07-31T00:00:00Z"})
    with open(p, "w", encoding="utf-8") as f:
        json.dump(m, f, indent=2, ensure_ascii=False)
        f.write("\n")
    print(name, "->", verdict)
