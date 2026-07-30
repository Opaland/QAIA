# Analyse BMAD → décisions d'adoption pour QAIA

> Étude réalisée sur les sources (clone de `bmad-code-org/BMAD-METHOD` v6 — docs incluses — et `bmad-method-test-architecture-enterprise`), 2026-07-23. Synthèse opérationnelle ; la décision d'ensemble est actée en D33 (`DECISIONS.md`).
>
> **Mise à jour 2026-07-29** : recoupée contre la doc publique live (`bmad-code-org.github.io/bmad-method-test-architecture-enterprise`) — 1 écart trouvé et corrigé ci-dessous (workflow *Teach Me Testing* + *TEA Academy*, absents de la version 2026-07-23). Pas de révision de fond : le reste (modèle de risque, gates, écart de nature avec QAIA) tient toujours.
>
> **Ce document analyse TEA, pas la méthode de construction de QAIA elle-même.** QAIA (le produit) n'a pas été bâti en suivant le pipeline BMAD 4 phases (Analysis → Planning → Solutioning → Implementation) : sa propre discovery (`docs/DISCOVERY.md`, gates G1-G3, questions Q1-Qn, ADRs, Kanban) a précédé cette étude BMAD de plusieurs semaines et suit un format distinct, propre à QAIA. Cette étude est arrivée **après** le début de la construction, comme une veille ponctuelle débouchant sur une adoption sélective de patterns (D33) — pas comme la méthode fondatrice du projet.

## Ce qu'est BMAD en une page

**BMAD** (Build More Architect Dreams, ~51k ⭐, MIT) est un framework de développement piloté par IA : *agentic planning* (les agents facilitent la réflexion via des workflows structurés, phase par phase) + *context-engineered development* (chaque phase produit les documents qui deviennent le contexte de la suivante ; « le LLM est le moteur », tout est markdown). Cycle v6 en 4 phases (Analysis → Planning → Solutioning → Implementation), 6 agents nommés à persona (Mary, John, Winston, Amelia…), story files auto-contenus, tracks adaptatifs à l'échelle, installeur multi-outils (40+ plateformes, Claude Code « preferred »), releases mensuelles.

**Le module TEA (Test Architect, agent « Murat »)** est le voisin direct de QAIA : **9 workflows** (Teach Me Testing/TMT, Test Design/TD, Framework Setup/TF, CI/CD Integration/CI, ATDD/AT, Test Automation/TA, Test Review/RV, NFR Evidence Audit/NR, Requirements Tracing/TR — TMT ajouté le 2026-07-29, absent du relevé initial du 2026-07-23), modèle de risque probabilité×impact (priorisation **P0-P3**) avec gates **PASS/CONCERNS/FAIL/WAIVED** et waivers datés/approuvés, base de connaissance à chargement sélectif par tiers (« 40-50 % de contexte économisé »), step-files chargés un à un avec reprise sur frontmatter YAML. Deux points d'entrée pédagogiques notés le 2026-07-29 : **TEA Academy** (7 sessions d'onboarding) et **TEA Lite** (automatisation rapide sans le parcours complet) — non repris dans QAIA (pas de volet formation en v1). **Différence de nature** : TEA part du code et de l'architecture d'un projet BMAD pour outiller des développeurs ; il ne produit pas de cahier Gherkin depuis des US, n'applique pas de techniques ISTQB nommées, n'a ni référentiel de test ni régénération par diff. Aucun recouvrement réel sur le cœur M1 de QAIA.

## Adopté (patterns retenus, par ordre valeur/effort)

