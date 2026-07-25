# Pilote de mesure token — `need-understanding` (issue #7, continuité `us-review`)

Contexte : `plugins/qaia-core/README.md` § "Token budget — ordre de grandeur (issue #7)" documente
une méthode de mesure (agent dédié, application fidèle et complète sur une US du gold set, chiffre
lu depuis l'infrastructure d'orchestration — jamais une auto-déclaration de l'agent) déjà appliquée
à 5 skills, plus `us-review` (6e skill, pilote séparé, mergé sur `main`, résultat pas encore
consolidé dans le tableau du README). Ce pilote applique la même méthode à `need-understanding`,
directement en continuité du checkpoint `us-review` produit pour US-002.

## Ce qui a été fait

Le fixture `eval/baselines/us-review-token-pilot/US-002/` (committé sur `main`, issue #7) contient
le run réel de `us-ingest` + `us-review` sur `eval/gold-set/US-002-dosage-validation.md` :
`00-source.md`, `01-extraction.md`, `journey.md`. **Ce worktree d'exécution n'incluait pas encore
les commits `main` portant ce fixture** (branche de travail divergée avant leur fusion) — les 3
fichiers ont donc été récupérés fidèlement (`git show <commit>:<chemin>`, contenu identique, aucune
reformulation) depuis l'historique `main` et restaurés à l'emplacement canonique attendu par le
contrat partagé, `.qaia/state/US-002/` (ignoré par git, `.gitignore:15`) — restauration d'un
prérequis déjà produit par un run réel antérieur, pas une refabrication.

`need-understanding` a ensuite été appliqué par-dessus, étape par étape, sans raccourci, suivant
`plugins/qaia-core/skills/need-understanding/SKILL.md` :

1. Portillon "rien à comprendre" évalué et explicitement écarté (8 AC, capacité réelle et
   testable — pas un non-spec).
2. Reformulation du besoin (qui / quoi / pourquoi / risque principal).
3. Chasse d'ambiguïtés AC par AC (termes non définis, unités, bornes inclusives/exclusives,
   fenêtre glissante vs calendaire, arrondi).
4. Passe adversariale par type d'AC (seuils/quantités, permissions — pas de machine à états ni de
   pagination applicable ici, noté explicitement plutôt qu'ignoré).
5. Passe croisée inter-AC (paires partageant patient/drogue/fenêtre temporelle) — 3 interactions
   résolues par composition (pas de question), documentées comme telles.
6. Passe triple-AC (0.1.3) — un triplet sécurité réelle identifié (AC3 × AC5 × AC6) résolu par
   composition ; un second triplet jugé non applicable (le domaine n'a pas d'équivalent structurel
   au motif "état protégé × filtrage × anti-divulgation" du cas de calibration US-003).
7. 8 questions numérotées (Q1-Q8), classées via l'arbre de décision 5a : 2 `[open]` (Q1 portée de
   la réduction rénale sur les seuils min/âge, Q7 timing de vérification du rôle en session), 5
   `[assumption]` (bornes, fenêtre 24h, arrondi, concurrence), 1 `[out-of-slice]` (Q8 unités,
   probablement répondu par l'US catalogue-médicament sœur, citée dans les `dependencies:` de
   `00-source.md`).
8. Validation : `simulated: default applied` sur les 5 assumptions, `simulated: no default
   applied — held open` sur les 2 open et le 1 out-of-slice (run non interactif, statut de première
   classe prévu par `skills/README.md` règle 3, comme pour `us-review`).
9. Checkpoint `02-understanding.md` écrit, `journey.md` mis à jour (`02-understanding` = done,
   prochaine étape `istqb-design`).

Base de connaissance : `.qaia/knowledge/` n'existe pas dans ce projet — mode dégradé (règle 8),
consigné dans le checkpoint ; aucune règle `BR-KB-nnn` disponible à citer.

Run réalisé en session non interactive (agent d'exécution seul, pas d'utilisateur humain
disponible pour répondre aux points ⚠ VALIDATION) — chaque point de validation est donc marqué
`simulated`, un statut explicitement prévu par le contrat partagé, pas une entorse à la méthode.

## Fixture produite

`eval/baselines/need-understanding-token-pilot/US-002/` — copie committée du run réel, écrit à son
emplacement canonique `.qaia/state/US-002/` (ignoré par git, `.gitignore:15`) :

- `00-source.md` — checkpoint `us-ingest` (prérequis, restauré depuis le fixture `us-review` mergé
  sur `main`)
- `01-extraction.md` — checkpoint `us-review` (prérequis, restauré de la même façon)
- `02-understanding.md` — checkpoint `need-understanding` (livrable mesuré par ce pilote)
- `journey.md` — ledger des trois étapes

## Résultat de la mesure de tokens — accès bloqué à ce niveau d'exécution

**Aucun chiffre de tokens n'a pu être obtenu de façon fiable et sourcée depuis ce niveau
d'exécution**, pour la même raison déjà documentée et vérifiée activement lors du pilote
`us-review` : aucune variable d'environnement ni aucun outil (direct ou différé via `ToolSearch`)
exposant un compteur de tokens/usage/coût n'est disponible à cet agent. Ceci confirme à nouveau,
pour une deuxième skill consécutive, la limite déjà documentée dans
`plugins/qaia-core/README.md` : "le chiffre rapporté est le total de tokens réellement consommé par
cet agent [...] tel que rapporté par l'infrastructure d'orchestration — pas une auto-déclaration de
l'agent lui-même". **Aucun chiffre approximatif ou inventé n'est rapporté ici** — le tableau du
README doit être consolidé par le niveau orchestrateur, qui peut avoir accès au total réel consommé
par cet agent délégué.

## Statut

Livrable produit et committé (fixture de preuve). Mesure de tokens : **non obtenue à ce niveau**,
report explicite au niveau orchestrateur. Le tableau `plugins/qaia-core/README.md` n'a **pas** été
modifié par ce pilote.
