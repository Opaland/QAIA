# Bilan de test — campagne json-server (2026-08-08)

Produit par `test-plan-and-closure` sur une campagne **déjà terminée**, donc rien n'a pu être
ajusté pour bien paraître. Chaque section nomme la source dont elle est tirée ; là où la source
n'existe pas, la section le dit.

---

## Ce qui reste ouvert à la livraison — d'abord

Un lecteur qui s'arrête après deux paragraphes doit avoir lu la mauvaise nouvelle.

**1. Trois tests du cahier sont périmés et n'ont pas été retirés.** `@QAIA-EXT-021`,
`@QAIA-EXT-023` et `@QAIA-EXT-032` exigent des fonctionnalités **retirées de la documentation** de
la cible entre les deux versions testées. Ils échouent aujourd'hui sur la version courante, et
**le code a raison**. Tant qu'ils sont là, la suite ne peut pas être verte contre la version
actuelle. *Source : `eval/confirm-fix-2026-08-08/report.md`.*

**2. Un constat non tranché.** `@QAIA-EXT-022` (`_start` seul) échoue sur les deux versions. Il est
compté **contesté** et non défaut : le README ne montre `_start` qu'en paire, donc le test
extrapole une promesse que le document ne fait pas. **Personne n'a arbitré.** Il faudrait le
mainteneur de la cible, ou la suppression du scénario. *Source : `report.md`, section « Un
troisième échec, contesté ».*

**3. Les sept questions ouvertes du cahier sont toutes encore ouvertes.** Aucune n'a été
résolue : y répondre demande le mainteneur de la cible, pas une exécution. Observer un code de
statut dit ce que l'application *fait*, jamais ce que le contrat *promet* — et c'est la question
posée. *(La première version de ce bilan affirmait que deux d'entre elles avaient été résolues par
l'exécution. C'était faux, et contredit par l'en-tête du cahier lui-même, qui écrit « NONE is
resolved by assumption ».)* *Source :
`testbook/json-server-rest.feature`.*

**4. La question centrale n'a pas été répondue, et ne pouvait pas l'être.** Cette campagne mesure
si les tests générés attrapent des défauts réels. Elle ne dit **rien** de leur utilité pour un
ingénieur QA dans son travail : lisibilité, conventions d'équipe, temps gagné. Aucun humain n'a
utilisé QAIA ici.

---

## Périmètre réellement couvert

*Source : `testbook/json-server-rest.feature` et les deux fichiers de résultats.*

| | |
|---|---|
| Exigence | le `README.md` de `typicode/json-server` au commit `8fb0f72`, gelé dans `sources/` |
| Scénarios conçus | 32 |
| Scénarios exécutés | 32 |
| Versions du SUT testées | 2 — `8fb0f72` (mai 2024) et `89a34a4` (mars 2026) |
| Niveaux de test | système uniquement, via HTTP |
| Types de test | fonctionnel uniquement |

**Hors périmètre, délibérément :** les niveaux composant et intégration
([ADR 0004](../../docs/adr/0004-test-level-boundary.md)), et tout ce qui n'est pas fonctionnel —
aucune vérification de performance, de sécurité, d'accessibilité ni de compatibilité n'a été faite
sur cette cible.

**Hors périmètre par manque, pas par choix :** le README documente plus que ce que le cahier
couvre. Les routes `/profile` sont couvertes, le service de fichiers statiques ne l'est pas, et
aucune couverture exhaustive du document n'a été visée. **32 scénarios ne sont pas une couverture,
c'est un échantillon.**

---

## Ce qui n'a pas été couvert, et pourquoi

*Section dérivée de l'écart entre les conditions conçues et les tests exécutés.*

- **Aucune priorisation n'a été faite.** `prioritize` n'a pas été lancée sur cette campagne : les
  scénarios portent des étiquettes `@P1`/`@P2` posées à la main pendant la génération, sans
  analyse probabilité × impact. **Il n'existe donc pas d'analyse de risque pour cette campagne**,
  et toute phrase qui en présenterait une serait inventée.
- **Aucun jeu de données généré, mais la base n'est pas non plus celle du README telle quelle.**
  Elle en reprend `posts`, `comments` et `profile`, **et y ajoute une collection `foo`** sans
  laquelle les deux scénarios de filtrage imbriqué (`@QAIA-EXT-031`, `@QAIA-EXT-032`) n'ont pas de
  données — le README documente ces promesses en illustrant avec `/foo` mais ne fournit pas la
  ressource. `dataset-generate` n'a pas été utilisée ; la base réelle est archivée sous
  `db.used.json`. *(La première version de ce bilan écrivait « recopiée telle quelle » : c'était
  faux, et la procédure de reproduction publiée en héritait.)*
- **Aucune piste mutation.** Les assertions de cette suite n'ont **jamais été prouvées
  non-décoratives**, contrairement aux deux suites vitrines du dépôt. Le fait qu'elles aient
  attrapé deux vrais défauts est une preuve indirecte et partielle : elle porte sur trois
  assertions, pas sur trente-deux.

---

## Critères de sortie

Aucun plan de test n'ayant été écrit **avant** cette campagne, il n'y avait pas de critère de
sortie à vérifier. C'est en soi le principal défaut de méthode de la campagne, et il est consigné
ici plutôt que passé sous silence.

Ce qui aurait dû être écrit à l'avance, et qui ne l'a pas été : combien de scénarios pour quelle
part du document, quel taux de verts attendu sur la version d'époque, et ce qu'on décide si un
échec est contesté. **La dernière question s'est posée pour de vrai et a été tranchée après coup**
— ce qui est exactement l'ordre qu'un plan sert à éviter.

---

## Résultats, pour mémoire

*Source : `results-alpha23-2024-05.json`, `results-beta15-2026-03.json`.*

| Version | Verts | Rouges | Lecture |
|---|---|---|---|
| `8fb0f72` (mai 2024) | 29 | 3 | **2 défauts réels**, 1 contesté |
| `89a34a4` (mars 2026) | 28 | 4 | 1 contesté, **3 tests périmés de notre fait** |

Les deux défauts ont été confirmés par des correctifs intégrés en amont (`e6055e6`, écrit par le
mainteneur ; `1b7c0fb`, proposé par `wll8` — l'auteur de l'issue #1551 — et fusionné par le
mainteneur), lus **après** la génération.

---

## Ce que ce bilan ne dit pas

Il décrit une campagne menée par l'auteur de l'outil sur une cible qu'il a choisie. Le protocole
est publié pour qu'un tiers en juge — mais **ni la sélection de la cible, ni l'interprétation des
résultats n'ont été soumises à quiconque**. La règle du dépôt selon laquelle aucun producteur ne
note sa propre sortie s'applique au score structurel et au juge sémantique ; elle ne s'applique
pas, et ne peut pas s'appliquer, au choix de ce qu'on mesure.
