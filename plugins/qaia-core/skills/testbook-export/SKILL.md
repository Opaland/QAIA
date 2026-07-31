---
name: testbook-export
description: Export the generated test book for human rework and reporting - .feature files as source of truth plus an XLSX and Markdown synthesis with coverage matrix, review order and confidence scores, plus opt-in file-only Xray and TestRail CSV exports (git-master mode, no API key). Use when test cases must leave the repository - handed to a test manager, imported into Xray, TestRail or Jira, reviewed in a spreadsheet, or attached to a release report. Seventh step of the QAIA journey.
---

# testbook-export — hand the book to the humans

Follow the shared contract in `../README.md`. Prerequisite: a generated test book in `.qaia/testbooks/<US-ID>/` (else offer `testbook-generate`).

## Deliverables

1. **`.feature` files** — already the source of truth; exported as-is (copied to the user-chosen location if outside the repo).
2. **Markdown synthesis** (`synthesis.md`) — the review aid, whose authoritative contract lives in the **shared contract** (`../README.md`, "Deliverable contract — synthesis.md"). This skill re-projects it; it never redefines it.
3. **XLSX workbook** — for teams reviewing in spreadsheets: sheet 1 *Scenarios* (ID, title, AC, condition, technique, priority, negative?, confidence, Gherkin text — **a Scenario Outline is exploded into one row per Examples line, ID suffixed `-eN`**), sheet 2 *Coverage matrix*, sheet 3 *Decisions & assumptions* (columns: ID, type answered/assumption/open/simulated/waiver, statement, source checkpoint — aggregated from `02-understanding.md` **and** the waivers/scope decisions of `03-04`). In Claude Code, build it with the available spreadsheet tooling; on surfaces without file tooling, produce CSV blocks the user can paste, and say so plainly.
4. **Xray or TestRail CSV export (opt-in)** — not one of the three default deliverables above; offered when the user names Xray or TestRail as their test-management target. File-only, git-master mode — the `.feature` files in git stay the master copy and the exported CSV is a one-way projection of them, so nothing is ever read back from the tool: a CSV for Jira's CSV/Test Case Importer (Xray) or TestRail's own CSV/Excel import wizard, one row per scenario either way. Field mapping, Background-flattening/Given-When-Then-split rules, and honestly-flagged format uncertainties live in `connectors/xray.md` and `connectors/testrail.md` respectively — follow the matching file, do not improvise the column layout here.

## Steps

1. Ask target location (default: `.qaia/testbooks/<US-ID>/export/`) and which deliverables (default: all three; mention the opt-in Xray or TestRail CSV export if the user has a test-management tool to feed).
2. Build the deliverables from checkpoint + testbook files only — no regeneration, no new content. Export is a *projection*, so any discrepancy it reveals is fixed in the source files first, then re-exported. For the Xray export specifically, follow `connectors/xray.md` step by step; for TestRail, follow `connectors/testrail.md` step by step.
3. Confirm to the user what was produced and where; remind them the `.feature` files remain the source of truth and that manual edits there are preserved by regeneration. For the Xray CSV, also repeat the caveats `connectors/xray.md` names (version drift, Labels mapping, never tested against a live instance); for the TestRail CSV, repeat the caveats `connectors/testrail.md` names (Type/Priority are QAIA defaults to reconcile in the wizard, some scenarios legitimately produce an empty Steps field, never tested against a live instance) — the user should not treat either file as pre-verified.
4. Update `journey.md`. Next steps: reporting (**Xray and TestRail connectors delivered, git-master/file-only — `connectors/xray.md` and `connectors/testrail.md`**) and `feedback` after their review.

## Guardrails

- Never export secrets or environment details that may sit in the repo; the export contains only testbook and checkpoint content.
- If the testbook and matrix disagree (edited by hand), stop and surface the discrepancy instead of exporting a lie.
- Neither CSV export calls a live API (Xray/Jira or TestRail) nor asks for a credential — both are export-only (see `connectors/xray.md` and `connectors/testrail.md`); a live push stays a future opt-in tier, deliberately outside the core, not this skill.
