#!/usr/bin/env python3
"""PostToolUse hook: lint a SKILL.md the moment it is edited or written.

Why it exists. The 2026-07-31 cold-read review found defects that are cheap to make and
expensive to notice: a description that never says *when* to use the skill (so nothing triggers
it), a journey step marked `= done` unconditionally (the validation bypass rule 3 forbids), a
`name` that drifted from its directory. CI already catches these, but CI catches them after the
fact — sometimes several commits later, which is exactly how the Gherkin lint broke silently and
motivated the post-push CI hook next to this one.

This closes the loop at the point of authoring: the linter runs on the single file that was just
touched, and only interrupts when that file has a blocking defect. Warnings (density, internal
codes, campaign dates) stay silent here — they are readability debt, tracked deliberately, and a
hook that fires on debt trains people to ignore the hook.

Contract: reads the hook payload on stdin, exits 0 to stay silent, exits 2 to surface a blocking
error to the model. Never blocks on anything but a lint failure — no network, no writes.

jq is deliberately not used: it is absent from this environment (verified 2026-07-31), and a hook
that silently does nothing is worse than no hook.
"""

import json
import os
import subprocess
import sys

try:
    payload = json.load(sys.stdin)
except Exception:
    sys.exit(0)                      # malformed payload is the harness's problem, not ours

tool_input = payload.get("tool_input") or {}
tool_response = payload.get("tool_response") or {}
path = tool_input.get("file_path") or tool_response.get("filePath") or ""

if not path.replace("\\", "/").endswith("SKILL.md"):
    sys.exit(0)

root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
linter = os.path.join(root, "eval", "tools", "lint_skills.py")
if not os.path.isfile(linter) or not os.path.isfile(path):
    sys.exit(0)                      # linter or target moved: stay quiet rather than cry wolf

try:
    run = subprocess.run([sys.executable, linter, path],
                         capture_output=True, text=True, timeout=60, cwd=root)
except Exception:
    sys.exit(0)

if run.returncode != 0:
    out = (run.stdout or "") + (run.stderr or "")
    fails = [l for l in out.split("\n") if "FAIL" in l]
    print("Lint SKILL.md — %s\n%s" % (path, "\n".join(fails) if fails else out.strip()))
    sys.exit(2)

sys.exit(0)
