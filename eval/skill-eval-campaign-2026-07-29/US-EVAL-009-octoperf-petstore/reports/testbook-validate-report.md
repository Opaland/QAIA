# testbook-validate report — US-EVAL-009

## Deterministic structural pass (real script execution, not simulated)

Ran (Git Bash, real subprocess, no simulation):

```
python eval/tools/structural_score.py eval/skill-eval-campaign-2026-07-29/US-EVAL-009-octoperf-petstore/testbooks/octoperf-petstore-cart.feature --acs AC1,AC2,AC3 --source eval/skill-eval-campaign-2026-07-29/US-EVAL-009-octoperf-petstore/state/01-extraction.md
```

Ran clean (no `UnicodeEncodeError` — the Windows-console UTF-8 fix from `US-EVAL-001` is still in
effect). `--source` was passed per this skill's own rule (line 19: "If a source/matrix exists in
the inputs but was not passed, the report must say the sniffer/completeness ran blind") — it did
not run blind here.

**Result** (real output, verbatim):

```json
{
  "file": "octoperf-petstore-cart.feature",
  "scenarios": 8,
  "readability": 25.0,
  "completeness": 30.0,
  "coherence": 20.0,
  "traceability": 25.0,
  "penalties": { "markers": 0, "sniffer": 10, "redundancy": 0 },
  "score": 90,
  "gate": "PASS",
  "forced_stop": false,
  "findings": [
    "fabrication sniffer: 2 untraceable technical literal(s): [(\"The Sub Total equals the sum of every distinct item's total cost\", 'EST-2'), ('Removing one item recomputes the Sub Total without affecting the remaining item', 'EST-2')]"
  ],
  "tag_audit": {
    "missing_priority_tag": [],
    "technique_tag_violations": [],
    "negative_scenarios": 1,
    "non_smoke_scenarios": 8,
    "negative_ratio_recomputed_pct": 12.5
  }
}
```

**Structural score 90/100 — a real, honest PASS, but with a genuine sniffer finding worth
surfacing rather than waving away.** The sniffer flagged `EST-2` (used in scenarios `003` and
`006` to build a second, distinct cart line for the Sub Total arithmetic) as an untraceable
technical literal — a −10 penalty (2 hits × −5), below the ≥3-hit forced-STOP threshold. This is
**not a fabrication**: `EST-2` ("Small Angelfish", `$16.50`) is a real, live-observed literal,
captured verbatim in `state/00-source.md`'s "What was actually fetched" section
(`WebFetch .../Catalog.action?viewProduct=&productId=FI-SW-01`). It is untraceable specifically
**to the file this run passed as `--source`** (`01-extraction.md`), because `01-extraction.md`'s
Story/AC text only ever names `EST-1` explicitly — `EST-2` appears solely inside `03-design.md`'s
own condition text (`AC2-C2`), one layer downstream of what the sniffer was fed. This traces to a
genuine ambiguity in `testbook-validate` step 2's own instruction ("Feed it the source when
available... pass `--source`/`--acs`") — it never specifies *which* checkpoint counts as "the
source" when a deeper raw capture (`00-source.md`) and a reviewed extraction (`01-extraction.md`)
both exist and disagree on which literals they quote. Every prior campaign run that used `--source`
pointed it at the `01-*` extraction file, the same choice made here — so this is the first run
whose test fixtures needed a second catalog item, which is what exposes the gap. Not a fabricated
literal, but a real, reproducible false-positive risk in how the sniffer is invoked.

No redundancy finding this run (`penalties.redundancy: 0`) — no two scenarios share an identical
`Given`/`When` shape. No hollow/empty/vague `Then` detected (`completeness: 30.0`, full marks —
every scenario asserts a concrete dollar amount, row presence/absence, or availability state), so
`forced_stop` is correctly `false`.

## 8-dimension checklist