| # | Pattern BMAD/TEA | Application QAIA | Quand |
|---|---|---|---|
| A1 | **Frontmatter YAML de progression + Resume** dans les artefacts (`stepsCompleted`, `lastStep`, `lastSaved`) | Complète `.qaia/state/` (T8) : l'état intra-document vit dans l'artefact lui-même — portable (D29), partageable git, lisible humain | M1 |
| A2 | **Index de connaissance à tiers** (core/extended/specialized) + flags de config | Colonne `tier` dans `knowledge/index.md` (D21) + chargement conditionnel (ex. fragments médical si `regulated: true`) | M1 |
| A3 | **Trois intents par skill : Create / Update / Validate** | QAIA a Create et Update (diff D17) ; ajouter un mode **Validate** (audit d'un cahier existant contre la checklist qualité — y compris un cahier non produit par QAIA : produit d'appel) | M1 |
| A4 | **Skill d'orientation `bmad-help`** | Skill `qaia-help` : inspecte `.qaia/`, dit la prochaine étape, invoquée en fin de chaque skill — résout le « et maintenant ? » | M1 |
| A5 | **Gate formalisée PASS/CONCERNS/FAIL/WAIVED** avec waivers (raison + approbateur + expiration) | La matrice de couverture (D18) débouche sur une **décision d'aptitude auditable** — différenciateur niche réglementée (D2), traçabilité depuis l'exigence (pas depuis le code comme TEA) | M1-M2 |
| A6 | **Step-file architecture** pour les skills longues | Découper `testbook-generate` en step-files chargés un à un + `checklist.md` de validation séparée | M1 (refactor) |
| A7 | **Sous-agents → JSON temporaire → agrégation** | Protocole de la parallélisation D30 : seuls les résultats agrégés remontent au contexte principal | M1 |
| A8 | **Checklists par artefact + revue adversariale à filtrage humain** (« zéro finding = re-analyse ; l'IA trouve des faux positifs, l'humain filtre ») | Outillage de D28 (revue des PR de skills) et D31 (aide à la revue du cahier) | M1 |
| A9 | **Un agent nommé à persona** (un seul — pas six) | Un « Test Architect » conversationnel qui porte le parcours et dispatche sur intention ; persona = continuité + découvrabilité | M2 |
| A10 | **Customisation en couches** (défauts → équipe committée → perso gitignorée) | Couche préférences personnelles non versionnées au-dessus du RAG d'équipe (D23) | M2 |
| A11 | **Modèles d'engagement gradués** (à la « TEA Lite ») | Documenter : QAIA Lite (`testbook-generate` seul sur une US collée) / Solo (sans RAG) / Full (parcours complet) | M1 (doc) |
| A12 | **README-architecture transparent** (quel fichier se charge quand) | Standard de doc des skills QAIA — aide aussi la revue adversariale des contributions | M1 (doc) |

## Écarté (et pourquoi)

1. **Constellation d'agents + party mode** — QAIA couvre un métier : un agent, des skills.
2. **Pipeline 4 phases complet** — QAIA consomme des US, il ne cadre pas le produit ; la leçon fondatrice (« des outils, pas un pipeline ») est l'inverse de cette tentation, que BMAD lui-même contourne (Quick Flow, TEA Solo).
3. **Installeur Node/Python 40-plateformes** — ingénierie inmaintenable en solo ; le canal QAIA reste marketplace + copie markdown (T12). Pas de scripts résolveurs non plus (casserait D29) — BMAD paie déjà cette dette.
4. **Sharding de documents** — mécanisme v4 abandonné par BMAD v6 lui-même ; QAIA part directement sur index + fragments ≤ 2k tokens (D21).
5. **Duplication des fragments de connaissance par workflow** — cauchemar de synchronisation en solo ; une seule source `.qaia/knowledge/`.
6. **Web bundles Gemini/ChatGPT** — hors positionnement session Claude, matrice de test triplée.
7. **Boucle non supervisée (bmad-loop)** — l'anti-thèse du contrat QAIA « le testeur valide chaque étape », qui est l'argument réglementaire.
8. **Taxonomie de risque TEA telle quelle** — pensée dev/produit ; QAIA garde les référentiels du métier test (ISTQB, compatible ISO 14971) et mappe vers un score simple (T16).

## Positionnement

**Inspiration d'abord, complément ensuite, concurrent en apparence seulement.** Pas de distribution comme module BMAD en v1 (dépendance à un écosystème mouvant, perte du positionnement skills portables) — mais l'option reste quasi gratuite plus tard : l'architecture skills v6 de BMAD converge vers les plugins Claude Code. Un doc « Using QAIA with BMAD » (QAIA en phase 4, en pair de TEA) est un canal d'acquisition vers une communauté de 51k ⭐ déjà sensibilisée. **Veille active sur TEA à chaque release** : son `risk_threshold` annoncé pointe vers le territoire de QAIA.
