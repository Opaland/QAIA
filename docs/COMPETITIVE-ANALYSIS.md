# Veille concurrentielle — QAIA (2026-07-25)

Demande fondateur (D67, mandat élargi post-M0) : regarder ce qui existe déjà sur le marché
dans l'espace "IA agentic pour le test logiciel" avant de remodeler le backlog. Recherche web
réelle (WebSearch/WebFetch, ~10 sources), pas de mémoire — le terrain évolue vite.

**Limites assumées** : plusieurs sources sont des articles de blog marketing (TestQuality,
Shiplight AI, QASkills.sh, Agensi.io) dont l'indépendance éditoriale n'est pas vérifiée — à
lire comme indicatif, pas comme benchmark neutre.

**Vérification (2026-07-25, sprint 20)** : le chiffre `~421★` cité pour `agentic-qe` avait été
noté comme non revérifié avant citation publique (`README.md` le cite). Re-fetch direct de
`github.com/proffesor-for-testing/agentic-qe` : **421 étoiles, 75 forks, licence MIT confirmée**
— le chiffre initial était exact, pas une fabrication. Fork count (75) ajouté ici car jamais
publié avant.

## Paysage concurrentiel

1. **Agentic QE Fleet** (`proffesor-for-testing/agentic-qe`, MIT, ~421★) — le concurrent le
   plus direct trouvé. Open source, natif Claude Code (+ 11 plateformes dont Cursor, Copilot,
   Cline), génère des tests multi-frameworks (Jest, Playwright, pytest…), inclut un
   générateur BDD, une détection de flaky tests, un "quality-gate" anti-sycophantie (rejette
   les assertions creuses type `expect(true).toBe(true)`), et un orchestrateur "Queen
   Coordinator" à 60 agents spécialisés qui s'exécutent automatiquement. Nécessite une clé
   API LLM (Claude/OpenAI/Gemini/Ollama), avec un mode "free-tier" vers des modèles locaux.
   Auto-enregistre un serveur MCP. Revendique explicitement le shift-left, touche aussi au
   shift-right (load/chaos testing).
2. **TestQuality / TestStory.ai** — SaaS, convertit des user stories en scénarios Gherkin,
   intégration native GitHub/Jira, positionné "agentic QA" vs les "anciens outils IA
   autocomplete".
3. **SaaS IA-natifs établis** (testRigor, Mabl, Functionize, Applitools, ACCELQ, Tricentis
   Tosca) — DSL en anglais courant ou low-code, self-healing de locators, visual AI
   (Applitools), model-based testing (Tosca). Tous SaaS/cloud, pricing $60-300/mois en entrée
   ou vente enterprise.
4. **Frameworks OSS d'automatisation navigateur pilotés par LLM** (BrowserUse, Stagehand,
   Skyvern — AGPL-3.0, Midscene.js, Shortest, Magnitude, Passmark) — tous nécessitent une clé
   API LLM au runtime, "OSS-client-only" : les données transitent vers un fournisseur externe.
   Aucun ne fait de Gherkin/BDD ni de scoring séparé selon la synthèse trouvée.
5. **Écosystème Playwright officiel** — Playwright MCP (Microsoft, open source, primitives de
   navigation) et Playwright Test Agents (planification + génération + réparation de
   sélecteurs), self-hosted, aucun mécanisme de scoring propre.
6. **Marketplaces de skills Claude Code génériques** (QASkills.sh, Agensi.io) — dizaines de
   skills étroits et indépendants (playwright-e2e, vitest, pytest, a11y, k6,
   contract-testing…), sans clé API mentionnée, mais **aucun ne fait Gherkin/BDD depuis des
   US ni de scoring** — des générateurs de tests techniques, pas un parcours métier complet.
7. **Outsourcing managé** (QA Wolf) et **outils API/backend** (Keploy — Apache-2.0, tests
   depuis du trafic réel enregistré ; EvoMaster — LGPL, tests évolutionnaires sans LLM).
8. **ISTQB CT-GenAI** (certification, pas un outil) — cadre normatif "Testing with Generative
   AI" (v1.1, avril 2026) qui légitime les techniques de conception assistées par IA et la
   gestion des risques (hallucination, biais) — un référentiel auquel QAIA pourrait se
   rattacher explicitement.

