# Kanban & Sprints — QAIA (v3, groomé)

Board GitHub Projects (à monter — action propriétaire M0-CHECKLIST #5). Colonnes : **Backlog** → **À challenger** → **Prêt** → **En cours** (WIP max 2 chantiers humains ; les agents parallélisent en dessous) → **En revue/validation** → **Terminé**. Processus de challenge inchangé : valeur / effort / leçon fondatrice / critère d'acceptation.

Le développement se déroule en **sprints courts** exécutés en sessions agentiques ; chaque sprint se termine par : harnais d'éval vert, revues (adversariale + cohérence) passées, Kanban re-groomé.

---

## Sprint 10 — Harnais de gap #24 sur matériel réel (accès web) ✅ TERMINÉ (2026-07-24 ter)

Demande fondateur : utiliser l'accès web confirmé cette session pour sourcer un vrai gold set
dur (pas des fixtures fabriquées) et attaquer le #24 jusqu'au bout.

| Livré | Preuve |
|---|---|
| 2 cas durs réels sourcés sur le web (GitLab CE `groups.feature` sans narratif US ; Sharetribe champs custom pilotés par config admin) | `eval/goldset-hardened/real-cases-24.md` |
| 4 runs isolés (3× sur le cas Groups pour la variance, 1× sur le cas config) mesurant les 4 modes d'échec IATS | `eval/baselines/gap-harness-24.md` |
| **2 défauts trouvés et corrigés** dans `istqb-design` (silence sur les entités-sœurs non nommées ; fabrication convergente non flaggée d'une sémantique de suppression) | `plugins/qaia-core/skills/istqb-design/SKILL.md` 3c, D44 |
| **Pass structurel déterministe branché sur `testbook-validate`** (comme demandé), aligné sur `testbook-score` | `plugins/qaia-core/skills/testbook-validate/SKILL.md`, D45 |
| **Détecteur de redondance (pesticide paradox)** ajouté à `structural_score.py`, validé sur fixture + contenu réel | `eval/tools/structural_score.py`, `eval/baselines/structural-score.md`, D46 |
| **Faux positif trouvé et corrigé dans le scoreur lui-même** (`HOLLOW_RE` sur du contenu réel généré) | `eval/baselines/structural-score.md` |
| `qaia-core` 0.2.6 → 0.2.7, `--strict` vert | validation `claude plugin validate --strict` |

**Reste (marqué honnêtement, non fait cette session)** : re-mesurer les 50 US de
`groundtruth-corpus.md` avec les 2 amendements `istqb-design` pour confirmer l'absence de
régression à grande échelle — le changement est petit et ciblé, mais seul le harnais complet
peut le confirmer. Prochain palier : **#25** (durcir l'oracle OpenAPI).

## Sprint 11 — Durcissement oracle OpenAPI (#25) ✅ TERMINÉ (2026-07-24 ter)

Enchaînement autonome après le Sprint 10 : prochain palier de plus haute valeur du backlog.

| Livré | Preuve |
|---|---|
| Résolution `$ref` interne rendue obligatoire (step 0.1) — un noeud non résolu perdait tous les négatifs de champ requis en silence | `oracles/openapi.md` |
| Avertissement « spec sous-documentée » (step 0.3) : 0 erreur 4xx/5xx documentée sur tout le spec, OU mutations sans auth déclarée | `oracles/openapi.md`, `SKILL.md` |
| Règle **re-vérifiée en re-fetchant les 3 vraies specs** (Petstore/apis.guru/Notion) — la première mouture aurait manqué apis.guru, corrigée avant livraison | `eval/baselines/connectors-real-data.md` |
| `qaia-core` 0.2.7 → 0.2.8, `--strict` vert | validation `claude plugin validate --strict` |

Décision D47.

## Sprint 12 — Contrôle de non-régression échantillonné des amendements #24 ✅ TERMINÉ (2026-07-24 ter)

Enchaînement autonome : au lieu du re-run complet des 50 US (disproportionné), 2 cas réels
neufs (jamais vus par les runs d'origine) soumis en tickets durs pour vérifier que les 2
amendements `istqb-design` généralisent.

| Livré | Preuve |
|---|---|
| Cas Dashboard (GitLab CE) : gap des entités-sœurs explicitement flagué, pas silencieux | `eval/baselines/istqb-amendments-regression-24.md` |
| Cas 2FA (Diaspora) : `@low-confidence` correctement posé sur désactivation + régénération codes | `eval/baselines/istqb-amendments-regression-24.md` |
| Aucune régression détectée sur les 2 cas | idem, décision D48 |

**Limite assumée** : pas équivalent au re-run complet des 50 US (pas de mesure de
rappel/précision agrégée) — signal de généralisation, pas clôture définitive du risque.

## Sprint 13 — Nouvelles sources (PRD réel, API publique réelle) + durcissement scoreur ✅ TERMINÉ (2026-07-24 ter, suite 3)

Demande fondateur : tester plusieurs types de sources (PRD, US, sites/APIs de pratique QA)
et vérifier la couverture du pass déterministe (tags, ratio).

| Livré | Preuve |
|---|---|
| Gate de décomposition testé sur un PRD réel-forme (TaskFlow, clean-room) : 19 stories listées, NFR séparées, 2 ambiguïtés flaggées | `eval/baselines/new-sources-25bis.md` |
| Risque de fabrication testé sur une vraie API publique en prose (Airport Gap, sans fichier spec) — zéro fabrication, y compris contre la tentation de rappel de connaissance d'entraînement | idem, vérité-terrain `curl` en direct |
| Audit déterministe des tags priorité/technique + **ratio négatif recalculé indépendamment** (fermait un trou de la règle 3) | `eval/tools/structural_score.py`, `eval/baselines/structural-score.md`, fixture `tag-conformant.feature` |

Décision D50. Aucun défaut produit trouvé (confirmations positives) ; le durcissement
scoreur corrige un vrai trou. Catalogue de sites/APIs de pratique QA reçu, pas encore
exploité pour `qaia-playwright:automate` contre une cible publique réelle.

## Sprint 14 — Prompt management sur les 23 skills + second juge indépendant ✅ TERMINÉ (2026-07-24 ter, suite 6)

Demande fondateur : auditer précision/format/exemples des skills produits, et évaluer
shadow/A-B testing comme méthode de vérification des changements de formulation.

| Livré | Preuve |
|---|---|
| Audit des 23 skills (précision/format/exemples) — 1 bug de numérotation trouvé et corrigé (`need-understanding`, deux étapes "4.") | `plugins/qaia-core/skills/need-understanding/SKILL.md`, `qaia-core` 0.2.9 |
| Second juge LLM indépendant (`eval/tools/second_judge.py`), repli gratuit Gemini→Groq→HF, HTTP direct sans SDK (ni LiteLLM ni API Anthropic) | `eval/baselines/second-judge.md`, D51 |
| Vérifié en live sur les 3 fournisseurs — 2 défauts de plomberie trouvés en l'exécutant (403 User-Agent HF, format de réponse Gemini mal documenté par une source web) ; accord tri-source avec le juge Claude et le scoreur déterministe sur le défaut C1 | idem |
| Premier test A/B contrôlé sur un skill (`prioritize`, avec/sans exemple chiffré) | `eval/baselines/prioritize-ab-test.md`, D52 |
| Résultat A/B **négatif et honnête** : l'exemple aurait sur-généralisé et dégradé la calibration — pas appliqué | idem |
| `.gitignore` racine créé (n'existait pas), `.env`/`.env.example` pour les secrets d'outillage mainteneur | — |

Décisions D51-D52. Prochain candidat si le prompt management continue : `qaia` (méta-agent
ReAct, le skill le plus vague du corpus).

## Sprint 15 — Balayage multi-modèles complet, Phase 1 (9/9 skills du cœur) ✅ TERMINÉ (2026-07-24 ter, suite 10)

Demande fondateur : étendre le harnais de gap à tous les skills, vérifier systématiquement
sur 4+ modèles gratuits, domaines variés (pas seulement médical).

| Livré | Preuve |
|---|---|
| 5 fournisseurs opérationnels (Claude + Gemini/Groq/HF/Mistral ; Cerebras ajouté mais bloqué côté compte, 402) | `eval/tools/second_judge.py`, `eval/baselines/second-judge.md` |
| 9 skills du cœur testés sur du matériel dur, domaines variés (santé, e-commerce, logistique, SaaS, ingénierie) | `eval/baselines/multimodel-skill-sweep.md` |
| 3 sans-faute collectifs sur tâches mécaniques (rag-build, testbook-export, feedback) | idem |
| 3 défauts réels trouvés, sans classement stable entre modèles (Groq/raisonnement, Mistral/traçabilité, HF/3 défauts distincts dont fuite PII) | idem, décision D55 |
| Claude sans défaut sur les 9 cas, hygiène épistémique démontrée 2 fois (oracle-generate) | idem |

Décision D55. Phase 2 (qaia-playwright, qaia-score) en attente de priorisation.

## Sprint 17 — Corpus élargi 24 cas, profondeur statistique ✅ TERMINÉ (2026-07-24 ter suite 13 → 2026-07-25)

Suite à D55-D57 (balayage en largeur, N=1/skill) : demande fondateur de creuser en profondeur
sur du matériel neuf pour voir si les patterns tiennent à N=20+. Plan complet (24 cas, 4 réels
GitLab CE + 20 clean-room par format/domaine) : `eval/goldset-hardened/corpus-24-plan.md`.

| Livré | Preuve |
|---|---|
| Lot 1/6 : 4 cas réels GitLab CE v8.16.9 (jamais utilisés cette session), Claude + Groq + Hugging Face + Mistral (Gemini rate-limité après R1) | `eval/baselines/corpus-24-depth.md` |
| **2 nouveaux défauts** : HF fabrique des codes HTTP précis (201/404/409) non demandés (4e défaut distinct chez HF cette session) ; Mistral invente une exception "propriétaire" non fondée | idem, décision D58 |
| Signal plus léger confirmé (dédup tautologique Groq/Mistral, R1) ; sans-faute total sur le piège précondition SSH (R3, 5/5 modèles) | idem |
| Lot 2/6 : 4 cas clean-room (fintech/PRD/spec/Jira-ticket), exécutés via 4 agents indépendants en parallèle, Claude + Gemini + Groq + Hugging Face + Mistral (Gemini dispo cette fois) | `eval/baselines/corpus-24-depth.md` |
| **2 défauts HF supplémentaires** (5e/6e cette session : contradiction résolue en silence, fabrication matrice/seuils config-driven) ; **Groq et Mistral confirment leurs profils** sur matériel neuf (raisonnement multi-règles ; invention non fondée, 3/8 cas) | idem, décision D59 |
| **Nuance nouvelle** : fuite PII possible dans la narration du modèle, pas seulement l'artefact (Mistral/Groq, C2) ; **confirmation transversale** : ratio négatif auto-rapporté peu fiable (valide D50) | idem |
| Claude et Gemini : 8/8 cas cumulés sans défaut | idem |

| Lot 3/6 : 4 cas clean-room (gaming/IoT/HR-tech/voyage), 4 agents parallèles | `eval/baselines/corpus-24-depth.md` |
| **Gemini : 1er défaut sur ce corpus** (fabrication codes HTTP, C7) ; **Hugging Face : 3 cas propres consécutifs** (C6-C8) après 6 défauts sur 8 cas ; Groq/Mistral confirment leurs profils | idem, décision D60 |
| **Gap outillage trouvé** : `structural_score.py` (`VAGUE_RE`) rate un `Then` vague ciblé (C5) — non corrigé cette session, noté en suite du #24/D46 | idem |

| Lot 4/6 : 4 cas clean-room (immobilier/média/fintech-KYC/logistique), 4 agents parallèles | `eval/baselines/corpus-24-depth.md` |
| **Sans-faute sur les défauts de pure détection** (CRUD-inverse, contradiction) ; **2e gap outillage trouvé** (`HOLLOW_RE` rate un renvoi paraphrasé au mockup, C10) ; Hugging Face indisponible 3/4 cas (402, crédit épuisé — pas un défaut qualité) | idem, décision D61 |

| Lot 5/6 : 4 cas clean-room (santé/edtech/gaming/IoT), 4 agents parallèles | `eval/baselines/corpus-24-depth.md` |
| **Mistral échoue net sur C14** (fabrication grave + auto-contradiction) ; **Groq échoue net sur C15** (rate le cas, erreur logique sur son propre ratio) ; **Gemini confirme un ratio D20 fiable** (3/4 cas exacts) ; 5e sans-faute consécutif sur CRUD-inverse (C16) | idem, décision D62 |
| Hugging Face indisponible sur les 4 cas (402, 7-10e échec consécutif — crédit épuisé) | idem |

| Lot 6/6 (DERNIER) : 4 cas clean-room (HR-tech/voyage/immobilier/média), 4 agents parallèles | `eval/baselines/corpus-24-depth.md` |
| **Mistral échoue net une 2e fois sur PII** (C17, ledger complet 4 catégories) ; **3e gap outillage aggravé** (`VAGUE_RE`, C18) ; **auto-contradiction synthèse/artefact chez Mistral** (C19) ; 3e cas consécutif sans-faute sur traçabilité (C20) | idem, décision D63 |
| **Bilan global 24/24 cas** : Claude 0 défaut ; Gemini le plus fiable des externes (0 échec de détection, ratio D20 exact) ; Groq/Mistral ~25-33% d'échec sur raisonnement profond ; HF 6 défauts denses sur 13/24 cas mesurés puis indisponible ; 2 défauts transversaux confirmés (ratio D20, gaps regex) ; CRUD-inverse/traçabilité généralisent fortement | idem, décision D64 |

**Corpus élargi 24 cas TERMINÉ.**

## Sprint 18 — Correctif `VAGUE_RE`/`HOLLOW_RE` ✅ TERMINÉ (2026-07-25)

| Livré | Preuve |
|---|---|
| `VAGUE_RE`/`HOLLOW_RE` étendus pour capter les 2 formulations paraphrasées trouvées par le corpus (C5-Mistral, C18-Groq) | `eval/tools/structural_score.py`, décision D65 |
| Vérifié sans régression : 7 fixtures existantes identiques (diff vide), seuls les 2 cas ciblés basculent sur 15 fichiers réels du corpus | `eval/baselines/structural-score.md` |
| Nouvelle fixture de régression (2 cas FAIL attendus + 1 cas concret + 1 cas config-driven légitime qui ne doit jamais être flagué) | `eval/goldset-hardened/paraphrased-vague.feature` |
| 3e cas documenté (C10) réexaminé : pas un vrai bug, le scénario est racheté par des lignes `And` concrètes — noté honnêtement, pas compté comme corrigé | idem |

**Reste (backlog, non fait)** : retenter Hugging Face sur C10-C20 (11 cas jamais mesurés pour
ce fournisseur) si le crédit gratuit se reconstitue ; limite résiduelle `ASSERT_RE` trop
permissif sur les guillemets (D65) à reprendre si un futur cas la reproduit.

## Sprint 16 — Balayage multi-modèles Phases 2 & 3 (8/8, qaia-playwright + qaia-score) ✅ TERMINÉ (2026-07-24 ter, suite 11)

Suite du Sprint 15 : demande fondateur d'aller au bout des 23 skills.

| Livré | Preuve |
|---|---|
| 8 skills testés (automate, perf-check, a11y-audit, run-report, security-surface, visual-check, testbook-score, aptitude-gate) sur 4-5 modèles | `eval/baselines/multimodel-skill-sweep.md` |
| **0 défaut trouvé** — contraste net avec la Phase 1 (3 défauts/9 skills) | idem, décision D56 |
| 17/23 skills couverts au total ; `hello`/`qaia-help` (triviaux) non testés | idem |

Décision D56. **Complété dans la foulée** (`hello`, `qaia-help`) : 23/23 skills couverts,
sans-faute total y compris sur un test de sécurité (injection via nom de fichier). Décision
D57 — balayage multi-modèles clos pour ce cycle.

## Sprint 9 — Sortie unifiée, plugin de score & 4 leviers skill-level ✅ TERMINÉ (2026-07-23)

Demande fondateur : enchaîner les 4 leviers + standardiser la sortie + un plugin de score seul.

| Livré | Preuve |
|---|---|
| **Contrat de sortie standardisé (D39)** : manifeste JSON unique par US, tous plugins au même format | `docs/OUTPUT-CONTRACT.md`, skill `qaia-core:report`, `run-report` fusionne `execution` |
| **Plugin `qaia-score` (D40)** : `testbook-score` (rubrique /20) + `aptitude-gate` (PASS/CONCERNS/FAIL/WAIVED), lecture seule, n'écrit que `gate` | `plugins/qaia-score/`, `examples/scoring-demo/`, `--strict` vert |
| **RAG en usage réel** : protocole récupération/citation + `istqb-design` 3d dérive des conditions citées des règles (casse le plafond D38) | `skills/README.md`, `examples/rag-demo/` (+5 conditions non inférables) |
| **Oracle v2 OpenAPI (D36b, #16)** : parsing du contrat désigné → statuts/champs requis/contraintes/format-chaining, borné | `oracles/openapi.md`, `examples/oracle-demo/*.openapi.yaml` (lint vert) |
| **Connecteur Jira (D9, #9)** : portable-first (export REST v3/CSV/collé) + live MCP borné, PII masquée, injection reportée | `connectors/jira.md`, `examples/jira-demo/` |
| **M3 `automate` durci (D41, #10)** : scaffold + templates CI (GitHub/GitLab/Jenkins) + handoff manifeste + gate T17 honnête | `automate/templates/`, exit-criterion T17 documenté |
| Versions : qaia-core 0.2.2→0.2.6, qaia-playwright 0.1.0→0.1.1, qaia-score 0.1.0 ; marketplace 3 plugins | `--strict` vert sur les 3 + marketplace |

**Reste à mesurer (non skill-level)** : gain de rappel RAG chiffré au harnais, verdict `qaia-score` vs humain sur baselines, M3/T17 sur app pilote — cf. « Prochains leviers » de `STATUS.md`. Le mur humain (5 pilotes, #1) est inchangé.

---

## Sprint 1 — Fondations & première baseline ✅ TERMINÉ (2026-07-23)

| Livré | Preuve |
|---|---|
| Discovery v2 (4 personas), 88 questions, 33 décisions + 17 défauts | `DISCOVERY.md`, `DECISIONS.md` |
| Gates G1 (purge + squash) et G3 (3 contradictions tranchées) | D1, D5, D6, D17 |
| M0 côté repo : licence, README bilingue, gouvernance, marketplace validée (`--strict`), CI durcie (supply-chain, DCO, gherkin-lint épinglé + config), harnais d'éval AVANT les skills | `M0-CHECKLIST.md` |
| 12 skills (parcours complet + hello, qaia-help, testbook-validate, agent `qaia`) | `plugins/qaia-core/skills/` |
| 3 revues (conformité, sécurité, cohérence) : 40 findings corrigés | commits `585b804`, `ba0f38d` |
| Étude BMAD : 12 patterns adoptés (D33), A1/A7 implémentés | `BMAD-ANALYSIS.md` |
| **Baseline 0.1.0 : 17/20 PASS** (3 runs × 3 juges, lint vert) | `eval/baselines/0.1.0-US-001.md` |

## Sprint 2 — Régression 0.1.1 & agent ReAct ✅ TERMINÉ (baseline 19/20, +2 ; dims 6 et 9 récupérées ; skills qaia-help/testbook-validate testées et corrigées)

## Sprint 9 — Industrialisation & sortie standardisée ✅ TERMINÉ
Contrat de sortie unifié (manifeste JSON par US, `docs/OUTPUT-CONTRACT.md`, D39) écrit au même format par tous les plugins. Nouveau plugin **`qaia-score` 0.1.0** (D40) : score /20 + gate PASS/CONCERNS/FAIL/WAIVED, lecture seule — aucun producteur ne s'auto-score. RAG en usage réel (récupération/citation, `examples/rag-demo/`). Oracle projet **OpenAPI** (#16b, `examples/oracle-demo/`). Connecteur **Jira** (#9 fermé, `examples/jira-demo/`). Durcissement M3 `automate` (#10 : scaffold + templates CI GitHub/GitLab/Jenkins + gate T17 honnête). Rituel `/session-review` (`.claude/commands/`). Issues fermées : #9, #11. **Mesure en cours** : calibration `qaia-score` (#17). Restant = **mesurer en réel** (RAG au harnais, M3/T17 sur app pilote) — majoritairement mur humain (#1).

## Sprint 8 — Éval vérité-terrain (oracle humain) ✅ TERMINÉ
50 paires réelles (US + tests d'acceptation humains validés : gitlab/diaspora/sharetribe). QAIA reçoit l'US seule, on compare au test humain. Protocole train/held-out anti-overfitting. Résultat (skills 0.1.9→0.2.2, `groundtruth-training.md`) : **généralisation prouvée** (held-out 53 % ≥ train 33 %, pas d'overfitting), **précision ~93 %**, **+200 scénarios valides** au-delà des humains, plafond structurel honnête (config-driven → RAG). Heuristiques génériques de couverture (listes/CRUD/décision/autorisation) ajoutées à `istqb-design`. ⚠️ Mesure de rappel bruitée (juge LLM ±15-20 pts) — seules les comparaisons intra-run sont fiables.

## Sprint 7 — Robustesse & oracles ✅ TERMINÉ
Campagne robustesse (50 vrais specs GitHub + 18 monkey, 3 vagues) → **2 blocages sécurité corrigés** (PII verbatim, abus) + 6 gates ajoutés, saturation atteinte (skills 0.1.6→0.1.8, D37, `robustness-campaign.md`). Skill **`oracle-generate`** (0.1.9, D36) : standards comme générateurs de cas (Luhn vérifié). Plugin **`qaia-playwright`** créé (jalon M3 : automate/a11y/perf/sécu/report en skills, industrialise medibook).

## Sprint 6 — Terrain réel & campagne (voir Sprint 7)

## Sprint 5 — Chaîne complète sur app réelle ✅ TERMINÉ
Recherche de cibles (médical + généraliste, `docs/DEMO-TARGETS.md`) ; sandbox fermée → app cible **auto-hébergée localement** (MediBook, implémente les CA d'US-001). Automatisation **POM-fixtures Playwright** (D34) : E2E desktop + mobile (Pixel 7), API, a11y (axe-core, 0 violation), visuel — **24/24 verts, déterministes**. Traçabilité continue exigence → scénario `@QAIA-xxx` → test (`examples/medibook/traceability.md`). 3 findings réels du chasse-flaky (course d'état partagé → `workers:1`, pin Chromium, baselines visuelles). Livré dans `examples/medibook/`.

## Sprint 4 — Skills 0.1.2 ✅ TERMINÉ (top-5 rétro appliqué ; spot-check en cours de validation)

## Sprint 3 — Élargissement (équipe agile en workflow, 8 agents) ✅ TERMINÉ — voir `eval/baselines/sprint3-retro.md` (US-002 : 17/20 4/4 ambiguïtés ; US-003 : 19/20 mais 0/4 → action C1 ; régénération/export/RAG : ✅). **Sprint 4 (nouveau) = skills 0.1.2** : top-5 actions de la rétro, puis re-run harnais 3 US.

## Ancien plan Sprint 2 (conservé pour trace) 🔄

| # | Tâche | État |
|---|---|---|
| S2.1 | Skills 0.1.1 : correctifs convergents (inter-AC, rationale, ratio, [open], @smoke) | ✅ livré |
| S2.2 | Skills `qaia-help` (A4), `testbook-validate` (A3+A5), méta-agent ReAct `qaia` (A9 — en skill, pas en `agents/` : garde-fou sécurité maintenu) | ✅ livré |
| S2.3 | 3 runs de régression 0.1.1 sur US-001 | 🔄 en cours |
| S2.4 | 3 juges + baseline 0.1.1 comparée (attendu : dim. 6 et 9 ↑, rien ne régresse) | ⏳ après S2.3 |
| S2.5 | Test d'exécution de `qaia-help` et `testbook-validate` sur artefacts réels | 🔄 en cours |
| S2.6 | Grooming du backlog (ce document) | ✅ ce commit |

## Sprint 3 — Élargissement du gold set & cycle complet (PRÊT)

| # | Tâche | Critère d'acceptation |
|---|---|---|
| S3.1 | Runs + juges sur **US-002** (frontières) et **US-003** (API/états) — les skills n'ont jamais vu ces US | Baseline 3 US, aucune dimension < 1 |
| S3.2 | Exercer `rag-build` + `feedback` en conditions réelles (initialisation knowledge, une correction promue en règle, effet mesuré au run suivant) | Boucle d'apprentissage démontrée sur le gold set |
| S3.3 | Exercer `testbook-export` (XLSX + Markdown réels) | Fichiers ouvrables, matrice conforme |
| S3.4 | Exercer la **régénération par diff** (D17) : US-001 modifiée + cahier retouché à la main | Retouches préservées, diff arbitré |
| S3.5 | Step-files pour `testbook-generate` (BMAD A6) si les runs 0.1.1 montrent encore des dérives d'exécution | Skill découpée, harnais non dégradé |
| S3.6 | Doc « Using QAIA with BMAD » (canal d'acquisition, D33) | Page publiée |

## Sprint 4 — Sortie publique (BLOQUÉ par actions propriétaire)

| # | Tâche | Bloqué par |
|---|---|---|
| S4.1 | Org GitHub + transfert + second admin + Sponsors/Security Advisories + Projects (Discussions/branch protection/2FA déjà faits) | M0-CHECKLIST #1, #4-5 |
| S4.2 | Merge **squash** de la branche + suppression (nom à purger) — 🔄 en attente, le fondateur s'en charge via l'UI GitHub (droits admin requis, hors de portée de l'agent) | M0-CHECKLIST #3 |
| S4.3 | Vérification nom QAIA + relecture contrat (G1 résiduel) | M0-CHECKLIST #2, #6 |
| S4.4 | Recrutement des **5 pilotes** via communautés QA (gate G2) | M0-CHECKLIST #8 |
| S4.5 | Release 0.2.0 taguée + baseline publiée + annonce | S4.1-S4.4 |

---

## Backlog groomé (au-delà des sprints planifiés)

### P1 — refonte à décider (remontée convergente du harnais)
- ~~**Repenser le gate D20 (ratio négatifs ≥ 40 %)**~~ — **résolu** (grooming 2026-07-24 ter,
  vérifié dans `testbook-generate/SKILL.md` : le vrai gate bloquant est désormais la
  **couverture** ADR 0001 — « chaque `[req-neg]` a son scénario `@negative` ou une dérogation
  explicite » — et le ratio est **reporté, jamais un seuil, jamais gonflé**. C'est exactement
  la proposition ci-dessous, déjà en place ; le backlog n'avait pas été re-groomé pour le
  refléter.

### P1 — après les pilotes (M1 fin)
- Parcours conversationnel réel avec les 5 pilotes (les baselines actuelles sont non-interactives — limite documentée) ; taux de scénarios conservés mesuré
- Budget token mesuré par commande, publié (T11)
- Gate d'aptitude PASS/CONCERNS/FAIL/WAIVED sur la matrice (A5 complet, tâche ex-17d)

### P2 — connecteurs & automatisation (M2-M3, tirés par l'usage réel de M1)
- Connecteur Jira via MCP Atlassian (lecture US) ; reporting retour Xray (mode git-master, D10)
- `qaia-playwright` : tests Playwright natifs référençant les IDs (D5) ; exploration Playwright MCP bornée (T5) ; tests API ; critère T17 sur app pilote réelle ; skill `run-report` (formats T1)
- Import de référentiels existants (Xray, Excel — ex-tâche 39/40 étendue)

### P3 — extensions (M4-M5)
- Plugins `qaia-a11y` (axe-core), `qaia-perf` (k6), `qaia-security` (périmètre D26) — indépendants du core
- Génération de jeux de données (D16) ; connecteurs additionnels votés ; agent nommé enrichi (customisation en couches A10)
- Rituel de release mensuel, good-first-issues, POC prédictibilité

### Supprimé au grooming (avec motif)
- ~~« Steps cucumber-js »~~ (invalidé par D5) ; ~~tâches 1-37 v2 numérotées~~ (absorbées par les sprints ci-dessus — l'historique reste dans git) ; ~~mode commands/ legacy~~ (migré skills/) ; ~~« 3-5 pilotes »~~ (harmonisé : 5 engagés, dont ≥ 3 cycles complets).

## Alimentation continue

Inchangée : issues « Proposition » → À challenger (contributeurs : votes 👍 pour les connecteurs ; agents : jamais d'auto-admission). Revue de backlog à chaque fin de sprint (ce grooming) + mensuelle une fois la communauté active.
