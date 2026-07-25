# report — pilot run (issue #7 continuation)

**Date : 2026-07-25. Version qaia-core au moment du run : 0.2.15.**

## Objet

`plugins/qaia-core/README.md` (§ "Token budget — ordre de grandeur (issue #7)") liste `report`
parmi les 4 skills encore **estimees** (~10-40k, non mesuree), aux cotes de `prioritize`,
`testbook-validate` et `feedback`. Ce fichier documente un **run pilote fidele** de `report`,
execute du debut a la fin selon la methode deja etablie (voir le README, "Methode de mesure" -
pas de raccourci), pour servir de substrat a une future mesure. **Ce fichier ne rapporte pas de
chiffre de tokens** : la methode deja validee par les 10 skills mesurees est explicite la-dessus
- le chiffre doit etre lu par l'infrastructure d'orchestration au niveau au-dessus de l'agent,
jamais une auto-declaration de l'agent (qui n'a aucun acces fiable a son propre compteur). Cet
agent n'a pas cet acces ; il produit le run et le livrable, pas le chiffre.
`plugins/qaia-core/README.md` lui-meme n'est pas modifie par ce pilote (le mainteneur reste seul
juge du moment ou une mesure rejoint la table).

## Cas d'usage choisi

US-004 (workflow d'approbation de notes de frais) - dont le parcours complet (ingest -> design ->
priorites -> generation du cahier -> export) existait deja, produit lors d'une session anterieure,
sous `examples/expense-demo/qaia-journey/`. Choisi parce que c'est le seul parcours US-004
complet du repo (8 AC, 37 conditions, 38 scenarios, 4 fichiers `.feature`) et qu'il exerce
`report` sur un cahier de taille reelle plutot qu'un stub.

## Etape prealable - mise a l'emplacement canonique

`report` lit ses artefacts sous `.qaia/` (contrat de chemin, `plugins/qaia-core/skills/README.md`),
pas sous `examples/expense-demo/qaia-journey/` (racine de sortie propre a cette demo, rule 9 du
contrat partage). Avant d'executer la skill, l'etat complet a ete copie verbatim (aucune
modification de contenu) vers l'emplacement par defaut :

- `examples/expense-demo/qaia-journey/state/US-004/` -> `.qaia/state/US-004/`
- `examples/expense-demo/qaia-journey/testbooks/US-004/` -> `.qaia/testbooks/US-004/`

## Fidelite du run

Skill executee integralement, etapes 1 a 6 de `plugins/qaia-core/skills/report/SKILL.md` :

