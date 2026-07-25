# Rappel à 3 juges/US — mesure de référence médiane (issue #20)

*2026-07-25. L'issue #20 (P1) demande de faire passer, pour une mesure de rappel donnée, le
protocole gold-set (`eval/RUBRIC.md`, déjà prévu à 3 juges/médiane pour le score qualité 0-20)
à une **mesure de rappel** spécifiquement — jusqu'ici jamais fait : `groundtruth-training.md`
documente le bruit (±15-20 points de rappel entre runs de juge indépendants) mais note
explicitement "stable per-US recall would need 3 judges/US (median) — expensive; not done."
Cette session comble ce trou pour **une** US, en documentant honnêtement une limite de
portée rencontrée en le faisant (voir "Écart de protocole assumé" ci-dessous).*

## US choisie et écart de protocole assumé

**US-001 — Book a teleconsultation appointment** (`eval/gold-set/US-001-appointment-booking.md`),
déjà mesurée dans `eval/baselines/0.1.0-US-001.md` / `0.1.1-US-001.md` (dimension 2 "AC
coverage" du rubric 0-20, la mesure la plus proche d'un rappel déjà appliquée à une US du
gold-set officiel).

**Honnêteté sur la portée** : le protocole de `groundtruth-training.md` mesure le rappel
**contre un oracle externe et indépendant** — de vrais tests d'acceptation humains écrits
dans des dépôts matures (GitLab, Diaspora, etc.), jamais vus par QAIA, formulés
indépendamment. Les 5 US du gold-set officiel (`eval/gold-set/`) sont du contenu
**synthétique clean-room** sans suite de tests humaine externe associée — il n'existe pas
d'oracle caché pour US-001 au sens strict de `groundtruth-training.md`. Ce contrôle mesure
donc un **rappel contre les critères d'acceptation de la source elle-même**, décomposés en
comportements testables discrets par chaque juge indépendamment (même logique
comportement-par-comportement que `groundtruth-training.md`, mais l'oracle est la liste d'AC
de l'US, pas un test humain tiers). **Ce n'est pas équivalent** à un re-run du corpus des 50 US
réelles — c'est la mesure la plus proche qu'on peut faire sur le gold-set officiel versionné
dans ce repo, documentée comme telle plutôt que présentée comme la même chose.

## Méthode

1. Une seule génération du cahier de test pour US-001, en appliquant `us-ingest` →
   (`need-understanding` condensé, prérequis non-nommé mais obligatoire) → `istqb-design` →
   (`prioritize` condensé, prérequis non-nommé mais obligatoire) → `testbook-generate`, dans
   une passe unique. Détail complet : `eval/baselines/multi-judge-median-testbook/00-pipeline-notes.md`.
   Artefacts : `booking.feature`, `cancellation.feature`, `coverage-matrix.md`, `synthesis.md`
   dans le même dossier. 24 blocs de scénarios (23 atomiques + 1 `@smoke`), les 8 AC couverts,
   ratio négatif 39,1 % (reporté tel quel, non gonflé).
2. **3 jugements indépendants, à l'aveugle les uns des autres** : 3 agents Claude séparés,
   lancés en parallèle dans des sessions isolées (aucun des trois n'a vu le raisonnement de
   génération ni les jugements des deux autres), chacun recevant **uniquement** : la user
   story + ses 8 AC (texte brut, sans les "planted ambiguities" réservées au juge dans le
   fichier gold-set — hors périmètre de cette mesure de rappel), les deux `.feature` générés,
   et une consigne méthodologique commune : décomposer soi-même les AC en comportements
   testables discrets, chercher une couverture **concrète** (pas un titre qui évoque le sujet),
   noter Found / Partial / Missing avec justification, calculer rappel = (Found + 0.5×Partial)
   / total.
3. Médiane et variance (écart max−min) calculées sur les 3 scores de rappel obtenus.

## Les 3 jugements bruts

| Juge | Décomposition (nb comportements) | Found | Partial | Missing | **Rappel** |
|---|---|---|---|---|---|
| **Juge 1** | 18 | 15 | 3 | 0 | **91.7 %** |
| **Juge 2** | 19 | 18 | 1 | 0 | **97.4 %** |
| **Juge 3** | 18 | 17 | 1 | 0 | **97.2 %** |

**Convergence forte sur le fond** : les 3 juges, indépendamment, ont retrouvé la même seule
vraie faiblesse de l'artefact — l'assertion de conversion de fuseau horaire dans la
confirmation (AC5, `@QAIA-US001-013`, *"the confirmation shows the date and time converted to
the patient's local timezone"*) **n'affirme aucune valeur concrète convertie** (ex. l'heure
locale réelle attendue), donc une conversion cassée ou une no-op passerait ce test. Les 3
juges classent ce point en `Partial`, avec la même justification en substance. Le Juge 1
ajoute deux `Partial` supplémentaires du **même type d'écart** (assertions "shape-only" sans
valeur concrète) sur les deux scénarios de piste d'audit (AC8, `@QAIA-US001-022/023` —
*"records who/what/when"* sans valeur vérifiée) ; les Juges 2 et 3 les ont comptés `Found`
(ils ont jugé la présence de l'assertion suffisante, sans exiger une valeur concrète pour ce
niveau de granularité). C'est la seule vraie divergence entre les 3 : **où placer le curseur
de rigueur sur une assertion "structurellement correcte mais non chiffrée"**, pas un désaccord
sur ce que fait réellement l'artefact.

