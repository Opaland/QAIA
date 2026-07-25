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
| `testbook-export` | 8. `.feature` + XLSX + Markdown synthesis; opt-in Xray CSV export (git-master, file-only — issue #35) | medium |
| `feedback` | 9. Corrections captured, validated promotion to rules | small |
| `oracle-generate` | Standards as generation oracles (Luhn, ISO 8601, HTTP, RFC 5322…) → grounded cases + expected results, tagged `@oracle:*` | small |

\* Orders of magnitude — never promises. The journey state lives in `.qaia/` (see `skills/README.md` for the full contract): every step checkpoints to disk, so an interrupted session resumes where it left off.

## Token budget — ordre de grandeur (issue #7)

**Version 0.2.14 — daté 2026-07-25. Partiellement instrumenté.** 5 skills ont une mesure
réelle (méthode ci-dessous) ; le reste demeure estimé (marqué explicitement) — instrumenter
les skills restantes reste ouvert (issue #7, portée réduite au solde non mesuré).

**Méthode de mesure** : chaque skill mesuré a été appliqué fidèlement, du début à la fin, par
un agent dédié sur une US du gold set (pas de raccourci) ; le chiffre rapporté est le total de
tokens réellement consommé par cet agent pour la tâche complète (input+output, tel que rapporté
par l'infrastructure d'orchestration — pas une auto-déclaration de l'agent lui-même, qui n'a
aucun accès fiable à son propre compteur, une limite découverte en tentant de le lui demander
directement). Un seul run par skill mesurée — pas encore de moyenne/variance.

| Commande | Ordre de grandeur (tokens, aller-retour) | Mesuré ? | Ce qui fait varier |
|---|---|---|---|
| `hello`, `qaia-help` | ~1–5k | Estimé | lecture seule, un tour |
| `us-ingest` | **44,9k mesuré** (US-002, 2026-07-25) | ✅ Mesuré | taille de l'US, gates — **la mesure réelle dépasse nettement l'ancienne estimation (~5-20k) : rapporté honnêtement, pas lissé** |
| `us-review`, `prioritize`, `feedback` | ~5–20k | Estimé | taille de l'US, gates |
| `istqb-design` | **40,1k mesuré** (US-004, 2026-07-25) | ✅ Mesuré | nb d'AC, expansion 3c — cohérent avec l'ancienne estimation |
| `rag-build` | **67,6k mesuré** (base de connaissance neuve, domaine covoiturage, 2026-07-25) | ✅ Mesuré | initialisation complète (5 fichiers) vs. ajout incrémental à une base existante, nb de règles métier — au-dessus de l'ancienne estimation ~20-60k, cohérent avec un run d'initialisation (le cas le plus coûteux du spectre) |
| `need-understanding`, `oracle-generate` | ~20–60k | Estimé | ambiguïté, nb d'AC, échanges Q&A |
| `testbook-generate` | **112,5k mesuré** (US-005, 2026-07-25), plage indicative ~40–150k+ | ✅ Mesuré | nb d'AC × techniques ; parallélisation sous-agents en amplifie le débit **et** le coût |
| `testbook-export` | **77,6k mesuré** (projection du cahier US-004, 4 fichiers/38 scénarios, 2026-07-25) | ✅ Mesuré | volume du test book, nb de livrables produits (XLSX ajoute un coût réel) — au-dessus de l'ancienne estimation ~10-40k |
| `testbook-validate`, `report` | ~10–40k | Estimé | volume du test book |

Le coût utilisateur est en **quota d'abonnement** (Q22), pas en facturation API. Télémétrie
disponible côté mainteneur : les campagnes d'évaluation consomment ~115k à 1.76M tokens (workflow
multi-agent), ce qui n'est **pas** représentatif d'une commande unique côté utilisateur.

## Portability

Skills are plain Markdown following the shared contract in `skills/README.md` — designed to work in any Claude surface with file access (decision D29). Claude Code adds comfort (sub-agent parallelization in `testbook-generate`, XLSX tooling in `testbook-export`); the skills degrade gracefully and honestly without it.
