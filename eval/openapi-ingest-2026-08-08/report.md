# Une spécification OpenAPI comme source d'exigence (2026-08-08)

Deuxième application de QAIA à un document que nous n'avons pas écrit, et première à une source
**formelle** plutôt qu'à de la prose.

Cible : la spécification **Swagger Petstore**, OpenAPI 3.0.4, version 1.0.27, récupérée le
2026-08-08 depuis `https://petstore3.swagger.io/api/v3/openapi.json`. Gelée dans `sources/`,
empreinte enregistrée dans `REQUIREMENT-SOURCE.json` — donc le jour où elle bouge,
`check_requirement_drift.py` échoue. C'est la première utilisation du mécanisme construit le matin
même pour un cas qu'il n'avait pas encore rencontré.

**Aucune requête n'a été envoyée au serveur Petstore : il ne nous appartient pas.** Ce travail lit
un document. Tout ce qui suit est de la forme *« la spécification promet X »*, jamais *« l'API fait
X »*.

## Inventaire, mesuré

| | |
|---|---|
| Chemins | 13 |
| Opérations | 19 |
| Schémas | 6 |
| Codes de réponse déclarés, tous confondus | `200`, `400`, `404`, `422`, `default` |
| Opérations déclarant un schéma de sécurité | **9 sur 19** |
| Opérations déclarant un `401` ou un `403` | **0** |

## Le gain immédiat sur une source en prose

La campagne json-server de la veille a dû ouvrir sept questions ouvertes dont une portait sur un
manque massif : *« aucun code de statut n'est documenté, pour aucune route »*. Ici, les codes sont
déclarés opération par opération. `GET /pet/{petId}` avec un identifiant inconnu **doit** répondre
404 — c'est écrit, ce n'est pas notre interprétation.

C'est tout l'intérêt d'une source formelle : la valeur attendue vient du document, pas du testeur.

## Ce que la dérivation a trouvé dans la spécification elle-même

Le passage systématique des quatre contradictions décrit par la skill a rendu **les quatre
présentes dans ce seul document**. Chacune est vérifiable dans le fichier gelé.

### 1. Un paramètre requis qui porte un défaut

`GET /pet/findByStatus`, paramètre `status` :

```json
{"name": "status", "in": "query", "required": true,
 "schema": {"type": "string", "default": "available", "enum": ["available","pending","sold"]}}
```

S'il est requis, le défaut est inatteignable. Si le défaut s'applique, il n'est pas requis. Le
document ne tranche pas → `Q1`, et **aucun scénario n'asserte le comportement quand `status` est
absent**.

### 2. Le même champ contraint ici et pas là

`Pet.status` porte l'enum `available|pending|sold`. Le paramètre de requête `status` de
`POST /pet/{petId}` est typé `{"type": "string"}`, sans enum. Deux promesses sur un même champ →
`Q2`.

### 3. Neuf opérations sécurisées, zéro code d'échec déclaré

Neuf des dix-neuf opérations déclarent `petstore_auth` ou `api_key`. **Aucune opération du document
n'déclare de `401` ni de `403`.** Le chemin de refus d'autorisation — celui où vivent les défauts
intéressants — est entièrement non spécifié.

C'est le constat le plus lourd de la dérivation, et il est purement mécanique : il tombe d'un
croisement entre le bloc `security` et le bloc `responses`, que personne ne fait à la main sur
dix-neuf opérations.

### 4. Une contrainte en prose, absente du schéma

```
GET  /store/order/{orderId} : "For valid response try integer IDs with value <= 5 or > 10."
DELETE /store/order/{orderId} : "Anything above 1000 or non-integers will generate API errors."
```

Aucun `minimum`, aucun `maximum` dans les schémas correspondants. Les machines lisent le schéma :
la contrainte n'est appliquée par rien. La skill **refuse d'en faire une assertion** — c'est une
question ouverte, pas un test.

## Le cahier dérivé

`testbook/petstore-pets.feature` — 11 scénarios sur les quatre opérations `/pet` qui portent assez
de schéma pour dériver. Ce n'est **pas une suite**, c'est un échantillon de dérivation : les 15
autres opérations ne sont pas couvertes.

Ce que la dérivation produit sans interprétation :
- **Partitions d'équivalence** depuis l'enum, avec sa moitié invalide (`OAS-002`) — c'est celle qui
  trouve les défauts, et elle tombe du document
- **Chemins de refus** depuis `required: ["name", "photoUrls"]`, un champ omis à la fois
  (`OAS-005`)
- **Valeur attendue déclarée** pour l'identifiant inconnu (`OAS-008`, 404 écrit dans le document)
- **Classe invalide de type** pour `petId` typé entier (`OAS-009`)

Deux scénarios (`OAS-003`, `OAS-011`) portent un résultat explicitement **indéterminé par la
spécification**. Ils ne passent pas et ne doivent pas passer : ils existent pour porter la question
jusqu'à l'humain qui doit trancher.

## Les limites, énoncées

- **Aucune exécution.** Rien ici ne dit si le Petstore tient ses promesses. La dérivation est
  prouvée ; le sondage ne l'est pas. C'est `contract-probe` qui ferait ça, et il faudrait un
  serveur qui nous appartienne.
- **Quatre opérations sur dix-neuf.** Échantillon, pas couverture.
- **Un seul document.** Une spécification d'exemple, écrite pour la démonstration, donc plus propre
  que la moyenne — et elle porte quand même les quatre classes de contradiction. Ce n'est pas un
  argument sur la qualité des spécifications réelles, plutôt une indication.
- **`int64` n'est pas une borne.** `petId` est typé `integer/format: int64` sans `minimum` ni
  `maximum`. Asserter les bornes de int64 serait inventer l'exigence ; la skill s'en abstient et le
  dit dans le cahier.

## Ce que ça change pour QAIA

La chaîne avait une seule porte d'entrée : une user story écrite pour des humains. Elle en a deux.
Le reste — `istqb-design`, `prioritize`, `testbook-generate` — n'a pas bougé d'une ligne, parce que
la sortie a la même forme.

Et la boucle du matin se referme : le mécanisme de dérive d'exigence construit après l'échec de la
campagne json-server couvre maintenant une source qu'il n'avait jamais vue. Une spécification
récupérée par URL est exactement le type d'exigence qui bouge sans prévenir.
