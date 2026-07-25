# Cas durs réels — sources web pour le gap harness #24

Catalogue des cas réels utilisés par `eval/baselines/gap-harness-24.md`, dans le même esprit
que `eval/groundtruth-corpus.md` (citation + lien, pas de copie intégrale du code applicatif —
seuls quelques extraits Gherkin courts sont cités à des fins d'évaluation transformative).

| id | source réelle | domaine | # scénarios humains | ce qui en fait un cas dur |
|---|---|---|---|---|
| RC01 | [gitlabhq/gitlabhq — features/groups.feature](https://github.com/gitlabhq/gitlabhq/blob/v8.16.9/features/groups.feature) | Plateforme DevOps | 11 | **Zéro narratif US** (titre + Background seuls) → AC entièrement implicite (mode 1) ; scénarios quasi-jumeaux issues-list/MR-list et avatar upload/removal → paradoxe du pesticide potentiel (mode 3) |
| RC02 | [sharetribe/sharetribe — features/listings/user_creates_a_new_listing.feature](https://github.com/sharetribe/sharetribe/blob/master/features/listings/user_creates_a_new_listing.feature) | Marketplace | 19 (dont 6 sur les champs custom) | Champs custom définis par une **config admin par catégorie** (bornes numériques, format, options) jamais explicitée dans un ticket normal → profondeur de contexte/config (mode 2) |

Ces deux cas font partie de la même famille de projets que `eval/groundtruth-corpus.md`
(licences permissives, mergé/réel) mais ne font PAS partie des 50 paires déjà utilisées pour
l'éval de rappel — nouveau matériel, choisi spécifiquement pour sa dureté sur les 4 modes
d'échec IATS plutôt que pour sa représentativité statistique.

Voir `eval/baselines/gap-harness-24.md` pour : le ticket dur soumis (texte exact), les runs
(isolés, sans accès à la vérité-terrain), et l'analyse de gap comparée aux scénarios réels
ci-dessus.
