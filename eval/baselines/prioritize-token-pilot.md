# Pilote de mesure token — `prioritize` (issue #7, portée réduite)

Contexte : `plugins/qaia-core/README.md` § "Token budget — ordre de grandeur (issue #7)" documente
une méthode de mesure (agent dédié, application fidèle et complète sur une US du gold set, chiffre
lu depuis l'infrastructure d'orchestration — jamais une auto-déclaration de l'agent) déjà appliquée
à 10 skills, `prioritize` faisant partie du solde explicitement non mesuré (`prioritize`,
`testbook-validate`, `report`, `feedback`). Ce pilote applique la même méthode à `prioritize`, sur
US-004, en continuité du fixture `istqb-design` déjà committé pour cette US
(`examples/expense-demo/qaia-journey/state/US-004/03-design.md`, run réel antérieur).

## Ce qui a été fait

Le fixture `examples/expense-demo/qaia-journey/state/US-004/` (committé, démo cross-domaine)
contient l'état complet d'un run antérieur de la démo `expense-demo` pour US-004 :
`00-source.md`, `01-extraction.md`, `02-understanding.md`, `03-design.md`, `journey.md`, ainsi
qu'un `04-priorities.md` produit par ce run antérieur.

Pour ce pilote, `00-source.md` à `03-design.md` (le prérequis de `prioritize`) plus `journey.md`
ont été copiés fidèlement, sans reformulation, vers l'emplacement canonique attendu par le contrat
partagé (`plugins/qaia-core/skills/README.md`), `.qaia/state/US-004/` (ignoré par git,
`.gitignore:15`). **Le `04-priorities.md` existant dans la fixture source a délibérément été
ignoré — ni copié, ni consulté** — pour garantir une exécution fraîche et indépendante de
`prioritize`, comme demandé : le tableau produit par ce pilote ne dérive pas du run antérieur.

`prioritize` a ensuite été appliqué par-dessus, étape par étape, sans raccourci, suivant
`plugins/qaia-core/skills/prioritize/SKILL.md` :

1. **Score proposé** pour chacune des 37 conditions de `03-design.md` (impact 1-3 × probabilité
   1-3), en lisant la logique propre à chaque condition plutôt qu'en s'appuyant sur le nombre brut
   de mentions `[req-neg]`/`[open]` — dimension impact ancrée sur le risque de contrôle financier
   propre à chaque condition (approbation non autorisée, contournement d'auto-approbation, perte
   d'un enregistrement d'audit) ; dimension probabilité ancrée sur la complexité structurelle
   (logique ré-entrante, intersection triple) et sur le statut `[open]`/`[assumption]` des
   questions de `02-understanding.md` citées par `03-design.md` (`@low-conf(Qn)`).
2. **Garde-fou "contexte réglementé" (D2) délibérément écarté** : `00-source.md` marque
   explicitement ce slice "finance/HR, non-medical", hors du niche v1 QAIA (D2, médical/réglementé)
   — la règle "impact 3 par défaut pour tout ce qui touche à la traçabilité" n'a donc **pas** été
   appliquée en bloc ; l'impact 3 reste attribué à plusieurs conditions (chaîne d'approbation,
   auto-approbation, IDOR, complétude de la piste d'audit) mais sur leur mérite propre, pas comme
   défaut automatique. Décision et justification consignées dans `04-priorities.md`.
3. **Signal git-history non utilisé** : aucun chemin de dépôt cible n'a été nommé par l'utilisateur
   pour cette session — le signal optionnel du step 1 (git log --stat) est donc explicitement
   ignoré, pas de citation `@history(...)` nulle part, conformément à la règle "ne jamais scanner un
   dépôt non nommé".
4. **Tableau de scores** : une ligne par condition, colonne rationale d'une phrase, `@low-conf(Qn)`
   reproduit pour chaque condition bâtie sur une question `02-understanding.md` — visibilité
   identique à celle exigée pour tout usage du signal git-history.
5. ⚠ VALIDATION : `simulated: default applied` sur les 37 scores (run non interactif, aucun
   arbitrage humain disponible) — statut de première classe (`skills/README.md` règle 3), chaque
   ligne listée comme en attente de revue humaine.
6. Checkpoint `04-priorities.md` écrit : **16 P1 / 12 P2 / 9 P3** (total 37, cohérent avec le
   compte de `03-design.md`). `journey.md` mis à jour — la ligne `04-priorities` reflète ce run
   frais et indépendant (16/12/9), distincte de la ligne `05/06` héritée de l'ancien run (marquées
   "not run in this pass", conservées pour l'historique uniquement, non dérivées de ce
   `04-priorities.md`).

Base de connaissance : `.qaia/knowledge/` n'existe pas dans ce projet — mode dégradé (règle 8),
déjà consigné dans `03-design.md` ; aucune règle `BR-KB-nnn` disponible à citer, confirmé de
nouveau dans `04-priorities.md`.

## Écart avec le run antérieur (attendu, pas une correction)

Le `04-priorities.md` du fixture source (non copié, ignoré par consigne) rapportait 18 P1 / 15 P2 /
4 P3 pour le même `03-design.md` — un autre run, une autre passe de scoring, sans graine partagée.
Ce pilote rapporte 16 P1 / 12 P2 / 9 P3. Les deux ne sont pas comparés ligne à ligne ici (l'un
n'a délibérément pas été lu pendant la production de l'autre) ; l'écart illustre la variance
attendue d'un scoring risque non déterministe plutôt qu'une divergence à corriger.

## Fixture produite

`eval/baselines/prioritize-token-pilot/US-004/` — copie committée du run réel, écrit à son
emplacement canonique `.qaia/state/US-004/` (ignoré par git, `.gitignore:15`) :

- `00-source.md` — checkpoint `us-ingest` (prérequis, copié depuis le fixture démo)
- `01-extraction.md` — checkpoint `us-review` (prérequis, idem)
- `02-understanding.md` — checkpoint `need-understanding` (prérequis, idem)
- `03-design.md` — checkpoint `istqb-design` (prérequis, idem, 37 conditions)
- `04-priorities.md` — checkpoint `prioritize` (**livrable mesuré par ce pilote**, exécution
  fraîche et indépendante, 16 P1 / 12 P2 / 9 P3)
- `journey.md` — ledger des cinq étapes, ligne `04-priorities` mise à jour pour ce run

## Résultat de la mesure de tokens — accès bloqué à ce niveau d'exécution

**Aucun chiffre de tokens n'a pu être obtenu de façon fiable et sourcée depuis ce niveau
d'exécution**, pour la même raison déjà documentée et vérifiée activement lors des pilotes
précédents (`us-review`, `need-understanding`, `oracle-generate`) : aucune variable d'environnement
ni aucun outil (direct ou différé via `ToolSearch`) exposant un compteur de tokens/usage/coût n'est
disponible à cet agent. **Aucun chiffre approximatif ou inventé n'est rapporté ici** — le tableau du
README doit être consolidé par le niveau orchestrateur, qui reçoit le champ `subagent_tokens` à la
notification de fin de tâche de cet agent délégué et peut ainsi lire le total réel consommé, un
cran au-dessus de ce niveau d'exécution.

## Statut

Livrable produit et committé (fixture de preuve). Mesure de tokens : **non obtenue à ce niveau**,
report explicite au niveau orchestrateur. Le tableau `plugins/qaia-core/README.md` n'a **pas** été
modifié par ce pilote, ni `docs/DECISIONS.md`.
