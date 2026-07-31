#!/usr/bin/env python3
"""flaky-detect skill -- Method steps 1-4, applied to N real JUnit XML runs.

Step 1: parse each run's JUnit XML; key every test by its @QAIA-* tag (the automate/run-report
        convention), falling back to `classname`+`name`.
Step 2: build the ordered verdict list per test key.
Step 3: flag flaky ONLY if the verdict set contains both `pass` and `fail`.
        All-fail  -> consistentFailures (a real bug, never merged into `flaky`).
        All-pass  -> allPassNoFlakinessObserved (NOT "stable" -- Guardrail: honesty over
                     false confidence, D38).
Step 4: record verdict sequence, failing run indices, pass rate k/N, failure excerpt.

stdlib only, no network, no fabrication: N files in, N runs counted.
Usage: python flaky_detect.py <run1.junit.xml> <run2.junit.xml> ... [--out <dir>]
"""
import sys, os, re, json
import xml.etree.ElementTree as ET

QAIA_TAG = re.compile(r"@(QAIA-[A-Za-z0-9_-]+)")


def parse_run(path):
    """-> {testKey: (verdict, failure_excerpt)}"""
    tree = ET.parse(path)
    root = tree.getroot()
    out = {}
    for suite in root.iter("testsuite"):
        for case in suite.findall("testcase"):
            name = case.get("name", "")
            classname = case.get("classname", "")
            m = QAIA_TAG.search(name)
            key = "@" + m.group(1) if m else f"{classname}::{name}"
            failure = case.find("failure")
            error = case.find("error")
            skipped = case.find("skipped")
            if failure is not None or error is not None:
                node = failure if failure is not None else error
                excerpt = (node.get("message") or (node.text or ""))[:400].strip()
                out[key] = ("fail", excerpt)
            elif skipped is not None:
                out[key] = ("skipped", "")
            else:
                out[key] = ("pass", "")
    return out


def main(argv):
    outdir = "."
    if "--out" in argv:
        i = argv.index("--out")
        outdir = argv[i + 1]
        argv = argv[:i] + argv[i + 2:]
    if not argv:
        print(__doc__)
        return 2
    runs = [parse_run(p) for p in argv]
    n = len(runs)

    keys = []
    for r in runs:
        for k in r:
            if k not in keys:
                keys.append(k)

    flaky, all_pass, consistent_fail, other = [], [], [], []
    for k in keys:
        verdicts = [r.get(k, ("missing", ""))[0] for r in runs]
        vset = set(verdicts)
        failed_runs = [i + 1 for i, v in enumerate(verdicts) if v == "fail"]
        passes = verdicts.count("pass")
        excerpt = next((r[k][1] for r in runs if k in r and r[k][1]), "")
        rec = {"testId": k, "verdicts": verdicts, "passRate": f"{passes}/{n}",
               "failedRuns": failed_runs}
        if excerpt:
            rec["failureExcerpt"] = excerpt
        if "pass" in vset and "fail" in vset:
            flaky.append(rec)
        elif vset == {"pass"}:
            all_pass.append(k)
        elif vset == {"fail"}:
            consistent_fail.append(k)
        else:
            other.append(rec)

    section = {
        "runsAnalyzed": n,
        # Controlled here: the 5 runs were produced back-to-back from one working copy with
        # zero edits between them (see runs/ logs + git status evidence in the wave report).
        "codeChangeControlled": True,
        "flaky": flaky,
        "allPassNoFlakinessObserved": all_pass,
        "consistentFailures": consistent_fail,
    }
    if other:
        section["mixedNonFlaky"] = other

    os.makedirs(outdir, exist_ok=True)
    with open(os.path.join(outdir, "flakiness-findings.json"), "w", encoding="utf-8") as f:
        json.dump(section, f, indent=2)

    lines = ["| Test ID | Verdict sequence | Pass rate | Failing runs | Classification |",
             "| --- | --- | --- | --- | --- |"]
    for rec in flaky:
        lines.append(f"| `{rec['testId']}` | {', '.join(rec['verdicts'])} | {rec['passRate']} | "
                     f"{rec['failedRuns']} | **flaky** |")
    for k in consistent_fail:
        lines.append(f"| `{k}` | {', '.join(['fail'] * n)} | 0/{n} | all | consistent failure (real bug, NOT flaky) |")
    for k in all_pass:
        lines.append(f"| `{k}` | {', '.join(['pass'] * n)} | {n}/{n} | - | no flakiness observed in {n} runs |")
    table = "\n".join(lines)
    with open(os.path.join(outdir, "flakiness-findings.md"), "w", encoding="utf-8") as f:
        f.write(f"# flaky-detect findings — {n} runs analyzed\n\nRuns:\n"
                + "\n".join(f"{i+1}. `{p}`" for i, p in enumerate(argv))
                + f"\n\n{table}\n\n"
                  f"**{len(flaky)} flaky test(s) flagged.** Tests listed as "
                  f"\"no flakiness observed in {n} runs\" are NOT declared stable — absence of "
                  f"evidence is not evidence of absence (flaky-detect Guardrails, D38).\n")
    print(table)
    print()
    print(json.dumps(section, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
