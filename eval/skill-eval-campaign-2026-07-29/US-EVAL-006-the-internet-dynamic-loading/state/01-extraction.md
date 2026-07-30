# 01-extraction — US-EVAL-006

## Story `[reconstructed]`

**As a** visitor of the "Dynamically Loaded Page Elements" demo page,
**I want** clicking "Start" to show a loading indicator and then, after a fixed delay, reveal
"Hello World!" — whether that final element already existed on the page (just hidden) or is
created fresh after the delay,
**so that** the page (and any automation driving it) correctly distinguishes "wait for an element
to become *visible*" from "wait for an element to *exist* at all," the two distinct async-DOM
patterns this feature's own index page says it demonstrates.

*(Not expressed as a story in the source — this is a demo page, not a ticket. Reconstructed from
the index page's own stated intent + both examples' inline JS, per `us-review` step 1's
`[reconstructed]` license for a real capability with no story phrasing.)*

## Acceptance criteria (numbered, stable — AC1..AC7)

- **AC1.** On Example 1 (`/dynamic_loading/1`), the initial page state (before any click) shows a
  visible "Start" button, and a `#finish` element containing "Hello World!" is already present in
  the DOM but not visible (`display:none`).
- **AC2.** On Example 1, clicking "Start" immediately (no delay) hides the `#start` block (button
  no longer visible) and inserts a "Loading..." indicator (with a spinner image) in its place.
- **AC3.** On Example 1, exactly 5000ms after the click, the loading indicator is hidden and the
  pre-existing `#finish` element becomes visible, displaying "Hello World!". Before the 5000ms
  elapse, "Hello World!" is not visible.
- **AC4.** On Example 2 (`/dynamic_loading/2`), the initial page state shows a visible "Start"
  button, and **no `#finish` element exists anywhere in the DOM** (not hidden — literally absent).
- **AC5.** On Example 2, clicking "Start" immediately hides the `#start` block and inserts the
  same "Loading..." indicator as Example 1.
- **AC6.** On Example 2, exactly 5000ms after the click, the loading indicator is hidden and a
  **new** `#finish` element is created and inserted into the DOM, then made visible, displaying
  "Hello World!". Before the 5000ms elapse, no `#finish` element exists in the DOM at all (a
  stricter absence than AC3's "exists but hidden").
- **AC7.** Both examples use the identical 5000ms delay, the identical loading-indicator markup,
  and the identical final "Hello World!" text — confirmed as literal string/value matches in both
  pages' own served source.

## Business rules / constraints found outside the AC list

- Neither example's click handler disables or removes the `#start button` element itself, or
  guards against a second timer being scheduled — the button becomes unreachable through the UI
  only because its container (`#start`) is hidden. A programmatic (non-pointer) second click while
  a timer is already pending is not guarded against in the read source.
- The two examples are explicitly framed by the source itself (index page copy) as testing two
  different DOM shapes ("already exists... not displayed" vs "not on the page and gets added in")
  — this is a deliberate pair, not two redundant copies of the same scenario, and downstream
  design should not collapse them into one technique.

## Referenced artifacts not analyzed

- The demo app's other "edge case" pages (`dynamic_controls`, `disappearing_elements`,
  `slow_resource`, and the rest of `the-internet`'s catalog) — out-of-slice, see `00-source.md`
  dependencies.
- `/img/ajax-loader.gif` (the spinner image itself) — its visual content is not analyzed, only its
  presence in the markup.

## Present but not classifiable

- None.

## What was NOT found

- Whether a forced/programmatic second click on the hidden `#start button` while a timer is
  already pending produces a defect (stacked timers, duplicate `#loading`/`#finish` insertions) —
  not exercised live in this capture; carried to `need-understanding` as an open point, not
  invented here.
- Exact server-side response timing/jitter beyond the literal `5000` in client-side JS — not
  probed (would require repeated timed requests, outside "explore").

## Journey

| Step | Status |
|---|---|
| 00-ingest | done |
| 01-review | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run) |

## Skill evaluation — `us-review` (`plugins/qaia-core/skills/us-review/SKILL.md`)

**Verdict: CONFORME.**

**Evidence**: Step 1 (line 13) requires marking a reconstructed story `[reconstructed]` when the
source has no story phrasing — done in the "Story" heading above. Step 1's AC numbering (line 14)
is stable (`AC1`..`AC7`), matching guardrail line 25 ("every AC gets a stable number here...
never renumber after validation"). Step 2 (line 18) requires explicitly listing what was NOT
found — done in its own section; the thin-but-real-capability carve-out on line 18 correctly does
not fire the not-a-spec gate here (this is a real, richly-specified capability — two working demo
pages with literal, readable JS — not a non-spec). No deviation found. **Modification proposed:
none.**
