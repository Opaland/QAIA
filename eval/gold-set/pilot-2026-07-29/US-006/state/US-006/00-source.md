---
stepsCompleted: [00-ingest]
lastStep: 00-ingest
lastSaved: 2026-07-29
---

# 00-source — US-006

- **Source type**: local file (Markdown), read in full.
- **Location**: `eval/gold-set/US-006-post-visibility-acl.md`.
- **Capture date**: 2026-07-29.
- **Size**: 43 lines, well under the ~20k-token split threshold — read whole, no section
  splitting needed.
- **US-ID**: `US-006` (the file's own heading already carries this key; no separate tracker
  lookup was needed). ⚠ VALIDATION: `simulated: accepted-as-is`.

## Triage gates

- **Empty/whitespace-only**: not fired — substantial content.
- **Not-a-testable-requirement**: not fired — a story (As a/I want/So that) plus 6 numbered
  acceptance criteria describing observable, testable behavior.
- **Abuse/illegality gate**: not fired — the source describes an access-control feature for a
  civic-tech reporting platform; no framing of an unlawful/abusive activity.

## Sensitive-data redaction

Scanned for national IDs, payment cards, health status, precise addresses/phones/emails of real
individuals. **None found.** The source mentions "email" and "real name" only as abstract field
*categories* subject to access control, never a concrete individual's value. 0 items masked.
Redaction ledger (type -> placeholder -> count): none — nothing to redact.

## Captured text (faithful, unmodified — no PII to mask)

> # US-006 -- Role-based post visibility and field locking
>
> Gold set item, sourced from a real product (Ushahidi Platform, `ushahidi/platform`, GPLv3,
> `tests/Integration/acl.feature`). Domain: civic-tech / crowdsourced incident reporting,
> non-medical.
>
> ## User story
>
> As a platform operator running a crowdsourced reporting deployment, I want post visibility and
> field-level access to be strictly governed by the viewer's role and the post's status, so that
> sensitive reports and fields are only ever seen by people authorized to see them.
>
> ## Acceptance criteria (1-6)
>
> See `01-extraction.md` for the numbered, structured restatement — reproduced faithfully there,
> not paraphrased away from the source's actual wording.

Note: this checkpoint captures the source; the note in the source file that a held-out raw
`.feature` oracle exists at `eval/gold-set/oracle-2026-07-29/ushahidi-acl-raw.feature` was **not
opened, read, or used** at any point in this journey, per the pilot's explicit isolation
instruction — recorded here for auditability, not as an ingested reference.

## Attachments / referenced artifacts not analyzed

None — the source is self-contained prose, no images/mockups/links.

## Sibling-story / dependency scan (guardrail)

- No sibling story IDs are referenced in the source.
- **Referenced-but-undefined terms** worth flagging as out-of-slice/underspecified (carried
  forward into `01-extraction.md` and `02-understanding.md`):
  - The exact name/set of "another non-public status" beyond `draft`/`published` (AC2) is not
    given.
  - The concrete mechanism by which a field is "locked to specific roles" (AC3) — a per-post
    override vs. a per-form/schema-level configuration — is not described.
  - The "manage posts" permission (AC1) is named but its full permission set (does it bundle
    other rights beyond viewing non-published posts?) is not enumerated.
- The source does not claim INVEST "Independent" explicitly, so no contradiction to flag there.

## Checkpoint

Step `00-ingest` = done. Gates: none fired. Redaction: 0 items masked. ⚠ VALIDATION (US-ID
confirm, capture confirm): both `simulated: accepted-as-is`. Next step: `us-review`.
