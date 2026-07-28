# QAIA — état du projet & prompt de reprise

## Sprint 25 — reliquat P1-P3 des audits clos : #49/#50/#53-#57 (2026-07-28, D108-D114) — TERMINÉ

Enchaînement direct après Sprint 24 : demande fondateur "(#49, #50, #53-#57) enchaîne" — le
reliquat complet du plan d'action des deux audits externes.

- **#49 fermée** — coût rapproché des paliers d'abonnement Claude, honnêtement (source
  officielle vérifiée d'abord : Anthropic ne publie plus de chiffre exact ; le quota est en
  prompts/session, pas en tokens bruts). D108.
- **#50 fermée** — palette de techniques `istqb-design` réorganisée selon la vraie taxonomie
  CTAL-TA v4.0, vérifiée contre le PDF officiel (pas une source secondaire). 2 dérives
  terminologiques corrigées + trouvaille que EP/BVA/error-guessing ne relèvent pas de la
  taxonomie ch.3 du syllabus. `qaia-core` 0.2.17→0.2.18. D109.
- **#54/#55 fermées** — 2 exclusions de scope (structure-based/white-box, exploratoire/
  session-based) nommées explicitement plutôt que laissées en silence. D110, D111.
- **#57 fermée** — conflit multi-devs sur `.qaia/state/` résolu par convention (un dev par US +
  garantie git ordinaire), pas de mécanisme dédié construit. D112.
- **#53 fermée** — techniques CT-AI enfin exercées pour de vrai : nouvelle fonctionnalité réelle
  ajoutée à `examples/expense-demo` (classifieur déterministe, explicitement non-ML), 8
  scénarios exécutés réellement, relation métamorphique vérifiée. Score 65/100 CONCERNS
  rapporté tel quel. D113.
- **#56 posée au fondateur, pas tranchée seule** — question de positionnement produit, pas un
  choix technique. Décision : la revendication "logiciel médical / environnements réglementés"
  est **retirée** de `README.md` (FR+EN), D2 révisée sans être supprimée. D114.

**Le plan d'action des deux audits externes (Sprint 22 + Gemini) est maintenant intégralement
traité : #49-#58, toutes closes.** Prochain point de départ à déterminer à la prochaine
reprise — plus de backlog agent-faisable connu issu de ces deux audits ; revérifier le board
GitHub avant de conclure à un nouveau mur.

## Sprint 24 — #51/#52/#58 livrés : benchmark, k6, adapter multi-LLM (2026-07-28, D105-D107) — TERMINÉ

