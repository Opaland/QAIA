---
stepsCompleted: [00-ingest]
lastStep: 05-testbook-generate
lastSaved: 2026-07-31
upstreamStatus: extraction unconfirmed; priorities proposed-but-not-arbitrated
---

# coverage-matrix — US-EVAL-013

Scope generated: **P1 + P2** (19 of 26 conditions). P3 deferred by the default quota trade-off
(Q22) and listed below rather than dropped from the count.

| AC | Condition | Scenario ID | Prio | Risk rationale (from `04-priorities.md`) | Confidence | Reuse notes (D19 duplicate scan) |
|---|---|---|---|---|---|---|
| AC1 | AC1-C3 (479 px) | `-001` (Outline row 1) | P1 | Boundary−1 of the only navigation-mode switch; the inclusivity it proves is an `[assumption]` | `@low-confidence` (Q1) | no duplicate found |
| AC1 | AC1-C4 (480 px) | `-001` (Outline row 2) | P1 | The boundary itself — decides Q1's inclusivity; get it wrong and two ACs invert | `@low-confidence` (Q1) | no duplicate found |
| AC2 | AC2-C1 (481 px) | `-002` | P1 | Boundary+1, the other face of the same untested edge | `@low-confidence` (Q1) | no duplicate found |
| AC1 | AC1-C1 (320 px) | `-003` (row 1) | P2 | Mid-partition representative at the narrowest realistic phone | `@low-confidence` (Q1) | no duplicate found |
| AC1 | AC1-C2 (390 px) | `-003` (row 2) | P2 | The width most real shoppers see; representative, not boundary | `@low-confidence` (Q1) | no duplicate found |
| AC3 | AC3-C1 `[req-neg]` | `-004` | P1 | A tap leaking through the drawer changes cart state on a screen the shopper cannot see | confirmed by measurement | no duplicate found |
| AC3 | AC3-C2 (control cell) | `-005` | P2 | Impact is the whole phone purchase path, but it is the core, most-exercised behaviour | confirmed by measurement | no duplicate found |
| AC4 | AC4-C1 (Closed→Open) | `-006` | P1 | The 20 × 20 px burger is the only gateway to every navigation action on a phone | confirmed by measurement | no duplicate found |
| AC4 | AC4-C2 (Open→Closed) | `-007` | P1 | No scrim and no tap-outside dismiss, so a drawer that will not close locks the shopper out | `[assumption]` Q4 noted in `02` | no duplicate found |
| AC4 | AC4-C3 (re-entrance ×2) | `-008` | P1 | Toggle state machines degrade on repetition, not on first use | confirmed by measurement | no duplicate found |
| AC4 | AC4-C4 (only logout route) | `-009` | P2 | High consequence (no fallback sign-out on a phone) but a stable structural fact | confirmed by measurement | no duplicate found |
| AC5 | AC5-C1 (logout → login page) | `-010` | P2 | Session termination itself; consequential but the best-trodden of the auth paths | confirmed by measurement | **adjacent book noted** — see below |
| AC5 | AC5-C2 `[req-neg]` | `-011` | P1 | Session **revocation** enforcement — the classic place auth breaks | confirmed by measurement | **adjacent book noted** |
| AC5 | AC5-C3 `[req-neg]` | `-012` | P1 | Unauthenticated access to a guarded route; a distinct code path from revocation | confirmed by measurement | **adjacent book noted** |
| AC5 | AC5-C4 `[req-neg]` | `-013` (2 rows) | P1 | UI-bypass across *every* guarded route, not just the one the AC names | confirmed by measurement | no duplicate found |
| AC6 | AC6-C1 (899 px) | `-014` (row 1) | P2 | Probability 3 because Q2 is `[open]` — the expected result itself is contested | `@low-confidence` (Q2) | no duplicate found |
| AC6 | AC6-C2 (900 px) | `-014` (row 2) | P2 | Same contested-expectation driver at the other side of the edge | `@low-confidence` (Q2) | no duplicate found |
| AC6 | AC6-C3 (sort persistence) | `-015` | P2 | State loss on a phone means redoing the selection through a 40 px stub | derived (3c), measured | no duplicate found |
| AC7 | AC7-C3 (20 px vs WCAG 24 px) | `-016` | P1 | Accessibility exposure on the sole navigation control; the gap is already measured | `@low-confidence` (Q3 `[open]`) | no duplicate found |
| AC1+AC4+AC5 | AC-J (journey) | `-017` | P1 | Journey-level smoke; excluded from atomicity accounting and the negative ratio | inherits the above | no duplicate found |

## Conditions deliberately not generated (P3 — deferred, not vanished)

| Condition | Prio | Reason |
|---|---|---|
| AC2-C2 (640 px) | P3 | deferred, P3, not requested |
| AC2-C3 (1280 px) | P3 | deferred, P3, not requested |
| AC3-C3 (wide + drawer open) | P3 | deferred, P3, not requested |
| AC3-C4 (wide + drawer closed) | P3 | deferred, P3, not requested |
| AC4-C5 (drawer item list = 4 links) | P3 | deferred, P3, not requested |
| AC7-C1 (burger invariance 320→1280) | P3 | deferred, P3, not requested |
| AC7-C2 (cart invariance 320→1280) | P3 | deferred, P3, not requested |

No P3 condition in this set is `[req-neg]`, so the priority-scoped waiver clause of
`testbook-generate` step 5 is not exercised on this run.

## Reuse notes — D19 duplicate scan **did run** (recorded even though it found nothing)

Scanned: all 71 `.feature` files in this repository outside `node_modules`
(`find . -name '*.feature' -not -path '*/node_modules/*'`), then grepped case-insensitively for
`viewport|drawer|burger|menu|mobile|saucedemo|Swag Labs`.

- **Only one other book targets SauceDemo**:
  `eval/skill-eval-campaign-2026-07-29/US-EVAL-001-saucedemo-login/testbooks/login-gate.feature`
  (6 scenarios, `@QAIA-US-EVAL-001-001..006`).
- **No scenario in it covers any condition of this book.** Its six scenarios are all *login-form*
  cases (valid login, locked-out account, unknown username, wrong password, empty fields,
  locked-out + wrong password). None mentions a viewport, a drawer, a burger, or a guarded-route
  request; none touches the post-authentication catalogue.
- **Closest adjacency, flagged rather than silently ignored**: `US-EVAL-001-001` asserts that a
  valid login "reaches the product catalog". This run's `-010`/`-011`/`-012` assert the *inverse*
  direction (leaving the catalogue, and being refused re-entry). They are complementary, not
  duplicates — no reuse proposed.
- **Outcome: no duplicates found, 0 reuses proposed.**
- ⚠ VALIDATION on the reuse list: `pending-validation` (no user available).
