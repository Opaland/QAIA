#!/usr/bin/env python3
"""Throwaway, in-session implementation of aptitude-gate/SKILL.md's *deterministic* verdict
bands, transcribed literally from the SKILL.md (lines 23-49) so the bands can be applied
"au chiffre pres" and re-run over probe manifests. Not shipped, not committed to plugins/.

Usage: python gate_bands.py <manifest.json> [--feature <file.feature>]

The --feature argument supplies the testId -> priority map that rule 2's "@P1 flaky" clause
needs; the manifest's own `flakiness.flaky[]` entries carry no priority field (see the
flaky-detect fixture schema), which is itself a finding.
"""
import json, re, sys


def priorities_from_feature(path):
    """@QAIA-xxx -> P1/P2/P3, read from the .feature tag lines."""
    out = {}
    for line in open(path, encoding="utf-8"):
        s = line.strip()
        if not s.startswith("@"):
            continue
        ids = re.findall(r"@QAIA-[A-Za-z0-9_.-]+", s)
        pri = re.findall(r"@(P[123])\b", s)
        for i in ids:
            out[i] = pri[0] if pri else None
    return out


def recompute_total(m):
    """SKILL.md step 1: 'Recompute the rubric total from the 10 dimensions scores yourself --
    never trust gate.score as given.' The contract only stores dimensions scored < 2
    (OUTPUT-CONTRACT.md line 87), so unlisted dimensions are taken as 2."""
    dims = (m.get("gate") or {}).get("dimensions") or []
    return 20 - sum(2 - d["score"] for d in dims), dims


def verdict(m, prio=None):
    prio = prio or {}
    reasons, cleared = [], []
    total, dims = recompute_total(m)
    gate = m.get("gate") or {}
    stated = gate.get("score")
    if stated is not None and stated != total:
        reasons.append(f"score mismatch: dimensions sum to {total}, manifest said {stated} -- using {total}")

    design = m.get("design") or {}
    cov = design.get("coverage") or {}
    ex = m.get("execution")
    fail = []

    # --- Rule 1: FAIL (hard gates) ---
    if cov.get("acCovered") is not None and cov.get("acCovered") < cov.get("acTotal", 0):
        fail.append(f"AC coverage hard gate: acCovered {cov['acCovered']} < acTotal {cov['acTotal']}")
    if cov.get("reqNegCovered") is not None and cov.get("reqNegCovered") < cov.get("reqNegTotal", 0):
        fail.append(f"ADR 0001 req-neg hard gate: reqNegCovered {cov['reqNegCovered']} < reqNegTotal {cov['reqNegTotal']}")
    for d in dims:
        if d["score"] == 0:
            fail.append(f"dim {d['n']} ({d['name']}) = 0 -- any rubric dimension at 0 is a hard FAIL")
    if ex and ex.get("failed", 0) > 0:
        fail.append(f"execution reports failed={ex['failed']}")
    if fail:
        return "FAIL", reasons + fail, total

    # --- Rule 2: CONCERNS ---
    conc = []
    if total < 16:
        conc.append(f"rubric total {total} < 16 (release gate) with no dimension at 0")
    arb = m.get("openArbitrations") or []
    if arb:
        conc.append(f"{len(arb)} unresolved openArbitrations ({', '.join(a['id'] for a in arb)}) -- caps at CONCERNS until human decision")
    fl = m.get("flakiness") or {}
    p1_flaky, other_flaky = [], []
    for f in fl.get("flaky", []):
        tid = f["testId"]
        p = prio.get(tid) or f.get("priority")
        (p1_flaky if p == "P1" else other_flaky).append(f"{tid} ({p or 'priority unknown'}, {f.get('passRate')})")
    if p1_flaky:
        conc.append("flaky @P1 scenario(s): " + "; ".join(p1_flaky))
    if other_flaky:
        conc.append("[reported, not blocking] flaky non-P1 scenario(s): " + "; ".join(other_flaky))
    if ex and ex.get("blocked", 0) > 0:
        conc.append(f"execution blocked={ex['blocked']}")
    if ex:
        t = ex.get("traceability") or {}
        if t.get("scenariosTotal") and t.get("scenariosAutomated", 0) < 0.5 * t["scenariosTotal"]:
            conc.append(f"automation coverage {t['scenariosAutomated']}/{t['scenariosTotal']} materially below the book")
    # a non-P1 flake alone must NOT force CONCERNS (SKILL.md lines 43-44)
    blocking = [c for c in conc if not c.startswith("[reported, not blocking]")]
    if blocking:
        return "CONCERNS", reasons + conc, total

    # --- Rule 3: PASS ---
    cleared = ["AC coverage complete", "all required negative conditions covered",
               f"rubric total {total} >= 16, no dimension at 0", "no pending arbitration"]
    if ex:
        cleared.append(f"execution failed=0, blocked=0")
    return "PASS", reasons + conc + cleared, total

    # --- Rule 4: WAIVED is deliberately unreachable from code: SKILL.md line 47 --
    # "Never self-granted: only a recorded human decision produces it."


if __name__ == "__main__":
    mpath = sys.argv[1]
    prio = {}
    if "--feature" in sys.argv:
        prio = priorities_from_feature(sys.argv[sys.argv.index("--feature") + 1])
    m = json.load(open(mpath, encoding="utf-8"))
    v, reasons, total = verdict(m, prio)
    print(json.dumps({"manifest": mpath, "recomputedTotal": total, "verdict": v, "reasons": reasons},
                     ensure_ascii=False, indent=2))
