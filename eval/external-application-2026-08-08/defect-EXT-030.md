# Anomalie — `_dependent` ne supprime pas les ressources dépendantes

Première application de la skill `defect-report` (#75), sur le premier défaut que QAIA ait trouvé
dans un logiciel qu'elle n'a pas écrit. Écrit **sans jamais ouvrir le code de la cible**, comme
tout le reste de la campagne.

---

**Titre** — `DELETE /:resource/:id?_dependent=<autre>` ne supprime pas les ressources dépendantes,
alors que le README le documente

**Sévérité** — **Majeure**. Une promesse documentée n'est pas tenue et aucun contournement n'est
documenté. La requête répond en succès et ne fait rien de ce qu'elle annonce : rien, côté client,
ne permet de détecter l'échec. Ce n'est pas Critique — aucune donnée n'est perdue et aucune
frontière d'autorisation n'est franchie ; l'effet est l'inverse, des données survivent.

**Version** — `typicode/json-server` au commit `8fb0f72` (2024-05-13, `1.0.0-alpha.23`)

**Scénario** — `@QAIA-EXT-030`, dans
[`testbook/json-server-rest.feature`](testbook/json-server-rest.feature)

**Promesse** — README.md du dépôt au même commit, section *Delete*, cité verbatim :

```
## Delete

DELETE /posts/1
DELETE /posts/1?_dependent=comments
```

Copie gelée : [`sources/README.8fb0f72.md`](sources/README.8fb0f72.md) (sha256 enregistré dans
`REQUIREMENT-SOURCE.json`, vérifié par `check_requirement_drift.py`).

**Étapes** — reproduction minimale, en termes de client HTTP :

1. Démarrer le serveur sur une base contenant une collection `posts` et une collection `comments`
2. `POST /posts` avec `{"title": "parent"}` → noter l'identifiant renvoyé, soit `P`
3. `POST /comments` avec `{"text": "x", "postId": "P"}` → noter l'identifiant renvoyé, soit `C`
4. `DELETE /posts/P?_dependent=comments`
5. `GET /comments`

**Attendu** — déduit de la promesse : le commentaire `C` n'est plus dans la collection après
l'étape 4, puisque `_dependent=comments` déclare les commentaires comme dépendants du post
supprimé.

**Obtenu** — le commentaire `C` est toujours présent à l'étape 5. Relevé de l'exécution :

```
Error: expect(received).not.toContain(expected)
Expected value: not "6f52"
Received array:     ["1", "2", "6f52"]
  at json-server.api.spec.js:221
```

L'étape 4 répond en succès. La suppression du post, elle, a bien eu lieu.

**Preuves**
- [`results-alpha23-2024-05.json`](results-alpha23-2024-05.json) — sortie brute de l'exécution,
  scénario `@QAIA-EXT-030`
- [`tests/json-server.api.spec.js`](tests/json-server.api.spec.js) — le test, rejouable en une
  commande
- [`sources/README.8fb0f72.md`](sources/README.8fb0f72.md) — l'exigence à la version testée

**Cause** — **non établie.** Le protocole de la campagne interdisait d'ouvrir le code de la cible.
Ce qui est observé : la requête répond en succès, le parent est supprimé, les dépendants ne le
sont pas. Rien dans la preuve jointe ne dit pourquoi.

**Portée** — vérifié par ailleurs et trouvé intact : `DELETE` sans `_dependent` supprime bien la
ressource (`@QAIA-EXT-010`), et 28 autres promesses du même README sont tenues. Non vérifié :
le comportement avec plusieurs dépendances, avec une ressource dépendante inexistante, ou quand le
parent lui-même n'existe pas.

---

## Ce que le mainteneur a fait, cinq jours plus tard

Lu **après** la rédaction de ce rapport, comme le reste du code de la cible.

Un utilisateur, `wll8`, avait ouvert
[l'issue #1551](https://github.com/typicode/json-server/issues/1551) le 2024-05-29 avec la cause
exacte : *« The parameter in the document is `_dependent`, but in the code it is `dependent` »*.
Correctif `1b7c0fb`, 2024-06-03 :

```diff
- res.locals['data'] = await service.destroyById(name, id, req.query['dependent'])
+ res.locals['data'] = await service.destroyById(name, id, req.query['_dependent'])
```

**Il avait raison et nous n'avions pas la cause.** La comparaison poste par poste entre son ticket
et ce rapport est dans
[`references/verified-against-1551.md`](../../plugins/qaia-playwright/skills/defect-report/references/verified-against-1551.md)
de la skill. Le résumé : il gagne sur la cause parce qu'il a lu le code ; ce rapport apporte une
reproduction rejouable, la promesse citée plutôt que liée, et l'attendu/obtenu en texte plutôt
qu'en capture d'écran.

Aucun des deux ne remplace l'autre.
