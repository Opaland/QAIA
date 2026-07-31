#!/usr/bin/env python3
"""oracle-generate, step 1+3 executed for real on US-EVAL-009.

Two built-in oracles trigger (oracles/library.md), no network, no project oracle
(no OpenAPI/JSON Schema was designated by the user for this US):
  - ISO 4217 (currency codes / minor units) -> AC2 Sub Total arithmetic
  - HTTP status semantics, RFC 9110         -> AC3 access boundary & malformed params

This script DERIVES the expected values instead of asserting them from memory.
Run: python eval/skill-coverage-wave-2026-07-30/A-artifacts/oracle-generate/derive.py
"""
from decimal import Decimal

MINOR_UNITS = {"USD": 2, "EUR": 2, "JPY": 0, "BHD": 3}  # oracles/library.md, ISO 4217
CUR = "USD"
q = Decimal(1).scaleb(-MINOR_UNITS[CUR])

print(f"ISO 4217 oracle -- currency={CUR}, minor units={MINOR_UNITS[CUR]}, quantum={q}")

# Observed catalog prices (00-source.md / 01-extraction.md): EST-1 and EST-2 at $16.50
prices = [Decimal("16.50"), Decimal("16.50")]
exact = sum(prices)
print(f"  AC2-C2  exact decimal sum of {prices} = {exact}  (quantized: {exact.quantize(q)})")
print(f"  AC1-C2  16.50 x 2 = {Decimal('16.50') * 2}")

# Derived, not asserted: can a plain sum of 2-dp USD amounts ever need a tie-break?
resid = (exact * (10 ** MINOR_UNITS[CUR])) % 1
print(f"  sub-cent residue of the sum = {resid} -> tie-break reachable by summation alone: {resid != 0}")

# But binary float DOES drift -- this is the testable failure mode an oracle can pin.
f = 0.0
for p in [0.1, 0.2, 16.5, 16.5]:
    f += float(p)
d = sum(Decimal(str(x)) for x in ["0.1", "0.2", "16.5", "16.5"])
print(f"  float accumulation  {f!r}  vs exact decimal {d}  -> equal: {Decimal(str(f)) == d}")
print(f"  classic drift probe: 0.1+0.2 = {0.1 + 0.2!r} (float) vs {Decimal('0.1') + Decimal('0.2')} (decimal)")

# Invalid ISO 4217 codes from the library, for a display/format negative
print(f"  ISO 4217 invalid codes (library.md): EU, EURO, US$, XXX")

print()
print("HTTP status semantics oracle (RFC 9110, library.md line 23) -- expected Then per condition:")
HTTP = {
    "unauthenticated": 401,
    "authenticated but not allowed": 403,
    "resource not found OR not visible (privacy)": 404,
    "malformed body/params": 400,
    "conflict / already exists / race lost": 409,
    "validation rule violated": 422,
    "rate limited": 429,
}
for cond, code in HTTP.items():
    print(f"  {code}  <- {cond}")

print()
print("Mapping onto US-EVAL-009 AC3 (endpoints observed in 00-source.md: /actions/Cart.action):")
cases = [
    ("AC3-C5", "session B GETs Cart.action?viewCart= carrying session A's identifier",
     "404 (not visible / privacy) OR 403 (recognized but refused)",
     "library.md line 23 gives BOTH; RFC 9110 lets a server hide existence -> the choice is a "
     "product decision, so it stays [open], not invented"),
    ("AC3-C5b", "session B GETs Cart.action?removeItemFromCart=&workingItemId=EST-1 against session A's cart",
     "404 or 403, and session A's cart unchanged", "same citation; the mutation variant of the above"),
    ("AC3-N1", "GET Cart.action?addItemToCart=&workingItemId=DOES-NOT-EXIST", "404",
     "library.md line 23, 'resource not found'"),
    ("AC3-N2", "GET Cart.action?addItemToCart=&workingItemId= (empty / non-catalog-shaped param)", "400",
     "library.md line 23, 'malformed body/params'"),
    ("AC3-C4", "checkout attempted with an item whose In Stock? = false", "409 if the store blocks "
     "overselling, 200/redirect if backorder is allowed",
     "library.md line 23 gives 409 for 'conflict'; WHICH branch is the store's policy is Q3 -> stays [open]"),
]
for cid, cond, then, cite in cases:
    print(f"  [{cid}] {cond}\n        -> Then: {then}\n        -> cite: {cite}")
