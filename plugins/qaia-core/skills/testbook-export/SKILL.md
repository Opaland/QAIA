---
name: testbook-export
description: Export the generated test book for human rework and reporting - .feature files as source of truth plus an XLSX and Markdown synthesis with coverage matrix, review order and confidence scores. Seventh step of the QAIA journey.
---

# testbook-export — hand the book to the humans

Follow the shared contract in `../README.md`. Prerequisite: a generated test book in `.qaia/testbooks/<US-ID>/` (else offer `testbook-generate`).

## Deliverables (D25)

1. **`.feature` files** — already the source of truth; exported as-is (copied to the user-chosen location if outside the repo).
2. **Markdown synthesis** (`synthesis.md`) — the review aid (D31), whose authoritative contract lives in the **shared contract** (`../README.md`, "Deliverable contract — synthesis.md"). This skill re-projects it; it never redefines it.
3. **XLSX workbook** — for teams reviewing in spreadsheets: sheet 1 *Scenarios* (ID, title, AC, condition, technique, priority, negative?, confidence, Gherkin text — **a Scenario Outline is exploded into one row per Examples line, ID suffixed `-eN`**), sheet 2 *Coverage matrix*, sheet 3 *Decisions & assumptions* (columns: ID, type answered/assumption/open/simulated/waiver, statement, source checkpoint — aggregated from `02-understanding.md` **and** the waivers/scope decisions of `03-04`). In Claude Code, build it with the available spreadsheet tooling; on surfaces without file tooling, produce CSV blocks the user can paste, and say so plainly.

## Steps

1. Ask target location (default: `.qaia/testbooks/<US-ID>/export/`) and which deliverables (default: all three).
2. Build the deliverables from checkpoint + testbook files only — no regeneration, no new content. Export is a *projection*, so any discrepancy it reveals is fixed in the source files first, then re-exported.
3. Confirm to the user what was produced and where; remind them the `.feature` files remain the source of truth and that manual edits there are preserved by regeneration (D17).
4. Update `journey.md`. Next steps: reporting (M2 connectors will push to Xray in git-master mode — D10) and `feedback` after their review.

## Guardrails

- Never export secrets or environment details that may sit in the repo; the export contains only testbook and checkpoint content.
- If the testbook and matrix disagree (edited by hand), stop and surface the discrepancy instead of exporting a lie.
