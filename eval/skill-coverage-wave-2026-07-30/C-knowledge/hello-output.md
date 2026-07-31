# hello — smoke test: real output + freshness check of every product claim

Skill exercised: `plugins/qaia-core/skills/hello/SKILL.md`
(`disable-model-invocation: true`, `allowed-tools: Read, Glob, Bash(ls:*)` — invoked here
deliberately as a smoke test). Read-only: no file created, no URL fetched, nothing modified.

---

## Part 1 — the output, produced by following steps 1-5 literally

*(Step 1: the conversation driving this run is in French → French output.)*

> **QAIA est bien installé.** Le plugin `qaia-core` tourne — c'est cette commande qui le prouve —
> en **version 0.2.21**, telle que déclarée dans
> `plugins/qaia-core/.claude-plugin/plugin.json` (lue, jamais codée en dur).
>
> **Pas de dossier `.qaia/` dans ce projet** (`ls -d .qaia` → `No such file or directory`) : le
> projet n'a pas encore de base de connaissance QAIA, et les prochaines skills proposeront de la
> créer.
>
> **Capacités disponibles dans cette version** — 15 skills dans `qaia-core`
> (`ls plugins/qaia-core/skills/`) : `us-ingest`, `us-review`, `need-understanding`, `rag-build`,
> `istqb-design`, `oracle-generate`, `prioritize`, `testbook-generate`, `report`,
> `testbook-validate`, `testbook-export`, `feedback`, plus le méta-agent `qaia`, `qaia-help` et
> `hello`.
> État honnête (ligne « Status » du `README.md`) : **pré-alpha, en développement actif** ;
> prouvé bout-en-bout sur deux domaines réels (`examples/medibook`, `examples/expense-demo`) ;
> **la validation par de vrais pilotes humains n'a pas encore eu lieu**.
> ⚠ Cette ligne « Status » est périmée sur les chiffres — voir la partie 2 : elle annonce
> `qaia-core 0.2.14` alors que `plugin.json` dit `0.2.21`, et `qaia-playwright 0.1.6, 8 skills`
> alors que le dépôt en contient `0.1.12, 11 skills`. Feuille de route :
> https://github.com/QAIA-Project/QAIA (mentionnée, non consultée).
>
> **QAIA tourne entièrement dans votre session Claude** — aucune clé API, aucun backend — et les
> fonctions de génération consomment votre propre quota de session.

---

## Part 2 — freshness of every product claim in `hello/SKILL.md`

| Claim in SKILL.md | Repo reality | Verdict |
|---|---|---|
| plugin name `qaia-core` (line 11) | `plugins/qaia-core/.claude-plugin/plugin.json` → `"name": "qaia-core"` | **à jour** |
| version read from `plugin.json`, "never hardcode" (line 11) | `"version": "0.2.21"` — no version hardcoded in the skill | **à jour** (and this instruction is what saves the output) |
| `https://github.com/QAIA-Project/QAIA` (line 15) | identical string in `plugin.json` `homepage`/`repository` | **à jour** |
| "read this plugin's own skill directory" (line 15) | 15 skill dirs + `README.md` — count matches | **à jour** |
| "never repeat a fixed 'pre-alpha'/'preview' claim from a prior version — check what's true now" (line 15) | still literally true: `README.md` line 5 says "Status: pre-alpha, in active development" | **à jour** |

### ÉCART MINEUR — the two sources step 2 and step 4 mandate contradict each other, with no precedence rule

`SKILL.md` line 11 orders the version to come from `plugin.json`; line 15 orders the capability
list to come from *"this plugin's own skill directory and `README.md` "Status" line"*. Those two
sources disagree today, and the skill says nothing about which wins:

`README.md` line 5, verbatim:

> **Status: pre-alpha, in active development.** Core (`qaia-core` **0.2.14**, 15 skills),
> automation (`qaia-playwright` **0.1.6, 8 skills**), scoring (`qaia-score` 0.1.4, 2 skills) and
> test-data (`qaia-testdata` 0.1.0, 1 skill) plugins exist…

Measured reality (`grep -H '"version"' plugins/*/.claude-plugin/plugin.json`, `ls plugins/*/skills/`):

| Plugin | README claims | plugin.json / `ls` | Drift |
|---|---|---|---|
| qaia-core | 0.2.14, 15 skills | **0.2.21**, 15 skills | version stale by 7 patches |
| qaia-playwright | 0.1.6, **8 skills** | **0.1.12**, **11 skills** | version *and* skill count wrong |
| qaia-score | 0.1.4, 2 skills | 0.1.4, 2 skills | — |
| qaia-testdata | 0.1.0, 1 skill | 0.1.0, 1 skill | — |

(The same drift, smaller, exists in `docs/STATUS.md` lines 242-245: `qaia-core 0.2.17`,
`qaia-playwright 0.1.9`.) An agent following line 15 to the letter announces 8 automation skills
when 11 shipped — `usability-heuristic-review`, `contract-probe` and `traffic-replay` become
invisible to a user running the installation check. The skill's own anti-staleness instruction
("check what's true now") is aimed at the *pre-alpha wording*, not at the numbers, so it does not
catch this.

The README is not a skill file and is out of this run's edit scope anyway; the durable fix is in
the skill, so that it stops depending on a hand-maintained number:

**Proposed diff (NOT applied)** — `hello/SKILL.md` line 15:

```diff
-4. List the QAIA capabilities available in this version — read this plugin's own skill directory
-and `README.md` "Status" line to state honestly what has actually shipped and been proven
+4. List the QAIA capabilities available in this version — enumerate this plugin's own skill
+directory for the skill names and counts (the directory is the only authority on what shipped;
+never quote a version or a skill count from `README.md`, which is hand-maintained and drifts),
+and read `README.md`'s "Status" line **only** for the maturity statement and the proof points.
+If a version or count in that line disagrees with `plugin.json` / the directory listing, say so
+in one line rather than repeating the stale figure.
```

### Non-écart worth recording

`allowed-tools: Read, Glob, Bash(ls:*)` is sufficient for every step actually required: `Read` for
`plugin.json` and `README.md`, `Glob`/`ls` for the skill directory and the `.qaia/` check. No step
needs a tool the frontmatter withholds — the smoke test is executable as declared.
