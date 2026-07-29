# Knowledge index — pilot base for US-005

Master index (D21). One line per file. Every read by any skill goes through this file.

| path | topic | tags |
|---|---|---|
| `business-rules.md` | loan ledger / reversal ordering | loan, ledger, repayment, refund, reversal, balance |

## Provenance note

This knowledge base was **initialized fresh** for this pilot run (no prior `.qaia/knowledge/`
existed anywhere in the project's own tree — `examples/*/knowledge` and
`eval/baselines/*/knowledge` seen elsewhere in the repo belong to other fixtures/runs, not this
one). Per `rag-build`'s guardrails, only a genuinely source-grounded, provenance-carrying entry
was seeded (`BR-KB-001`, a literal restatement of AC6) — no speculative or simulated-default
answer from `02-understanding.md` was promoted, since a `simulated: accepted-as-is` default is
not a validated human decision and promoting it would fabricate provenance this skill requires
to be honest (`decided-by` would have no real decider). The other nine open/assumption
questions stay exactly where the shared contract puts them: in `openArbitrations`, not in the
knowledge base.
