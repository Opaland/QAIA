# feedback — pilot run (issue #7 continuation)

**Date : 2026-07-25. Version qaia-core au moment du run : 0.2.14.**

## Objet

`plugins/qaia-core/README.md` (§ "Token budget — ordre de grandeur (issue #7)") liste
`feedback` parmi les skills **estimées** (~5–20k, non mesurée) — la table y indique
explicitement que 10 skills ont désormais une mesure réelle et que `prioritize` et `feedback`
restent le solde ouvert. Ce fichier documente un **run pilote fidèle** de `feedback`, exécuté du
début à la fin selon la méthode déjà établie (voir le README, "Méthode de mesure" — pas de
raccourci), pour servir de substrat à une future mesure. **Ce fichier ne rapporte pas de chiffre
de tokens** : la méthode déjà validée par les 10 skills mesurées est explicite là-dessus — le
chiffre doit être lu par l'infrastructure d'orchestration au niveau au-dessus de l'agent, jamais
une auto-déclaration de l'agent (qui n'a aucun accès fiable à son propre compteur — vérifié
activement dans les pilotes précédents, pas seulement supposé : aucune variable d'environnement
ni aucun outil accessible à l'agent délégué n'expose son propre total). `plugins/qaia-core/README.md`
lui-même n'est pas modifié par ce pilote (le mainteneur reste seul juge du moment où une mesure
rejoint la table).

## Cas d'usage choisi

US-004 (`eval/gold-set/US-004-expense-approval.md`) — workflow d'approbation de notes de frais.
Choisi parce que son parcours complet (ingestion → export) existe déjà dans le repo, intact,
sous `examples/expense-demo/qaia-journey/` (fixture de démo déjà committée) : `feedback` a un
vrai cahier de tests généré à comparer, exactement le prérequis que `SKILL.md` exige ("A
generated test book to compare against ... from `testbook-generate`. If none exists — no
checkpoint, no test book — say so").

## Préparation — copie vers l'emplacement canonique `.qaia/`

`skills/README.md` fixe le contrat de chemin : les skills lisent/écrivent sous `.qaia/` à la
racine du projet (`state/<US-ID>/`, `testbooks/<US-ID>/`, `feedback/`), pas sous un chemin de
fixture d'exemple. `.qaia/` n'existait pas encore dans ce worktree (vérifié avant copie). Avant
d'exécuter `feedback`, l'état complet de `examples/expense-demo/qaia-journey/` a donc été copié
tel quel vers `.qaia/` :

```
.qaia/state/US-004/       ← copié depuis examples/expense-demo/qaia-journey/state/US-004/
.qaia/testbooks/US-004/   ← copié depuis examples/expense-demo/qaia-journey/testbooks/US-004/
```

`.qaia/` est ignoré par git (`.gitignore:15`) — cette copie ne pollue pas l'arbre versionné ;
seul le livrable produit par le run (voir plus bas) est committé, sous un chemin de preuve
dédié, à l'identique du patron des pilotes précédents (`oracle-generate-token-pilot`,
`us-review-token-pilot`, `need-understanding-token-pilot`).

## Fidélité du run

Skill exécutée intégralement, étapes 1 à 6 de `plugins/qaia-core/skills/feedback/SKILL.md` :

1. **Collect** — le cahier généré (`.qaia/testbooks/US-004/*.feature`, `synthesis.md`,
   `coverage-matrix.md`) relu pour identifier des points de correction plausibles et réalistes.
   Session non interactive (pas de testeur humain réel disponible) : conformément à la
   consigne de ce pilote, les corrections elles-mêmes sont **inventées** — un usage typique
   simulé, jamais un run vide sans aucune correction. 4 corrections capturées, chacune ancrée à
   un ou plusieurs IDs de scénario réels du cahier (`@QAIA-US-004-012`, `013`, `024`–`027`),
   avec quoi, pourquoi et forme corrigée.
2. **Classify** — 2 `business-rule` (`US-004-1`, `US-004-2`, même famille de règle FX), 1
   `style` (`US-004-3`), 1 `one-off` (`US-004-4`).
3. **Store examples** — 4 fichiers écrits sous `.qaia/feedback/examples/US-004-{1..4}.md`,
   provenance et classification en frontmatter.
