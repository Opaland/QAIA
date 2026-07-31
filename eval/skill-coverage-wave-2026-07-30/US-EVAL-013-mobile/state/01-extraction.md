---
stepsCompleted: [00-ingest]
lastStep: 01-review
lastSaved: 2026-07-30
status: unconfirmed
---

# 01-extraction — US-EVAL-013

> **Status: `unconfirmed`.** `us-review` SKILL.md line 19 forbids marking step 3 `done` in a
> non-interactive context. No human was available in this session, so this extraction is
> `unconfirmed` and `01-review` stays `pending-validation` in `journey.md`.
>
> **Documented deviation, not a silent one** — see `## Skill finding` at the bottom of this file:
> the same line also says *"and stop"*, which literally forbids continuing to
> `need-understanding`. The campaign brief for this run explicitly requires the full canonical
> parcours in one non-interactive session. Those two instructions cannot both be honoured. I
> continued, and I am naming the conflict here rather than quietly ignoring half of one of them.

## Story

`[reconstructed]` — the source is a live application with no written story. Reconstructed per
`us-review` SKILL.md line 13 ("if absent but a real capability is described, reconstruct it and
mark it `[reconstructed]`").

> **As a** shopper browsing the Swag Labs catalogue on a phone,
> **I want** the navigation drawer to take over the whole screen and the catalogue controls to stay
> reachable at a narrow viewport,
> **So that** I can navigate, sort and sign out without needing a desktop-sized pointer or screen.

## Acceptance criteria

All ACs are `[reconstructed]` from measured behaviour (`00-source.md`). Each cites its measurement.

| ID | Acceptance criterion | Grounded in |
|---|---|---|
| **AC1** | On a viewport **≤ 480 CSS px** wide, opening the navigation drawer renders it at **100 % of the viewport width** — it covers the catalogue entirely. | drawer table: 320/390/479/480 → width == viewport, `productStillUncovered: false` |
| **AC2** | On a viewport **≥ 481 CSS px** wide, the same drawer renders at a **fixed 300 CSS px**, leaving catalogue content visible beside it. | drawer table: 481→300 (62 %), 640→300 (47 %), 1280→300 (23 %), `productStillUncovered: true` |
| **AC3** | While the drawer is open on a phone viewport, the catalogue underneath is **not reachable**: a tap at a product card's position lands on the drawer, and no item is added to the cart. | `probe-occlusion.js`: at 390 and 480 the topmost element at the card centre is `NAV.bm-item-list` |
| **AC4** | The drawer is the **only** route to Logout on a phone, and it toggles closed → open → closed via its own open/close controls (`aria-hidden` `true` → `false` → `true`). | `probe-logout2.js`: 1 matching element in the whole DOM, `insideDrawer: true`; `probe-breakpoint.js` drawer sweep: `aria` flips |
| **AC5** | Logging out from the drawer returns the shopper to the login page, and a subsequent direct request for `/inventory.html` is **refused** with `Epic sadface: You can only access '/inventory.html' when you are logged in.` while the URL stays on the login page. | `probe-logout.js` verbatim `refusalText` |
| **AC6** | The product-sort control renders at **~40 CSS px** wide for viewports **≤ 899 px** and **~223 CSS px** for **≥ 900 px** — i.e. it collapses to a stub on every phone and tablet width. | `probe-breakpoint.js` sort width column |
| **AC7** | Touch-target dimensions are **not** viewport-adaptive: the burger control stays **20 × 20 CSS px** and the cart control **40 × 40 CSS px** at every viewport from 320 to 1280. | `probe-breakpoint.js` burger/cart columns, identical on all 18 widths |

## Business rules and constraints found outside the AC list

- **BR1** — The single-column product grid is **not** a phone-specific behaviour: 1 column holds
  from 320 px all the way to 1060 px; only 1280 px shows 2 columns. Any AC phrased as "collapses to
  one column on mobile" would be wrong about *where* it collapses.
- **BR2** — No horizontal overflow (`scrollWidth == clientWidth`) at any of the 18 widths measured,
  including 320 px.
- **BR3** — Playwright's `iPhone 13` descriptor defaults to the **WebKit** engine, `Pixel 7` to
  Chromium. A suite that runs both descriptors on one browser engine is not exercising what the
  descriptors describe.

## Referenced artifacts not analyzed

- SauceDemo's **native** companion app (SauceLabs *My Demo App*, React Native) — named in
  `docs/DEMO-TARGETS.md` line 24 and explicitly out of scope per D100. Not fetched, not analysed.
- The target's stylesheets. During exploration I did read the page's list of `@media` condition
  texts once, to choose which widths to bisect. **That is a white-box peek** and it is disclosed
  here; every AC above is nevertheless anchored on a *rendered measurement*, and each boundary was
  re-derived empirically (479/480/481 and 899/900/901 were all measured directly). Flagged as a
  tension with `istqb-design`'s "black-box only, by design (D110)" rather than left unsaid.

## Present in the source but not classifiable

- Console errors observed on the live target (2 on load, more after form fills) — a real signal but
  not part of this responsive slice; not turned into an AC, not dropped either.

## What I did NOT find

- No written story, no numbered ACs, no design spec, no changelog — the entire AC list is
  `[reconstructed]`.
- No stated intent for the 480/481 or 899/900 breakpoints.
- No orientation / landscape behaviour (not explored — see `00-source.md`).
- No touch-gesture behaviour beyond `tap` (swipe-to-open not exercised).

## ⚠ VALIDATION (step 3)

`pending-validation` — no user available. Extraction status `unconfirmed`.

## Skill finding — `us-review` SKILL.md line 19 (raised, not fixed)

- **SKILL.md line 19, verbatim**: *"**In a non-interactive context with no user available, do NOT
  mark this step done** — write the extraction with status `unconfirmed`, leave `01-review` as
  `pending-validation` in `journey.md`, **and stop**"*.
- **Conflict**: `docs/SKILL-EVAL-CAMPAIGN-PROMPT.md` defines a 7-step non-interactive parcours
  whose steps 3-7 all sit *after* this instruction. Taken literally, the D125 fix makes the
  project's own evaluation campaign terminate at step 2 on every run — the campaign's entire
  purpose (exercising `istqb-design` … `automate` on real targets) becomes unreachable
  non-interactively.
- **Proposed diff (NOT applied)** — on line 19, replace:
  `` leave `01-review` as `pending-validation` in `journey.md`, and stop ``
  with:
  `` leave `01-review` as `pending-validation` in `journey.md`. Stop here when the journey's purpose is to deliver a test book to a user. An evaluation/batch harness may continue past this point **only** if every downstream artifact it produces is stamped with the unconfirmed provenance (`extraction: unconfirmed`) and no gate downstream reports a green verdict on it. ``
- Rationale: the intent of the D125 fix (kill `simulated: accepted-as-is`) is preserved — what is
  forbidden is *pretending* a human confirmed. Propagating the `unconfirmed` stamp is a stricter,
  runnable form of the same control.
