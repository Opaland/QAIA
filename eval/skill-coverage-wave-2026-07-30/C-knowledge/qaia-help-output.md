# qaia-help — real execution + claim-vs-repo cross-check

Skill exercised: `plugins/qaia-core/skills/qaia-help/SKILL.md` (read-only, per its own line 8).
Nothing was modified. Raw inspection output: `evidence/qaia_help_inspect.out.txt`.

---

## Part 1 — the skill's actual output on a real project root

Root chosen: `examples/expense-demo/qaia-journey/` — the only *complete* journey in the repo that
follows the contract layout (`state/<US-ID>/journey.md`).

> **US-004** : journey ledger complete through `06-export (Playwright automation)` (2026-07-25,
> 38 scenarios in 4 `.feature` files, negative ratio 45.9 %) — next: **`feedback`**, the one step
> of the journey never run on this US.
> Open ambiguities and pending validations: the ledger records 9 questions (5 open, 4 assumption)
> at `02-understanding` and `simulated: <default applied>` at every ⚠ VALIDATION point, so **all
> of them are still pending human review**.
> Resume frontmatter: **absent** (`journey.md` has no YAML block) — per SKILL.md line 13 this
> diagnosis falls back to the ledger alone, and that is stated here rather than guessed.
> Project level: knowledge base **absent** (no `knowledge/index.md` under this root) —
> initializing `rag-build` would help, since this project's rules currently live nowhere;
> promoted rules count: **not available** (no `feedback/rules.md`).
>
> **Single recommended next action: run `feedback` on US-004** to capture what a reviewer would
> change in the generated book, since it is the only unrun journey step. *(Not auto-run —
> guardrail line 22.)*

That output is what the skill produces when its preconditions hold. The rest of this file is the
cross-check the task asked for, and it is where the skill does not hold up.

---

## Part 2 — claim vs. repo, item by item

Repo inventory, measured (`find plugins -name SKILL.md | wc -l` → **29**; per plugin
`ls plugins/*/skills/`): qaia-core **15**, qaia-playwright **11**, qaia-score **2**,
qaia-testdata **1**. Four plugins. This matches the task's stated inventory exactly.

### ÉCART STRUCTUREL 1 — the read allowlist glob matches almost nothing in this repo

`SKILL.md` line 12: *"Read only: `state/*/journey.md` (frontmatter and ledger)"*.

Measured (`find . -path "*/state/*/journey.md" | wc -l` → **5**;
`find . -name journey.md | wc -l` → **19**): **only 5 of 19 real `journey.md` files in the repo
sit where this glob can find them.** The other 14:

- 10 campaign roots (`eval/skill-eval-campaign-2026-07-29/US-EVAL-0NN-*/state/journey.md`) put the
  ledger flat under `state/`, one directory per US at the *root* level;
- 4 token-pilot roots (`eval/baselines/*-token-pilot/US-00N/journey.md`) put it at the US root.

Verbatim from `evidence/qaia_help_inspect.out.txt`, on the richest completed journey in the repo:

```
ROOT: eval/skill-eval-campaign-2026-07-29/US-EVAL-009-octoperf-petstore
  .qaia/ present: False -> inspecting base: eval/.../US-EVAL-009-octoperf-petstore
  state/*/journey.md  -> NONE MATCHED
  !! journey.md found OUTSIDE the allowlist glob, at state/journey.md: ['...\state\journey.md']
  testbooks/*/        -> ['coverage-matrix.md', 'octoperf-petstore-cart.feature', 'synthesis.md']
```

qaia-help would report "no US found" on a root that contains a fully generated, validated test
book. Because line 12 is an exhaustive *allowlist*, the skill has no licence to widen the glob at
runtime — it is structurally blind here, not merely unlucky.

**Proposed diff (NOT applied)** — `SKILL.md` line 12:

