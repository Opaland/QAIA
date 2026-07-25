# Business rules — discount & checkout

One concern per entry, declarative and testable, provenance mandatory (shared contract rule 5).
These are project truths that **do not appear in any single US** — they live here so every test
design retrieves and applies them (D38 RAG-in-use).

## BR-KB-004 — single-use per customer
A discount code is **single-use per customer**: once a customer has redeemed a code on a
completed order, re-applying the same code is rejected (`code already used`).
_Provenance: SHOP-201, 2026-03-11, decided-by product. Promoted from feedback (2 recurrences)._

## BR-KB-007 — stacking disabled by config
Code **stacking is disabled** in this project (`checkout.stacking = false`): applying a second
code replaces the first, it never adds. If stacking is later enabled by config, both apply.
_Provenance: SHOP-233, 2026-04-02, decided-by product. Config-driven — not inferable from a US._

## BR-KB-011 — B2B customers bypass the cart minimum
The €20 cart minimum for discount eligibility is **waived for B2B (segment = business)**
customers; retail customers below €20 are rejected (`cart below minimum`).
_Provenance: SHOP-260, 2026-05-19, decided-by billing. Segment/role-driven._

## BR-KB-014 — codes are case-insensitive, trimmed
Codes are matched **case-insensitively** after trimming surrounding whitespace (`  save10 ` ==
`SAVE10`). A code differing only by case or surrounding spaces is the same code.
_Provenance: anomaly ANO-88 (a valid code rejected for trailing space), 2026-06-01._
