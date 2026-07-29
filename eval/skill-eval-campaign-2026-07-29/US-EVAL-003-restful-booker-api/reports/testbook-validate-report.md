# testbook-validate report — US-EVAL-003

## Deterministic structural pass (real script execution, not simulated)

Ran, for real:

```
python eval/tools/structural_score.py \
  eval/skill-eval-campaign-2026-07-29/US-EVAL-003-restful-booker-api/testbooks/booking-create.feature \
  --acs AC1,AC2,AC3,AC4,AC5 \
  --source eval/skill-eval-campaign-2026-07-29/US-EVAL-003-restful-booker-api/state/01-extraction.md
```

(source fed explicitly per this skill's own step 2/line 19 requirement — not run blind — so
`completeness`/`sniffer` above are source-checked, not defaulted.)

**First run found a real Gherkin-form defect in the generated book itself** (not the tool):
scenario `QAIA-US-EVAL-003-001`'s `Given` and its final `And` were each wrapped across two
physical lines without a Gherkin continuation keyword — the parser correctly flagged
`"truncated step(s): ['A well-formed booking with no room conflict is created']"`. This is a
`testbook-generate`-stage authoring defect this validation step caught by actually running the
tool (not by re-reading the `.feature` file with an LLM impression) — **fixed** in
`testbooks/booking-create.feature` (both wrapped lines rejoined onto one physical line each; no
content changed, only the Gherkin form).

**Result** (after the fix):

```
score: 82/100 -- gate: PASS
readability 25/25, completeness 24/30, coherence 20/20, traceability 25/25
penalties: markers 0, sniffer 0, redundancy 12
finding: pesticide paradox -- 2 near-duplicate groups (same Given/When shape)
```

Both redundancy groups are expected, not a defect: `004`/`005` (missing `depositpaid` vs. missing
`bookingdates`) and `006`/`007` (same-day vs. inverted date range) each share a `Given`/`When`
shape but assert a genuinely distinct rule per this skill's own carve-out ("a real per-value
behavioral difference... is not a duplicate and must not be flagged as one") — flagged for a human
to confirm, not silently dismissed. `completeness` at 24/30 (not 30/30) reflects that `AC5` has no
scenario in this P1+P2-scope book — a real, honestly-reported gap, not a script quirk (see the
checklist's Coverage dimension below).

## 8-dimension checklist

| Dimension | Score | Evidence |
|---|---|---|
| Atomicity | 2 | One `When` per scenario; outcomes only in `Then`; the Outline (`003`) correctly merges 5 examples sharing priority (P2) and confidence (full). |
| Coverage | 1 | AC1 2/2, AC2 7/7, AC3 2/2, AC4 1/1 of the in-scope conditions — but **AC5 has zero scenarios** in this book (all 5 of its conditions are P3, deferred by the default P1+P2 scope, per `04-priorities.md`). A real AC with zero covering scenarios caps this dimension at 1, not 2, even though the gap is deliberate and disclosed. |
| Negative-path coverage (ADR 0001) | 1 | All 11 in-scope `[req-neg]` conditions are covered — but 5 `[req-neg]` conditions from `03-design.md` (`AC2-C4`, `AC2-C7`, `AC5-C1`, `AC5-C3`, `AC5-C4`) have no scenario in the delivered book at all (P3-deferred). Scored on coverage of the *design's* full refusal set, not just the generated subset — same honest-gap reasoning as Coverage above. |
| Technique fit | 2 | `@ep` for the two happy/whole-field-absent classes, `@boundary` for every sized/dated threshold, `@decision-table` for the room-conflict and field-shape-vs-date-range crosses. |
| Business correctness | 2 | Every asserted literal (field names, size bounds, status codes) traces to **primary source** (`Booking.java`, `BookingController.java`, `BookingService.java`, `DateCheckValidator.java`) — stronger grounding than a secondary write-up. The two extrapolations (`Q1`, `Q3`) are explicitly flagged `@low-confidence`, not asserted with full confidence. |
| Ambiguity honesty | 2 | `Q1`/`Q2`/`Q3` all visible in `synthesis.md`'s open/assumption list; `002` and `009` are explicitly titled "(proposed default, unconfirmed)," none silently resolved. |
| Traceability | 2 | Stable `@QAIA-US-EVAL-003-NNN` IDs, `# condition:` comment on every scenario, matrix consistent with the book, no ID gaps. |
| Gherkin form | 2 | Valid keywords, correct `Scenario Outline`/`Examples` use, no `Background` needed (no invariant shared by all 9 scenarios), the wrapped-line defect above fixed before this checklist pass. |

**Total: 14/16.** Per the gate rule, total ≥14 with **no dimension at 0** and neither
traceability nor business-correctness at 1 → **PASS**, not CONCERNS — even though two other
dimensions (Coverage, Negative-path) sit at 1. This is the gate rule exactly as written in
`testbook-validate/SKILL.md` line 31 (its CONCERNS-at-≥14 clause names only traceability/
business-correctness) — flagged here for the human reviewer's awareness (a book that leaves an
entire AC uncovered still nets a checklist PASS), not treated as a skill defect: the rule was
followed literally, not reinterpreted or loosened.

