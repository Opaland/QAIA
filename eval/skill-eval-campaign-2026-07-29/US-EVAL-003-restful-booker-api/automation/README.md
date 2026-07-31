# Preuves du run bloqué US-EVAL-003 (Restful-Booker)

Ce run est l'un des deux qui se sont terminés en **blocage** pendant la campagne d'évaluation :
la cible `restful-booker` ne renvoyait plus l'API documentée.

Deux fichiers portaient l'extension `.json` alors qu'ils n'ont jamais contenu de JSON — ce sont
justement les réponses qui prouvent le blocage :

| Fichier | Contenu réel | Ce qu'il prouve |
|---|---|---|
| `b3-response-fragment.txt` | 8 octets, `/booking` | réponse tronquée, pas un objet |
| `b4-response.html` | une page HTML complète | l'endpoint renvoyait le **site**, pas l'API |

Renommés le 2026-07-31 : leur extension `.json` faisait échouer le job CI « Validate JSON
manifests » (`jq empty` sur tout `*.json`). Le contenu est inchangé, octet pour octet — c'est la
preuve du blocage, pas un artefact à corriger. Renommer plutôt que supprimer, et plutôt
qu'assouplir le contrôle : le contrôle a raison, c'est le nom qui mentait.
