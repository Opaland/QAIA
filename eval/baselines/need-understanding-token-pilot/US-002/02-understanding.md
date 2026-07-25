---
stepsCompleted: [00-ingest, 01-review, 02-understanding]
lastStep: 02-understanding
lastSaved: 2026-07-25
---

# 02-understanding — US-002 (ambiguity hunt)

Source: `.qaia/state/US-002/01-extraction.md` (8 ACs, US-002 — prescription dosage validation).
Knowledge base: `.qaia/knowledge/` does not exist in this project — **degraded mode** (rule 8):
proceeding on the source alone, no `BR-KB-nnn` rules were available to cite or apply.

## Step 0 — Nothing-to-understand check

Not fired. `01-extraction.md` carries a concrete capability (dosage validation against per-drug
safety rules) with 8 checkable ACs covering a happy path, two independent blocking paths, one
role-conditioned exception, a data-transform rule, an audit requirement and a UX constraint. There
is real behavior to question here — proceeding.

## Step 1 — Reformulation

A prescribing physician enters a dosage for a patient before signing a prescription; the system
must check that dosage against the target drug's safety envelope (minimum effective dose, maximum
per-intake dose, maximum 24h cumulative dose, and a minimum patient age), adjusted for renal
insufficiency, and return pass / warning / blocked inline on the signing screen. Warnings (too-low
dose, underage patient without specialist standing) can be overridden by the physician with a
recorded justification; true safety breaches (too-high dose, cumulative overdose) cannot be signed
at all. This exists so that dosing errors are caught at the point of prescribing rather than
discovered later at the pharmacy or by the patient. The main risk if it misbehaves is **silent
under-blocking**: a boundary, rounding, or threshold-composition mistake that lets an unsafe dose
pass as "OK" is far worse than an over-cautious false warning, because the failure mode is a real
patient harm event with no second checkpoint downstream.

## Step 2 — Ambiguity hunt (per AC)

- **AC1** — defines the *shape* of the reference record (4 fields) but no unit of measure and no
  statement that all 4 fields share one unit per drug. See Q8.
