#!/usr/bin/env python3
"""Deterministic structural scorer for Gherkin test books (maintainer eval tooling).

Grounds issues #26 (deterministic score, not an LLM self-note), #27 (anti-fabrication
sniffer) and #28 (a case with no verifiable expected result is a question, not a test),
themselves derived from the founding project's documented failure modes (case US 676266:
100/100 machine vs 58/100 human — an AC "covered" by an unreadable image, a case with no
expected result, idempotence gaps).

Also detects the "pesticide paradox" (#24 gap harness, mode 3b): near-duplicate scenarios
whose Given/When shape is identical and only a literal changed, with no distinct assertable
behavior — the same test repeated under a new name catches nothing new. A real per-value
behavioral difference (a distinct validation rule, a distinct boundary in the Then) is NOT
flagged: only steps are compared, so a differing Then on structurally-identical Given/When
still counts as a duplicate at the step-shape level and is reported for human judgment, not
auto-failed (unlike C1/C2/sniffer, redundancy alone never forces STOP).

NO LLM, NO network — reproducible and auditable, by design. This lives in eval/ (it is a
maintainer measurement tool), NOT in plugins/ (it is not shipped to installers). The plugin
skills reference the *approach*; this proves it discriminates on a hardened gold set.

Usage: python3 structural_score.py <file.feature> [--acs AC1,AC2,...] [--source src.md]
       python3 structural_score.py --batch <dir>
"""
import re, sys, os, json, glob

TECHNIQUE_TAGS = {"@ep", "@boundary", "@decision-table", "@state-transition", "@use-case", "@pairwise", "@error-guessing"}
PRIORITY_TAGS = {"@p1", "@p2", "@p3"}

MARKER_RE = re.compile(r"\[\s*(?:À|A)\s*D[EÉ]FINIR[^\]]*\]|\bTODO\b|\bFIXME\b|<\s*placeholder\s*>|\bXXX\b|\bTBD\b", re.I)
# a Then that defers to an external artifact as its sole evidence is hollow (C1 of case 676266).
# Requires a referential/deference cue immediately before the artifact noun (#24 gap-harness
# fix: the naive "contains the word image/table" version false-positived on legitimate business
# assertions that merely mention a picture/image field, e.g. "the picture should be the default
# image" — found by running the scorer on a real generated .feature, not a hand-built fixture).
HOLLOW_RE = re.compile(
    r"\b(voir|see|cf\.?|selon|according to|refers? to|referred to|se r[ée]f[ée]rer (à|au)|consulter|"
    r"conforme (au|à l['’]|aux)|correspond(ent|s)? (au|à|aux)|as (shown|depicted) (in|on))\s+"
    r"(le\s+|la\s+|les\s+|the\s+|l['’])?(tableau|table|image|screenshot|capture d.?[ée]cran|copie d.?[ée]cran|annexe|maquette)\b"
    r"|\b(exactement\s+)?(exactly\s+)?(tel(le)?\s+que|as)\s+(dessin[ée]|dessin[ée]e|drawn|configur[ée]|configured|"
    r"sp[ée]cifi[ée]|specified|document[ée]|documented|d[ée]crit(e)?|described|illustr[ée]|illustrated|"
    r"[ée]crit(e)?|written)\b",
    re.I,
)
# vague, non-verifiable outcomes (C2): restates success without an asserted value/state/status.
# Also catches non-committal deferrals to "a rule/mechanism" and circular restatements of a
# formula ("is the sum of...") that name no concrete resulting number/state — found via the
# corpus-24-depth C5/C10/C18 gap: these evade the original narrow success-word list entirely,
# scoring completeness down but never surfacing as a named C2 finding (eval/baselines/corpus-24-depth.md).
VAGUE_RE = re.compile(
    r"\b(correct(e|ement)?|comme attendu|as expected|works?|fonctionne|r[ée]pond correctement|"
    r"le syst[eè]me r[ée]pond|properly|ok|sans erreur|no error|success(fully)?|"
    r"appropri[ée]e?(ment)?|appropriately|as appropriate|"
    r"(une\s+)?r[èe]gle\s+d[ée]terministe|deterministic rule|"
    r"\bconsistent(e|ly)?\b|\bcoh[ée]rent(e|s)?\b|"
    r"(is|est|sont|are)\s+(the\s+|le\s+|la\s+|les\s+)?(sum|somme|total|full amount|montant (complet|int[ée]gral)|correct amount|montant correct))\b",
    re.I,
)
# a real assertion carries a concrete token: number, quoted value, status code, comparator, state verb
ASSERT_RE = re.compile(r"\d|\"[^\"]+\"|'[^']+'|\b(status|code|HTTP|=|==|>=|<=|>|<|equals?|[ée]gal|contains?|contient|affiche|displays?|redirect|returns?|retourne|is (not )?(visible|present|enabled|disabled)|est (visible|pr[ée]sent|absent))\b", re.I)
# fabrication sniffer: technical literals that should trace to a source/oracle
TECH_LITERAL_RE = re.compile(r"https?://\S+|\b\d{1,3}(?:\.\d{1,3}){3}\b|\b[a-z0-9.-]+\.(?:com|net|org|io|local|internal)\b|:\d{2,5}\b|\b[A-Z]{2,}-\d+\b|\b\d+[.,]\d{2}\s?(?:€|EUR|\$|USD)\b", re.I)

