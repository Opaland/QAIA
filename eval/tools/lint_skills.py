#!/usr/bin/env python3
"""Lint every SKILL.md against the skill-authoring norm and this project's own rules.

Why this exists. The 2026-07-31 cold-read review by four business personas (Directeur QA,
Automaticien expert, Lead QA, PM/PO) scored the 29 skills on sense, clarity, size and format.
Sense came out at 2.87/3 — nobody struggles to understand *what* a skill does. Clarity came out
at 2.09 with ten skills at or below 1.75: the catalogue explains itself well and executes badly.
Several of the defects behind that gap are mechanical, and a mechanical defect that is only ever
caught by a human review comes back the next time nobody reviews.

So: the checks below are the ones a machine can decide. Everything requiring judgement — is this
instruction actually followable, is this the right technique — stays with human and LLM review,
and this tool deliberately says nothing about it.

FAIL (exit 1) — objectively wrong, blocks CI:
  - frontmatter missing, unterminated, or `name` not matching the directory
  - description missing, or with no trigger clause: the description is the whole triggering
    mechanism, and one that only says what the skill *does* leaves the model no reason to invoke
    it. Under-triggering is the dominant failure mode, so a skill with no "use when…" is
    effectively unreachable outside a scripted journey.
  - body over 500 lines (the authoring norm's ceiling — past it, split into references/ with a
    pointer rather than trimming content)
  - an unconditional `= done` on a journey step: a validation gate that writes itself done is
    the exact bypass the shared contract's rule 3 exists to prevent.

WARN (exit 0, printed) — worth knowing, not worth blocking:
  - density over 150 characters per line. The review's sharpest finding: size scores correlate
    with density, not length. The best-rated skills sit between 66 and 100 c/line; the worst
    between 150 and 245. `us-ingest` is 31 lines long and still unreadable — it is compacted,
    not long. Density is a smell, not a defect, so it warns.
  - description outside 120-600 characters (thin ones under-trigger, long ones dilute)
  - internal codes (D125, Q35, #41) and campaign dates in the body. All four personas asked for
    this, unanimously — but it is a readability debt, not a correctness one.

Usage:
  python eval/tools/lint_skills.py [--strict] [path ...]
    --strict  promote warnings to failures
    path      specific SKILL.md files (default: every SKILL.md under plugins/)
"""

import os
import re
import sys

NORM_MAX_LINES = 500
DENSITY_WARN = 150
DESC_MIN, DESC_MAX = 120, 600

# A description triggers when it says *when* to reach for the skill, not only what it does.
# "Use whenever…" and "Use right after…" are as valid as "Use when…", so match the verb plus any
# ordinary continuation rather than a closed list of next words — the first draft of this regex
# rejected a description it had itself just been written to accept.
TRIGGER = re.compile(r"\bUse\s+(when|whenever|for|to|it|this|after|before|right|on|during|in)\b", re.I)
# `step X = done` with nothing making it conditional on the validation having happened.
UNCONDITIONAL_DONE = re.compile(r"step\s+`?[\w-]+`?\s*=\s*done(?!\s*\*{0,2}only)", re.I)
INTERNAL_CODE = re.compile(r"(?<![A-Za-z0-9])(?:D\d{1,3}|T\d{1,2}|Q\d{1,3}|ADR\s*\d{4}|#\d{1,3})(?![A-Za-z0-9])")
CAMPAIGN_DATE = re.compile(r"\b20\d{2}-\d{2}-\d{2}\b")


def find_skills(paths):
    if paths:
        return list(paths)
    out = []
    for root, dirs, files in os.walk("plugins"):
        dirs[:] = [d for d in dirs if d not in ("node_modules", ".git")]
        if "SKILL.md" in files and os.path.basename(root) != "skills":
            out.append(os.path.join(root, "SKILL.md"))
    return sorted(out)


