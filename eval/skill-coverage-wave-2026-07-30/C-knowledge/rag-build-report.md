# rag-build — step 3 "Report"

Skill exercised: `plugins/qaia-core/skills/rag-build/SKILL.md`.
Source rule material: `eval/skill-eval-campaign-2026-07-29/US-EVAL-009-octoperf-petstore/state/01-extraction.md`
(+ `02-understanding.md` for the open/assumption classifications).
Format reference: `examples/rag-demo/knowledge/`, `examples/carpool-demo/knowledge/`.

## What changed

| File | Change |
|---|---|
| `knowledge/index.md` | created — master index, 1 row (`path \| topic \| tags`), plus the pending-validation note on the three starter files not created |
| `knowledge/business-rules.md` | created — 6 rules `BR-KB-001`..`BR-KB-006`, each with a provenance line; 6 explicitly *non*-rules listed separately |

Suggested commit message:
`knowledge: seed cart arithmetic & checkout rules from US-EVAL-009 (BR-KB-001..006)`

Per the skill's step 3, **no git command was run**.

## Step-by-step conformance

- **Step 1 Initialize** — `knowledge/` + `index.md` created. The four starter files were *offered*,
  not created: only `business-rules.md` had real sourced content. `glossary.md`,
  `application-map.md`, `anomaly-history.md` require the "2-3 seed questions" the skill mandates
  asking the user, and this run is non-interactive → **pending-validation**, recorded in
  `index.md` itself rather than silently skipped.
- **Step 2 Enrich** — index checked (empty base → no target-file ambiguity); duplicate and
  **contradiction** check run against existing content: none existed, so no ⚠ VALIDATION
  arbitration was triggered. Provenance (US-ID, date, decided-by) written on all 6 entries. No
  split needed (see budget below).
- **Step 3 Report** — this file.

## Format verification (real script, not a claim)

`evidence/verify_knowledge_format.py` → `evidence/verify_knowledge_format.out.txt`:

```
 - indexed rows: ['business-rules.md']
 - files present: ['business-rules.md']
 - business-rules.md: 4257 chars ~= 1064 tokens (budget 2048)
 - index.md: 1402 chars ~= 350 tokens (budget 2048)
 - business-rules.md / BR-KB-001..006: provenance OK
=== RESULT ===
 PASS: knowledge base conforms to the documented rag-build layout
```

Checks: index existence, index↔file bijection, 3-column rows, ≤ ~2k tokens per file (D21),
provenance on every `## BR-KB-` heading, no secret/internal-URL pattern. **PASS**, exit 0.

## Guardrails

- No secrets, no credentials, no internal-environment URL, no personal data. The target host
  (`petstore.octoperf.com`) is a public shared demo and is deliberately **not** written into any
  knowledge file — only into this report.
- Entries are declarative and testable (`"Sub Total equals the sum of every row's Total Cost"`),
  never narrative.
- Everything still `[open]`/`[assumption]` upstream is quarantined in a "Not yet rules" table
  instead of being laundered into a rule. This is the choice with the most leverage in this run:
  4 of the 6 questions `need-understanding` raised would read as perfectly plausible rules.

## ÉCART MINEUR — `rag-build` allocates `BR-KB-nnn` IDs with no stated authority

`rag-build/SKILL.md` never mentions the `BR-KB-nnn` scheme, yet it is the skill that writes
`knowledge/business-rules.md`, the reference example
`examples/rag-demo/knowledge/business-rules.md` uses those IDs throughout (`## BR-KB-004`,
`## BR-KB-007`, …), and `skills/README.md` line 63 makes citation by that ID mandatory
(*"`BR-KB-nnn` in the checkpoint that used it … matching `feedback`/`rag-build`'s IDs"*).

The counter is defined only in `feedback/SKILL.md` step 4 — *"Rules get stable IDs `BR-KB-nnn`
(counter persisted in `rules.md` frontmatter)"* — and `rules.md` lives under `feedback/`, which a
knowledge-first project (the skill's own step 1 "Initialize", first use) does not have. So this
run had to invent `BR-KB-001`..`006` on its own authority, and the `feedback` run in this same
wave independently opened its counter at `BR-KB-001` too (`feedback/rules.md` frontmatter
`nextRuleId: BR-KB-001`). Two distinct `BR-KB-001`s now coexist in one output directory. Not
fixed here.

**Proposed diff (NOT applied)** — `rag-build/SKILL.md`, step 2, after "write the entry with its
provenance (US-ID, date, decided-by)":

```diff
+   - allocate the entry's stable ID `BR-KB-nnn` from the **single project-wide counter**: read
+     `feedback/rules.md`'s `nextRuleId` frontmatter if that file exists, otherwise the highest
+     `BR-KB-nnn` already present in `knowledge/`, otherwise start at `BR-KB-001` — and write the
+     new high-water mark back to whichever of the two files exists. Never restart a counter that
+     another skill already opened.
```

## Handoff note

Nothing was handed over from `feedback` this run: that skill promoted zero rules (see
`feedback/rules.md`). The 6 rules here come straight from the US source, which is `rag-build`'s
other documented input, not from a promotion.