def parse_scenarios(text):
    scen, cur = [], None
    tags_pending = []
    for raw in text.splitlines():
        line = raw.strip()
        if line.startswith("@"):
            tags_pending += line.split()
            continue
        m = re.match(r"(Scenario Outline|Scenario|Sc[ée]nario|Plan du sc[ée]nario)\s*:\s*(.*)", line, re.I)
        if m:
            if cur: scen.append(cur)
            cur = {"name": m.group(2).strip(), "tags": tags_pending, "steps": [], "then": []}
            tags_pending = []
            continue
        # tags only bind to the next scenario, but a comment line between the tags and the
        # `Scenario:` line (e.g. "# Condition: ...", common when a scenario cites its source
        # condition) must not wipe them — found via cross-model comparison (#25bis-multimodel):
        # this exact pattern silently dropped every tag past the first scenario in a real
        # generated .feature, tanking traceability to ~0 for a file that was actually tagged.
        if not line.startswith("#"):
            tags_pending = tags_pending if not cur else []
        if cur is not None:
            sm = re.match(r"(Given|When|Then|And|But|Soit|Quand|Alors|Et|Mais|Etant donn[ée])\b(.*)", line, re.I)
            if sm:
                kw, txt = sm.group(1), sm.group(2).strip()
                cur["steps"].append((kw, txt))
    if cur: scen.append(cur)
    # attach 'then' steps: a Then and the And/But that follow it
    for s in scen:
        in_then = False
        for kw, txt in s["steps"]:
            k = kw.lower()
            if k in ("then", "alors"): in_then = True; s["then"].append(txt)
            elif k in ("and", "but", "et", "mais") and in_then: s["then"].append(txt)
            elif k in ("given", "when", "soit", "quand", "etant donné", "etant donnée"): in_then = False
    return scen

