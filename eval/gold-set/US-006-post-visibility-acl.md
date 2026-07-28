# US-006 — Role-based post visibility and field locking

> Gold set item, sourced from a real product (Ushahidi Platform, `ushahidi/platform`, GPLv3,
> `tests/Integration/acl.feature`). Domain: civic-tech / crowdsourced incident reporting,
> non-medical. The AC below are a faithful business-language derivation from reading the real
> scenarios, not a copy of their Gherkin steps or test data. Original raw oracle kept at
> `eval/gold-set/oracle-2026-07-29/ushahidi-acl-raw.feature` for post-hoc comparison — NOT
> given to any generation skill.

## User story

**As a** platform operator running a crowdsourced reporting deployment,
**I want** post visibility and field-level access to be strictly governed by the viewer's role
and the post's status,
**so that** sensitive reports and fields are only ever seen by people authorized to see them.

## Acceptance criteria

1. Roles, from least to most privileged: anonymous (no account), basic user (has an account,
   no special permissions), manager (has explicit "manage posts" permission), admin (full
   access). A deployment can additionally be configured "private", which changes anonymous
   access rules (see AC5).
2. A post has a status: `draft`, `published`, or another non-public status. Anyone (including
   anonymous) can create a post as a draft. Only the post's owner, a manager, or an admin can
   view a post that is not published; any other user (including anonymous) is refused access to
   it.
3. A post's individual fields can be locked to specific roles independently of the post's own
   status (field-level, not just post-level, access control). A viewer without the required
   role for a locked field must not see that field at all in the response (not shown as null —
   omitted entirely), while still seeing the post's other, unlocked fields. A manager or admin
   sees every field regardless of field-level locks.
4. The author's identity (real name, email) on a post is itself treated as a lockable field: an
   anonymous or basic-user viewer without the relevant role must not see the author's real name
   or email, even though they can see the post's content — a manager or admin does see the
   author's identity.
5. When a deployment is configured "private", anonymous users lose all access: they can neither
   list nor view any post (even ones that would otherwise be public), cannot register a new
   account, and cannot create new posts. A deployment can also independently disable new
   registrations entirely (for every role, not just anonymous).
6. A user can always delete media (e.g. an uploaded photo attached to a post) that they
   themselves uploaded. A user cannot delete media uploaded by someone else, or media that has
   no identified owner (was uploaded anonymously) — only an admin can delete such media.
