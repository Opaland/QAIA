---
stepsCompleted: [00-ingest]
lastStep: 02-understanding
lastSaved: 2026-07-30
upstreamStatus: extraction unconfirmed (01-review pending-validation)
---

# 02-understanding — US-EVAL-013

Knowledge base: **absent** (`.qaia/knowledge/` does not exist for this evaluation run) — recorded
per the shared contract rule 8, proceeding on the source alone, inventing none of its content.

## Reformulation

A shopper opens the Swag Labs catalogue on a phone. The whole navigation of the site — All Items,
About, Logout, Reset App State — lives behind a single 20 × 20 px burger control in the top-left
corner; there is no other route to any of them. Tapping it slides in a drawer that, below a
480 px viewport, covers the screen completely, so navigation is a modal, full-takeover mode rather
than a side panel. The catalogue's only control, the sort selector, shrinks to a 40 px stub on
every phone and tablet width. **Main risk if it misbehaves**: on a phone the drawer is a single
point of failure for the entire session — if it fails to open, fails to close, or renders under
something else, the shopper can neither navigate nor sign out, and there is no fallback control
anywhere in the page.

## Ambiguity hunt — numbered questions

| ID | Question | Why it matters for testing | Proposed default | **Status** |
|---|---|---|---|---|
| **Q1** | Is the 480 / 481 drawer breakpoint an **intended** product boundary, and is 480 meant to be **inclusive** in the "phone" class? | Every boundary scenario asserts on this exact edge; getting inclusivity wrong inverts two scenarios. | Observed behaviour is the rule: **≤ 480 full-screen, ≥ 481 fixed 300 px** (480 inclusive on the phone side). | `[assumption]` |
| **Q1b** | What happens at a **fractional** viewport width (480.5 px), which a real device can produce via zoom/DPR but `setViewportSize` cannot? | C2 hard rule: I chose integer widths, which *sidesteps* an undefined case — so it must be a numbered question, not a quiet test-data choice. | Unknown. Not defaulted; no scenario asserts fractional behaviour. | `[open]` |
| **Q2** | Is the sort control collapsing to **40 × 30 px** below 900 px an intended mobile presentation, or a degradation? At 40 px the selected option's text is not readable. | Determines whether the AC6 scenario is a *conformance* check or a *regression* check on a known defect. | None safe — this is a user-visible product policy. | `[open]` |
| **Q3** | Is a **20 × 20 CSS px** burger — the sole navigation control on a phone — an accepted target size? WCAG 2.2 SC 2.5.8 sets a 24 × 24 minimum (SC 2.5.5 Enhanced: 44 × 44). | Accessibility/compliance evidence; the answer decides whether AC7's scenario documents a rule or a violation. | None safe — decision tree step 2 (legal/compliance) forbids defaulting. | `[open]` |
| **Q4** | The drawer has **no scrim/overlay element** (`.bm-overlay` is `null` in the DOM). Is "closes only via its own ✕ control" intended, or is tap-outside-to-dismiss missing? | Decides whether a "tap outside closes the drawer" scenario is a valid expectation or a fabricated one. | Observed behaviour is the rule: the drawer is modal and closes only via its own control. | `[assumption]` |
| **Q5** | Does the application react to an **orientation change** (portrait → landscape) at all — is there any behaviour tied to `orientationchange`, or only to width? | A landscape phone (844 × 390) crosses the 480 px boundary and would get the *desktop* drawer. Whether that is intended is unspecified. | None safe — unexplored **and** unspecified; defaulting would be a guess about a case I never observed. | `[open]` |
| **Q6** | Is the single-column grid holding all the way to **1060 px** (not just on phones) intended? | BR1: the intuitive "collapses to 1 column on mobile" AC would place the boundary in the wrong decade. | Observed behaviour is the rule. | `[assumption]` |
| **Q7** | Is the post-logout refusal on `/inventory.html` **viewport-independent**? Observed only under the iPhone 13 descriptor. | If it were viewport-dependent, AC5 would need a per-descriptor scenario instead of one. | Yes — authorisation is not a presentation concern. | `[assumption]` |
| **Q8** | While the drawer is open at ≥ 481 px, part of the catalogue sits under the 300 px panel and part does not. Is the catalogue meant to be **interactive** in that state, or modal-blocked like on a phone? | AC3 asserts "unreachable" only for the phone class; the ≥ 481 case is genuinely undetermined by measurement (the card centre lands under the panel at 481). | None safe — it is a modality policy, and my own measurement is explicitly inconclusive here (`00-source.md`, occlusion table). | `[open]` |
| **Q9** | If the session ends **while the drawer is open on a phone**, is the refusal message rendered *behind* the full-screen drawer — i.e. invisible to the shopper? | Triple-AC intersection (see below): a real "the user is told nothing" failure mode, and the shape of the error is what AC5 asserts. | None safe — error-disclosure shape under an occluding surface is a product decision. | `[open]` |

