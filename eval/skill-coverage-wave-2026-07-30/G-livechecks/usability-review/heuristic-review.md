# usability-heuristic-review — real run against MediBook (self-hosted)

- Skill exercised: `plugins/qaia-playwright/skills/usability-heuristic-review/SKILL.md`
- SUT: `examples/medibook/app/server.js` started locally with `PORT=4401 node server.js` — **self-hosted**, per the skill guardrail *"Self-hosted targets only (D35), … never a third-party production site."*
- Evidence: `explore.js` / `explore-stdout.txt` / `explore-output.md`, `probe-cancel.js` / `probe-cancel-output.json`, `screens/01-…08-….png`
- Every quoted string below was read from the live DOM at run time. Nothing is recalled.

> **Target deviation, stated openly.** The wave brief proposed SauceDemo. The skill forbids it
> (guardrail 1, and `docs/DEMO-TARGETS.md` lists SauceDemo `Self-host = ❌`). I followed the skill,
> not the brief, and ran on the self-hosted MediBook SUT instead. Chosen over `examples/expense-demo`
> because expense-demo is the skill's own reference fixture (`fixture/expense-demo-review.md`) —
> re-reviewing it would risk recycling known findings instead of producing new ones.

## Step 1 — Screen inventory (navigated + captured live)

| # | Screen | Screenshot |
|---|--------|-----------|
| S1 | Sign in (`#login-section`) | `screens/01-signin.png` |
| S1b | Sign in after empty submit | `screens/02-signin-empty-submit.png` |
| S1c | Sign in after wrong password | `screens/03-signin-bad-password.png` |
| S2 | Available slots + My appointments (`#app-section`) | `screens/04-slots.png` |
| S2b | Booking request in flight (throttled 1500 ms) | `screens/05-booking-inflight.png` |
| S2c | After booking confirmed | `screens/06-booked.png` |
| S2d | Business-rule rejection (minor, no guardian) | `screens/07-minor-noguardian-error.png` |
| S2e | After clicking Cancel | `screens/08-after-cancel.png` |

## Step 2 — Heuristic evaluation (expert review, NOT user testing)

### @QAIA-UT-001 — Serious — H1 Visibility of system status (S2, booking)
No pending state at all during the async booking call. With the API throttled to 1500 ms, the DOM
sampled 500 ms into the request reads:
```
"clickedButtonDisabled": false,
"clickedButtonLabel": "Book",
"anySpinnerOrBusy": 0,
"firstSlotHTML": "<div class=\"slot\" role=\"listitem\" data-slot-id=\"s1\"><span>Dr. Ada Reed — cardiology — 31/07/2026 02:35:57</span><button data-testid=\"book-s1\">Book</button></div>"
```
The button stays enabled and unlabelled-as-busy, so the screen is pixel-identical to the idle state
and a second click is possible. Trigger: click `[data-testid="book-s1"]` on a slow link.

### @QAIA-UT-002 — Serious — H1 / H4 (S2) — stale error announced on the wrong screen
`#message` (`role="status" aria-live="assertive"`) still carries the previous screen's failure after a
**successful** sign-in. `S2 slots: visible text` (verbatim from `#app-section`) ends with:
```
Dr. Ada Reed — cardiology — 01/08/2026 01:35:57
Book
invalid credentials
My appointments
```
The user just signed in successfully and is looking at an assertive "invalid credentials". Trigger:
sign in with a wrong password once, then sign in correctly — the message is never cleared.

### @QAIA-UT-003 — Serious — H4 Consistency and standards (S2) — same rule class, opposite treatment
Two time-window business rules, rendered inconsistently:
- Book, blocked ahead of time: `<button data-testid="book-s2" disabled title="Starts in less than 2 hours">Book</button>`
- Cancel, blocked only after the click: `<button data-testid="cancel-a2">Cancel</button>` — enabled, no `title`, no `disabled`; clicking it yields `"cancellation refused: less than 4 hours before start"` (`probe-cancel-output.json`).

The same app teaches the user "greyed = not allowed" on one control and then breaks that contract on
the adjacent one. Trigger: sign in `patient@demo`, book `book-s1`, click `cancel-a2`.

### @QAIA-UT-004 — Serious — H5 Error prevention (S2, cancel) + H1
Follows from UT-003: the destructive `Cancel` is offered as available for an appointment the server
will refuse. `modalsInDom: 0` and `nativeDialogSeen: null` — there is no confirmation step either, so
the control is simultaneously *too* available (no confirmation) and *falsely* available (will fail).

