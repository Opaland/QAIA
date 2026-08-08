# The automation rubric, applied by blank-context judges for the first time (2026-08-08)

Issue #63, last open checkbox: *« la rubrique LLM n'a jamais été appliquée par un agent. Elle est
écrite, pas validée. Tant qu'un juge à contexte vide ne l'a pas passée sur une vraie suite, elle
ne vaut rien de plus qu'une intention. »*

Two independent judges, dispatched with no generation context, on two suites **neither of them
nor this session had edited** — deliberately not `US-EVAL-001`, whose suite was modified on
2026-08-01, and whose scoring carried a declared conflict for exactly that reason.

| Suite | Total | Gate |
|---|---|---|
| `US-EVAL-002` toolshop checkout | **3 / 12** — three dimensions at 0 | **not met** |
| `US-EVAL-006` the-internet dynamic loading | **8 / 10 judgeable** (dimension 3 `n/a`) | not computable as written — see below |

## The limit of this run, stated first

These judges are agents dispatched by the project. They had **no generation context** — that
specific conflict, the one D136 declared, is removed. They are not independent of the project
itself, and no arrangement of subagents makes them so. What this run establishes is narrower than
"the rubric is validated": **the rubric discriminates, and applying it found more defects in the
rubric than in the code.**

Both judges also disclosed, unprompted, that they hit producer self-grading sections (`## Skill
evaluation — … Verdict: CONFORME`) inside files the rubric requires them to read, and stopped at
the heading. That the rubric's own required inputs contain verdicts a blank-context judge must
avoid is a finding in itself.

## What the judges found in the code

**`US-EVAL-002` — six negative tests that would pass against an app doing the forbidden thing.**
Verified independently before publishing: the file contains **6 `not.toBe(200)` assertions and
zero calls to `GET /invoices`**. Every negative scenario whose `Then` says *"and no invoice is
created"* asserts only that the response was not a 200 — on an endpoint this instance refuses
unconditionally for an unrelated reason (a rejected address). So the assertion is green whether or
not the validation under test exists. Ship an API that accepts a missing `guest_email` and creates
the invoice with a 201, and the suite still reports ✅ PASS.

The judge's sharpest point is not the assertion, it is the missing control: **a negative test
whose positive control is red proves nothing**, and three of these sit next to a `test.fail`-marked
positive.

**`US-EVAL-006` — an assertion that cannot detect the defect its scenario exists for.** Scenario
001's subject is *"Example 1's **pre-existing** hidden element"*, and the coverage matrix gives its
rationale as the *presence-vs-visibility defect class*. The code asserts `toBeHidden()`, which in
Playwright **passes on zero elements**. If Example 1 silently became Example 2 — element created
later instead of pre-existing — the test stays green and the feature's headline distinction becomes
unfalsifiable.

Worth being precise about where the fault lies, because it is the same pattern D136 found: the
scenario's `Then` says only *"Hello World! is not visible"*. **The code is faithful to the `Then`;
the `Then` is weaker than the scenario's stated purpose.** The judge scored fidelity 2 and
assertion-strength 1, which is the correct split — and it means the defect is in the test book
first, inherited by the code.

## What the judges found in the rubric — the larger result

Eight distinct defects across the two runs, several hit independently by both. All are now fixed
in `eval/AUTOMATION-RUBRIC.md`:

| Defect | Fix applied |
|---|---|
| No `n/a`, but a fixed /12 denominator: a book honestly declaring zero negative scenarios makes the gate arithmetically unreachable | `n/a` allowed; gate rescales to ≥ 75 % of judgeable points |
| No aggregation rule — level wordings mix "one test…" and "each scenario…" | **Worst-instance**, stated. Both judges had adopted it independently |
| One defect satisfies the level-0 wording of dimensions 1, 3 and 5 at once — up to a 4-point swing on the judge's discretion | Charge it to the dimension whose *subject* it is, name it once elsewhere, and say which |
| Dimension 3 keyed on the `@negative` tag, so an untagged scenario claiming absence escapes it | Rewritten tag-independent: *assertions that would survive an inert app* |
| Dimension 3 said nothing about positive controls | A negative with a red positive control cannot score 2 |
| Dimension 4 gave no rule for a flag carried on the wrong scenario, nor for `test.fail` | Flag must be on the flagged scenario; `test.fail` does not excuse an unflagged assertion |
| `mutation.status = "skipped"` unhandled — the guardrail only scripted `blocked` | Any non-completed mutation state triggers the same mandatory sentence; `skipped` named as the weaker state |
| The judge/tool boundary is blurrier than "don't re-score what a machine counts": `not.toBe(200)` is a real assertion by static count and vacuous against the spec | Written down: the tool judges assertion **shape**, the judge judges assertion **vacuity against the specification** |