def parse_frontmatter(lines):
    """Return (fields, body_start_index, error)."""
    if not lines or lines[0].strip() != "---":
        return {}, 0, "no YAML frontmatter (a skill must open with ---)"
    try:
        end = lines.index("---", 1)
    except ValueError:
        return {}, 0, "frontmatter opened with --- but never closed"
    fields, key = {}, None
    for raw in lines[1:end]:
        if not raw.strip():
            continue
        if re.match(r"^\s", raw) and key:          # continuation of a folded value
            fields[key] += " " + raw.strip()
            continue
        if ":" not in raw:
            return fields, end + 1, "frontmatter line is not a key: value pair -> %r" % raw[:60]
        key, val = raw.split(":", 1)
        key = key.strip()
        fields[key] = val.strip()
    return fields, end + 1, None


def lint_one(path):
    fails, warns = [], []
    text = open(path, encoding="utf-8", errors="replace").read()
    lines = text.split("\n")
    skill_dir = os.path.basename(os.path.dirname(path))

    fields, body_start, fm_err = parse_frontmatter(lines)
    if fm_err:
        fails.append(fm_err)
        return fails, warns

    name = fields.get("name")
    if not name:
        fails.append("frontmatter has no `name`")
    elif name != skill_dir:
        fails.append("`name: %s` does not match its directory %r — the two must agree or the "
                     "skill cannot be addressed reliably" % (name, skill_dir))

    desc = fields.get("description", "")
    if not desc:
        fails.append("frontmatter has no `description` — nothing would ever trigger this skill")
    else:
        if not TRIGGER.search(desc):
            fails.append("description never says WHEN to use the skill (no \"Use when/for/to …\"). "
                         "It is the only triggering signal the model gets; without it the skill is "
                         "reachable only by someone already following a scripted journey.")
        if len(desc) < DESC_MIN:
            warns.append("description is thin (%d chars, under %d) — likely to under-trigger"
                         % (len(desc), DESC_MIN))
        elif len(desc) > DESC_MAX:
            warns.append("description is long (%d chars, over %d) — the trigger dilutes"
                         % (len(desc), DESC_MAX))

    body = lines[body_start:]
    if len(lines) > NORM_MAX_LINES:
        fails.append("%d lines, over the %d-line authoring ceiling — move material into "
                     "references/ with a pointer rather than cutting it" % (len(lines), NORM_MAX_LINES))

    non_empty = [l for l in body if l.strip()]
    if non_empty:
        density = sum(len(l) for l in non_empty) / len(non_empty)
        if density > DENSITY_WARN:
            warns.append("%.0f characters per line — dense enough to read as a wall. The "
                         "best-rated skills sit between 66 and 100; length is not the problem, "
                         "compaction is." % density)

    for i, line in enumerate(body, start=body_start + 1):
        if UNCONDITIONAL_DONE.search(line):
            fails.append("line %d marks a journey step `= done` unconditionally. A validation gate "
                         "that writes itself done is the bypass rule 3 exists to prevent — make it "
                         "conditional on the validation actually happening." % i)

    codes = INTERNAL_CODE.findall("\n".join(body))
    dates = CAMPAIGN_DATE.findall("\n".join(body))
    if codes:
        warns.append("%d internal code reference(s) (%s…) — unreadable to anyone without the "
                     "project's history; gloss on first use or move to references/"
                     % (len(codes), ", ".join(sorted(set(codes))[:4])))
    if dates:
        warns.append("%d campaign date(s) in the body — a skill is a specification, not a changelog"
                     % len(dates))

    return fails, warns


def main(argv):
    strict = "--strict" in argv
    paths = [a for a in argv if not a.startswith("--")]
    targets = find_skills(paths)
    if not targets:
        print("no SKILL.md found")
        return 2

    n_fail = n_warn = 0
    for path in targets:
        fails, warns = lint_one(path)
        n_fail += len(fails)
        n_warn += len(warns)
        if fails or warns:
            print("%s" % path)
            for f in fails:
                print("  FAIL  %s" % f)
            for w in warns:
                print("  warn  %s" % w)

    print("\n%d skill(s) linted — %d failure(s), %d warning(s)" % (len(targets), n_fail, n_warn))
    if n_fail:
        return 1
    if strict and n_warn:
        print("--strict: warnings promoted to failures")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
