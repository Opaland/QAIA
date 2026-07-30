# 00-source — US-EVAL-006

- **Source type**: live public demo, **primary source** (the page's own served HTML + inline
  JavaScript, read directly — not a blog/tutorial summary of "how the-internet's dynamic loading
  page works"), per `docs/SKILL-EVAL-CAMPAIGN-PROMPT.md`'s "explore freely on public demos"
  allowance. Target: `the-internet` (`docs/DEMO-TARGETS.md` row, UI✅✅ "edge cases",
  self-hostable via Docker, `saucelabs/the-internet` / `tourdedave/the-internet` on GitHub) —
  specifically its **"Dynamically Loaded Page Elements"** feature (index page links it as
  "Dynamic Loading"), chosen over the catalog's other UI-edge-case pages because it is a
  structurally different shape from every prior campaign run (`US-EVAL-001`..`005`): no auth, no
  cart, no REST API — pure client-side timing/DOM-mutation behavior, which is exactly the "edge
  cases" the `DEMO-TARGETS.md` row (UI✅✅) is annotated for.
- **Capture method**: direct unauthenticated `GET` (via `curl`, a single request per page, no
  scan/load pattern — golden rule respected) of the three real pages that make up this feature:
  the index page and both of its linked examples. Not scraped beyond what the index page itself
  links to.
- **Capture date**: 2026-07-29.
- **Pages read (primary source, cited per fact below)**:
  - `GET https://the-internet.herokuapp.com/dynamic_loading` (index — lists the two examples)
  - `GET https://the-internet.herokuapp.com/dynamic_loading/1` ("Example 1: Element on page that
    is hidden")
  - `GET https://the-internet.herokuapp.com/dynamic_loading/2` ("Example 2: Element rendered
    after the fact")

- **Captured facts (faithful, not paraphrased into stronger claims than the source supports)**:

  > Index page (`/dynamic_loading`) states the feature's own intent verbatim: "It's common to see
  > an action get triggered that returns a result dynamically... There are two examples. One in
  > which an element already exists on the page but it is not displayed. And [an]other where the
  > element is not on the page and gets added in." — the two examples are explicitly framed by the
  > source itself as testing two *different* DOM shapes, not two copies of the same behavior.
  >
  > **Example 1** (`/dynamic_loading/1`) served HTML contains, in the initial DOM (before any
  > click): `<div id='start'><button>Start</button></div>` followed by
  > `<div id='finish' style='display:none'><h4>Hello World!</h4></div>` — i.e. `#finish` **exists
  > in the DOM from page load**, merely hidden via inline `display:none`.
  > Inline `<script>` (jQuery, page's own literal code):
  > ```
  > $('#start button').click(function(){
  >   $('#start').hide();
  >   $('#start').before("<div id='loading'>Loading... <img src='/img/ajax-loader.gif'></div>");
  >   setTimeout(function() {
  >     $('#loading').hide();
  >     $('#finish').show();
  >   } , 5000 );
  > });
  > ```
  > On click: `#start` is hidden (not removed — it stays in the DOM, just not displayed); a new
  > `#loading` div (text "Loading..." + a spinner `<img>`) is inserted immediately before it; a
  > hardcoded `setTimeout` of **exactly 5000ms** later hides `#loading` and calls jQuery `.show()`
  > on the already-present `#finish`, revealing "Hello World!". No AJAX/network call — the delay
  > is a pure client-side timer, no server round-trip to wait on.
  >
  > **Example 2** (`/dynamic_loading/2`) served HTML contains, in the initial DOM:
  > `<div id='start'><button>Start</button></div>` and **no `#finish` element anywhere in the
  > page** (confirmed by reading the full served HTML — absent, not merely hidden).
  > Inline `<script>` (page's own literal code):
  > ```
  > $('#start button').click(function(){
  >   $('#start').hide();
  >   $('#start').before("<div id='loading'>Loading... <img src='/img/ajax-loader.gif'></div>");
  >   setTimeout(function() {
  >     $('#loading').hide();
  >     $('#loading').before("<div id='finish' style='display:none'><h4>Hello World!</h4></div>")
  >     $('#finish').show();
  >   } , 5000 );
  > });
  > ```
  > Identical click/hide/loading-insert behavior to Example 1, but after the same **5000ms**
  > timer, the callback **first creates a brand-new `#finish` node** (inserted before `#loading`,
  > itself still `display:none` at creation) and only then calls `.show()` on it — the element
  > **does not exist in the DOM at all until after the delay**, unlike Example 1 where it exists
  > all along, hidden.
  >
  > Both examples use the **same 5000ms literal** and the **same** `#loading` indicator markup
  > (`Loading... <img src='/img/ajax-loader.gif'>`) and the **same** final visible text
  > ("Hello World!" inside an `<h4>`) — confirmed identical strings in both served pages' source,
  > not assumed to match.
  >
  > No page-level `disabled` attribute or click-guard is set on `#start button` after the first
  > click in either example's own JS (the button becomes unreachable through the UI only because
  > its container `#start` is hidden by the same handler — the handler itself does not prevent a
  > second `.click()` triggered outside a normal pointer click, e.g. programmatically).

- **Not confirmed by any source found**: server response headers/timing precision beyond the
  literal `5000` in the client-side `setTimeout` call (no server-side artificial delay was probed
  — probing exact wall-clock jitter would require repeated timed requests, which this capture did
  not do, staying inside "explore," not a load-test pattern); and whether a second, out-of-band
  click on the hidden `#start button` (forced via `.trigger('click')`, not a real pointer click)
  stacks a second `setTimeout`/`#loading` insertion — the handler code itself does not guard
  against it, but this was not exercised live in this capture (see `01-extraction.md`/
  `02-understanding.md` for how this is carried forward, not silently assumed either way).
- **Redaction**: none needed (no personal data anywhere on this page — static demo copy only).
- **Dependencies (out-of-slice)**: `the-internet`'s other "edge case" pages (`dynamic_controls`,
  `disappearing_elements`, `slow_resource`, etc., also captured in `docs/DEMO-TARGETS.md`'s ✅✅
  row) are separate features of the same demo app, not designed here — this US-slice is scoped to
  the "Dynamically Loaded Page Elements" feature (both its examples) only.

## Journey

| Step | Status |
|---|---|
| 00-ingest | done — gates checked (not empty, is a testable capability — a real page with
  deterministic, timer-driven DOM behavior, no abuse/illegality, no PII to redact) |

## Skill evaluation — `us-ingest` (`plugins/qaia-core/skills/us-ingest/SKILL.md`)

**Verdict: CONFORME.**

**Evidence**: Step 1 (line 12) requires fetching "exactly that source — nothing else." Here the
designated source is `docs/DEMO-TARGETS.md`'s `the-internet` row (not a single URL), and the three
pages read are exactly the index page plus the two examples the index page itself links to — no
page outside that closed set was fetched, and no silent substitution occurred (the 2026-07-29
footnote on line 12 that campaign runs must watch for). Step 2's triage gates (lines 14-17) were
run: not empty, a real testable capability (deterministic timer-driven DOM mutation), no abuse
framing. Step 3's redaction gate (line 18) correctly found nothing to mask (static demo copy, no
PII). No deviation found between what steps 1-7 literally ask for and what this checkpoint does.
**Modification proposed: none.**

⚠ VALIDATION (US-ID, captured-source confirmation): `simulated: accepted-as-is` (non-interactive
campaign run, per shared-contract rule 3's `simulated` convention).