Two further defects are **recorded and not fixed**, because they are scope decisions rather than
wording:

- **Tests that trace to no scenario are outside every dimension.** `a11y.toolshop-checkout.spec.js`
  contributes 3 of 14 tests and no dimension covers them; the tool reported
  `testbook_scenarios: 0`. Neither judge nor machine looked at a fifth of the suite.
- **Dimension 2's ladder has a hole**: level 0 needs a literal that contradicts the source *or* an
  assumption encoded as a requirement; level 1 needs one that is *plausible **and** harmless*. An
  unsourced-but-plausible literal that is load-bearing for six other tests is neither. One judge
  went to 0 and said another would defensibly say 1 — a one-point swing on wording alone.

## What this does not settle

- The campaign suites were **not modified**. They are evaluation evidence; correcting them would
  destroy the record of what the generator produced. The findings are recorded here and belong in
  the generator's next pass, not in a retrofit.
- Neither judge ran the code. Both said so. `mutation.status` is `skipped` on both suites, so
  **neither suite's assertions have been shown to be load-bearing** — the rubric now forces that
  sentence into every output where it applies.
- Two suites, not the four the issue names. `US-EVAL-013` and the rest are unjudged.

---

## Troisième juge, même jour :  — 2/12

Dispatché après la révision, pour éprouver les règles fraîchement écrites. Il les a appliquées
**et il en a cassé une**.

Le constat le plus lourd, vérifié à la main :  et  assèrent
 pour un scénario dont le  exige l'alerte
*« Your token has expired, please login again. »* **et** l'absence de *« Product added. »*.
La chaîne  a une longueur supérieure à zéro : **le test passe contre le
comportement exact qu'il existe pour interdire.** Une régression qui supprimerait la branche
d'erreur laisserait 8/8 au vert et la table de traçabilité afficherait PASS.

Trois défauts de plus dans la rubrique, tous corrigés le jour même :

1. **La règle « compter un défaut une seule fois » ne disait pas ce que devient l'autre
   dimension.** Ses niveaux sont écrits comme des universels (« *chaque* test assère… »), donc
   après avoir chargé un défaut ailleurs, on ignore si la dimension peut encore revendiquer
   l'universel. Le juge a documenté les deux lectures et le point d'écart que ça produit — soit
   exactement la variance que la révision voulait supprimer. Tranché : la dimension est notée sur
   ses instances restantes et **peut atteindre 2**.
2. **La clause « contrôle positif vert » est invérifiable** avec les entrées que le protocole
   donne au juge : ni le cahier, ni le code, ni le JSON statique ne contiennent de résultat
   d'exécution. Corrigé dans les deux sens — les résultats de run sont ajoutés aux entrées quand
   ils existent, et à défaut le juge doit dire qu'il a vérifié l'existence du contrôle et non son
   résultat.
3. **Le rapport de run est à la fois une entrée obligatoire et un document d'auto-évaluation.**
   Les trois juges ont heurté une section d'auto-notation du producteur et l'ont signalée
   spontanément. Le protocole dit maintenant : lire le rapport, s'arrêter au premier titre qui
   note le producteur.

Bilan des trois applications : **trois suites jugées, aucune ne franchit la porte** (3/12, 8/10
jugeables, 2/12), et **onze défauts trouvés dans la rubrique** contre cinq dans le code. Une
rubrique non éprouvée mesure surtout la confiance qu'on lui accorde.