### @QAIA-UT-005 — Serious — H9 Recover from errors (S1) — one generic message for two causes
Both the empty form and the wrong password produce the exact same string, `"invalid credentials"`
(`S1 H5` block and `S1 H9` block). It is lowercase, states no cause, and states no next action; the
underlying `401` reaches only the console:
```
"Failed to load resource: the server responded with a status of 401 (Unauthorized)"
```
There is no "check your email address", no password-reset path. Trigger: click `#login-btn` with
`#email` and `#password` empty.

### @QAIA-UT-006 — Moderate — H5 Error prevention (S1) — no client-side guard
`S1 sign-in: interactive controls` shows both inputs with `"required": false`, `"placeholder": ""`,
`"title": ""`, and `emailValidity: true` on an empty field. The empty submit therefore performs a real
network round trip to learn something the browser could have prevented.

### @QAIA-UT-007 — Moderate — H2 Match between system and the real world (S2)
Raw internal policy wording surfaced verbatim to a patient:
`"practitioner not authorized for minors"` (`#message`, after clicking Book as `minor-noguardian@demo`)
and `"cancellation refused: less than 4 hours before start"`. Both read as log lines (lowercase,
colon-delimited), name no concrete actor ("Dr. Ada Reed"), and offer no alternative to pick instead.

### @QAIA-UT-008 — Moderate — H6 Recognition rather than recall (S2)
The reason a slot is unbookable exists only in a `title` attribute:
`title="Starts in less than 2 hours"`. A `disabled` button is not focusable, so that explanation is
unreachable by keyboard and invisible without hovering — the user sees a grey button and must recall
or guess the rule.

### @QAIA-UT-009 — Moderate — H10 Help and documentation (S1, S2)
Zero help affordance anywhere in the document:
```
"linksInDoc": [],
"elementsMentioningHelp": []
```
No "forgot password", no support contact, no rule explanation, at the exact points (UT-005, UT-007)
where the user is stuck.

### Clean, reported as clean (no padding)
- **H3 User control and freedom** — an explicit way out exists on both screens:
  `H3: every button present anywhere on the signed-in screen` = `["Sign in","Sign out","Book","Book","Book","Book","Cancel"]`.
  Sign out is always present; a booked appointment does expose a `Cancel`. **Zero finding on H3** (the
  *rendering* problem of that Cancel is filed under H4/H5 as UT-003/UT-004, not against H3).
- **H8 Aesthetic and minimalist design** — the signed-in screen text (jargon scan output) contains
  only the sign-in identity, the specialty filter, the slot list and the appointment list. No
  irrelevant competing content. **Zero finding.**
- **H7 Flexibility and efficiency** — the specialty `<select>` defaults to `All` and the email is not
  re-requested after sign-in. **Zero finding**, on this screen pair.

## Step 3 — Cognitive walkthrough (one key task: "book a teleconsultation slot")

Distinct technique from step 2: one path, end to end, as a first-time user.

| Step | Will the user know what to do / notice the control / understand the feedback? | Real observation |
|---|---|---|
| 1. Land on `/` | Yes | `main` text = `Sign in / Email / Password / Sign in`. Unambiguous. |
| 2. Sign in | **Not obviously** on failure | 63 ms to `#app-section` on success — fine. On failure, `"invalid credentials"` gives no route forward (UT-005). |
| 3. Find a slot | Partly | Rows read `Dr. Ada Reed — cardiology — 31/07/2026 02:35:57` + `Book`. Legible, but the greyed second row offers no visible reason (UT-008). |
| 4. Click Book | **Not obviously** | Nothing changes for the duration of the request (UT-001). A first-time user's rational response is to click again. |
| 5. Read the outcome | Yes | `#message` = `"Booking confirmed with Dr. Ada Reed"` and `#appointments` gains `Dr. Ada Reed — 31/07/2026 02:35:57 — booked`. Clear and specific — the best feedback in the app. |
| 6. Change one's mind | **Not obviously** | `Cancel` looks available, click does nothing visible except `"cancellation refused: less than 4 hours before start"`; the row is unchanged (UT-003/UT-004). |

Walkthrough-only conclusion (not visible from the per-screen pass): the task *completes*, but steps 4
and 6 both leave the user without confirmation that their click was even received.

## Method statement (guardrail: "the report must say plainly which of the two produced each finding")
- Produced by **heuristic evaluation**: UT-001 … UT-009.
- Produced by the **cognitive walkthrough**: the step-4 and step-6 "no acknowledgement of the click"
  reading in the table above (it reinforces UT-001/UT-004 rather than adding a new numbered finding).
- No finding here comes from user testing. No SUS score, no task-completion-rate, no eye-tracking.
- Advisory only; nothing here gates a release (guardrail 4).