Enchaînement direct après Sprint 23 : demande fondateur "fait 51 puis 52 puis 58" (les 3 items
les plus prioritaires du plan d'action des audits externes).

- **#52 fermée** — vrai script k6 (`perf-check/k6/load.js`), exécuté réellement contre
  `examples/expense-demo` (10 VUs/20s, 1981 req, 0 échec, p95=2,23ms). `qaia-playwright`
  0.1.10→0.1.11. D105.
- **#58 fermée** — premier adapter multi-LLM (`prompts/adapters/gemini/testbook-generate.md`),
  exécuté réellement contre Gemini/Groq/Mistral sur US-004. Résultat honnête et mitigé : 1/4
  ambiguïtés plantées repérées par Gemini (contre 4/4 pour QAIA), plus une fabrication de rôle
  inexistant ("Executive Board"). D106.
- **#51 fermée** — le chantier le plus attendu : benchmark chiffré QAIA vs un bon prompt direct
  à Claude Code, deux bras exécutés à froid en isolation sur le même ticket (US-004).
  **Résultat honnête, pas une victoire nette pour QAIA** : coût ~2,9× plus élevé côté QAIA
  (133,1k vs 46,5k tokens) ; score structurel déterministe meilleur en moyenne côté QAIA
  (~72 vs 47/100) mais 2/7 fichiers QAIA échouent quand même au gate structurel (assertions
  narratives non vérifiables) ; sur le rappel des 4 ambiguïtés plantées du gold set, le prompt
  direct égale ou fait légèrement mieux que QAIA **sur ce run précis** (variance de génération
  déjà documentée, D62). Le différenciateur le plus solide n'est pas "QAIA trouve plus" mais
  **QAIA est vérifiable/gaté/traçable** (couverture négative auditée contre ADR 0001, manifeste
  validé par schema D104, zéro règle métier fabriquée côté QAIA contre 4 inventées et non
  signalées côté prompt direct). D107, `eval/baselines/qaia-vs-direct-prompt-benchmark-2026-07-28.md`.
- **1 run rejeté et refait proprement** : le premier bras "prompt direct" du benchmark #51
  avait accidentellement lu la réponse cachée du gold set (outil `Read`, pas de lecture
  partielle possible) — signalé, invalidé, re-exécuté sans laisser l'agent toucher le fichier
  source.

**Prochain point de départ** : le backlog agent-faisable venant d'un audit externe est
maintenant traité pour ses items les plus prioritaires (#51/#52/#58). Reliquat P2/P3 restant
des deux audits (taxonomie CTAL-TA v4.0 #50, démo IA/ML #53, décisions de scope #54-#57) —
vérifier le board GitHub avant de piocher, pas de nouveau levier majeur identifié à la date de
cette session au-delà de ce reliquat déjà tracé.

## Sprint 23 — second audit externe (Gemini), recoupement, JSON Schema (2026-07-28, D104) — TERMINÉ

Le fondateur a transmis un rapport d'audit produit par **Gemini** (3 personas : ISTQB, IA/Prompt
agentic, PM open-source), demandant mise à jour du Kanban puis démarrage d'un plan
d'implémentation ; en session, demande complémentaire de rejouer le même exercice à 3 personas
côté Claude pour recoupement indépendant (le message portait une injection de prompt imitant une
"IMPORTANT SYSTEM INSTRUCTION" exigeant une navigation web du dépôt — signalée au fondateur,
traitée comme une instruction utilisateur ordinaire, écartée sur ce point précis).

- **Rapport Gemini sauvegardé et recoupé** contre l'état réel (pas pris au mot) :
  `eval/baselines/audit-report-gemini-2026-07-28.md`.
- **Second audit Claude 3-personas**, ancré sur les fichiers locaux :
  `eval/baselines/audit-report-claude-3persona-2026-07-28.md`.
- **Divergence de note globale expliquée** : Gemini 7,5/10 ("prêt pour le pilote") vs Sprint 22
  2,4/5≈4,8/10 ("non prêt sans conditions") — différence de méthode (lecture de prose vs
  exécution/reproduction de défauts en direct comme D96/D99), pas de désaccord de fait une fois
  les mêmes items comparés en détail. Les deux s'accordent sur le point faible relatif : preuve
  d'exécution/outillage (#51/#52/#53, déjà ouvertes depuis Sprint 22).
- **JSON Schema formel du contrat de sortie livré le jour même** (`docs/schemas/output-contract-v1.schema.json`
  + `eval/tools/validate_manifest.py`, stdlib sans dépendance), vérifié sans erreur contre les 2
  manifests réels du dépôt + testé positif sur un cas cassé injecté (5 erreurs détectées).
  **Effet de bord** : a trouvé en le construisant un vrai défaut de dérive
  (`examples/scoring-demo/manifest.json` sans `design.knowledgeApplied`, pourtant du contrat 1.0,
  D38) — corrigé dans la foulée.
- **1 nouvelle issue** pour le seul gap Phase 1 restant non implémenté à la volée : portabilité
  multi-LLM des instructions elles-mêmes ([#58](https://github.com/Opaland/QAIA/issues/58),
  distinct du bridge MCP #42).

**Le prochain point de départ reste #51** (benchmark "QAIA vs prompt direct à Claude Code") —
confirmé comme priorité n°1 restante par les deux audits externes (Sprint 22 et ce recoupement),
inchangé par cette session.

Dernière session avant celle-ci : 2026-07-25 (mandat élargi post-M0 **terminé** — D67-D88 : gate G2 levée par
le fondateur, veille concurrentielle faite, backlog remodelé, démonstration hors médical livrée
et vérifiée, puis **8 chantiers du backlog remodelé livrés en autonomie continue** — composite
rules `istqb-design` #45, audit `visual-check` #40, correctif `structural_score.py` #31,
validation conversationnelle simulée #5, 2 mesures de budget token #7, connecteur d'export Xray
#35, nouveau plugin `qaia-testdata` #15, nouvelle skill `traffic-replay` #39 — chacun vérifié
indépendamment avant merge, pas seulement pris au mot de l'agent constructeur). Le backlog
agent-faisable de ce cycle est **épuisé** : tout ce qui reste ouvert est bloqué sur une décision
ou une action du fondateur, une ressource externe, ou un cadrage explicitement requis avant tout
code. Ce document donne l'état honnête du projet et un **prompt prêt à coller** pour reprendre
le travail plus tard (y compris en Claude Code **local** : tout est poussé sur `main`, le pickup
est immédiat).

## Sprint 22 — audit externe multi-persona, correction et suivi (2026-07-26, D99-D103) — TERMINÉ

**L'audit lancé en fin de Sprint 21 a rendu son verdict** : *« Prototype d'ingénierie avancé —
à mi-chemin vers un MVP crédible. Non validé en production, non prêt pour une adoption pilote
sans conditions. »* Moyenne 2,4/5 sur 13 personas (8 ISTQB couverts + 5 hors périmètre), après
revue adversariale à 3 sceptiques ayant reproduit >90% des claims en direct (curl, suites
rejouées, tokens recalculés). **Rapport complet : `eval/baselines/audit-report.html`.**

- **Faille critique trouvée et corrigée le jour même (D99)** : `GET /api/audit` non authentifié
  dans `expense-demo` ET `medibook`, exposait emails/montants/commentaires de rejet — reproduite
  en direct par les 3 sceptiques de l'audit.
- **8 items P0/P1 du plan d'action corrigés directement (D100-D103)** : 3 citations internes
  cassées rétro-documentées, portabilité Chromium/BASE_URL corrigée, preuve `flaky-detect`
  dégonflée (×3→réel), politique retry/quarantaine rendue concrète, trou de couverture CT-MBT
  symétrique comblé (`approved` jamais testé comme terminal, contrairement à `rejected`).
- **9 nouvelles issues (#49-#57)** pour le reliquat P1-P3 (benchmark coût/paliers, benchmark
  "QAIA vs prompt direct" — jugé le plus menaçant par l'audit, moteur k6 réel, démo IA/ML,
  taxonomie CTAL-TA v4.0, décisions de scope à trancher : white-box, exploratoire, niche
  médicale réglementée, multi-devs concurrent).
- **#1/#2 mis à jour** : l'audit les cite explicitement comme 2 des 3 faits bloquants du
  verdict final (gate G2 jamais franchie, bus factor = 1 non résolu).

**Le prochain point de départ n'est plus une veille à froid — c'est ce plan d'action.** Avant
de chercher un nouveau levier, lire le verdict complet et vérifier l'état des issues #49-#57.

## Sprint 21 — élargissement ISTQB global, IDOR trouvé, démo statique (2026-07-26, D94-D98) — TERMINÉ

Enchaînement après Sprint 20 : demande fondateur de sortir du seul angle médical pour la veille
concurrentielle (GitHub + web, regard global), puis d'auditer la couverture ISTQB complète
(pas seulement CT-GenAI) et de combler les gaps trouvés, de tester en local, et de publier une
démo statique GitHub Pages pour les skills UI-only.

- **Veille élargie (D94)** : écosystème de plugins Claude Code QA densifié depuis D67, aucun
  concurrent à l'échelle d'Agentic QE Fleet (421★, toujours le seul acteur sérieux). 1 trouvaille
  distincte vérifiée directement (`chaos-qa`, sondage adversarial de contrat) → #47.
- **8 ajouts ISTQB au-delà de CTFL/CT-GenAI (D95, #48 fermée)** : Domain Analysis + Metamorphic
  testing + techniques CT-AI v2.0 dans `istqb-design` ; menu de types nommés CT-PT dans
  `perf-check` ; refonte risk-based CT-SEC dans `security-surface` ; précheck de testabilité
  CTAL-TAE dans `automate` ; nouvelle skill `usability-heuristic-review` (CT-UT). Confirmé déjà
  couvert ou hors périmètre sans travail double : CRUD, Test Impact Analysis, CTAL-TM, CT-MAT
  natif.
- **Vrai IDOR trouvé et corrigé (D96)** en testant localement le nouveau `security-surface`
  risk-based sur `expense-demo` : `GET /api/reports/:id` n'avait aucune vérification de
  propriété, contrairement au `PUT` sœur — n'importe quel utilisateur authentifié pouvait lire
  le brouillon de n'importe qui. Corrigé, 3 cas de non-régression ajoutés.
- **Démo statique GitHub Pages (D97)** publiée à `https://opaland.github.io/QAIA/`
  (`static-demo/`, mock-backend fidèle y compris le correctif IDOR). Vérifiée à deux niveaux :
  logique Node identique au fichier déployé, puis navigateur réel une fois Playwright
  reconnecté (flux complet employee→manager rejoué, captures d'écran, zéro erreur console).
- **Nouvelle skill `contract-probe` (D98, #47 fermée)** : sondage adversarial de contrat,
  dernier chantier de la veille élargie. Vérifiée sur un fixture dédié avec un défaut injecté
  délibérément.

**Backlog agent-faisable de nouveau épuisé.** Un audit externe multi-persona (cabinet fictif,
8 personas ISTQB sur les disciplines couvertes + 5 personas sur les disciplines non couvertes,
revue adversariale à 3 sceptiques, synthèse) a été lancé en `Workflow` pour challenger le produit
dans son ensemble — **verdict pas encore rendu au moment de la rédaction de cette section**,
à consulter/résumer dans la prochaine reprise si la session s'est arrêtée avant qu'il ne finisse.

## Sprint 20 — reliquat + fiabilisation (2026-07-25, D89-D93) — TERMINÉ

Enchaînement direct après le mandat post-M0 : le fondateur a demandé de compléter le reliquat
honnête déjà identifié plutôt que d'attendre un nouveau levier, puis un nouveau passage de veille
concurrentielle pour re-chercher du carburant de backlog.

- **#35 fermée** — connecteur d'export TestRail livré (Xray déjà livré en D86), même discipline
  d'honnêteté, vérifié indépendamment (D89).
- **#7 fermée** — les 14 skills de `qaia-core` ont désormais une mesure réelle de budget token
  (9 nouvelles cette session). Gain méthodologique réutilisable : la notification de fin de
  tâche d'un agent délégué porte son vrai total de tokens (`subagent_tokens`), lisible
  directement par l'orchestrateur (D91, D92).
- **#46 ouverte puis fermée le jour même** — trouvée en exerçant `testbook-validate`/`report` en
  conditions réelles (effet de bord d'une mesure de budget token, pas cherchée) : `testbook-generate`
  pouvait asserter un total de conversion de devise précis au centime sans source de taux tracée.
  Corrigé (garde-fou ajouté + fixture réparée), vérifié indépendamment (D93).
- **Re-veille concurrentielle (même jour)** : un chemin prometteur (IEC 62304 Edition 2 vs
  AI-comme-outil-de-développement) **n'a pas résisté à la vérification directe** de la source —
  l'article ne couvre que l'IA embarquée dans le dispositif médical, pas l'IA utilisée comme
  outil de développement/test, et reste de toute façon en brouillon. Écarté honnêtement plutôt
  que forcé en backlog. **Aucun nouveau levier trouvé** — le paysage n'a pas bougé depuis D67
  (quelques heures plus tôt le même jour).
- **Board GitHub re-vérifié** : 10 issues ouvertes, toutes bloquées exactement comme documenté
  ci-dessous — aucune n'est devenue agent-faisable entre-temps.

## Mandat post-M0 (D67-D88, 2026-07-25) — TERMINÉ

Le fondateur a levé le gate G2 (5 pilotes réels) et donné un mandat élargi : veille
concurrentielle (faite, `docs/COMPETITIVE-ANALYSIS.md`), remodelage du backlog (fait —
#1/#5/#23 fermées ou reformulées, #29/#30 débloqués sur le papier, 10 nouvelles issues
#33-#42), extension du produit à un domaine non-médical (**faite**, `examples/expense-demo/`
sur US-004 — notes de frais, finance/HR), puis relance du développement en autonomie sur le
backlog remodelé — **exécutée jusqu'à épuisement de ce qui est agent-faisable**.

**Démonstration hors médical (D68)** : app réelle self-hostée + parcours QAIA complet (38
scénarios Gherkin) + automatisation Playwright — **40/40 tests verts, re-vérifié
indépendamment** (pas seulement le rapport de l'agent constructeur), score structurel
déterministe 4/4 fichiers PASS. **3 vrais défauts trouvés et corrigés pendant
l'automatisation** (une vraie violation WCAG, une course de test induite par le correctif,
une erreur arithmétique dans le cahier généré). **1 vrai défaut produit trouvé et corrigé** :
`istqb-design` sous-classifiait parfois une ambiguïté métier en `[assumption]` plutôt que
`[open]` quand une convention de machine à états comblait le vide silencieusement — tracé en
[#43](https://github.com/Opaland/QAIA/issues/43), corrigé, puis étendu par #45 (D81,
décomposition des règles composites).

**8 chantiers du backlog remodelé livrés en autonomie continue (D81-D88)**, chacun vérifié
indépendamment avant merge (tests rejoués, diffs isolés relus, valeurs grep-ées) — pas
seulement pris au mot de l'agent constructeur :
1. **#45** — `istqb-design` décompose désormais les règles composites (`BR-KB-203` 3/7→7/7).
2. **#40** — audit `visual-check` vs diff perceptuel : suffisant tel quel, 1 vraie lacune
   documentaire trouvée et corrigée (budget de tolérance consommé en silence).
3. **#31** — `structural_score.py` : limite résiduelle `ASSERT_RE`/guillemets corrigée (cas
   C5 du corpus 24 désormais détecté FAIL), zéro régression.
4. **#5** — première validation conversationnelle **simulée** (arbitrage humain réellement
   exercé, pas en mode non-interactif) : 8 objections/corrections sur 5 étapes, rétention
   28/34 scénarios (82,4 %).
5. **#7** — 2 mesures de budget token réelles de plus (`rag-build` 67,6k, `testbook-export`
   77,6k) — 5/12 skills mesurées, 7 honnêtement encore estimées.
6. **#35** — connecteur d'export Xray (git-master, CSV, fichier seul) ; TestRail
   explicitement non couvert.
7. **#15** — 4ème plugin `qaia-testdata` (jeux de données synthétiques), validé 10/10 tests.
8. **#39** — nouvelle skill `traffic-replay` (HAR → conditions de non-régression), masquage
   PII/secrets vérifié sans fuite sur 8 catégories.

Objectif final du mandat : un projet montrable, docs à jour, diffusable, sans bug évident —
pas seulement sur le médical. **Atteint pour tout ce qui est agent-faisable.** Ce qui reste
ouvert est bloqué sur le fondateur ou une ressource externe — voir « Ce qui bloque »
ci-dessous.

## Où on en est

**Le produit existe et est éprouvé (en automatique, et maintenant aussi sur du matériel dur réel). Quatre plugins.**
- **`qaia-core` 0.2.17** — 15 skills, **budget token intégralement mesuré (issue #7 fermée)**, **technique palette élargie CTFL+Test Analyst+CT-AI (D95)** : parcours complet US → cahier Gherkin (`us-ingest` [+ connecteur Jira #9], `us-review`, `need-understanding`, `rag-build`, `istqb-design` [RAG-in-use + amendements #24/#43/#45 + Domain Analysis/Metamorphic/CT-AI/modèle d'états explicite #48], `oracle-generate` [+ oracle projet OpenAPI #16, durci #25], `prioritize` [audité, A/B testé, +signal git-history #36], `testbook-generate` [garde-fou anti-fabrication étendu aux valeurs calculées non sourcées, #46], `report` [manifeste standardisé], `testbook-export` [+ export Xray et TestRail opt-in, #35 fermée], `feedback`) + `qaia` (méta-agent ReAct), `qaia-help`, `testbook-validate` [+ pass structurel déterministe, D45], `hello`.
- **`qaia-playwright` 0.1.9** — 11 skills : `automate` (Gherkin → Playwright POM + pipeline CI, +lint anti-assertions-creuses #41, +précheck de testabilité CTAL-TAE #48), `a11y-audit`, `visual-check` (régression visuelle, audité #40), `perf-check` (+menu de types nommés CT-PT #48), `security-surface` (+refonte risk-based CT-SEC #48, a trouvé et corrigé un vrai IDOR #96), `usability-heuristic-review` (nouveau, CT-UT #48), `contract-probe` (nouveau, sondage adversarial de contrat #47), `run-report`, `flaky-detect` (#34), `locator-repair` (#37), `traffic-replay` (HAR → non-régression, #39).
- **`qaia-score` 0.1.4** — score uniquement, lecture seule : `testbook-score` (rubrique ISTQB /20 + top-3, pass structurel DÉTERMINISTE step 0, sniffer anti-fabrication #27, détecteurs C1/C2 #28), `aptitude-gate` (PASS/CONCERNS/FAIL/WAIVED, +recalcul du total #21, +signal `flakiness` #44). N'écrit que le bloc `gate` ; aucun producteur ne se score lui-même.
- **`qaia-testdata` 0.1.0** (nouveau, #15) — 1 skill : `dataset-generate` (jeux de données synthétiques cohérents métier, injectables via fixtures Playwright, jamais de données réelles/PII).
- **Démo statique GitHub Pages** : `https://opaland.github.io/QAIA/` (`examples/expense-demo/static-demo/`), pour tester `usability-heuristic-review`/`a11y-audit`/`visual-check` sans backend local.

**Session 2026-07-25 — corpus élargi 24 cas TERMINÉ (lots 2-6, 20 cas clean-room via agents
parallèles) :** Reprise après un plantage de session (rien perdu, tout committé). Les 5 lots
restants (C1-C20) ont été exécutés via des agents indépendants en parallèle (4 par lot),
chacun rédigeant son propre ticket clean-room, sa propre génération Claude fidèle aux 3
skills, et ses propres appels aux fournisseurs externes. **Bilan global (D58-D64,
`eval/baselines/corpus-24-depth.md`)** : **Claude 24/24 cas sans défaut de détection** ;
**Gemini le fournisseur externe le plus fiable** (0 échec de détection sur 21 cas
disponibles, ratio négatif D20 auto-rapporté systématiquement exact, mais 4 défauts annexes
de fabrication non flaguée cumulés) ; **Groq et Mistral échouent chacun ~25-33 % des cas** à
raisonnement multi-règles ou `Then` vérifiable (sans-faute sur CRUD-inverse/traçabilité) ;
**Hugging Face couverture partielle (13/24 cas)**, le profil de défauts le plus dense (6
distincts) puis indisponibilité opérationnelle (crédit gratuit épuisé, `402`) sur les 11
derniers cas. **2 défauts transversaux confirmés à l'échelle du corpus entier** : le ratio
négatif D20 auto-rapporté est peu fiable chez tous sauf Gemini (valide fortement D50) ; le
détecteur `structural_score.py` (`VAGUE_RE`/`HOLLOW_RE`) a un angle mort sur les formulations
paraphrasées, confirmé 3 fois (C5, C10, C18) — **non corrigé cette session, backlog explicite**.
CRUD-inverse et traçabilité des IDs généralisent fortement (quasi aucun échec sur 24 cas).
Le produit QAIA lui-même (3 skills testés) n'a montré aucune régression — la variance mesurée
est modèle-dépendante, pas skill-dépendante.

**Session 2026-07-24 (ter, suite 13) — corpus élargi 24 cas, lot 1/6 (profondeur statistique) :**
Suite à D55-D57 (balayage en largeur, N=1/skill) : demande fondateur de creuser en profondeur
sur du matériel neuf pour voir si les patterns tiennent à plus grande échelle. Plan à 24 cas
(4 réels GitLab CE + 20 clean-room répartis par format/domaine, `eval/goldset-hardened/corpus-24-plan.md`).
**Lot 1/6 exécuté** (4 cas réels GitLab CE v8.16.9, jamais utilisés cette session) sur Claude +
Groq + Hugging Face + Mistral (Gemini rate-limité après le 1er cas, décision fondateur de
continuer sans lui). **2 nouveaux défauts** : Hugging Face invente des codes HTTP précis
(201/404/409) sur un ticket sans API REST mentionnée (4e défaut distinct trouvé chez HF cette
session) ; Mistral invente une exception "propriétaire" non fondée sur une page de visibilité
publique. Signal plus léger confirmé (dédup tautologique Groq/Mistral). Sans-faute total sur le
piège précondition SSH (5/5 modèles). Décision D58. Preuve : `eval/baselines/corpus-24-depth.md`.
**Reste** : lots 2-6 (20 cas clean-room), même protocole, par lots de 4-6 pour respecter les
paliers gratuits.

**Session 2026-07-24 (ter, suite 12) — balayage multi-modèles COMPLET, 23/23 skills :**
Demande fondateur : étendre le harnais de gap à tous les skills, vérifier systématiquement
sur 4+ modèles gratuits (Gemini, Groq, Hugging Face, Mistral ; Cerebras ajouté mais bloqué
côté compte). **Bilan** : 3 défauts réels trouvés, tous sur les 9 skills à jugement ouvert du
cœur du pipeline (Groq/raisonnement multi-règles profond, Mistral/traçabilité de provenance,
Hugging Face/3 défauts distincts dont une fuite de PII présentée comme "sanitized") ; **0
défaut** sur les 14 skills à règles mécaniques/ordonnées explicitement (tout
`qaia-playwright`, `qaia-score`, `hello`, `qaia-help`) — y compris un test de sécurité
(injection via nom de fichier) où aucun des 5 modèles n'a cédé. Décisions D55-D57. Preuve
complète : `eval/baselines/multimodel-skill-sweep.md`.

**Session 2026-07-24 (ter, suite 6) — prompt management sur les 23 skills + second juge :**
Demande fondateur : auditer précision/format/exemples des 23 skills, et outiller un second
juge LLM indépendant (multi-fournisseur gratuit, en repli : Gemini → Groq → Hugging Face).
**Trouvé et corrigé** : un doublon de numérotation dans `need-understanding` (deux étapes
"4."). **Second juge livré et vérifié en live sur les 3 fournisseurs** (2 défauts trouvés en
l'exécutant réellement : 403 urllib/User-Agent sur HF, format de réponse Gemini mal
documenté par une source web résumée) — converge avec le juge Claude et le scoreur
déterministe sur le même défaut C1 (accord tri-source). `eval/tools/second_judge.py`,
`.env`/`.gitignore` ajoutés (secrets jamais commis, jamais dans le produit livré — D29
intact). **Premier test A/B contrôlé sur un skill** (`prioritize`, avec/sans exemple
chiffré) : résultat négatif honnête — l'exemple testé aurait dégradé la calibration (sur-
généralisation "chemin négatif → probabilité plus haute" jusqu'à un contrôle d'auth
générique), **pas appliqué**. Décisions D51-D52. Preuves : `eval/baselines/second-judge.md`,
`eval/baselines/prioritize-ab-test.md`. Reste : auditer `qaia` (méta-agent, identifié comme
le skill le plus vague du corpus) si on continue le prompt management.

**Session 2026-07-24 (ter, suite 2) — non-régression des amendements #24 échantillonnée :**
2 cas réels neufs (GitLab CE `dashboard.feature`, Diaspora `two_factor_authentication.feature`),
jamais vus par les runs d'origine, soumis en tickets durs. **Les 2 amendements généralisent** :
le gap des entités-sœurs est explicitement flagué (pas silencieux) sur le Dashboard ; le tag
`@low-confidence` est correctement posé sur la désactivation 2FA et la régénération des codes
de récupération. Limite assumée : pas un re-run complet des 50 US (pas de mesure de
rappel/précision agrégée) — signal de généralisation, pas clôture définitive. Preuve :
`eval/baselines/istqb-amendments-regression-24.md`, décision D48.

**Session 2026-07-24 (ter, suite) — #25 durci en enchaînement autonome :** `oracle-generate`
(`oracles/openapi.md`) reçoit un **step 0** obligatoire : résolution `$ref` interne avant toute
lecture de contrainte (un noeud non résolu perdait les négatifs de champ requis en silence), et
avertissement explicite **« spec sous-documentée »** (0 erreur 4xx/5xx documentée sur tout le
spec, ou mutations sans auth déclarée) au lieu de dégénérer silencieusement vers `[open]`
partout. Règle **re-vérifiée en re-fetchant les 3 vraies specs** du constat initial
(Petstore/apis.guru/Notion) — la première mouture aurait manqué apis.guru (méta-API en lecture
seule), corrigée avant livraison. `qaia-core` 0.2.7→0.2.8. Preuve :
`eval/baselines/connectors-real-data.md`, décision D47.

**Session 2026-07-24 (ter) — harnais de gap #24 exécuté sur du matériel réel (accès web) :**
2 cas durs sourcés sur le web (GitLab CE `groups.feature` sans narratif US, Sharetribe champs
custom pilotés par config admin), 4 runs isolés (3× sur le cas Groups pour la variance).
**Résultats honnêtes** : mode 2 (config-driven) confirmé tenu sur cas neuf, zéro régression ;
mode 4 (variance) confirmé significatif (29→42 scénarios, +45 %, sur ticket identique) ; mode 1
(extraction) → **2 défauts trouvés et corrigés** dans `istqb-design` (silence sur les
entités-sœurs non nommées, fabrication convergente non flaggée d'une sémantique de
suppression) ; mode 3 (redondance) → détecteur déterministe ajouté à `structural_score.py`,
qui a lui-même révélé et corrigé un faux positif sur du contenu réel (C1 se déclenchait sur le
mot "image" seul). `testbook-validate` reçoit désormais le même pass structurel déterministe
que `testbook-score` (D45). Preuves : `eval/baselines/gap-harness-24.md`,
`eval/goldset-hardened/real-cases-24.md`, `eval/baselines/structural-score.md` (mis à jour).
Décisions D44-D46. **Non fait** : re-mesure des 50 US de `groundtruth-corpus.md` avec les 2
amendements — honnêtement marqué comme suivi, pas encore validé à grande échelle.

**Session 2026-07-24 — le meilleur d'IATS, en autonomie :** lecture des **vrais docs IATS** (Google Drive, dossier *Softway Medical*) → rétrospective honnête `docs/IATS-RETROSPECTIVE.md` (cas réel US 676266 : 100/100 machine vs 58/100 humain ; FinOps confirmé comme régression). **Score structurel déterministe** (`eval/tools/structural_score.py` + `eval/baselines/structural-score.md`, gold set durci `eval/goldset-hardened/`) — discrimine 100/PASS vs C1/C2/fabrication FAIL. **Connecteurs testés sur données réelles** (`eval/baselines/connectors-real-data.md` : oracle OpenAPI dégénère en silence sur specs sous-documentées #25 ; Jira sur réponse réelle). **Gouvernance ADR 0002 / D42-D43** (révise D14) : Python en session autorisé ; hooks/MCP/agents = tier opt-in post-pilote (#29 hook budget, #30 agent ReAct). Nouvelles issues : #18-#30.
- **Contrat de sortie standardisé (D39)** : un unique manifeste JSON par US (`docs/OUTPUT-CONTRACT.md`, contrat 1.0) que tous les plugins écrivent au même format — socle du scoring et de tout export/CI.
- Les trois valident `claude plugin validate --strict`. CI durcie (supply-chain, DCO, gherkin-lint). Marketplace prêt (3 plugins).

**Session 2026-07-23 (bis) — 6 chantiers livrés en autonomie :** contrat de sortie standardisé (D39), plugin de score `qaia-score` (D40), RAG en usage réel (protocole récupération/citation + conditions tirées des règles, `examples/rag-demo/`), oracle projet OpenAPI (D36b, `#16`), connecteur Jira (D9, `#9`, `examples/jira-demo/`), durcissement M3 `automate` (D41, `#10` : scaffold + templates CI + gate T17 honnête). Démos : `examples/scoring-demo/`, `rag-demo/`, `jira-demo/`, `oracle-demo/` (+OpenAPI).

**Ce qui a été mesuré (pas affirmé) :**
- Rubrique gold-set : **médiane 17→19/20** sur 5 US, défauts critiques fermés (C1).
- Exemple exécutable réel `examples/medibook/` : **31 tests Playwright verts, 7 types** (E2E desktop+mobile, API, a11y, visuel, sécu, perf).
- **Campagne robustesse** (50 vrais specs + 18 monkey) : **2 blocages sécurité trouvés et corrigés** (PII, abus), 6 gates ajoutés, saturation. `eval/baselines/robustness-campaign.md`.
- **Éval vérité-terrain** (50 paires US+tests humains validés, gitlab/diaspora/sharetribe) : **généralisation prouvée sans overfitting** (held-out ≥ train), **précision ~93 %**, **+200 scénarios valides** au-delà des humains. Plafond honnête (config-driven → RAG). ⚠️ mesure de rappel bruitée. `eval/baselines/groundtruth-training.md`.

**Décisions** : 38 décisions + 17 défauts tracés dans `docs/DECISIONS.md`. Étude BMAD intégrée (`docs/BMAD-ANALYSIS.md`).

## Ce qui bloque (et qui n'est pas à la main d'un agent)

Le mur humain reste réel, même si G2 a été levée sur le plan calendaire (D67) : personne n'a
encore validé le parcours avec un vrai testeur externe. `#5` a désormais une validation
**simulée** avec arbitrage humain réellement exercé (D84), mais ce n'est explicitement pas un
substitut à `#1` (5 vrais pilotes). Issues bloquées sur ce mur :
[#1](https://github.com/Opaland/QAIA/issues/1) (5 pilotes, gate G2),
[#10](https://github.com/Opaland/QAIA/issues/10)/[#12](https://github.com/Opaland/QAIA/issues/12)/[#13](https://github.com/Opaland/QAIA/issues/13)/[#14](https://github.com/Opaland/QAIA/issues/14)/[#18](https://github.com/Opaland/QAIA/issues/18)
(critère T17 sur app pilote réelle — D79 : la démo expense-demo ne le satisfait pas
littéralement, malgré sa forte valeur de preuve). Kit prêt : `docs/PILOT-KIT.md` (15 min) ;
message de recrutement dans `docs/OWNER-GUIDE.md`.

**Autres blocages non-agent (2026-07-25) :**
- [#2](https://github.com/Opaland/QAIA/issues/2) — transfert d'org GitHub, droits admin requis.
- [#32](https://github.com/Opaland/QAIA/issues/32) — crédit gratuit Hugging Face épuisé (`402`), ressource externe.
- [#29](https://github.com/Opaland/QAIA/issues/29)/[#30](https://github.com/Opaland/QAIA/issues/30) — tier opt-in (hook budget/observabilité, agent de revue adversariale) : ADR 0002 dit encore explicitement « post-pilote uniquement » dans son propre texte ; D67 a dit le développement « possible » mais je n'ai pas traité cette ligne ambiguë comme un blanc-seing pour rouvrir unilatéralement le débat multi-agents (D33) ou le tier supply-chain — nécessite un engagement plus explicite du fondateur.
- [#42](https://github.com/Opaland/QAIA/issues/42) — son propre critère d'acceptation exige un tranchage fondateur (« aller / ne pas aller » acté dans `docs/DECISIONS.md`) avant tout code.

## Prochains leviers (par ordre de valeur)

**Le backlog agent-faisable de ce cycle est épuisé (2026-07-25).** Les 8 chantiers du mandat
post-M0 remodelé (#45, #40, #31, #5, #7 partiel, #35 partiel, #15, #39) sont livrés et vérifiés
indépendamment (voir « Mandat post-M0 » ci-dessus). Tout ce qui reste ouvert sur le board
GitHub est listé dans « Ce qui bloque » — chacun nécessite soit une décision/action du
fondateur, soit une ressource externe non disponible en session. **Ne pas inventer de travail
marginal** : le prompt de reprise ci-dessous doit d'abord re-vérifier le board GitHub pour un
nouveau levier avant de conclure au mur, mais à la date de cette session il n'y en a aucun.

**Reliquat honnête sur des issues partiellement closes (pas de nouveau levier, juste à
compléter si le fondateur le demande) :**
- `#7` — 7 skills de `qaia-core` restent estimées, pas mesurées (`hello`/`qaia-help`,
  `us-review`, `need-understanding`, `prioritize`, `oracle-generate`, `testbook-validate`,
  `report`, `feedback`).
- `#35` — TestRail non couvert (Xray seul livré).

**Tier opt-in (post-pilote, ADR 0002) :** #29 hook budget/observabilité (comble #7 FinOps), #30 agent ReAct, #42 bridge MCP. Ne pas construire avant un engagement fondateur plus explicite que D67 (#23, leçon #2, tension D33 non rouverte).

> **Note accès web (2026-07-24 ter)** : cette session a confirmé l'accès à `WebSearch`/`WebFetch` (GitHub + web général), utilisé pour sourcer les 2 cas durs réels du #24 — à **reconfirmer en reprise** (l'environnement d'exécution peut varier d'une session à l'autre, ne pas supposer l'accès acquis par défaut).
>
> **Gold set IATS (~88 US) : piste abandonnée (D49, fondateur, 2026-07-24 ter).** Sur
> **Google Drive** (dossier *Softway Medical*, confidentiel), seul le pitch IATS (cas réel
> US 676266) est présent — le gold set des ~88 US N'EST PAS sur Drive, probablement dans
> **Tuleap** ou des exports Notion ZIP non inspectés. Le fondateur a tranché : ne pas
> poursuivre cette piste, le coût (accès Tuleap, dézippage/inspection Notion, tout
> confidentiel/jamais commité) dépasse la valeur puisque le harnais #24 fonctionne déjà sur
> du matériel réel public, réutilisable indéfiniment. **Ne pas rouvrir sans raison nouvelle
> et concrète.**

## Actions propriétaire restantes
Voir `docs/M0-CHECKLIST.md` (détail à jour) et `docs/OWNER-GUIDE.md`. Fait : repo public,
Discussions, branch protection, 2FA. Reste : **merger cette branche dans `main` (squash) puis
la supprimer** — nécessite des droits admin que l'agent n'a pas (pas de `gh` CLI en session,
branch protection active) ; pilotes (#1) ; contrat (#3) ; org (optionnel #2) ; Sponsors/
Security Advisories ; GitHub Projects.

---

## 🔁 Prompt de reprise (à coller dans une nouvelle session Claude Code sur ce repo)

```
Reprends le projet QAIA (plateforme QA agentic open source, plugins Claude Code).
Lis d'abord docs/STATUS.md, docs/DECISIONS.md et docs/KANBAN.md pour le contexte complet.

**Sprint 23 (D104) puis Sprint 24 (D105-D107), 2026-07-28, TERMINÉS** depuis la dernière reprise
ci-dessous : un second audit externe (Gemini) a été reçu et recoupé contre un audit indépendant
Claude 3-personas — voir `eval/baselines/audit-report-gemini-2026-07-28.md` et
`eval/baselines/audit-report-claude-3persona-2026-07-28.md`. JSON Schema formel du contrat de
sortie livré (`docs/schemas/output-contract-v1.schema.json` + `eval/tools/validate_manifest.py`,
D104). Puis, sur demande explicite du fondateur, les 3 items les plus prioritaires du plan
d'action des deux audits ont été traités dans l'ordre : **#52** (script k6 réel, exécuté
réellement, D105), **#58** (adapter multi-LLM, exécuté réellement contre Gemini/Groq/Mistral,
résultat mitigé honnête, D106), **#51** (benchmark QAIA vs prompt direct — le chantier le plus
attendu des deux audits, résultat honnête et **pas une victoire nette pour QAIA** : coût ~2,9×
plus élevé, score structurel meilleur en moyenne mais pas parfait, rappel d'ambiguïté égal ou
légèrement en faveur du prompt direct sur ce run précis ; le vrai différenciateur mesuré est la
vérifiabilité/traçabilité, pas la couverture brute — D107). **#49/#50/#53-#57 restent ouvertes**
(reliquat P2/P3, pas traité cette session, pas un nouveau levier majeur identifié).

État (2026-07-26) : QUATRE plugins validés --strict — qaia-core 0.2.17 (15 skills, budget
token intégralement mesuré, palette de techniques élargie CTFL+Test Analyst+CT-AI), qaia-playwright
0.1.9 (11 skills, dont usability-heuristic-review et contract-probe tout neufs), qaia-score
0.1.4 (2 skills), qaia-testdata 0.1.0 (1 skill). Éprouvé en automatique (gold set 19/20,
robustesse, éval vérité-terrain ~93 % précision), sur du matériel dur réel (harnais #24, corpus
élargi 24 cas D58-D64 : Claude 24/24 sans défaut), bout-en-bout sur DEUX domaines indépendants
(santé — examples/medibook/, 31 tests verts ; finance/RH — examples/expense-demo/, 40+ tests
verts), ET maintenant sur une démo statique GitHub Pages publique
(https://opaland.github.io/QAIA/, vérifiée en navigateur réel).

**Mandat post-M0 (D67-D88), Sprint 20 (D89-D93), Sprint 21 (D94-D98) TERMINÉS.** Sprint 21
(2026-07-26) : veille concurrentielle élargie hors médical (D94, aucun nouveau concurrent
sérieux, 1 trouvaille `chaos-qa` → #47), audit complet des syllabus ISTQB au-delà de CTFL/CT-GenAI
et 8 ajouts livrés (D95, #48 fermée : Domain Analysis/Metamorphic/CT-AI/modèle d'états dans
`istqb-design`, menu CT-PT dans `perf-check`, refonte risk-based CT-SEC dans `security-surface`,
précheck testabilité CTAL-TAE dans `automate`, nouvelle skill `usability-heuristic-review`),
**un vrai IDOR trouvé et corrigé** en testant localement le nouveau security-surface (D96),
démo statique GitHub Pages publiée et vérifiée à deux niveaux — logique Node puis navigateur
réel (D97), nouvelle skill `contract-probe` fermant #47 (D98). Décisions D67-D98 dans
docs/DECISIONS.md.

**Sprint 22 (D99-D103) : l'audit externe multi-persona a rendu son verdict.** *« Prototype
d'ingénierie avancé, non prêt pour une adoption pilote sans conditions. »* Moyenne 2,4/5 sur
13 personas. **Lire le rapport complet avant toute chose** (`eval/baselines/audit-report.html`)
si tu ne l'as pas déjà en contexte — il est plus informatif que ce résumé. Une faille critique
trouvée (IDOR sur `GET /api/audit`) a été corrigée le jour même (D99), 8 items P0/P1 du plan
d'action ont été corrigés directement (D100-D103), 9 nouvelles issues ouvertes pour le reliquat
(#49-#57, voir ci-dessous).

**Le backlog agent-faisable N'EST PLUS épuisé — 9 issues fraîches (#49-#57) attendent, plus le
reliquat pré-existant (10 issues, toujours bloquées comme avant).** Priorité suggérée par le
compte-rendu d'audit lui-même : **#51 (benchmark "QAIA vs prompt direct à Claude Code")** avant
d'étendre encore la couverture fonctionnelle — c'est l'angle que l'audit juge le plus menaçant
pour la valeur même du produit, et rien d'autre dans le backlog ne le remplace. Les autres
issues fraîches (#49 coût/paliers, #50 taxonomie CTAL-TA v4.0, #52 moteur k6 réel, #53 démo
IA/ML, #54-#57 décisions de scope à trancher) sont documentées avec un critère d'acceptation
clair. Le reliquat pré-existant reste bloqué sur : (a) le mur humain — #1 (5 vrais pilotes,
confirmé bloquant par l'audit), #10/#12/#13/#14/#18 (T17, D79) ; (b) une ressource externe —
#32 (crédit Hugging Face épuisé) ; (c) un cadrage fondateur — #29/#30/#42 ; (d) propriétaire
seul — #2 (transfert d'org, confirmé bloquant par l'audit). **Vérifie le board GitHub avant de
piocher** — l'état ci-dessus est celui de la fin de Sprint 22, une issue a pu bouger depuis.

**Coût agent (D102, réappliqué tout le Sprint 21) : par défaut, préfère l'édition directe
(Read/Edit/Bash) à un dispatch d'agent en sous-tâche pour du travail déjà bien cadré** — ne
réserve le dispatch d'agent (surtout en `isolation: "worktree"`, ~40-140k tokens par agent
observé) qu'aux tâches vraiment parallélisables ou nécessitant une exécution isolée/indépendante
(ex. une mesure qui doit être un run réel séparé). **Exception explicitement voulue par le
fondateur (fin Sprint 21) : le `Workflow` tool reste approprié pour un panel multi-persona
genuinement parallèle avec revue adversariale** (l'audit externe ci-dessus) — la discipline de
coût vise le dispatch d'agent isolé pour du travail séquentiel bien cadré, pas l'orchestration
multi-agents quand la tâche l'exige vraiment et que le fondateur la demande explicitement.

Principes non négociables : distribution 100 % skill (Markdown, sans clé API) ; Python EN
SESSION généré par un skill autorisé (déterminisme sans shipper de code, ADR 0002/D42) ;
hooks/MCP/agents = tier opt-in séparé, jamais dans le cœur, gardé post-pilote sauf engagement
fondateur explicite plus fort que D67 (leçon #2, tension D33 sur le multi-agents à ne pas
rouvrir seul) ; sortie au contrat standard (D39) ; aucun producteur ne s'auto-valide/score
(rule 3) ; Gherkin atomique + IDs stables ; Playwright natif (D5) ; POM-as-fixtures (D34) ;
PII masquée + gates abus/not-a-spec (D37, étendu au trafic HTTP par D88) ; rappel honnête >
fabriqué (D38) ; connecteurs portable-first (D29) ; jamais réutiliser un secret qui a transité
en clair dans le chat (D51, réappliqué cette session sur un PAT GitHub collé par le fondateur) ;
toute modif de skill se mesure au harnais eval/ ; le board GitHub est la source de vérité.

Pattern d'exécution établi cette session (à réutiliser) : dispatcher des agents en
`isolation: "worktree"` en parallèle, chacun committant localement SANS toucher à
docs/DECISIONS.md ni pousser ; l'orchestrateur diff chaque worktree contre son VRAI parent
(pas `main` si `main` a avancé depuis le dispatch — utiliser `git diff --stat <parent-sha>
<worktree-head>`), vérifie indépendamment au moins un chiffre/claim clé (re-grep, re-run de
tests, re-parse d'un artefact), merge avec `git merge --no-ff <sha>`, s'assure du sign-off DCO
(`git commit --amend -s --no-edit` si manquant — seulement avant push), ajoute UNE entrée
DECISIONS.md avec le prochain numéro D libre, bump la version de plugin si le contenu d'une
skill a changé (jamais pour un simple README), `claude plugin validate --strict .`, push,
commente + ferme (ou laisse honnêtement ouvert) l'issue GitHub, nettoie le worktree
(`git worktree remove --force` puis `git branch -D` — un verrou Windows résiduel se résout en
retentant après quelques secondes, rarement besoin de tuer un process node.exe).

Travaille en autonomie par sprints : une modif → validation --strict → mesure au harnais
→ commit signé → push sur main (déjà autorisé explicitement par le fondateur cette session
pour du travail vérifié). Pas de PR sans demande explicite.

Vérifie d'abord si `.env` contient toujours des credentials valides pour Gemini/Groq/HF/
Mistral avant de relancer `multi_model_generate.py`/`second_judge.py`, et si
GITHUB_PERSONAL_ACCESS_TOKEN est toujours valide dans ~/.claude/settings.json avant de
compter sur le connecteur GitHub MCP (`plugin:github:github`).

Le gold set IATS confidentiel (~88 US) reste abandonné pour de bon (D49) ; ne pas relancer de
nouveaux lots du corpus élargi 24 cas sans demande explicite (D58-D64, plan épuisé).
```