| Dimension | Score | Evidence |
|---|---|---|
| Atomicity | 2 | One `When` per scenario; outcomes only in `Then`; no `Scenario Outline` needed this run (every condition is a single concrete case). |
| Coverage | 2 | AC1 2/2, AC2 2/3, AC3 3/5 — every AC has ≥1 covering scenario; the 3 missing conditions (`AC2-C1`, `AC3-C2`, `AC3-C3`) are cited P3 waivers, not silent AC-level gaps. |
| Negative-path coverage (ADR 0001) | 2 | The only `[req-neg]`-tagged condition in this design (`AC3-C5`) has a covering `@negative` scenario (`008`); the three deferred P3 conditions are correctly not `[req-neg]` (their outcomes are not refusals), so no `[req-neg]` condition is uncovered without a cited reason. |
| Technique fit | 2 | `@ep` for add/format classes, `@state-transition` for re-entrance on add/remove, `@decision-table` for the out-of-stock and session-scoping axes, `@oracle:iso4217` grounding the currency-format assertion instead of guessing it. |
| Business correctness | 1 | No scenario asserts a value contradicting any source, and every dollar figure is arithmetic over live-observed prices — but two of the three P1 scenarios (`007`, `008`) rest on genuinely `[open]` proposed defaults that could each turn out to be the *opposite* of OctoPerf's real behavior (Q3, Q7), and the structural pass's real sniffer hit on `EST-2` (above) is a legitimate, if explainable, traceability weak point on exactly the scenarios building the book's core multi-item arithmetic (`003`, `006`). Honestly flagged throughout, but full-confidence business correctness cannot be claimed. |
| Ambiguity honesty | 2 | Q1-Q7 all visible in `synthesis.md`'s open/assumption list; `002`, `004`, `005`, `007`, `008` explicitly carry `@low-confidence` and inline `# assumption:`/`# open:` comments matching the design/priorities checkpoints; the 3 P3 deferrals state their reason and are correctly distinguished from a `[req-neg]` waiver rather than mislabeled. |
| Traceability | 2 | Stable `@QAIA-US-EVAL-009-NNN` IDs, `# condition:` comment on every scenario, matrix consistent with the book. |
| Gherkin form | 2 | Valid keywords, no `Background` (correctly omitted — no invariant holds across all 8 scenarios: some start from an empty cart, others from a pre-populated one, one spans two sessions). |

**Total: 15/16.** Per the gate rule, a total ≥14 with **business correctness at 1** forces
**CONCERNS**, not PASS, regardless of the total.

## Gate decision

Two gates, stricter wins: structural = **PASS** (90/100), checklist = **CONCERNS** (15/16, business
correctness capped at 1) → **overall: CONCERNS**.

## Three highest-impact fixes

1. **Arbitrate Q3 and Q7 for real** (`AC3-C4`/`007`, `AC3-C5`/`008`) — both are P1, both rest on
   unconfirmed proposed defaults, and getting either wrong means the scenario asserts the
   *opposite* of OctoPerf/JPetStore's real behavior. Q7 (cross-session cart isolation) is the
   higher-stakes of the two — a wrong assumption there means this book fails to test a genuine
   access-control boundary, not just a business-policy nuance.
2. **Re-run the structural pass with a richer `--source`** (e.g. concatenating `00-source.md`'s
   captured text alongside `01-extraction.md`, or passing `00-source.md` directly) so fixture-level
   literals like `EST-2` — real, live-observed, but only ever quoted in the raw capture, not the
   AC-level extraction — are recognized rather than flagged as untraceable. This is a real,
   reproducible gap in *how* the sniffer was invoked this run, not in the scenario content itself.
3. **Obtain a stateful test harness** (e.g. Playwright with a persisted session cookie, out of
   scope for this exploration-only `WebFetch` capture) to directly observe Q1 (repeat-add quantity
   behavior) and Q7 (cross-session isolation) instead of relying on proposed defaults — the same
   limitation that made both genuinely `[open]`/`[assumption]` in the first place.

No file was modified by this audit (`testbook-validate` is audit-only, per its own guardrails).

## Skill evaluation — `testbook-validate`

- **Skill evaluated**: `plugins/qaia-core/skills/testbook-validate/SKILL.md`.
- **Input**: `octoperf-petstore-cart.feature` (8 scenarios), `01-extraction.md` as `--source`.
- **Output**: this report.
- **Verdict**: **CONFORME** (with a procedural gap documented, not treated as an écart against this
  run's own execution).
- **Evidence**: line 19's rule that a source available but not fed must be reported as a blind run
  was correctly avoided by actually passing `--source`/`--acs` in the recorded command. Line 21's
  rule that the structural pass and the checklist stay "separate... never averaged together" is
  respected: the report shows 90/100 and 15/16 as two distinct numbers, combined only at the
  gate-decision step by taking the stricter of the two. Line 38 ("be as strict with QAIA-generated
  books as with external ones") is exercised concretely: business correctness is capped at 1
  despite a high structural score (90, PASS) rather than letting the strong structural number
  soften the checklist's own independent read of the two open P1 scenarios. The sniffer's `EST-2`
  finding surfaced a real ambiguity in the skill's own text (line 19 never specifies which
  checkpoint file counts as "the source" when a raw capture and a reviewed extraction disagree on
  which literals they quote) — documented above as a highest-impact fix and left for a separate
  evaluator pass to judge whether it rises to an `ÉCART MINEUR` against the skill text itself,
  rather than pre-judged here by the producer.
- **Modification proposed**: none (by this producer — see the separate evaluator verdict for
  whether `SKILL.md` line 19 itself warrants a clarifying edit).
