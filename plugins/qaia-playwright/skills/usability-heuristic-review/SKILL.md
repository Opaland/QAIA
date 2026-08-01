---
name: usability-heuristic-review
description: Review a running app's screens against Nielsen's 10 usability heuristics (CT-UT) via a structured heuristic evaluation and a cognitive walkthrough of one key task, reporting violations by severity. Use for usability coverage. Self-hosted targets only.
---

# usability-heuristic-review — heuristic evaluation (CT-UT)

Reference: `fixture/expense-demo-review.md` (3 real violations found and confirmed against
`examples/expense-demo/app/public/`, no fabrication). This skill covers the ISTQB CT-UT
(usability testing) syllabus — the one test type QAIA's other skills leave entirely uncovered.

**What this is not**: not a quantitative user survey (SUS score, task-completion-rate study with
real users) and not A/B testing or eye-tracking — those need real users QAIA cannot recruit.
This skill is the **formative, expert-review** half of CT-UT (heuristic evaluation + cognitive
walkthrough), the half a single reviewer session-bound to a self-hosted app can actually do
honestly.

## Steps

1. **Screen inventory.** For each key screen the test book covers (and any the user names),
   navigate and capture a snapshot/screenshot — same navigation discipline as
   `visual-check`/`a11y-audit`.
2. **Heuristic evaluation.** For each screen, check it against Nielsen's 10 heuristics
   (nngroup.com/articles/ten-usability-heuristics, verified against the source, not recalled):
   1. Visibility of system status — is there feedback for every action, especially async ones
      (loading/pending state, not just a final result)?
   2. Match between system and the real world — plain language, no internal jargon/error codes
      shown raw to the user.
   3. User control and freedom — an obvious way out of an unwanted state (cancel, undo, back)
      without a multi-step workaround.
   4. Consistency and standards — the same word/color/control means the same thing everywhere in
      the app.
   5. Error prevention — is a mistake caught before submission (format hints, confirmation on a
      destructive action) rather than only after?
   6. Recognition rather than recall — options/data visible when needed, not memorized from an
      earlier screen.
   7. Flexibility and efficiency of use — reasonable defaults and no forced re-entry of
      already-known data.
   8. Aesthetic and minimalist design — no irrelevant information competing for attention on the
      task at hand.
   9. Help users recognize, diagnose, and recover from errors — error messages state what went
      wrong and what to do next, in plain language.
   10. Help and documentation — is task-relevant help discoverable at the point of need (not
       just a generic external link, if present at all)?
   For each violation, cite the concrete evidence (a source line, a missing element, a
   reproduced click sequence) — never "feels off," always a pointed observation, same discipline
   as `a11y-audit`'s violation reporting.
3. **Cognitive walkthrough (one key task).** Pick the single most important user task the test
   book covers (the `@smoke` journey scenario, if one exists). Walk it step by step as a
   first-time user would, and at each step ask: will the user know what to do here? Will they
   notice the correct control? Will they understand the feedback after acting? Record every step
   where the honest answer is "not obviously" — this is a distinct technique from the per-screen
   heuristic pass above (it follows one path end-to-end rather than surveying each screen
   independently) and often surfaces gaps the heuristic pass alone misses.
4. **Severity and report.** Rate each finding on this scale — all four levels are defined,
   because a backlog is arbitrated on the two middle ones and "Moderate vs Minor" decided by
   feel is not arbitrable:
   - **Critical** — the user cannot complete the task at all: a dead end, a destructive action
     with no confirmation or undo, data lost without warning.
   - **Serious** — the task is completable but only with outside help, a retry, or a guess: an
     error that does not say what to fix, a required field revealed only on submit, a control
     whose effect is unpredictable.
   - **Moderate** — the task succeeds unaided but costs avoidable effort or doubt: unnecessary
     steps, an inconsistent label between two screens, feedback that arrives late.
   - **Minor** — the user notices nothing at the time; it degrades polish or accumulates across
     a product: inconsistent spacing, a tone that departs from the rest of the interface, a
     redundant confirmation.

   The dividing line between Critical and Serious is *unaided completion*; between Moderate and
   Minor it is *whether the user is slowed down at all*. Where a finding sits between two
   levels, choose the lower one and say why — an inflated severity list is discounted wholesale
   by the team receiving it. tag `@QAIA-UT-<NNN>`; report honestly, including a clean screen
   with **zero findings** as such rather than padding the report to look thorough.

## Guardrails

- **Self-hosted targets only** (same posture as `perf-check`/`security-surface`): review your
  own app, never a third-party production site.
- **Expert review, not a user study** — never present a heuristic-evaluation finding as if it
  came from real user testing; the report must say plainly which of the two (evaluation vs.
  walkthrough) produced each finding.
- A finding without a concrete, reproducible trigger (a specific element, a specific step) is
  not reported — no vague "feels unpolished" entries.
- Additive, not a replacement — usability findings never gate a release on their own; they are
  advisory input for `prioritize`/human review, same posture as every other producer skill (rule
  3: no producer scores itself).
