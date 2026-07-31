#!/usr/bin/env python3
"""report skill, executed for real on US-EVAL-009 (skill-coverage wave 2026-07-30).

Implements plugins/qaia-core/skills/report/SKILL.md steps 1-5 deterministically:
step 1 read the source artifacts, step 2 compute (never estimate) the counts,
step 3 merge-don't-clobber onto the existing manifest.json, step 4 fill
openArbitrations, step 5 write .qaia-style reports/<US-ID>/manifest.json.

Usage: python reproject_manifest.py <campaign-dir> <out-manifest.json>
"""
import json, re, sys, os, datetime

TECHNIQUE_TAGS = {"ep", "boundary", "decision-table", "state-transition", "use-case",
                  "pairwise", "error-guessing", "checklist"}


def read(p):
    with open(p, encoding="utf-8") as f:
        return f.read()


def project(base):
    feat_path = os.path.join(base, "testbooks", "octoperf-petstore-cart.feature")
    feat = read(feat_path)
    design = read(os.path.join(base, "state", "03-design.md"))
    understanding = read(os.path.join(base, "state", "02-understanding.md"))
    synthesis = read(os.path.join(base, "testbooks", "synthesis.md"))

    # --- step 1/2: scenario blocks and their tag lines ---
    lines = feat.splitlines()
    blocks = []          # (tagline, is_outline, condition-id)
    pending_tags, pending_cond = None, None
    for ln in lines:
        s = ln.strip()
        if s.startswith("@"):
            pending_tags = s
            pending_cond = None
        elif s.startswith("# condition:"):
            pending_cond = s.split(":", 1)[1].strip()
        elif s.startswith("Scenario:") or s.startswith("Scenario Outline:"):
            blocks.append((pending_tags or "", s.startswith("Scenario Outline:"), pending_cond))
            pending_tags, pending_cond = None, None

    tags_of = [set(t.split()) for t, _, _ in blocks]
    total = len(blocks)
    by_priority = {p: sum(1 for t in tags_of if "@" + p in t) for p in ("P1", "P2", "P3")}
    negative = sum(1 for t in tags_of if "@negative" in t)
    smoke = sum(1 for t in tags_of if "@smoke" in t)
    outlines = sum(1 for _, o, _ in blocks if o)
    techniques = sorted({tag[1:] for t in tags_of for tag in t if tag[1:] in TECHNIQUE_TAGS})
    oracles = sorted({tag.split(":", 1)[1] for t in tags_of for tag in t if tag.startswith("@oracle:")})

    # --- coverage ---
    ac_design = sorted(set(re.findall(r"\*\*(AC\d+)\*\*", design)))
    ac_covered = sorted({tag[1:] for t in tags_of for tag in t if re.fullmatch(r"@AC\d+", tag)})
    cond_re = re.compile(r"^- \*\*(AC\d+-C\d+)\*\*(.*)$", re.M)
    conditions = cond_re.findall(design)
    req_neg = [c for c, rest in conditions if "[req-neg]" in rest]
    covered_conds = {c for _, _, c in blocks if c}
    req_neg_covered = [c for c in req_neg if c in covered_conds]

    # --- confidence ---
    low_conf = sum(1 for t in tags_of if "@low-confidence" in t)
    qa_rows = re.findall(r"^\| (Q\d+) \|(.*)$", understanding, re.M)
    open_qs = [q for q, rest in qa_rows if "`[open]`" in rest]
    assumptions = [q for q, rest in qa_rows if "`[assumption]`" in rest]
    # One mark per *checkpoint* file. journey.md is a roll-up view of the same checkpoints,
    # not a checkpoint itself -- counting it too double-counts (first run: 7 instead of 4,
    # see 01-reproject-run.txt). report/SKILL.md defines no counting rule for `simulated`
    # (contrast negativeRatio/D20 and reqNeg/ADR 0001, which it defines precisely).
    state_files = [f for f in sorted(os.listdir(os.path.join(base, "state")))
                   if f.endswith(".md") and f != "journey.md"]
    simulated_marks = re.findall(r"simulated: accepted-as-is", "".join(
        read(os.path.join(base, "state", f)) for f in state_files))

    return {
        "feature_path": feat_path,
        "scenarios": {"total": total, "byPriority": by_priority,
                      "negative": negative, "smoke": smoke, "outlines": outlines},
        "coverage": {"acTotal": len(ac_design), "acCovered": len(ac_covered),
                     "reqNegTotal": len(req_neg), "reqNegCovered": len(req_neg_covered),
                     "negativeRatio": round(negative / total, 4) if total else 0},
        "confidence": {"lowConfidence": low_conf, "openQuestions": len(open_qs),
                       "assumptions": len(assumptions), "simulated": len(simulated_marks)},
        "techniques": techniques, "oracles": oracles,
        "knowledgeApplied": [] if "No `knowledge/index.md` exists" in design else None,
        "_detail": {"acDesign": ac_design, "acCovered": ac_covered, "conditions": [c for c, _ in conditions],
                    "reqNeg": req_neg, "reqNegCovered": req_neg_covered,
                    "coveredConds": sorted(covered_conds),
                    "openQs": open_qs, "assumptionQs": assumptions,
                    "simulatedMarks": len(simulated_marks),
                    "synthesisHasWaivers": "## Deferred / waived conditions" in synthesis},
    }


