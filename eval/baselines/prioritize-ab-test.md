# Test A/B sur `prioritize` — un exemple chiffré ajouté vs formulation actuelle

*2026-07-24 ter, suite 6. Demande fondateur (prompt management) : les skills manquent
d'exemples inline, testons si en ajouter un améliore réellement la calibration.*

## Méthode

Même jeu de 8 conditions dures (facturation médicale régulée, mélange sécurité/cosmétique/
`[assumption]`/`[open]`), deux runs isolés en parallèle, sans contexte partagé :

- **Variant A** : formulation actuelle de `prioritize` (aucun exemple chiffré).
- **Variant B** : formulation actuelle + un exemple chiffré calibré (règle de rejet de
  facturation → impact 3, probabilité 2, P1 ; contraste avec un cas cosmétique → P3 malgré
  probabilité élevée, plafonné par l'impact).

## Résultat — 7/8 conditions identiques, 1 divergence significative

| Condition | Variant A | Variant B |
|---|---|---|
| AC1-C1, AC1-C2, AC2-C1, AC3-C1, AC6-C1, AC7-C1 | identique | identique |
| AC4-C1 (cosmétique) | P3 (prob. 2) | P3 (prob. 1) — même bande malgré le score brut différent |
| **AC5-C1 (auth billing)** | **P2** (impact 3, **prob. 1** — "vérification standard framework") | **P1** (impact 3, **prob. 2** — "chemin négatif documenté") |

**La seule vraie divergence change la bande de priorité** (P2 → P1) sur un contrôle
d'authentification générique.

## Diagnostic — l'exemple a sur-généralisé, pas amélioré

L'exemple portait sur une règle métier **spécifique** (rejet de facturation par secteur non
conventionné). Variant B a repris sa justification quasi mot pour mot ("chemin de
refus/négatif documenté") et l'a appliquée à **un contrôle d'authentification générique** —
alors que ce type de vérification est justement l'archétype du cas *bien compris, peu
propice aux défauts* que la règle originale ("stable well-understood rules → probabilité
plus basse") visait à distinguer. L'exemple a ancré le modèle sur un pattern de surface
("chemin négatif = probabilité plus haute") au lieu de le laisser raisonner sur la vraie
variable pertinente (nouveauté/complexité de la logique), qui est ce que demandait déjà la
règle sans exemple.

## Décision

**Ne pas appliquer cet exemple à `prioritize/SKILL.md` tel quel** — il dégraderait la
calibration sur ce cas précis, pas l'améliorerait. Refaire l'exemple en le scopant
explicitement ("une règle métier spécifique — pas un contrôle d'auth générique bien
compris") serait possible, mais reste à faire et re-tester avant d'être mérité.

## Ce que ça prouve sur la méthode elle-même

Un vrai test A/B (même input, deux formulations, en parallèle, diff direct) a détecté un
effet de bord plausible mais faux qu'une simple relecture n'aurait pas révélé — "ajouter un
exemple, ça aide" est une intuition, pas une garantie ; elle se mesure comme le reste.
