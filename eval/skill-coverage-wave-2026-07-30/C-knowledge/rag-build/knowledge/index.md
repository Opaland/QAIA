# Knowledge base — master index (MANDATORY, D21)

One line per file: `path | topic | tags`. Every skill read routes through this index; a file
absent here is invisible. Initialized 2026-07-30 by `rag-build` for the OctoPerf Pet Store
(JPetStore-style) evaluation target, seeded from the business rules extracted at US-EVAL-009.

| path | topic | tags |
|---|---|---|
| business-rules.md | cart stock gating, price display format | cart, stock, in-stock, availability, checkout, price, currency, format, rounding, subtotal |

## Starter files not created (rag-build step 1)

`rag-build` step 1 offers four starter files — `glossary.md`, `business-rules.md`,
`application-map.md`, `anomaly-history.md` — "asking the user 2-3 seed questions for each they
accept". This run is non-interactive (skill-coverage evaluation wave, no human in session), so
per the shared contract rule 3 the offer is recorded, not answered:

- `business-rules.md` — **created**: a real candidate rule existed in
  `US-EVAL-009/state/01-extraction.md`, so it had a non-empty payload without any seed question.
- `glossary.md` — `simulated: declined` (no seed answers available; creating an empty stub would
  add an index row pointing at no knowledge).
- `application-map.md` — `simulated: declined` (same reason; `US-EVAL-009/state/00-source.md`
  holds the surface capture, and copying it here without user confirmation would duplicate, not
  curate).
- `anomaly-history.md` — `simulated: declined` (no production incident is known for this target).

All four `simulated:` entries are pending human review, not resolved.
