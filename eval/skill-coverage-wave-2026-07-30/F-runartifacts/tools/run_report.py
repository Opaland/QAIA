#!/usr/bin/env python3
"""run-report Steps 2-3 (plugins/qaia-playwright/skills/run-report/SKILL.md) applied to a
REAL Playwright run of US-EVAL-006.

- reads the run's results.json (Playwright JSON reporter) -- the only source of counts
- emits Cucumber JSON + a self-contained HTML summary with the AC -> scenario -> test -> result
  traceability table (the JUnit XML is produced by Playwright's own junit reporter)
- merges ONLY the `execution` section into a COPY of the real manifest, appends the producer,
  appends the artifacts, leaves design/gate/status/openArbitrations untouched.

Usage: python run_report.py <results.json> <manifest.json> <outdir> <relprefix>
"""
import sys, json, os, re, html, datetime

TAGRE = re.compile(r"@(QAIA-[A-Za-z0-9\-]+)")
ACRE = re.compile(r"@(AC\d+)")
PRIRE = re.compile(r"@(P\d)")


def walk(suite, acc, project_names):
    for spec in suite.get("specs", []):
        for t in spec.get("tests", []):
            res = t.get("results", [{}])[-1]
            acc.append({
                "title": spec["title"],
                "file": spec.get("file"),
                "line": spec.get("line"),
                "project": t.get("projectName"),
                "status": res.get("status"),
                "expected": t.get("status"),
                "duration": res.get("duration"),
                "errors": res.get("errors", []),
            })
            project_names.add(t.get("projectName"))
    for s in suite.get("suites", []):
        walk(s, acc, project_names)


