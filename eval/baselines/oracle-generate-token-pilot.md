# oracle-generate — pilot run (issue #7 continuation)

**Date : 2026-07-25. Version qaia-core au moment du run : 0.2.14.**

## Objet

`plugins/qaia-core/README.md` (§ "Token budget — ordre de grandeur (issue #7)") liste
`oracle-generate` parmi les skills **estimées** (~20–60k, non mesurée) — la table y indique
explicitement que 5 skills seulement ont une mesure réelle et que le reste demeure ouvert.
Ce fichier documente un **run pilote fidèle** de `oracle-generate`, exécuté du début à la fin
selon la méthode déjà établie (voir le README, "Méthode de mesure" — pas de raccourci), pour
servir de substrat à une future mesure. **Ce fichier ne rapporte pas de chiffre de tokens** :
la méthode déjà validée par les 5 skills mesurées est explicite là-dessus — le chiffre doit être
lu par l'infrastructure d'orchestration au niveau au-dessus de l'agent, jamais une auto-
déclaration de l'agent (qui n'a aucun accès fiable à son propre compteur). Cet agent n'a pas cet
accès ; il produit le run et le livrable, pas le chiffre. `plugins/qaia-core/README.md`
lui-même n'est pas modifié par ce pilote (le mainteneur reste seul juge du moment où une mesure
rejoint la table).

## Cas d'usage choisi

US-004 (`eval/gold-set/US-004-expense-approval.md`) — workflow d'approbation de notes de frais.
Choisi plutôt que de rejouer `examples/oracle-demo/` (déjà présent, déjà Luhn) pour exercer la
skill sur un cas neuf : deux ACs touchent des domaines standardisés que la bibliothèque
d'oracles couvre mais que le repo n'avait pas encore illustrés dans un run réel :

- **AC6** (conversion de devise autre qu'EUR) → oracle **ISO 4217**.
- **AC4** (date de ligne dans les 90 derniers jours) → oracle **ISO 8601**.

## Fidélité du run

Skill exécutée intégralement, étapes 1 à 4 de `plugins/qaia-core/skills/oracle-generate/SKILL.md` :

1. **Detect** — les 8 ACs de US-004 passées au crible de la table de déclencheurs du skill ;
   2 correspondances retenues (AC6/ISO 4217, AC4/ISO 8601), les 6 autres ACs n'appellent aucun
   oracle de la bibliothèque (pas de carte, email, statut HTTP, IBAN ou code pays dans cette US)
   — pas de couverture inventée là où la source n'en appelle pas.
2. **⚠ VALIDATION** — run non interactif (contexte d'évaluation, pas d'humain dans la boucle) :
   conformément à la règle 3 du contrat partagé (`plugins/qaia-core/skills/README.md`), chaque
   point de validation est enregistré `simulated: accepted`, jamais silencieusement sauté.
3. **Emit** — 6 scénarios Gherkin émis, chacun tagué `@oracle:iso4217` ou `@oracle:iso8601` avec
   un commentaire `# oracle:` citant la source ; 2 des 6 portent une question `[open]` réelle
   (Q1, Q2) plutôt qu'un `Then` inventé, conformément au guardrail "never invent".
4. **Record** — provenance consignée dans le fichier de conditions de conception, avec la
   phrase de synthèse type (style D31) citant les IDs de cas fondés sur l'oracle.

**Écart au contrat de journey noté honnêtement** : aucun checkpoint `.qaia/state/US-004/`
n'existait dans ce worktree (US-004 n'a pas été rejouée ici via `us-ingest`/`us-review`/
`istqb-design`). Conformément à la règle 2 du contrat partagé ("prérequis manquant → propose,
n'échoue pas"), l'étape 1 a lu directement le texte des ACs du gold set à la place du
checkpoint `01-extraction.md` absent — noté explicitement (règle 8, "modes dégradés explicites"),
jamais fait passer pour un run de bout en bout sur la chaîne complète des skills.

## Garde-fous vérifiés

- **Aucune valeur inventée** : les codes ISO 4217 et les dates ISO 8601 utilisés proviennent
  verbatim de `plugins/qaia-core/skills/oracle-generate/oracles/library.md` (mêmes faits déjà
  utilisés par `examples/oracle-demo/`), pas de nouvelles valeurs calculées ad hoc pour ce
  pilote hormis leur application aux ACs de US-004.
- **Provenance obligatoire** : chaque scénario porte son tag `@oracle:*` et son commentaire
  `# oracle:`.
- **Réseau borné** : aucun accès réseau — bibliothèque encodée uniquement, pas d'oracle projet
  (pas de fichier OpenAPI désigné pour cette US).
- **2 questions ouvertes** au lieu de 2 `Then` devinés (Q1 : arrondi/rejet d'un montant dont la
  précision ne respecte pas l'unité mineure de sa devise ; Q2 : date vs date-heure ISO 8601 pour
  la fenêtre de 90 jours) — cohérent avec le principe "un oracle est une citation, jamais une
  supposition".

## Livrable produit

- `eval/baselines/oracle-generate-token-pilot/US-004-design-conditions.md` — détection,
  proposition (validation simulée) et provenance (étapes 1, 2, 4 du skill).
- `eval/baselines/oracle-generate-token-pilot/US-004-oracle-cases.feature` — 6 scénarios Gherkin
  ancrés à l'oracle (étape 3 du skill), tagués `@oracle:iso4217` / `@oracle:iso8601`, dont 2
  `@low-confidence` portant une question ouverte plutôt qu'un résultat inventé.

## Suite possible (hors scope de ce pilote)

Si le mainteneur souhaite faire rejoindre `oracle-generate` aux 5 skills déjà mesurées de
`plugins/qaia-core/README.md`, ce run peut être rejoué sous l'instrumentation qui a produit les
5 mesures existantes (agent dédié, chiffre lu par l'infrastructure d'orchestration) — ce
document n'anticipe pas ce chiffre.