- **AC2** — "strictly below" is explicit and exclusive; no ambiguity on this AC's own boundary.
  Undefined: what counts as a valid "documented reason" (free text? minimum length, like AC7's 20
  chars?). See Q-note under Q7 (folded into the AC2/AC7 "documented reason" vs "justification
  text" wording pair — resolved by composition, see below, not a separate numbered question).
- **AC3** — "above the maximum safe dose" drops the "strictly" qualifier AC2 uses. Boundary
  semantics at the maximum are unspecified. See Q2.
- **AC4** — "must not exceed" (same exclusive-style wording as AC3, no "strictly" needed since
  "exceed" is inherently exclusive by dictionary meaning, but paired with AC3's inconsistency it's
  worth confirming both read the same way). Bigger gap: which 24h window (rolling vs calendar-day)
  and against which clock. See Q4. This is also the AC that "does the computation" for the
  duration rule, so the reference-clock question is attached here per the skill's instruction.
- **AC5** — "below the drug's age floor" also drops "strictly." Is age == floor blocked or
  allowed? See Q3.
- **AC6** — "all maximum thresholds are reduced by 50%" — literally scoped to fields phrased as
  "maximum" (max per-intake, max cumulative). AC1's minimum effective dose and age floor are not
  phrased as "maximum." Per the skill's own classification rule (5a.1), quoting this sentence does
  **not** answer whether the reduction also applies to the minimum threshold — that stays a
  question. See Q1.
- **AC7** — "justification text of at least 20 characters" — is this the same field as AC2's
  "documented reason" and AC5's override justification, or a distinct, additional field? "Every
  override" is an unqualified quantifier and AC2/AC5 both use the vocabulary "override" /
  "overridable," so this reads as **answered by composition**: AC7's 20-character minimum applies
  to all overrides, including AC2's and AC5's. No separate question raised for this.
- **AC8** — "without page reload" is a clear, testable non-functional constraint; no ambiguity in
  the AC itself. No stated rounding/formatting of the displayed dosage or thresholds — folded into
  Q5 (decimal/rounding), since AC8 is where a rounding choice would become visible to the user.

No direct contradictions found *within* a single AC. Missing-behavior gaps (error paths,
concurrency, permissions) are handled in the adversarial and cross-AC passes below.

## Step 3 — Adversarial pass by AC type

- **State machine / lifecycle.** Not applicable. Validation results (AC8) are computed live per
  signing attempt from current inputs; nothing in the source describes a persisted state with
  transitions or re-entrance (no "warning" or "blocked" record that itself gets corrected/chained).
  No re-entrance question to raise here — noting the checklist item was run, not skipped.
- **Auth / tokens / permissions.** AC5's override path is gated on the physician holding the
  "pediatric specialist" role. The source never states *when* that role is checked relative to the
  signing action. See Q7 (mid-session role change).
- **Sorting / pagination.** Not applicable — no listing or pagination surface in this US.
- **Thresholds / quantities.** Ran the full checklist: inclusive/exclusive at every bound (Q2, Q3),
  rounding (Q5), units (Q8), reference clock (Q4). All four sub-items produced either a question or
  an explicit "not applicable" note above.

**Hard rule check (C2):** no test-data choice was made in this checkpoint to sidestep an
unspecified case (e.g., no dates or boundary values were silently picked); every sidestepped case
above was converted into a numbered question instead.

## Step 4 — Cross-AC interaction pass

- **AC2 × AC6**: a renal-insufficiency patient's minimum-effective-dose check — is it evaluated
  against the original minimum or a reduced one? Dependent on Q1's answer; not a separate question.
- **AC3 × AC5 (composition, covered, not a question)**: AC3 ("cannot be signed") carries no
  override clause anywhere in the source, and AC5's role-based override is scoped explicitly to
  the age-floor rule. Reading the ACs as independent gates that each supply their own override (or
  none), a pediatric specialist overriding AC5's age block does **not** unlock AC3 — an
  independently-triggered max-dose breach remains blocking regardless of role or age-exception
  status. Logged as **covered by composition**, no open question.
- **AC2 × AC5 (composition, covered)**: both are independently overridable by their own stated
  actors (AC2: any physician; AC5: only a pediatric specialist for the age-floor case). Each
  trigger, if it fires, needs its own override + its own AC7 audit entry; nothing suggests one
  override satisfies both. Logged as covered.
- **AC4 × concurrency**: AC4 aggregates "all intakes of the same drug for that patient" — this
  reads across prescriptions, plausibly written by different physicians/sessions. See Q6.
- **AC7 × AC2/AC5**: already resolved above (AC2/01) — "every override" unambiguously spans both.

## Step 4a — Triple-AC contradiction pass

Enumerated the safety-critical triplets that share the same patient/drug/intake entity:

- **AC3 (absolute block) × AC5 (role-conditioned age block) × AC6 (renal threshold reduction)**:
  an underage, renal-insufficient patient prescribed a dose that — after AC6's reduction — exceeds
  the reduced max-per-intake threshold (AC3), while also being underage (AC5). Even if the
  prescriber is a pediatric specialist and overrides the AC5 age warning, the AC3 breach (now
  computed against the *reduced* threshold) remains independently blocking — AC3's own text has no
  override clause and AC6's reduction only changes the number being compared, not which AC governs
  it. **Resolved by composition**, consistent with the AC3×AC5 pair above; logged as covered, not
  raised as a separate open question, because it does not require a new rule beyond "each AC's own
  override applies only to that AC."
- **AC2 (min-side warning) × AC5 (age block) × AC6 (renal reduction, scope per Q1)**: a
  renal-insufficient, underage patient's dose could sit below whatever minimum applies (original or
  reduced, per Q1) *and* the patient is underage. Both are independently overridable by their
  respective actors; no third rule (anti-disclosure/error-shape) exists in this domain to make the
  triplet contradictory the way the ADR-0001 calibration example does for a visibility/existence
  question. This domain has no analogous "hide vs 404" concern — validation outcomes are always
  shown to the authenticated prescriber (AC8), never hidden. Logged as **not applicable** — the
  specific triple-contradiction pattern from the calibration example (protected-state × scoping ×
  anti-disclosure) does not have a structural analogue in US-002; the closer triplet risk here is
  the AC3×AC5×AC6 case above, already resolved by composition.

