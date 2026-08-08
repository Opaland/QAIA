# Ce que QAIA couvre du métier de test, et ce qu'elle ne couvre pas (2026-08-08)

Établi en cartographiant les **skills réellement présentes** dans `plugins/` — 30 le matin du
2026-08-08, **33** le soir, les trois ajoutées étant précisément trois trous de cette carte — contre le
processus de test ISTQB (CTFL ch. 1 et 5), les **niveaux** de test (ch. 2.2) et les **types** de
test (ch. 2.3). Aucune case n'est cochée sur une intention : une case est verte quand une skill
existe et porte le sujet.

## 1. Le processus de test

| Phase ISTQB | Couverture | Skills |
|---|---|---|
| Planification | **couverte** | `test-plan-and-closure` — dérivé des artefacts, jamais d'un gabarit |
| Pilotage et contrôle | partielle | `report`, `run-report`, `aptitude-gate` |
| Analyse | **couverte** | `us-ingest`, `openapi-ingest`, `us-review`, `need-understanding`, `istqb-design` |
| Conception | **couverte** | `istqb-design`, `testbook-generate`, `oracle-generate`, `prioritize` |
| Implémentation | **couverte** | `automate`, `dataset-generate` |
| Exécution | **couverte** | `automate`, `a11y-audit`, `perf-check`, `visual-check`, `security-surface` |
| Clôture | **couverte** | `test-plan-and-closure` + `report` — le bilan nomme d'abord ce qui reste ouvert |

**Le trou le plus visible est aux deux bouts.** QAIA commence à la user story et s'arrête au
rapport d'exécution. Un responsable de test commence par un **plan de test** et finit par un
**bilan** — deux livrables qu'on ne sait pas produire.

## 2. Les niveaux de test

| Niveau | Couverture | Commentaire |
|---|---|---|
| Composant (unitaire) | **hors périmètre, décidé** | [ADR 0004](adr/0004-test-level-boundary.md) : QAIA part d'une promesse observable de l'extérieur. Un test unitaire s'écrit contre une fonction, donc contre l'implémentation — c'est abandonner l'oracle qui fait la valeur du reste. |
| Intégration | **absente en tant que telle** | `contract-probe` en approche une partie par le contrat, sans jamais nommer l'intégration |
| Système | **couverte** | c'est le cœur du produit |
| Acceptation | partielle | on produit le cahier ; personne ne pilote une recette humaine |

## 3. Les types de test

| Type | Couverture | Skills |
|---|---|---|
| Fonctionnel | **couvert** | toute la chaîne |
| Performance | partiel | `perf-check` (budgets de latence, CT-PT) — pas de charge réelle |
| Sécurité | partiel | `security-surface` (passif, CT-SEC) |
| Accessibilité | **couvert** | `a11y-audit` (WCAG 2 A/AA) |
| Utilisabilité | **couvert** | `usability-heuristic-review` (CT-UT) |
| Visuel | **couvert** | `visual-check` |
| Compatibilité (navigateurs, appareils) | **absente** | aucune skill ne nomme le sujet |
| Structurel (boîte blanche, couverture de code) | **absente** | aucune skill ne part de la couverture |
| Confirmation (re-test après correction) | **couvert** | `confirm-fix` — trois verdicts, et le troisième jamais rapporté comme le premier |
| Régression | **couvert** | `traffic-replay`, `flaky-detect`, `impact-select` (depuis un diff) |

## 4. Les trous, classés par ce qu'ils coûtent à un vrai utilisateur

**1. ~~Le rapport de défaut.~~** **Comblé le 2026-08-08** — `qaia-playwright:defect-report`,
éprouvée contre un ticket écrit par un humain sur le même défaut
([#1551](https://github.com/typicode/json-server/issues/1551)). Aucun des deux rapports ne domine :
l'humain gagne sur la cause parce qu'il a lu le code, la machine sur la reproduction et la
traçabilité.

**2. ~~La sélection des tests à partir d'un diff.~~** **Comblé le 2026-08-08** —
`qaia-playwright:impact-select`, avec sa mesure : sur une faute injectée pour de vrai dans
`examples/expense-demo`, la lecture naïve rate **6 impacts sur 10** et la lecture transitive n'en
rate aucun (`eval/impact-select-2026-08-08/`).

**3. ~~OpenAPI / Swagger comme source d'exigence.~~** **Comblé le 2026-08-08** —
`qaia-core:openapi-ingest`, deuxième porte d'entrée de la chaîne. Appliquée à une vraie
spécification, elle y a trouvé **les quatre classes de contradiction** qu'elle cherche
(`eval/openapi-ingest-2026-08-08/`).

**4. ~~Le niveau composant.~~** Tranché le 2026-08-08 : hors périmètre, [ADR 0004](adr/0004-test-level-boundary.md). Ce n'est plus un trou, c'est une frontière déclarée.

**5. ~~Le plan de test et le bilan.~~** **Comblé le 2026-08-08** — `test-plan-and-closure`, appliquée à une campagne *déjà terminée* pour qu'aucune section ne puisse être ajustée pour bien paraître (`eval/external-application-2026-08-08/closure-report.md`). *(Le test de confirmation, qui figurait aussi dans cette liste, est comblé : `confirm-fix`.)*

**6. ~~L'anonymisation de données réelles.~~** **Écartée le 2026-08-08** ([#81](https://github.com/QAIA-Project/QAIA/issues/81)),
et c'est une frontière, pas un trou. Le critère est la **vérifiabilité**, pas la difficulté : toutes
les autres skills produisent quelque chose qu'un tiers peut recouper, alors qu'une anonymisation ne
se vérifie qu'en tentant de ré-identifier — ce qui demande le jeu d'origine, des données
auxiliaires et une méthode, dont QAIA ne dispose d'aucun. Une skill qui anonymise mal est pire
qu'aucune skill : elle donne la confiance sans la propriété.

**7. Compatibilité navigateurs et appareils.** Playwright le fait nativement ; aucune skill ne
guide personne dessus.

## 5. Ce que cette carte ne dit pas

Elle mesure la **présence** d'une skill, pas sa **qualité**. Une case verte veut dire « le sujet
est porté », pas « c'est bien fait ». Sur les 33 skills, **trois** ont été appliquées à un logiciel
ou à un document que nous n'avons pas écrit — `automate` et `defect-report` sur json-server,
`openapi-ingest` sur la spécification Petstore — et **aucune n'a jamais été utilisée par un humain
dans son travail réel**. C'est toujours l'inconnue n°1, et trois skills de plus n'y changent
rien.
