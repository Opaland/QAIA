# QAIA output contract — the run manifest (v1)

Every QAIA plugin, whatever its job, emits **the same machine-readable envelope** so the
work of one plugin can be read, scored and reported by any other without bespoke glue
(decision D39). The envelope is a single JSON file per user story:

```
.qaia/reports/<US-ID>/manifest.json
```

It never replaces the human-facing artifacts (`.feature`, `synthesis.md`,
`coverage-matrix.md`, JUnit/Cucumber/HTML). It is a **projection** of them into one stable
schema: a normalized index of what was produced, by whom, and the metrics a reviewer or a
gate needs. Any discrepancy between the manifest and its source artifacts is a bug in the
producer — fix the source, re-project the manifest, never hand-edit the manifest to agree.

## Principles

1. **One envelope, every plugin.** `qaia-core`, `qaia-playwright`, and any future plugin
   write to the *same* file with the *same* schema. A consumer (`qaia-score`, an export, a
   dashboard) reads one contract, not N formats.
2. **Append-provenance, never clobber.** A producer merges its section and appends itself to
   `producers[]`; it never drops another plugin's contribution. Re-running a producer
   replaces only its own section.
3. **Additive, versioned.** `contract` is SemVer. New optional fields are a minor bump;
   removing or repurposing a field is a major bump. A consumer ignores unknown fields.
