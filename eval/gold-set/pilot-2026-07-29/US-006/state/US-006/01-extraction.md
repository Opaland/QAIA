---
stepsCompleted: [00-ingest, 01-review]
lastStep: 01-review
lastSaved: 2026-07-29
---

# 01-extraction — US-006

## Story

- **As a** platform operator running a crowdsourced reporting deployment,
- **I want** post visibility and field-level access to be strictly governed by the viewer's role
  and the post's status,
- **so that** sensitive reports and fields are only ever seen by people authorized to see them.

## Acceptance criteria (stable numbering — never renumbered downstream)

- **AC1** — Role hierarchy, least to most privileged: `anonymous` (no account) <
  `basic user` (account, no special permissions) < `manager` (explicit "manage posts"
  permission) < `admin` (full access). A deployment can additionally be configured **"private"**,
  which changes anonymous-access rules (cross-referenced to AC5).
- **AC2** — A post has a status: `draft`, `published`, or another non-public status (name not
  given). Anyone, including anonymous, can create a post as a draft. Only the post's owner, a
  manager, or an admin can view a post that is not published; any other viewer (including
  anonymous) is refused access.
- **AC3** — A post's individual fields can be locked to specific roles, independently of the
  post's own status (field-level access control, distinct from post-level). A viewer lacking the
  required role for a locked field must not see that field **at all** (omitted, not null) while
  still seeing the post's other, unlocked fields. Manager/admin see every field regardless of
  field-level locks.
- **AC4** — The author's identity (real name, email) is itself a lockable field. An anonymous or
  basic-user viewer without the relevant role must not see the author's real name/email, even
  though they can see the post's content. Manager/admin do see the author's identity.
- **AC5** — When a deployment is "private", anonymous users lose all access: cannot list or view
  any post (even ones that would otherwise be public), cannot register a new account, cannot
  create new posts. A deployment can also independently disable new registrations entirely (for
  every role, not just anonymous).
- **AC6** — A user can always delete media they themselves uploaded. A user cannot delete media
  uploaded by someone else, or media with no identified owner (uploaded anonymously) — only an
  admin can delete such unowned media.

## Business rules/constraints found outside the AC list

None beyond what is folded into the AC statements above — the source is a compact, well-scoped
AC list with no separate "business rules" section.

## Referenced artifacts not analyzed

None (see `00-source.md`).

## Present in the source but not classifiable

None — every sentence of the source maps to one of the 6 ACs above; nothing left unclassified.

## What was NOT found (explicit — do not invent)

- No explicit list of *all* non-public statuses beyond "draft" and "an unnamed other one" (AC2).
- No description of the field-lock **configuration mechanism** (per-post vs per-schema) (AC3).
- No mention of whether manager's permission set extends to media deletion beyond post
  management (AC6).
- No numeric thresholds, dates, or currency — no boundary-value domain of that kind present.
- No API/OpenAPI contract designated by the user — no project oracle applicable.

## Checkpoint

⚠ VALIDATION (extraction confirm): `simulated: accepted-as-is`. Step `01-review` = done. Next
step: `need-understanding`.
