# Pilote de mesure token — `us-review` (issue #7)

Contexte : `plugins/qaia-core/README.md` § "Token budget — ordre de grandeur (issue #7)" documente
une méthode de mesure (agent dédié, application fidèle et complète sur une US du gold set, chiffre
lu depuis l'infrastructure d'orchestration — jamais une auto-déclaration de l'agent) déjà appliquée
à 5 skills. Ce pilote applique la même méthode à `us-review`, sixième skill.

## Ce qui a été fait

Aucune US du gold set n'avait de `01-extraction.md` (ou même de `00-source.md`) déjà présent dans
ce worktree — `.qaia/state/` n'existait pas. Prérequis exécuté d'abord : `us-ingest` sur
`eval/gold-set/US-002-dosage-validation.md` (la même US que la mesure déjà rapportée pour
`us-ingest`, 44,9k, pour rester dans la continuité du corpus déjà utilisé), puis `us-review`
appliqué par-dessus, étape par étape, sans raccourci, suivant
`plugins/qaia-core/skills/us-review/SKILL.md` :

1. Structuration de la capture (story / 8 AC numérotés / règles métier hors liste d'AC / artefacts
   référencés / contenu non classable).
2. Diff mentality : ce qui n'a explicitement PAS été trouvé (pas de seuils numériques concrets, pas
   de texte d'erreur, pas de politique de rétention pour la piste d'audit, dépendances externes
   listées dans `00-source.md`). Portillon "non-spec" évalué et explicitement écarté (US-002 décrit
   une capacité réelle et testable).
3. Validation utilisateur : `simulated: default applied` (run non interactif, statut de première
   classe prévu par `skills/README.md` règle 3).
4. Checkpoint écrit, `journey.md` mis à jour (`01-review` = done, prochaine étape
   `need-understanding`).

Run réalisé en session non interactive (agent d'exécution seul, pas d'utilisateur humain
disponible pour répondre aux points ⚠ VALIDATION) — chaque point de validation est donc marqué
`simulated: default applied`, un statut explicitement prévu par le contrat partagé, pas une
entorse à la méthode.

## Fixture produite

`eval/baselines/us-review-token-pilot/US-002/` — copie committée du run réel, initialement écrit à
son emplacement canonique `.qaia/state/US-002/` (ignoré par git, `.gitignore:15`) :

- `00-source.md` — checkpoint `us-ingest` (prérequis)
- `01-extraction.md` — checkpoint `us-review` (livrable mesuré)
- `journey.md` — ledger des deux étapes

## Résultat de la mesure de tokens — accès bloqué à ce niveau d'exécution

**Aucun chiffre de tokens n'a pu être obtenu de façon fiable et sourcée depuis ce niveau
d'exécution.** Vérifié activement, pas supposé :

- Aucune variable d'environnement liée à un compteur de tokens/usage/coût n'est exposée à l'agent
  (`env | grep -i token|usage|cost` ne remonte que `CLAUDE_CODE_SESSION_ID`, `CLAUDE_PID`,
  `CLAUDE_EFFORT`, rien relatif à une consommation).
- Aucun outil (direct ou différé via `ToolSearch`) exposant un compteur de tokens n'est disponible
  dans la liste d'outils accessible à cet agent.

Ceci est **cohérent avec la limite déjà documentée** dans `plugins/qaia-core/README.md` : "le
chiffre rapporté est le total de tokens réellement consommé par cet agent [...] tel que rapporté
par l'infrastructure d'orchestration — pas une auto-déclaration de l'agent lui-même, qui n'a aucun
accès fiable à son propre compteur". Ce pilote confirme empiriquement cette limite pour
`us-review` : elle a été retrouvée indépendamment, pas seulement supposée. **Aucun chiffre
approximatif ou inventé n'est rapporté ici** — le tableau du README doit être consolidé par le
niveau orchestrateur, qui peut avoir accès au total réel consommé par cet agent délégué (là où cet
agent, lui, n'a pas accès à son propre total).

## Statut

Livrable produit et committé (fixture de preuve). Mesure de tokens : **non obtenue à ce niveau**,
report explicite au niveau orchestrateur. Le tableau `plugins/qaia-core/README.md` n'a **pas** été
modifié par ce pilote.
