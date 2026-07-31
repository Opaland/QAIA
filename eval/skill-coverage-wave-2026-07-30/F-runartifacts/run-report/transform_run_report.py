#!/usr/bin/env python3
"""run-report skill, step 2 -- transform a real Playwright JSON run into the three consumable
outputs (JUnit XML is emitted natively by the `junit` reporter configured in step 1; this
script produces the Cucumber JSON and the self-contained HTML, and computes the `execution`
counts that step 3 merges into the manifest).

Written for the skill-coverage wave 2026-07-30 (F-runartifacts). stdlib only, no network.
Never fabricates a result: every count comes from the parsed run file.

Usage: python transform_run_report.py <playwright-results.json> <out-dir> <US-ID> <feature-path>
"""
import sys, os, json, html, datetime, re

TYPE_BY_FILE_PREFIX = {"e2e.": "e2e", "api.": "api", "a11y.": "a11y", "perf.": "perf", "security.": "security"}


def test_type(filename):
    for prefix, t in TYPE_BY_FILE_PREFIX.items():
        if filename.startswith(prefix):
            return t
    return "other"


def walk_specs(suite, out, file_hint=None):
    fname = suite.get("file") or file_hint
    for spec in suite.get("specs", []):
        out.append((fname, spec))
    for child in suite.get("suites", []):
        walk_specs(child, out, fname)


def verdict_of(spec):
    """passed / failed / skipped -- blocked is a QAIA-level notion (see caller)."""
    statuses = []
    for t in spec.get("tests", []):
        for r in t.get("results", []):
            statuses.append(r.get("status"))
    if not statuses:
        return "skipped"
    if "failed" in statuses or "timedOut" in statuses:
        return "failed"
    if all(s == "skipped" for s in statuses):
        return "skipped"
    if "interrupted" in statuses:
        return "blocked"
    return "passed" if spec.get("ok") else "failed"


def error_text(spec):
    msgs = []
    for t in spec.get("tests", []):
        for r in t.get("results", []):
            for e in r.get("errors", []):
                if e.get("message"):
                    msgs.append(e["message"])
    return "\n".join(msgs)