def score_feature(path, declared_acs=None, source_text=None):
    text = open(path, encoding="utf-8").read()
    scen = parse_scenarios(text)
    findings = []
    n = len(scen) or 1

    # --- detectors ---
    markers = MARKER_RE.findall(text)
    truncated = [s["name"] for s in scen if any(t.endswith(("…", "...", ",", "-")) or (len(t.split()) < 2) for _, t in s["steps"] if t)]
    empty_then = [s["name"] for s in scen if not s["then"]]
    hollow = [s["name"] for s in scen if s["then"] and all(HOLLOW_RE.search(t) for t in s["then"])]
    vague = [s["name"] for s in scen if s["then"] and not any(ASSERT_RE.search(t) for t in s["then"]) and any(VAGUE_RE.search(t) for t in s["then"])]
    # a scenario "really covers" only if it has a Then with a concrete assertion, not hollow/empty
    def covers(s): return bool(s["then"]) and s["name"] not in empty_then and s["name"] not in hollow and s["name"] not in vague and any(ASSERT_RE.search(t) for t in s["then"])
    traced = [s for s in scen if any(re.match(r"@QAIA-", t) for t in s["tags"])]
    ac_linked = [s for s in scen if any(re.search(r"@AC[:_-]?\w+|@QAIA-\w+-\d+", t) for t in s["tags"])]

    # fabrication sniffer: technical literals present in a step but not in the source (if given)
    sniffer_hits = []
    if source_text is not None:
        for s in scen:
            for _, t in s["steps"]:
                for lit in TECH_LITERAL_RE.findall(t):
                    if lit and lit not in source_text:
                        sniffer_hits.append((s["name"], lit))

    # pesticide-paradox / redundancy detector (#24 mode 3b): group scenarios by the
    # normalized shape of their Given/When steps only (literals collapsed) — same shape,
    # different literal, no new behavior. Then is deliberately excluded from the shape key:
    # a distinct assertion on an identical Given/When is still flagged (reported, not failed)
    # so a human decides whether it is a real per-value rule or a copy-paste scenario.
    def normalize_step(t):
        t = re.sub(r'"[^"]*"|\'[^\']*\'', "<val>", t)
        t = re.sub(r"\d+", "<num>", t)
        return re.sub(r"\s+", " ", t).strip().lower()
    def shape_key(s):
        gw, in_then = [], False
        for kw, t in s["steps"]:
            k = kw.lower()
            if k in ("then", "alors"): in_then = True; continue
            if k in ("given", "when", "soit", "quand", "etant donné", "etant donnée"): in_then = False
            if in_then: continue
            gw.append(("and" if k in ("and", "but", "et", "mais") else k, normalize_step(t)))
        return tuple(gw)
    shape_groups = {}
    for s in scen:
        shape_groups.setdefault(shape_key(s), []).append(s["name"])
    redundant_groups = [names for names in shape_groups.values() if len(names) > 1]
    redundant_scenarios = [name for group in redundant_groups for name in group]

    # --- independent tag/ratio audit (reported facts, NOT folded into the /100 score) ---
    # This is the mechanical bookkeeping half of the gate (tag presence, ratio) — deliberately
    # kept separate from the 0-100 budget above so it never silently shifts scores for fixtures
    # that predate this check, and separate from the generator's OWN self-reported ratio (rule 3:
    # no producer scores/validates itself — the ratio a user sees must be independently
    # recomputed from the .feature file, not trusted from synthesis.md).
    def tags_lower(s): return {t.lower() for t in s["tags"]}
    no_priority = [s["name"] for s in scen if not (tags_lower(s) & PRIORITY_TAGS)]
    technique_hits = [s["name"] for s in scen for t in [tags_lower(s) & TECHNIQUE_TAGS]
                       if len(t) != 1 and "@smoke" not in tags_lower(s)]
    smoke = [s for s in scen if "@smoke" in tags_lower(s)]
    negative = [s for s in scen if "@negative" in tags_lower(s)]
    non_smoke_n = len(scen) - len(smoke) or 1
    negative_ratio_recomputed = round(100 * len(negative) / non_smoke_n, 1)
    tag_audit = {
        "missing_priority_tag": no_priority,
        "technique_tag_violations": technique_hits,
        "negative_scenarios": len(negative),
        "non_smoke_scenarios": non_smoke_n,
        "negative_ratio_recomputed_pct": negative_ratio_recomputed,
    }

    # --- deterministic /100 (explicit budget, like a real tg_scorer) ---
    readability = 25 * (len([s for s in scen if s["name"] and s["steps"]]) / n)
    completeness_base = len([s for s in scen if covers(s)]) / n
    if declared_acs:
        covered_acs = set()
        for s in scen:
            if covers(s):
                for tag in s["tags"]:
                    for ac in declared_acs:
                        if ac.lower() in tag.lower(): covered_acs.add(ac)
        completeness = 30 * (len(covered_acs) / len(declared_acs))
    else:
        completeness = 30 * completeness_base
    coherence = 20 * (1 - (len(set(truncated + empty_then)) / n))
    traceability = 25 * (len(traced) / n) * (0.6 + 0.4 * (len(ac_linked) / n))

    raw = readability + completeness + coherence + traceability
    marker_pen = min(25, 5 * len(markers))
    sniffer_pen = min(25, 5 * len(sniffer_hits))
    redundancy_pen = min(15, 3 * len(redundant_scenarios))
    score = max(0, round(raw - marker_pen - sniffer_pen - redundancy_pen))

    # forced STOP (IEC-style): >=3 fabrication/marker hits, or any hollow/empty/vague Then.
    # Redundancy alone never forces STOP (mode 3b — real per-value assertions may still
    # differ on an identical Given/When; a human, not the detector, judges that call).
    forced_stop = (len(markers) + len(sniffer_hits) >= 3) or bool(hollow or empty_then or vague)
    if forced_stop: gate = "FAIL"
    elif score >= 80: gate = "PASS"
    elif score >= 60: gate = "CONCERNS"
    else: gate = "FAIL"
    # a truncated step is never publishable as-is: cap a would-be PASS at CONCERNS
    if truncated and gate == "PASS": gate = "CONCERNS"

    if markers: findings.append(f"{len(markers)} unresolved marker(s) → -{marker_pen}")
    if sniffer_hits: findings.append(f"fabrication sniffer: {len(sniffer_hits)} untraceable technical literal(s): {sniffer_hits[:3]}")
    if hollow: findings.append(f"hollow AC (C1 — covered only by an image/table ref): {hollow}")
    if empty_then: findings.append(f"no expected result (C2 — a question, not a test): {empty_then}")
    if vague: findings.append(f"vague/non-verifiable Then (C2): {vague}")
    if truncated: findings.append(f"truncated step(s): {truncated}")
    if redundant_groups: findings.append(f"pesticide paradox: {len(redundant_groups)} near-duplicate group(s) (same Given/When shape) → -{redundancy_pen}: {redundant_groups[:3]}")
    if no_priority: findings.append(f"missing priority tag (@P1/@P2/@P3): {no_priority}")
    if technique_hits: findings.append(f"technique tag count != 1 from the closed list: {technique_hits}")

    return {
        "file": os.path.basename(path), "scenarios": len(scen),
        "readability": round(readability, 1), "completeness": round(completeness, 1),
        "coherence": round(coherence, 1), "traceability": round(traceability, 1),
        "penalties": {"markers": marker_pen, "sniffer": sniffer_pen, "redundancy": redundancy_pen},
        "score": score, "gate": gate, "forced_stop": forced_stop, "findings": findings,
        "tag_audit": tag_audit,
    }

def main():
    args = sys.argv[1:]
    if not args: print(__doc__); sys.exit(1)
    if args[0] == "--batch":
        rows = [score_feature(f) for f in sorted(glob.glob(os.path.join(args[1], "*.feature")))]
        for r in rows: print(json.dumps(r, ensure_ascii=False))
        return
    declared = None; source = None; path = args[0]
    if "--acs" in args: declared = args[args.index("--acs") + 1].split(",")
    if "--source" in args: source = open(args[args.index("--source") + 1], encoding="utf-8").read()
    print(json.dumps(score_feature(path, declared, source), ensure_ascii=False, indent=2))

if __name__ == "__main__":
    main()
