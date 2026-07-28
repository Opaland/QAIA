# CT-AI techniques exercées contre une vraie fonctionnalité (2026-07-28)

**Ferme #53** ("Démo avec une vraie fonctionnalité IA/ML pour exercer les techniques CT-AI
ajoutées"). Trouvaille de l'audit externe : les techniques CT-AI v2.0 ajoutées à
`istqb-design` (D95) avaient 0 occurrence de leurs tags dans les 7 exemples du dépôt — jamais
exercées en conditions réelles.

## Ce qui a été fait

- **Nouvelle fonctionnalité réelle** : `POST /api/suggest-category` dans
  `examples/expense-demo/app/server.js` — un classifieur déterministe à mots-clés pondérés
  (`suggestCategory()`), **pas un modèle ML entraîné**, dit explicitement en commentaire de code.
  Choisi comme cible légitime pour les techniques CT-AI car sa sortie exacte (le score de
  confiance) ne peut pas être énoncée directement depuis un seul champ d'entrée — elle dépend
  conjointement de la densité de mots-clés matchés ET du nombre total de mots — exactement la
  précondition que ciblent les tests métamorphiques/CT-AI, sans avoir besoin d'une vraie
  infrastructure ML pour le démontrer.
- **8 scénarios Gherkin dérivés et exécutés pour de vrai** (`curl` direct contre le serveur
  local, pas Playwright — indisponible dans cet environnement, même limite déjà documentée en
  D96) : `examples/expense-demo/qaia-journey/testbooks/US-004-AI/category-suggestion.feature`.

## Vérification réelle (chaque ligne rejouée avant d'écrire le scénario correspondant)

| Vérification | Commande | Résultat réel |
|---|---|---|
| Classification correcte | `{"description":"taxi ride to airport for flight"}` | `{"category":"travel","confidence":0.33}` |
| Repli "other" sans mot-clé | `{"description":"xyz qux blorp"}` | `{"category":"other","confidence":0}` |
| Description vide refusée | `{"description":""}` | `422 {"error":"description is required"}` |
| Entrée adversariale (nombre au lieu de texte) | `{"description": 12345}` | `422`, **pas de 5xx, pas de crash** |
| Entrée adversariale (2500+ caractères, 500 mots répétés) | payload long | `200`, pas de crash |
| Non-authentifié refusé avant toute classification | sans jeton | `401` |
| Consistance / back-to-back | `"dinner at restaurant"` × 2 | `{"category":"meals","confidence":0.67}` les deux fois, identique |
| Relation métamorphique (dilution) | `"dinner at restaurant"` puis la même phrase + mots parasites | `0.67` → **`0.18`** (strictement plus bas, jamais plus haut) |

**Aucune de ces lignes n'est projetée** — chaque commande `curl` a été exécutée contre le
serveur réel (`examples/expense-demo`, port 4599 local) avant que le scénario correspondant ne
soit écrit, pas l'inverse.

## Score structurel déterministe

`eval/tools/structural_score.py examples/expense-demo/qaia-journey/testbooks/US-004-AI/category-suggestion.feature`
→ **65/100, CONCERNS** (8 scénarios, ratio négatif recalculé 62,5%). Deux findings honnêtes,
non corrigés :
- **Redondance** (AI-01/AI-02, même forme Given/When) — accepté, comportement légitimement
  distinct malgré la forme partagée (catégorie trouvée vs repli "other").
- **`traceability` à 0** — ce sous-testbook autonome n'utilise pas le préfixe `@QAIA-<ID>` du
  parcours complet (hors scope de #53, qui visait à exercer les techniques, pas à intégrer
  cette démo au parcours `us-ingest`→`report` complet).
- **2 scénarios sans tag de technique du set fermé** (`consistency`/`metamorphic`) — attendu :
  `@metamorphic` n'est pas encore dans la liste fermée `TECHNIQUE_TAGS` de
  `structural_score.py` (ajoutée au palette D95/D109 après la dernière mise à jour de ce set) —
  limite de l'outil, pas du contenu, signalée honnêtement plutôt que masquée en retirant le tag.

## Verdict

Les techniques CT-AI (`@ai-feature`, `@metamorphic`) sont maintenant exercées pour de vrai
contre une fonctionnalité réelle du dépôt, pas seulement écrites en prose dans un `SKILL.md`.
Le score CONCERNS (pas PASS) est rapporté tel quel — cohérent avec la discipline du projet de
ne jamais lisser un résultat pour l'occasion (D38).
