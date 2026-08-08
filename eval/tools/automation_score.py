#!/usr/bin/env python3
"""Deterministic quality score for QAIA-generated Playwright test code.

Companion to `structural_score.py`, which does the same job for the Gherkin test book.
This tool judges the *generated automation* — the layer that, until now, was only ever
reviewed by its own producer (`automate` SKILL.md step 4), in violation of the project's
own rule 3 ("a producer plugin never grades its own output",
`plugins/qaia-score/README.md:26`).

It carries the two tracks that can be made mechanical and reproducible:

  STATIC    — reads the test files without running them: hollow assertions, fragile
              selectors, POM-as-fixtures compliance, forbidden waits, tag traceability
              back to the test book.

  MUTATION  — inverts the expectation of each assertion, re-runs the owning test, and
              requires it to go RED. An assertion that survives its own inversion is
              decorative: it cannot fail, so it tests nothing. Survivors are BLOCKING,
              in the same spirit as `structural_score.py`'s C1/C2 detectors.

              The mutation is applied to the TEST, never to the system under test — so the
              track works against any target, including public sites we do not own, and the
              score stays comparable from run to run. Honest limit, stated here rather than
              buried: this proves an assertion is sensitive to its own expected value; it
              does NOT prove it asserts the *right* thing. That second question is the LLM
              judge's job (`eval/AUTOMATION-RUBRIC.md`), and the two are never merged.

What this tool deliberately does NOT do: judge intent, business fidelity, or whether the
test matches the scenario's `Then`. Those are not mechanical. The LLM rubric owns them, and
its number is reported separately — never summed with this one. That separation is the
lesson of case US 676266 (100/100 machine vs 58/100 human), see `eval/RUBRIC.md`.

Parsing is regex-based, not a real JS parser. This is a deliberate trade-off (no Node
dependency for the static track) and it means unusual formatting can be missed. Every
finding therefore carries its file and line so a human can check it; a MISSED defect is
possible, a FABRICATED one is not.

Usage:
  python eval/tools/automation_score.py --tests-dir <dir> [--testbook <dir-or-file>]
      [--run-cwd <dir>] [--run-cmd "npx playwright test"] [--max-mutations N]
      [--skip-mutation] [--out result.json]
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

SPEC_GLOB = re.compile(r"\.spec\.(js|ts|mjs|cjs)$")

# --------------------------------------------------------------------------- static track

FORBIDDEN_WAITS = [
    (re.compile(r"waitForTimeout\s*\("), "waitForTimeout"),
    (re.compile(r"networkidle"), "networkidle"),
    (re.compile(r"waitForLoadState\s*\(\s*['\"]networkidle"), "waitForLoadState(networkidle)"),
]

# Assertions that can never fail, whatever the app does. Blocking.
HOLLOW_ASSERTIONS = [
    (re.compile(r"expect\s*\(\s*true\s*\)\s*\.\s*toBe\s*\(\s*true\s*\)"), "expect(true).toBe(true)"),
    (re.compile(r"expect\s*\(\s*1\s*\)\s*\.\s*toBe\s*\(\s*1\s*\)"), "expect(1).toBe(1)"),
    (re.compile(r"expect\s*\(\s*\)\s*\."), "expect() with no subject"),
    (re.compile(r"\.\s*toBeDefined\s*\(\s*\)"), "toBeDefined() (a locator handle always exists)"),
]

# Assertions that CAN fail but carry little information. Reported, never blocking — the
# distinction matters: `expect(cart.items.some(i => i.id === x)).toBeTruthy()` is a real
# check on real data, and blocking on it wrongly failed US-EVAL-002 in this tool's own
# first run. Weak is not hollow.
WEAK_ASSERTIONS = [
    (re.compile(r"\.\s*toBeTruthy\s*\(\s*\)"), "toBeTruthy() — asserts existence, not a value"),
    (re.compile(r"\.\s*toBeFalsy\s*\(\s*\)"), "toBeFalsy() — asserts absence, not a value"),
    (re.compile(r"\.\s*not\s*\.\s*toBeNull\s*\(\s*\)"), "not.toBeNull() — asserts existence, not a value"),
]

# Single-sided refusal evidence. Added 2026-08-08 after four blank-context judge runs, three of
# which found the same shape: a negative test whose ONLY assertion is "not the success value".
# `expect(alertText.length).toBeGreaterThan(0)` for a scenario whose Then demands a specific alert
# AND the absence of "Product added." passes when the app shows "Product added" -- that string is
# 13 characters long. `not.toBe(200)` passes against an app that refused for an unrelated reason,
# and against one that did the forbidden thing and answered 201.
#
# Reported, never blocking, and the boundary is deliberate: the rubric states that the tool judges
# assertion *shape* while the judge judges *vacuity against the specification*. Whether a
# single-sided assertion is vacuous depends on what its scenario claimed, which this tool cannot
# read. What it can say is "this test's whole evidence is one-sided" -- a fact, handed to the judge.
SINGLE_SIDED = [
    (re.compile(r"\.\s*length\s*\)\s*\.\s*toBeGreaterThan\s*\(\s*0\s*\)"),
     "length > 0 -- satisfied by the forbidden value as readily as the expected one"),
    (re.compile(r"\.\s*not\s*\.\s*toBe\s*\("), "not.toBe(...) -- asserts what it is not, not what it is"),
    (re.compile(r"\.\s*not\s*\.\s*toContain\s*\("), "not.toContain(...) -- one-sided"),
    (re.compile(r"\.\s*not\s*\.\s*toEqual\s*\("), "not.toEqual(...) -- one-sided"),
]

# A scenario the test book flagged as resting on an open question, whose generated test carries no
# trace of the flag. Blocking, and the severity comes from the failure mode rather than the code:
# when such a test goes red, the reader cannot tell "the open question just got answered" from
# "the product regressed", and the cheapest resolution is to edit the expected value to match the
# app -- silently converting a finding into a specification. Found on two of the four suites judged.
FLAG_IN_CODE = re.compile(r"low[-_]confidence|open:\s*Q\d|unconfirmed|human arbitration|test\.(fixme|fail)", re.I)
FEATURE_FLAGGED_SCENARIO = re.compile(r"@low-confidence|#\s*open:\s*Q\d", re.I)

# A comment or report citing a file that does not exist. Added 2026-08-08 from the fifth judge
# run: `pages/api-helpers.js` carried "a real finding, see automation/NOTES.md" and no NOTES.md
# was ever written. The rubric already makes a false claim in the *run report* chargeable; this is
# the same failure mode -- evidence offered that cannot be inspected -- one file over. Cheap to
# check, impossible to argue with, and it decays silently: the citation looks authoritative
# precisely because nobody follows it.
CITATION = re.compile(r"see\s+([A-Za-z0-9_./-]+\.(?:md|json|txt|ya?ml|js|ts))\b", re.I)

# Raw CSS/XPath selectors: the automate skill mandates getByRole/getByTestId/getByLabel.
RAW_SELECTOR = re.compile(r"\.\s*(locator|\$\$?|querySelector)\s*\(\s*['\"`]")
XPATH_SELECTOR = re.compile(r"['\"`]\s*(//|xpath=)")
ROLE_SELECTOR = re.compile(r"\.\s*(getByRole|getByTestId|getByLabel|getByPlaceholder|getByText|getByTitle|getByAltText)\s*\(")

NL = chr(10)
EXPECT_CALL = re.compile(r"\bexpect\s*\(")
# `test(...)`, `test.only(...)`, `test.fixme(...)` — but never `test.describe(...)`, which is a
# grouping block, not a test. Counting describe blocks as tests reported every suite as having a
# "test without assertion" (found by running the tool on US-EVAL-001, not by reading it).
TEST_DECL = re.compile(
    r"^\s*test\s*(?:\.\s*(?:only|skip|fixme|fail|slow)\s*)?\(\s*(['\"`])(?P<title>(?:\\.|(?!\1).)*)\1")
QAIA_TAG = re.compile(r"@?\bQAIA[-A-Za-z0-9_]*-\d+\b")
FEATURE_TAG = re.compile(r"@(QAIA[-A-Za-z0-9_]*-\d+)\b")


# A `//` line comment is prose, not code. Stripping it before pattern matching was added
# 2026-08-08 after the assertion rules fired on `// Was: expect(true).toBe(true)` in a fixture
# whose whole purpose is to document the defect it fixed. Any suite that explains its own
# corrections was being penalised for the explanation. Block comments and `//` inside a string
# literal are deliberately not handled: the cheap version is right far more often than not, and a
# clever one that mis-parses a URL would be worse than none.
COMMENT_TAIL = re.compile(r"(?<!:)//.*$")


def code_of(line):
    return COMMENT_TAIL.sub("", line)


def first_match(rules, line):
    """Only the first matching rule fires. `waitForLoadState('networkidle')` matches two
    patterns and was reported twice before this (found by running the tool, not reading it)."""
    for rx, label in rules:
        if rx.search(line):
            return label
    return None


def read(path):
    with open(path, encoding="utf-8", errors="replace") as fh:
        return fh.read()


SOURCE_GLOB = re.compile(r"\.(js|ts|mjs|cjs)$")


def _walk(tests_dir):
    for root, dirs, files in os.walk(tests_dir):
        dirs[:] = [d for d in dirs if d not in ("node_modules", "test-results", "playwright-report", ".git")]
        for f in sorted(files):
            yield os.path.join(root, f)


def find_spec_files(tests_dir):
    return [p for p in _walk(tests_dir) if SPEC_GLOB.search(os.path.basename(p))]


def find_support_files(tests_dir, spec_files):
    """Page objects and fixtures. Under POM-as-fixtures — which `automate` mandates — the
    selectors live here, not in the specs. Scoring selector quality on the specs alone
    reported 0 role selectors and 0 raw selectors for a suite that is entirely POM-based
    (found by running the tool on US-EVAL-001)."""
    specs = set(spec_files)
    return [p for p in _walk(tests_dir)
            if p not in specs
            and SOURCE_GLOB.search(os.path.basename(p))
            and not os.path.basename(p).startswith("playwright.config")]


def split_tests(text):
    """Return [(title, start_line, end_line)] — 1-indexed, end exclusive.

    A test block ends where the next test declaration begins (or at EOF). Coarse but
    sufficient: we only need to attribute a line to its owning test.
    """
    lines = text.split("\n")
    starts = []
    for i, line in enumerate(lines):
        m = TEST_DECL.match(line)
        if m:
            starts.append((i + 1, m.group("title")))
    blocks = []
    for idx, (ln, title) in enumerate(starts):
        end = starts[idx + 1][0] if idx + 1 < len(starts) else len(lines) + 1
        blocks.append((title, ln, end))
    return blocks


def static_track(spec_files, support_files, tests_dir, feature_ids, flagged_ids=frozenset()):
    findings = []
    tests_total = 0
    tests_with_real_assertion = 0
    selector_role = 0
    selector_raw = 0
    tagged_tests = 0
    seen_ids = set()

    # A suite is laid out either as `tests/{pages,fixtures.js,*.spec.js}` or as
    # `automation/{tests/*.spec.js, pages/, fixtures.js}`. Looking only under tests_dir reported
    # `pom-missing` on suites whose pages/ sat one level up -- a false finding that appeared in
    # several campaign JSONs and that two independent judges flagged as a probable tool bug before
    # anyone checked. Look in both places, and remember which one won so support files and
    # citations resolve there too.
    pom_roots = [tests_dir, os.path.dirname(tests_dir.rstrip(os.sep))]
    pom_root = next((r for r in pom_roots if os.path.isdir(os.path.join(r, "pages"))), None)
    has_pages_dir = pom_root is not None
    fixtures_path = None
    for root in pom_roots:
        for cand in ("fixtures.js", "fixtures.ts", "fixtures.mjs"):
            p = os.path.join(root, cand)
            if os.path.isfile(p):
                fixtures_path = p
                break
        if fixtures_path:
            break

    for path in spec_files:
        text = read(path)
        lines = text.split("\n")
        rel = os.path.relpath(path, tests_dir)
        blocks = split_tests(text)

        for i, line in enumerate(lines, start=1):
            for cm in CITATION.finditer(line):
                target = cm.group(1)
                # resolved against the tests dir and against its parent (a suite root), the two
                # places a relative citation in a spec can plausibly mean
                if not any(os.path.exists(os.path.join(base, target))
                           for base in (tests_dir, os.path.dirname(tests_dir.rstrip(os.sep)))):
                    findings.append({"kind": "dead-citation", "file": rel, "line": i,
                                     "detail": "cites " + target + ", which does not exist: "
                                               "evidence offered that cannot be inspected",
                                     "blocking": False})

            wait = first_match(FORBIDDEN_WAITS, line)
            if wait:
                findings.append({"kind": "forbidden-wait", "file": rel, "line": i,
                                 "detail": wait, "blocking": False})
            hollow = first_match(HOLLOW_ASSERTIONS, code_of(line))
            if hollow:
                findings.append({"kind": "hollow-assertion", "file": rel, "line": i,
                                 "detail": hollow, "blocking": True})
            weak = first_match(WEAK_ASSERTIONS, code_of(line))
            if weak:
                findings.append({"kind": "weak-assertion", "file": rel, "line": i,
                                 "detail": weak, "blocking": False})
            if RAW_SELECTOR.search(line) or XPATH_SELECTOR.search(line):
                selector_raw += 1
                findings.append({"kind": "fragile-selector", "file": rel, "line": i,
                                 "detail": line.strip()[:160], "blocking": False})
            if ROLE_SELECTOR.search(line):
                selector_role += 1

        for title, start, end in blocks:
            tests_total += 1
            body = "\n".join(lines[start - 1:end - 1])
            real_assertions = len([
                1 for ln in body.split("\n")
                if EXPECT_CALL.search(code_of(ln)) and not any(rx.search(code_of(ln)) for rx, _ in HOLLOW_ASSERTIONS)
            ])
            if real_assertions:
                tests_with_real_assertion += 1
            else:
                findings.append({"kind": "test-without-assertion", "file": rel, "line": start,
                                 "detail": title[:160], "blocking": True})
            # Whole-evidence check: fires only when EVERY assertion in the test is one-sided.
            # A test that asserts `not.toBe(200)` and then reads the error body is fine.
            assertion_lines = [ln for ln in body.split(NL) if EXPECT_CALL.search(code_of(ln))]
            if assertion_lines and all(first_match(SINGLE_SIDED, ln) for ln in assertion_lines):
                findings.append({"kind": "single-sided-evidence", "file": rel, "line": start,
                                 "detail": "every assertion in this test is one-sided ("
                                           + first_match(SINGLE_SIDED, assertion_lines[0])
                                           + "): it cannot distinguish the refusal under test from "
                                             "any other refusal, nor from the forbidden behaviour "
                                             "returning a different value",
                                 "blocking": False})

            tag = QAIA_TAG.search(title)
            if tag:
                tagged_tests += 1
                sid = tag.group(0).lstrip("@")
                seen_ids.add(sid)
                if sid in flagged_ids and not FLAG_IN_CODE.search(body):
                    findings.append({"kind": "flag-dropped", "file": rel, "line": start,
                                     "detail": sid + " rests on an open question in the test book "
                                               "(@low-confidence / # open: Q) and the generated test "
                                               "carries no trace of it: a red here is "
                                               "indistinguishable from a regression",
                                     "blocking": True})
            else:
                findings.append({"kind": "untraceable-test", "file": rel, "line": start,
                                 "detail": "no @QAIA-<ID> in the test title: " + title[:120],
                                 "blocking": False})

        if has_pages_dir and fixtures_path:
            uses_fixtures = re.search(r"require\s*\(\s*['\"].*fixtures|from\s+['\"].*fixtures", text)
            if not uses_fixtures:
                findings.append({"kind": "pom-bypassed", "file": rel, "line": 1,
                                 "detail": "pages/ and fixtures exist but this spec does not import the fixtures",
                                 "blocking": False})

    # Page objects / fixtures: selectors and waits count here too.
    for path in support_files:
        rel = os.path.relpath(path, tests_dir)
        for i, line in enumerate(read(path).split("\n"), start=1):
            # Support files carry citations too, and the fifth judge found the dead one in a
            # page object rather than in a spec.
            for cm in CITATION.finditer(line):
                target = cm.group(1)
                if not any(os.path.exists(os.path.join(base, target))
                           for base in (tests_dir, os.path.dirname(tests_dir.rstrip(os.sep)))):
                    findings.append({"kind": "dead-citation", "file": rel, "line": i,
                                     "detail": "cites " + target + ", which does not exist: "
                                               "evidence offered that cannot be inspected",
                                     "blocking": False})
            wait = first_match(FORBIDDEN_WAITS, line)
            if wait:
                findings.append({"kind": "forbidden-wait", "file": rel, "line": i,
                                 "detail": wait, "blocking": False})
            if RAW_SELECTOR.search(line) or XPATH_SELECTOR.search(line):
                selector_raw += 1
                findings.append({"kind": "fragile-selector", "file": rel, "line": i,
                                 "detail": line.strip()[:160], "blocking": False})
            if ROLE_SELECTOR.search(line):
                selector_role += 1

    if not has_pages_dir or not fixtures_path:
        findings.append({"kind": "pom-missing", "file": ".", "line": 0,
                         "detail": "automate SKILL.md mandates POM-as-fixtures (pages/ + fixtures.js); "
                                   + ("pages/ missing" if not has_pages_dir else "fixtures file missing"),
                         "blocking": False})

    # Scenarios present in the test book but with no test carrying their ID.
    orphan_scenarios = sorted(feature_ids - seen_ids) if feature_ids else []
    for sid in orphan_scenarios:
        findings.append({"kind": "scenario-without-test", "file": "<testbook>", "line": 0,
                         "detail": sid, "blocking": False})

    def pct(num, den):
        return 0.0 if den == 0 else num / den

    selectors_total = selector_role + selector_raw
    if selectors_total == 0:
        # Nothing to judge rather than "all bad" — but say so out loud instead of quietly
        # awarding full marks for an absence.
        robust_selectors = 25.0
        findings.append({"kind": "no-selector-detected", "file": ".", "line": 0,
                         "detail": "no locator call found in specs or page objects; the selector "
                                   "dimension is not applicable and was not penalised",
                         "blocking": False})
    else:
        robust_selectors = round(25 * pct(selector_role, selectors_total), 1)

    budget = {
        "substantive_assertions": round(30 * pct(tests_with_real_assertion, tests_total), 1),
        "robust_selectors": robust_selectors,
        "pom_as_fixtures": 20.0 if (has_pages_dir and fixtures_path) else 0.0,
        "traceability": round(25 * pct(tagged_tests, tests_total), 1),
    }
    score = round(sum(budget.values()), 1)

    return {
        "score": score,
        "budget": budget,
        "counts": {
            "spec_files": len(spec_files),
            "tests": tests_total,
            "tests_with_real_assertion": tests_with_real_assertion,
            "role_selectors": selector_role,
            "raw_selectors": selector_raw,
            "tagged_tests": tagged_tests,
            "testbook_scenarios": len(feature_ids),
            "scenarios_without_test": len(orphan_scenarios),
        },
        "findings": findings,
    }


# ------------------------------------------------------------------------- mutation track

def _bump_number(txt):
    try:
        if "." in txt:
            return str(float(txt) + 1)
        return str(int(txt) + 1)
    except ValueError:
        return None


MUTANT_MARK = "__QAIA_MUT__"


def mutate_line(line):
    """Return (mutated_line, description) or (None, None) if nothing mutable here.

    Every mutation makes the expectation FALSE for an app that behaves as the original
    asserted. A correct, load-bearing assertion must therefore turn red.
    """
    # `.not.X(...)` -> `X(...)`: dropping the negation flips the expectation.
    m = re.search(r"\.\s*not\s*\.", line)
    if m:
        return line[:m.start()] + "." + line[m.end():], "drop .not."

    pairs = [("toBeVisible", "toBeHidden"), ("toBeHidden", "toBeVisible"),
             ("toBeEnabled", "toBeDisabled"), ("toBeDisabled", "toBeEnabled"),
             ("toBeChecked", "toBeHidden")]
    for src, dst in pairs:
        m = re.search(r"\.\s*" + src + r"\s*\(", line)
        if m:
            return line[:m.start()] + "." + dst + "(" + line[m.end():], "%s -> %s" % (src, dst)

    # Numeric matchers: shift the expected value so the real one no longer satisfies it.
    for name in ("toHaveCount", "toHaveLength", "toBeLessThan", "toBeLessThanOrEqual"):
        m = re.search(r"\.\s*" + name + r"\s*\(\s*(-?\d+(?:\.\d+)?)\s*\)", line)
        if m:
            if name.startswith("toBeLess"):
                new = "-1"
            else:
                new = _bump_number(m.group(1))
            if new is not None:
                return line[:m.start(1)] + new + line[m.end(1):], "%s(%s) -> %s(%s)" % (name, m.group(1), name, new)
    for name in ("toBeGreaterThan", "toBeGreaterThanOrEqual"):
        m = re.search(r"\.\s*" + name + r"\s*\(\s*(-?\d+(?:\.\d+)?)\s*\)", line)
        if m:
            return line[:m.start(1)] + "999999999" + line[m.end(1):], "%s(%s) -> %s(999999999)" % (name, m.group(1), name)

    # String matchers: append a marker no real UI text can contain.
    for name in ("toHaveText", "toContainText", "toHaveValue", "toHaveAttribute", "toContain", "toHaveTitle"):
        m = re.search(r"\.\s*" + name + r"\s*\(\s*(['\"])((?:\\.|(?!\1).)*)\1", line)
        if m:
            return (line[:m.end(2)] + MUTANT_MARK + line[m.end(2):],
                    "%s('%s') -> '...%s'" % (name, m.group(2)[:40], MUTANT_MARK))

    # Regex matchers (toHaveURL(/x/)): replace with a pattern that cannot match.
    m = re.search(r"\.\s*(toHaveURL|toHaveText|toContainText)\s*\(\s*/((?:\\.|[^/])*)/", line)
    if m:
        return (line[:m.start(2)] + "qaia_mut_never_matches" + line[m.end(2):],
                "%s(/%s/) -> /qaia_mut_never_matches/" % (m.group(1), m.group(2)[:40]))

    # Generic equality on a literal.
    m = re.search(r"\.\s*(toBe|toEqual|toStrictEqual)\s*\(\s*(-?\d+(?:\.\d+)?)\s*\)", line)
    if m:
        new = _bump_number(m.group(2))
        if new is not None:
            return line[:m.start(2)] + new + line[m.end(2):], "%s(%s) -> %s(%s)" % (m.group(1), m.group(2), m.group(1), new)
    m = re.search(r"\.\s*(toBe|toEqual)\s*\(\s*(true|false)\s*\)", line)
    if m:
        flip = "false" if m.group(2) == "true" else "true"
        return line[:m.start(2)] + flip + line[m.end(2):], "%s(%s) -> %s(%s)" % (m.group(1), m.group(2), m.group(1), flip)
    m = re.search(r"\.\s*(toBe|toEqual)\s*\(\s*(['\"])((?:\\.|(?!\2).)*)\2", line)
    if m:
        return (line[:m.end(3)] + MUTANT_MARK + line[m.end(3):],
                "%s('%s') -> '...%s'" % (m.group(1), m.group(3)[:40], MUTANT_MARK))

    return None, None


def run_cmd(cmd, cwd, timeout):
    try:
        p = subprocess.run(cmd, cwd=cwd, shell=True, timeout=timeout,
                           stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        return p.returncode, p.stdout.decode("utf-8", errors="replace")
    except subprocess.TimeoutExpired:
        return None, "TIMEOUT after %ss" % timeout
    except OSError as exc:
        return None, "OSError: %s" % exc


def baseline(run_cwd, base_cmd, timeout):
    """Which tests pass before any mutation? Only those are meaningful mutation targets."""
    code, out = run_cmd(base_cmd, run_cwd, timeout)
    if code is None:
        return None, out
    return code, out


def escape_grep(title):
    return re.sub(r"([.^$*+?()\[\]{}|\\/])", r"\\\1", title)


def mutation_track(spec_files, tests_dir, run_cwd, base_cmd, max_mutations, timeout):
    code, out = baseline(run_cwd, base_cmd, timeout)
    if code is None:
        return {"status": "blocked", "blocker": "baseline run could not execute: " + out[-800:],
                "total": 0, "killed": 0, "survived": []}
    if code != 0:
        return {"status": "blocked",
                "blocker": ("baseline suite is not green (exit %s) — mutation results would be "
                            "meaningless because a test that was already red cannot prove anything. "
                            "Fix the suite first. Tail of output:\n%s" % (code, out[-800:])),
                "total": 0, "killed": 0, "survived": []}

    candidates = []
    for path in spec_files:
        text = read(path)
        lines = text.split("\n")
        blocks = split_tests(text)
        for i, line in enumerate(lines, start=1):
            if not EXPECT_CALL.search(line):
                continue
            if any(rx.search(line) for rx, _ in HOLLOW_ASSERTIONS):
                continue  # already reported as blocking by the static track
            mutated, desc = mutate_line(line)
            if mutated is None or mutated == line:
                continue
            owner = None
            for title, start, end in blocks:
                if start <= i < end:
                    owner = title
                    break
            candidates.append({"file": path, "line": i, "test": owner,
                               "original": line.strip()[:200], "mutation": desc,
                               "mutated_line": mutated})

    skipped = 0
    if max_mutations and len(candidates) > max_mutations:
        skipped = len(candidates) - max_mutations
        candidates = candidates[:max_mutations]

    survived, killed, errored = [], 0, []
    for cand in candidates:
        path = cand["file"]
        original_text = read(path)
        lines = original_text.split("\n")
        lines[cand["line"] - 1] = cand["mutated_line"]
        backup = tempfile.mktemp(suffix=".bak")
        shutil.copy2(path, backup)
        try:
            with open(path, "w", encoding="utf-8") as fh:
                fh.write("\n".join(lines))
            cmd = base_cmd
            if cand["test"]:
                cmd = base_cmd + ' --grep "%s"' % escape_grep(cand["test"])
            rc, rout = run_cmd(cmd, run_cwd, timeout)
        finally:
            shutil.copy2(backup, path)
            os.remove(backup)

        rel = os.path.relpath(path, tests_dir)
        if rc is None:
            errored.append({"file": rel, "line": cand["line"], "reason": rout[-300:]})
        elif rc == 0:
            survived.append({"file": rel, "line": cand["line"], "test": cand["test"],
                             "assertion": cand["original"], "mutation": cand["mutation"]})
        else:
            killed += 1

    return {
        "status": "ok",
        "blocker": "",
        "total": len(candidates),
        "killed": killed,
        "survived": survived,
        "errored": errored,
        "skipped_over_cap": skipped,
    }


# ------------------------------------------------------------------------------- assembly

def collect_feature_ids(testbook):
    ids = set()
    if not testbook:
        return ids
    paths = []
    if os.path.isfile(testbook):
        paths = [testbook]
    else:
        for root, dirs, files in os.walk(testbook):
            dirs[:] = [d for d in dirs if d not in ("node_modules", ".git")]
            paths += [os.path.join(root, f) for f in files if f.endswith(".feature")]
    flagged = set()
    for p in paths:
        text = read(p)
        for m in FEATURE_TAG.finditer(text):
            ids.add(m.group(1))
        # A scenario is flagged when the marker sits on its tag line or in the comment block just
        # above it. Walk the file and attribute a pending flag to the next scenario ID seen.
        pending_flag = False
        for line in text.split(NL):
            if FEATURE_FLAGGED_SCENARIO.search(line):
                pending_flag = True
            m = FEATURE_TAG.search(line)
            if m and pending_flag:
                flagged.add(m.group(1))
            if line.strip().startswith("Scenario"):
                pending_flag = False
    return ids, flagged


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--tests-dir", required=True, help="directory holding the generated .spec files")
    ap.add_argument("--testbook", help="test book dir or .feature file, for traceability cross-check")
    ap.add_argument("--run-cwd", help="cwd for the Playwright run (defaults to --tests-dir)")
    ap.add_argument("--run-cmd", default="npx playwright test", help="command that runs the suite")
    ap.add_argument("--max-mutations", type=int, default=25, help="cap on mutations (0 = no cap)")
    ap.add_argument("--timeout", type=int, default=300, help="per-run timeout in seconds")
    ap.add_argument("--skip-mutation", action="store_true", help="static track only")
    ap.add_argument("--out", help="write JSON here instead of stdout")
    args = ap.parse_args()

    tests_dir = os.path.abspath(args.tests_dir)
    if not os.path.isdir(tests_dir):
        print("error: --tests-dir does not exist: %s" % tests_dir, file=sys.stderr)
        return 2
    spec_files = find_spec_files(tests_dir)
    if not spec_files:
        print("error: no .spec.* files under %s" % tests_dir, file=sys.stderr)
        return 2

    support_files = find_support_files(tests_dir, spec_files)
    # If pages/ lives one level up (the automation/{tests,pages} layout), its files are
    # support files too -- otherwise selectors and citations there are invisible.
    parent = os.path.dirname(tests_dir.rstrip(os.sep))
    if os.path.isdir(os.path.join(parent, 'pages')):
        support_files += [p for p in find_support_files(os.path.join(parent, 'pages'), spec_files)
                          if p not in support_files]

    feature_ids, flagged_ids = collect_feature_ids(args.testbook)
    static = static_track(spec_files, support_files, tests_dir, feature_ids, flagged_ids)

    if args.skip_mutation:
        mutation = {"status": "skipped", "blocker": "--skip-mutation requested",
                    "total": 0, "killed": 0, "survived": []}
    else:
        mutation = mutation_track(spec_files, tests_dir, os.path.abspath(args.run_cwd or tests_dir),
                                  args.run_cmd, args.max_mutations, args.timeout)

    blocking = []
    for f in static["findings"]:
        if f.get("blocking"):
            blocking.append("%s: %s (%s:%s)" % (f["kind"], f["detail"][:90], f["file"], f["line"]))
    for s in mutation.get("survived", []):
        blocking.append("mutation-survivor: %s (%s:%s) — %s" % (s["assertion"][:90], s["file"], s["line"], s["mutation"]))

    result = {
        "tool": "automation_score.py",
        "version": 1,
        "inputs": {"tests_dir": tests_dir, "testbook": args.testbook, "run_cmd": args.run_cmd},
        "static": static,
        "mutation": mutation,
        "blocking": {"failed": bool(blocking), "reasons": blocking},
        "llm_rubric": None,
        "note": ("static score and the LLM rubric score are never summed — see eval/RUBRIC.md, "
                 "case US 676266. A blocking failure stands regardless of either score."),
    }

    text = json.dumps(result, indent=2, ensure_ascii=False)
    if args.out:
        with open(args.out, "w", encoding="utf-8") as fh:
            fh.write(text + "\n")
        print("written: %s" % args.out)
    else:
        print(text)
    return 1 if blocking else 0


if __name__ == "__main__":
    sys.exit(main())
