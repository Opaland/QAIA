---
stepsCompleted: [00-ingest, 01-review, 02-understanding, rag-build, 03-design, 04-priorities, 05-testbook-generate, 06-oracle-generate-checked, 07-report, 08-export, 09-validate, 10-feedback]
lastStep: 10-feedback
lastSaved: 2026-07-29
---

# Journey ledger — US-005

Mode: **non-interactive pilot run** (validation campaign, 2026-07-29). Every `⚠ VALIDATION`
point is recorded as `simulated: accepted-as-is` (the shared contract's documented
non-interactive default) — no human present to arbitrate. Output root re-based to
`eval/gold-set/pilot-2026-07-29/US-005/` instead of `.qaia/` (shared-contract rule 9).
Assigned skill order: `us-ingest → us-review → need-understanding → rag-build →
istqb-design → oracle-generate → prioritize → testbook-generate → report →
testbook-export → testbook-validate → feedback`.

## 00-ingest — done
- Source: `eval/gold-set/US-005-loan-servicing.md`, the `## User story` and
  `## Acceptance criteria` sections only. The header note naming the held-out raw oracle file
  was read (it is part of the same Markdown file) but the oracle file itself
  (`eval/gold-set/oracle-2026-07-29/fineract-loanproduct-raw.feature`) was **never opened,
  fetched, or referenced** — the evaluation-harness constraint and the ingest guardrail
  ("fetch/read exactly the designated source") both hold.
- Triage gates: not empty; a testable requirement (a ledger/balance-computation spec); no
  abuse/illegality framing. All pass.
- Redaction: no direct personal/sensitive data found. Nothing masked.
- Sanitization: no control/bidi characters found.
- US-ID: `US-005` — `simulated: accepted-as-is`.
- Dependencies: none found in the ingested slice.
- Checkpoint written: `00-source.md`. Validation: `simulated: accepted-as-is`.

## 01-review — done
- Extraction structured into story + 6 numbered AC + no additional business rules outside the
  AC list + no referenced attachments. AC6 noted as a cross-cutting invariant rather than an
  isolated behavior.
- Validation: `simulated: accepted-as-is`.
- Checkpoint written: `01-extraction.md`.

## 02-understanding — done
- Reformulation written (who/what/why/main risk). Ambiguity hunt run: per-AC pass, adversarial
  pass (state re-entrance, auth/permissions, thresholds), cross-AC pass, triple-AC pass.
- 10 questions raised (Q1–Q10): 1 answered (Q4, from AC6 itself), 2 assumption (Q2, Q10),
  7 open (Q1, Q3, Q5, Q6, Q7, Q8, Q9). Bounded at the ~10/pass guardrail.
- Validation per question: `simulated: accepted-as-is` (assumption defaults accepted; open
  items stay open, most still given a proposed default for generation — Q3 and Q7 have no
  defensible default in either direction and are **not** given one, see `03-design.md` and
  `synthesis.md`).
- Knowledge capture offer: Q4's answer (AC6's literal order-independence statement) offered to
  `rag-build` — accepted.
- Checkpoint written: `02-understanding.md`.

## rag-build — done
- Knowledge base did not exist anywhere in this run's own tree prior to this step (confirmed:
  no `.qaia/knowledge` or project-root `knowledge/` for this pilot; unrelated fixtures
  elsewhere in the repo — `examples/*/knowledge`, `eval/baselines/*/knowledge` — belong to
  other runs). Initialized `knowledge/index.md` + `knowledge/business-rules.md` under this
  run's own base.
- Seeded **one** entry only: `BR-KB-001` (reversal order-independence), a literal restatement
  of AC6 with real source provenance. **Deliberately did not** promote any of the nine
  `simulated`/open/assumption defaults from `02-understanding.md` into the knowledge base —
  a non-interactive `simulated: accepted-as-is` default is not a validated human decision, and
  `rag-build`'s provenance rule ("no secrets... provenance mandatory") would be violated by
  recording a fabricated `decided-by`. This is a deliberate, conservative choice, flagged here.
