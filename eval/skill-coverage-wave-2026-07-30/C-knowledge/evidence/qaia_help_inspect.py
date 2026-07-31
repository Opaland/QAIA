#!/usr/bin/env python3
"""Execute qaia-help/SKILL.md step 1's read-allowlist LITERALLY against real project roots.

Allowlist (SKILL.md line 12), nothing else may be opened:
  state/*/journey.md | knowledge/index.md | feedback/rules.md | testbooks/*/
"""
import glob
import os
import sys

ROOTS = [
    ".",                                                              # repo root (no .qaia/)
    "eval/skill-eval-campaign-2026-07-29/US-EVAL-009-octoperf-petstore",  # campaign output root
    "eval/baselines/feedback-token-pilot/US-004",
    "examples/carpool-demo",
    "examples/rag-demo",
]

for root in ROOTS:
    print("=" * 72)
    print("ROOT:", root)
    qaia = os.path.join(root, ".qaia")
    base = qaia if os.path.isdir(qaia) else root
    print("  .qaia/ present:", os.path.isdir(qaia), "-> inspecting base:", base)
    journeys = sorted(glob.glob(os.path.join(base, "state", "*", "journey.md")))
    print("  state/*/journey.md  ->", journeys if journeys else "NONE MATCHED")
    stray = sorted(glob.glob(os.path.join(base, "state", "journey.md")))
    if stray:
        print("  !! journey.md found OUTSIDE the allowlist glob, at state/journey.md:", stray)
    ki = os.path.join(base, "knowledge", "index.md")
    print("  knowledge/index.md  ->", ki if os.path.isfile(ki) else "ABSENT")
    fr = os.path.join(base, "feedback", "rules.md")
    print("  feedback/rules.md   ->", fr if os.path.isfile(fr) else "ABSENT")
    tb = sorted(glob.glob(os.path.join(base, "testbooks", "*")))
    print("  testbooks/*/        ->", [os.path.basename(x) for x in tb] or "ABSENT")
    rep = sorted(glob.glob(os.path.join(base, "reports", "*")))
    print("  (reports/ exists but is NOT in the allowlist) ->",
          [os.path.basename(x) for x in rep] or "ABSENT")
sys.exit(0)
