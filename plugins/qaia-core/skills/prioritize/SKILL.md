---
name: prioritize
description: Risk-based prioritization of derived test conditions - the skill proposes probability x impact scores, the human arbitrates. Use when there is more to test than time allows, when someone asks what to test first or what can be dropped, or before generating a test book so generation covers the right conditions. Fifth step of the QAIA journey, before test book generation.
---

# prioritize — risk-based, human-arbitrated

Follow the shared contract in `../README.md`. Prerequisite: `03-design.md` (else offer `istqb-design`). Risk-based testing needs inputs only a human has — how much a failure would actually cost this
business, and how fragile this part of the system really is: **the skill proposes, the user decides.**

## Steps

1. **Propose scores.** For each test condition of `03-design.md`, propose:
   - **Impact** (1-3): consequence if this behavior fails in production — safety/regulatory/data-loss = 3, degraded service = 2, cosmetic = 1. Use `knowledge/` (criticality notes, anomaly history) when available; cite what you used.
   - **Probability** (1-3): likelihood of a defect — new/complex/concurrent logic and `[open]`-flagged conditions score higher; stable well-understood rules lower.
   - **Optional git-history signal.** Only if the user has explicitly named a target repo path for this session — never scan or infer a repo the user did not name, and never reach beyond it. When named, and a condition maps to identifiable file(s) (from the US/design context), a lightweight `git log --stat` on those files is one more input to the probability call, not a new score dimension: recent and/or frequent changes there are cited in the rationale as an additional risk factor ("`path/to/file` changed N times / M lines in the recent history — cited as a probability input"). Weigh substance over raw count — a file touched often only by small, mechanical, append-only edits (a changelog, a version bump) is not a higher-risk zone just because its commit count is high; a file with few but large/structural recent diffs can be. This signal never raises probability on its own past what the condition's own complexity already supports, never lowers impact, and is silently skipped (no error, no placeholder score) when no repo path is available or a condition maps to no identifiable file. Absence of history data is not evidence of low risk either — say so rather than treating "no data" as "safe."
   - Priority = impact × probability → **P1 (≥6) / P2 (3-4) / P3 (≤2)**.
2. **Show your reasoning compactly.** One table: condition, impact, probability, priority, one-line rationale. Flag every score based on an `[assumption]` or `[open]` item, and every score whose probability the git-history signal nudged, citing the file(s) and stat used (`@history(path, stat)`) — same visibility rule as `[assumption]`/`[open]`, an uncited influence is not usable.
3. ⚠ VALIDATION: the user adjusts scores (their business knowledge overrides yours), or approves. Record each override with the user's stated reason — that reason is knowledge (offer `rag-build` capture when reusable). **In a non-interactive context with no user available, do NOT treat auto-acceptance as arbitration** — output the scores explicitly as `proposed but not arbitrated`, with a disclaimer that they are unsuitable for a production Go/No-Go until a human reviews them; a `simulated: accepted-as-is` note is not a substitute for the arbitration this step exists to force. Marking this step done without a human having looked cancels the only control the skill provides: a simulated acceptance is not an acceptance, and scores that were never contradicted are not scores that were validated — nobody downstream can tell the difference once the note is written. Leave `04-prioritize` as `pending-validation` in `journey.md`, record the `simulated` entry in `openArbitrations[]`, and continue — `../README.md` rule 3 is the single arbitration and this step follows it verbatim.
4. **Checkpoint.** Write `04-priorities.md`: the arbitrated table. Update `journey.md`. Next step: `testbook-generate` — tell the user generation will cover P1 and P2 fully; P3 coverage is their call, because generation costs the user real subscription quota and P3 is where that budget stops paying for itself.

## Deliverable rule (rubric dim. 9)

The **one-line risk rationale of every priority assignment must reach the delivered book** — `testbook-generate` copies it into the coverage matrix (rationale column) and the synthesis, together with the list of assignments needing human arbitration. A priority whose rationale only lives in `04-priorities.md` (an internal state file the reviewer never sees) counts as unjustified.

## Guardrails

- Never present your scores as final — the arbitration step is the point of this skill.
- A regulated-context project (medical software and regulated environments are QAIA's primary niche) treats traceability-relevant conditions as impact 3 by default; say so when applying it.
- The git-history signal is an input to probability, never a verdict and never a shortcut around arbitration: it cannot substitute for reading the condition's actual logic, it never moves probability past what that reading already supports, and every use is cited (file + stat) so the user can reject it as easily as any other proposed score — including when it was the deciding nudge across a priority-band boundary. Raw commit frequency alone is never sufficient justification (see the "substance over raw count" rule above); the citation must point to something concrete (a diff's content, not just a count) for the nudge to stand up to arbitration. Read only the repo path the user explicitly gave for this session — no scanning other repos, no crawling beyond the files tied to the condition at hand (shared-contract rule 6, no side effects beyond what's requested).