Aucun jugement ne signale un AC réellement manqué (`Missing` = 0 partout) — les 8 AC ont
chacun au moins un scénario qui les couvre concrètement, dans les 3 lectures indépendantes.

## Médiane et variance

- **Médiane : 97.2 %**
- **Variance (écart max−min) : 97.4 − 91.7 = 5.7 points**

## Interprétation honnête — pourquoi la variance ici est bien plus faible que ±15-20 points

Ce résultat **ne contredit pas** le bruit ±15-20 points documenté dans
`groundtruth-training.md` — les deux mesurent des choses différentes, et la différence de
variance a une explication structurelle plausible, pas un artefact de chance :

1. **L'oracle est fermé et bien spécifié ici.** Les 8 AC d'US-001 sont des phrases courtes,
   univoques, numérotées — décomposer "AC5 contient 3 comportements" est presque mécanique et
   les 3 juges y arrivent avec 18-19 items quasi identiques. Dans `groundtruth-training.md`,
   l'oracle est une **vraie suite de tests humaine indépendante** (formulée dans un style,
   un découpage et un vocabulaire différents de tout ce que QAIA produit) — faire correspondre
   un scénario Gherkin QAIA à un test humain écrit des années plus tôt dans un style différent
   est un jugement d'équivalence comportementale **beaucoup plus subjectif** que "cet AC
   court est-il couvert par une assertion concrète ?".
2. **Le rappel mesuré ici est structurellement plus haut** (91-97 %) que celui de
   `groundtruth-training.md` (33-53 % pondéré train/held-out) — à un plafond aussi élevé, il y
   a mécaniquement moins de marge de désaccord possible entre juges qu'à un rappel médian
   proche de 50 % où chaque cas limite peut faire basculer le score de plusieurs points.
3. **Un seul point de désaccord réel** (le seuil de rigueur sur les assertions "shape-only"
   sans valeur chiffrée) explique toute la variance observée — ce n'est pas un désaccord
   diffus sur de nombreux items, c'est un désaccord net sur un critère de jugement précis,
   qui pourrait être resserré en amendant la consigne du juge (ex. expliciter si une assertion
   non-chiffrée compte comme couverture complète ou partielle) plutôt que corrigé en
   augmentant le nombre de juges.

**Ne pas sur-généraliser** : ceci est **une** US, **une** génération, **un** protocole de
décomposition — pas une preuve que le bruit de juge est globalement plus faible qu'estimé.
C'est un point de données honnête qui affine l'hypothèse : le bruit de juge dépend
probablement de la **subjectivité de la tâche de correspondance** (comparaison à un oracle
externe indépendant vs. couverture d'une liste d'AC fermée de la même source), pas seulement
du rappel lui-même.

## Recommandation

**Ne pas généraliser ce protocole à chaque itération.** Le coût est réel : 1 génération + 3
sessions de jugement isolées (~35-40k tokens chacune ici) pour un seul point de mesure sur une
seule US — un ordre de grandeur plus cher qu'un jugement simple, cohérent avec l'avertissement
de l'issue #20 elle-même ("coûteux — mesures décisives seulement, pas chaque itération").

**Quand l'appliquer** (mesures décisives, faible fréquence) :
- Avant une release publique/pilote, sur un échantillon restreint (2-3 US représentatives,
  pas tout le gold-set) — pour donner un intervalle de confiance à un chiffre qui sera cité
  à l'extérieur du projet.
- Quand une décision produit ou une priorisation dépend directement d'un delta de rappel
  précis entre deux versions de skill (le cas exact que `groundtruth-training.md` signale
  comme actuellement non fiable : "34%→47%→33%" n'est pas une vraie trajectoire).
- Après un changement de `istqb-design`/`testbook-generate` jugé structurel (pas un
  amendement ciblé comme #24, déjà couvert par le contrôle échantillonné moins coûteux de
  `istqb-amendments-regression-24.md`).

**Quand ne pas l'appliquer** (routine, itération rapide) :
- Un simple jugement (1 juge, 1 run) reste suffisant pour détecter des défauts qualitatifs
  nets (un AC entièrement manqué, une fabrication, une fuite PII) — ce type de défaut ne se
  perd pas dans le bruit ±15-20 points, il est binaire et visible dès un seul passage, comme
  l'ont montré les balayages multi-modèles (`multimodel-skill-sweep.md`,
  `corpus-24-depth.md`) qui utilisent systématiquement 1 juge par cas et trouvent des défauts
  réels sans avoir besoin d'une médiane à 3.
- Pour du travail de développement quotidien sur les skills, le signal utile est la
  **comparaison intra-run** (train vs held-out, avant vs après un changement dans la même
  session) — déjà identifiée comme fiable dans `groundtruth-training.md` — pas le chiffre
  absolu, qui est précisément ce que ce protocole coûteux sert à stabiliser quand (et
  seulement quand) le chiffre absolu doit être cité de façon décisive.

## Artefacts

- Cahier de test généré (1 seule génération, jugée 3 fois) :
  `eval/baselines/multi-judge-median-testbook/booking.feature`,
  `cancellation.feature`, `coverage-matrix.md`, `synthesis.md`, `00-pipeline-notes.md`.
