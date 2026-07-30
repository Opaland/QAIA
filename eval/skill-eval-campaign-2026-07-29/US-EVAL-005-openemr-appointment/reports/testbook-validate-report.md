# testbook-validate report — US-EVAL-005

## Deterministic structural pass (real script execution, not simulated)

Ran (Git Bash, real subprocess, no simulation):

```
python eval/tools/structural_score.py eval/skill-eval-campaign-2026-07-29/US-EVAL-005-openemr-appointment/testbooks/openemr-appointment-booking.feature --acs AC1,AC2,AC3 --source eval/skill-eval-campaign-2026-07-29/US-EVAL-005-openemr-appointment/state/01-extraction.md
```

Ran clean on the first try (no `UnicodeEncodeError` — the Windows-console UTF-8 fix made during
`US-EVAL-001`'s run is still in effect). `--source` was passed per this skill's own rule (line 19:
"If a source/matrix exists in the inputs but was not passed, the report must say the
sniffer/completeness ran blind") — it did not run blind here.

**Result** (real output, verbatim):

```json
{
  "file": "openemr-appointment-booking.feature",
  "scenarios": 12,
  "readability": 25.0,
  "completeness": 0.0,
  "coherence": 20.0,
  "traceability": 25.0,
  "penalties": { "markers": 0, "sniffer": 0, "redundancy": 0 },
  "score": 70,
  "gate": "CONCERNS",
  "forced_stop": false,
  "findings": [],
  "tag_audit": {
    "missing_priority_tag": [],
    "technique_tag_violations": [],
    "negative_scenarios": 11,
    "non_smoke_scenarios": 12,
    "negative_ratio_recomputed_pct": 91.7
  }
}
```

**Completeness is 0.0/30 — worse than US-EVAL-002's 7.5/30, and a genuine finding about this test
book, not a scorer defect.** The script's `completeness` dimension only counts an AC as covered
when at least one of its scenarios has a `Then` matching `ASSERT_RE` — a concrete literal (a
number, a quoted value, or a keyword like `status`/`equals`/`contains`/`returns`). Every one of
this book's 12 `Then` steps is phrased qualitatively ("the appointment is created and returned in
the response data", "the appointment creation is refused", "...refused with a validation error",
"no appointment is created") — **including `011`/`012`, which quote the malformed input value in
the `When` step but never assert a concrete result value in the `Then`** (they assert only that
creation is refused, not e.g. a specific HTTP status code or `validationErrors` field content).
This traces directly to `01-extraction.md`'s "Referenced artifacts not analyzed" note: the
interactive Swagger UI never expanded past a JS shell, so the exact response schema
(`validationErrors` field shape, HTTP status codes) was never confirmed by any source, and
asserting one would have been fabrication — consistent with `testbook-generate`'s own rule (line
32: "a computed value is only as grounded as its inputs... keep the assertion qualitative"). The
scorer is correctly punishing the resulting shallowness of every `Then` step in this book; it is
not a false positive, and it is a stronger (harsher, more honest) signal than US-EVAL-002 produced
on a structurally similar API-only source, because that book had at least one concrete literal
(`"AWAITING_FULFILLMENT"`) available from its source and this one has none. `forced_stop` is
`false` (no hollow/empty/vague `Then` detected — the qualitative phrasing is thin but not
hedge-worded or evidence-free), so this is a real completeness gap, not a fabrication/hollow-AC
defect.

No redundancy finding this run (`penalties.redundancy: 0`) — unlike US-EVAL-002's one
near-duplicate group, no two scenarios in this book share an identical `Given`/`When` shape; the
create-only slice's conditions are structurally distinct enough (different field under test per
scenario) that this did not arise here. No sniffer hits and no unresolved markers either.

## 8-dimension checklist

