---
name: us-review
description: Verify that an ingested user story was correctly extracted - restructure it (story, acceptance criteria, business rules, open points) and have the user confirm or fix the extraction. Second step of the QAIA journey, after us-ingest.
---

# us-review — extraction check

Follow the shared contract in `../README.md`. Prerequisite: `00-source.md` (else offer `us-ingest`).

## Steps

1. **Structure the capture.** From `00-source.md`, produce a structured extraction:
   - Story (As a / I want / So that, quoted or faithfully paraphrased if present; if absent but a real capability is described, **reconstruct it and mark it `[reconstructed]`**; otherwise "not expressed in the source" — found by running this skill on a real capture with no story phrasing, 2026-07-29 skill-eval campaign: reconstructing without this explicit license is an undocumented deviation even when self-disclosed)
   - Numbered acceptance criteria, quoted or faithfully paraphrased
   - Business rules and constraints found outside the AC list
   - Referenced artifacts not analyzed (attachments, mockups, links)
   - Anything present in the source but not classifiable (keep it visible, never drop content)
2. **Show the diff mentality.** Present the structure and explicitly list what you did NOT find (no AC numbering, no story, etc.). Do not invent missing parts. **If the extraction has no acceptance criteria and no described behavior at all** (design doc, RFC, empty template, non-spec), say so plainly and route back to the user for real requirements rather than emitting an empty shell. **But a thin US that names a real capability is NOT a non-spec**: a bare `Feature:` with a title and a `Background:` (e.g. "Feature: Profile" / "a signed-in user") *does* describe testable behavior — proceed and generate, marking inferred behavior `[assumption]`. The not-a-spec gate fires only on genuine non-requirements, never on a real-but-underspecified story.
3. ⚠ VALIDATION: the user confirms the extraction or corrects it (missing AC, wrong split, misread rule). Apply corrections and re-show until confirmed.
4. **Checkpoint.** Write `.qaia/state/<US-ID>/01-extraction.md` with the confirmed structure. Update `journey.md`: step `01-review` = done. Next step: `need-understanding`.

## Guardrails

- Faithfulness over polish: when the source is ambiguous, reproduce the ambiguity and flag it — resolving it is the next skill's job, with the user.
- Every AC gets a stable number here (`AC1`, `AC2`…): downstream traceability (coverage matrix, scenario IDs) anchors on these numbers, so never renumber after validation.
