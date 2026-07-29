# 04-priorities — US-EVAL-003

| Condition | Impact | Probability | Priority | Rationale |
|---|---|---|---|---|
| AC1-C1 | 3 | 1 | **P2** (3) | The sole write path every other endpoint reads from — total-service-loss blast radius if the happy path itself is broken (impact 3), but this is the simplest, best-tested code path in the service (probability 1). |
| AC1-C2 | 1 | 1 | P3 (1) | Min-length boundary on an already-covered happy path — low marginal risk once AC1-C1 passes. |
| AC1-C3 | 1 | 1 | P3 (1) | Max-length boundary, same reasoning as AC1-C2. |
| AC1-C4 | 2 | 1 | P3 (2) | Minimal valid date range — a real boundary, but low complexity (single strict-inequality check). |
| AC1-C5 | 2 | 3 | **P1** (6) | Impact 2 (an unvalidated `roomid` could let a booking reference a non-existent room — a data-integrity risk, not a crash). Probability bumped to 3 because this condition rests on `[assumption]` Q1, per this skill's own rule that assumption/open-flagged conditions score higher — **flag: human arbitration decides whether room-existence should even be checked here.** |
| AC2-C1 | 2 | 2 | **P2** (4) | A validation gap here lets a syntactically-invalid `roomid` (0) persist — impact 2 (data-quality, not a crash); probability 2 (an off-by-one on `@Min` is a classic BVA-class defect). |
| AC2-C2 | 2 | 2 | **P2** (4) | Same reasoning as AC2-C1, `firstname` min-boundary. |
| AC2-C3 | 2 | 2 | **P2** (4) | Same reasoning, `firstname` max-boundary. |
| AC2-C4 | 2 | 1 | P3 (2) | Blank-name case has an explicit, simple `@NotBlank` check (lower probability than the size boundaries — a coarser, harder-to-miss condition). |
| AC2-C5 | 2 | 2 | **P2** (4) | Same reasoning as AC2-C2, `lastname` min-boundary. |
| AC2-C6 | 2 | 2 | **P2** (4) | Same reasoning, `lastname` max-boundary. |
| AC2-C7 | 2 | 1 | P3 (2) | Same reasoning as AC2-C4, for `lastname`. |
| AC2-C8 | 2 | 2 | **P2** (4) | A missing `depositpaid` slipping through would corrupt a boolean business field silently — impact 2, probability 2 (a `@NotNull` on a primitive-boxing boundary is a real defect class). |
| AC2-C9 | 2 | 2 | **P2** (4) | A missing `bookingdates` slipping through would break every downstream date-dependent read — impact 2, probability 2. |
| AC3-C1 | 3 | 2 | **P1** (6) | A same-day (0-night) booking persisted is a genuine business-integrity failure (impact 3) visible to real downstream consumers (availability queries, summaries); probability 2 (a strict-vs-non-strict inequality is an easy off-by-one to get wrong). |
| AC3-C2 | 3 | 2 | **P1** (6) | Same reasoning as AC3-C1, inverted-range side of the same boundary. |
| AC4-C1 | 3 | 2 | **P1** (6) | A double-booked room is the single worst-case business failure this US-slice can hide (impact 3, a real guest conflict) — probability 2 (the overlap-window SQL logic is more complex than a plain field check). |
| AC4-C2 | 2 | 1 | P3 (2) | Confirms room-scoping correctness (a false-positive conflict block would be a real bug) but the logic is simple (single `roomid` filter in the query) — probability 1. |
| AC5-C1 | 1 | 1 | P3 (1) | Optional field, cosmetic-severity if wrongly accepted/rejected — impact 1. |
| AC5-C2 | 1 | 1 | P3 (1) | Same reasoning, valid-email positive case. |
| AC5-C3 | 1 | 2 | P3 (2) | Optional field (impact 1) but a real size-boundary defect class (probability 2). |
| AC5-C4 | 1 | 2 | P3 (2) | Same reasoning as AC5-C3. |
| AC5-C5 | 1 | 1 | P3 (1) | Min-boundary positive case, low marginal risk. |
| AC-DT-1 | 3 | 3 | **P1** (9) | Impact 3 (which status a client sees when two failure modes coincide is exactly the kind of contract ambiguity that breaks client error-handling in production). Probability bumped to 3 because this condition is `[assumption]` Q3, per this skill's own rule — **flag: this P1 rank rests on standard Spring MVC framework semantics inferred, not literally read in `Booking.java`/`BookingController.java`; human arbitration is what actually confirms it against the running service.** |

⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) — no human override recorded;
the AC1-C5/Q1 and AC-DT-1/Q3 flags above are carried forward as-is into `testbook-generate` rather
than silently resolved.

**Scope decision for `testbook-generate` (Q22 quota trade-off)**: default scope is **P1 + P2 in
full** (13 conditions: 5 P1, 8 P2); the 11 P3 conditions are listed above with their rationale but
**not** generated into scenarios in this run — a human call per this skill's own step 4, deferred
here since no human is available to override the default (same convention as US-EVAL-001, which
had no P3 conditions to defer in the first place — this run is the first in the campaign series to
actually exercise that deferral).

## Journey

| Step | Status |
|---|---|
| 04-priorities | done — scores above proposed, not yet arbitrated by a human |

## Skill evaluation — `prioritize` (`plugins/qaia-core/skills/prioritize/SKILL.md`)

**Verdict: CONFORME.**

**Evidence**: Step 1 (lines 12-16) requires an impact/probability/priority triple with a rationale
for every condition from `03-design.md` — all 24 conditions are scored above, none skipped. Step
2's flag rule (line 17: "flag every score based on an `[assumption]` or `[open]` item") is applied
to `AC1-C5` (Q1) and `AC-DT-1` (Q3), both explicitly naming which assumption inflated their
probability, matching the "probability bumped... per this skill's own rule" phrasing the rubric
expects to be traceable back to this exact instruction. The git-history signal (line 15) was
correctly not invoked — no target repo path was named for *this* session (the campaign brief only
designated the public upstream GitHub repo for read-only source grounding at `us-ingest`, not a
local working copy for `git log --stat`), and the guardrail (line 29) requires it be skipped
silently rather than faked when unavailable, which is what happened (no `@history(...)` citation
anywhere above). Step 4's scope-deferral note (line 19, "P3 coverage is their call") is recorded
explicitly rather than silently generating or silently dropping the P3 set. No deviation found.
**Modification proposed: none.**
