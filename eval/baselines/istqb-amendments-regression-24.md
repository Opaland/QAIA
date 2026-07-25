# Non-régression des 2 amendements istqb-design (#24) — contrôle échantillonné

*2026-07-24 (ter, suite).* Suite honnête à `gap-harness-24.md` : les 2 amendements
(entités-sœurs non nommées, tag bas-confiance obligatoire sur sémantique de suppression
inventée) avaient été appliqués sans re-mesure à grande échelle. Un **re-run complet des 50
US de `groundtruth-corpus.md`** (3 juges, train/held-out) est coûteux et hors de proportion
pour valider 2 règles ciblées ; ce contrôle échantillonne **2 cas réels neufs**, jamais vus
par les runs qui ont produit les amendements, choisis pour déclencher précisément chaque
règle, sur des repos différents du cas d'origine (GitLab CE `dashboard.feature`, Diaspora
`two_factor_authentication.feature` — tous deux dans `groundtruth-corpus.md`, jamais utilisés
dans `gap-harness-24.md`).

## Cas 1 — Dashboard (amendement « entités-sœurs non nommées »)

Ticket dur soumis : une page Dashboard montrant "mes projets et leur activité récente" — sans
jamais nommer "issues", "merge requests" ni aucune autre collection.

**Résultat : l'amendement fonctionne.** Le run flague explicitement, en gap ouvert (pas en
silence) :
> *"Sibling collections of 'project' [...] issues, merge/pull requests, commits, tasks [...]
> must be surfaced as an open question rather than guessed"*
> *"Other aggregation views [...] a cross-project activity feed [...] notifications,
> starred/pinned projects, or 'tasks assigned to me' [...] should be asked rather than
> assumed absent"*

C'est exactement la classe de défaut trouvée sur le cas Groups (#24, mode 1) — silencieuse à
l'époque (0/3 runs la signalaient), maintenant explicite. Aucune régression sur le reste :
extraction AC cohérente, ratio négatif 44 % (cible ≥40 % tenue, non gonflé), gates
d'autorisation (IDOR, non-authentifié) toujours présents.

## Cas 2 — Authentification à deux facteurs (amendement « tag bas-confiance obligatoire »)

Ticket dur soumis : activer la 2FA par application d'authentification — sans jamais préciser
le mécanisme de désactivation.

**Résultat : l'amendement fonctionne.** Le scénario de désactivation est généré (couverture
CRUD-complétude toujours active) mais correctement dégradé :
> `@QAIA-2FA-013 [...] @low-confidence` — *"exact disable mechanism not specified by the
> source [assumption]"*

Idem pour la régénération des codes de récupération (opération CRUD sœur) :
> `@QAIA-2FA-020 [...] @low-confidence` — *"regeneration mechanism not specified by the
> source [assumption]"*

C'est l'inverse exact du défaut trouvé sur le cas Groups (#24, mode 1) : les 3 runs d'origine
inventaient tous la même sémantique de reset-à-défaut **sans** ce tag. Ici, la même classe de
scénario (inverse CRUD non spécifié) porte désormais le tag. Aucune régression : 20
scénarios, ratio négatif 60 % (non gonflé, chaque négatif tracé), techniques justifiées,
gates d'autorisation (IDOR sur les paramètres d'un autre utilisateur, UI-bypass) présents.

## Verdict

**Aucune régression détectée** sur les 2 cas de contrôle ; les 2 amendements produisent
l'effet recherché sur du matériel neuf, pas seulement sur le cas qui les a inspirés — un
signal de généralisation, pas de sur-ajustement à un seul exemple. **Ce contrôle n'est pas
équivalent à un re-run complet des 50 US** (aucune mesure de rappel/précision agrégée n'a été
refaite, aucun juge LLM en aveugle n'a scoré ces 2 cas) — honnêteté : si un futur amendement
touche à nouveau `istqb-design`, le re-run complet du corpus reste la mesure de référence à
faire avant une release publique/pilote.