**Deliberately NOT given a Q-slot** (per `need-understanding` SKILL.md line 29 — *"Q-slots are for
requirement ambiguity only … never for test-feasibility or flakiness questions"*): "is
`.bm-menu-wrap` addressable without a `data-test` attribute?" and "does `isVisible()` lie on the
off-canvas drawer link?" Both are real and both are recorded — but as **automation-design
concerns** in `automate`'s step-2 testability precheck (`automation/traceability.md`), not as gaps
in what the US specifies. This is the D125 fix working as intended on a run that had two obvious
candidates for the wrong bucket.

## Adversarial pass (by AC type)

| AC type present | ACs | Findings |
|---|---|---|
| **thresholds / quantities** | AC1, AC2, AC6, AC7 | Inclusive-vs-exclusive checked at **both** bounds by direct measurement, not inference: 479/480 → full-screen, 481 → 300 px; 899 → 40 px, 900 → 223 px. Units are CSS px throughout (never device px — the descriptors carry DSF 2–3, so a 20 × 20 CSS-px burger is 60 × 60 *device* px on an iPhone 13; the AC is stated in CSS px and says so). Rounding/fractional widths → **Q1b**, raised rather than sidestepped. |
| **state machine / lifecycle** | AC4 | States: `closed` (`aria-hidden="true"`, `display:none`) / `open` (`aria-hidden="false"`). **Re-entrance checked**: closed → open → closed → open was exercised six times in a row across six viewports in `probe-breakpoint.js`'s drawer sweep, returning to `aria-hidden:"false"` every time — no degradation, no stuck state. **Terminal state**: none — every state is reachable from every other. **Forbidden transition**: none declared by the source. |
| **auth / tokens / permissions** | AC5 | **Revocation vs expiration**: only *revocation* (explicit Logout) was observed; natural session **expiry** was never observed and is not asserted anywhere. **Indistinguishability**: the refusal names the requested path verbatim (`'/inventory.html'`), so it discloses which resource was requested — noted as an observation, not turned into an AC, because there is no stated anti-disclosure requirement to measure it against. |
| **sorting / pagination** | AC6 (footprint only) | Sort *semantics* (tie-breaks, ordering correctness) are explicitly **out-of-slice** (`00-source.md` dependencies) — this AC covers the control's rendered size, nothing else. Empty-list / pagination: the catalogue is a fixed 6 items with no pagination control; no degenerate empty state reachable without a filter, and there is no filter. |

## Cross-AC interaction pass

| Pair | Shared resource | Interaction at the boundary | Status |
|---|---|---|---|
| AC1 × AC3 | the drawer's rendered surface | full-width drawer ⇒ catalogue fully occluded — the two ACs are two faces of the same measurement | **covered** (scenarios -003, -011) |
| AC2 × AC3 | same | at 481 px the drawer is 300 px but the first card's centre still falls under it → occlusion is *not* a clean discriminator at that width | **`[open]` — Q8** |
| AC1 × AC4 | the only logout route | on a phone, Logout lives inside the surface that also blocks everything else: one control, one failure mode, no fallback | **covered** (scenario -005, and named as the main risk in the reformulation) |
| AC4 × AC5 | drawer open-state across a navigation | logging out from the open drawer navigates away; whether the drawer state is "closed" or simply "gone with the page" is not separately observable | **`[assumption]`** — treated as page-scoped, not asserted |
| AC1 × AC6 | viewport width | at 480 px **both** the full-screen drawer *and* the 40 px sort stub apply; the two breakpoints (480, 900) are independent and do not interact | **covered** — verified by the same sweep |
| AC7 × AC1 | the burger control | the 20 × 20 px target is the sole gateway to the full-screen drawer: the smallest target on the page guards the largest surface | **covered** (scenario -009 + Q3) |

## Triple-AC contradiction pass

**Applicable — one genuine triplet found** (not "not applicable"):

- a **restricted-state** rule (AC5: an unauthenticated request for `/inventory.html` is refused),
- a **scoping/presentation** rule (AC1: below 480 px the drawer covers 100 % of the viewport),
- an **error-shape / disclosure** rule (AC5's second half: the refusal is rendered as
  `[data-test="error"]` text *on the login page*).

At their intersection: **a session that ends while the drawer is open on a phone**. The refusal is
rendered into a page region that a 100 %-width drawer would sit on top of — so the one artefact
that tells the shopper what happened may be the one thing they cannot see. Which rule wins is not
stated anywhere. → **Q9, `[open]`**, never silently defaulted. It is deliberately **not** scenarised
with a guessed outcome; it is carried to the synthesis as an open arbitration.

## Knowledge capture

Nothing to promote — no user answered anything in this session, so there is no validated rule to
offer `rag-build`.

## ⚠ VALIDATION (step 6)

`pending-validation` — no user available. Q1/Q4/Q6/Q7 carry **proposed** defaults that a human has
not accepted; Q1b/Q2/Q3/Q5/Q8/Q9 stay `[open]`. Every scenario built on Q1/Q4/Q6/Q7 inherits
`@low-confidence`.

## Skill finding — `need-understanding` has no mobile/viewport dimension (raised, not fixed)

- **SKILL.md step 2** lists the ambiguity categories: *"undefined terms and units … every duration
  or deadline … contradictions between ACs … missing behavior (error paths, empty states,
  concurrency, permissions) … unspecified data rules (formats, rounding, limits, uniqueness)"*.
- **SKILL.md step 3** lists the adversarial AC types: *"state machine / lifecycle … auth / tokens /
  permissions … sorting / pagination … thresholds / quantities"*.
- **Neither list contains a single presentation-context category.** No viewport, no breakpoint, no
  orientation, no input modality (touch vs pointer), no device-pixel-ratio. Verified mechanically:
  a case-insensitive grep for `mobile|viewport|responsive|touch|breakpoint|orientation|landscape|
  portrait|tablet|phone` across all 29 `SKILL.md` files returns **zero** substantive hits in the
  seven `qaia-core` journey skills (the two apparent hits are `us-ingest:18` "phone" inside a PII
  list and `testbook-generate:46` "touch" as an ordinary verb). The only real mobile content in the
  whole repo's skills is `automate` lines 33 and 52, and `visual-check` lines 8 and 23.
- **Consequence measured on this run**: Q5 (orientation) and Q1b (fractional widths) came from my
  own reflex, not from any checklist in the skill. A different executor following the SKILL.md
  literally would have had no prompt to ask either. This is a **product lacuna**, not a
  non-event — D100 claims mobile-by-emulation as a supported axis, but nothing upstream of
  `automate` knows the axis exists.
- **Proposed diff (NOT applied)** — add a fifth bullet to step 3's AC-type checklist:
  `` - **presentation context / responsive** → for any AC whose outcome depends on the rendering surface: which viewport classes are in scope (phone / tablet / desktop) and where their boundaries sit (inclusive or exclusive); whether orientation change is a distinct case or only width matters; whether interactive targets have a stated minimum size on touch; whether the AC is expressed in CSS px or device px. ``
