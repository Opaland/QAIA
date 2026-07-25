# journey — US-004

Output base: `examples/expense-demo/qaia-journey/` (project-local, rule 9 — a demo project directory
rather than a real repo's default `qaia-journey/` root).

| Step | Status | Date | Notes |
|---|---|---|---|
| 00-ingest | done | 2026-07-25 | No gates fired. No redaction needed. `simulated: accepted-as-is`. |
| 01-review | done | 2026-07-25 | 8 AC extracted, numbered AC1–AC8, final. `simulated: accepted-as-is`. |
| 02-understanding | done | 2026-07-25 | 9 questions (5 open, 4 assumption). `simulated: defaults applied`. |
| 03-design | done | 2026-07-25 | 37 conditions, 8 AC + 2 cross-cutting groups, 17 `[req-neg]`. |
| 04-priorities | done | 2026-07-25 | 16 P1 / 12 P2 / 9 P3. Scope: full-breadth (all 37 conditions scored). `simulated: default applied` (non-interactive, no arbitration). Independent re-run of this step — see note below. |
| 05-testbook-generate | not run in this pass | — | Out of scope for this `prioritize` re-run; the 05/06 rows below describe an earlier, separate run and are kept for history only — they do not derive from this session's `04-priorities.md`. |
| 06-export (Playwright automation) | not run in this pass | — | See note above. |

Execution mode: **non-interactive** (batch, matching the gold-set baseline protocol) — every
⚠ VALIDATION point above was recorded as `simulated: <default applied>`, not a live
conversational approval. This mirrors the disclosed limitation of `eval/baselines/0.1.0-US-001.md`
("the conversational validation path is NOT covered by this baseline").

Known asymmetry vs. a true blind run: the acting model read `eval/gold-set/US-004-expense-approval.md`
in full, including the sequestered "Judge reference" section, before running this journey (per
the task's own instructions to read the file end-to-end first). The ambiguity hunt in
`02-understanding.md` was performed by applying the `need-understanding` checklist mechanically
to the AC text alone (not by consulting the judge section while writing), but this is not a
blind eval — see the maintainer-facing report for the honest comparison against the judge
reference and this caveat.

**Note on this `04-priorities` row (token-budget pilot, issue #7).** `00-source.md` through
`03-design.md` above are the original fixture checkpoints, unmodified, used here as-is as the
prerequisite for a fresh, independent `prioritize` run. A `04-priorities.md` already existed in
the source fixture from an earlier run; it was deliberately **not** copied or consulted for this
pass — the table in this session's `04-priorities.md` was scored from `03-design.md` alone,
without reference to the prior result, so the two are independent measurements rather than one
copying the other. Their totals differ (16/12/9 here vs. 18/15/4 previously), which is expected
variance for an unseeded risk-scoring pass, not a correction of either run.
