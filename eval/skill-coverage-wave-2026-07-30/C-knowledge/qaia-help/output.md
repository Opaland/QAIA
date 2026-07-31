# qaia-help — actual output of the run

Skill: `plugins/qaia-core/skills/qaia-help/SKILL.md` (read-only; nothing was modified).
Run: 2026-07-30. Two inspections were performed, because the first one found nothing.

---

## Inspection A — repository root (the default `.qaia/` lookup)

```
$ ls -d .qaia
ls: cannot access '.qaia': No such file or directory
$ find . -name ".qaia"
(no output)
```

**No `.qaia/` exists anywhere in the QAIA repository.** Per SKILL.md step 4, this is the
"no `.qaia/` at all" branch → present the three engagement models:

- **QAIA Lite** — paste a US, generate a test book directly (`testbook-generate`).
- **QAIA Solo** — the full journey without a team knowledge base.
- **QAIA Full** — initialize `rag-build` first, then run the journey.

Recommendation for this repository: **none of the three**, and that is the honest answer. This
repo is QAIA's *own source*, not a project under test; recommending an engagement model here
would be a category error the skill's step 4 has no branch for.

---

## Inspection B — re-based on `eval/skill-eval-campaign-2026-07-29/` (shared contract rule 9)

The skill's own allowlisted globs, run verbatim against that root:

```
$ ls state/*/journey.md   -> No such file or directory
$ ls knowledge/index.md   -> No such file or directory
$ ls feedback/rules.md    -> No such file or directory
$ ls -d testbooks/*/      -> No such file or directory
```

**All four allowlisted paths miss.** The real artifacts are laid out as
`<US-ID>/state/journey.md` and `<US-ID>/testbooks/` — the US-ID segment sits *above* `state/`,
not inside it, the inverse of the contract layout (`.qaia/state/<US-ID>/journey.md`). This is a
deviation of the evaluation harness from the shared contract, not of `qaia-help`; it is recorded
because it means **zero contract-shaped QAIA projects exist in this repository** for the skill to
report on.

Re-globbed at the real depth (`*/state/journey.md`), 10 US were found and diagnosed below.

### Per-US status (from the `journey.md` ledger alone)

Frontmatter is **absent from all 10 `journey.md` files** (each starts with `# journey — US-…`),
so SKILL.md step 2's fallback applies and is stated here as required: *diagnosis is from the
ledger alone*. (Contract rule 10 requires resume frontmatter on every generated artifact; its
absence on all 10 is a harness/producer gap, reported not guessed-around.)

| US | Last completed step in ledger | Verdict of that step | Open points recorded | Next |
|---|---|---|---|---|
| US-EVAL-001-saucedemo-login | 07-testbook-validate | CONCERNS (structural 65/100, checklist 15/16) | Q3 open | human gate |
| US-EVAL-002-toolshop-checkout | 07-testbook-validate | CONCERNS (72/100, 15/16) | Q5/Q6 open | human gate |
| US-EVAL-003-restful-booker-api | 06-testbook-validate | PASS (82/100, 14/16) | none open (Q1-Q3 assumption) | human gate |
| US-EVAL-004-juiceshop-password-reset | 07-testbook-validate | CONCERNS (94/100 PASS structural, 15/16) | Q1/Q3/Q4 open | human gate |
| US-EVAL-005-openemr-appointment | 07-testbook-validate | CONCERNS (70/100, 15/16) | Q1/Q6/Q8/Q9 open | human gate |
| US-EVAL-006-the-internet-dynamic-loading | 06-testbook-validate | CONCERNS (77/100) | none open | human gate |
| US-EVAL-007-deque-broken-workshop-form | 07-testbook-validate | CONCERNS (92/100 PASS structural, 14/16) | none open | human gate |
| US-EVAL-008-demoblaze | 06-testbook-validate | CONCERNS (78/100) | Q3 open | human gate |
| US-EVAL-009-octoperf-petstore | 07-testbook-validate | CONCERNS (90/100 PASS structural, 15/16) | Q3/Q7 open | human gate |
| US-EVAL-011-quickpizza-perf | 07-testbook-validate | CONCERNS (71/100, 14/16) | Q1/Q6/Q8 open | human gate |

Pending `⚠ VALIDATION` points, counted from the ledgers: **every one of the 10 US** carries
`⚠ simulated: accepted-as-is` on steps 01/02/03, and all 10 record `04-priorities … not yet
human-arbitrated`. All 10 also carry an explicit `⚠ ARRÊT` human Go/No-Go gate line.

### Project level

- **Knowledge base: absent.** No `knowledge/` directory exists under the campaign root or under
  any US directory (`ls -d */knowledge` → no match). `rag-build` initialization *would* help: 10
  US on 10 distinct domains ran with an empty knowledge set, which is exactly the "visible signal
  that the knowledge base is thin" the shared contract describes.
- **Promoted rules: 0.** No `feedback/rules.md` exists anywhere (`ls -d */feedback` → no match).

### The single recommended next action

**A human must give Go / No-Go on the 10 test books before any further step — there is no skill
to invoke.** `testbook-validate` has already run on all 10 (with real script execution), and the
next item in every ledger is the `⚠ ARRÊT` gate, which no agent may cross.

The closest *skill-shaped* action, if the gate has already been passed offline, is
`qaia-core:rag-build` — to give the 10 domains the knowledge base they all ran without.

---

## Cross-check against the repository (requested: does what the skill announces match reality?)

| Skill claim | Repository reality | Match |
|---|---|---|
| Journey = "ingest → review → understanding → design → priorities → generate → export → feedback" (L13) | Real ledgers run ingest → review → understanding → design → priorities → generate → **report** → **testbook-validate** | **NO** — see defects |
| `state/<US-ID>/journey.md` | campaign uses `<US-ID>/state/journey.md` | harness deviation |
| artifacts carry resume frontmatter (L13) | 0/10 `journey.md` have frontmatter | fallback branch correctly provided |
| engagement models QAIA Lite/Solo/Full (L18) | documented only as backlog item A11 in `docs/BMAD-ANALYSIS.md`; no user-facing doc | **partial** |
| 29 SKILL.md across 4 plugins | verified: 15 qaia-core + 11 qaia-playwright + 2 qaia-score + 1 qaia-testdata = 29 | yes |
