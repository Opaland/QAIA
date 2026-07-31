---
name: us-review
description: Verify that an ingested user story was correctly extracted - restructure it (story, acceptance criteria, business rules, open points) and have the user confirm or fix the extraction. Use right after ingesting a US, and whenever someone asks whether a specification was read faithfully, whether acceptance criteria were missed, or wants to check an extraction before designing tests on top of it. Second step of the QAIA journey, after us-ingest.
---

# us-review — extraction check

Follow the shared contract in `../README.md`. Prerequisite: `00-source.md` (else offer `us-ingest`).

## Steps

1. **Structure the capture.** From `00-source.md`, produce a structured extraction:
   - Story (As a / I want / So that, quoted or faithfully paraphrased if present; if absent but a real capability is described, **reconstruct it and mark it `[reconstructed]`**; otherwise "not expressed in the source". The `[reconstructed]` marker is what makes the reconstruction legitimate: a story the reader believes came from the source, when in fact you wrote it, silently turns your interpretation into the requirement everything downstream is tested against. Mentioning it in prose is not enough — the marker must sit on the artifact itself, where the next step reads it.)
   - Numbered acceptance criteria, quoted or faithfully paraphrased
   - Business rules and constraints found outside the AC list
   - Referenced artifacts not analyzed (attachments, mockups, links)
   - Anything present in the source but not classifiable (keep it visible, never drop content)
2. **Show the diff mentality.** Present the structure and explicitly list what you did NOT find (no AC numbering, no story, etc.). Do not invent missing parts. **If the extraction has no acceptance criteria and no described behavior at all** (design doc, RFC, empty template, non-spec), say so plainly and route back to the user for real requirements rather than emitting an empty shell. **But a thin US that names a real capability is NOT a non-spec**: a bare `Feature:` with a title and a `Background:` (e.g. "Feature: Profile" / "a signed-in user") *does* describe testable behavior — proceed and generate, marking inferred behavior `[assumption]`. The not-a-spec gate fires only on genuine non-requirements, never on a real-but-underspecified story.
3. ⚠ VALIDATION: the user confirms the extraction or corrects it (missing AC, wrong split, misread rule). Apply corrections and re-show until confirmed. **In a non-interactive context with no user available, do NOT mark this step done** — write the extraction with status `unconfirmed`, leave `01-review` as `pending-validation` in `journey.md`, record the `simulated` entry in `openArbitrations[]`, **and continue**; a simulated acceptance is not a substitute for step 4's "confirmed structure". Marking this step done on the strength of a self-issued "accepted as is" note annuls the only control this skill provides: the whole point of the step is that a human confirmed the extraction matches the source, and nothing the skill writes about itself can stand in for that. Follow `../README.md` rule 3 verbatim — it is the single arbitration. Note what the control is and is not: stopping the journey is *not* the control (a run that stops is simply a run nobody finishes, and harnesses restart it anyway) — refusing to mark the step done is.
4. **Checkpoint.** Write `.qaia/state/<US-ID>/01-extraction.md` with the confirmed structure. Update `journey.md`: step `01-review` = done **only if step 3's validation actually happened**; otherwise `pending-validation`, per step 3 and `../README.md` rule 3. Next step: `need-understanding`.

## Guardrails

- Faithfulness over polish: when the source is ambiguous, reproduce the ambiguity and flag it — resolving it is the next skill's job, with the user.
- Every AC gets a stable number here (`AC1`, `AC2`…): downstream traceability (coverage matrix, scenario IDs) anchors on these numbers, so never renumber after validation.
