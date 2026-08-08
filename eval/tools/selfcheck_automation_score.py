# -*- coding: utf-8 -*-
"""Self-check for the parts of automation_score.py that a fixture suite cannot reach.

The static track is validated by running the tool against
`eval/tools/fixtures/automation-score-static/` (see its VALIDATION.md). The mutation track is not:
validating it needs a live Playwright suite and a running system under test, which CI does not have.

The two defects found on 2026-08-08 both lived in that unreachable half, and both inflated the kill
count without ever failing:

  1. Playwright exits 1 both for "a test failed" and for "No tests found". Mutations the run command
     never selected were therefore scored as kills.
  2. A test title containing an apostrophe was captured with its JavaScript escape (`manager\\'s`),
     so `--grep` matched nothing -- which, via (1), also read as a kill.

Run: python eval/tools/selfcheck_automation_score.py
Exits non-zero on the first failure.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import automation_score as A  # noqa: E402

failures = []


def check(label, got, want):
    if got != want:
        failures.append("%s\n    got:  %r\n    want: %r" % (label, got, want))


# --- 1. "No tests found" must be distinguishable from a failing test -------------------------
check("NO_TESTS_FOUND matches Playwright's message",
      bool(A.NO_TESTS_FOUND.search("Error: No tests found\n")), True)
check("NO_TESTS_FOUND does not match an ordinary failure",
      bool(A.NO_TESTS_FOUND.search("1 failed\n  [api] > api.spec.js:12:3 > a test\n")), False)

# --- 2. A title's JavaScript escapes must not reach --grep -----------------------------------
check("apostrophe unescaped", A.unescape_js("a manager\\'s report"), "a manager's report")
check("double quote unescaped", A.unescape_js('he said \\"no\\"'), 'he said "no"')
check("backslash unescaped", A.unescape_js("a\\\\b"), "a\\b")
check("plain title untouched", A.unescape_js("@QAIA-US-004-001 a plain title"), "@QAIA-US-004-001 a plain title")

SRC = "\n".join([
    "const { test, expect } = require('./fixtures');",
    # JavaScript source: test('@QAIA-1 a manager\'s own report escalates', ...)
    "test('@QAIA-1 a manager\\'s own report escalates', async () => {",
    "  expect(x).toBe('approved');",
    "});",
])
titles = [t for t, _, _ in A.split_tests(SRC)]
check("split_tests returns the runner's title, not the source's",
      titles, ["@QAIA-1 a manager's own report escalates"])

# The grep pattern is built from that title: it must escape regex metacharacters but must not
# reintroduce the JS escape, or the mutation is silently never run.
if titles:
    check("escape_grep leaves the apostrophe alone",
          "\\'" in A.escape_grep(titles[0]), False)

if failures:
    print("selfcheck_automation_score: %d FAILURE(S)\n" % len(failures))
    for f in failures:
        print("  - " + f)
    sys.exit(1)
print("selfcheck_automation_score: ok")
