#!/usr/bin/env python3
"""Fail when the requirement a test book was written from has changed since it was written.

Why this exists, and it is not a hypothesis. On 2026-08-08 a test book generated from the README
of `typicode/json-server` was run against two versions of that project. Against the version its
README described: 29/32 green, two real defects found. Against the current version: four red --
and **three of those four were our fault**. `_limit`, `_start`/`_end` and `arr[0]` had been
removed from the documentation in the meantime. The suite went on demanding promises that had
been retired, and it did so with the confidence of tests that had once been green.

That is the failure mode this file exists for. A generated suite is only ever as true as the
requirement it was generated from, and nothing in the suite says when that requirement moved.
The mechanism is the one already used for published skill copies
(`check_published_copies.py`): record the sha256 of the source at generation time, and fail when
it no longer matches. What is checked is **provenance**, not content -- the tool cannot know
which promise disappeared, only that the ground moved and a human must re-read.

A provenance file sits next to the test book it covers:

    {
      "testbook": "testbook/json-server-rest.feature",
      "sources": [
        {
          "label": "typicode/json-server README at 8fb0f72",
          "path": "sources/README.8fb0f72.md",
          "origin": "https://github.com/typicode/json-server/blob/8fb0f72/README.md",
          "sha256": "..."
        }
      ]
    }

`path` is the **frozen copy** kept in the repo, so the check works offline and in CI. Freezing
the copy is the point: a requirement you cannot re-read at the version you generated from is a
requirement you cannot argue about later.

Refreshing after a deliberate re-read is one command:

    python eval/tools/check_requirement_drift.py --update

Running it means "I have re-read the source and the test book still says the truth". The diff it
produces is what a reviewer looks at.

Exit codes: 0 every source current, 1 at least one source changed since the book was written,
2 a provenance file is missing, malformed, or points at a file that is not there.
"""

import argparse
import hashlib
import io
import json
import os
import sys

CR, LF = chr(13), chr(10)
CRLF = CR + LF

# Provenance files are found by name so a new campaign is covered the day it is added, rather
# than the day someone remembers to register it here. The Gherkin linter was silently broken for
# several commits by exactly the opposite arrangement -- a hand-maintained list of paths.
PROVENANCE_NAME = "REQUIREMENT-SOURCE.json"
SEARCH_ROOTS = ["eval", "examples"]


def sha256(path):
    """Hash the *normalised* text, not the bytes.

    Same reason as in check_published_copies.py: git rewrites line endings on checkout under
    Windows, so a raw byte hash makes a file look changed when only the checkout differs. That
    bug was shipped once already; it is not worth shipping twice.
    """
    text = io.open(path, encoding="utf-8", errors="replace").read()
    text = text.replace(CRLF, LF).replace(CR, LF)
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def find_provenance_files():
    found = []
    for root in SEARCH_ROOTS:
        if not os.path.isdir(root):
            continue
        for dirpath, dirnames, filenames in os.walk(root):
            dirnames[:] = [d for d in dirnames if d != "node_modules"]
            if PROVENANCE_NAME in filenames:
                found.append(os.path.join(dirpath, PROVENANCE_NAME))
    return sorted(found)


def load(path):
    try:
        with io.open(path, encoding="utf-8") as fh:
            data = json.load(fh)
    except (IOError, ValueError) as e:
        return None, "%s: unreadable or malformed (%s)" % (path, e)
    if not isinstance(data.get("sources"), list) or not data["sources"]:
        return None, "%s: no `sources` list" % path
    return data, None


def check(update=False):
    files = find_provenance_files()
    if not files:
        print("No %s found under %s -- nothing to check." % (PROVENANCE_NAME, ", ".join(SEARCH_ROOTS)))
        return 0

    drifted, broken, checked = [], [], 0
    for prov_path in files:
        data, err = load(prov_path)
        if err:
            broken.append(err)
            continue
        base = os.path.dirname(prov_path)
        book = data.get("testbook", "(unnamed test book)")
        changed_here = False
        for src in data["sources"]:
            frozen = os.path.join(base, src.get("path", ""))
            if not os.path.isfile(frozen):
                broken.append("%s: frozen copy missing: %s" % (prov_path, frozen))
                continue
            actual = sha256(frozen)
            checked += 1
            if actual != src.get("sha256"):
                changed_here = True
                if update:
                    src["sha256"] = actual
                else:
                    drifted.append((prov_path, book, src.get("label", src["path"]),
                                    src.get("origin", ""), src.get("sha256"), actual))
        if update and changed_here:
            with io.open(prov_path, "w", encoding="utf-8", newline="\n") as fh:
                json.dump(data, fh, indent=2, ensure_ascii=False)
                fh.write("\n")
            print("updated: %s" % prov_path)

    if broken:
        for b in broken:
            print("BROKEN: " + b)
        return 2
    if update:
        print("OK: %d source(s) re-recorded." % checked)
        return 0
    if drifted:
        print("REQUIREMENT DRIFT: %d source(s) changed since their test book was written.\n" % len(drifted))
        for prov_path, book, label, origin, was, now in drifted:
            print("  %s" % label)
            print("    test book : %s" % book)
            print("    declared  : %s" % prov_path)
            if origin:
                print("    origin    : %s" % origin)
            print("    recorded  : %s" % was)
            print("    now       : %s" % now)
            print("    -> Re-read the source. A scenario whose promise was retired is a test that")
            print("       will keep passing, or keep failing, for a reason that no longer exists.")
            print("       Then run: python eval/tools/check_requirement_drift.py --update")
            print("")
        return 1
    print("OK: %d requirement source(s) unchanged since their test book was written." % checked)
    return 0


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--update", action="store_true",
                    help="re-record the hashes after a deliberate re-read of the sources")
    args = ap.parse_args()
    sys.exit(check(update=args.update))


if __name__ == "__main__":
    main()
