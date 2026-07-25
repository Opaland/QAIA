# qaia-score calibration (issue #17)

Does the scoring plugin's verdict track real test-book quality? Measured on 3 books of known quality (read-only scoring, judge not told to trust the labels).

## Result

| Book | Score /20 | Gate | Matches known quality |
|---|---|---|---|
| `oracle-demo/card-validation.feature` (good: stable IDs, negatives, `@oracle` tags) | **18** | PASS | ✅ |
| `oracle-demo/openapi-oracle.feature` (good: OpenAPI-derived, cited) | **18** | PASS | ✅ |
| `weak-book.feature` (control: non-atomic, no tags/IDs, no negatives, vague `Then`) | **2** | FAIL | ✅ |

**Discriminates cleanly:** 16-point gap, opposite gates, no false positive/negative. Penalties are traceable — the two good books lose the same 2 points on a real gap (priority rationale / synthesis), the weak book floors on rubric zeros (atomicity, tags, negative paths).

## Honest caveats

- **Small sample (n=3), no mid-zone.** No CONCERNS-band book (~11-14/20) was tested; near-threshold robustness (score ~15) is not demonstrated.
- **Judge noise ±1-2 pts** on subjective dimensions (priority rationale, synthesis quality) — the two 18s could swing 16-19 without changing the gate here, because the PASS/FAIL margin is wide. Near a threshold it could flip.

## Verdict

`qaia-score` is **calibrated and discriminant on this sample, safe for read-only review assistance** — it separates good from bad reliably with traceable penalties, and (by design) writes only the manifest `gate` block, never self-scoring a book it produced. **It stays a human decision aid, not an automatic blocking gate**, until the CONCERNS band and near-threshold stability are validated. Consistent with the project rule: a skill never self-validates.
