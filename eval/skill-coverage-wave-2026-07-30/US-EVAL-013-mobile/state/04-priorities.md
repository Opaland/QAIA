---
stepsCompleted: [00-ingest]
lastStep: 04-priorities
lastSaved: 2026-07-31
arbitration: PROPOSED BUT NOT ARBITRATED (no human in this session)
---

# 04-priorities — US-EVAL-013

> ## ⚠ Status: **proposed but not arbitrated**
>
> `prioritize` SKILL.md line 18: *"In a non-interactive context with no user available, do NOT treat
> auto-acceptance as arbitration — output the scores explicitly as `proposed but not arbitrated`,
> with a disclaimer that they are unsuitable for a production Go/No-Go until a human reviews them."*
>
> No human was available. **These scores are unsuitable for a production Go/No-Go.** Zero overrides
> were recorded because zero arbitration happened — not because the proposal was accepted.
> Everything downstream (`testbook-generate`'s P1+P2 scope) inherits this provenance, and the whole
> table below is on the synthesis's arbitration list.

## Signals used

- **Knowledge base**: absent (`.qaia/knowledge/` does not exist) — no criticality notes, no anomaly
  history to cite. Impact calls below rest on the observed behaviour alone.
- **git-history signal**: **not used, and its absence is not evidence of low risk.** SKILL.md
  line 15 gates it on "the user has explicitly named a target repo path for this session"; none was
  named, and SauceDemo's front-end source is not in this repo. Silently skipped per the same line,
  and stated here per the guardrail's "Absence of history data is not evidence of low risk either".
- **Regulated-context default (guardrail, D2)**: **not applied** — this evaluation target is a
  public e-commerce demo, not the project's medical niche. Said explicitly rather than assumed:
  had it applied, every traceability-relevant condition would default to impact 3, which would have
  moved several P2s.

## Proposed scores

Impact 1-3 × Probability 1-3 → **P1 ≥ 6 · P2 3-4 · P3 ≤ 2**.

| Condition | I | P | Prio | One-line risk rationale (this text is copied into the coverage matrix) | Flags |
|---|---|---|---|---|---|
| **AC1-C3** (479 px) | 2 | 3 | **P1** | Boundary−1 of the only navigation-mode switch in the product; the inclusivity it proves is an `[assumption]`, so the edge is untested truth, not verified truth | `[assumption]` Q1 |
| **AC1-C4** (480 px) | 2 | 3 | **P1** | The boundary itself — the single condition that decides Q1's inclusivity; get it wrong and two ACs invert | `[assumption]` Q1 |
| **AC2-C1** (481 px) | 2 | 3 | **P1** | Boundary+1, the other face of the same untested edge; CSS breakpoints are exactly where off-by-one regressions land | `[assumption]` Q1 |
| **AC3-C1** (phone + drawer open ⇒ catalogue blocked) | 3 | 2 | **P1** | On a phone the drawer is the whole screen: a tap leaking through it changes cart state on a screen the shopper cannot see — an unintended state change with no visible feedback | **`[req-neg]`** |
| **AC4-C1** (Closed → Open) | 3 | 2 | **P1** | A 20 × 20 px burger is the *only* gateway to every navigation action on a phone; if it fails to open, the session is stranded with no fallback control anywhere on the page | — |
| **AC4-C2** (Open → Closed) | 3 | 2 | **P1** | Symmetric single point of failure: no scrim, no tap-outside dismiss (`[assumption]` Q4), so a drawer that will not close locks the shopper out of the catalogue | `[assumption]` Q4 |
| **AC4-C3** (re-entrance ×2) | 3 | 2 | **P1** | Toggle state machines degrade on repetition, not on first use; the first-cycle tests would pass while a real session breaks on the third tap | — |
| **AC5-C2** (post-logout `/inventory.html` refused) | 3 | 2 | **P1** | Session **revocation** enforcement — the classic place auth breaks (the token/route check that still honours a dead session) | **`[req-neg]`** |
| **AC5-C3** (never-logged-in `/inventory.html` refused) | 3 | 2 | **P1** | Unauthenticated access to a guarded route; distinct code path from revocation and just as consequential | **`[req-neg]`** |
| **AC5-C4** (`/cart.html`, `/checkout-step-one.html` refused) | 3 | 2 | **P1** | UI-bypass across *every* guarded route, not just the one the US names — the enumeration reflex is what catches the route someone forgot to guard | **`[req-neg]`** |
| **AC7-C3** (burger 20 px vs WCAG 24 px) | 3 | 3 | **P1** | Accessibility exposure on the sole navigation control of the mobile experience; probability is 3 because the gap is *already measured*, not hypothetical | `[open]` Q3, `@oracle:wcag-2.2-2.5.8` |
| **AC1-C1** (320 px) | 2 | 2 | **P2** | Mid-partition representative at the narrowest realistic phone; lower probability than the edges but the class still rests on an `[assumption]` | `[assumption]` Q1 |
| **AC1-C2** (390 px, `iPhone 13` viewport) | 2 | 2 | **P2** | The width most real shoppers see; representative rather than boundary, so probability is moderate | `[assumption]` Q1 |
| **AC3-C2** (phone + drawer closed ⇒ add to cart works) | 3 | 1 | **P2** | Impact is the whole purchase path on a phone, but this is the core, stable, most-exercised behaviour — low probability, high consequence | control cell for AC3-C1 |
| **AC4-C4** (drawer is the only Logout route) | 3 | 1 | **P2** | High consequence (no fallback sign-out on a phone) but it is a structural DOM fact, unlikely to drift | — |
| **AC5-C1** (Logout returns to the login page) | 3 | 1 | **P2** | Session termination itself; consequential but the simplest and best-trodden path of the three auth conditions | — |
| **AC6-C1** (899 px ⇒ 40 px stub) | 1 | 3 | **P2** | Probability 3 because Q2 is `[open]` — nobody has said whether the 40 px stub is intended, so the expected result itself is contested; impact stays 1 (a readability degradation, not a blocked action) | `[open]` Q2 |
| **AC6-C2** (900 px ⇒ 223 px) | 1 | 3 | **P2** | Same contested-expectation driver at the other side of the edge | `[open]` Q2 |
| **AC6-C3** (sort survives a drawer cycle) | 2 | 2 | **P2** | State loss on a phone means redoing the selection through a 40 px stub — annoying, not blocking; derived by reflex, so less certain than the ACs | derived (3c) |
| **AC2-C2** (640 px) | 2 | 1 | **P3** | Deep inside the wide partition, far from any edge; adds a data point, not a risk | — |
| **AC2-C3** (1280 px) | 2 | 1 | **P3** | Desktop representative; the value is already pinned by AC2-C1 at the edge | — |
| **AC3-C3** (wide + drawer open ⇒ catalogue reachable) | 1 | 2 | **P3** | Desktop modality question, not a mobile one, and the neighbouring 481 px case is `[open]` (Q8) anyway | `[open]` Q8 adjacent |
| **AC3-C4** (wide + drawer closed) | 1 | 1 | **P3** | The trivial cell of the decision table — present for table completeness, near-zero information | — |
| **AC4-C5** (drawer item list = 4 links) | 2 | 1 | **P3** | An inventory of the menu; useful as a regression tripwire, but nothing in the US depends on the count | derived (3c) |
| **AC7-C1** (burger 20 × 20 at every width) | 2 | 1 | **P3** | The invariance itself is measured and stable; the *consequence* of that invariance is what matters, and it is carried by AC7-C3 at P1 | — |
| **AC7-C2** (cart 40 × 40 at every width) | 1 | 1 | **P3** | 40 px already exceeds the 24 px minimum — measuring its invariance is documentation, not risk | — |

**Distribution**: P1 = 11 · P2 = 8 · P3 = 7 (26 conditions).
**All 4 `[req-neg]` conditions land in P1** (AC3-C1, AC5-C2, AC5-C3, AC5-C4) — no `[req-neg]` is
deferred, so `testbook-generate`'s step-5 priority-scoped waiver clause is not needed on this run.

## Assignments a human must arbitrate first (the whole table, plus these specifically)

1. **AC7-C3 at P1** — I scored an accessibility gap as the joint-highest risk of the story on a
   `[open]` question (Q3: is 20 × 20 px accepted?). A product owner may legitimately rule the
   opposite. This is the single most contestable call in the table.
2. **AC6-C1/C2 probability 3** — driven entirely by Q2 being `[open]`. If a human answers "the
   40 px stub is intended", probability drops to 1 and both fall to P3.
3. **AC3-C1 impact 3** — I treated a phantom tap through the drawer as an unintended state change.
   Someone may score an accidental cart addition as impact 2 (annoying, reversible).
4. **The Q1 cluster (AC1-C3/C4, AC2-C1) at probability 3** — probability is high *because* the
   inclusivity is an assumption. A human confirming Q1 would legitimately drop all three to P2.

## Scope handed to `testbook-generate`

P1 + P2 (19 conditions) generated in full; **P3 (7 conditions) not generated** — the default
quota trade-off (Q22). Every P3 condition still appears in the coverage matrix with the reason
`deferred, P3, not requested`, so none vanishes from the count.

## ⚠ VALIDATION (step 3)

`pending-validation` — no user available. **0 overrides recorded, because no arbitration occurred.**

## Skill finding — `prioritize` (raised, not fixed)

- **SKILL.md line 13**: *"**Impact** (1-3): consequence if this behavior fails in production —
  safety/regulatory/data-loss = 3, degraded service = 2, cosmetic = 1."*
- **Friction met on this run**: a responsive/presentation defect does not sit anywhere on that
  scale. Is a navigation drawer that renders at 300 px instead of full-screen on a phone
  "cosmetic" (it looks different) or "degraded service" (the shopper's only navigation surface
  behaves as a different mode)? I chose 2 and justified it per condition, but the scale offers no
  anchor — and the same ambiguity pushed AC6's sort stub to impact 1 while AC3's blocked tap got 3,
  on judgement alone.
- More sharply: **an accessibility threshold breach (AC7-C3) has no home on this scale at all.**
  It is not safety, not data-loss, and in several jurisdictions it is closer to *regulatory* than
  to *cosmetic*. I scored it 3 by reading "regulatory" broadly; a different executor reading the
  same line literally would score it 1, and the story's P1 set would differ by its most contested
  item. That is a reproducibility gap in the skill, not in the executor.
- **Proposed diff (NOT applied)** — on line 13, extend the impact anchors:
  `` - **Impact** (1-3): consequence if this behavior fails in production — safety/regulatory/data-loss/**accessibility-conformance breach** = 3, degraded service **(including a navigation or input surface that behaves in the wrong mode for the user's device class)** = 2, cosmetic = 1. ``
- Not applied; left for arbitration.
