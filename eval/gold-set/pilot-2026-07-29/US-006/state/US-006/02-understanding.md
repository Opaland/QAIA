---
stepsCompleted: [00-ingest, 01-review, 02-understanding]
lastStep: 02-understanding
lastSaved: 2026-07-29
---

# 02-understanding — US-006

Knowledge base: **absent** (no `.qaia/knowledge/` in this repo checkout) — proceeding on the
source alone, per degraded-mode rule 8.

## Reformulation

A crowdsourced-reporting platform must show each viewer exactly the post content — and exactly
the fields within a post — that their role and the post's status entitle them to, nothing more
and nothing less. The main risk if this misbehaves is **disclosure**: a non-published report, a
locked sensitive field, or a reporter's real identity leaking to a viewer who should never see
it — potentially endangering the reporter or violating the operator's stated privacy contract in
a civic-tech/crisis-reporting context. A secondary risk is destructive: media (e.g. photos)
being deleted by someone other than its owner or an admin, causing irrecoverable evidence loss.

## Cross-AC interaction pass (mandatory)

- **AC2 x AC3/AC4 (post-level gate before field-level gate)**: if a viewer fails AC2's post-level
  check, field-level questions (AC3/AC4) never arise for that viewer on that post — resolved
  analytically, see Q2.
- **AC2 x AC5 (private mode overrides anonymous creation)**: AC2 says "anyone, including
  anonymous, can create a draft"; AC5 says a private deployment blocks anonymous users from
  "creating new posts" outright. These two ACs contradict for the anonymous-in-private-mode
  case — resolved as an arbitration question, see Q5.
- **AC1 x AC6 (privilege hierarchy vs. destructive-action exception)**: AC1 defines admin as
  "full access" and manager as holding "manage posts" (not "manage media"); AC6 only carves out
  an admin-only exception for *unowned* media, leaving manager's rights over *other users'
  owned* media unstated — see Q6/Q7.

## Triple-AC contradiction pass

No genuine three-way contradiction was found (unlike the calibration example in the skill, which
needed a restricted-state + scoping + anti-disclosure triplet). The closest candidate — AC2
(post-level restriction) x AC3 (field-level lock) x AC4 (identity as a lockable field) — is not a
contradiction, just a layering: AC2 gates the post, AC3/AC4 gate fields within a post a viewer
already passed AC2 for. Recorded as **covered**, not a question.

## Adversarial pass by AC type

- **Auth/permissions** (AC1-AC6 throughout): revocation/expiration mid-session is out of scope
  (the source has no session/token concept — purely role x status). Scope changes mid-request are
  not applicable (stateless per-request check assumed).
- **Access boundary -> question, never assumption** (rule applied): whether a refused post-level
  view returns an explicit error or is silently list-excluded is a genuine access-boundary
  question -> `[open]` (Q1), not asserted either way.

## Questions

1. **Q1 `[open]`** — For a viewer without rights to view a non-published post (AC2), does a
   direct view attempt return an explicit refusal (e.g. an error response), and is the same post
   silently excluded from list results, or could it appear in a list with restricted content?
   Why it matters: this is an information-disclosure policy choice (existence disclosure), not a
   detail — the two behaviors are independently testable and a wrong assumption here is exactly
   the "plausible but wrong" defect class this journey must avoid. Proposed default: assume BOTH
   behaviors are required (explicit refusal on direct view AND exclusion from list results) since
   AC2 says "refused access" without qualifying the request shape — but this stays `[open]`
   because the source never actually states the *list* behavior, only "view".
2. **Q2 `[assumption]`** — Post-level visibility (AC2) is evaluated before field-level locks
   (AC3/AC4) apply; a viewer who fails AC2 never reaches an AC3/AC4 field-visibility question for
   that post. Default: yes (structurally the only sequencing that makes sense of "view a post
   that is not published" as a single gate).
3. **Q3 `[gap]` (config-driven family, not a numbered arbitration question)** — The mechanism by
   which specific fields are locked to specific roles (AC3) — per-post override vs. per-form/
   schema-level configuration — is not described and is exactly the "config/feature-flag-driven
   behavior" family `istqb-design` flags as **not inferable from a thin US** (belongs to a
   knowledge base, not guessing). Treated generically in test design: scenarios assert "a field
   locked to role R" as a given precondition, without asserting *how* that lock was configured.
4. **Q4 `[assumption]`** — The post's owner, viewing their own post, sees their own author-identity
   fields (real name/email) even when their role (e.g. basic user) would not otherwise grant that
   visibility to a third party. Default: yes — a self-view exception is the safe, low-risk,
   practitioner-obvious default (nobody expects to be hidden from their own data).
5. **Q5 `[assumption]`** — When a deployment is private, AC5's block on anonymous post-creation
   overrides AC2's general "anyone including anonymous can create a draft" allowance, for
   anonymous users specifically; authenticated roles' creation rights under AC2 are unaffected by
   the private flag. Default: yes (this is the only reading that makes AC5's explicit "cannot
   create new posts" sentence non-redundant).
6. **Q6 `[assumption]`** — A manager cannot delete media uploaded by another identified user (only
   their own manager "manage posts" permission does not extend to media ownership overrides).
   Default: forbidden-unless-stated (default-deny reflex for a destructive action, per
   `istqb-design` guardrails) — flagged `@low-confidence`.
7. **Q7 `[assumption]`** — An admin, per AC1's "full access", can delete *any* media regardless of
   ownership — not just the anonymous/unowned media AC6 explicitly calls out. Default: yes.
8. **Q8 `[assumption]`** — The unnamed "other non-public status" from AC2 is treated as a single
   generic "not published" partition for visibility purposes (no distinctly-named status gets a
   different visibility rule) — testing invented status names beyond `draft`/`published` would be
   fabrication beyond the source. Default: yes, generic partition.
9. **Q9 `[open]`** — Does "disable new registrations entirely" (AC5's independent toggle) also
   block an admin from directly creating a new user account (out-of-band, not self-service), or
   does it only close the self-service registration path? Why it matters: real, materially
   different behavior either way, and it is not a safety-obvious default (blocking admin account
   creation entirely could be operationally crippling; allowing it could defeat the point of the
   toggle in some deployments) — stays open pending human/product arbitration.
10. **Q10 `[assumption]`** — In private mode, authenticated basic/manager/admin users keep exactly
    their normal (public-mode) access levels — the private flag's restriction is anonymous-only,
    per AC5's literal wording ("anonymous users lose all access", no other role mentioned).
    Default: yes.

## Knowledge capture

No existing `knowledge/` base to enrich (see rag-build deviation note in `journey.md`). Two
`[assumption]`s above (Q6, Q7 — media-deletion ownership rules) are flagged as good `rag-build`
candidates for a real project's `business-rules.md`, not acted on here.

## Checkpoint

⚠ VALIDATION: all 10 questions -> `simulated: accepted-as-is` (proposed defaults applied; Q1 and
Q9 remain genuinely `[open]` — no default is asserted as fact for those two, only used to drive a
`@low-confidence` scenario each). Step `02-understanding` = done. Next step: `istqb-design`.
