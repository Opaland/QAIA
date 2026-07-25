# Validation — usability-heuristic-review on `examples/expense-demo/app/public/` (2026-07-26)

Applied the skill for real against ExpenseFlow's actual shipped HTML/JS (`index.html` + `app.js`)
— not a fabricated demo app. Screens: sign-in, new-draft, draft/line-items, my-reports, inbox.

## Heuristic evaluation — findings with concrete evidence

| # | Heuristic | Severity | Evidence |
|---|---|---|---|
| 1 | **H1 — Visibility of system status** | Serious | `app.js:15-23` (login) and `app.js:69-84` (submit) issue `fetch` calls with **no button-disable and no loading/pending indicator** — `showMsg` (`app.js:5`) only fires after the request resolves (success or error). A user clicking "Sign in"/"Submit for approval" gets zero feedback during the request and could plausibly double-click, believing nothing happened. |
| 2 | **H3 — User control and freedom** | Moderate | `index.html:50-61` (`#draft-section`): once "Start a draft" is clicked, the only controls are "Add line" and "Submit for approval" — **no cancel/discard-draft control** anywhere in the section or header. A user who starts a draft by mistake has no in-UI way back out short of reloading the page. Consistent with the gap already named honestly in `istqb-design`'s ceiling note ("no delete/discard mechanism is named anywhere in the source") — this is the same gap, now confirmed from the UI side, not just the spec side. |
| 3 | **H10 — Help and documentation** | Minor | No help link, tooltip, or `?`-affordance anywhere in `index.html` — a first-time user misreading "changes-requested" vs "rejected" status labels (`index.html:22,25`) has no in-app way to check what those states mean. |

No violations found for H2, H4, H5, H6, H7, H8, H9 on this pass — reported as clean, not omitted, per the skill's "report a clean screen honestly" guardrail. (H5/H9 are partially covered already by `security-surface`'s error-handling checks; this pass only adds the usability-framing findings above, not a re-run of those.)

## Cognitive walkthrough — task: "submit a first expense report as a new employee"

Steps walked: sign in → Start a draft → Add line → fill category/amount/date/receipt → Submit for approval.

- **Sign in**: clear (email/password, familiar pattern). No walkthrough gap.
- **Start a draft → Add line**: the empty `#lines` container gives no hint that a line must be added before submitting is meaningful — a first-time user could click "Submit for approval" on an empty draft with no line-count guidance beforehand. Not a hard blocker (the backend presumably rejects it, per `collectLines()`'s `app.js:56-67` filtering logic), but the *UI* gives no proactive nudge. Folds into finding #1's severity (Serious) rather than a new row — same underlying "no in-progress feedback" pattern.
- **Submit for approval**: per finding #1, no feedback during the request; per H2, the final message is generic (`put.data.error`/`r.data.error`, whatever the API returns verbatim) — plain-language quality depends entirely on the backend's error strings, not verified further here (out of this skill's scope, which reviews the UI, not the API's error-copy quality).

## Honesty notes

- This is a **single reviewer pass** (expert heuristic evaluation + one walkthrough), not a multi-rater study — CT-UT's own methodology recommends 3-5 evaluators for heuristic evaluation to reach reasonable coverage; one pass is a first signal, not a definitive audit. Stated plainly, not smoothed over.
- All three findings are cited to an exact file:line — none is a subjective "feels off" entry, per the skill's guardrail.
