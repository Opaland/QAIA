# Rétro Sprint 3 — équipe agile autonome (8 agents, workflow)

Date : 2026-07-23. Détail complet dans le journal de session ; l'essentiel décisionnel ci-dessous.

## Résultats

| Livrable | Résultat | Clé |
|---|---|---|
| US-002 (dosages) — génération jugée | **17/20** | 24 scénarios, 52 % négatifs, **4/4 ambiguïtés plantées détectées** ; pertes : Then composé, littéral faux (18≠19 car.), Background non invariant |
| US-003 (API labo) — génération jugée | **19/20** | 27 scénarios, 58 % négatifs ; **0/4 ambiguïtés détectées** (2 évitées silencieusement par choix de données) |
| Régénération US-001 v2 (D17) | ✅ | Diff 21 unchanged / 3 modified / 3 new ; 2 retouches humaines préservées |
| Export XLSX (D25) | ✅ | 3 feuilles conformes, auto-vérifié |
| Boucle RAG (D22/D23) | ✅ | Règle BR-KB-004 promue et appliquée au scénario régénéré |

## Défauts critiques consolidés (dédupliqués sur 5 rapports)

- **C1** — `need-understanding` : détection d'ambiguïtés non systématique par *type* d'AC (états, auth, tri, pagination) — cause du 0/4 sur US-003.
- **C2** — résolution silencieuse par évitement de données (jeu de données choisi pour contourner un cas indéfini, sans Q-item).
- **C3** — régénération : pas de snapshot/hash de la génération précédente → détection des retouches humaines non garantie (D17 fragile).
- Majeurs M1-M8 : frontière [assumption]/[open] non déterministe (santé/sécurité), littéraux non vérifiés par calcul, diff aveugle aux couplages inter-AC, statut `simulated` hors nomenclature, bornes BVA reléguées P3 puis waived, Outlines dans l'export, deltas amont sans destination, traçabilité des règles knowledge appliquées.

## TOP-5 actions → skills 0.1.2

1. `need-understanding` : **passe adversariale par type d'AC** (machine à états → ré-entrance ; auth → révocation vs expiration ; tri → tie-break ; filtres → cas dégénéré) + règle dure : tout jeu de données évitant un cas indéfini déclenche un Q-item.
2. `need-understanding` : **arbre de décision** answered/[assumption]/[open] avec précédence et 3 exemples calibrés.
3. `testbook-generate` : **3 lints d'émission** — Then composés interdits, littéraux vérifiés par calcul, Background = invariants 100 % vrais.
4. Régénération : **snapshot/hash en `state/`** (D17 exécutable), scan de tout le cahier sur les valeurs modifiées, destination des deltas amont.
5. Transverse : statut `simulated` normalisé, éclatement des Outlines à l'export, schéma `BR-KB-nnn` + traçabilité des règles appliquées dans la matrice.

## Suivi C1 (mis à jour)

C1 (US-003 0/4 ambiguïtés) : **CLOS en 0.1.3** — 3/4 détectées, contradiction inter-AC à 3 branches attrapée, résolution silencieuse éliminée. Détail : `eval/baselines/0.1.3-US-003-C1-closure.md`. Résidu 0.1.4 : chaîne de re-corrections (pattern distinct).

## Verdict

Démontré : pipeline complet sur 2 US complexes à scores élevés, les 3 modes avancés opérationnels, discipline de confiance tenue. Non couvert : parcours conversationnel réel (pilotes, gate G2) et robustesse inter-domaines de la détection d'ambiguïtés (C1) — priorité n°1 de la 0.1.2.