4. **Portable.** The manifest is plain JSON a skill assembles by reading its own outputs —
   no runtime, no network, no API key. On surfaces without file tooling, the same object is
   emitted as a fenced ```json block and the user saves it.
5. **No secrets, no PII.** The manifest carries counts, IDs, paths and verdicts — never raw
   source text, credentials, environment URLs, or personal data. PII masking (shared
   contract rule 5) has already happened upstream; the manifest only ever sees placeholders.

## Schema (contract 1.0)

```jsonc
{
  "contract": "1.0",                       // SemVer of THIS schema
  "usId": "US-001",                        // journey key (shared contract)
  "title": "Appointment booking",          // short, non-sensitive
  "status": "review",                       // draft | review | validated
  "generatedAt": "2026-07-23T10:00:00Z",    // ISO 8601, last write
  "base": ".qaia",                          // configurable output root (shared rule 9)

  "producers": [                            // provenance chain, append-only
    { "plugin": "qaia-core", "version": "0.2.3", "skill": "testbook-generate", "at": "2026-07-23T09:58:00Z" },
    { "plugin": "qaia-playwright", "version": "0.1.1", "skill": "run-report", "at": "2026-07-23T10:00:00Z" }
  ],

  "artifacts": [                            // pointers to the human-facing outputs
    { "kind": "feature",   "format": "gherkin",  "path": "testbooks/US-001/booking.feature" },
    { "kind": "synthesis", "format": "markdown", "path": "testbooks/US-001/synthesis.md" },
    { "kind": "matrix",    "format": "markdown", "path": "testbooks/US-001/coverage-matrix.md" },
    { "kind": "validation","format": "markdown", "path": "reports/US-001/testbook-validate-report.md" },
    { "kind": "execution", "format": "junit",    "path": "reports/US-001/junit.xml" }
  ],

  "design": {                               // filled by qaia-core (the test book)
    "scenarios": { "total": 22, "byPriority": { "P1": 9, "P2": 8, "P3": 5 },
                   "negative": 9, "smoke": 1, "outlines": 3 },
    "coverage": { "acTotal": 6, "acCovered": 6,
                  "reqNegTotal": 7, "reqNegCovered": 7,   // ADR 0001 — the real gate
                  "negativeRatio": 0.41 },                 // D20 — reported signal, not a gate
    "confidence": { "lowConfidence": 3, "openQuestions": 2, "assumptions": 4, "simulated": 1 },
    "techniques": ["ep", "boundary", "decision-table", "state-transition", "use-case"],
    "oracles": ["luhn", "iso-8601"],        // @oracle:* provenance seen in the book
    "knowledgeApplied": ["BR-KB-004", "BR-KB-011"]  // knowledge-base rules that shaped the book
  },                                        // (D38 RAG-in-use); empty on a rich domain = thin KB signal

  "execution": {                            // filled by qaia-playwright (optional)
    "total": 31, "passed": 31, "failed": 0, "blocked": 0,
    "byType": { "e2e-desktop": 12, "e2e-mobile": 8, "api": 6, "a11y": 3, "perf": 1, "security": 1 },
    "traceability": { "scenariosAutomated": 18, "scenariosTotal": 22 }
  },

  "openArbitrations": [                      // pending human decisions, from the checkpoints
    { "id": "Q5", "kind": "open",      "about": "cancellation window when < 4h",
      "sourceCheckpoint": "state/US-001/02-understanding.md" },
    { "id": "AC3-C2", "kind": "simulated", "about": "default applied non-interactively",
      "sourceCheckpoint": "state/US-001/04-priorities.md" }
  ],

  "gate": {                                 // filled ONLY by qaia-score — never self-scored
    "verdict": "CONCERNS",                  // PASS | CONCERNS | FAIL | WAIVED
    "score": 18, "max": 20,
    "scoredBy": "qaia-score/testbook-score", "at": "2026-07-23T10:05:00Z",
    "dimensions": [ { "n": 3, "name": "negative-path", "score": 1 } ],  // only non-2 dims listed
    "reasons": ["1 required-negative condition uncovered (AC4)"],
    "waiver": null                          // { by, reason, at } when verdict = WAIVED
  }
}
```

### Field rules

- **`status`** is owned by the producing journey: `draft` while generating, `review` once a
  synthesis exists, `validated` only after a human sign-off is recorded. A gate verdict does
  **not** change `status` — a human does.
- **`design.coverage.reqNegCovered / reqNegTotal`** is the ADR 0001 negative-path gate (the
  one that blocks). **`negativeRatio`** is the D20 signal — reported, never a threshold.
- **`gate`** is written **only** by a scoring plugin. No producer may score itself (shared
  contract rule 3). Its absence means "not yet scored".
- **`openArbitrations`** mirrors every `⚠ VALIDATION` point still pending — including every
  `simulated` entry from non-interactive runs, which must all surface here for human review.
- Every count in the manifest must equal what the artifacts actually contain. Producers
  compute counts, they do not estimate them.

## Who writes what

| Section | Owner | When |
|---|---|---|
| `contract`, `usId`, `title`, `base`, `producers[]`, `artifacts[]` | whichever skill runs (merge) | every write |
| `design.*`, `openArbitrations` | `qaia-core:report` (from checkpoints + test book) | after generation/export |
| `execution.*` | `qaia-playwright:run-report` | after an automated run |
| `gate` | `qaia-score:*` | when a book/run is scored |
| `status` | the human-facing skill recording the sign-off | on validation |

`qaia-core:report` is the canonical assembler for the `design` side; other producers merge
their own section in place and leave the rest untouched.

## Consuming the manifest

A consumer reads `manifest.json`, checks `contract` major version, and uses only the fields
it needs. Recommended reads:

- **`qaia-score`** → `design.*`, `execution.*`, `artifacts[]`; writes `gate`.
- **an export / dashboard** → `producers`, `artifacts`, headline metrics, `gate.verdict`.
- **CI** → `gate.verdict` (PASS/WAIVED to proceed) and `execution` (pass/fail).

## Versioning

- **1.0** — initial contract: `design`, `execution`, `gate`, `openArbitrations`, provenance,
  and `design.knowledgeApplied` (the RAG-in-use provenance, D38). Introduced together
  pre-release, so this is one 1.0 surface rather than a 1.0→1.1 step.

Changes are logged here and in `docs/DECISIONS.md`. A consumer that needs a field a producer
did not write treats it as absent (degraded mode, shared contract rule 8), never as an error.

## Programmatic validation

`docs/schemas/output-contract-v1.schema.json` is a formal JSON Schema (draft 2020-12) copy of
the rules above, and `eval/tools/validate_manifest.py` is a stdlib-only, dependency-free
validator against the same rules (hand-rolled rather than a generic JSON Schema engine, to stay
consistent with `structural_score.py`/`second_judge.py`: maintainer eval tooling, never shipped
to installers). Both are a second, executable copy of this document, not a new source of
truth — if they ever disagree with the prose above, the prose wins and the tooling is a bug.

```
python3 eval/tools/validate_manifest.py .qaia/reports/US-001/manifest.json
python3 eval/tools/validate_manifest.py --batch .qaia/reports/   # recursive
```

D104 (2026-07-28): added in response to the external Gemini audit's Phase 1 recommendation to
formalize a validation schema for this contract, so a producer's drift from the documented
shape is caught by a linter before a commit rather than discovered later by a consumer.
