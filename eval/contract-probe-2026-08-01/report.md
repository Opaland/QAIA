# contract-probe — first run on the nominal case (self-hosted), 2026-08-01

Issue #64, item 1. Until today `contract-probe` had exactly one real verdict, obtained against an
explicitly authorized **third party** — the exception, not the case the skill describes itself as
operating on. This is the nominal case: a self-hosted, in-repo app.

**Target**: `examples/expense-demo` (`node app/server.js`, `http://localhost:4500`).
**Authorization**: basis (a), in-repo app under `examples/` — see `contract-source.md`.
**Contract**: AC1-AC8 of `eval/gold-set/US-004-expense-approval.md`, archived verbatim in
`contract-source.md`.
**Raw run**: `probe-run.txt`. **Probe script**: `probe.sh`.

---

## Disclosure first — run 1 was misconstructed, and the report says so

The skill's disclosure rule (D127) exists for exactly what happened here, so it goes at the top
rather than in a footnote.

**Run 1 of the probe script silently tested nothing.** It built each report by `POST /api/reports`
with the line items in the creation body. That endpoint **ignores `lines`** and always creates an
empty draft (`server.js:184-190`, `lines: []` hard-coded); line items are set by a separate `PUT`.
Every probe P1-P7 therefore submitted an **empty** report and got back
`422 "a report needs at least one line item"` — a plausible-looking 422 that has nothing to do
with the promise being probed.

Had that run been written up as-is, it would have reported six promises as "kept, refused with a
422" when **not one of them was exercised**. That is the precise failure mode #64 describes from
the previous run, reproduced by me on the next one.

Two things caught it: the raw output showed the *same* error message under six different
probes, and run 1's own weaker construction check (an empty-id guard) was visibly not enough.
The script now asserts, per draft, that the lines actually landed, and prints
`DRAFT-FAILED-NOLINES:<id>` if they did not. **The results below come only from run 2**, where
every draft reported a valid state.

There is a second, smaller disclosure: **P9-P11 did not execute in run 2** (the script ended
after P8 while building a 1 MB payload in a shell variable). They were re-run separately and
their output appended to `probe-run.txt` — so they are reported, but they come from a separate
invocation rather than the main run.

---

## Findings

### CP-001 — `amount: 1e309` bypasses the positive-amount validator and produces a submitted report with a null total

**Broken promises**: AC4 ("Each line item must have a category, an amount, and a date") and
AC2 ("the converted total drives the approval threshold").

**Probe**: create a draft, `PUT` a line with `amount: 1e309`, submit.

**Observed** — reproduced **3/3**:

```
POST /api/reports/<id>/submit -> HTTP 200
{"report":{ … "status":"submitted",
            "lines":[{"category":"meal","amount":null,"date":"2026-08-01","receipt":true}],
            "totalEur":null … }}
```

**Why this is a contract violation and not merely surprising.** `1e309` exceeds IEEE-754 double
range, so the JSON parser yields `Infinity`, and serialisation turns it back into `null`. The
report is accepted into `submitted` with **`amount: null`** — while the *same validator*, given a
literal `null`, correctly refuses:

```
amount=null   -> 422 "each line needs a category, a positive amount and a date"
amount=1e309  -> 200 submitted, amount recorded as null
```

Two identical end states, two opposite verdicts. And `totalEur: null` means AC2's routing input
does not exist: the report is in the approval workflow with **no total to compare against the
€500/€5000 thresholds**.

**Severity: high.** It is the only probe of this run that put the SUT into a state its own
documented state machine cannot process, and it is reachable by a single well-formed request.

**Regression scenario**: `regression.feature`, `@QAIA-CP-001`.

---

## Promises kept (reported, not omitted)

| Promise | Probe | Observed | Verdict |
|---|---|---|---|
| AC4 — line older than 90 days blocked, with an explanatory message | line dated 200 days back | `422 "line \"travel\" dated 2026-01-13 is more than 90 days old and is blocked at submission"` | **kept** — and the message is genuinely explanatory, which AC4 requires and a bare 422 would not satisfy |
| AC5 — receipt mandatory at ≥ €25 | line at exactly €25, no receipt | `422 "line \"meal\" (EUR-equivalent 25 >= 25) requires an attached receipt"` | **kept**, inclusive at the boundary |
| AC5 — boundary below | line at €24.99, no receipt | `200 submitted` | **kept** — the threshold does not over-refuse |
| AC3 — an approver cannot approve their own report | manager submits, then decides, their own report | `403 "cannot approve your own report"` | **kept** |
| AC8 — mandatory comment ≥ 10 chars | reject with 2 chars; reject with no field; changes-requested with no field | `422` on all three | **kept**, and it covers `changes-requested`, not only rejection |
| AC7 — a rejected report is terminal | reject properly, then edit, then re-submit | `409 "only a draft report can be edited"` / `409 "only a draft report can be submitted"` | **kept** |
| AC4 — category, amount and date each required | three drafts, one field missing each | `422` on all three | **kept** |
| AC4 — amount must be positive | `"10"` (string), `-100`, `null` | `422` on all three | **kept** |
| AC3 — cross-user access (IDOR) | finance reads / edits / decides an employee's draft | `404` / `404` / `409` | **kept** — 404 rather than 403, so existence is not disclosed |
| (implicit) authentication | no token on `GET /api/reports` | `401 "unauthenticated"` | **kept** |

---

## Observations that are NOT findings

This section is the discipline the skill exists for: none of the following contradicts a
documented promise, so none is reported as a defect.

- **Truncated JSON body → `201 Created`.** `POST /api/reports` swallows the parse failure and
  creates an empty draft. Surprising, and in a production API it would be a defect — but AC1-AC8
  document **no** error-handling contract for malformed requests, so per the skill's rule 3 the
  angle is out of scope here rather than filled in with a guess. It is recorded so a human can
  decide whether to *add* the promise.
- **Form-encoded body labelled `application/json` → `201`.** Same reasoning.
- **1 MB string field → `201`.** No documented size limit; not a finding. Not pushed further: a
  size probe past this point starts to take a load shape, which the guardrail forbids.
- **`DELETE /api/reports` → `404` rather than `405`.** The distinction matters to a client, but
  no documented promise covers method semantics on this API.

---

## What was not probed, and why

- **AC2's €500 / €5000 thresholds and AC6's currency conversion.** Both are the subject of
  *planted ambiguities* in the gold set (inclusive/exclusive at the boundary, rate source). The
  contract genuinely does not settle them, so there is no promise to falsify — probing them
  would produce a finding against my own reading rather than against the documentation.
- **AC3's "skips straight to the next level up"** for a manager above €5000: same reason, its
  scope is one of the documented ambiguities.
- **AC8's "records who, when"** beyond the comment rule: the history array is populated in every
  response above, but no probe attempted to falsify the completeness of the audit trail.

## Verdict

**1 finding (high), 10 promises verified kept, 4 observations excluded as non-findings.**

The skill's hardest discipline held again on its nominal case: four real oddities were found and
correctly *not* reported as defects, because the target documents no promise about them.

Advisory only — this feeds human review, never a gate (rule 3).
