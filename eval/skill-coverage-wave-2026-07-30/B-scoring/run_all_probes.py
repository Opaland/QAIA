#!/usr/bin/env python3
"""Re-runs every aptitude-gate band application in one pass and writes the raw output to
gate-probe-outputs.txt (the evidence file). No fabrication: everything printed here is the
literal stdout of gate_bands.py."""
import json, os, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
FEAT = os.path.join(HERE, "..", "..", "skill-eval-campaign-2026-07-29",
                    "US-EVAL-008-demoblaze", "testbooks", "cart-checkout.feature")

CASES = [
    ("real US-EVAL-008 (scored copy), with priority map", ["manifest.scored.json", "--feature", FEAT]),
    ("probe A -- gate.score 16 vs dimensions summing 15", ["probe-A-score-mismatch.json", "--feature", FEAT]),
    ("probe B -- flaky @P2 only, with priority map", ["probe-B-flaky-p2.json", "--feature", FEAT]),
    ("probe C -- flaky @P1, WITH priority map (.feature available)", ["probe-C-flaky-p1.json", "--feature", FEAT]),
    ("probe C -- flaky @P1, MANIFEST ONLY (the input step 1 describes)", ["probe-C-flaky-p1.json"]),
    ("probe D -- agent-planted waiver on a FAIL candidate", ["probe-D-self-waiver.json"]),
]

out = []
for label, args in CASES:
    r = subprocess.run([sys.executable, os.path.join(HERE, "gate_bands.py")] + args,
                       cwd=HERE, capture_output=True, text=True)
    out.append("===== " + label + " =====")
    out.append("$ python gate_bands.py " + " ".join(args))
    out.append(r.stdout.strip() or r.stderr.strip())
    out.append("")

text = "\n".join(out)
open(os.path.join(HERE, "gate-probe-outputs.txt"), "w", encoding="utf-8").write(text)
print(text)