| Dimension | Score | Evidence |
|---|---|---|
| Atomicity | 2 | One `When` per scenario; outcomes only in `Then`; all three Outlines (`002`, `011`, `012`) correctly merge same-priority/same-confidence examples. |
| Coverage | 2 | AC1 4/4, AC2 4/4, AC3 4/5 — every AC has ≥1 covering scenario; the one missing condition (`AC3-C2`) is a cited P3 waiver, not a silent AC-level gap. |
| Negative-path coverage (ADR 0001) | 2 | 11 of 12 `[req-neg]` conditions have a covering `@negative` scenario; the 12th (`AC3-C2`) is a standing, cited P3 waiver per `testbook-generate`'s own scope rule, not an uncited gap. |
| Technique fit | 2 | `@ep`/`@boundary` for the field-content classes, `@decision-table` for the token-state × scope × validity cross, `@oracle:iso8601` grounding the malformed-date/time cases instead of guessing them. |
| Business correctness | 1 | Zero scenarios assert a concrete response value (completeness 0.0 above) — every checkout-equivalent scenario rests on the documented `crus`/`validationErrors` channel names but never a confirmed status code or field value, and three of the five P1 scenarios (`004`, `007`, `008`) additionally rest on genuinely `[open]` proposed defaults (double-booking, cross-site scoping, auth/validation precedence) that could each turn out to be the *opposite* of what is asserted. Honestly flagged throughout, but full-confidence business correctness cannot be claimed. |
| Ambiguity honesty | 2 | Q1-Q9 all visible in `synthesis.md`'s open/assumption list; `004`, `007`, `008` explicitly labeled "proposed default, unconfirmed" in their own scenario titles, matching the design/priorities checkpoints' flags; `AC3-C2`'s deferral is stated with its reason, not silently dropped. |
| Traceability | 2 | Stable `@QAIA-US-EVAL-005-NNN` IDs, `# condition:` comment on every scenario, matrix consistent with the book. |
| Gherkin form | 2 | Valid keywords, correct `Scenario Outline`/`Examples` use, no `Background` (correctly omitted — no invariant holds across all 12 scenarios: some are unauthenticated, some authenticated, some pre-auth). |

**Total: 15/16.** Per the gate rule, a total ≥14 with **business correctness at 1** forces
**CONCERNS**, not PASS, regardless of the total — same outcome class as US-EVAL-002, for a related
but distinct reason (there: an unconfirmed schema *linkage*; here: zero confirmed response
*values at all*, plus three load-bearing `[open]` proposed defaults on P1 scenarios).

## Gate decision

Two gates, stricter wins: structural = **CONCERNS** (70/100, driven by the completeness gap
above), checklist = **CONCERNS** → **overall: CONCERNS**.

## Three highest-impact fixes

1. **Arbitrate Q1, Q6 and Q9 for real** (`AC1-C4`/`004`, `AC2-C3`/`007`, `AC2-C4`/`008`) — all
   three are P1, all three rest on unconfirmed proposed defaults, and getting any of them wrong
   means the scenario asserts the *opposite* of OpenEMR's real behavior, which is a worse defect
   than an honest gap. Q6 (cross-site patient scoping) is the highest-stakes of the three — a
   wrong assumption there means this book fails to test a genuine health-data access-control
   boundary.
2. **Obtain a real OpenAPI/Swagger export or a working demo instance** to unlock concrete
   assertions (HTTP status codes, the exact `validationErrors` field shape) — this is the direct
   cause of the 0.0 structural completeness score, and unlike US-EVAL-002's partial case, every
   single scenario in this book is affected, not just one AC.
3. **Confirm whether `docs/DEMO-TARGETS.md`'s designated OpenEMR demo URL is stale** — `00-source.md`
   found `one.openemr.io/d/openemr` returning HTTP 404 and the bare host root serving only a
   default Apache page, not the documented demo container. If this is a genuine demo-availability
   regression (not just this run's timing), it is worth flagging back to whoever maintains
   `docs/DEMO-TARGETS.md`, separately from this test book's own content.

No file was modified by this audit (`testbook-validate` is audit-only, per its own guardrails).

## Skill evaluation — `testbook-validate`

- **Skill evaluated**: `plugins/qaia-core/skills/testbook-validate/SKILL.md`.
- **Input**: `openemr-appointment-booking.feature` (12 scenarios), `01-extraction.md` as
  `--source`.
- **Output**: this report.
- **Verdict**: **CONFORME.**
- **Evidence**: line 19's rule that a source available but not fed must be reported as a blind run
  was correctly avoided by actually passing `--source`/`--acs` in the recorded command. Line 21's
  rule that the structural pass and the checklist stay "separate... never averaged together" is
  respected: the report shows 70/100 and 15/16 as two distinct numbers, combined only at the
  gate-decision step by taking the stricter of the two. Line 38 ("be as strict with QAIA-generated
  books as with external ones") is exercised concretely here: this run's structural completeness
  (0.0) is markedly worse than US-EVAL-002's (7.5) on a book generated by the same skill chain in
  the same campaign — the report does not soften that comparison or explain it away, it states the
  harsher number plainly and traces it to a real, cited cause (zero concrete `Then` assertions
  anywhere in the book, not one AC out of four as in the prior run).
- **Modification proposed**: none.
