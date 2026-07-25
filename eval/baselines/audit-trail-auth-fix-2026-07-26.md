# Faille corrigée — `GET /api/audit` non authentifié (trouvée par l'audit externe, 2026-07-26)

L'audit externe multi-persona (Workflow, 17 agents, revue adversariale à 3 sceptiques) a trouvé
et **reproduit en direct par les 3 sceptiques indépendamment** une vulnérabilité active dans les
deux SUT vitrines du produit : `GET /api/audit` répondait `200` avec le journal d'audit complet
sans **aucune vérification d'authentification**, alors que chaque autre endpoint mutant de ces
apps en exige une.

## Ce qui fuitait

- `examples/expense-demo/app/server.js` : email du soumetteur/approbateur, totaux de rapport,
  **commentaires de rejet en texte libre** (`audit('reject', a.email, { id, comment })`).
- `examples/medibook/app/server.js` : email du patient, activité de réservation/annulation.

## Pourquoi ça n'a pas été vu avant

AC8 (les deux apps) exige que chaque transition **soit enregistrée** (qui/quand) mais ne
spécifie jamais **qui a le droit de relire** ce journal. L'ambiguïté a été résolue silencieusement
vers "totalement ouvert" (commentaire de code : `// AC8 (demo-open, like MediBook)`) plutôt que
vers le défaut sûr (authentification requise) — exactement la même classe de défaut que le gap
IDOR corrigé hier (D96) : une portée d'autorisation non déclarée résolue en silence côté
permissif au lieu d'être flaguée. Le test existant (`api.expense.spec.js`, `@QAIA-US-004-034`)
appelait l'endpoint **sans jeton** et comptait ça comme un PASS, masquant le problème plutôt que
de le révéler.

## Correctif

Les deux `server.js` : `GET /api/audit` exige désormais un jeton valide (`401` sinon), même
posture par défaut-refus que le reste de l'API. Aucune restriction de rôle plus fine n'est
imposée (aucune spec ne la demande) — le défaut sûr minimal est "authentifié", pas "ouvert".

## Vérification (curl direct + suites de tests mises à jour)

```
$ curl -s -w " HTTP %{http_code}\n" http://localhost:4500/api/audit
{"error":"unauthenticated"} HTTP 401
$ curl -s -o /dev/null -w "HTTP %{http_code}\n" -H "Authorization: Bearer <token>" http://localhost:4500/api/audit
HTTP 200
```

Identique pour `medibook` (port 4400). Les 2 tests existants qui appelaient l'endpoint sans
jeton (`api.expense.spec.js` #034, `api.booking.spec.js` #108) ont été corrigés pour passer un
jeton et vérifier explicitement `status() === 200` avant de lire le corps — ils échouaient
silencieusement autrement (`.audit` sur `undefined`). 2 nouveaux cas de non-régression ajoutés
(`@QAIA-US-004-042`, `@QAIA-US-001-109`) prouvant le `401` sans jeton.

La démo statique GitHub Pages (`static-demo/mock-backend.js`) n'implémente aucune route
`/api/audit` du tout — jamais exposée là, rien à corriger de ce côté (confirmé par absence dans
le fichier, pas supposé).
