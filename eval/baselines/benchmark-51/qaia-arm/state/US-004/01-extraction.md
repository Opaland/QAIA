---
stepsCompleted: [00-ingest, 01-review]
lastStep: 01-review
lastSaved: 2026-07-28
---

# 01-extraction — US-004

## Story
- **As a**: employee
- **I want**: to submit an expense report and have it approved through the right chain
- **So that**: I get reimbursed correctly and the company keeps an auditable trail

## Acceptance criteria (numbered, stable — downstream traceability anchors here)

- **AC1**: Report state machine — `draft → submitted → (approved | rejected |
  changes-requested)`; `changes-requested → draft`, re-submittable.
- **AC2**: Approval-chain-by-amount: `<€500` → manager only; `€500–€5000` → manager then
  finance; `>€5000` → manager, finance, then director.
- **AC3**: No self-approval; a manager-submitter's report skips to the next level up.
- **AC4**: Line-item mandatory fields (category, amount, date); date must be within the last
  90 days or submission is blocked with an explanatory message.
- **AC5**: Receipt mandatory for any line ≥ €25; submission refused otherwise.
- **AC6**: Non-EUR lines converted at the expense-date rate; converted total drives AC2's
  threshold.
- **AC7**: Rejected is terminal — no edit, no re-submit; a new report is required.
- **AC8**: Every transition records who/when; rejections and changes-requested additionally
  require a comment ≥ 10 characters.

## Business rules/constraints found outside the numbered AC list
- None. The story sentence itself ("so that I get reimbursed correctly and the company keeps
  an auditable trail") states intent/rationale, not an additional testable rule beyond AC8's
  audit-trail requirement.

## Referenced artifacts not analyzed
- None (no attachments, mockups, or links in the ingested slice).

## Present but not classifiable
- None — everything in the ingested slice maps cleanly to story or numbered AC.

## What was explicitly NOT found
- No named roles/permissions matrix (who is a "manager", how "finance" and "director" are
  identified as approvers) — assumed to be organizational data outside this US's slice.
- No explicit mention of currencies supported, rate source, or rounding rule.
- No mention of notifications, SLAs/deadlines for approvers to act, or partial approval
  visibility to the employee.

⚠ VALIDATION (extraction confirmed / corrected): `simulated: accepted-as-is`.