def main(argv):
    results_path, manifest_path, outdir, relprefix = argv
    data = json.load(open(results_path, encoding="utf-8"))
    tests, projects = [], set()
    for s in data.get("suites", []):
        walk(s, tests, projects)

    for t in tests:
        t["qaiaId"] = (TAGRE.search(t["title"]).group(1) if TAGRE.search(t["title"]) else None)
        t["ac"] = ACRE.search(t["title"]).group(1) if ACRE.search(t["title"]) else None
        t["pri"] = PRIRE.search(t["title"]).group(1) if PRIRE.search(t["title"]) else None

    passed = sum(1 for t in tests if t["status"] == "passed")
    failed = sum(1 for t in tests if t["status"] in ("failed", "timedOut", "interrupted"))
    blocked = sum(1 for t in tests if t["status"] in ("skipped",))
    total = len(tests)
    assert passed + failed + blocked == total, "unclassified test status present"

    byType = {}
    for t in tests:
        byType[t["project"]] = byType.get(t["project"], 0) + 1

    os.makedirs(outdir, exist_ok=True)

    # --- Cucumber JSON ------------------------------------------------------
    cucumber = [{
        "uri": tests[0]["file"] if tests else "",
        "id": "us-eval-006",
        "keyword": "Feature",
        "name": "the-internet - Dynamically Loaded Page Elements (US-EVAL-006)",
        "line": 1,
        "elements": [{
            "id": f"us-eval-006;{(t['qaiaId'] or 'untagged').lower()}",
            "keyword": "Scenario", "type": "scenario",
            "name": t["title"], "line": t.get("line") or 0,
            "tags": [{"name": "@" + x, "line": 1} for x in filter(None, [t["qaiaId"], t["ac"], t["pri"]])],
            "steps": [{
                "keyword": "When ", "name": "the automated test runs", "line": t.get("line") or 0,
                "result": {
                    "status": "passed" if t["status"] == "passed" else ("skipped" if t["status"] == "skipped" else "failed"),
                    "duration": int((t.get("duration") or 0) * 1_000_000),
                    **({"error_message": json.dumps(t["errors"])[:2000]} if t["errors"] else {}),
                },
            }],
        } for t in tests],
    }]
    with open(os.path.join(outdir, "cucumber.json"), "w", encoding="utf-8") as f:
        json.dump(cucumber, f, indent=2)

    # --- self-contained HTML ------------------------------------------------
    rows = "\n".join(
        f"<tr><td>{html.escape(t['ac'] or '-')}</td><td>{html.escape(t['qaiaId'] or '-')}</td>"
        f"<td>{html.escape(t['pri'] or '-')}</td><td>{html.escape(t['title'])}</td>"
        f"<td class='{ 'p' if t['status']=='passed' else 'f' }'>{html.escape(t['status'] or '?')}</td>"
        f"<td>{t['duration']} ms</td></tr>" for t in tests)
    bytype_rows = "\n".join(f"<tr><td>{html.escape(k)}</td><td>{v}</td></tr>" for k, v in sorted(byType.items()))
    htmlout = f"""<meta charset="utf-8"><title>run-report - US-EVAL-006</title>
<style>body{{font-family:system-ui,sans-serif;margin:2rem;max-width:60rem}}
table{{border-collapse:collapse;width:100%;margin:1rem 0}}td,th{{border:1px solid #ccc;padding:.4rem .6rem;text-align:left}}
.p{{color:#0a7}}.f{{color:#c00;font-weight:700}}</style>
<h1>Execution report - US-EVAL-006</h1>
<p>Source run: <code>{html.escape(os.path.basename(results_path))}</code> -
started {html.escape(str(data.get('stats',{}).get('startTime')))},
duration {data.get('stats',{}).get('duration')} ms, Playwright {html.escape(str(data.get('config',{}).get('version')))}.</p>
<h2>Totals</h2>
<table><tr><th>total</th><th>passed</th><th>failed</th><th>blocked/skipped</th></tr>
<tr><td>{total}</td><td>{passed}</td><td>{failed}</td><td>{blocked}</td></tr></table>
<h2>By type (Playwright project)</h2>
<table><tr><th>type</th><th>tests</th></tr>{bytype_rows}</table>
<h2>Traceability: AC -&gt; scenario -&gt; test -&gt; result</h2>
<table><tr><th>AC</th><th>Scenario ID</th><th>Priority</th><th>Test title</th><th>Result</th><th>Duration</th></tr>
{rows}</table>
<p><em>Blocked/skipped tests are reported as such, never as passed. No result here is
fabricated: every row comes from the Playwright JSON reporter output above.</em></p>
"""
    with open(os.path.join(outdir, "report.html"), "w", encoding="utf-8") as f:
        f.write(htmlout)

    # --- manifest merge (contract rule 2: merge, never clobber) -------------
    m = json.load(open(manifest_path, encoding="utf-8"))
    before_keys = list(m.keys())
    m["execution"] = {
        "total": total, "passed": passed, "failed": failed, "blocked": blocked,
        "byType": byType,
        "traceability": {
            "scenariosAutomated": len({t["qaiaId"] for t in tests if t["qaiaId"]}),
            "scenariosTotal": m.get("design", {}).get("scenarios", {}).get("total", 0),
        },
    }
    now = datetime.datetime.now(datetime.timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
    m.setdefault("producers", []).append(
        {"plugin": "qaia-playwright", "version": "0.2.4", "skill": "run-report", "at": now})
    for kind, fmt, path in [("execution", "junit", f"{relprefix}/results-run5.junit.xml"),
                            ("execution", "cucumber-json", f"{relprefix}/cucumber.json"),
                            ("execution", "html", f"{relprefix}/report.html")]:
        m.setdefault("artifacts", []).append({"kind": kind, "format": fmt, "path": path})
    m["generatedAt"] = now
    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(m, f, indent=2, ensure_ascii=False)

    print(f"tests={total} passed={passed} failed={failed} blocked={blocked} byType={byType}")
    print("manifest keys before:", before_keys)
    print("manifest keys after :", list(m.keys()))
    print("gate present:", "gate" in m, "| status:", m.get("status"))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