- Report: one new file, no contradictions found (base was empty). No git commit run (per the
  skill's own guardrail — it never runs git itself); this pilot run's own commit (below)
  includes it.

## 03-design — done
- Knowledge base: present with `BR-KB-001`, routed through `index.md`, applied to AC3/AC5/AC6
  conditions. `design.knowledgeApplied = ["BR-KB-001"]`.
- AC → technique map with justification for all 6 AC, plus systematic-expansion (3c reflex)
  conditions: CRUD reflex noted as not applicable (no "delete a loan" concept in the source),
  and a 3-condition authorization/server-side-enforcement reflex (Q10) across AC3/AC4/AC5.
- Oracle-generate check run inline (see below) — no standardized domain found.
- 35 conditions derived across the 6 AC (see the condition list). 15 marked `[req-neg]`.
- Validation (technique map): `simulated: accepted-as-is`.
- Checkpoint written: `03-design.md`.

## oracle-generate — run, no-op
- Scanned `01-extraction.md` for standardized-domain triggers (card/PAN, date/expiry, HTTP
  status, email, currency code, country code, IBAN). US-005 uses only abstract monetary
  amounts and staff actions — **no standardized domain present**. `design.oracles = []`.
  Recorded explicitly rather than silently skipped, per the assigned journey order (this step
  runs after `istqb-design` and before `prioritize`, as instructed) — it found nothing to add
  to either the design conditions or the eventual scenarios.

## 04-priorities — done
- Regulated-context default applied (fintech loan ledger): money-affecting conditions default
  to impact 3. No git-history signal used (no target repo path was named for this session —
  correctly and silently skipped per the skill's own rule, not treated as "safe").
- All 35 conditions scored impact × probability → 20 P1, 11 P2, 4 P3.
- Validation: `simulated: accepted-as-is` (no user override in this non-interactive run).
- Checkpoint written: `04-priorities.md`.

## 05-testbook-generate — done
- Scope: **full P1+P2+P3** generated (broadened from the P1+P2 default) so the pilot's
  coverage is complete for later comparison against the held-out oracle —
  `simulated: accepted-as-is` on the scope question, a deliberate broadening recorded here and
  in the synthesis's arbitration list.
- Duplicate scan: no pre-existing `.feature` files in this fresh output directory — nothing to
  reuse.
- Generated 8 `.feature` files (35 atomic scenarios + 1 `@smoke` journey), `coverage-matrix.md`,
  `synthesis.md`, `generated.snapshot.md` (file-level SHA-256 baseline). Self-checks run before
  emission: negative-path gate (15/15 `[req-neg]` covered), one-`When` rule (verified per
  scenario; the `@smoke` journey is the one exception, has multiple `When` steps and a single
  final `Then`, per its own constraint), literal-value verification (every asserted balance
  recomputed by hand against its `Given` — see arithmetic notes in each scenario), `Background`
  avoided entirely (no invariant held across 100% of any file's scenarios once assumption/edge
  cases were included), ID continuity (001→036, no gaps).
- Two open questions (Q3, Q7) deliberately **not** rendered as scenarios — no defensible
  default exists in either direction; recorded in the synthesis and `openArbitrations` instead
  of guessing.
- **Self-check catch + fix (before this checkpoint closed)**: running the structural pass
  (materialized `eval/tools/structural_score.py`, the same one `testbook-validate` uses at its
  step 2) surfaced 12 refusal scenarios across `nsf-fee.feature`, `refund.feature`,
  `repayment-reversal.feature` and `authorization.feature` whose `Then` stated only a refusal
  reason with no concrete, checkable state. Each was strengthened with an explicit
  balance-unchanged (or, for the one fee-amount-ungrounded scenario, a qualitative
  greater-than) assertion before `generated.snapshot.md` was written — see that file's note
  and `reports/US-005/testbook-validate-report.md` for the full before/after reasoning.
- Validation (synthesis review): `simulated: accepted-as-is`.

## 06-report — done
- `reports/US-005/manifest.json` written, projecting the artifacts above. No `gate` block
  (never self-scored, per contract/shared-contract rule 3).

## 07-export — done
- Deliverables produced under `testbooks/US-005/export/`: the `.feature` files remain the
  source of truth (referenced, not duplicated); a Markdown export re-projecting the synthesis
  and coverage matrix for offline review; a CSV scenario export (one row per scenario, the
  spreadsheet-tool-free path per the skill's own fallback rule — no XLSX library was available
  in this environment, so CSV blocks were produced instead and this substitution is stated
  plainly rather than silently). No Xray/TestRail export requested (opt-in, not applicable to
  a pilot run with no named test-management target).

## 08-validate — done
- `testbook-validate` run against this run's own book (audit-only, no fixes applied). Report
  written to `reports/US-005/testbook-validate-report.md`: structural pass + 8-dimension
  checklist, both reported as required, gate decision recorded there.

## 09-feedback — done, nothing to capture
- No human reviewer has yet corrected this freshly-generated book (this is the pilot's first
  and only generation pass, non-interactive, no prior corrections exist to diff against).
  Recorded a short note (`feedback/US-005/00-no-corrections.md`) stating this rather than
  fabricating example corrections. Nothing promoted to `knowledge/rules.md`.
