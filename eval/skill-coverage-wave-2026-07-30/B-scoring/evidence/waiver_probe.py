#!/usr/bin/env python3
"""Probe: is aptitude-gate's 'WAIVED is never self-granted' rule enforced by anything
OTHER than the prose of the SKILL.md?

This builds a manifest that CLAIMS a waiver with no recorded human decision
(verdict WAIVED, waiver null) and runs the project's own contract validator on it.
It is written to evidence/, NOT to any real run directory, and is never adopted as
this evaluation's verdict -- the real verdict stays FAIL in manifest.copy.json.
"""
import json, os, copy

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.dirname(HERE)

m = json.load(open(os.path.join(OUT, "manifest.copy.json"), encoding="utf-8"))
m["_synthetic"] = ("FABRICATED PROBE -- tests whether a self-granted WAIVED is mechanically "
                   "rejected. Not a verdict. No human accepted anything.")
m["gate"]["verdict"] = "WAIVED"
m["gate"]["waiver"] = None
p = os.path.join(HERE, "waiver-selfgrant-probe.manifest.json")
json.dump(m, open(p, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
print("wrote", p)
