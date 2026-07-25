# journey — US-004

Output base: `examples/expense-demo/qaia-journey/` (project-local, rule 9 — a demo project directory
rather than a real repo's default `qaia-journey/` root).

| Step | Status | Date | Notes |
|---|---|---|---|
| 00-ingest | done | 2026-07-25 | No gates fired. No redaction needed. `simulated: accepted-as-is`. |
| 01-review | done | 2026-07-25 | 8 AC extracted, numbered AC1–AC8, final. `simulated: accepted-as-is`. |
| 02-understanding | done | 2026-07-25 | 9 questions (5 open, 4 assumption). `simulated: defaults applied`. |
| 03-design | done | 2026-07-25 | 37 conditions, 8 AC + 2 cross-cutting groups, 17 `[req-neg]`. |
| 04-priorities | done | 2026-07-25 | 18 P1 / 15 P2 / 4 P3. Scope: full-breadth (all generated). |
| 05-testbook-generate | done | 2026-07-25 | 38 scenarios, 4 `.feature` files, negative ratio 45.9 %. |
| 06-export (Playwright automation) | done | 2026-07-25 | `examples/expense-demo/tests/` — see traceability.md. |
| 07-feedback | done | 2026-07-25 | 4 corrections captured (`.qaia/feedback/examples/US-004-{1..4}.md`), 2 promoted (`BR-KB-001`, `BR-KB-002` — `.qaia/feedback/rules.md`), 1 not promoted (one-off). `simulated: accepted` throughout. `rag-build` handoff not performed (no `knowledge/` in this worktree — honest gap, see `rules.md`). |

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
