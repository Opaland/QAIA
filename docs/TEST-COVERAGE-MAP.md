# Ce que QAIA couvre du métier de test, et ce qu'elle ne couvre pas (2026-08-08)

Établi en cartographiant les **30 skills réellement présentes** dans `plugins/` contre le
processus de test ISTQB (CTFL ch. 1 et 5), les **niveaux** de test (ch. 2.2) et les **types** de
test (ch. 2.3). Aucune case n'est cochée sur une intention : une case est verte quand une skill
existe et porte le sujet.

## 1. Le processus de test

| Phase ISTQB | Couverture | Skills |
|---|---|---|
| Planification | **absente** | — |
| Pilotage et contrôle | partielle | `report`, `run-report`, `aptitude-gate` |
| Analyse | **couverte** | `us-ingest`, `us-review`, `need-understanding`, `istqb-design` |
| Conception | **couverte** | `istqb-design`, `testbook-generate`, `oracle-generate`, `prioritize` |
| Implémentation | **couverte** | `automate`, `dataset-generate` |
| Exécution | **couverte** | `automate`, `a11y-audit`, `perf-check`, `visual-check`, `security-surface` |
| Clôture | **quasi absente** | `report` produit un manifeste ; rien n'archive ni ne capitalise |

**Le trou le plus visible est aux deux bouts.** QAIA commence à la user story et s'arrête au
rapport d'exécution. Un responsable de test commence par un **plan de test** et finit par un
**bilan** — deux livrables qu'on ne sait pas produire.

## 2. Les niveaux de test

| Niveau | Couverture | Commentaire |
|---|---|---|
| Composant (unitaire) | **absente** | Aucune skill n'écrit ni n'analyse de test unitaire. C'est pourtant le niveau où vivent la majorité des tests d'un vrai dépôt. |
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
| Confirmation (re-test après correction) | **absente** | on ne sait pas fermer la boucle d'un défaut |
| Régression | partiel | `traffic-replay`, `flaky-detect` — rien qui parte d'un **diff** |

## 4. Les trous, classés par ce qu'ils coûtent à un vrai utilisateur

**1. Le rapport de défaut.** Le livrable quotidien d'un testeur. QAIA n'en produit aucun. Elle
sait dire qu'un test est rouge ; elle ne sait pas écrire ce qu'un développeur doit lire pour
corriger. C'est le manque le plus embarrassant du catalogue.

**2. La sélection des tests à partir d'un diff.** Quels tests rejouer, lesquels vont casser, où
manque la couverture. **Un diff, un développeur en a un tous les jours ; une user story, une fois
par sprint.** Notre porte d'entrée est la plus rare des deux. Déjà relevé en lisant QA Orchestra,
qui a cette skill et pas nous.

**3. OpenAPI / Swagger comme source d'exigence.** `contract-probe` part d'une documentation en
prose. La plupart des API réelles ont une spécification formelle, lisible par machine. On l'ignore
— alors que la campagne json-server vient de montrer que **partir du contrat plutôt que du code
est exactement ce qui trouve les vrais défauts**.

**4. Le niveau composant.** Zéro skill. Toute la valeur est en système et en bout de chaîne.

**5. Le plan de test et le bilan.** Les deux artefacts qu'un responsable de test doit signer.

**6. L'anonymisation de données réelles.** `dataset-generate` fabrique du synthétique. Prendre un
jeu de production et le rendre utilisable est un autre problème, très demandé, réglementé.

**7. Compatibilité navigateurs et appareils.** Playwright le fait nativement ; aucune skill ne
guide personne dessus.

## 5. Ce que cette carte ne dit pas

Elle mesure la **présence** d'une skill, pas sa **qualité**. Une case verte veut dire « le sujet
est porté », pas « c'est bien fait ». Sur les 30 skills, une seule a été appliquée à un logiciel
que nous n'avons pas écrit (`eval/external-application-2026-08-08/`), et aucune n'a été utilisée
par un humain dans son travail réel.
