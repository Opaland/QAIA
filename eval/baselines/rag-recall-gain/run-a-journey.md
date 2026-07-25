---
stepsCompleted: [00-ingest, 01-review, 02-understanding, 03-design]
lastStep: 03-design
lastSaved: 2026-07-25
mode: non-interactive (simulated defaults, shared-contract rule 3)
knowledgeBase: absent (Run A — no `knowledge/` provided)
---

# Run A journey — FIT-118, no knowledge base

Executed skills: `us-ingest` → `us-review` (extraction, folded into ingestion for this
experiment) → `need-understanding` (ambiguity hunt, required because it is `istqb-design`'s
prerequisite) → `istqb-design`. `prioritize` was run minimally (P1/P2/P3 tags only, not a full
risk narrative) purely to satisfy `testbook-generate`'s prerequisite — it is not the object of
this experiment.

## 01-extraction (us-review)

**Story**: As a studio member, I want to book a spot in a fitness class and manage my booking,
so that I know if I'm attending and don't lose a spot I don't need.

**Acceptance criteria** (none were numbered in the source — derived from the narrative):
- **AC1** — A member can book an available class from the schedule; a successful booking
  confirms the spot and deducts membership credits.
- **AC2** — A member can cancel an existing booking before the class; cancelling frees the spot
  for another member.
- **AC3** — If a class is full, a member can join a waitlist instead of booking directly.

**Business rules found outside the AC list**: "booking uses membership credits" (mechanism/
amount not stated). "Login and membership management already exist" — out of scope for this
ticket (dependency).

**Not found / not classifiable**: no numeric thresholds anywhere, no mention of no-shows, no
mention of membership tiers, no mention of peak pricing.

**dependencies** (sibling-story terms, us-ingest guardrail): "membership" and "credits" are
defined elsewhere (a membership/tier ticket not ingested here) — out-of-slice.

## 02-understanding (need-understanding)

**Reformulation**: A studio member needs to reserve a spot in a scheduled class through a
booking flow, and release that spot by cancelling, so the studio's limited capacity goes to
members who will attend; when a class is full the member can queue on a waitlist instead of
being turned away outright. Main risk if this misbehaves: members lose credits for classes they
never attended, or a class gets overbooked past its real capacity, eroding trust in the system.

Knowledge base check: **absent** — proceeding on the source alone (shared-contract rule 8).

**Ambiguity log**:

| Q | Question | Classification | Note |
|---|---|---|---|
| Q1 | How many credits does booking a class cost — does it vary by class type/time? | `[out-of-slice]` | Plausibly answered in a membership/pricing ticket not ingested here; money-policy, not a safe-default case |
| Q2 | Is there a cutoff before class start after which cancelling is blocked or penalized? | `[out-of-slice]` | Money-policy (penalty), not mechanically forced |
| Q3 | Does a no-show have any consequence (credit loss, tracking)? | `[out-of-slice]` | Same reasoning as Q2 |
| Q4 | When a spot frees up, how/when is the waitlist promoted — automatic, manual, any cutoff near class start? | `[out-of-slice]` | Config-driven mechanism, not stated |
| Q5 | Is the waitlist strictly FIFO, or can staff reorder it? | `[assumption]` | Safe, low-risk default: FIFO by join time |
| Q6 | Is booking restricted to signed-in members (vs. anonymous/drop-in)? | `[assumption]` | The story says "studio member" throughout; default-deny for unauthenticated access, low-confidence since not stated as an explicit rule |
| Q7 | Can a member hold two overlapping bookings at the same time? | `[assumption]` | Default-deny (prevent double-booking the same slot) — safe, non-controversial |
| Q8 | Can a member leave (cancel) a waitlist spot the same way as a confirmed booking? | `[assumption]` | Safe default: yes, symmetric with AC2 |

Q1-Q4 are exactly the class of question `need-understanding` cannot resolve from the source and
that a knowledge base would answer — this is the target of the experiment.

## 03-design (istqb-design)

Technique map: AC1 → equivalence partitioning + decision table (capacity states) + reflex
auth/uniqueness checks. AC2 → equivalence partitioning + state transition (booking lifecycle).
AC3 → state transition (waitlist membership) + decision table (full/not-full guard).

### Derived conditions (steps 1-3c, no knowledge base)

| ID | Condition | Technique | Kind |
|---|---|---|---|
| AC1-C1 | Booking an available class (spots remaining > 0) confirms the booking | EP | positive |
| AC1-C2 | Booking a class deducts membership credits from the member's balance (amount unspecified) | EP | positive |
| AC1-C3 | Booking a class with zero remaining spots is not offered directly (routes to waitlist, AC3) | decision-table | `[req-neg]` |
| AC1-C4 | Booking with an insufficient credit balance is rejected | EP | `[req-neg]` |
| AC1-C5 | Unauthenticated access to booking is denied | error-guessing | `[req-neg]`, `[assumption]` (Q6) |
| AC1-C6 | Booking the same class slot twice by the same member is rejected (duplicate) | error-guessing | `[req-neg]` |
| AC1-C7 | Class schedule list can be filtered/sorted (date, time, instructor) | EP | positive |
| AC1-C8 | Empty schedule (no classes available) shows an empty state, not an error | EP | positive |
| AC2-C1 | Cancelling a booking before the class removes it and frees the spot | EP | positive |
| AC2-C2 | Cancelling another member's booking is rejected (IDOR) | error-guessing | `[req-neg]` |
| AC2-C3 | Cancelling an already-cancelled booking is rejected / safe no-op | state-transition | `[req-neg]` |
| AC2-C4 | Cancelling a booking after the class has already occurred is rejected (terminal state) | state-transition | `[req-neg]` |
| AC3-C1 | Joining the waitlist of a full class succeeds and records a position | state-transition | positive |
| AC3-C2 | Joining the waitlist of a class that is not full is rejected/redirected to direct booking | decision-table | `[req-neg]` |
| AC3-C3 | Leaving a waitlist spot succeeds | state-transition | `[assumption]` (Q8) |
| AC3-C4 | Joining the same class's waitlist twice by the same member is rejected | error-guessing | `[req-neg]` |

**16 conditions**, of which **9** are `[req-neg]`.

### Ceiling — flagged gaps, not invented (step 3c ceiling clause / D38)

| Gap | Why it cannot be answered from the source | Cites |
|---|---|---|
| GAP-A1 | Exact credit cost per class, and whether it varies by time slot or membership tier | Q1 |
| GAP-A2 | Cancellation cutoff window before class start (free vs. blocked/penalized) | Q2 |
| GAP-A3 | Consequence of a no-show (credit forfeiture, repeated-offense tracking) | Q3 |
| GAP-A4 | Waitlist promotion mechanism and timing near class start (auto vs. manual, cutoff) | Q4 |

`knowledgeApplied`: **[]** (knowledge base absent — recorded per shared-contract rule 8, not
fabricated).

These four gaps are surfaced to the user/manifest instead of guessed. This is the honest-recall
ceiling D38 describes, reproduced on a fresh domain.
