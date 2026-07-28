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

**Version 0.2.15 — daté 2026-07-25. Intégralement instrumenté.** Les 14 skills de ce tableau
ont désormais une mesure réelle (méthode ci-dessous) — issue #7 fermée.

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
| `prioritize` | **84,7k mesuré** (US-004, 2026-07-25) | ✅ Mesuré | nb de conditions à scorer (37 ici) — au-dessus de l'ancienne estimation ~5-20k |
| `feedback` | **88,5k mesuré** (US-004, 2026-07-25) | ✅ Mesuré | nb de corrections capturées (4 ici, 2 promues en règle) — au-dessus de l'ancienne estimation ~5-20k |
| `istqb-design` | **40,1k mesuré** (US-004, 2026-07-25) | ✅ Mesuré | nb d'AC, expansion 3c — cohérent avec l'ancienne estimation |
| `rag-build` | **67,6k mesuré** (base de connaissance neuve, domaine covoiturage, 2026-07-25) | ✅ Mesuré | initialisation complète (5 fichiers) vs. ajout incrémental à une base existante, nb de règles métier — au-dessus de l'ancienne estimation ~20-60k, cohérent avec un run d'initialisation (le cas le plus coûteux du spectre) |
| `need-understanding` | **91,1k mesuré** (US-002, 2026-07-25) | ✅ Mesuré | ambiguïté, nb d'AC (8 questions sur 8 AC ici), échanges Q&A — au-dessus de l'ancienne estimation ~20-60k |
| `oracle-generate` | **67,1k mesuré** (US-004, 2026-07-25) | ✅ Mesuré | nb de domaines d'oracle détectés (2 ici : ISO 4217, ISO 8601) — au-dessus de l'ancienne estimation ~20-60k |
| `testbook-generate` | **112,5k mesuré** (US-005, 2026-07-25), plage indicative ~40–150k+ | ✅ Mesuré | nb d'AC × techniques ; parallélisation sous-agents en amplifie le débit **et** le coût |
| `testbook-export` | **77,6k mesuré** (projection du cahier US-004, 4 fichiers/38 scénarios, 2026-07-25) | ✅ Mesuré | volume du test book, nb de livrables produits (XLSX ajoute un coût réel) — au-dessus de l'ancienne estimation ~10-40k |
| `testbook-validate` | **107,1k mesuré** (US-004, 2026-07-25) | ✅ Mesuré | volume du test book audité (4 fichiers/38 scénarios) + score structurel déterministe rejoué en plus du LLM-judge — au-dessus de l'ancienne estimation ~10-40k |
| `report` | **139,7k mesuré** (US-004, 2026-07-25) | ✅ Mesuré | volume du parcours complet à consolider (7 étapes) — au-dessus de l'ancienne estimation ~10-40k |

**Constat transversal (2026-07-25)** : sur les 14 skills désormais mesurées, **13/14 dépassent
leur ancienne estimation à dire d'expert**, parfois nettement (`report` 139,7k vs ~10-40k
estimé, `need-understanding` 91,1k vs ~20-60k estimé). Seule `istqb-design` est restée dans sa
fourchette. Ce n'est pas corrigé artificiellement à la baisse — c'est le signal que les
anciennes fourchettes, jamais instrumentées, étaient systématiquement optimistes plutôt qu'un
problème propre à une skill en particulier.

Le coût utilisateur est en **quota d'abonnement** (Q22), pas en facturation API. Télémétrie
disponible côté mainteneur : les campagnes d'évaluation consomment ~115k à 1.76M tokens (workflow
multi-agent), ce qui n'est **pas** représentatif d'une commande unique côté utilisateur.

## Coût face aux paliers d'abonnement (issue #49, D108)

**Limite honnête à poser d'abord** : Anthropic ne publie plus de chiffre exact et garanti de
messages/heures par palier — confirmé en relisant directement la page d'aide officielle
(support.claude.com, 2026-07-28) : *"Both Pro and Max plans offer usage limits that are shared
across Claude and Claude Code"*, sans quantifier. Les chiffres ci-dessous sont des **estimations
tierces, non officielles**, datées et sourcées, à recouper vous-même dans votre compte avant
d'engager une équipe dessus — pas une garantie contractuelle d'Anthropic.

| Palier | Fenêtre 5h (tiers, 2026-07-28) | Cadence hebdo (tiers) |
|---|---|---|
| Pro (~20 $/mois) | ~45 prompts / 5h | pas de plage publiée, usage jugé adapté à 2-5h/semaine de Claude Code sur des tâches contenues |
| Max 5x (~100 $/mois) | ~225 prompts / 5h | ~140-280h Claude Code/semaine (tiers) |
| Max 20x (~200 $/mois) | ~900 prompts / 5h | ~240-480h Claude Code/semaine (tiers) |

**Pourquoi le budget token mesuré (tableau ci-dessus) ne se convertit pas 1:1 en "nombre de
parcours par semaine"** : le quota d'abonnement est compté en **prompts/temps de session**, pas
en tokens bruts — un appel de skill qui consomme 133k tokens en interne (agent + outils) compte
généralement comme **un seul prompt** dans la fenêtre de 5h, au même titre qu'un message court.
Le vrai facteur limitant pour une équipe n'est donc pas le volume de tokens mesuré par skill,
mais le **nombre d'invocations de skill** (≈ un prompt chacune) et le temps de session cumulé.

**Recommandation d'usage, avec cette réserve explicite** : un parcours QAIA complet (6 skills du
cœur : `us-ingest` → `us-review` → `need-understanding` → `istqb-design` → `testbook-generate`
→ `report`) consomme de l'ordre de **6 à 12 prompts** (une skill peut se relancer une fois en cas
d'arbitrage humain) — largement sous la fenêtre 5h même du palier Pro (~45 prompts). Le facteur
limitant réel pour un usage équipe (plusieurs développeurs, plusieurs US par semaine) est le
**temps de session cumulé**, pas le compte de prompts isolé — une équipe de 3-5 développeurs
lançant 1-2 parcours complets par jour reste dans l'ordre de grandeur d'un usage individuel
"contenu" par personne, cohérent avec le palier Pro déjà cité comme suffisant pour ce profil par
les sources tierces ci-dessus ; un usage plus intensif (plusieurs US en parallèle, régénérations
fréquentes, skills optionnelles ajoutées comme `oracle-generate`/`testbook-validate`) pousse vers
Max 5x. **Aucun de ces deux profils ne nécessite Max 20x** sur la seule base de ce que QAIA
consomme — ce palier resterait pertinent pour un usage Claude Code plus large que QAIA seul
(développement général en parallèle).

**Non fait, honnêtement** : aucune équipe pilote réelle n'a encore rapporté sa consommation de
quota sur plusieurs semaines (mur humain, #1) — cette section reste une **projection à partir
du budget token mesuré**, pas une mesure de quota réel épuisé, à corriger dès qu'un retour pilote
existe.

## Portability

Skills are plain Markdown following the shared contract in `skills/README.md` — designed to work in any Claude surface with file access (decision D29). Claude Code adds comfort (sub-agent parallelization in `testbook-generate`, XLSX tooling in `testbook-export`); the skills degrade gracefully and honestly without it.
