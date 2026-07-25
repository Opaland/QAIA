# Pilot run — `qaia-core:qaia-help` (issue #7, token-budget method)

- Date: 2026-07-25 — one faithful, complete run of `plugins/qaia-core/skills/qaia-help/SKILL.md`
  by a dedicated agent, same method as the 5 already-measured skills documented in
  `plugins/qaia-core/README.md` § "Token budget — ordre de grandeur (issue #7)": read-only,
  no shortcut, executed end-to-end against real `.qaia/` state.

## Fixture

No live `.qaia/` project state existed at the repo root (expected — gitignored, per-project).
To give the skill real state to inspect rather than an empty repo, the existing US-004 journey
state was copied from `examples/expense-demo/qaia-journey/` to the canonical root
`.qaia/` (contract path per `plugins/qaia-core/skills/README.md`):

- `.qaia/state/US-004/` — `journey.md` + 5 checkpoint files (`00-source.md` … `04-priorities.md`)
  + `generated.snapshot.md`
- `.qaia/testbooks/US-004/` — 3 `.feature` files, `synthesis.md`, `coverage-matrix.md`, and an
  `export/` subfolder (4 `.feature` files, `synthesis.md`, `coverage-matrix.md`, an XLSX, and an
  `xray/` CSV+README)
- `.qaia/knowledge/` and `.qaia/feedback/` — absent (not part of this fixture; expense-demo never
  initialized a knowledge base or captured feedback for US-004)

This copy is a local, gitignored fixture only — not committed (per instructions; `.qaia/` is in
`.gitignore`).

## Execution — read set (per SKILL.md step 1, allowlist respected)

- `.qaia/state/US-004/journey.md` — frontmatter: none on this file (it's the ledger itself, not
  a generated artifact per rule 10); ledger read in full.
- `.qaia/knowledge/index.md` — absent, existence check only.
- `.qaia/feedback/rules.md` — absent, existence check only.
- `.qaia/testbooks/US-004/` — directory + `export/` subdirectory listed for existence/file names
  only; no testbook content opened (per the skill's explicit prohibition).

## Output produced (the "what now" report, step 3-4 of SKILL.md)

> **US-004**: ingest through export all done (00-ingest → 06-export/Playwright automation,
> 7/7 ledger rows `done`) — test book generated (38 scenarios across 4 `.feature` files per the
> ledger note) and already exported. `feedback` is the one journey step in the shared sequence
> (ingest → review → understanding → design → priorities → generate → export → feedback) with no
> ledger row yet — **next: run `feedback`.**
> Open-ambiguity count: 5 open (+ 4 assumption) per the `02-understanding` ledger note — not
> re-derived from the checkpoint file itself (out of this skill's read allowlist).
> Pending validation: every ledger row is annotated `simulated: <default applied>` — this run was
> non-interactive end to end, so all 7 validation points are pending human review, not live
> approvals (contract rule 3).
>
> **Project level**: no `knowledge/index.md` — knowledge base absent; `rag-build` initialization
> would let a re-run of `istqb-design`/`testbook-generate` apply cited project rules. No
> `feedback/rules.md` — 0 promoted rules.
>
> **Recommended next action**: invoke `feedback` on US-004 to capture and promote corrections
> from the exported book (not auto-run — recommendation only, per guardrail).

No file was written or modified under `.qaia/` — read-only run confirmed (`git status --short`
before and after: clean, `.qaia/` untracked/ignored throughout).

## Token count

Not reported here. Per the established method (`plugins/qaia-core/README.md`), the number that
belongs in the token-budget table is read by the orchestration layer **above** the executing
agent, never self-declared by the agent (an agent has no reliable access to its own token
counter — the same limitation the method doc already discloses). This pilot's job was to produce
a faithful, complete run to measure; updating the table itself with the resulting figure is a
maintainer follow-up and is intentionally left out of this commit (the task also asked not to
touch `plugins/qaia-core/README.md`).

## Note on scope

This was a single pilot run on one fixture (US-004, full journey already complete except
`feedback`). It does not exercise the "no `.qaia/` at all" branch (step 4, the three engagement
models) or a mid-journey US with a genuinely incomplete step — both remain open if a second
pilot is wanted before promoting `qaia-help` from "Estimé" to "✅ Mesuré" in the budget table.
