# qaia-core

QAIA core plugin: from user story to prioritized, traceable, atomic Gherkin test books.

**Status: 0.1.0 — pre-alpha.** The journey skills exist in preview; none has shipped through an evaluated release yet (see `eval/` at the repo root).

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
| `testbook-export` | 8. `.feature` + XLSX + Markdown synthesis | medium |
| `feedback` | 9. Corrections captured, validated promotion to rules | small |
| `oracle-generate` | Standards as generation oracles (Luhn, ISO 8601, HTTP, RFC 5322…) → grounded cases + expected results, tagged `@oracle:*` | small |

\* Orders of magnitude — never promises. The journey state lives in `.qaia/` (see `skills/README.md` for the full contract): every step checkpoints to disk, so an interrupted session resumes where it left off.

## Token budget — ordre de grandeur (issue #7)

**Version 0.1.0 — daté 2026-07-24. Estimé, non instrumenté.** Ces ordres de grandeur sont
dérivés de la taille des prompts de skill et d'un nombre typique de tours sur le gold set — ils
**ne proviennent pas encore d'une instrumentation par commande**. À traiter comme un plancher
indicatif, pas comme une mesure. L'instrumentation réelle reste ouverte (issue #7).

| Commande | Ordre de grandeur (tokens, aller-retour) | Ce qui fait varier |
|---|---|---|
| `hello`, `qaia-help` | ~1–5k | lecture seule, un tour |
| `us-ingest`, `us-review`, `prioritize`, `feedback` | ~5–20k | taille de l'US, gates |
| `need-understanding`, `istqb-design`, `rag-build`, `oracle-generate` | ~20–60k | ambiguïté, nb d'AC, échanges Q&A |
| `testbook-generate` | ~40–150k+ | nb d'AC × techniques ; parallélisation sous-agents en amplifie le débit **et** le coût |
| `testbook-export`, `testbook-validate`, `report` | ~10–40k | volume du test book |

Le coût utilisateur est en **quota d'abonnement** (Q22), pas en facturation API. Télémétrie
disponible côté mainteneur : les campagnes d'évaluation consomment ~115k à 1.76M tokens (workflow
multi-agent), ce qui n'est **pas** représentatif d'une commande unique côté utilisateur.

## Portability

Skills are plain Markdown following the shared contract in `skills/README.md` — designed to work in any Claude surface with file access (decision D29). Claude Code adds comfort (sub-agent parallelization in `testbook-generate`, XLSX tooling in `testbook-export`); the skills degrade gracefully and honestly without it.
