# hello — actual output of the smoke test

Skill: `plugins/qaia-core/skills/hello/SKILL.md` (read-only; nothing was created or modified,
no URL fetched). Run: 2026-07-30.

---

## The output the skill produces (steps 1-5, executed literally)

**1. Language.** Conversation is in French → the real run would answer in French. Reproduced in
English here because this file is the evaluation evidence, not the user-facing reply.

**2. `qaia-core` is installed — version `0.2.21`.**
Read from `plugins/qaia-core/.claude-plugin/plugin.json` line 3, not hardcoded:
```
"name": "qaia-core",
"version": "0.2.21",
```

**3. `.qaia/` in the current project: absent.**
```
$ ls -d .qaia
ls: cannot access '.qaia': No such file or directory
```
→ one sentence, per the skill: this project has no QAIA knowledge base yet; future skills will
offer to create it.

**4. Capabilities available in this version.**
From `plugins/qaia-core/skills/` (read directly, 15 skill directories):
`feedback, hello, istqb-design, need-understanding, oracle-generate, prioritize, qaia, qaia-help,
rag-build, report, testbook-export, testbook-generate, testbook-validate, us-ingest, us-review`.

From the `README.md` "Status" line — **and this is where the skill's own instruction produces a
wrong answer**, see the defect section: the root `README.md` states *"pre-alpha … `qaia-core`
0.2.14, 15 skills … `qaia-playwright` 0.1.6, 8 skills … `qaia-score` 0.1.4, 2 skills …
`qaia-testdata` 0.1.0, 1 skill"*, and `plugins/qaia-core/README.md` line 5 states
*"**Status: 0.2.14.**"* — both stale.

Roadmap: https://github.com/QAIA-Project/QAIA (mentioned, not fetched).

**5.** QAIA runs entirely inside the user's Claude session — no API key, no backend — and
generation features consume their own session quota.

---

## Claim-by-claim recheck against the repository (the point of this smoke test)

| Claim | Source of the claim | Repository reality | Verdict |
|---|---|---|---|
| version `0.2.21` | `plugin.json` (skill step 2) | `plugin.json` line 3 = `0.2.21` | **correct** |
| `qaia-core` = 15 skills | root `README.md` Status line | `find plugins/qaia-core -name SKILL.md \| wc -l` = **15** | correct |
| `qaia-core` version `0.2.14` | root `README.md` + `plugins/qaia-core/README.md` L5 | `plugin.json` = **0.2.21** | **STALE** |
| `qaia-playwright` `0.1.6`, **8 skills** | root `README.md` Status line | `plugin.json` = **0.1.12**; SKILL.md count = **11** | **STALE ×2** |
| `qaia-score` `0.1.4`, 2 skills | root `README.md` Status line | `plugin.json` = 0.1.4; 2 SKILL.md | correct |
| `qaia-testdata` `0.1.0`, 1 skill | root `README.md` Status line | `plugin.json` = 0.1.0; 1 SKILL.md | correct |
| "Les 14 skills de ce tableau" | `plugins/qaia-core/README.md` L39 | table has **13** rows; disk has **15** (`report` and `qaia` are in neither the table nor the count) | **STALE** |
| roadmap URL `https://github.com/QAIA-Project/QAIA` | `hello` SKILL.md L15 | identical to `homepage`/`repository` in all 4 `plugin.json` and all 4 `marketplace.json` entries | **correct** |
| plugin name `qaia-core`, marketplace `qaia` (`/plugin install qaia-core@qaia`) | root `README.md` install block | `.claude-plugin/marketplace.json` `"name": "qaia"`, plugin `"name": "qaia-core"` | **correct** |
| "no API key, no backend" | `hello` SKILL.md L16 | no network/credential path in `plugins/`; the only networked component, `mcp-bridge/`, is outside `plugins/` and never auto-installed (D116) | **correct** |

Repository-wide inventory used as the reference, actually counted:
```
$ find plugins -name SKILL.md | wc -l
29
```
qaia-core 15 + qaia-playwright 11 + qaia-score 2 + qaia-testdata 1 = 29, matching D116's
"lecture seule des 29 `SKILL.md`".

---

## Verdict

`hello` executes cleanly and its own two hard facts — the version read from `plugin.json`, and
the `.qaia/` presence check — are **correct**. Its step 4, however, instructs the agent to source
the capability statement from a `README.md` "Status" line that is measurably out of date, and the
skill's own anti-drift clause ("never repeat a fixed 'pre-alpha'/'preview' claim from a prior
version — check what's true now") points the agent at the exact artifact that carries the stale
claim. Details and a proposed diff are in the wave report; **no file was modified by this run.**
