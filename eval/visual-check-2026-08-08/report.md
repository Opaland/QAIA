# visual-check — second domain, first mutation-verified run (2026-08-08)

Issue #18. Until today `visual-check` had exactly one suite behind it — `examples/medibook/tests/visual.booking.spec.js` — which is also the file the skill cites as its own reference. A skill whose only evidence is the example it was written from has not been shown to generate anything.

**Target**: `examples/expense-demo` (`node app/server.js`, `http://localhost:4500`), a domain the skill had never seen.
**Produced**: `examples/expense-demo/tests/visual.expense.spec.js`, 6 snapshots, `@QAIA-VIS-001` to `@QAIA-VIS-006`.
**Raw run**: `run-visual.txt`.

---

## What this run does and does not settle

**Settles**: the skill generates a working, deterministic visual suite on a domain it was not written against, and the suite is load-bearing — verified by mutation, not asserted.

**Does not settle**: T17. This is a second in-repo demo, not a pilot application. #18's remaining requirement — generation against a real pilot app — is still blocked on #1, and nothing here substitutes for it.

## Result

**6 snapshots, 6 green, twice in a row.** Full suite with the new project: **56/56**.

The first run reported six failures. That is the skill's own rule working as written — *"a first run is never a pass, it is baseline creation"* — and it is recorded here rather than quietly rerun, because a reader who sees only the green second run learns the wrong thing about what a first run means.

## The defect this found, which is not a visual defect

Generating `@QAIA-VIS-002` — the sign-in screen after a rejected credential — failed on the assertion *before* the snapshot: the error element was not there.

`app.js` calls `showMsg()` on a failed sign-in, and `showMsg` wrote into `#message`. **`#message` lives inside `#app-section`, which is still `hidden` at that point.** So on a wrong password the user saw nothing at all: no message, no colour, no shift. And because that element carries `role="status" aria-live="assertive"`, the announcement a screen-reader user depends on was being made inside a hidden subtree — announced to nobody.

Two things follow, and the second is the more uncomfortable:

- The page object `LoginPage.error` pointed at `#login-section #message` — a location where no message can exist. It was **never used by any test**, so nothing ever failed on it. A dead selector in a POM is a recorded intention the application does not implement, and it survives precisely because it is unused.
- Neither the E2E suite nor the a11y suite caught this. The a11y automation checks the rendered page; an aria-live region inside a hidden subtree is not a WCAG violation the scanner flags, it is a behaviour nobody asserted.

**Fixed**: a visible `#login-message` region inside `#login-section`, and `showMsg` now routes to whichever region is actually on screen. `LoginPage.error` repointed at the real element.

This is the second defect in this demo found by a QAIA skill applied to it (after the IDOR of Sprint 22 and `CP-001` of #71) and, like those, it was found by generating tests rather than by reading code.

## Mutation verification

Snapshots that pass are worthless as evidence unless something proves they can fail. Two mutations, each reverted after measurement:

| Mutation | Killed | Survived | Reading |
|---|---|---|---|
| Primary button colour `#1c2b1e` → `#7a1e1e` | **5 of 6** | `VIS-005` | `VIS-005` snapshots the *submitted* list, which contains no button — correct scoping, not a gap |
| `.card` padding `.75rem` → `.95rem` (a ~3 px layout shift) | **2 of 6** | 4 | only `VIS-005` and `VIS-006` scope card lists; the other four contain no `.card` |

Each mutation is caught by exactly the snapshots whose scope contains the mutated element, and by no others. That is the property scoping is supposed to have, and the numbers are reported per mutation rather than summed into a single "kill rate" that would hide it.

The subtle mutation matters more than the colour one: a 3-pixel padding change is the kind of regression a human reviewer waves through and a functional test cannot see at all.

## Determinism

The suite reset the SUT per test and scoped every snapshot to a container rather than the viewport. The one genuinely dynamic value — the date input, which a browser may default to today — is **filled with a fixed date rather than masked**, per the skill's own guardrail that a frozen region gives a provable 0-pixel diff where a mask only hides.

Run twice back to back: identical, 6/6 both times.

## Limits, stated

- **Baselines are `-win32`.** They were generated on Windows and the CI runs Linux; a diff against these baselines in CI is meaningless. To run this suite in CI the baselines must be regenerated there — the skill says so and it applies to this suite too. **The visual project is therefore not wired into the CI workflow.**
- **Six screens, not all screens.** No approval decision screen, no rejected/changes-requested state, no mobile-emulation snapshot. The skill supports device descriptors; this run did not exercise them.
- **One tolerance, unexamined.** Every snapshot uses `maxDiffPixelRatio: 0.002`. No screen needed a different one, so no reasoning about per-screen tolerance was tested here.