Sources : [Agentic QE Fleet](https://github.com/proffesor-for-testing/agentic-qe),
[TestQuality — Claude Code pour QA](https://testquality.com/agentic-testing-qa-claude-code/),
[TestQuality — Agentic QA](https://testquality.com/the-shift-to-agentic-qa-beyond-automated-testing-to-autonomous-ai-generation-in-2026/),
[Shiplight — 8 plateformes comparées](https://www.shiplight.ai/blog/best-agentic-qa-tools-2026),
[Autonoma — outils OSS de génération de tests](https://getautonoma.com/blog/open-source-ai-test-generation-tools-2026),
[QASkills.sh](https://qaskills.sh/blog/best-claude-code-skills-for-testing-2026),
[Agensi.io](https://www.agensi.io/learn/best-qa-testing-skills-claude-code-2026),
[ISTQB CT-GenAI](https://istqb.org/istqb-certified-tester-specialist-level-testing-with-generative-ai-ct-genai-press-release/),
[Gherkin guidelines for AI](https://github.com/AutomationPanda/gherkin-guidelines-for-ai).

## Angles morts de QAIA (vérifiés contre `plugins/qaia-*/skills/`)

- **Détection de flaky tests** : absente chez QAIA, présente chez Agentic QE Fleet et évoquée
  comme catégorie de skills chez QASkills.sh.
- **Priorisation risque data-driven** : `prioritize` est un score probabilité×impact arbitré
  par l'humain, sans ingestion automatique d'historique de défauts/changements de code.
- **Génération depuis trafic de production réel** (shift-right "fort", type Keploy) :
  `perf-check`/`security-surface`/`a11y-audit` sont des vérifications actives, pas une
  capture-rejeu de trafic réel.
- **Self-healing de sélecteurs / correctifs proposés en diff PR** (Shiplight, Playwright Test
  Agents) : aucun mécanisme de réparation automatique de locators cassés.
- **Round-trip avec outils de gestion de tests** (Jira, TestRail, Xray) : `testbook-export`
  produit `.feature` + XLSX + Markdown, pas de push API direct.
- **Orchestration multi-agents parallèle** (Queen Coordinator à 60 agents) : QAIA reste un
  parcours de skills séquentiel invoqué par l'utilisateur/agent, pas un essaim autonome —
  choix assumé (D33), pas un manque.
- **Visual AI perceptuelle** (Applitools) : `visual-check` existe mais rien ne confirme un
  moteur de diff perceptuel équivalent — à vérifier en interne.

## Différenciation réelle de QAIA (pas juste marketing)

- **Zéro clé API dans le produit livré, zéro exécution automatique de hooks/agents/MCP** — la
  différence structurelle la plus nette. Tous les concurrents OSS trouvés exigent une clé LLM
  au runtime et/ou auto-enregistrent un serveur MCP qui s'exécute. QAIA en 100% skills
  Markdown invoqués à la demande est une posture de sécurité/portabilité distincte, pas
  retrouvée ailleurs dans le paysage exploré.
- **Score déterministe séparé du générateur, "aucun producteur ne s'auto-note"** : Agentic QE
  Fleet a un quality-gate qui s'en rapproche, mais c'est un agent parmi d'autres dans le même
  essaim, pas un plugin isolé et optionnel.
- **Shift-left + shift-right combinés dans un même parcours skill-first, humain-arbitré** :
  Agentic QE Fleet le revendique aussi mais via exécution agentique autonome ; QAIA le fait
  via un parcours explicite US → Gherkin → automatisation → score, plus proche de l'esprit
  ISTQB CT-GenAI ("l'IA propose, l'humain décide" — cf. `prioritize`).

## Pistes de backlog (classées par valeur probable, converties en issues GitHub)

1. Doc de positionnement explicite vs Agentic QE Fleet et le paysage concurrentiel.
2. Détection de flaky tests (post-hoc, sur logs CI).
3. Export natif vers formats de gestion de tests (Xray/Jira, TestRail).
4. Priorisation risque enrichie par historique (git blame / fréquence de modification),
   restant "propose, humain décide".
5. Suggestion de réparation de locators cassés en diff proposé (jamais auto-appliqué).
6. Mapping explicite des skills vers le syllabus ISTQB CT-GenAI.
7. Skill de capture/rejeu de trafic réel → conditions de test (shift-right fort).
8. Vérifier/renforcer `visual-check` face au standard "visual AI perceptuel".
9. Lint anti-assertions-creuses dans `qaia-playwright` — à garder strictement séparé de
   `qaia-score` pour ne pas contredire "aucun producteur ne s'auto-note".
10. Bridge MCP optionnel pour Cursor/Copilot, sans casser "zéro clé API dans le cœur".

## Veille élargie hors médical, recherche globale (2026-07-26)

Demande fondateur : sortir explicitement du seul angle médical/réglementé et regarder plus large
— GitHub (recherche directe de dépôts, pas seulement les noms déjà connus) et le web en général.

**GitHub — recherche directe** (`search_repositories`, plusieurs requêtes : génération Gherkin/BDD
depuis des US, générateurs de cas de test LLM, marketplaces de plugins Claude Code pour la QA) :
aucun concurrent à l'échelle d'Agentic QE Fleet (421★, déjà connu) n'est apparu. En revanche,
**l'écosystème de plugins Claude Code dédiés QA s'est nettement densifié depuis la veille du
2026-07-25** : une douzaine de petits dépôts (0-2★, tous créés/mis à jour en 2026), par exemple
`orbit` (équipe QA WordPress à 10 agents, 116 skills), `testforge` (génération de cas de test
Azure DevOps, 3 agents, Gherkin via Claude/Gemini/Ollama), `quality-engineering-skills`
(marketplace groupant qavajs/Vividus/Tosca/ServiceNow ATF), `web-tester-marketplace` (Playwright
E2E + hooks de sécurité). Aucun ne combine génération Gherkin-depuis-US **et** score déterministe
séparé **et** preuve multi-domaine comme QAIA — mais le signal de marché est clair : la niche se
peuple vite, pas seulement chez les gros acteurs SaaS.

**Web — recherche générale** : le marché confirme sa taille (test automation ~24 Mds$ en 2026,
IA de test ~687 M$ en 2025→3,8 Mds$ visés en 2035) et une poignée de nouveaux entrants financés
(Ranger, Drizz, Skyramp) — tous des SaaS cloud nécessitant une clé API/compte, aucun ne reprend
la posture "zéro clé API, 100 % skills" de QAIA. Différenciation D67 toujours tenable.

**Une trouvaille distincte, `chaos-qa`** (`keithalindsay/chaos-qa`, très récent — créé
2026-07-21, 2 commits, 0★, vérifié directement plutôt que pris au mot d'un résumé de recherche) :
suite de skills Claude Code qui **sonde adversarialement** un projet en confrontant son
comportement réel au contrat documenté (README/aide), pas seulement « est-ce que ça plante » —
puis **convertit chaque défaut trouvé en test de régression** dans le framework existant du
projet. Aucune clé API, aucune exécution non contrôlée (skills Claude Code classiques). Angle
**complémentaire, pas concurrent direct** : QAIA part de la spécification (US → Gherkin →
automatisation, en amont), `chaos-qa` part du comportement observé d'un système déjà vivant (en
aval) — les deux directions sont utiles et ne se recouvrent pas. QAIA n'a aujourd'hui aucune
skill qui sonde activement un système en confrontant son comportement à son contrat documenté
(`security-surface` est passif/ciblé auth-erreurs, `flaky-detect` détecte la variance entre runs,
pas la conformité au contrat) — gap réel, converti en piste de backlog ci-dessous.

11. **Sondage adversarial de contrat** (README/aide → comportement réel, jamais destructif,
    self-host uniquement comme le reste du shift-right — cf. `security-surface`/D26/D35) →
    conversion des défauts trouvés en scénarios de régression Gherkin taggués. Complémentaire au
    parcours spec-first existant, pas un remplacement. Voir issue GitHub correspondante.

Voir les issues GitHub correspondantes pour le détail et le suivi.
