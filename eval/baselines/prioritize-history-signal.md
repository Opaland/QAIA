# Test A/B — signal git-history optionnel dans `prioritize` (issue #36, D52-consistent)

*2026-07-25. Demande fondateur : la veille concurrentielle (`docs/COMPETITIVE-ANALYSIS.md`,
angle mort #2 "priorisation risque data-driven") pointe l'absence d'ingestion d'historique de
code dans `prioritize`. Ajout d'un signal optionnel, en entrée du score seulement — jamais un
verdict — puis test réel sur QAIA lui-même comme cas d'usage.*

## Pourquoi QAIA lui-même comme cas d'usage, pas le gold set externe

Le gold set (`eval/groundtruth-corpus.md`, 50 paires gitlab/diaspora/sharetribe/cucumber/
behave) n'a pas d'historique git accessible dans ce repo — lire l'historique d'un repo autre
que celui explicitement fourni est une contrainte non négociable de cette mission. QAIA est en
revanche un **repo réel avec un historique git réel** (18 commits visibles sur cette branche,
squash `ec0529e` du développement antérieur + commits individuels depuis), et le produit a une
US récente et bien documentée qui s'y prête : **la skill `flaky-detect` (issue #34, mergée en
D69/D71)**. Ses AC dérivent directement de `plugins/qaia-playwright/skills/flaky-detect/
SKILL.md`, et les fichiers liés existent réellement dans ce repo avec un historique réel — donc
le signal peut être calculé pour de vrai, pas simulé.

## Méthode

6 conditions de test dérivées de `flaky-detect/SKILL.md` (Method + Guardrails), notées comme
si elles étaient l'entrée `03-design.md` de `prioritize`. Deux passes :

- **Variant A** — formulation `prioritize/SKILL.md` d'avant ce changement (git HEAD avant
  édition ; probabilité dérivée uniquement de la complexité/nouveauté de la logique, aucune
  lecture d'historique).
- **Variant B** — formulation modifiée (ce commit), avec le repo QAIA explicitement nommé comme
  cible et `git log --numstat` réellement exécuté sur les fichiers liés à chaque condition
  (commandes et sorties ci-dessous, pas de chiffres inventés).

## Données git réelles utilisées (`git log --numstat -- <path>`)

