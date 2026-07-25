# Connecteurs testés sur données RÉELLES avec erreurs (2026-07-24)

Demande fondateur : « essaie tes connecteurs (pas que Jira), trouve des données diverses
avec des erreurs ». Test sur de **vraies** données publiques (récupérées depuis GitHub, seul
hôte joignable dans le sandbox), **jamais inventées** — inventer serait le mode d'échec IATS #3
(« jeu de données fantaisie »).

## Connecteur oracle OpenAPI (issue #16) — 3 specs réelles

| Spec réelle (source) | openapi | ops | 4xx/5xx documentés | auth déclarée | Ce que l'oracle produit |
|---|---|---|---|---|---|
| Swagger **Petstore** (swagger-api/swagger-petstore) | 3.0.4 | 19 | 15 | 9 ops | **négatifs réels** : `Pet.required=[name,photoUrls]` (via `$ref`), 401 sur ops sécurisées, statuts documentés |
| **apis.guru** (APIs-guru/openapi-directory) | 3.0.0 | 7 | **0** | 0 | **≈ 0 négatif ancré** — tout reste `[open]` |
| **Notion** (APIs-guru/openapi-directory) | 3.0.3 | 13 | **0** | 0 (aucun `securityScheme`) | **≈ 0 négatif ancré** + **rate l'auth** (l'API Notion est bearer-gated en vrai) |

### Constat (vérifié)

- **L'oracle respecte son garde-fou** : il n'invente jamais un statut/une contrainte absente
  de la spec — sur apis.guru et Notion il reste honnêtement `[open]`. C'est le bon comportement.
- **MAIS il dégénère silencieusement** : sur 2 des 3 specs réelles, le rendement tombe à quasi
  zéro négatif ancré, **sans aucun signal** que la spec est suspecte. Un utilisateur peut croire
  « oracle passé, couverture ancrée » alors qu'il n'a rien produit. Une API produit (Notion) qui
  documente **0 réponse d'erreur et 0 auth** est un signal d'alarme, pas un silence normal.
- **Piège de résolution `$ref`** : mon premier passage d'analyse comptait `Pet.required=0` parce
  qu'il ne suivait pas le `$ref` vers `#/components/schemas/Pet`. Une fois résolu, `required=[name,
  photoUrls]`. **Risque réel pour le skill** (qui est un prompt) : s'il ne résout pas les `$ref`,
  il rate tous les négatifs de champ requis. À durcir dans `oracles/openapi.md`.

### Correctifs apportés au connecteur (#25, 2026-07-24 ter) — CLÔS

1. **Avertissement « spec sous-documentée »** ajouté à `oracles/openapi.md` step 0 : se
   déclenche si **0 réponse 4xx/5xx documentée sur tout le spec** OU **(mutations
   POST/PUT/PATCH/DELETE présentes ET 0 auth déclarée)**. Règle **vérifiée en re-fetchant les 3
   specs réelles** (pas seulement conçue en théorie) :

   | Spec | Mutations | 4xx/5xx documentés | Auth déclarée | Règle se déclenche ? |
   |---|---|---|---|---|
   | Petstore | 8 | 7 codes distincts | oui (OAuth2 + API key) | **non** — bien documenté |
   | apis.guru (méta-API, lecture seule) | 0 | 0 | non | **oui** (1er bras : 0 codes d'erreur sur tout le spec) |
   | Notion | 1 (PATCH) | 0 | non | **oui** (les deux bras) |

   La première mouture de la règle (mutations>0 ET (0 erreurs OU 0 auth)) aurait **manqué**
   apis.guru (0 mutation → jamais déclenchée) alors que c'est justement l'un des 2 cas
   silencieusement dégénérés du constat initial — corrigée avant livraison grâce à cette
   re-vérification sur données réelles, pas seulement sur le cas qui avait inspiré la règle.
2. **Résolution `$ref` rendue obligatoire** (step 0.1) avant toute lecture de `required`/
   `enum`/bornes — un noeud `$ref` non résolu se lit comme « aucune contrainte », perdant tous
   les négatifs de champ requis en silence (confirmé : le `Pet` de Petstore déclare
   `required: [name, photoUrls]`, mais seulement une fois le `$ref` suivi).

Preuve : `plugins/qaia-core/skills/oracle-generate/oracles/openapi.md` (step 0),
`plugins/qaia-core/skills/oracle-generate/SKILL.md` (résumé condensé).

## Connecteur Jira (issue #9) — vraie réponse REST

Fixture réelle `issues_in_sprint.json` (andygrunwald/go-jira) — une **réponse de recherche**
(enveloppe `{total, issues[]}`) contenant l'issue **AR-86** avec `summary=null` et
`description=null` (un ticket **vide** — donnée réelle avec erreur).

- **Gate de décomposition** (us-ingest guardrail) : une réponse de recherche = plusieurs stories,
  pas une US → le connecteur doit lister et demander laquelle traiter, jamais fusionner. ✅ le
  contrat le prévoit.
- **Gate triage vide** (us-ingest step 2) : AR-86 sans résumé ni description → « source vide,
  fournir une vraie US, ne jamais inventer ». ✅ le contrat le prévoit.
- Limite honnête : fixture pauvre (1 issue quasi vide) ; pas de description ADF riche, pas de PII,
  pas d'injection. Les cas adversariaux (ADF imbriqué, PII dans le reporter, directive injectée
  dans la description) restent à tester sur une fixture plus riche.

## Portée & honnêteté

- 3 specs OpenAPI + 1 réponse Jira = un début de **jeu réel divers avec erreurs**, pas un
  gold set durci complet (#24). Petit échantillon, sourcé sous contrainte réseau (GitHub only).
- Les **vraies** données les plus dures (specs/US régulées, gold set IATS ~88 US, cas US 676266)
  sont **confidentielles** (Softway Medical) et **ne peuvent pas être versionnées** dans ce repo
  public — l'éval publique doit utiliser des analogues publics. Contrainte structurelle à assumer.
