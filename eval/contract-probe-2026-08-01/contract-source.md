# Archived contract source — examples/expense-demo

Captured **2026-08-01**. Required by `contract-probe`'s traceability guardrail: a live page is
not a citation. Every promise probed in `report.md` cites a line archived here, verbatim.

## Authorization basis

**Basis (a) — an in-repo app under `examples/`, self-hosted and owned by definition.** No
third-party authorization quote is needed or claimed. The SUT ran locally on
`http://localhost:4500` from `examples/expense-demo/app/server.js`; nothing external was
contacted.

This is the **nominal case** the skill describes and had never been exercised: its only prior
real run was against an explicitly authorized third party, i.e. the exception (issue #64).

## Where the contract lives

`examples/expense-demo/README.md`, line 11, states:

> The SUT implements the acceptance criteria of `eval/gold-set/US-004-expense-approval.md`
> (story + AC1-AC8 only — the file's sequestered "Judge reference" section of planted
> ambiguities was **not** given to the QAIA skills […])

So the app's documented contract is **AC1-AC8 of that file, and nothing below them**.

## The promises, verbatim

From `eval/gold-set/US-004-expense-approval.md`, `## Acceptance criteria`, lines 14-21 —
transcribed exactly as they stand at commit `c5fec90`:

| # | Promise (verbatim) |
|---|---|
| AC1 | A report moves through states: `draft` → `submitted` → (`approved` \| `rejected` \| `changes-requested`). A `changes-requested` report returns to `draft` for editing and can be re-submitted. |
| AC2 | A report under €500 total needs one approval (the employee's direct manager). €500–€5000 needs manager **then** finance. Above €5000 needs manager, finance, **then** a director. |
| AC3 | An approver cannot approve their own report; if the submitter is themselves a manager, their report skips straight to the next level up. |
| AC4 | Each line item must have a category, an amount, and a date within the last 90 days; a line outside 90 days is blocked at submission with an explanatory message. |
| AC5 | Receipts are mandatory for any single line ≥ €25; submission is refused if a ≥ €25 line has no attached receipt. |
| AC6 | Currency other than EUR is converted at the rate of the expense date; the converted total drives the approval threshold of AC2. |
| AC7 | A rejected report is terminal and cannot be edited or re-submitted; a new report must be created. |
| AC8 | Every state transition records who, when, and (for rejections and changes-requested) a mandatory comment of at least 10 characters. |

## What is deliberately NOT treated as a promise

- **Error handling for malformed requests.** AC1-AC8 say nothing about unparsable bodies, wrong
  content types, oversized payloads or unsupported methods. Per the skill's rule 3, an angle the
  target does not document is **out of scope**, not filled in with a guess. Observations on
  those angles are recorded in `report.md` under "observations, not findings".
- **The sequestered "Judge reference" section** of the gold-set file (planted ambiguities).
  Excluded by the README's own wording and by gold-set protocol.

  **Disclosure**: while locating the AC block, a `grep` for `AC[1-8]` incidentally printed four
  lines of that sequestered section to my terminal. It was **not** used to construct any probe —
  every probe above cites an AC, and the planted ambiguities concern boundary *interpretation*
  (inclusive/exclusive at €500, skip-level scope, rate source) which no probe here touches. It
  is recorded because a run that silently absorbs sequestered material is exactly what the
  gold-set protocol exists to prevent, and a prior run was invalidated for that reason (D107).