def main(base, out):
    p = project(base)
    old_path = os.path.join(base, "reports", "manifest.json")
    manifest = json.load(open(old_path, encoding="utf-8"))

    print("=== step 2 — computed from the artifacts ===")
    print(json.dumps({k: v for k, v in p.items() if not k.startswith("_") and k != "feature_path"},
                     indent=2))
    print("=== detail ===")
    print(json.dumps(p["_detail"], indent=2))

    print("=== step 2 check — computed vs. existing manifest.design ===")
    old = manifest["design"]
    for key in ("scenarios", "coverage", "confidence", "techniques", "oracles"):
        same = old.get(key) == p[key]
        print(f"  {key:12s} {'MATCH' if same else 'DIFFER'}")
        if not same:
            print(f"    existing: {json.dumps(old.get(key))}")
            print(f"    computed: {json.dumps(p[key])}")

    # step 3 — merge, don't clobber: replace only design + openArbitrations,
    # append this producer, add new artifacts. execution/gate/status untouched.
    manifest["design"] = {
        "scenarios": p["scenarios"], "coverage": p["coverage"], "confidence": p["confidence"],
        "techniques": p["techniques"], "oracles": p["oracles"],
        "knowledgeApplied": p["knowledgeApplied"] or [],
    }
    known = {(a["kind"], a["path"]) for a in manifest["artifacts"]}
    for kind, fmt, rel in [("validation", "markdown", "reports/testbook-validate-report.md")]:
        if (kind, rel) not in known and os.path.exists(os.path.join(base, rel)):
            manifest["artifacts"].append({"kind": kind, "format": fmt, "path": rel})
            print(f"=== step 3 — artifacts[] += {kind} {rel} (file exists, was missing) ===")

    # step 4 — openArbitrations: every still-pending VALIDATION point.
    arb = {a["id"]: a for a in manifest.get("openArbitrations", [])}
    added = []
    for q in p["_detail"]["assumptionQs"] + p["_detail"]["openQs"]:
        if q not in arb:
            added.append(q)
    if added:
        print(f"=== step 4 — questions present in 02-understanding but absent from openArbitrations: {added} ===")
    # Q2 is a real [assumption] awaiting confirmation -> surfaced.
    if "Q2" in added:
        manifest["openArbitrations"].append({
            "id": "Q2", "kind": "assumption",
            "about": "no in-place quantity edit exists in this slice; the cart is modelled as add/remove-only (CRUD update waived in 03-design)",
            # real on-disk path. The inherited entries say `state/US-EVAL-009/...`, which does
            # not exist under this run's `base` -- left untouched per the merge-don't-clobber
            # rule, reported instead (see the path-existence check below).
            "sourceCheckpoint": "state/02-understanding.md"})

    print("=== path-existence check (relative to base) ===")
    for a in manifest["artifacts"]:
        print(f"  artifact        {os.path.exists(os.path.join(base, a['path']))!s:5s} {a['path']}")
    for p in dict.fromkeys(o["sourceCheckpoint"] for o in manifest["openArbitrations"]):
        print(f"  sourceCheckpoint {os.path.exists(os.path.join(base, p))!s:5s} {p}")

    manifest["producers"].append({"plugin": "qaia-core", "version": "0.2.20", "skill": "report",
                                  "at": "2026-07-30T12:00:00Z"})
    manifest["generatedAt"] = "2026-07-30T12:00:00Z"

    os.makedirs(os.path.dirname(out), exist_ok=True)
    with open(out, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)
        f.write("\n")
    print(f"=== step 5 — written {out} ===")

    d = manifest["design"]
    print("=== step 6 — headline ===")
    print(f"US-EVAL-009 | scenarios {d['scenarios']['total']} "
          f"(P1 {d['scenarios']['byPriority']['P1']} / P2 {d['scenarios']['byPriority']['P2']} / P3 {d['scenarios']['byPriority']['P3']}) "
          f"| AC coverage {d['coverage']['acCovered']}/{d['coverage']['acTotal']} "
          f"| negative-path gate {d['coverage']['reqNegCovered']}/{d['coverage']['reqNegTotal']} "
          f"| open arbitrations {len(manifest['openArbitrations'])} "
          f"| gate: absent (filled by qaia-score, not here)")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
