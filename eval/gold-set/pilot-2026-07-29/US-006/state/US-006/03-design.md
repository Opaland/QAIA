---
stepsCompleted: [00-ingest, 01-review, 02-understanding, 03-design]
lastStep: 03-design
lastSaved: 2026-07-29
---

# 03-design — ISTQB technique map + test conditions, US-006

Black-box only (D110): no implementation was read; every technique below is chosen from the
acceptance criteria and the 02-understanding disposition alone. Knowledge base absent — no
`BR-KB-nnn` citations in this run (`design.knowledgeApplied` will be `[]`).

## AC -> technique map

- **AC1** (role hierarchy + private-config axis) — **Equivalence Partitioning**: defines the four
  role partitions (`anonymous`, `basic`, `manager`, `admin`) and the `private`/`public` config
  axis reused by every other AC. Not independently scenario-able as its own behavior (it states
  domain structure, not an action) — covered *compositely*: every scenario below that varies role
  or the private flag exercises AC1's partitions. No standalone AC1 scenario is generated; this is
  recorded explicitly rather than left as a silent coverage gap.
- **AC2** (post status -> visibility) — **State Transition Testing** (`draft`/`published`/other
  status as the state axis feeding a visibility decision) + **Decision Table Testing** (role x
  status -> allow/deny).
- **AC3** (field-level lock) — **Decision Table Testing** (role x field-lock -> field shown/
  omitted).
- **AC4** (author identity as a lockable field) — **Decision Table Testing**, same shape as AC3,
  specialized to the identity fields; **Equivalence Partitioning** on viewer role.
- **AC5** (private deployment + registration toggle) — **Decision Table Testing** (private-flag x
  role x action -> allow/deny) + **Error Guessing** (registration-disabled edge, Q9).
- **AC6** (media deletion ownership) — **Decision Table Testing** (role x ownership -> allow/
  deny), tagged `@crud` where the technique driving the scenario is the delete/inverse lifecycle
  pattern itself.
- **Journey scenario** (`@smoke`, at most one per US) — **Scenario-Based Testing**: an end-to-end
  path crossing AC2-AC4-AC6 (a report submitted, reviewed under lock, media cleaned up).

## Oracle check (oracle-generate, folded in)

Detected trigger words: "email" (AC4). Conclusion: not applicable — AC4's email is an *exposure*
concern (who may see it), not a *format-validation* concern (is it syntactically valid), so the
RFC 5322 oracle does not supply anything here. No API/OpenAPI/JSON-Schema file was designated, so
no project oracle. No card/date/currency/IBAN domain present. **No oracle applied** —
`design.oracles = []`, recorded rather than silently omitted.

## Derived test conditions

Legend: `[req-neg]` = required-negative (ADR 0001 gate). `@low-confidence` marks a condition built
on an `[assumption]`/`[open]` item, citing the question ID.

### AC2 — post status visibility

- **AC2-C1** anonymous viewer, `published` post -> allowed (baseline positive).
- **AC2-C2** anonymous viewer, non-owned `draft` post -> refused `[req-neg]`.
- **AC2-C3** basic-user viewer (not owner), non-owned `draft` post -> refused `[req-neg]`.
- **AC2-C4** basic-user owner, own `draft` post -> allowed.
- **AC2-C5** manager, non-owned `draft` post -> allowed.
- **AC2-C6** admin, non-owned `draft` post -> allowed. *(C4-C6 share priority/confidence -> merged
  into one Scenario Outline downstream.)*
- **AC2-C7** anonymous creates a draft (public mode) -> allowed (baseline positive; low
  impact/probability -> P3, see `04-priorities.md`).
- **AC2-C8** viewer without owner/manager/admin standing, generic "other non-public" status post
  -> refused `[req-neg]` `@low-confidence` (Q8).
- **AC2-C9a** direct view of a restricted post -> explicit refusal `[req-neg]` `@low-confidence`
  (Q1, `[open]`).
- **AC2-C9b** restricted post excluded from list results -> `[req-neg]` `@low-confidence` (Q1,
  `[open]`).

### AC3 — field-level lock

- **AC3-C1** viewer without the required role for a locked field: field omitted entirely from the
  response (not null), post's other unlocked fields still shown -> `[req-neg]`.
- **AC3-C2** manager sees the locked field -> allowed (positive).
- **AC3-C3** admin sees the locked field -> allowed (positive). *(C2-C3 merged downstream.)*

### AC4 — author identity as a lockable field

- **AC4-C1** anonymous viewer sees post content but not author name/email -> `[req-neg]`.
- **AC4-C2** basic-user viewer (non-owner, no relevant role) — same -> `[req-neg]`. *(C1-C2
  merged.)*
- **AC4-C3** manager sees author identity -> positive.
- **AC4-C4** admin sees author identity -> positive. *(C3-C4 merged.)*
- **AC4-C5** owner views own post, sees own identity fields -> positive `@low-confidence` (Q4).

### AC5 — private deployment + registration toggle

- **AC5-C1** private=true, anonymous attempts to list posts -> refused `[req-neg]`.
- **AC5-C2** private=true, anonymous attempts to view a normally-public post -> refused `[req-neg]`.
- **AC5-C3** private=true, anonymous attempts to register -> refused `[req-neg]`.
- **AC5-C4** private=true, anonymous attempts to create a post -> refused `[req-neg]`
  `@low-confidence` (Q5).
- **AC5-C5** private=true, authenticated basic user retains normal access -> positive
  `@low-confidence` (Q10).
- **AC5-C6** registration-disabled=true, self-service registration attempt (any role context) ->
  refused `[req-neg]`.
- **AC5-C7** registration-disabled=true, admin directly creates a user account -> allowed
  `@low-confidence` (Q9, `[open]`) — proposed safe default only, not asserted as fact.

### AC6 — media deletion ownership

- **AC6-C1** user deletes their own uploaded media -> positive (low impact/probability -> P3, see
  `04-priorities.md`).
- **AC6-C2** user attempts to delete another identified user's media -> refused `[req-neg]`.
- **AC6-C3** user attempts to delete anonymous-owned (unidentified) media -> refused `[req-neg]`.
  *(C2-C3 merged downstream — same priority/confidence.)*
- **AC6-C4** admin deletes anonymous-owned media -> positive.
- **AC6-C5** admin deletes another user's owned media -> positive `@low-confidence` (Q7).
- **AC6-C6** manager attempts to delete another user's owned (non-anonymous) media -> refused
  `[req-neg]` `@low-confidence` (Q6).

**Total: 31 conditions** (AC1 compositely covered, no dedicated conditions of its own).
**16 tagged `[req-neg]`.**

## Checkpoint

⚠ VALIDATION (technique map + condition list): `simulated: accepted-as-is`. Step `03-design` =
done. Next step: `prioritize`.
