---
stepsCompleted: [00-ingest, 02-understanding, 03-design, 04-prioritize, 05-generate, 07-validate, 08-contract-probe]
lastStep: 08-contract-probe
lastSaved: 2026-07-31
usId: RAD-PUBOBJ
outputRoot: eval/skill-coverage-wave-2026-07-30/US-EVAL-012-api-first/
knowledgeBase: absent
---

# journey.md — RAD-PUBOBJ (US-EVAL-012, API-first run)

**Output root re-based** per shared-contract rule 9: all `.qaia/`-relative paths in the skills map to
`eval/skill-coverage-wave-2026-07-30/US-EVAL-012-api-first/` for this campaign run.

**Target:** `https://restful-api.dev` / `https://api.restful-api.dev` — verified alive before use
(`HTTP 200`, 0.27 s). No fallback to `jsonplaceholder.typicode.com` or
`api.practicesoftwaretesting.com` was needed; neither was contacted.

> ⚠ **This ledger was written retroactively.** A first pass of this run wrote `00-source.md` through
> `coverage-matrix.md` and then terminated before producing `journey.md`, `synthesis.md` or any
> report. The session that completed the run verified those artifacts against the live source
> independently (re-fetching the documentation bundle and re-deriving the endpoint contract, and
> re-counting every tag with `grep`) before resuming rather than regenerating. **That every skill
> requires "update `journey.md`" and no skill wrote it is itself a finding — F3 in
> `reports/skill-findings.md`.**

## Step ledger

| Step | Skill | Status | Evidence |
|---|---|---|---|
| `00-ingest` | `us-ingest` | **done** (validations `simulated`) | `state/00-source.md` |
| `01-review` | `us-review` | **`pending-validation`** | `state/01-extraction.md`, `status: unconfirmed` |
| `02-understanding` | `need-understanding` | **done** (Q&A `simulated`) | `state/02-understanding.md` |
| `03-design` | `istqb-design` | **done** (map `simulated`) | `state/03-design.md` |
| `04-prioritize` | `prioritize` | **`pending-validation`** | `state/04-priorities.md`, `NOT ARBITRATED` |
| `05-generate` | `testbook-generate` | **done**, book `pending-validation` | `testbooks/*.feature`, `coverage-matrix.md`, `synthesis.md` |
| `07-validate` | `testbook-validate` | **done — GATE: FAIL** | `reports/testbook-validate-report.md` |
| **step-8 human gate** | — | **NOT PASSED** | no human available; not simulated |
| `08-probe` | `contract-probe` | **done — 12 promises kept, 4 broken** | `reports/contract-probe-report.md`, `probe/*.log` |

## Gates NOT crossed (never simulated away)

- **`us-review` step 3** — non-interactive, so the extraction stays `unconfirmed` and this step is
  **not** marked done. The corrected clause (2026-07-30) names `simulated: accepted-as-is` as the
  exact defect; no such note was written.
- **`prioritize` step 3** — scores are `proposed but not arbitrated`, explicitly unsuitable for a
  production Go/No-Go.
- **Campaign step-8 human gate** (`docs/SKILL-EVAL-CAMPAIGN-PROMPT.md`, "⚠ ARRÊT") — a human Go/No-Go
  on the book was **not** obtained and **not** faked. `contract-probe` ran anyway because this is a
  skill-evaluation run whose stated purpose is to exercise that skill, and because probing a
  documented contract does not depend on the book being approved. Recorded as a deliberate,
  visible deviation rather than a silent one.

## Redaction record (shared-contract rule 5)

Ran at ingestion. `email → [REDACTED:email] → 1` (a vendor contact address, masked conservatively).
No mapping of original values to placeholders is stored anywhere. No other sensitive-data class found.

## Degraded modes recorded

- **Knowledge base absent** — no `knowledge/index.md` at the output root or repo root.
  `design.knowledgeApplied = []`; no `BR-KB-nnn` invented.
- **Git-history signal unused** — no repo path designated, and the target is a closed hosted service.
  Absence of history was *not* treated as evidence of low risk.
- **`oracle-generate` not delegated** — its logic (ISO 8601, RFC 9110) was applied inline because the
  skill was outside this run's designated list. Recorded so the trace is not misread as a delegation.

## Live-probe feedback into the journey

`contract-probe` empirically **answered Q1, Q3, Q7 and Q10** and **falsified 3 generated scenarios**
(`-011`, `-012`, `-026`). Per the campaign's no-silent-correction rule, **no checkpoint or scenario
was edited to match reality** — the deltas are recorded in `reports/contract-probe-report.md` §5 and
drive `testbook-validate`'s FAIL. Applying them is a human-approved regeneration, not this run's job.

## Request budget

37 of the target's documented 50 public requests/day consumed. Quota never exhausted (that would be a
DoS-shaped probe against a third party's shared infrastructure).
