# Première application de QAIA à un logiciel que nous n'avons pas écrit (2026-08-08)

Tout ce que ce projet mesure, il le mesure sur du code qu'il a lui-même produit. La question
restée ouverte depuis le début : **est-ce que ça trouve quelque chose sur du vrai logiciel ?**

Cible : [`typicode/json-server`](https://github.com/typicode/json-server) — 74 000 étoiles, un
serveur REST qui transforme un fichier JSON en API. Choisi parce qu'il tourne sans base de
données externe et surtout parce qu'il a **un contrat public et antérieur** : son README.

## Le protocole, et pourquoi il est construit ainsi

| Étape | Ce qui a été fait |
|---|---|
| Exigence | Le `README.md` du dépôt au commit `8fb0f72` (2024-05-13). **Rien d'autre.** |
| Génération | Cahier Gherkin de 32 scénarios, puis suite Playwright API — sans jamais lire le code, les tests, les tickets ni les correctifs du projet cible |
| Version A | `8fb0f72`, alpha.23, mai 2024 — la version que le README décrit |
| Version B | `89a34a4`, beta.15, mars 2026 — la version courante |
| Verdict | Un test rouge en A et vert en B désigne un **défaut réel, corrigé depuis** |

La logique : si un test écrit depuis la documentation seule tombe sur la version d'époque et
passe une fois que le mainteneur a corrigé, alors ce test aurait attrapé le défaut **le jour où
il est parti en production**. Ce n'est pas une note qu'on s'attribue : c'est vérifiable par
n'importe qui avec deux `git checkout`.

## Résultat

**Version A (mai 2024) : 29 tests verts sur 32, 3 rouges.**

### Deux défauts réels, confirmés par le mainteneur lui-même

**`@QAIA-EXT-019` — deux conditions sur le même champ ne se combinent pas.**
`GET /posts?views_gt=100&views_lt=300` renvoyait **les deux posts** au lieu du seul post 2.
Cause, lue *après* la génération dans le correctif `e6055e6` (2024-08-19) :

```diff
- const conds: Record<string, [Condition, string | string[]]> = {}
+ const conds: [string, Condition, string | string[]][] = []
...
- conds[field] = [op, value]
+ conds.push([field, op, value])
```

Les conditions étaient stockées dans un dictionnaire **indexé par nom de champ**. Une deuxième
condition sur le même champ écrasait la première. Seul `views_lt=300` survivait — et les deux
posts le satisfont. Corrigé trois mois après la version testée.

**`@QAIA-EXT-030` — `_dependent` ne supprimait pas les dépendances.**
`DELETE /posts/1?_dependent=comments` laissait les commentaires en place. Cause, correctif
`1b7c0fb` (2024-06-03), issue **#1551 ouverte par un vrai utilisateur** :

```diff
- res.locals['data'] = await service.destroyById(name, id, req.query['dependent'])
+ res.locals['data'] = await service.destroyById(name, id, req.query['_dependent'])
```

Le code lisait `dependent`, le README documentait `_dependent`. **Un underscore.** Le cahier a
été écrit depuis le README, donc il a envoyé `_dependent`, donc il est tombé dessus. C'est
exactement le défaut qu'une suite écrite depuis le code ne peut pas voir : elle aurait copié le
nom du paramètre depuis l'implémentation et serait passée au vert sur un contrat rompu.

### Un troisième échec, contesté — et c'est nous qui avons trop lu

**`@QAIA-EXT-022` — `_start=1` seul renvoie une liste vide.** C'est un fait, vérifié à la main,
et toujours vrai sur la version courante.

Mais le README liste `start`, `end`, `limit` comme trois paramètres et n'en montre que des
**paires** (`_start=10&_end=20`, `_start=10&_limit=10`). Utiliser `_start` seul est une lecture
défendable, ce n'est pas une promesse explicite. **Ce test extrapole**, et il est compté comme
tel : deux défauts, pas trois. Un cahier qui gonfle son score en assertant ce que le contrat ne
dit pas se disqualifie lui-même.

## Le résultat négatif, à égalité de traitement

**Version B (mars 2026) : 28 verts sur 32, 4 rouges — et 3 de ces rouges sont de notre faute.**

`@QAIA-EXT-021` (`_limit`), `@QAIA-EXT-023` (`_start`/`_end`) et `@QAIA-EXT-032` (`arr[0]`)
passaient en 2024 et échouent en 2026. Ce ne sont **pas** des régressions : ces fonctionnalités
ont été **retirées de la documentation** entre-temps (`_limit` y est désormais explicitement
« deprecated », la section Range et le filtrage par indice de tableau ont disparu).

Autrement dit : **le contrat a changé et la suite ne l'a pas su.** Elle a continué à exiger des
promesses périmées, avec l'assurance de tests verts devenus faux. QAIA n'a aujourd'hui aucun
mécanisme pour détecter qu'une exigence a été retirée — c'est un manque, il est réel, et il est
écrit ici plutôt que dans une note de bas de page.

## Ce que cette campagne ne prouve pas

- **Elle n'est pas aveugle.** Les *titres* des commits de correction ont été lus avant la
  génération, pour choisir une version cible qui contienne des défauts. Les zones concernées
  étaient donc connues ; les comportements fautifs, non — aucun diff n'a été ouvert avant la fin
  de la génération. Un lecteur qui trouve cette précaution insuffisante a raison de le dire, et
  le protocole est décrit ci-dessus pour qu'il puisse en juger.
- **Ce n'est pas un pilote.** Aucun humain n'a utilisé QAIA ici. Cette campagne mesure si les
  tests générés attrapent des défauts réels. Elle ne dit rien de leur utilité pour un ingénieur
  QA dans son travail : lisibilité, conventions d'équipe, temps gagné. C'est l'inconnue n°1 du
  projet et elle reste entière.
- **Une seule cible, une seule API.** Un serveur REST sans interface. Rien ici ne se transporte
  automatiquement à une application avec navigateur, ni à un domaine métier.
- **32 scénarios**, pas une couverture exhaustive du README.

## Ce qu'elle prouve

Un cahier de tests écrit depuis la seule documentation publique d'un projet tiers, sans jamais
en lire le code, a trouvé **deux défauts réels dans un projet à 74 000 étoiles** — dont un
signalé par un vrai utilisateur dans un vrai ticket, et les deux corrigés par le mainteneur
après la version testée.

Et il a échoué là où on ne l'avait pas prévu : sur un contrat qui bouge.

## Reproduire

```bash
git clone https://github.com/typicode/json-server.git
git -C json-server worktree add ../sut   --detach 8fb0f72   # version A, mai 2024
git -C json-server worktree add ../fixed --detach 89a34a4   # version B, mars 2026
# npm install dans chaque worktree, puis, avec la base d'exemple du README :
npx tsx src/bin.ts db.json --port 3010   # dans ../sut
npx tsx src/bin.ts db.json --port 3020   # dans ../fixed
cd eval/external-application-2026-08-08/tests && npm install
SUT_URL=http://localhost:3010 npx playwright test   # attendu : 3 rouges
SUT_URL=http://localhost:3020 npx playwright test   # attendu : 4 rouges, dont 3 contrats retirés
```

Sorties brutes conservées : `results-alpha23-2024-05.json`, `results-beta15-2026-03.json`.
Cahier : `testbook/json-server-rest.feature`. Suite : `tests/json-server.api.spec.js`.