4. **Propose promotions** (D22) — les deux chemins de la règle sont exercés dans ce pilote :
   - `BR-KB-001` promue via le **seuil de récurrence** (`US-004-1` + `US-004-2` : même règle FX
     capturée deux fois, ≥ 2 exemples, seuil D22 atteint) ;
   - `BR-KB-002` promue via le **chemin de demande explicite** ("l'utilisateur demande une
     promotion immédiate", critère unique alternatif du step 4) — une seule instance capturée
     (`US-004-3`), promue sans attendre une récurrence.
   `US-004-4` (`one-off`) n'est **pas** proposée à la promotion — ni récurrence ni demande
   explicite, conformément à la garde-fou "never promote without explicit validation, even for
   'obvious' corrections" (aucune promotion silencieuse par défaut).
   ⚠ VALIDATION à chaque point : run non interactif, donc `simulated: accepted` (`US-004-1`,
   `US-004-2`, `US-004-4`) et `simulated: accepted, immediate promotion requested` (`US-004-3`),
   conformément à la règle 3 du contrat partagé (statut de première classe, pas un saut
   silencieux).
5. **Prune** — les 3 exemples sources des 2 règles promues marqués `status: promoted` dans leur
   frontmatter ; aucun exemple de plus de 6 mois dans ce store neuf (premier run), donc rien à
   archiver.
6. **Close the loop** — `.qaia/feedback/rules.md` liste, pour chacune des deux règles promues,
   les scénarios existants du cahier qui devront être régénérés (`testbook-generate`, hors
   scope de ce pilote) pour appliquer la règle : 3 scénarios pour `BR-KB-001` (portée AC6), les
   17 scénarios `@negative` du cahier pour `BR-KB-002` (portée transversale, convention de
   style). `.qaia/state/US-004/journey.md` mis à jour avec une nouvelle ligne `07-feedback:
   done`.

## Écart au contrat noté honnêtement (comme les pilotes précédents)

`SKILL.md` step 4 prévoit qu'une promotion approuvée est **transmise à `rag-build`**, qui
l'écrit dans `knowledge/business-rules.md`, met à jour `knowledge/index.md`, et exécute la
vérification de contradiction avec toute règle existante (garde-fou Q31). **`rag-build` n'a pas
été exécutée dans ce pilote** — `expense-demo` n'a pas de `knowledge/` dans ce worktree (mode
dégradé, règle 8 du contrat partagé — noté explicitement, jamais supposé silencieusement) donc
il n'y a pas non plus de règle existante à contredire. `BR-KB-001` et `BR-KB-002` n'existent
donc qu'au niveau de `feedback/rules.md` tant que `rag-build` ne les a pas matérialisées dans la
base de connaissance — un futur run d'`istqb-design` sur US-004 ne les récupérerait pas encore.
Ceci est cohérent avec le scope de ce pilote (mesurer `feedback` seule, pas la chaîne complète
`feedback` → `rag-build` → `istqb-design`).

## Garde-fous vérifiés

- **Aucune promotion sans validation explicite** : les 2 règles promues portent chacune leur
  chemin de validation (seuil de récurrence ou demande explicite) ; `US-004-4` reste un exemple
  non promu, pas de promotion par défaut d'une correction "évidente".
- **Provenance obligatoire** : chaque exemple cite le(s) ID(s) de scénario concerné(s), la
  classification, et le statut de validation (`simulated: ...`).
- **Aucune PII, aucun secret** : les corrections portent sur une politique métier FX et une
  convention Gherkin ; aucune donnée personnelle ou sensible en jeu (US-004 n'en contient pas).
- **Pas d'effet de bord hors `.qaia/`** : le run n'a touché que `.qaia/feedback/` et
  `.qaia/state/US-004/journey.md` ; aucun fichier du cahier généré (`.qaia/testbooks/US-004/*.feature`)
  n'a été réécrit par `feedback` elle-même (ce n'est pas son rôle — c'est `testbook-generate`
  qui régénère, sur la base des règles promues, lors d'un futur passage).

## Livrable produit

- `eval/baselines/feedback-token-pilot/US-004/feedback/examples/US-004-{1,2,3,4}.md` — les 4
  corrections capturées (étapes 1–3 du skill).
- `eval/baselines/feedback-token-pilot/US-004/feedback/rules.md` — les 2 règles promues
  (`BR-KB-001`, `BR-KB-002`), leur provenance, les scénarios flagués pour régénération, et le
  gap `rag-build` noté honnêtement (étapes 4–6 du skill).
- `eval/baselines/feedback-token-pilot/US-004/journey.md` — ledger complet du parcours US-004
  jusqu'à `07-feedback: done` inclus.

## Suite possible (hors scope de ce pilote)

Si le mainteneur souhaite faire rejoindre `feedback` aux 10 skills déjà mesurées de
`plugins/qaia-core/README.md`, ce run peut être rejoué sous l'instrumentation qui a produit les
mesures existantes (agent dédié, chiffre lu par l'infrastructure d'orchestration) — ce document
n'anticipe pas ce chiffre. Un futur pilote pourrait aussi enchaîner `rag-build` par-dessus ce
run pour combler le gap noté ci-dessus et mesurer la chaîne `feedback` → `rag-build` complète.
