# Knowledge base — master index (MANDATORY, D21)

One line per file: `path | topic | tags`. Every skill read routes through this index; a file
absent here is invisible. Built by `rag-build` (initialize + enrich in one pass) from the real
US-EVAL-009 checkpoint `eval/skill-eval-campaign-2026-07-29/US-EVAL-009-octoperf-petstore/state/01-extraction.md`
(OctoPerf Pet Store, JPetStore-style catalog/cart — public shared demo).

| path | topic | tags |
|---|---|---|
| business-rules.md | cart arithmetic, currency display, checkout availability, stock flag | cart, subtotal, total-cost, currency, usd, checkout, stock, remove |

## Starter files not created (⚠ VALIDATION pending)

`rag-build` step 1 says: "create `knowledge/` with `index.md` and **offer** the four starter files
— `glossary.md`, `business-rules.md`, `application-map.md`, `anomaly-history.md` — **asking the
user 2-3 seed questions for each they accept**." This run is non-interactive (skill-coverage
campaign, no human in the loop), so only the file for which real sourced content existed
(`business-rules.md`) was written. `glossary.md`, `application-map.md` and `anomaly-history.md`
are **offered, not created**: creating them here would mean either inventing seed content or
committing empty stubs, both of which the shared contract forbids. Status:
**pending-validation** — a human must accept them and answer the seed questions.
