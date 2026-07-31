---
stepsCompleted: [00-ingest]
lastStep: 03-design
lastSaved: 2026-07-31
upstreamStatus: extraction unconfirmed (01-review pending-validation); 02-understanding pending-validation
---

# 03-design — US-EVAL-013 (technique selection, justified)

Scope reminder read before selecting anything: **black-box only (D110)** — no structure-based
technique. One white-box tension is already disclosed upstream (`01-extraction.md`, "Referenced
artifacts not analyzed": the page's `@media` condition texts were read once during exploration to
choose which widths to bisect). **Every boundary below was nevertheless re-derived empirically**
(479/480/481 and 899/900/901 measured directly, re-run and reproduced byte-identically on
2026-07-31 — see `## Re-verification` at the bottom), so no condition depends on that peek.

Upstream artifacts are `unconfirmed` / `pending-validation` (no human in this session). Every
condition below inherits that provenance.

---

## 1. AC → technique map (with justification)

| AC | Shape of the AC | Technique(s) selected | Justification |
|---|---|---|---|
| **AC1** | a width threshold with a class below it (≤ 480 → full-screen drawer) | **Equivalence partitioning** + **Boundary value analysis** | Two viewport-width classes treated identically inside each class (EP), separated by one exact threshold whose inclusivity is the whole question (BVA on 479/480/481 — Q1's inclusivity answer is `[assumption]`, so the boundary must be tested, not inferred) |
| **AC2** | the complementary class (≥ 481 → fixed 300 px) | **Equivalence partitioning** + **Boundary value analysis** | Same threshold seen from the other side; the 300 px value is invariant across the whole upper partition (481 / 640 / 1280 measured), which is an EP claim, not a per-width claim |
| **AC3** | a combination of two conditions (viewport class × drawer state) producing an interaction outcome | **Decision Table Testing (CTAL-TA §3.3.1)** | The outcome ("is the catalogue reachable") depends on *two* independent conditions, not one threshold — exactly the shape §3.3.1 names. The table forces the control cells (drawer *closed*) that prove the blockage is caused by the drawer, not by the phone viewport |
| **AC4** | a lifecycle with declared states and events (closed ↔ open) | **State Transition Testing (CTAL-TA §3.2.2)** | Explicit state × event table built first (below), then conditions derived from the completed table — never transition pairs picked from prose (CT-MBT discipline, D95) |
| **AC5** | an authorisation rule that refuses, plus the shape of the refusal | **State Transition Testing (§3.2.2)** for the revoke transition + **Error guessing / checklist (§3.4.2 sibling)** for the direct-URL paths | Logout is a state transition (authenticated → anonymous); "what happens if I just type the guarded URL" is the classic checklist item, anchored on the ambiguity log (Q9) rather than invented |
| **AC6** | a second, independent width threshold (899/900) | **Boundary value analysis** | A pure threshold on one variable. **Deliberately NOT Domain Testing (§3.1.1)**: the two thresholds of this US (480 and 900) were measured to be *independent* — at 480 px both the full-screen drawer and the 40 px sort stub hold, with no combined behaviour — so there is no worst-case/best-case combination to cover, and forcing §3.1.1 here would be technique theatre |
| **AC7** | an invariance claim across every partition | **Equivalence partitioning** (invariance form) + **oracle** (see 3b) | The claim is "the same value in every class", which is EP used to *falsify* a partition boundary rather than to find one: it is disproved by a single class where the value differs |

**Techniques of the palette deliberately NOT selected**, named rather than silently omitted:
Domain Testing (§3.1.1 — see AC6's justification), Combinatorial/pairwise (§3.1.2 — the only two
axes here are viewport width and drawer state, 2 axes × small domains, fully enumerable in the
AC3 decision table; pairwise exists to tame an explosion that does not occur), Scenario-Based
Testing (§3.2.3 — one `@smoke` journey is generated, see AC-J below), CRUD (§3.2.1 — no entity
lifecycle in this slice), Metamorphic (§3.3.2 — every expected value here is directly measurable,
so the "cannot state the output directly" trigger never fires), AI/ML feature (CT-AI — the SUT has
no AI feature).

**AC-J (journey, §3.2.3, at most one per US)**: open the catalogue on a phone descriptor → open the
drawer → sign out → confirm the guarded route is refused. Single journey-level `Then`, tagged
`@smoke`, excluded from atomicity accounting.

---

## 2. State × event table for AC4 (built first, per D95 — conditions derived from it, not from prose)

Observed states of `.bm-menu-wrap`: `Closed` (`aria-hidden="true"`), `Open` (`aria-hidden="false"`).
Events available to a shopper on a phone viewport: `tapBurger` (`#react-burger-menu-btn`),
`tapCross` (`#react-burger-cross-btn`), `tapLogout` (`#logout_sidebar_link`), `tapReset`.

| state \ event | `tapBurger` | `tapCross` | `tapLogout` | `tapReset` |
|---|---|---|---|---|
| **Closed** | → **Open** (measured) | **not a legitimate user event** — the cross control is off-canvas with the drawer; note the automation trap in `00-source.md` (Playwright reports it "visible" anyway) | **not a legitimate user event** — same off-canvas situation; the link is unreachable to a real finger although it has a box | idem |
| **Open** | **not reachable** — the burger sits under the full-screen drawer at ≤ 480 px | → **Closed** (measured) | → **page exit**: navigates to the login page; the drawer's state afterwards is not separately observable (`02-understanding.md`, AC4 × AC5 `[assumption]`) | out-of-slice (`Reset App State` is a separate US — a destructive action, not a navigation one) |

**Forbidden transitions**: none *declared* by the source. The four "not a legitimate user event"
cells above are **physical unreachability observed in the rendering**, not a declared prohibition —
they are therefore **not** turned into `[req-neg]` "must refuse" conditions (that would be inventing
a rule the source never states). They are recorded here because the state table demands every cell
be marked, and because one of them is the origin of the `isVisible()` automation trap.

---

## 3. Derived test conditions

Legend: `[req-neg]` = required-negative (a refusal/denial/error path — the ADR 0001 checklist);
`[assumption]` / `[open]` inherited from `02-understanding.md`; `@oracle:<std>` per 3b.

### AC1 — ≤ 480 px ⇒ drawer covers 100 % of the viewport (EP + BVA)

| ID | Condition | Expected (measured) | Flags |
|---|---|---|---|
| **AC1-C1** | viewport 320 × 844, drawer opened — lower representative of the phone partition | `.bm-menu-wrap` width = 320 px = 100 % of viewport | `[assumption]` Q1 |
| **AC1-C2** | viewport 390 × 664 (the `iPhone 13` descriptor's own viewport) | width = 390 px = 100 % | `[assumption]` Q1 |
| **AC1-C3** | viewport 479 (boundary − 1) | width = 479 px = 100 % | `[assumption]` Q1 |
| **AC1-C4** | viewport 480 (the boundary itself, claimed inclusive on the phone side) | width = 480 px = 100 % | `[assumption]` Q1 — **the condition that decides Q1's inclusivity** |

### AC2 — ≥ 481 px ⇒ drawer is a fixed 300 px (EP + BVA)

| ID | Condition | Expected (measured) | Flags |
|---|---|---|---|
| **AC2-C1** | viewport 481 (boundary + 1) | width = 300 px (62 % of viewport) | `[assumption]` Q1 |
| **AC2-C2** | viewport 640 | width = 300 px (47 %) | — |
| **AC2-C3** | viewport 1280 (desktop representative of the upper partition) | width = 300 px (23 %) | — |

### AC3 — catalogue reachability while the drawer is open (Decision Table §3.3.1)

Conditions: `viewport class` ∈ {phone ≤ 480, wide ≥ 481} × `drawer` ∈ {open, closed} → action:
`is the catalogue interactive at the first card's centre?`

| ID | viewport | drawer | Expected (measured) | Flags |
|---|---|---|---|---|
| **AC3-C1** | phone (390/412) | open | topmost element at the card centre is `NAV.bm-item-list` (inside the drawer); a tap there adds nothing — cart badge count stays **0** | **`[req-neg]`** (a denied interaction) |
| **AC3-C2** | phone (390/412) | closed | topmost is the card; the "Add to cart" button works — cart badge reads **"1"** | control cell — proves C1 is caused by the drawer, not by the narrow viewport |
| **AC3-C3** | wide (1280) | open | topmost at the card centre is `DIV.inventory_item_desc` — **not** inside the drawer | — |
| **AC3-C4** | wide (1280) | closed | catalogue interactive (the trivial cell, completing the table) | P3 candidate — kept for table completeness, not for its information value |

**Not scenarised — `[open]` Q8**: whether the catalogue is *meant* to be interactive at 481 px with
the drawer open. My own measurement is inconclusive at exactly that width (the first card's centre
falls under the 300 px panel there), so the table above uses 1280 for the "wide" class and the 481
cell stays an open arbitration rather than a guessed row.

### AC4 — drawer lifecycle and route uniqueness (State Transition §3.2.2, from the table in §2)

| ID | Condition | Expected (measured) | Flags |
|---|---|---|---|
| **AC4-C1** | `Closed --tapBurger--> Open` on a phone descriptor | `aria-hidden` flips `"true"` → `"false"` | — |
| **AC4-C2** | `Open --tapCross--> Closed` on a phone descriptor | `aria-hidden` flips `"false"` → `"true"` | — |
| **AC4-C3** | re-entrance: `Closed → Open → Closed → Open` (2 full cycles) | final `aria-hidden` = `"false"`, no stuck/degraded state | — |
| **AC4-C4** | on a phone descriptor, count the elements in the whole DOM whose text matches `/logout\|sign out/i` | exactly **1**, `#logout_sidebar_link`, inside `.bm-menu-wrap` — i.e. the drawer is the only route | — |
| **AC4-C5** | the drawer's own item list at a phone viewport (3c "enumerate EVERY list" reflex — the drawer *is* a second collection view besides the catalogue) | exactly 4 links, in order: `All Items`, `About`, `Logout`, `Reset App State` (`inventory-sidebar-link`, `about-sidebar-link`, `logout-sidebar-link`, `reset-sidebar-link`) | measured 2026-07-31 (`probe-recall.js`) — not `[assumption]` |

### AC5 — logout and guarded-route refusal (State Transition + Error guessing §3.4.2)

| ID | Condition | Expected (measured) | Flags |
|---|---|---|---|
| **AC5-C1** | `Open --tapLogout-->` on a phone descriptor | URL becomes `https://www.saucedemo.com/` (the login page) | — |
| **AC5-C2** | after that logout, request `/inventory.html` directly | URL stays on the login page; `[data-test="error"]` = `Epic sadface: You can only access '/inventory.html' when you are logged in.` | **`[req-neg]`** |
| **AC5-C3** | 3c **authorization reflex — unauthenticated access**: a *fresh* context that never logged in requests `/inventory.html` | identical refusal, verbatim | **`[req-neg]`** |
| **AC5-C4** | 3c **UI-bypass + enumerate-every-guarded-route**: fresh context requests `/cart.html`, then `/checkout-step-one.html` | refusal naming each path verbatim (`'/cart.html'`, `'/checkout-step-one.html'`) — **measured, not extrapolated from the `/inventory.html` template** | **`[req-neg]`** |

### AC6 — sort-control footprint (BVA)

| ID | Condition | Expected (measured) | Flags |
|---|---|---|---|
| **AC6-C1** | viewport 899 (boundary − 1) | `[data-test="product-sort-container"]` width = 40 px | — |
| **AC6-C2** | viewport 900 (the boundary) | width = 223 px | — |
| **AC6-C3** | 3c **list-view state-persistence reflex**: choose a sort option at a phone viewport, open the drawer, close it | the selection survives (`za` before → `za` after) — measured | — |

### AC7 — touch-target invariance (EP invariance form + oracle)

| ID | Condition | Expected (measured) | Flags |
|---|---|---|---|
| **AC7-C1** | burger `#react-burger-menu-btn` measured at a phone width (390) **and** a desktop width (1280) | 20 × 20 CSS px in both — no viewport-adaptive enlargement | — |
| **AC7-C2** | cart `[data-test="shopping-cart-link"]` measured at 390 and 1280 | 40 × 40 CSS px in both | — |
| **AC7-C3** | the burger's 20 × 20 CSS px against the published minimum target size | 20 < **24 × 24 CSS px**, the WCAG 2.2 SC 2.5.8 *Target Size (Minimum)* threshold (AA) — SC 2.5.5 *Enhanced* (AAA) sets 44 × 44 | `@oracle:wcag-2.2-2.5.8`, **`[open]` Q3** — the scenario records the measured gap against the published threshold; it does **not** assert that conformance is required here, because whether SauceDemo claims WCAG 2.2 AA is unsourced |

**Total: 26 conditions** — AC1: 4, AC2: 3, AC3: 4, AC4: 5, AC5: 4, AC6: 3, AC7: 3.
`[req-neg]` set: **AC3-C1, AC5-C2, AC5-C3, AC5-C4** (4 conditions).

---

## 4. Sub-step ledger (each of 3b/3c/3d recorded with its outcome — never silently absent)

### 3b — standardized domains → oracle: **partially applied**

- **Applied**: AC7-C3 cites **WCAG 2.2 SC 2.5.8** (Target Size Minimum, 24 × 24 CSS px) as the
  oracle for the touch-target threshold, tagged `@oracle:wcag-2.2-2.5.8`. This is a *published,
  citable* threshold, which is exactly what 3b exists to prevent guessing.
- **Honest limitation stated rather than glossed**: `oracle-generate`'s own scope list is
  "card/Luhn, dates/ISO 8601, HTTP status, email/RFC 5322, currency/ISO 4217, IBAN…" — all
  *data-format* standards. **A11y/target-size standards are not in that list**, and the skill was
  not literally invoked (no `.qaia/knowledge/` and no oracle corpus for WCAG exists in this repo).
  The citation above is mine, from the standard's own published text, and is flagged `[open]` (Q3)
  precisely because I will not turn an uninvoked oracle into an asserted conformance verdict.
  Recorded as a **product gap**, see `## Skill findings`.
- **Not applied elsewhere**: no AC in this US touches a data-format standard. CSS px vs device px
  is a unit question (handled in `02-understanding.md`'s adversarial pass), not an oracle question.

### 3c — systematic coverage expansion: **applied, pattern by pattern**

| 3c pattern | Trigger present? | Outcome |
|---|---|---|
| **List / collection view** (sort, filter, empty-list, pagination, persistence) | yes — the catalogue | **sort**: semantics out-of-slice (`00-source.md`), footprint covered by AC6; **persistence** derived → **AC6-C3** (measured); **filter**: no filter control exists on this page (measured — the only control is the sort select); **empty-list**: not reachable — a fixed 6-item catalogue with no filter, so no degenerate empty state exists to test; **pagination**: no pagination control exists. Waived-with-reason, not silently skipped |
| **Enumerate EVERY list, not just the primary one** | yes — the drawer is a second collection view | derived → **AC4-C5** (the drawer's 4-item list). This is the pattern that would have been missed by reading the ACs alone |
| **Any entity → full CRUD + inverses + cancel mid-operation** | **no** | this slice has no entity CRUD. The nearest lifecycle (drawer open/close and its inverse) is already the AC4 state machine, tagged `@state-transition`, not `@crud` — the palette's own distinction |
| **Conditional behaviour → decision table over the variation axes** | yes | axes present here are *viewport class* × *drawer state* → the AC3 table. Role/ownership axes (`problem_user`, `visual_user`, `performance_glitch_user`) are declared out-of-slice in `00-source.md`, **not** invented into cells |
| **Authorization & server-side enforcement** (unauthenticated, permission denied, cross-tenant/IDOR, uniqueness, UI-bypass) | partially | **unauthenticated** → AC5-C3; **UI-bypass** (direct URL, not through the UI) → AC5-C2/C4. **permission-denied / cross-tenant (IDOR)**: not derivable — SauceDemo has a single role and no per-user resource to address; deriving an IDOR condition here would be fabrication, and probing one would breach the `docs/DEMO-TARGETS.md` golden rule on a shared demo. **uniqueness/constraint**: no creatable entity in this slice |
| **Sibling collections of a named entity** | **no** | no AC describes an entity as "a collection of X" |
| **Account & auth → include the recovery path** | trigger fires (AC5 is an auth AC), **but the affordance does not exist** | measured: `probe-recall.js` found **zero** elements matching `/forgot\|reset\|recover\|help/i` on the login page. No recovery flow exists to test. Recorded as measured-absent rather than either skipped (the 2026-07-29 defect this guardrail names) or invented |
| **Ceiling — do not hallucinate to chase recall** | applies | two families surfaced as gaps rather than scenarised: (a) **config-driven behaviour** — the per-user variants are exactly the "feature-flag" family 3c's ceiling reserves for the knowledge base; (b) **rich interactions the source never mentions** — swipe-to-open the drawer, pinch-zoom, `orientationchange` (Q5). None invented |

### 3d — knowledge-driven conditions: **knowledge base absent**

`.qaia/knowledge/` does not exist for this evaluation run — no `index.md` to route through, no
`BR-KB-nnn` to cite, `design.knowledgeApplied` will be empty. Proceeding on the source alone,
inventing none of its content (shared contract rule 8). Recorded here **and** independently in
`testbooks/synthesis.md`, per `testbook-generate` step 4.

---

## 5. ⚠ VALIDATION (step 4)

`pending-validation` — no human in this session. The AC → technique map above is **proposed, not
approved**. Conditions built on `[assumption]`/`[open]` items (AC1-C1..C4, AC2-C1, AC7-C3) carry
their flags into `testbook-generate` and will be tagged `@low-confidence` there.

## Re-verification (2026-07-31, this session)

`probe-breakpoint.js` was re-executed from scratch in this session; its output reproduced the
2026-07-30 figures exactly (drawer 320→320 / 390→390 / 480→480 / 640→300 / 900→300 / 1280→300;
sort 40 px up to 899 and 223 px from 900; burger 20 × 20 and cart 40 × 40 at all 18 widths;
1 grid column up to 1060, 2 at 1280). `probe-recall.js` was written and executed in this session to
ground every 3c-derived condition before writing it here. No figure in this file is carried over
unverified.

## Skill findings — `istqb-design` (raised, not fixed)

### Finding 1 — the technique palette has no responsive/presentation dimension (`ÉCART` candidate)

- **SKILL.md lines 27-64** enumerate the whole palette. Every "Fits when the AC involves" cell is
  about *data, rules, lifecycle or user goals*: "input/state classes", "thresholds, limits, sizes,
  dates", "several related variables each carrying their own boundaries", "many independent
  parameters", "lifecycle rules (statuses, allowed/forbidden transitions, events)", "end-to-end
  user goals", "full entity lifecycle", "combinations of conditions → actions (roles × flags ×
  states)", "the exact expected output can't be stated directly", "error handling, empty states,
  concurrency".
- **Not one of them names the rendering surface.** A viewport width *is* a threshold, so BVA
  transfers — but nothing in the palette tells the reader that, and nothing suggests the second
  axis that actually matters on mobile: **which device descriptors constitute the partitions**.
  I selected `iPhone 13` / `Pixel 7` / `Desktop Chrome` as my EP representatives from
  `automate`'s guardrail (line 52), not from this skill.
- **Line 81 comes closest and still misses it**: *"cross the system's real axes: **config/feature
  flag** on/off, **visibility** private/public, **ownership/role** owner vs member vs admin vs
  anonymous"* — three axes, all server-side. Viewport class and input modality (touch vs pointer)
  are as real an axis as role, and produced this run's only genuine decision table (AC3).
- **Proposed diff (NOT applied)** — extend line 81's axis list:
  `` - **Conditional behavior (decision table over the variation axes)** → cross the system's real axes: **config/feature flag** on/off, **visibility** private/public, **ownership/role** owner vs member vs admin vs anonymous, and — for any AC whose outcome depends on the rendering surface — **viewport class** (phone / tablet / desktop, with the descriptors that represent each) and **input modality** (touch vs pointer). Generate the cell for each combination that changes behavior. ``
- **Why this is a real lacuna and not a non-event**: D100 makes mobile-by-emulation a claimed
  product axis. The claim is honoured in `automate` (line 33 "projects split by type e2e-desktop /
  e2e-mobile emulation / api", line 52 the guardrail) and in `visual-check`, i.e. **only in the
  execution layer**. Every design-layer skill upstream is viewport-blind. Concretely on this run:
  nothing in `istqb-design` would have prompted a reader to bisect for a breakpoint at all — the
  most mobile-specific act of the whole design step came from outside the skill.

### Finding 2 — 3b's oracle scope excludes the one standard a mobile US actually needs (`ÉCART MINEUR` candidate)

- **SKILL.md line 76**: *"If an AC touches a standardized domain (card/Luhn, dates/ISO 8601, HTTP
  status, email/RFC 5322, currency/ISO 4217, IBAN…), invoke `oracle-generate`"*.
- **This run's output, AC7-C3**: the only standardized threshold in the whole US is **WCAG 2.2
  SC 2.5.8's 24 × 24 CSS px**. The `…` in that list is doing all the work — a reader following the
  list literally sees six *data-format* standards and concludes 3b does not apply to a mobile US.
- **Proposed diff (NOT applied)** — on line 76, after `IBAN…`, insert:
  `` , or a published **interaction/accessibility threshold** (WCAG 2.2 target size SC 2.5.8/2.5.5, contrast SC 1.4.3, reflow SC 1.4.10) ``
- Not applied; left for arbitration.
