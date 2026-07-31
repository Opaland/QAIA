#!/usr/bin/env python3
"""Builds 4 probe manifests to exercise aptitude-gate/SKILL.md's rules that the real
US-EVAL-008 manifest short-circuits (it FAILs on rule 1 before rules 2/3 are ever reached).

All probes are COPIES written into this eval directory -- the original
eval/skill-eval-campaign-2026-07-29/.../reports/manifest.json is never touched.

Probe A -- step-1 "recompute the total yourself" rule: dimensions sum to 15, gate.score claims 16.
Probe B -- rule 2's "@P2/@P3 flaky named in reasons but don't by themselves force CONCERNS".
Probe C -- rule 2's "@P1 flaky -> CONCERNS" (D80's documented path).
Probe D -- rule 4 / step 3: a waiver block with NO recorded human decision.
"""
import copy, json, os

HERE = os.path.dirname(os.path.abspath(__file__))

CLEAN = {
    "contract": "1.0", "usId": "US-EVAL-008-PROBE",
    "title": "probe baseline (clean: all hard gates met, no arbitration)",
    "status": "review", "generatedAt": "2026-07-30T00:00:00Z",
    "base": "eval/skill-coverage-wave-2026-07-30/B-scoring",
    "producers": [], "artifacts": [],
    "design": {
        "scenarios": {"total": 10, "byPriority": {"P1": 2, "P2": 8, "P3": 0},
                      "negative": 3, "smoke": 0, "outlines": 0},
        "coverage": {"acTotal": 9, "acCovered": 9, "reqNegTotal": 5, "reqNegCovered": 5,
                     "negativeRatio": 0.30},
        "confidence": {"lowConfidence": 0, "openQuestions": 0, "assumptions": 0, "simulated": 0},
        "techniques": ["ep"], "oracles": [], "knowledgeApplied": []},
    "execution": {"total": 10, "passed": 10, "failed": 0, "blocked": 0,
                  "byType": {"e2e-desktop": 10},
                  "traceability": {"scenariosAutomated": 10, "scenariosTotal": 10}},
    "openArbitrations": [],
    "gate": {"score": 19, "max": 20, "scoredBy": "qaia-score/testbook-score",
             "at": "2026-07-30T00:00:00Z",
             "dimensions": [{"n": 3, "name": "negative-path", "score": 1}]},
}

# ---- Probe A: arithmetic slip at the release threshold (SKILL.md step 1, #21 calibration) ----
a = copy.deepcopy(CLEAN)
a["usId"] = "US-EVAL-008-PROBE-A"
a["title"] = "probe A: gate.score says 16, listed dimensions sum to 15"
a["gate"]["score"] = 16
a["gate"]["dimensions"] = [{"n": 1, "name": "atomicity", "score": 1},
                           {"n": 3, "name": "negative-path", "score": 1},
                           {"n": 5, "name": "business-correctness", "score": 1},
                           {"n": 8, "name": "gherkin-form", "score": 1},
                           {"n": 10, "name": "review-support", "score": 1}]  # 20 - 5 = 15

# ---- Probe B: flaky @P2 only (must NOT by itself force CONCERNS) ----
b = copy.deepcopy(CLEAN)
b["usId"] = "US-EVAL-008-PROBE-B"
b["title"] = "probe B: one flaky @P2 scenario, everything else clean"
b["flakiness"] = {"runsAnalyzed": 5, "codeChangeControlled": True,
                  "flaky": [{"testId": "@QAIA-US-EVAL-008-005",
                             "verdicts": ["pass", "fail", "pass", "pass", "fail"],
                             "passRate": "3/5", "failedRuns": [2, 5],
                             "failureExcerpt": "Expected total 1150, received 790 (run 2)"}],
                  "allPassNoFlakinessObserved": [], "consistentFailures": []}

# ---- Probe C: flaky @P1 (D80's documented CONCERNS path) ----
c = copy.deepcopy(CLEAN)
c["usId"] = "US-EVAL-008-PROBE-C"
c["title"] = "probe C: one flaky @P1 scenario, everything else clean"
c["flakiness"] = {"runsAnalyzed": 5, "codeChangeControlled": True,
                  "flaky": [{"testId": "@QAIA-US-EVAL-008-009",
                             "verdicts": ["pass", "pass", "fail", "pass", "pass"],
                             "passRate": "4/5", "failedRuns": [3],
                             "failureExcerpt": "confirmation dialog not shown (run 3)"}],
                  "allPassNoFlakinessObserved": [], "consistentFailures": []}

# ---- Probe D: a waiver with no recorded human decision ----
d = copy.deepcopy(CLEAN)
d["usId"] = "US-EVAL-008-PROBE-D"
d["title"] = "probe D: waiver block present, granted by an agent (no human)"
d["design"]["coverage"]["acCovered"] = 5           # a genuine FAIL candidate
d["gate"]["waiver"] = {"by": "qaia-score/aptitude-gate (agent)",
                       "reason": "non-interactive campaign run, accepted as-is",
                       "at": "2026-07-30T00:00:00Z"}

for name, obj in [("probe-A-score-mismatch.json", a), ("probe-B-flaky-p2.json", b),
                  ("probe-C-flaky-p1.json", c), ("probe-D-self-waiver.json", d)]:
    with open(os.path.join(HERE, name), "w", encoding="utf-8") as fh:
        json.dump(obj, fh, ensure_ascii=False, indent=2)
    print("wrote", name)
