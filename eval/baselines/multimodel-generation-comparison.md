# La méthodologie QAIA généralise-t-elle hors Claude ? Comparaison multi-modèles

*2026-07-24 ter, suite 8. Demande fondateur : utiliser les modèles ajoutés (Gemini, Groq,
Hugging Face) pour de l'A/B sur la génération de cahiers de test, pas seulement le jugement.*

## Méthode

Même ticket dur et mêmes règles condensées que les runs Claude du harnais de gap #24 (cas
"Group pages", vérité-terrain réelle = 11 scénarios humains d'un projet DevOps open source),
envoyés **tels quels** (aucune adaptation par fournisseur) à Gemini, Groq et Hugging Face via
`eval/tools/multi_model_generate.py`. Comparaison à 3 niveaux : score structurel déterministe,
respect des règles d'émission (IDs, tags, ratio), et rappel contre la vérité-terrain réelle.

## Défaut trouvé dans le scoreur lui-même (pas dans un modèle)

Le run Hugging Face place son commentaire `# Condition: ...` **entre** les tags et la ligne
`Scenario:` (une convention différente de celle que Claude utilise habituellement dans ce
projet, commentaire avant les tags). Le parseur de `structural_score.py` effaçait alors les
tags en attente à cause d'une ligne de code trop large (`tags_pending = ... if not cur else
[]` s'appliquait à *toute* ligne non-tag non-Scenario, y compris les commentaires).
**Conséquence mesurée avant correctif** : traçabilité HF à 0.9/25 au lieu de 25/25, score
48/FAIL au lieu de 72/CONCERNS — un score de près de moitié, uniquement à cause d'une
convention de mise en forme différente, pas d'un vrai défaut du contenu généré. Corrigé
(la ligne de reset ignore désormais les lignes de commentaire) ; **0 régression** sur les 7
fixtures de `eval/goldset-hardened/`. Pertinent au-delà de ce test : `testbook-validate`
note explicitement gérer des cahiers "non générés par QAIA" — cette même convention de
commentaire aurait pu fausser silencieusement un vrai audit externe.

## Résultat structurel (après correctif)

| Fournisseur / modèle | Scénarios | Score /100 | Gate | Défauts trouvés |
|---|---|---|---|---|
| **Gemini** (gemini-3.6-flash) | 20 | **100** | **PASS** | Aucun |
| **Hugging Face** (gpt-oss-120b) | 18 | 72 | CONCERNS | 1 groupe quasi-dupliqué (pagination première/dernière page) — signal, pas un vrai défaut ; assertions parfois peu concrètes (complétude 8,3/30) |
| **Groq** (llama-3.3-70b) | 10 | **42** | **FAIL** | **IDs de scénario absents** (un seul `@QAIA-GRP-001` posé sur la `Feature`, pas par scénario — viole D18) ; **complétude à 0** (assertions systématiquement vagues : "I see the group's projects" sans valeur/état concret vérifiable) ; ratio négatif 30 % sous la cible 40 %, jamais signalé comme insuffisant |

## Rappel contre la vérité-terrain réelle (11 scénarios humains)

- **Gemini** : le plus complet — reprend projets/activité/membres/settings/image, ajoute
  **l'annulation en cours d'édition d'image** (pattern CRUD "cancel mid-operation" qu'aucun
  des 3 runs Claude de #24 n'avait utilisé), flague explicitement les axes config-driven en
  prose. Rate la suppression d'avatar (comme Claude) et n'appelle pas isues/MR par leur nom.
- **Hugging Face** : discipline de gap remarquable — flague explicitement "not tested – gap
  identified" pour la visibilité privée et le tri/filtre plutôt que les inventer, **exactement
  le réflexe que #24 avait dû ajouter en dur à `istqb-design`** (le prompt condensé envoyé ici
  ne contenait PAS cet amendement — ce modèle l'a fait spontanément).
- **Groq** : le plus faible des trois — couverture correcte des cas évidents (projets,
  activité, groupe inexistant, visibilité publique) mais aucune discipline de gap, aucune
  tentative sur la suppression d'image, et les deux vrais défauts structurels ci-dessus.

Aucun des 3 ne couvre la suppression d'avatar correctement (même limite que les 3 runs Claude
originaux de #24 — cohérent, pas un artefact du changement de modèle).

## Conclusion

**La méthodologie (les règles condensées) généralise au-delà de Claude — l'exécution, non.**
Gemini et le modèle servi par Hugging Face (gpt-oss-120b) produisent un travail sérieux,
parfois même plus riche que certains runs Claude (le pattern "cancel mid-operation" de
Gemini, la discipline de gap spontanée de HF). Groq (llama-3.3-70b, un modèle plus petit/
rapide) décroche nettement : les règles d'émission (IDs stables, assertions concrètes,
signalement du ratio) ne sont pas suivies avec la même rigueur. Ce n'est pas une surprise
étant donné la taille relative du modèle, mais c'est **mesuré, pas supposé** : la qualité de
QAIA en pratique dépend du modèle qui l'exécute, pas seulement du texte du skill.

## Limites honnêtes

- Un seul cas testé (Groups), un seul run par fournisseur — pas de mesure de variance
  inter-run comme pour Claude (#24, 3 runs). À étendre si l'usage se généralise.
- Aucun accès aux vrais outils de fichier/état QAIA (`.qaia/`) pour ces fournisseurs — la
  comparaison porte sur la sortie brute d'un prompt condensé, pas sur une exécution réelle du
  skill dans un harnais agentique complet.