```diff
-Read only: `state/*/journey.md` (frontmatter and ledger), `knowledge/index.md` ...
+Read only: the journey ledger, located at `state/<US-ID>/journey.md` (canonical) **or**
+`state/journey.md` when the output root is itself a single-US directory (rule 9 re-basing) —
+if both shapes are absent but a `state/` directory exists, report "journey ledger not found at
+either canonical path" instead of "no US found", `knowledge/index.md` ...
```

### ÉCART STRUCTUREL 2 — the journey model omits two steps that real ledgers record

`SKILL.md` line 13: *"determine the first incomplete step of the journey (ingest → review →
understanding → design → priorities → generate → export → feedback)"* — 8 steps.

The real US-EVAL-009 ledger (`.../state/journey.md`, lines 5-12) records **8 done steps that are
not that list**:

```
| 05-testbook-generate | done | ...
| 06-report            | done | `reports/manifest.json` written, `validate_manifest.py` -> PASS
| 07-testbook-validate | done | real script execution -- structural PASS (90/100) ...
```

`report` and `testbook-validate` are journey skills — `qaia/SKILL.md` line 15 dispatches to both
by name, and `skills/README.md` makes `reports/<US-ID>/manifest.json` "the one output contract
every QAIA plugin shares (D39)". qaia-help's model has no slot for either, so on this ledger it
would compute "first incomplete step = export" and recommend `testbook-export`, when the real
next action is the human Go/No-Go gate the ledger states explicitly (lines 14-19).

Compounding it, line 12's allowlist does not include `reports/`, so qaia-help **cannot see whether
`report` ran at all** even if the step were in its model. Confirmed in the raw output: `reports/`
holds `manifest.json` and `testbook-validate-report.md`, both outside the allowlist.

**Proposed diff (NOT applied)** — `SKILL.md` lines 12-13:

```diff
-`testbooks/*/` (existence, file names). Do not read testbook contents or other state files.
+`testbooks/*/` (existence, file names), `reports/*/manifest.json` (existence + its `gate`
+field only). Do not read testbook contents or other state files.
-determine the first incomplete step of the journey (ingest -> review -> understanding -> design
--> priorities -> generate -> export -> feedback)
+determine the first incomplete step of the journey (ingest -> review -> understanding -> design
+-> priorities -> generate -> report -> validate -> export -> feedback). A ledger step whose name
+matches none of these is reported verbatim rather than silently skipped.
```

### ÉCART MINEUR 3 — "the single recommended next action" can never name 14 of the 29 skills

qaia-help is the "what now?" skill, and step 3 promises *"the single recommended next action, as
one sentence naming the skill to invoke."* Its journey model ends at `feedback`, so it can only
ever name qaia-core skills. The 14 skills of the other three plugins — the entire automation step
of the canonical parcours (`docs/SKILL-EVAL-CAMPAIGN-PROMPT.md` step 8: `automate`, `a11y-audit`,
`perf-check`, `security-surface`, `contract-probe`) plus `qaia-score`'s gate and
`qaia-testdata`'s `dataset-generate` — are unreachable from it. Concretely: on the expense-demo
root above, `06-export (Playwright automation)` is *done* and `examples/expense-demo/tests/`
exists, yet qaia-help has no vocabulary to say "next: `run-report`" or "next: `aptitude-gate`".
It is not wrong, it is silent — a user who is lost after export stays lost.

**Proposed diff (NOT applied)** — append to `SKILL.md` step 3:

```diff
+   - when the journey's last step is complete, the recommended next action crosses plugins:
+     name the automation skill matching the test type (`automate` / `a11y-audit` / `perf-check` /
+     `security-surface` / `contract-probe`), then `run-report` and `aptitude-gate`. Say plainly
+     when a plugin providing it is not installed rather than recommending nothing.
```

### ÉCART MINEUR 4 — "the three ways to start" are documented nowhere else

`SKILL.md` line 18 presents *"QAIA Lite ... QAIA Solo ... QAIA Full"* as an established product
concept. Repo-wide, the only other occurrence
(`grep -rn "QAIA Lite" --include=*.md .`) is `docs/BMAD-ANALYSIS.md` line 29, where it is an
**open action item**, not documentation:

```
| A11 | **Modeles d'engagement gradues** (a la « TEA Lite ») | Documenter : QAIA Lite ... | M1 (doc) |
```

So the names exist only inside this skill and inside a to-do. A user told "you're in QAIA Solo"
has nothing to read. Not a behavioural bug; a dangling reference.

### Verified correct (no écart)

- Every skill named by qaia-help exists: `rag-build`, `testbook-export`, `us-ingest` — all three
  resolve to real `SKILL.md` files.
- Read-only guardrail (line 22, "never auto-run") is honoured by this run: nothing was executed
  on the user's behalf, only recommended.
- Line 13's frontmatter-absent fallback is real and was exercised on expense-demo's `journey.md`,
  which genuinely has no YAML block.
- The `feedback/rules.md` and `knowledge/index.md` probes work: they correctly located
  `eval/baselines/feedback-token-pilot/US-004/feedback/rules.md` and both demo knowledge indexes.
