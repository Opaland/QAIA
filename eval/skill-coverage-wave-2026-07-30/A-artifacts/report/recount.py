#!/usr/bin/env python3
"""report skill, step 2 -- recompute every manifest count from the source artifacts.

Run: python eval/skill-coverage-wave-2026-07-30/A-artifacts/report/recount.py
No estimation: each number below is derived by parsing the .feature / checkpoint files.
"""
import re, sys, os, json, collections

BASE = os.path.join("eval", "skill-eval-campaign-2026-07-29", "US-EVAL-009-octoperf-petstore")
FEATURE = os.path.join(BASE, "testbooks", "octoperf-petstore-cart.feature")
DESIGN = os.path.join(BASE, "state", "03-design.md")
UNDERSTANDING = os.path.join(BASE, "state", "02-understanding.md")
MATRIX = os.path.join(BASE, "testbooks", "coverage-matrix.md")


def read(p):
    return open(p, encoding="utf-8").read()


feature = read(FEATURE)
lines = feature.splitlines()

# --- scenario blocks: a tag line followed (possibly after comments) by Scenario:/Scenario Outline:
blocks = []
current_tags = None
for ln in lines:
    s = ln.strip()
    if s.startswith("@"):
        current_tags = s.split()
    elif s.startswith("Scenario Outline:") or s.startswith("Scenario:"):
        blocks.append({
            "tags": current_tags or [],
            "outline": s.startswith("Scenario Outline:"),
            "title": s.split(":", 1)[1].strip(),
        })
        current_tags = None

total = len(blocks)
by_pri = collections.Counter()
for b in blocks:
    pri = [t for t in b["tags"] if t in ("@P1", "@P2", "@P3")]
    by_pri[pri[0][1:] if pri else "NONE"] += 1
negative = sum(1 for b in blocks if "@negative" in b["tags"])
smoke = sum(1 for b in blocks if "@smoke" in b["tags"])
outlines = sum(1 for b in blocks if b["outline"])
low_conf = sum(1 for b in blocks if "@low-confidence" in b["tags"])

TECH = {"@ep", "@boundary", "@decision-table", "@state-transition", "@use-case", "@pairwise",
        "@error-guessing", "@checklist"}
techniques, oracles, acs = [], [], set()
for b in blocks:
    for t in b["tags"]:
        if t in TECH and t[1:] not in techniques:
            techniques.append(t[1:])
        if t.startswith("@oracle:") and t.split(":", 1)[1] not in oracles:
            oracles.append(t.split(":", 1)[1])
        if re.fullmatch(r"@AC\d+", t):
            acs.add(t[1:])

design = read(DESIGN)
# conditions declared in 03-design.md "## Test conditions"
cond_section = design.split("## Test conditions", 1)[1]
conds = re.findall(r"^- \*\*(AC\d+-C\d+)\*\*(.*)$", cond_section, re.M)
ac_total = len({c.split("-")[0] for c, _ in conds})
req_neg_conds = [c for c, rest in conds if "[req-neg]" in rest]
# a req-neg condition is covered if a scenario carries "# condition: <id>"
covered_conds = set(re.findall(r"#\s*condition:\s*(AC\d+-C\d+)", feature))
req_neg_covered = [c for c in req_neg_conds if c in covered_conds]

# confidence, from 02-understanding.md Q&A log
qa = read(UNDERSTANDING).split("## Q&A log", 1)[1].split("## Journey", 1)[0]
rows = [r for r in qa.splitlines() if r.strip().startswith("| Q")]
assumptions = sum(1 for r in rows if "[assumption]" in r)
open_qs = sum(1 for r in rows if "[open]" in r)

# simulated VALIDATION points across every checkpoint
simulated = []
for f in sorted(os.listdir(os.path.join(BASE, "state"))):
    if f == "journey.md":
        continue
    txt = read(os.path.join(BASE, "state", f))
    for ln in txt.splitlines():
        if "simulated" in ln and "VALIDATION" in ln:
            simulated.append(f)

out = {
    "scenarios": {"total": total, "byPriority": {"P1": by_pri["P1"], "P2": by_pri["P2"], "P3": by_pri["P3"]},
                  "negative": negative, "smoke": smoke, "outlines": outlines},
    "coverage": {"acTotal": ac_total, "acCovered": len(acs),
                 "reqNegTotal": len(req_neg_conds), "reqNegCovered": len(req_neg_covered),
                 "negativeRatio": round(negative / total, 3) if total else 0},
    "confidence": {"lowConfidence": low_conf, "openQuestions": open_qs, "assumptions": assumptions,
                   "simulated": len(simulated)},
    "techniques": techniques, "oracles": oracles,
    "_debug": {"conditionsDeclared": [c for c, _ in conds], "conditionsCovered": sorted(covered_conds),
               "reqNegConditions": req_neg_conds, "acTagsSeen": sorted(acs),
               "simulatedCheckpoints": simulated, "byPriorityRaw": dict(by_pri)},
}
print(json.dumps(out, indent=2))
