#!/usr/bin/env python3
"""Builds the manifest copies used to exercise qaia-score's two skills.

NEVER touches the original manifest (eval/skill-eval-campaign-2026-07-29/
US-EVAL-008-demoblaze/reports/manifest.json) -- it only reads it.

Outputs (all under eval/skill-coverage-wave-2026-07-30/B-scoring/):
  manifest.copy.testbook-score-only.json  -- gate block as testbook-score writes it (NO verdict)
  manifest.copy.json                      -- + aptitude-gate verdict on the REAL evidence
  flakiness-probe-A.manifest.json         -- SYNTHETIC: clean candidate + one @P2 flaky
  flakiness-probe-B.manifest.json         -- SYNTHETIC: clean candidate + one @P1 flaky
Probes A/B are fabricated *inputs* to test a documented skill rule (D80 / aptitude-gate
rule 2 last bullet). They are explicitly labelled synthetic; no execution was actually run.
"""
import json, os, copy

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.dirname(HERE)
SRC = os.path.normpath(os.path.join(
    OUT, "..", "..", "skill-eval-campaign-2026-07-29",
    "US-EVAL-008-demoblaze", "reports", "manifest.json"))

base = json.load(open(SRC, encoding="utf-8"))

DIMENSIONS_BELOW_2 = [
    {"n": 1, "name": "Atomicity", "score": 1},
    {"n": 2, "name": "AC coverage", "score": 0},
    {"n": 3, "name": "Negative-path coverage (ADR 0001)", "score": 0},
    {"n": 5, "name": "Business correctness", "score": 1},
    {"n": 8, "name": "Gherkin form", "score": 1},
]

def write(name, obj):
    p = os.path.join(OUT, name)
    with open(p, "w", encoding="utf-8") as f:
        json.dump(obj, f, indent=2, ensure_ascii=False)
        f.write("\n")
    print("wrote", p)

# --- 1. after testbook-score (skill step 5: "Do NOT set verdict here") -------------
m1 = copy.deepcopy(base)
m1["gate"] = {
    "score": 13, "max": 20,
    "scoredBy": "qaia-score/testbook-score",
    "at": "2026-07-31T00:00:00Z",
    "dimensions": DIMENSIONS_BELOW_2,
}
write("manifest.copy.testbook-score-only.json", m1)

# --- 2. after aptitude-gate on the REAL evidence ----------------------------------
m2 = copy.deepcopy(m1)
m2["gate"] = dict(m1["gate"])
m2["gate"].update({
    "verdict": "FAIL",
    "scoredBy": "qaia-score/aptitude-gate",
    "reasons": [
        "hard gate: design.coverage.acCovered=5 < acTotal=9 -- AC1, AC5, AC6, AC9 have zero scenarios (coverage-matrix.md lists no row for them); rubric dim 2 = 0",
        "hard gate: design.coverage.reqNegCovered=3 < reqNegTotal=5 -- required negative conditions AC7-C1 and AC7-C2 uncovered (03-design.md 'Negative pressure'); rubric dim 3 = 0",
        "hard gate: rubric dimensions 2 and 3 scored 0 (any dimension at 0 is release-blocking)",
        "recomputed rubric total = 13/20 from the 10 dimension scores; matches gate.score=13 (no mismatch)",
        "3 open arbitrations pending human decision (Q1, Q2 assumptions; Q3 open) plus 7 'simulated' entries -- would cap at CONCERNS on their own, but FAIL takes precedence (rules applied in order)",
        "no execution block present in the manifest -- verdict rests on design + rubric evidence only",
        "note (not a band trigger): the AC/req-neg gaps are a disclosed P1+P2 priority-scope decision (04-priorities.md), not a hidden omission; the rubric and rule 1 provide no scope-aware carve-out, so the literal bands still produce FAIL",
    ],
    "waiver": None,
    "at": "2026-07-31T00:00:00Z",
})
write("manifest.copy.json", m2)

# --- 3/4. SYNTHETIC flakiness probes ---------------------------------------------
def probe(tag, flakiness):
    m = copy.deepcopy(base)
    m["_synthetic"] = ("FABRICATED INPUT -- not a real run. Built by build_manifests.py to "
                       "exercise aptitude-gate's flakiness rule (D80). No suite was executed.")
    m["design"]["coverage"] = {"acTotal": 9, "acCovered": 9,
                               "reqNegTotal": 5, "reqNegCovered": 5, "negativeRatio": 0.42}
    m["openArbitrations"] = []
    m["execution"] = {
        "total": 12, "passed": 12, "failed": 0, "blocked": 0,
        "byType": {"e2e": 12},
        "traceability": {"scenariosTotal": 12, "scenariosAutomated": 12},
        "_synthetic": True,
    }
    m["flakiness"] = flakiness
    m["gate"] = {
        "score": 16, "max": 20,
        "scoredBy": "qaia-score/testbook-score",
        "at": "2026-07-31T00:00:00Z",
        "dimensions": [{"n": 1, "name": "Atomicity", "score": 1},
                       {"n": 5, "name": "Business correctness", "score": 1},
                       {"n": 8, "name": "Gherkin form", "score": 1},
                       {"n": 10, "name": "Review support", "score": 1}],
    }
    write("flakiness-probe-%s.manifest.json" % tag, m)

probe("A", {"runs": 5, "flaky": [
    {"scenario": "QAIA-US-EVAL-008-005", "priority": "P2", "verdicts": ["pass", "pass", "fail", "pass", "pass"]}
]})
probe("B", {"runs": 5, "flaky": [
    {"scenario": "QAIA-US-EVAL-008-005", "priority": "P2", "verdicts": ["pass", "pass", "fail", "pass", "pass"]},
    {"scenario": "QAIA-US-EVAL-008-009", "priority": "P1", "verdicts": ["pass", "fail", "pass", "pass", "pass"]}
]})
