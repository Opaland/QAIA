#!/usr/bin/env python3
"""flaky-detect Method (plugins/qaia-playwright/skills/flaky-detect/SKILL.md, steps 1-4)
applied to N real JUnit XML runs. Stdlib only, no network, no fabrication.

Usage: python flaky_detect.py <run1.junit.xml> [<run2.junit.xml> ...]
Prints a Markdown findings table + the JSON `flakiness` block on stdout.
"""
import sys, json, re
import xml.etree.ElementTree as ET

QAIA_TAG = re.compile(r"@(QAIA-[A-Za-z0-9\-]+)")


def parse_run(path):
    """-> {testKey: (verdict, failure_excerpt|None)}"""
    out = {}
    root = ET.parse(path).getroot()
    for tc in root.iter("testcase"):
        name = tc.get("name", "")
        m = QAIA_TAG.search(name)
        # Method step 1: key by the @QAIA-* tag, else classname+name.
        key = "@" + m.group(1) if m else f'{tc.get("classname","")}::{name}'
        verdict, excerpt = "pass", None
        if tc.find("failure") is not None:
            verdict = "fail"
            f = tc.find("failure")
            excerpt = (f.get("message") or (f.text or ""))[:300].strip()
        elif tc.find("error") is not None:
            verdict = "fail"
            e = tc.find("error")
            excerpt = (e.get("message") or (e.text or ""))[:300].strip()
        elif tc.find("skipped") is not None:
            verdict = "skipped"
        out[key] = (verdict, excerpt)
    return out


def main(paths):
    runs = [parse_run(p) for p in paths]
    n = len(runs)
    keys = sorted({k for r in runs for k in r})
    flaky, all_pass, consistent_fail, other = [], [], [], []
    for k in keys:
        seq, excerpts, failed_idx = [], [], []
        for i, r in enumerate(runs, start=1):
            v, ex = r.get(k, ("absent", None))
            seq.append(v)
            if v == "fail":
                failed_idx.append(i)
                if ex:
                    excerpts.append(f"{ex} (run {i})")
        vs = set(seq)
        entry = {"testId": k, "verdicts": seq,
                 "passRate": f"{seq.count('pass')}/{n}", "failedRuns": failed_idx}
        if excerpts:
            entry["failureExcerpt"] = excerpts[0]
        # Method step 3: flaky iff BOTH pass and fail appear.
        if "pass" in vs and "fail" in vs:
            flaky.append(entry)
        elif vs == {"pass"}:
            all_pass.append(k)
        elif vs == {"fail"}:
            consistent_fail.append(k)
        else:
            other.append(entry)

    print(f"# flaky-detect findings - {n} runs analyzed\n")
    print("| Test ID | Verdict sequence | Pass rate | Failing runs | Classification |")
    print("|---|---|---|---|---|")
    for k in keys:
        seq = [r.get(k, ("absent", None))[0] for r in runs]
        vs = set(seq)
        cls = ("FLAKY" if ("pass" in vs and "fail" in vs)
               else "no flakiness observed" if vs == {"pass"}
               else "consistent failure (real bug, not flaky)" if vs == {"fail"}
               else "mixed/skipped - see JSON")
        print(f"| `{k}` | {' -> '.join(seq)} | {seq.count('pass')}/{n} | "
              f"{[i for i, v in enumerate(seq, 1) if v == 'fail'] or '-'} | {cls} |")

    block = {"flakiness": {
        "runsAnalyzed": n,
        "codeChangeControlled": True,
        "flaky": flaky,
        "allPassNoFlakinessObserved": all_pass,
        "consistentFailures": consistent_fail,
    }}
    if other:
        block["flakiness"]["mixedNonBinaryVerdicts"] = other
    print("\n```json\n" + json.dumps(block, indent=2) + "\n```")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