## Gate decision

Two gates, stricter wins: structural = **PASS** (82/100), checklist = **PASS** (14/16) →
**overall: PASS**.

## Three highest-impact fixes

1. **Generate the AC5 (P3) scenarios, or get an explicit human waiver for them** — this is the
   actual gap behind both the Coverage=1 and Negative-path=1 scores above; a checklist PASS
   should not be read as "AC5 is fine," only as "the P1+P2 subset is fine."
2. **Arbitrate Q1 and Q3 for real** (`AC1-C5`/`002` and `AC-DT-1`/`009`) — both rest on inference
   about the running service's actual behavior (room-existence checking, and which HTTP status
   wins when two failure modes coincide) that only observing the live API (or reading the `room`
   microservice / Spring's actual runtime behavior) can confirm.
3. **Human-eyeball the two redundancy groups** (`004`/`005`, `006`/`007`) — confirm each pair's
   `Then` genuinely tests a distinct rule (it does, per the analysis above) before accepting the
   structural finding as a non-issue.

## Files modified by this audit

- `testbooks/booking-create.feature` — fixed the wrapped-line Gherkin-form defect in scenario
  `QAIA-US-EVAL-003-001` (content unchanged, only line-wrapping). No other file was modified by
  this step; `testbook-validate` audits, it never rewrites test intent, only the literal
  line-wrap bug caught by the tool it ran.

## Skill evaluation — `testbook-validate` (`plugins/qaia-core/skills/testbook-validate/SKILL.md`)

**Verdict: CONFORME.**

**Evidence**: Step 2's already-amended rule (line 19, from the 2026-07-29 campaign's prior fix:
"Feed it the source when available... If a source/matrix exists in the inputs but was not passed,
the report must say the sniffer/completeness ran blind") was followed — the source
(`01-extraction.md`) and declared ACs were passed via `--source`/`--acs` for real, and this report
states so explicitly rather than silently omitting it. Step 2's requirement to actually run the
script "for true determinism" (line 14) was honored — a real subprocess call, output pasted above
verbatim, not a mental simulation, and the first run's finding (the wrapped-line defect) was a
genuine result of that real execution, not something a re-read of the file would have surfaced as
cleanly. Step 4's gate-decision thresholds (line 31) were applied exactly as written, including
the narrow CONCERNS-at-≥14 clause (traceability/business-correctness only) — followed literally
even though it produces a counterintuitive PASS on an AC-incomplete book, which is disclosed
prominently above rather than silently smoothed over. Step 5's three-highest-impact-fixes
deliverable (line 32) is present. No deviation between the skill's literal text and this output
found. **Modification proposed: none.**