## Step 5 — Questions (numbered, most impactful first)

1. **Q1 — AC6 scope.** Does the 50% threshold reduction for renal-insufficiency patients apply
   only to the two fields explicitly phrased as "maximum" (max safe dose per intake, max cumulative
   dose), or also to the minimum effective dose and/or the age floor? *Why it matters:* if the
   minimum effective dose is left unreduced while the maximum is halved, a drug with a narrow
   therapeutic window could end up with an unreduced minimum sitting above the reduced maximum —
   an unsatisfiable, self-contradictory range for that patient. *Proposed default:* none proposed —
   this is a genuine clinical-safety policy decision affecting a vulnerable population
   (renal-insufficient patients), not a mechanically forced answer.
   **Classification: `[open]`** (decision-tree step 2: protected/vulnerable population, silent
   source, real safety stakes on both sides of the default).

2. **Q2 — AC3/AC4 maximum-side boundary.** AC2 explicitly says "strictly below"; AC3 ("above the
   maximum safe dose") and AC4 ("must not exceed") do not carry the same "strictly" qualifier. Is a
   dose/cumulative total exactly equal to the threshold a **pass** (exclusive boundary) or already
   **blocking** (inclusive boundary)? *Why it matters:* boundary value analysis for AC3/AC4 needs
   this to place the boundary test case correctly. *Proposed default:* exclusive — dose/cumulative
   == threshold passes; only strictly greater blocks (conventional reading of "above"/"exceed,"
   consistent with AC2's own linguistic convention even though AC3/AC4 don't repeat "strictly").
   **Classification: `[assumption]`** — a reasonable, source-consistent default exists.

3. **Q3 — AC5 age-floor boundary.** Is a patient whose age exactly equals the drug's age floor
   treated as meeting the floor (allowed) or still below it (blocked)? *Why it matters:* same
   boundary-test placement concern as Q2, for the age-block/warning path. *Proposed default:* age
   == floor is allowed (floor = minimum acceptable age, "at least X" convention).
   **Classification: `[assumption]`.**

4. **Q4 — AC4 24h window.** Is the 24h cumulative-dose window a rolling window (any 24h span ending
   at the new intake) or a calendar-day window (resets at local midnight)? Against which clock is
   it measured (server time, patient's local time, prescribing site's local time)? *Why it
   matters:* this changes which historical intakes count toward the cumulative check — a wrong
   assumption could under- or over-count doses near a day boundary. *Proposed default:* rolling
   24h window, measured in the prescribing system's server time.
   **Classification: `[assumption]`** (a plausible engineering default exists; flagged for
   confirmation given the safety relevance).

5. **Q5 — Rounding/precision.** No rounding rule is given for decimal dosages compared against
   thresholds (AC2/AC3/AC4/AC6). Are comparisons performed on exact/raw decimal values, or is some
   rounding/precision rule applied before comparing to a threshold? *Why it matters:* a rounding
   step could silently move a value across a boundary. *Proposed default:* comparisons use
   raw/exact decimal values; any rounding is a display-only concern for AC8, not part of the
   validation logic.
   **Classification: `[assumption]`.**

6. **Q6 — Concurrent prescriptions (AC4).** AC4 aggregates "all intakes of the same drug for that
   patient." If two prescriptions for the same patient/drug are signed concurrently (different
   physicians or sessions), is the check-then-sign sequence guaranteed to serialize per
   (patient, drug), or is there a race window where both individually pass but combined exceed the
   cumulative max? *Why it matters:* an unmitigated race is a real path to a cumulative overdose
   the AC4 rule was written to prevent. *Proposed default:* the check is transactionally serialized
   per (patient, drug) — no silent race window.
   **Classification: `[assumption]`** (engineering default, flagged for confirmation with whoever
   owns the signing transaction boundary).

