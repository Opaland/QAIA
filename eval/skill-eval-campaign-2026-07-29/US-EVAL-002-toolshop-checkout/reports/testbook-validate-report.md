# testbook-validate report — US-EVAL-002

## Deterministic structural pass (real script execution, not simulated)

Ran (PowerShell, real subprocess, no simulation):

```
python eval/tools/structural_score.py eval/skill-eval-campaign-2026-07-29/US-EVAL-002-toolshop-checkout/testbooks/toolshop-checkout.feature --acs AC1,AC2,AC3,AC4 --source eval/skill-eval-campaign-2026-07-29/US-EVAL-002-toolshop-checkout/state/01-extraction.md
```

Ran clean on the first try (no `UnicodeEncodeError` — the Windows-console UTF-8 fix made during
`US-EVAL-001`'s run is confirmed still in effect). `--source` was passed per this skill's own rule
(line 19: "If a source/matrix exists in the inputs but was not passed, the report must say the
sniffer/completeness ran blind") — it did not run blind here.

**Result** (real output, verbatim):

```json
{
  "file": "toolshop-checkout.feature",
  "scenarios": 11,
  "readability": 25.0,
  "completeness": 7.5,
  "coherence": 20.0,
  "traceability": 25.0,
  "penalties": { "markers": 0, "sniffer": 0, "redundancy": 6 },
  "score": 72,
  "gate": "CONCERNS",
  "forced_stop": false,
  "findings": [
    "pesticide paradox: 1 near-duplicate group(s) (same Given/When shape) -> -6: [['An authenticated customer completes checkout on a cart they own', 'A newly created invoice starts in the awaiting-fulfillment status (proposed default, unconfirmed)']]"
  ],
  "tag_audit": {
    "missing_priority_tag": [],
    "technique_tag_violations": [],
    "negative_scenarios": 7,
    "non_smoke_scenarios": 11,
    "negative_ratio_recomputed_pct": 63.6
  }
}
```

**Completeness (7.5/30) is the real driver of this score, and it is a genuine finding about this
test book, not a scorer defect.** The script's `completeness` dimension only counts an AC as
covered when at least one of its scenarios has a `Then` matching `ASSERT_RE` — a concrete literal
(a number, a quoted value, or a keyword like `status`/`equals`/`contains`/`returns`). Of this
book's 11 scenarios, only `QAIA-US-EVAL-002-011` (AC4, the invoice-status scenario, asserting the
quoted literal `"AWAITING_FULFILLMENT"`) meets that bar — every other scenario's `Then` is
phrased qualitatively ("the cart reflects the added product", "the checkout request is refused",
"an invoice is created from the cart") because the underlying schemas (`InvoiceRequest`,
`CartResponse`) were never fully expanded by the source fetch (`00-source.md`, `01-extraction.md`
"Referenced artifacts not analyzed"), so no concrete field/value was available to assert without
fabricating one — consistent with `testbook-generate`'s own rule (line 32: "a computed value is
only as grounded as its inputs... keep the assertion qualitative"). The scorer is correctly
punishing the resulting shallowness of the `Then` steps; it is not a false positive. `forced_stop`
is `false` (no hollow/empty/vague `Then` detected — the qualitative phrasing is thin but not
hedge-worded or evidence-free), so this is a real completeness gap, not a fabrication/hollow-AC
defect.

The single redundancy finding (`004`/`011` sharing a `Given`/`When` shape) is expected and not a
defect: both scenarios use the same authenticated-checkout action with a different `Then`
(invoice created vs. invoice status), exactly the case this script's own documentation says is
"reported for human judgment, not auto-failed."

## 8-dimension checklist

| Dimension | Score | Evidence |
|---|---|---|
| Atomicity | 2 | One `When` per scenario; outcomes only in `Then`; both Outlines (`003`, `009`) correctly merge same-priority/same-confidence examples. |
| Coverage | 2 | AC1 3/3, AC2 4/4, AC3 3/3, AC4 1/1 — all 11 design conditions covered, 0 waived. |
| Negative-path coverage (ADR 0001) | 2 | All 7 `[req-neg]` conditions have a covering `@negative` scenario. |
| Technique fit | 2 | `@ep`/`@boundary` for the cart-input classes, `@decision-table` for the auth×ownership×cart-state cross, `@state-transition` for the initial-status question, `@oracle:rfc5322` grounding the malformed-email case instead of guessing it. |
| Business correctness | 1 | The exact `InvoiceRequest`/`CartResponse` field shapes and the cart-linkage mechanism (Q7) were never confirmed by a primary source (schemas not expanded by the fetch tool) — every checkout scenario's phrasing rests on that unconfirmed assumption, honestly flagged in `synthesis.md`, not hidden, but not full-confidence. |
| Ambiguity honesty | 2 | Q1-Q7 all visible in `synthesis.md`'s open/assumption list; `007` and `011` explicitly labeled "proposed default, unconfirmed" in their own scenario titles, matching the design/priorities checkpoints' flags. |
| Traceability | 2 | Stable `@QAIA-US-EVAL-002-NNN` IDs, `# condition:` comment on every scenario, matrix consistent with the book. |
| Gherkin form | 2 | Valid keywords, correct `Scenario Outline`/`Examples` use, no `Background` (correctly omitted — no invariant holds across all 11 scenarios: some are authenticated, some guest, some pre-auth). |

**Total: 15/16.** Per the gate rule, a total ≥14 with **business correctness at 1** forces
**CONCERNS**, not PASS, regardless of the total.

## Gate decision

Two gates, stricter wins: structural = **CONCERNS** (72/100, driven by the completeness gap
above), checklist = **CONCERNS** → **overall: CONCERNS**.

## Three highest-impact fixes

1. **Tighten `Then` assertions to concrete, verifiable values** where the underlying schema
   permits it (e.g. assert an HTTP status code or a response field once `InvoiceRequest`/
   `CartResponse` are actually confirmed) — this is the direct cause of the low structural
   completeness score, and the fix is bounded by resolving Q7 first (asserting a field that
   doesn't exist would be a worse defect than the current qualitative phrasing).
2. **Arbitrate Q6 and Q5 for real** (`AC2-C4`/`007`, `AC4-C1`/`011`) — both are P1, both rest on
   unconfirmed proposed defaults, and `011` is also the one scenario driving what little
   completeness score this book has; getting it wrong compounds two problems at once.
3. **Confirm the schema fields against a primary source** — the UI origin was unreachable (403)
   in this run; a follow-up attempt (different network path, or a user-supplied OpenAPI JSON
   export) could resolve Q7 and unlock concrete assertions across most of the book, not just AC4.

No file was modified by this audit (`testbook-validate` is audit-only, per its own guardrails).

## Skill evaluation — `testbook-validate`

- **Skill evaluated**: `plugins/qaia-core/skills/testbook-validate/SKILL.md`.
- **Input**: `toolshop-checkout.feature` (11 scenarios), `01-extraction.md` as `--source`.
- **Output**: this report.
- **Verdict**: **CONFORME.**
- **Evidence**: line 19's rule that a source available but not fed must be reported as a blind
  run was correctly avoided by actually passing `--source`/`--acs` in the recorded command (not
  merely mentioned as a good idea). Line 21's rule that the structural pass and the checklist stay
  "separate... never averaged together" is respected: the report shows 72/100 and 15/16 as two
  distinct numbers, combined only at the gate-decision step by taking the stricter of the two. The
  UTF-8 console fix found and applied during `US-EVAL-001`'s run of this same tool (a defect in
  `eval/tools/structural_score.py`, not in this skill's own text) is confirmed still effective —
  no `UnicodeEncodeError` occurred this run, so nothing new needed fixing here.
- **Modification proposed**: none.
