# oracle-generate — step 4 provenance record (US-EVAL-009, AC1 + AC2)

Real execution, skill-coverage wave 2026-07-30. Skill:
`plugins/qaia-core/skills/oracle-generate/SKILL.md`. Reference file loaded as the skill
mandates: `plugins/qaia-core/skills/oracle-generate/oracles/library.md`, section
`## ISO 4217 (currency codes)`.

## Step 1 — detection (executed, `detect_oracles.py`, output `01-detect-run.txt`)

Scanned `state/01-extraction.md` and `state/03-design.md` against the SKILL.md
domain-trigger table. Exactly one domain triggers: **ISO 4217** (18 hits in `03-design.md`:
`USD`, `currency`, `$16.50`…). Luhn, ISO 8601, RFC 5322, HTTP semantics, ISO 3166 and IBAN
all score 0 hits — recorded as not-triggered rather than force-applied.

No project oracle (OpenAPI/JSON Schema) is in play: no user designated a spec file, and none
exists in the campaign directory. The `oracles/openapi.md` path was therefore not loaded.

## Step 2 — ⚠ VALIDATION: **pending-validation**

SKILL.md line 67: *"propose the oracle-derived cases to the user … The oracle *proposes*; the
human arbitrates."* No human is available in this run, so **nothing below is accepted**. The
proposed cases live in `proposed-iso4217.feature` only; they were deliberately **not** merged
into `eval/skill-eval-campaign-2026-07-29/US-EVAL-009-octoperf-petstore/testbooks/`.

## Step 3 — emitted cases (proposed)

| ID | AC | Oracle | Derivation from the standard | Status |
|---|---|---|---|---|
| `AC1-O1` | AC1 | ISO 4217 | USD minor unit = 2 → every monetary field is an integral number of cents and shows exactly 2 decimals. Extends `AC1-C1`, which asserts the *amounts* but not the *minor-unit invariant* on `List Price`/`Total Cost`. | proposed |
| `AC2-O2` | AC2 | ISO 4217 | `library.md`: *"Minor-unit rule drives rounding"* → the half-cent tie-break is the boundary of a summed Sub Total. | proposed, `@low-confidence`, **unreachable from confirmed inputs** (2-decimal prices × integer quantities never leave the cent) — kept P3 and flagged rather than fabricated with an invented catalog price. |

Both carry `@oracle:iso4217` **and** the `# oracle: <ref>` comment SKILL.md step 3 mandates.

## Cases deliberately NOT emitted (guardrail "Never invent")

- **Invalid currency-code corpus** (`EU`, `EURO`, `US$`, `XXX`, from `library.md`): the
  application exposes **no currency-code input surface** — the cart is USD-only and the code is
  never user-supplied. Emitting a rejection scenario would fabricate an input the US does not
  have. Stays out, recorded here.
- **Multi-currency minor-unit variance** (`JPY` 0 decimals, `BHD` 3 decimals): same reason —
  single-currency application, no observed multi-currency surface. Not applicable, stated
  rather than silently skipped.

## Deterministic check on the emitted Gherkin

`python eval/tools/structural_score.py …/proposed-iso4217.feature`

- v1 (`02-structural-score-v1.txt`): score **70**, gate `CONCERNS`, `completeness: 0.0`.
- v2 (`03-structural-score-v2.txt`, after making both `Then` clauses carry a concrete token):
  score **100**, gate `PASS`.

The v1→v2 delta is recorded rather than hidden: the v1 `Then` clauses ("*is displayed with
exactly two decimal places*") carried no numeric/quoted token, so `structural_score.py`'s
`ASSERT_RE` (which matches `displays?`, not `displayed`, and digits, not spelled-out numbers)
counted them as non-covering. The oracle content is identical in both versions; only the
assertion wording changed.
