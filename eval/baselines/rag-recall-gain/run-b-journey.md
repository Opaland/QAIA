---
stepsCompleted: [00-ingest, 01-review, 02-understanding, 03-design]
lastStep: 03-design
lastSaved: 2026-07-25
mode: non-interactive (simulated defaults, shared-contract rule 3)
knowledgeBase: present — knowledge/index.md + knowledge/business-rules.md (BR-KB-201..205)
---

# Run B journey — FIT-118, WITH the knowledge base

Same source (`us.md`), same extraction as Run A (`01-extraction` is identical — the ticket
didn't change). What changes is `need-understanding` step 8 and `istqb-design` step 3d: both
now route through `knowledge/index.md`, match on entities `booking, credit, class,
cancellation, waitlist, membership, tier, no-show, peak`, and open `business-rules.md`.

## 02-understanding — delta from Run A

Knowledge base check: **present**. Re-running the ambiguity hunt with retrieval:

| Q | Run A status | Run B status | Resolved by |
|---|---|---|---|
| Q1 (credit cost) | `[out-of-slice]` | **answered** | `BR-KB-201` (standard=1, peak=2), `BR-KB-203` (tier allowances) |
| Q2 (cancellation cutoff) | `[out-of-slice]` | **answered** | `BR-KB-202` (4h cutoff, 1-credit late fee) |
| Q3 (no-show consequence) | `[out-of-slice]` | **answered** | `BR-KB-202` (2-credit forfeiture), `BR-KB-205` (3-strikes restriction) |
| Q4 (waitlist promotion mechanism) | `[out-of-slice]` | **answered** | `BR-KB-204` (2h auto-promote cutoff, 15-min manual offer window) |
| Q5 (FIFO waitlist) | `[assumption]` | **confirmed as project rule** (no longer a guess) | `BR-KB-204` ("earliest-joined") |
| Q6 (auth required) | `[assumption]` | `[assumption]` — unchanged | not covered by the knowledge base |
| Q7 (overlapping bookings) | `[assumption]` | `[assumption]` — unchanged | not covered by the knowledge base |
| Q8 (leave waitlist) | `[assumption]` | `[assumption]` — unchanged | not covered by the knowledge base |

**4 of 8 questions move from a deferred/guessed status to a cited, human-decided project rule.**
Q6-Q8 show the honest limit of this experiment's knowledge base: RAG closes what it was written
to cover, not everything — it is not a general substitute for a fuller US.

## 03-design — conditions added or sharpened by step 3d

Same 16 base conditions as Run A (AC1-C1..C8, AC2-C1..C4, AC3-C1..C4) — knowledge retrieval
does not remove or contradict anything the AC-alone pass already found. Added on top:

| ID | Condition | Technique | Rule | Kind |
|---|---|---|---|---|
| AC1-C9 | Booking a standard-hour class deducts exactly 1 credit | EP | `BR-KB-201` | positive |
| AC1-C10 | Booking a peak-hour class (weekday 18:00-20:00) deducts exactly 2 credits | EP | `BR-KB-201` | positive |
| AC1-C11 | A Basic-tier member with 0 remaining monthly credits cannot book (tier cap reached) | decision-table | `BR-KB-203` | `[req-neg]` — sharpens AC1-C4 into a concrete, testable case |
| AC1-C12 | A Premium-tier member's unused credits roll over up to a cap of 10; the 11th rolled-over credit is forfeited | boundary | `BR-KB-203` | positive/boundary (10 vs. 11) |
| AC1-C13 | An Unlimited-tier member's 2nd active booking attempt on the same day is rejected | decision-table | `BR-KB-203` | `[req-neg]` |
| AC1-C14 | A member under an active no-show booking restriction cannot book a new class | decision-table | `BR-KB-205` | `[req-neg]` |
| AC2-C5 | Cancelling exactly 4 hours (or more) before class start is free | boundary | `BR-KB-202` | positive |
| AC2-C6 | Cancelling less than 4 hours before class start forfeits 1 credit | boundary | `BR-KB-202` | positive/penalty (not a refusal — cancellation still succeeds) |
| AC2-C7 | A no-show forfeits 2 credits | state-transition | `BR-KB-202` | positive/penalty |
| AC2-C8 | A 3rd no-show within a rolling 30-day window triggers a 7-day booking restriction and a warning | state-transition | `BR-KB-205` | positive (trigger event; the resulting refusal is AC1-C14) |
| AC3-C5 | A spot freeing >=2h before class start auto-promotes the earliest-joined waitlisted member | state-transition | `BR-KB-204` | positive |
| AC3-C6 | A spot freeing <2h before class start offers the spot to the earliest-joined member with a 15-minute confirmation window | state-transition + boundary | `BR-KB-204` | positive |
| AC3-C8 | An unconfirmed offer, once the 15-minute window expires, passes to the next-earliest-joined waitlisted member | state-transition | `BR-KB-204` | positive (not `[req-neg]` — no request was refused, this is a passive timeout cascade, D20 closed definition) |
| AC3-C7 | Waitlist promotion order follows FIFO by join time (confirms Q5, previously an assumption) | EP | `BR-KB-204` | positive — **confirmation, not counted as new recall** (Run A already generated the equivalent behavior under `[assumption]`) |

**13 net-new conditions** (AC1-C9..C14 = 6, AC2-C5..C8 = 4, AC3-C5/C6/C8 = 3),
plus 1 assumption-to-fact confirmation (AC3-C7) tracked separately so the headline number isn't
inflated by re-stating something Run A already covered.

`knowledgeApplied`: `[BR-KB-201, BR-KB-202, BR-KB-203, BR-KB-204, BR-KB-205]` — all five rules
in the base were matched and applied; none contradicted the source (no question raised back to
`need-understanding`).

### Gap closure — mapped to Run A's flagged gaps

| Gap (Run A) | Closed by | Conditions |
|---|---|---|
| GAP-A1 (credit cost) | `BR-KB-201`, `BR-KB-203` | AC1-C9, C10, C11, C12, C13 (5) |
| GAP-A2 (cancellation cutoff) | `BR-KB-202` | AC2-C5, C6 (2) |
| GAP-A3 (no-show consequence) | `BR-KB-202`, `BR-KB-205` | AC2-C7, C8, AC1-C14 (3) |
| GAP-A4 (waitlist promotion mechanism) | `BR-KB-204` | AC3-C5, C6, C8 (3) |

All four of Run A's honestly-flagged config-driven gaps are closed (5+2+3+3 = 13 conditions),
each citing its rule ID — none of the numbers (1/2 credits, 4h, 8/20/10, 3-in-30-days/7-day,
2h/15min) were invented; every one is copy-traceable to `knowledge/business-rules.md`.

### What is still NOT closed (honesty check — RAG is not a cure-all)

- **GAP-B1** — what happens to a member's unused credits if they downgrade or cancel their
  membership mid-cycle. Not covered by `business-rules.md`; stays `[out-of-slice]`, same status
  as in Run A. Flagged, not invented.
- Q6-Q8 (auth requirement, overlapping bookings, leaving the waitlist) remain `[assumption]` —
  the knowledge base happens not to cover them; they are not contradicted, just absent.
- **GAP-B2 (found by independent judge review, not by this generation pass itself)** — even
  with `BR-KB-203` matched and cited, this run only realized 3 of its 7 distinct sub-clauses
  (the rollover-cap boundary and the Unlimited daily cap) — it never asserted Basic's base
  8-credit monthly grant, Basic's "no rollover" property, Premium's base 20-credit grant, or
  Unlimited's "uncapped credits" property. A rule that bundles several tier facts in one
  paragraph does not automatically yield one condition per fact — step 3d derived the
  boundary-worthy sub-clauses but skipped the flatter baseline ones. See
  `../rag-recall-gain.md` "Défaut trouvé" for the write-up; flagged here for traceability, not
  patched retroactively (patching after the judge caught it would understate the finding).
