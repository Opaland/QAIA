# oracle-generate — US-EVAL-009 (OctoPerf Pet Store cart)

Skill: `plugins/qaia-core/skills/oracle-generate/SKILL.md`.
Reference file loaded per SKILL.md line 12: `oracles/library.md`.
Derivation executed, not asserted: `derive.py` → `../raw/oracle-generate.out.txt`.

## Step 1 — Detect standardized domains (SKILL.md line 66)

Scanned `state/01-extraction.md` and `state/03-design.md`.

| Domain trigger found | Oracle | Where |
|---|---|---|
| "US dollars with a `$` prefix and two decimal places (`$16.50`)" — `01-extraction.md` l.35 | **ISO 4217** | AC1 (row Total Cost), AC2 (Sub Total) |
| `/actions/Cart.action?viewCart=`, `?addItemToCart=&workingItemId=EST-1`, `?removeItemFromCart=` — `00-source.md` ll.35-54: the whole slice is HTTP GET endpoints with query params | **HTTP semantics (RFC 9110)** | AC3 (remove, checkout gate, cross-session access) |

Not triggered, stated explicitly rather than silently skipped: Luhn (no PAN in this slice — checkout
payment is out of scope per `00-source.md` dependencies), ISO 8601 (no date/expiry field observed),
RFC 5322 (the sign-in/register forms are out-of-slice), ISO 3166 (no country field), IBAN (none).

**Project oracle (SKILL.md l.24-29): NOT in play.** No OpenAPI/Swagger or JSON Schema file was
designated by a user for this US, and the skill permits reading exactly *one user-designated* source.
JPetStore ships no spec in this campaign directory. Nothing was fetched; `oracles/openapi.md` was
deliberately not applied. Recorded rather than substituted with a guessed contract.

## Step 2 — ⚠ VALIDATION: **pending-validation**

SKILL.md line 67 requires the oracle to *propose* and a human to arbitrate ("The oracle *proposes*;
the human arbitrates"). This run is non-interactive: **no human accepted these cases.** They are
therefore emitted below as a *proposal* in a separate file and were **not** merged into
`testbooks/octoperf-petstore-cart.feature`. Recorded in the refreshed manifest as
`openArbitrations[id=AC3-C4-oracle], kind=open`.

## Step 3 — Emitted (proposed) oracle-derived conditions

### ISO 4217 — AC2

The existing book's `AC2-C4` (`@oracle:iso4217`) asserts only "exactly two decimal places". The
library's own rule is stronger — *"Minor-unit rule drives rounding: JPY has no decimals, BHD has 3 —
generate rounding boundary cases accordingly"* (`library.md` l.33). Derived here:

- `USD` minor units = 2 → quantum `0.01`.
- **Derived, and it contradicts the book's framing of Q6**: a sum of finitely many 2-dp amounts is
  *exactly* 2-dp. `derive.py` output: `sub-cent residue of the sum = 0.00 -> tie-break reachable by
  summation alone: False`. So Q6's "no *observed* source price forces a sub-cent rounding tie-break"
  understates it — **no catalog price ever can**, as long as every list price is itself 2-dp.
  A rounding *tie-break* condition is therefore not derivable and stays out (SKILL.md l.73, "never
  invent"). What *is* derivable is a **binary-float drift** assertion: `0.1 + 0.2 = 0.30000000000000004`
  in IEEE-754 (`derive.py`, verbatim) — an implementation summing prices as floats can display a Sub
  Total that differs from the exact decimal sum. That is the real, oracle-grounded money-correctness
  negative for AC2, and it is not in the current book.

  → **`AC2-C6`** `[ep]` `@oracle:iso4217` — the displayed Sub Total equals the *exact decimal* sum of
  the row Total Costs, to the ISO 4217 USD quantum (`0.01`), with no representation drift.

### HTTP semantics (RFC 9110) — AC3

`library.md` l.23 supplies the expected `Then` status per condition. Mapped onto the observed
endpoints:

| ID | Condition | Expected `Then` (from the oracle) | Status |
|---|---|---|---|
| `AC3-C5` (existing) | session B requests `Cart.action?viewCart=` bound to session A | `404` (not found **or** not visible/privacy) **or** `403` (recognized, refused) | **`[open]`** — the library gives *both*; RFC 9110 permits hiding existence, so which one is a product decision, not an oracle output |
| `AC3-C5b` (new) | session B calls `Cart.action?removeItemFromCart=&workingItemId=EST-1` against session A's cart | `404`/`403`, **and** session A's cart unchanged | `[open]`, same reason — the mutation variant, currently untested |
| `AC3-N1` (new) | `Cart.action?addItemToCart=&workingItemId=DOES-NOT-EXIST` | `404` — "resource not found" | derivable, `[req-neg]` |
| `AC3-N2` (new) | `Cart.action?addItemToCart=&workingItemId=` (empty param) | `400` — "malformed body/params" | derivable, `[req-neg]` |
| `AC3-C4` (existing) | checkout reached with `In Stock? = false` | `409` (conflict) **if** the store blocks overselling; success **if** backorder is allowed | **stays `[open]`** — Q3 is a policy fork; the oracle supplies the *status for each branch*, never the branch itself |

`AC3-N1` and `AC3-N2` raise the `[req-neg]` count from 1 to 3 without fabrication — each cites
`library.md` l.23, not the US.

## Step 4 — Provenance

Every proposed scenario in `oracle-proposed.feature` carries `@oracle:<standard>` plus a
`# oracle: <ref>` comment naming the exact library line. Wording for the synthesis, if a human
accepts: *"negative cases AC3-N1 (404) and AC3-N2 (400) are grounded in the RFC 9110 status
semantics of `oracles/library.md` l.23, not fabricated; AC2-C6 is grounded in the ISO 4217 USD
minor-unit rule of l.33."*

**Not written into `03-design.md` or `synthesis.md`.** SKILL.md line 69 says to record provenance
there, but step 2's VALIDATION gate has not been passed and this session is forbidden from editing
the campaign's source artifacts. Recorded here instead, with the gate left open.