1. **Read the source artifacts** - les 4 `.feature` (`.qaia/testbooks/US-004/*.feature`,
   hors sous-dossier `export/` qui n'est qu'une projection dupliquee), `coverage-matrix.md`,
   `03-design.md`, `synthesis.md` et `02-understanding.md` lus integralement, jamais
   regeneres. Comptages faits directement sur les blocs `Scenario:`/tags plutot que recopies
   depuis la prose des documents (voir garde-fou "les comptages doivent correspondre au
   cahier" ci-dessous).
2. **Compute the counts** - aucun chiffre estime :
   - `scenarios.total` = 38 (compte direct des blocs `Scenario:`), `smoke` = 1 (`@smoke` sur
     `@QAIA-US-004-001` uniquement), `outlines` = 0 (aucun `Scenario Outline` dans ce cahier).
   - `byPriority` = {P1:18, P2:15, P3:4}, somme 37 = `total` moins `smoke`, conformement a la
     regle de comptage de `testbook-generate` (le journey `@smoke` est exclu de la comptabilite
     d'atomicite/priorite, `SKILL.md` de `testbook-generate`, ligne 14/18) - le tag brut `@P1`
     apparait 19 fois (incluant le scenario smoke qui porte aussi `@P1`), ramene a 18 une fois
     le smoke exclu.
   - `negative` = 17 (tags `@negative`, comptage direct par fichier : 3+5+4+5) - identique a
     `reqNegTotal`/`reqNegCovered` = 17/17 (`coverage-matrix.md` : "17/17 - gate satisfied,
     ADR 0001").
   - `negativeRatio` = 17/37 = 0.459 (D20 - signal rapporte, jamais un seuil).
   - `acTotal`/`acCovered` = 8/8 (`coverage-matrix.md` : "all 8 AC have >= 2 scenarios each").
   - `techniques` = les 6 tags de technique effectivement presents dans le cahier (`use-case`,
     `ep`, `boundary`, `decision-table`, `state-transition`, `error-guessing`) - pas de
     `pairwise` dans ce cahier.
   - `oracles` = `[]` - aucun tag `@oracle:*` dans ce cahier (le pilote `oracle-generate` sur
     US-004, `eval/baselines/oracle-generate-token-pilot/`, est un run **separe**, jamais
     fusionne dans ce cahier canonique - verifie par grep, aucune correspondance).
   - `knowledgeApplied` = `[]` - `03-design.md` le dit explicitement ("knowledge base absent
     for this project slice... `design.knowledgeApplied` will be empty in the manifest").
   - `openQuestions`/`assumptions` = 5/4 - repris de la classification agregee deja validee a
     deux endroits independants (`journey.md` et `synthesis.md` : "9 questions (5 open, 4
     assumption)"), Q4 etant compte une fois sous "open" dans cet agregat bien qu'il porte une
     sous-partie `[assumption]` (le fallback) documentee separement dans `02-understanding.md`.
   - `simulated` = 4 - nombre de points VALIDATION distincts au niveau des checkpoints,
     chacun recense `simulated: <defaut applique>` (`00-source.md`, `01-extraction.md`, le
     point agrege de `02-understanding.md`, `04-priorities.md`).
3. **Merge, don't clobber** - aucun `manifest.json` preexistant sous `.qaia/reports/US-004/`
   dans ce worktree ; ecriture initiale, pas de fusion necessaire.
4. **Fill `openArbitrations`** - 12 entrees : les 2 acceptations de checkpoint simulees
   (`00-source`, `01-extraction`), les 5 questions `[open]` (Q1, Q2, Q4, Q6, Q7) et les 4
   `[assumption]` appliquees non-interactivement (Q3, Q5, Q8, Q9) comme `kind: "simulated"`,
   plus l'acceptation de `04-priorities` (scores + decision de portee pleine largeur). Chaque
   entree cite son `sourceCheckpoint`, conformement a la regle 3 du contrat partage ("every
   simulated entry appears in the synthesis's arbitration list as pending human review").
5. **Write** `.qaia/reports/US-004/manifest.json`.
6. **Report** - voir "Ligne de tete" ci-dessous.

### Ecart honnete note (comptage vs prose)

`synthesis.md`, section "Review order", enumere 10 scenarios `@low-confidence`
(007, 009, 010, 014, 015, 016, 023, 025, 026, 027) - mais le comptage direct des tags
`@low-confidence` dans les `.feature` trouve **11** occurrences, la liste omettant le scenario
**018** (`AC4-C2`, `@low-confidence` citant Q5, present et verifie dans `line-items.feature`
ligne 15). Conformement au garde-fou de `report` ("Counts must match the book... the artifacts
win: stop and surface the discrepancy rather than writing numbers that lie"), le manifeste porte
`confidence.lowConfidence: 11` (comptage reel sur les `.feature`), pas 10 (chiffre de la prose de
`synthesis.md`). Cet ecart est un defaut mineur pre-existant de `synthesis.md` (liste manuelle
incomplete), pas une erreur introduite par ce pilote - signale ici plutot que silencieusement
lisse.

### Convention de comptage `openArbitrations` / `confidence.simulated`

Le schema (`docs/OUTPUT-CONTRACT.md`) et l'exemple existant `examples/scoring-demo/manifest.json`
ne couvrent qu'un cas a faible cardinalite (1 open + 1 simulated sur 4 assumptions au total) et
ne tranchent pas explicitement si `confidence.simulated` compte chaque item individuellement
defaulte ou chaque **point de checkpoint** VALIDATION. Ce pilote retient la seconde lecture
(comptage par checkpoint : 4 points distincts) parce qu'elle correspond litteralement a la
structure des fichiers d'etat (VALIDATION apparait une fois par fichier, pas une fois par
question) - mais `openArbitrations` liste bien **chaque** item individuel dans les checkpoints
concernes (les 9 questions Q1-Q9, separement des 2 acceptations de document), en application
litterale de la regle 3 du contrat partage citee ci-dessus. Un futur mainteneur pourrait
legitimement choisir une autre convention ; elle est documentee ici pour etre auditee plutot que
silencieuse.

## Garde-fous verifies

- **Jamais de self-scoring** : le bloc `gate` n'a pas ete ecrit - absent du manifeste, comme
  prescrit ("gate is filled by qaia-score, not here").
- **Aucun secret, aucune PII, aucune source brute** : le manifeste ne porte que des comptages,
  IDs, chemins et un extrait court (`about`) par arbitration - jamais le texte integral des
  questions ni de donnee personnelle (il n'y en a d'ailleurs aucune dans US-004,
  `00-source.md` : "no direct personal/sensitive data found").
- **Les comptages correspondent au cahier** : chaque nombre du manifeste a ete recalcule
  directement sur les `.feature`/`coverage-matrix.md`/`03-design.md`/`02-understanding.md`, pas
  recopie aveuglement depuis `synthesis.md` (voir l'ecart note ci-dessus).
- **Contrat 1.0** stampe, conforme a `docs/OUTPUT-CONTRACT.md` en vigueur (aucun changement de
  version du contrat par ce pilote).

## Ligne de tete (etape 6 de la skill)

US-004 - 38 scenarios (18 P1 / 15 P2 / 4 P3, hors smoke) - couverture AC 8/8 - gate
negatif-requis 17/17 (ADR 0001, satisfait) - 12 arbitrations ouvertes (5 questions `[open]`
encore non tranchees + 7 acceptations/defauts simules en attente de revue humaine). Le verdict
`gate` reste a remplir par `qaia-score` - non ecrit ici.

## Livrable produit

- `eval/baselines/report-token-pilot/US-004/manifest.json` - manifeste produit par les etapes
  1 a 5 de la skill (copie exacte de `.qaia/reports/US-004/manifest.json`, l'emplacement
  canonique reellement ecrit pendant le run).

## Suite possible (hors scope de ce pilote)

Si le mainteneur souhaite faire rejoindre `report` aux 10 skills deja mesurees de
`plugins/qaia-core/README.md`, ce run peut etre rejoue sous l'instrumentation qui a produit les
10 mesures existantes (agent dedie, chiffre lu par l'infrastructure d'orchestration) - ce
document n'anticipe pas ce chiffre.
