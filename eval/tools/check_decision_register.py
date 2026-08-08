#!/usr/bin/env python3
"""Fail when a commit names a decision that `docs/DECISIONS.md` does not carry.

Why this exists. On 2026-08-08 the same defect occurred **three times in one day**:

- morning — D147 to D153 were labelled in commit messages and existed nowhere in the register.
  Found, filled, and committed with a message explaining that *"commit messages are not the
  project's memory; DECISIONS.md is"*.
- four hours later — D154 to D157 were in exactly the same state. Found by a blank-context review
  panel, filled again.
- the same evening — D159 to D162, again.

Three corrections, one lesson written down twice, and the defect came back within hours each time.
That is the signal that a rule is not enforceable by intention: the register is edited by hand at
the end of a task, and the end of a task is precisely when attention is lowest.

## The rule

**A commit that names a decision must register it in the same commit.**

Referencing an already-registered decision is fine — `see D147` passes because D147 is in the
file. Only a decision that exists nowhere in `docs/DECISIONS.md` fails.

The check reads the **HEAD commit message only**, so it works on the shallow clone CI uses and it
fires at the moment the omission happens, rather than accumulating a backlog nobody reconciles.

Run: python eval/tools/check_decision_register.py
Exit 0 every named decision is registered, 1 at least one is missing, 2 no git history available.
"""
import io
import os
import re
import subprocess
import sys

REGISTER = os.path.join("docs", "DECISIONS.md")
DECISION = re.compile(r"\bD(\d{1,4})\b")


def head_message():
    try:
        out = subprocess.check_output(["git", "log", "-1", "--format=%B"],
                                      stderr=subprocess.STDOUT)
    except (subprocess.CalledProcessError, OSError) as e:
        return None, str(e)
    return out.decode("utf-8", "replace"), None


def registered():
    if not os.path.isfile(REGISTER):
        return None
    ids = set()
    for line in io.open(REGISTER, encoding="utf-8", errors="replace"):
        m = re.match(r"\|\s*D(\d{1,4})\s*\|", line)
        if m:
            ids.add(int(m.group(1)))
    return ids


def main():
    msg, err = head_message()
    if msg is None:
        print("BROKEN: no git history available (%s)." % err)
        return 2
    known = registered()
    if known is None:
        print("BROKEN: %s not found -- run from the repository root." % REGISTER)
        return 2

    named = sorted({int(n) for n in DECISION.findall(msg)})
    missing = [n for n in named if n not in known]

    if missing:
        print("DECISION NOT REGISTERED: the HEAD commit names %s, absent from %s.\n"
              % (", ".join("D%d" % n for n in missing), REGISTER))
        print("  A commit that names a decision must register it in the same commit.")
        print("  Commit messages are not the project's memory: DECISIONS.md is.\n")
        print("  Highest registered: D%d" % (max(known) if known else 0))
        return 1

    if not named:
        print("OK: the HEAD commit names no decision.")
    else:
        print("OK: %s registered." % ", ".join("D%d" % n for n in named))
    return 0


if __name__ == "__main__":
    sys.exit(main())
