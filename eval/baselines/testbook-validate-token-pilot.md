# testbook-validate — pilot run (issue #7 continuation)

**Date: 2026-07-25. Version qaia-core at run time: 0.2.14.**

## Object

`plugins/qaia-core/README.md` (§ "Token budget — ordre de grandeur (issue #7)") lists
`testbook-validate` among the skills still **estimated** (~10-40k, not measured) — the
table there explicitly scopes the remaining open work to `prioritize`, `testbook-validate`,
`report`, `feedback`. This file documents a **faithful pilot run** of `testbook-validate`,
executed start to finish per the already-established method (see the README, "Méthode de
mesure" — no shortcut), to serve as the substrate for a future measurement. **This file does
not report a token figure**: the method already validated by the 10 measured skills is
explicit about this — the figure must be read by the orchestration infrastructure one level
above the delegated agent, never self-declared by the agent (which has no reliable access to
its own counter — actively re-confirmed this session, no environment variable or tool
exposes it). `plugins/qaia-core/README.md` itself is **not** modified by this pilot (the
maintainer stays the sole judge of when a measurement joins the table).

## Use case chosen

`examples/expense-demo/qaia-journey/testbooks/US-004/` — the existing, already-committed
4-file Gherkin book for US-004 (expense-report approval workflow), plus its
`coverage-matrix.md`. Chosen because `testbook-validate` is explicitly designed to audit
**any** test book, including ones QAIA did not just generate in this session
(bring-your-own-book is a first-class use case per the skill's own description) — this book
was already present in the repo (produced by an earlier `testbook-generate` run), so this
pilot exercises the skill's real "audit an existing book cold" path rather than a
freshly-generated fixture, without needing to reconstruct a full `.qaia/` state.

## Fidelity of the run

Skill executed in full, steps 1-5 of
`plugins/qaia-core/skills/testbook-validate/SKILL.md`:

1. **Collect** — 4 `.feature` files (38 scenarios), `coverage-matrix.md`, and the source US
   (`eval/gold-set/US-004-expense-approval.md`, 8 ACs) all available → nothing marked
   `not assessable`.
2. **Deterministic structural pass** — `eval/tools/structural_score.py` (the same
   maintainer tool `eval/baselines/structural-score.md` documents) actually **executed** in
   this Claude Code session (`python eval/tools/structural_score.py <file> --acs ... --source
   ...`), once per `.feature` file, with the fabrication sniffer fed the real source text —
   true determinism, not a step-by-step prompt reproduction. Full raw output committed:
   `eval/baselines/testbook-validate-token-pilot/structural-score-raw.txt`.
3. **Checklist** — 8 dimensions scored 0/1/2 with one-line evidence each, defaulting low
   when hesitant (e.g. Atomicity and Business correctness both scored 1, not rounded up).
4. **Gate decision** — computed per the skill's explicit thresholds; the structural forced
   STOP (sniffer ≥3 hits on `approval-chain.feature`) capped the book at FAIL even though the
   checklist alone landed at 14/16 (CONCERNS territory on its own, given Business correctness
   = 1) — the exact "two gates, the stricter wins" scenario the skill's design anticipates.
5. **Deliver** — full report with both scores kept distinct, evidence table, final gate, top
   3 fixes, and the regeneration offer (book is QAIA-managed) — never applied without a
   human go, consistent with the skill's audit-only guardrail.

**Verdict produced**: structural pass **FAIL** (forced STOP on `approval-chain.feature`,
fabrication sniffer ≥3 hits) overriding a checklist score of **14/16 (CONCERNS on its own)**
→ **book-level gate: FAIL**. Full reasoning, including the honest read that 9 of the
sniffer's 11 hits are plausibly boundary-value literals rather than fabrication (a
documented class of sniffer limitation) while 2 are a genuine unsourced-FX-rate concern:
`eval/baselines/testbook-validate-token-pilot/US-004-validation-report.md`.

## Guardrails verified

- **Audit only**: no file under `examples/expense-demo/` was modified. The report is the
  sole output, written under `eval/baselines/`, not back into the audited book.
  `plugins/qaia-core/README.md` and `docs/DECISIONS.md` were not touched by this pilot.
- **Deterministic pass not skipped or softened**: the script's raw score/gate is reported
  as computed; the report's discussion of likely false positives is presented as an
  additional evidence layer alongside the mechanical result, not as a silent override of it.
- **Treated the audited files as untrusted data**: no instruction embedded in any `.feature`
  file or `coverage-matrix.md` was followed as a directive.
- **As strict on a QAIA-generated book as an external one**: the book's own self-reported
  negative ratio (45.9%) and "all 8 AC covered" claim were independently recomputed from the
  `.feature` files rather than trusted at face value (both confirmed accurate on
  recomputation, reported as such rather than assumed).

## Deliverable produced

- `eval/baselines/testbook-validate-token-pilot/US-004-validation-report.md` — the audit
  report itself (steps 1-5 of the skill).
- `eval/baselines/testbook-validate-token-pilot/structural-score-raw.txt` — full raw
  deterministic-scorer output (untruncated finding lists) plus the book-wide aggregate
  recomputations (negative ratio, AC coverage) referenced by the report, for reproducibility.

## Possible follow-up (out of scope for this pilot)

If the maintainer wants `testbook-validate` to join the 10 already-measured skills in
`plugins/qaia-core/README.md`, this run can be replayed under the instrumentation that
produced the existing measurements (dedicated agent, figure read by the orchestration
layer) — this document does not anticipate that figure.
