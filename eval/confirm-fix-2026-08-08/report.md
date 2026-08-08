# Confirmer une correction : le verdict naïf est faux, et il l'est de la pire façon

Fermer un défaut demande de rejouer le test qui l'a prouvé — et de vérifier que rien d'autre n'a
bougé. La deuxième moitié est celle que personne ne fait, et c'est celle qui coûte.

Éprouvé sur un cas entièrement public : le défaut `_dependent` de `typicode/json-server`, trouvé
par QAIA depuis la documentation seule (`eval/external-application-2026-08-08/`), corrigé par le
mainteneur au commit `1b7c0fb`. Les deux versions sont publiques, donc **n'importe qui peut
refaire cette confirmation**.

## Les deux exécutions

Même suite, 32 scénarios, jamais modifiée entre les deux.

| | Version | Verts | Rouges |
|---|---|---|---|
| **Avant** | `8fb0f72`, alpha.23, mai 2024 | 29 | 3 |
| **Après** | `89a34a4`, beta.15, mars 2026 | 28 | 4 |

**En agrégat : un vert de moins.** C'est tout ce qu'un compteur dit, et c'est faux dans les deux
sens.

## La comparaison test par test

Les quatre transitions possibles sont toutes présentes dans ce seul cas, ce qui en fait un jeu de
mesure inhabituellement complet. Données brutes : `transitions.json`.

| Avant → Après | Nombre | Scénarios |
|---|---|---|
| vert → vert | 26 | inchangés |
| **rouge → vert** | **2** | `@QAIA-EXT-019`, `@QAIA-EXT-030` |
| rouge → rouge | 1 | `@QAIA-EXT-022` |
| **vert → rouge** | **3** | `@QAIA-EXT-021`, `@QAIA-EXT-023`, `@QAIA-EXT-032` |

## Ce que le verdict naïf donnerait

`@QAIA-EXT-030` est le test qui prouvait le défaut. Il passe de rouge à vert. Trois tests passent
de vert à rouge.

> Verdict naïf : **fermé avec dégâts collatéraux — 3 régressions.**

**Et il est faux.** Aucun de ces trois n'est une régression.

## L'étape que le verdict naïf saute

`check_requirement_drift.py` répond en une commande : la source d'exigence a-t-elle bougé entre les
deux versions ?

Elle a bougé. `_limit`, `_start`/`_end` et le filtrage par indice de tableau ont été **retirés de
la documentation** entre mai 2024 et mars 2026 — `_limit` y est même explicitement marqué
*deprecated*.

Les trois tests qui tombent sont exactement ceux-là. **Le code a raison, les tests sont périmés.**

> Verdict réel : **fermé.** Deux défauts corrigés, aucun dégât collatéral, trois tests à retirer
> parce que leur promesse n'existe plus.

Deux verdicts opposés à partir des mêmes chiffres. La différence tient à une seule vérification.

## Les deux autres constats, à ne pas laisser passer

**`@QAIA-EXT-019` passe aussi de rouge à vert — et ce n'était pas le test qui prouvait le défaut.**
Un `rouge → vert` non demandé mérite autant de suspicion qu'un `vert → rouge` : quelque chose a
changé que le rapport d'anomalie ne décrivait pas. Ici l'explication est connue — c'est un second
défaut, corrigé séparément par le mainteneur au commit `e6055e6`. Mais elle a dû être **cherchée**,
pas supposée.

**`@QAIA-EXT-022` reste rouge.** Il ne fait partie d'aucun verdict : le rapport de la campagne le
compte comme **contesté**, parce que le README ne montre `_start` qu'en paire et que le test
extrapole. Un test contesté n'entre pas dans une confirmation — sinon il maintient ouvert un défaut
qui n'en est peut-être pas un.

## Ce que cette mesure institue

1. **Une confirmation exige deux exécutions.** Avec une seule, « ce test est vert » ne dit rien de
   ce que le changement a coûté.
2. **Comparer test par test, jamais en agrégat.** Ici l'agrégat dit « un vert de moins » et cache
   deux corrections, trois péremptions et une contestation.
3. **Vérifier la dérive d'exigence avant de crier à la régression.** C'est la vérification qui
   retourne complètement le verdict, et elle coûte une commande.

## Limites

- **Un seul cas.** Complet — les quatre transitions y sont — mais un seul.
- **Vingt-deux mois entre les deux versions.** Une confirmation réelle porte sur un correctif de
  quelques jours ; l'écart ici est ce qui rend la dérive d'exigence visible, donc le cas est
  favorable à la démonstration.
- **La dérive est détectée au niveau du document, pas de la promesse.** L'outil dit que la source a
  bougé ; c'est un humain qui a lu ce qui avait disparu.