| Fichier | Commits | Détail |
|---|---|---|
| `plugins/qaia-playwright/skills/flaky-detect/SKILL.md` | 1 | `bd809d8` : +108/-0 (création, jamais retouché depuis) |
| `docs/OUTPUT-CONTRACT.md` | 1 | `ec0529e` (squash) : +136/-0, aucune modification depuis |
| `plugins/qaia-score/skills/aptitude-gate/SKILL.md` | 2 | `ec0529e` (squash) : +73/-0 ; puis `378cc44` : **+6/-3**, correction ciblée post-audit (D69, issue #22) : *"ces deux skills n'avaient pas de garde-fou local explicite pour le cas 'checkpoint/manifeste totalement absent'"* |

## AC → fichier(s) mappé(s) et conditions

| Condition | Résumé AC | Fichier(s) lié(s) |
|---|---|---|
| AC1 | Flag flaky si verdicts pass+fail sur N runs, preuve complète (séquence, run indices, extrait d'échec) | `flaky-detect/SKILL.md` |
| AC2 | Échec systématique ≠ flaky ; jamais fusionné dans la liste `flaky` | `flaky-detect/SKILL.md` |
| AC3 | Fusion manifeste : seule la section `flakiness` est touchée, jamais `execution/design/gate/status` (contrat D39 règle 2) | `flaky-detect/SKILL.md`, `docs/OUTPUT-CONTRACT.md` |
| AC4 | `codeChangeControlled` = `false`/`"unknown"` si non confirmé (pas de confiance par défaut) | `flaky-detect/SKILL.md` |
| AC5 | Tout-vert sur N runs → "aucune flakiness observée", jamais "stable" | `flaky-detect/SKILL.md` |
| AC6 | Jamais d'auto-retry/auto-quarantine/auto-fix ; famille de règle "aucun producteur ne s'auto-note" | `flaky-detect/SKILL.md` (guardrails), `plugins/qaia-score/skills/aptitude-gate/SKILL.md` (garde-fou apparenté) |

## Résultat — 5/6 conditions identiques, 1 divergence justifiée par une preuve concrète

| Condition | Variant A (sans historique) | Variant B (avec historique) | Écart |
|---|---|---|---|
| AC1 | Impact 2, Prob. 2 → **P2** — "logique nouvelle de classification de séquence, modérément complexe" | Impact 2, Prob. 2 → **P2** — même rationale + `@history(flaky-detect/SKILL.md, 1 commit/+108)` cité comme *corroborant* la nouveauté déjà comptée, sans l'ajouter deux fois | aucun (signal cité, pas additif) |
| AC2 | Impact 3, Prob. 2 → **P1** — mauvaise classification d'un vrai bug en "flaky" détournerait un humain d'une vraie régression | Impact 3, Prob. 2 → **P1** — même chiffres, `@history` cité, corroborant seulement | aucun |
| AC3 | Impact 3, Prob. 1 → **P2** (3) — fusion "lire section, remplacer la sienne", mécaniquement simple | Impact 3, Prob. 1 → **P2** (3) — `docs/OUTPUT-CONTRACT.md` cité : 1 commit, **0 modification depuis la création** → cible stable, aucun risque de cible mouvante ajouté | aucun |
| AC4 | Impact 2, Prob. 2 → **P2** — raccourci classique ("faire confiance par défaut") | Impact 2, Prob. 2 → **P2** — `@history` cité (même fichier, même stat qu'AC1), pas de complexité structurelle supplémentaire révélée | aucun |
| AC5 | Impact 1, Prob. 1 → **P3** — règle de formulation simple | Impact 1, Prob. 1 → **P3** — `@history` cité, le signal ne force pas la probabilité au-delà de ce que la simplicité réelle de la règle justifie (garde-fou explicitement testé ici) | aucun |
| **AC6** | Impact 3, Prob. **1** → **P2** (3) — "interdiction catégorique, stable et bien comprise" | Impact 3, Prob. **2** → **P1** (6) — `@history(plugins/qaia-score/skills/aptitude-gate/SKILL.md, 2 commits, dernier +6/-3)` : un fichier de la **même famille de garde-fou** ("aucun producteur ne s'auto-note" / limites d'action autonome) a réellement dû être corrigé après qu'un audit (D69) a trouvé qu'il s'appuyait sur la règle générale du contrat partagé sans instruction locale explicite — précédent concret, pas un pattern de surface | **P2 → P1** |

## Diagnostic de la seule divergence (AC6)

Le signal ne s'est pas contenté de "ce fichier a plus de commits donc risque plus élevé" — il a
cité un **fait précis et vérifiable** : un fichier voisin, dans la même famille de garde-fou
(limite d'action autonome / séparation producteur-score), avait déjà été trouvé insuffisamment
explicite par un audit réel et corrigé en conséquence (`378cc44`, +6/-3, motivé par D69/#22).
C'est un précédent de **cette classe de risque précise** (une règle générale supposée couvrir un
cas particulier sans restatement local explicite) — exactement le type de preuve que la règle
d'origine de `prioritize` demande déjà ("new/complex logic... score higher") mais que la lecture
qualitative seule n'avait pas de moyen de découvrir : AC6 est elle-même une règle "générale
supposée suffisante" (le guardrail `flaky-detect` "jamais d'auto-fix" repose sur l'instruction
locale, mais la classe de risque "garde-fou pas assez explicite" vient de se matérialiser
ailleurs dans ce repo, récemment).

**Contraste avec AC1/AC2/AC4/AC5** : ces conditions pointent vers `flaky-detect/SKILL.md`
lui-même, qui n'a qu'**un seul commit de création** — aucune trace de retouche/correction, donc
aucune preuve de risque additionnelle au-delà de "c'est nouveau", déjà compté dans la probabilité
de base. Le signal ne les a pas gonflées. **Contraste avec AC3** : `docs/OUTPUT-CONTRACT.md` est
au contraire stable (0 modification depuis sa création) — le signal, s'il devait jouer, irait
plutôt dans le sens d'une probabilité plus basse, mais la règle du skill dit explicitement qu'il
ne baisse jamais la probabilité en dessous de ce que la lecture qualitative justifie déjà ; ici
elle ne change rien non plus, à dessein.

## Cohérence avec D52

Le test A/B précédent (`eval/baselines/prioritize-ab-test.md`, D52) a montré qu'un exemple
chiffré inline peut sur-généraliser un pattern de surface ("chemin négatif documenté" copié
mot pour mot sur un cas non pertinent) et dégrader la calibration. La formulation ajoutée ici
évite délibérément cet écueil :

- **Aucun exemple chiffré inline** dans `SKILL.md` — la règle reste qualitative
  ("substance over raw count", "never raises probability on its own past what the condition's
  own complexity already supports"), pas un couple impact/probabilité à imiter.
- **1 seule divergence sur 6**, et elle est motivée par un fait vérifiable spécifique au
  contenu du diff cité (une correction de garde-fou réelle), pas par la fréquence brute d'un
  fichier — `docs/DECISIONS.md` a 7 commits sur cette même fenêtre (le fichier le plus "chaud"
  du repo) mais n'apparaît dans aucune condition testée ici, précisément parce que ses commits
  sont des ajouts mécaniques d'une ligne (changelog append-only) sans rapport avec la logique
  de `flaky-detect` — un bon test que "fréquent ≠ risqué" est appliqué, pas juste énoncé.
- Le signal reste **cité et rejetable** (`@history(path, stat)`), au même titre que
  `[assumption]`/`[open]`, jamais un score final — l'arbitrage humain (étape 3 de `prioritize`)
  garde le dernier mot sur les 6 conditions, y compris AC6.

## Limite honnête

L'historique de ce repo est jeune et en grande partie compressé dans un unique commit squash
(`ec0529e`, tout le développement antérieur) — la fenêtre "récent/fréquent" est donc peu
discriminante par date (tous les commits datent du même jour dans cette session). Le signal
utilisé ici s'appuie sur le **nombre de commits post-squash + la substance du dernier diff**,
pas sur une vraie récence calendaire ; sur un repo avec un historique plus étalé, le signal
gagnerait en pertinence. Ce n'est pas caché : un repo jeune ou fraîchement squashé est un cas où
`prioritize` devrait signaler "historique peu profond, signal de confiance limité" plutôt que de
laisser le silence suggérer une lecture plus riche qu'elle ne l'est.

## Verdict

**Le signal optionnel est appliqué à `plugins/qaia-core/skills/prioritize/SKILL.md`** (étape 1,
sous-puce "Optional git-history signal" + étape 2 pour la citation obligatoire + un garde-fou
dédié). Testé sur un cas d'usage réel de ce repo (skill `flaky-detect`, US #34) : 5/6 scores
inchangés, 1 divergence (AC6, P2→P1) justifiée par une preuve concrète et citée, jamais par la
fréquence brute seule — cohérent avec la prudence exigée par D52.
