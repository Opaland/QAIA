---
name: dataset-generate
description: Generate a rich, business-coherent synthetic test dataset (never real data or PII) from a QAIA user story or test book, covering realistic distributions and the boundary/edge cases the acceptance criteria demand, in a format directly injectable as a Playwright fixture. Use when a generated or automated test book needs concrete data instead of placeholder literals.
---

# dataset-generate — synthetic, business-coherent test data

`qaia-core` only ever produces small inline examples inside a scenario — test data is a separate
concern, deliberately kept out of the generator so a scenario stays readable and the data stays
reusable. This skill is the separate producer of **standalone, reusable datasets**: entity collections and
scenario-oriented "cases" rich and coherent enough that `qaia-playwright:automate`'s generated
tests can seed real state from them instead of inventing a literal per test.

## Prerequisites

- The source US (`.qaia/state/<US-ID>/00-source.md` / `01-extraction.md`, or an equivalent
  gold-set-style file) — the acceptance criteria are what the dataset's entities, fields and
  boundaries are derived from.
- Ideally the design/test book (`.qaia/state/<US-ID>/03-design.md`, `.feature` files under
  `.qaia/testbooks/<US-ID>/`) so cases can cite the actual derived condition/scenario IDs. If
  only the US is available, generate from its acceptance criteria alone and say so — do not
  block on a test book that does not exist yet.

## Steps

1. **Model the entities first.** Read the acceptance criteria and extract the nouns and
   relationships they imply (reference records, actors, transactional records, the foreign
   keys between them). Write the entity list and its relationships down before generating a
   single row — a dataset invented row-by-row with no schema is how referential integrity
   breaks silently.
2. **Business-coherent values, not random noise.** For each field, choose a domain (units,
   ranges, distributions) a domain reviewer would recognize as plausible. This is what "riche
   et cohérent métier" means in practice: a shopper's loyalty tier and their spend history
   agree, a patient's age and the drug's age floor are both present and comparable, a
   cumulative total is never contradicted by the rows that should sum to it.
3. **Cover the boundaries the AC demands**, mirroring `istqb-design`'s EP/BVA techniques
   (equivalence partitioning + boundary value analysis): one or more concrete rows per
   condition, not just happy-path rows. Tag every case with the AC(s) and condition it targets
   (`coversAC`, and a `coversCondition`/scenario ID when a test book exists) so a generated
   test can request "the row for AC3's upper boundary" instead of grep-hunting the fixture.
4. **Enforce cross-entity coherence, and check it, don't just claim it.** Foreign keys must
   resolve, computed fields must agree with the raw rows they derive from (a cumulative total
   equals the sum of the intake/line rows it summarizes), and no two facts about the same
   entity contradict each other. Recompute totals; do not eyeball them.
5. **Anti-fabrication discipline applied to data, not just scenarios** — honest recall beats
   fabricated recall: never let an invented value read as a sourced one. Three situations:
   - The US **states** a threshold/rule — use it, cite the AC.
   - The US is **silent** on a concrete value the fixture still needs (an exact mg threshold,
     a tier spending cutoff's exact rounding) — invent a plausible one for fixture purposes,
     but mark the field `synthetic: true` with a short note, and never let it read as a sourced
     clinical/legal/business fact.
   - When the US is **internally ambiguous** (inclusive/exclusive boundary wording, rolling vs.
     calendar window, and similar), do not silently pick a side: record the interpretation
     chosen for the fixture as a named, citable assumption (`_meta.assumptions[]`, `ASM-n`) and
     tag every case it touches (`assumptionRefs`). Where the ambiguity is genuinely a fork with
     no defensible default, build a case that **exposes** the fork instead of resolving it: its
     `expectedResult.status` is literally `"[open]"`, listing both interpretations, mirroring
     the `[open]`/`[assumption]` discipline `istqb-design`/`need-understanding` already apply to
     scenarios — the honest recall ceiling applies to invented data exactly as it does to
     invented test logic.

   ⚠ VALIDATION — when the fixture rests on an invented value or a chosen interpretation,
   surface it with this callout, verbatim, rather than burying it in `_meta`:

   > **If you own the product rather than the tests, read this. You do not need the rest of
   > this page.**
   >
   > - **What you're being asked:** to build test data we needed concrete values the
   >   specification never gave — an exact threshold, a cut-off, whether a limit counts as
   >   "reached" or "exceeded". We made them up, plausibly, and listed them below. You are being
   >   asked whether any of them is wrong.
   > - **Why it matters:** these values are what the tests are built around. If our invented
   >   threshold sits on the wrong side of your real one, the tests will pass while checking the
   >   wrong boundary — and a boundary is exactly where defects live. This is the one kind of
   >   error that leaves no trace: everything is green and nothing was verified.
   > - **If you don't answer:** the fixture ships with those values marked as invented
   >   (`synthetic`), so nobody later mistakes them for your rules. Where the choice was a
   >   genuine fork with no safe default, the case is left deliberately unresolved instead of
   >   being decided for you.
   >
   > No real data is ever used here — every person, address and identifier is fabricated on
   > purpose, even when the real thing would be easier to obtain.
6. **No real data, no PII, ever.** Every person-like entity (patient, physician, customer,
   employee, ...) gets a clearly synthetic identity: a name pattern that signals fixture data at
   a glance (e.g. `<first name> Sample-NN`), an `@example.invalid`-style email (RFC 2606
   reserved TLD — guaranteed to never resolve to a real domain), no real-world-resolvable
   identifier, and a `synthetic: true` flag. Never reuse a real drug/company/product name, a
   real address, or any value that could be mistaken for a real record — a reviewer must be able
   to tell at a glance this is fixture data, not exported real data. This holds with extra
   weight in health and other regulated domains, and applies identically to every domain the
   skill is used in outside them.
7. **Emit the dataset.** Primary format: one JSON file (`<US-ID>-dataset.json`) with:
   - `_meta`: US-ID, generation date, a plain-language non-fabrication disclaimer, and the
     `assumptions[]` list from step 5;
   - one array per entity (referential integrity per step 4);
   - a `cases[]` array of scenario-oriented rows — `id`, `description`, references to the
     entities/rows involved, `coversAC`/`coversCondition`, `assumptionRefs`, and an
     `expectedResult` (status + the rule/condition it exercises, or `"[open]"` per step 5). This
     last array is what a generated test actually iterates over.
   CSV export of a single entity array is optional, on request, for tooling that needs it.
   Never emit a database dump or a real-service payload shape unless the US actually specifies
   one — invented "realism" beyond what's needed is its own risk (a fixture that looks more
   authoritative than it is).