7. **Q7 — Mid-session role change (AC5).** If a physician's "pediatric specialist" role is granted
   or revoked between opening the signing screen and the moment of signing, is the role re-checked
   live at sign-time, or cached from screen-load? *Why it matters:* a stale cached role could let an
   unauthorized override happen, or block a now-eligible one. *Proposed default:* none — this is an
   access-boundary timing question.
   **Classification: `[open]`** (per the skill's explicit guardrail: an access-boundary condition
   the source is silent on is never defaulted).

8. **Q8 — Units of measure (out-of-slice).** No unit (mg, mL, IU, …) is stated for AC1's four
   threshold fields or for the dosages compared/summed against them in AC2-AC6. Is the unit fixed
   per drug (so all intakes and thresholds for a drug are directly summable/comparable in AC4), or
   can it vary per prescription/formulation? *Why it matters:* AC4's summation only makes sense if
   units are consistent. *Note:* `00-source.md`'s Dependencies section already names the drug
   reference record (which would define units) as owned by a sibling drug-catalog story, not this
   US.
   **Classification: `[out-of-slice]`** — plausibly answered by the drug-catalog sibling story;
   not answered within this ingested slice.

No 9th/10th question was needed — 8 questions covers the AC-level, cross-AC, and triple-AC passes
without padding; well under the ~10 guardrail.

## Step 6 — Validation (⚠ VALIDATION, non-interactive run)

Per `skills/README.md` rule 3, no interactive user is present in this execution; each question's
disposition below is recorded as the first-class `simulated` status, not silently resolved:

| # | Classification | Simulated disposition |
|---|---|---|
| Q1 | `[open]` | simulated: no default applied — held open, no human present to make the safety-policy call. Caps confidence on AC6-derived scenarios for renal-insufficiency patients. |
| Q2 | `[assumption]` | simulated: default applied — exclusive boundary (== threshold passes) adopted as working assumption. |
| Q3 | `[assumption]` | simulated: default applied — age == floor allowed, adopted as working assumption. |
| Q4 | `[assumption]` | simulated: default applied — rolling 24h window, server clock, adopted as working assumption. |
| Q5 | `[assumption]` | simulated: default applied — raw/exact decimal comparison, adopted as working assumption. |
| Q6 | `[assumption]` | simulated: default applied — transactional per-(patient,drug) serialization, adopted as working assumption. |
| Q7 | `[open]` | simulated: no default applied — held open, access-boundary timing question, never defaulted per skill guardrail. |
| Q8 | `[out-of-slice]` | simulated: no default applied — flagged for the drug-catalog sibling story, not answered here. |

All 8 entries are first-class per the shared contract (rule 3) and appear in the arbitration list
below as pending human review — Q1 and Q7 additionally cap the confidence of any scenario derived
from them, per the classification tree's own rule.

### Open arbitrations (pending human review)

- Q1 (AC6 scope — does the renal-insufficiency reduction apply to minimum/age-floor thresholds).
- Q7 (AC5 mid-session role-check timing).
- Q8 (units of measure — out-of-slice, likely answered by the drug-catalog story).
- Q2, Q3, Q4, Q5, Q6 — accepted defaults (assumptions), still listed as pending confirmation since
  every `simulated` entry is arbitration-list material regardless of assumption vs open (rule 3).

## Step 7 — Knowledge capture

`.qaia/knowledge/` does not exist in this project (degraded mode, rule 8) — there is no
`rag-build` target to offer a rule to. If the knowledge base is initialized later, Q1's eventual
answer (renal-insufficiency reduction scope) and Q4's eventual answer (24h window semantics) are
the two strongest candidates for promotion to a reusable `BR-KB-nnn` business rule, since both are
project-wide dosing-safety policies likely to recur across other drug/prescription US's, not
one-off facts local to US-002.

## Step 8 — Checkpoint

This file (`02-understanding.md`) is the checkpoint for this step. `journey.md` updated
accordingly (see below). Next step: `istqb-design`.
