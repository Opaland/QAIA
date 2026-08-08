# Validation — `automation_score.py`, the two static checks added 2026-08-08

Companion to `../automation-score/VALIDATION.md`, which proves the mutation track. This one
proves the two checks that came out of the first four blank-context applications of
`eval/AUTOMATION-RUBRIC.md`.

## Why these two exist

Both were found by human-language judges reading code, in defects the tool walked straight past:

- **`flag-dropped`** — two of the four suites judged carried scenarios the test book marked
  `@low-confidence` / `# open: Q…`, whose generated tests carried no trace of it. The severity is
  not in the code, it is in what happens later: when such a test goes red, the reader cannot tell
  *"the open question just got answered"* from *"the product regressed"*, and the cheapest
  resolution is to edit the expected value to match the application — **silently converting a
  finding into a specification.** Blocking.
- **`single-sided-evidence`** — three of the four suites contained tests whose *entire* evidence
  was "not the success value": `expect(alertText.length).toBeGreaterThan(0)` for a scenario
  demanding a specific alert *and* the absence of `"Product added."` (that string is 13 characters
  long, so the test passes against the forbidden behaviour), or `not.toBe(200)` against an endpoint
  that refuses unconditionally for an unrelated reason. Reported, **never blocking** — see the
  boundary note below.

## The boundary, and why one blocks and the other does not

The rubric states that the tool judges assertion **shape** and the judge judges assertion
**vacuity against the specification**. Whether a one-sided assertion is vacuous depends on what
its scenario claimed, which this tool cannot read. So the tool reports the shape fact — *this
test's whole evidence is one-sided* — and hands it to the judge rather than deciding.

A dropped flag is different: it is a straight comparison of two artifacts the tool already reads.
The book says this scenario rests on an open question; the code does not. No interpretation is
involved, so it blocks.

`single-sided-evidence` fires only when **every** assertion in the test is one-sided. A test that
asserts `not.toBe(200)` and then reads the error body is not flagged — the extra assertion is the
attributable evidence the check exists to look for.

## The fixture

`testbook/flags.feature` declares four scenarios; `tests/flags.spec.js` implements all four. Two
of the four are traps, and the other two exist so a check that fires on everything is caught.

| Scenario | Book | Code | Expected finding |
|---|---|---|---|
| `FIX-001` | `@low-confidence` + `# open: Q1` | no mention | **`flag-dropped`, blocking** |
| `FIX-002` | not flagged | no mention | none — nothing to carry |
| `FIX-003` | `@negative` | sole assertion `not.toBe(200)` | **`single-sided-evidence`**, non-blocking |
| `FIX-004` | `@low-confidence` | comment says *open: Q1, unconfirmed, human arbitration pending* | none — the flag is carried |

## Real run

```
$ python eval/tools/automation_score.py \
    --tests-dir eval/tools/fixtures/automation-score-static/tests \
    --testbook  eval/tools/fixtures/automation-score-static/testbook --skip-mutation

blocking: True
  flag-dropped          | flags.spec.js:11 | QAIA-FIX-001 rests on an open question in the test book…
  single-sided-evidence | flags.spec.js:20 | every assertion in this test is one-sided (not.toBe(…))
  pom-missing           | .:0              | automate SKILL.md mandates POM-as-fixtures; pages/ missing
  no-selector-detected  | .:0              | no locator call found in specs or page objects
```

Four scenarios in, exactly the two intended findings out, on the two intended lines. `FIX-002`
and `FIX-004` are silent, which is the half of the proof that matters: a check that fires on
everything discriminates nothing.

The last two findings are artefacts of a minimal fixture — it has no page objects and no real
locators because it never opens a browser. They are noise here and real findings anywhere else;
recorded rather than filtered, so nobody later mistakes the filtering for a bug.

## Verified against the real corpus, not only the fixture

| Suite | `flag-dropped` | `single-sided-evidence` |
|---|---|---|
| `US-EVAL-013-mobile` | **5** — exactly the five scenarios the judge found by hand (001, 002, 003, 014, 016) | 0 |
| `US-EVAL-004-juiceshop` | 3 — the two the judge named plus the one it called "least-bad but still untagged" | 0 |
| `US-EVAL-008-demoblaze` | 2 | 3 — including the two `length > 0` tests the judge called the suite's most serious defect |
| `US-EVAL-002-toolshop` | 1 | 4 |
| `US-EVAL-001-saucedemo` (corrected suite) | **0** | **0** — no false positive |

`US-EVAL-002` deserves a note: the judge counted **six** `not.toBe(200)` assertions, the tool
reports **four** tests. Both are right — two of those assertions sit in tests that carry other
evidence as well, and the whole-evidence rule correctly leaves them alone.

## A third check, and a tool bug it uncovered

**`dead-citation`** came from the fifth judge run: a page object carried *"a real finding, see
automation/NOTES.md"* and no such file was ever written. Same failure mode as a false claim in the
run report — evidence offered that cannot be inspected — one file over. Cheap to check, impossible
to argue with, and it decays silently: a citation looks authoritative precisely because nobody
follows it.

Adding it exposed a **real defect in this tool**. It found nothing at first, because the citation
lives in `automation/pages/` while `--tests-dir` points at `automation/tests/` — and the tool only
ever looked *under* `tests_dir`. Two suite layouts exist in this corpus (`tests/{pages,specs}` and
`automation/{tests,pages}`) and the tool understood one. Consequences, now fixed:

- `pom-missing` was reported on suites whose `pages/` sat one level up. **Two independent judges
  flagged it as a probable tool bug before anyone checked** — they were right.
- Selectors and citations in those page objects were invisible to every check.

After the fix, `US-EVAL-013` loses its false `pom-missing` and its static score moves 80.0 → 93.4;
`US-EVAL-004` keeps its `pom-missing` because it genuinely has no `fixtures.js`, and gains the
`dead-citation` the judge found by reading.

## What this does not prove

The tool now catches these two shapes. It does **not** catch the other defects those four judges
found — an assertion faithful to a `Then` that is itself weaker than its scenario's purpose, a
literal with no provenance, a test project listed as used that ran nothing. Those needed reading
comprehension, and they are why the semantic judge stays.

## Passe sur nos propres exemples — et le controle avait tort

Les trois controles n'avaient jamais ete lances sur les suites vitrines du projet, seulement sur
le corpus de campagne. C'etait un trou : nos exemples sont ce qu'un visiteur lit en premier, et
rien ne garantissait qu'ils ne portaient pas les defauts qu'on venait d'apprendre a signaler.

Resultat :  95,3/100 et  95,2/100, **aucun constat
bloquant**, aucun , aucun . Les suites vitrines tiennent.

**Mais  s'est declenche a tort**, sur  :

>  (ARIA requires it even when empty, see app.js)

C'est une reference en prose a un fichier que le lecteur connait — , qui existe bien, sous
. Ce n'est pas une citation vers un emplacement que l'outil peut resoudre. Le motif
exigeait un nom de fichier ; il exige desormais **un separateur de chemin**.  ne
declenche plus,  declenche toujours.

Verifie dans les trois sens apres correction : faux positif disparu de la vitrine, vrai constat
maintenu sur , fixture avant/apres du generateur toujours discriminante (quatre
classes avant, zero apres).

**Cinquieme fois de la semaine qu'un garde-fou du projet attrape son auteur** — et la premiere ou
il l'attrape en ayant tort. Un controle trop large coute la meme chose qu'un controle absent : on
apprend a ignorer ce qu'il dit.
