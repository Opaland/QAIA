# qaia-core

QAIA core plugin: from user story to prioritized, traceable, atomic Gherkin test books.

**Status: 0.2.14.** Proven end-to-end on two independent domains (medical — `examples/medibook/` — and non-medical — `examples/expense-demo/`), plus a 24-case multi-model robustness corpus (`eval/baselines/corpus-24-depth.md`). See `eval/` at the repo root for the full evaluation trail.

## Install

From Claude Code:

```
/plugin marketplace add Opaland/QAIA
/plugin install qaia-core@qaia
/reload-plugins
```

## Skills

| Skill | Journey step | Indicative token budget* |
|---|---|---|
| `/qaia-core:hello` | Installation check (read-only) | minimal (< 1k) |
| `qaia-help` | "What now?" — journey status per US + recommended next step (read-only) | small |
| `testbook-validate` | Audit any Gherkin test book (even non-QAIA) → scored report + PASS/CONCERNS/FAIL gate | medium |
| `us-ingest` | 1. Capture and validate the source | small |
| `us-review` | 2. Extraction check, AC numbering | small |
| `need-understanding` | 3. Ambiguity hunt, Q&A, assumptions | medium |
| `rag-build` | 4. Team knowledge base (index + focused files) | small |
| `istqb-design` | 5. Techniques chosen and justified per AC | medium |
| `prioritize` | 6. Risk scores proposed, human arbitrated | small |
| `testbook-generate` | 7. Atomic Gherkin book, stable IDs, matrix, ratio check; diff-based regeneration | large |
| `testbook-export` | 8. `.feature` + XLSX + Markdown synthesis; opt-in Xray or TestRail CSV export (git-master, file-only — issue #35) | medium |
| `feedback` | 9. Corrections captured, validated promotion to rules | small |
| `oracle-generate` | Standards as generation oracles (Luhn, ISO 8601, HTTP, RFC 5322…) → grounded cases + expected results, tagged `@oracle:*` | small |

\* Orders of magnitude — never promises. The journey state lives in `.qaia/` (see `skills/README.md` for the full contract): every step checkpoints to disk, so an interrupted session resumes where it left off.

## Token budget — ordre de grandeur (issue #7)

**Version 0.2.15 — daté 2026-07-25. Partiellement instrumenté.** 10 skills ont une mesure
réelle (méthode ci-dessous) ; 4 restent estimées (marquées explicitement) — instrumenter les
skills restantes reste ouvert (issue #7, portée réduite au solde non mesuré : `prioritize`,
`testbook-validate`, `report`, `feedback`).

**Méthode de mesure** : chaque skill mesurée a été appliquée fidèlement, du début à la fin, par
un agent dédié sur une US du gold set (pas de raccourci) ; le chiffre rapporté est le total de
tokens réellement consommé par cet agent pour la tâche complète (input+output, tel que rapporté
par l'infrastructure d'orchestration — pas une auto-déclaration de l'agent lui-même, qui n'a
aucun accès fiable à son propre compteur, confirmé activement à plusieurs reprises cette
session : aucune variable d'environnement ni aucun outil accessible à l'agent délégué
n'expose son propre total). Chiffre lu au niveau orchestrateur, un cran au-dessus de l'agent
délégué, où il est bien exposé (confirmation méthodologique nouvelle cette session, D91). Un
seul run par skill mesurée — pas encore de moyenne/variance.

| Commande | Ordre de grandeur (tokens, aller-retour) | Mesuré ? | Ce qui fait varier |
|---|---|---|---|
| `hello` | **39,1k mesuré** (2026-07-25) | ✅ Mesuré | lecture seule, un tour — au-dessus de l'ancienne estimation ~1-5k |
| `qaia-help` | **56,3k mesuré** (fixture US-004, 2026-07-25) | ✅ Mesuré | lecture seule, un tour, mais lit un état de parcours complet (7 étapes) — au-dessus de l'ancienne estimation ~1-5k |
| `us-ingest` | **44,9k mesuré** (US-002, 2026-07-25) | ✅ Mesuré | taille de l'US, gates — **la mesure réelle dépasse nettement l'ancienne estimation (~5-20k) : rapporté honnêtement, pas lissé** |
| `us-review` | **73,8k mesuré** (US-002, 2026-07-25) | ✅ Mesuré | taille de l'US, gates — au-dessus de l'ancienne estimation ~5-20k |
| `prioritize`, `feedback` | ~5–20k | Estimé | taille de l'US, gates |
| `istqb-design` | **40,1k mesuré** (US-004, 2026-07-25) | ✅ Mesuré | nb d'AC, expansion 3c — cohérent avec l'ancienne estimation |
| `rag-build` | **67,6k mesuré** (base de connaissance neuve, domaine covoiturage, 2026-07-25) | ✅ Mesuré | initialisation complète (5 fichiers) vs. ajout incrémental à une base existante, nb de règles métier — au-dessus de l'ancienne estimation ~20-60k, cohérent avec un run d'initialisation (le cas le plus coûteux du spectre) |
| `need-understanding` | **91,1k mesuré** (US-002, 2026-07-25) | ✅ Mesuré | ambiguïté, nb d'AC (8 questions sur 8 AC ici), échanges Q&A — au-dessus de l'ancienne estimation ~20-60k |
| `oracle-generate` | **67,1k mesuré** (US-004, 2026-07-25) | ✅ Mesuré | nb de domaines d'oracle détectés (2 ici : ISO 4217, ISO 8601) — au-dessus de l'ancienne estimation ~20-60k |
| `testbook-generate` | **112,5k mesuré** (US-005, 2026-07-25), plage indicative ~40–150k+ | ✅ Mesuré | nb d'AC × techniques ; parallélisation sous-agents en amplifie le débit **et** le coût |
| `testbook-export` | **77,6k mesuré** (projection du cahier US-004, 4 fichiers/38 scénarios, 2026-07-25) | ✅ Mesuré | volume du test book, nb de livrables produits (XLSX ajoute un coût réel) — au-dessus de l'ancienne estimation ~10-40k |
| `testbook-validate`, `report` | ~10–40k | Estimé | volume du test book |

**Constat transversal (2026-07-25)** : sur les 10 skills désormais mesurées, **9/10 dépassent
leur ancienne estimation à dire d'expert**, parfois nettement (`need-understanding` 91,1k vs
~20-60k estimé). Seule `istqb-design` est restée dans sa fourchette. Ce n'est pas corrigé
artificiellement à la baisse — c'est le signal que les anciennes fourchettes, jamais
instrumentées, étaient systématiquement optimistes plutôt qu'un problème propre à une skill en
particulier.

Le coût utilisateur est en **quota d'abonnement** (Q22), pas en facturation API. Télémétrie
disponible côté mainteneur : les campagnes d'évaluation consomment ~115k à 1.76M tokens (workflow
multi-agent), ce qui n'est **pas** représentatif d'une commande unique côté utilisateur.

## Portability

Skills are plain Markdown following the shared contract in `skills/README.md` — designed to work in any Claude surface with file access (decision D29). Claude Code adds comfort (sub-agent parallelization in `testbook-generate`, XLSX tooling in `testbook-export`); the skills degrade gracefully and honestly without it.