8. **Document the injection pattern — don't ship code.** Show how
   `qaia-playwright:automate`'s POM-as-fixtures convention (page objects exposed as Playwright
   fixtures) consumes the file: a `testData` fixture in `fixtures.js` that reads and parses the
   JSON once and exposes it to every test — the same `test.extend()` mechanism
   [`examples/medibook/tests/fixtures.js`](https://github.com/QAIA-Project/QAIA/blob/main/examples/medibook/tests/fixtures.js) already uses for `loginPage`/`bookingPage`/`patient`.
   This is documentation, or an in-session snippet the generating skill or the user materializes
   when wiring tests — the plugin itself ships **no** runtime code: skills stay 100% Markdown,
   and executable code is generated and run in-session, never distributed, so installing a
   plugin can never introduce a supply-chain payload. See `../../fixture/fixtures.js` for a
   worked, executed example.
9. **Traceability.** Write (or update) `dataset-map.md`: one row per `cases[]` entry — case ID,
   AC(s), condition/scenario ID if a test book exists, expected outcome, assumption refs. This
   is the dataset's own coverage matrix, mirroring the AC → scenario → status pattern
   `testbook-generate` already uses, so a reviewer audits the data the same way they audit
   the tests.
10. **Optional manifest merge (shared output contract, `../../OUTPUT-CONTRACT.md`).** If
    `.qaia/reports/<US-ID>/manifest.json` already exists,
    merge into `producers[]` and add an `artifacts[]` entry (`kind: "dataset"`,
    `format: "json"`, `path`), plus `kind: "dataset-map"` if you emitted a map. Two rules
    bound this, both learned the hard way: the `path` is **relative to that run's report
    directory and may not climb out of it**, and you only ever merge into the manifest of the
    run you are part of — declaring your output inside someone else's manifest makes their run
    claim work it never did. Append-only, never touching another producer's section
    (`design`/`execution`/`gate`/`status` stay byte-for-byte untouched, contract rule 2). If no
    manifest exists yet this is skipped, not a blocker for delivering the dataset itself.

## Guardrails

- **Never real data, never PII, ever.** Synthetic identity markers on every person-like row
  (step 6). A dataset that could be mistaken for exported real records is a defect, not a
  feature — this is stricter than, and in addition to, the shared contract's PII-masking rule
  for ingested source content (`https://github.com/QAIA-Project/QAIA/blob/main/plugins/qaia-core/skills/README.md` rule 5): here nothing real
  ever enters in the first place.
- **Never fabricate a domain fact as if sourced** when the US is silent — invent, but flag
  (`synthetic: true`, `_meta.assumptions[]`, or an explicit `[open]` case). Honest recall beats
  fabricated recall, applied to data exactly as to scenarios.
- **No auto-executed code ships with the plugin.** The fixture-wiring pattern in
  step 8 is a documented convention the user/skill materializes in their own test repo, never a
  script this plugin runs on its own.
- **Scoped writes.** This skill's only outputs are the dataset file(s), `dataset-map.md`, and
  optionally the manifest's `producers[]`/`artifacts[]` — it never edits `.feature` files,
  checkpoints, or another producer's manifest section.
- **Portable.** Plain JSON/CSV/Markdown, no network, no API key, no runtime dependency to
  *generate* the data. The optional Playwright fixture wiring shown in step 8 is consumed
  downstream, by whatever test suite the user or `qaia-playwright:automate` builds — it is not
  a dependency of this skill.

## Worked example

`../../fixture/` builds and validates a real dataset for [`eval/gold-set/US-002-dosage-validation.md`](https://github.com/QAIA-Project/QAIA/blob/main/eval/gold-set/US-002-dosage-validation.md)
(prescription dosage validation, health domain — chosen because no example dataset exists for it
elsewhere in the repo) — 4 synthetic drugs, 3 synthetic physicians, 11 synthetic patients, 20
intake records and 17 boundary-focused cases covering all 8 ACs, including one case
(`C-015`) that deliberately surfaces a genuine AC ambiguity as `"[open]"` rather than resolving
it. See `../../fixture/VALIDATION.md` for what was actually run (a real `npx playwright test`
pass over a fixture-injection spec, not a narrated claim).