def main(argv):
    if len(argv) != 4:
        print(__doc__)
        return 2
    src, outdir, us_id, feature_path = argv
    data = json.load(open(src, encoding="utf-8"))
    os.makedirs(outdir, exist_ok=True)

    specs = []
    for suite in data.get("suites", []):
        walk_specs(suite, specs)

    rows = []
    for fname, spec in specs:
        tags = spec.get("tags", [])
        qaia = next((t for t in tags if t.startswith("QAIA-")), None)
        acs = [t for t in tags if re.fullmatch(r"AC\d+", t)]
        pri = next((t for t in tags if re.fullmatch(r"P[123]", t)), "")
        dur = 0
        for t in spec.get("tests", []):
            for r in t.get("results", []):
                dur += r.get("duration", 0)
        rows.append({
            "scenarioId": "@" + qaia if qaia else spec["title"][:60],
            "title": spec.get("title", ""),
            "file": fname,
            "type": test_type(os.path.basename(fname or "")),
            "ac": acs,
            "priority": pri,
            "verdict": verdict_of(spec),
            "durationMs": dur,
            "error": error_text(spec),
        })

    total = len(rows)
    passed = sum(1 for r in rows if r["verdict"] == "passed")
    failed = sum(1 for r in rows if r["verdict"] == "failed")
    blocked = sum(1 for r in rows if r["verdict"] in ("blocked", "skipped"))

    by_type = {}
    for r in rows:
        b = by_type.setdefault(r["type"], {"total": 0, "passed": 0, "failed": 0, "blocked": 0})
        b["total"] += 1
        key = r["verdict"] if r["verdict"] in ("passed", "failed") else "blocked"
        b[key] += 1

    # ---- Cucumber JSON (BDD reporters / Xray import, D10 git-master) ----
    cucumber = [{
        "keyword": "Feature",
        "name": data.get("config", {}).get("rootDir", us_id),
        "id": us_id.lower(),
        "uri": feature_path,
        "line": 1,
        "elements": [{
            "keyword": "Scenario",
            "type": "scenario",
            "id": f"{us_id.lower()};{r['scenarioId'].lstrip('@').lower()}",
            "name": r["title"],
            "line": 1,
            "tags": [{"name": "@" + t, "line": 1} for t in ([r["scenarioId"].lstrip("@")] + r["ac"] + ([r["priority"]] if r["priority"] else []))],
            "steps": [{
                "keyword": "When ",
                "name": "the automated Playwright test for this scenario runs",
                "line": 1,
                "match": {"location": f"{r['file']}"},
                "result": ({"status": "passed", "duration": r["durationMs"] * 1000000}
                           if r["verdict"] == "passed" else
                           {"status": "failed" if r["verdict"] == "failed" else "skipped",
                            "duration": r["durationMs"] * 1000000,
                            "error_message": r["error"]}),
            }],
        } for r in rows],
    }]
    with open(os.path.join(outdir, "results.cucumber.json"), "w", encoding="utf-8") as f:
        json.dump(cucumber, f, indent=2, ensure_ascii=False)

    # ---- Self-contained HTML summary ----
    badge = {"passed": "#1a7f37", "failed": "#b3261e", "blocked": "#8a6d00", "skipped": "#8a6d00"}
    trs = "\n".join(
        "<tr><td><code>{sid}</code></td><td>{ac}</td><td>{pri}</td><td>{typ}</td>"
        "<td style='color:{c};font-weight:600'>{v}</td><td>{d} ms</td><td>{t}</td></tr>".format(
            sid=html.escape(r["scenarioId"]), ac=", ".join(r["ac"]) or "-", pri=r["priority"] or "-",
            typ=r["type"], c=badge.get(r["verdict"], "#555"), v=r["verdict"].upper(),
            d=r["durationMs"], t=html.escape(r["title"]))
        for r in rows)
    type_rows = "\n".join(
        f"<tr><td>{t}</td><td>{b['total']}</td><td>{b['passed']}</td><td>{b['failed']}</td><td>{b['blocked']}</td></tr>"
        for t, b in sorted(by_type.items()))
    html_doc = f"""<!doctype html><html lang="en"><head><meta charset="utf-8">
<title>QAIA execution report — {html.escape(us_id)}</title>
<style>
body{{font:14px/1.5 system-ui,sans-serif;margin:2rem;max-width:1100px}}
table{{border-collapse:collapse;width:100%;margin:1rem 0}}
th,td{{border:1px solid #ddd;padding:.4rem .6rem;text-align:left;vertical-align:top}}
th{{background:#f4f4f5}} code{{font-family:ui-monospace,monospace}}
.kpi{{display:inline-block;margin-right:2rem;font-size:1.1rem}}
</style></head><body>
<h1>Execution report — {html.escape(us_id)}</h1>
<p>Source run: <code>{html.escape(os.path.basename(src))}</code> ·
generated {datetime.datetime.now(datetime.timezone.utc).replace(microsecond=0).isoformat().replace('+00:00','Z')}</p>
<p><span class="kpi">Total <b>{total}</b></span><span class="kpi" style="color:#1a7f37">Passed <b>{passed}</b></span>
<span class="kpi" style="color:#b3261e">Failed <b>{failed}</b></span>
<span class="kpi" style="color:#8a6d00">Blocked/skipped <b>{blocked}</b></span></p>
<h2>Per-type breakdown</h2>
<table><tr><th>Type</th><th>Total</th><th>Passed</th><th>Failed</th><th>Blocked</th></tr>
{type_rows}</table>
<h2>AC → scenario → test → result traceability</h2>
<table><tr><th>Scenario ID</th><th>AC</th><th>Priority</th><th>Type</th><th>Result</th><th>Duration</th><th>Test title</th></tr>
{trs}</table>
<p style="color:#666">Blocked/skipped tests are reported as such, never as passed (run-report guardrail).
This report carries counts and paths only — no secrets, no environment URLs, no PII.</p>
</body></html>"""
    with open(os.path.join(outdir, "execution-report.html"), "w", encoding="utf-8") as f:
        f.write(html_doc)

    execution = {
        "total": total, "passed": passed, "failed": failed, "blocked": blocked,
        "byType": by_type,
        "traceability": {"scenariosAutomated": total, "scenariosTotal": None},
    }
    with open(os.path.join(outdir, "execution-section.json"), "w", encoding="utf-8") as f:
        json.dump(execution, f, indent=2)
    print(json.dumps(execution, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
