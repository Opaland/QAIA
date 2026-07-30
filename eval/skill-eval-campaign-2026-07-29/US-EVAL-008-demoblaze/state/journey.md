# journey — US-EVAL-008

| Step | Status | Note |
|---|---|---|
| 00-ingest | done | gates checked, primary-source grounded (direct `GET` of the served HTML +
  linked JS of `index.html`/`prod.html`/`cart.html`, no write request sent against the shared
  demo) |
| 01-review | done | ⚠ simulated: accepted-as-is — story `[reconstructed]` (no story phrasing in
  source), AC1..AC9 |
| 02-understanding | done | ⚠ simulated: accepted-as-is — Q1/Q2 `[assumption]`, Q3 `[open]`
  (genuine classification diversity, not all converged to one band) |
| 03-design | done | ⚠ simulated: accepted-as-is — 21 conditions across a state × event table
  (CT-MBT discipline), a real non-zero but deliberately capped `[req-neg]` set (5 conditions,
  `AC3-C1` explicitly excluded with a stated reason rather than padded or silently dropped) |
| 04-priorities | done | not yet human-arbitrated — 2 P1, 8 P2, 11 P3 (P3 deferred by default
  scope; standing `[req-neg]` waiver on `AC7-C1`/`AC7-C2`, both P3) |
| 05-testbook-generate | done | 10 scenario blocks (P1+P2 scope, 10/21 conditions), negative ratio
  **30%** (honest — below the 40% target, explained rather than padded: only 3/5 in-scope
  `[req-neg]` conditions), `reports/manifest.json` written and schema-validated
  (`eval/tools/validate_manifest.py` → **PASS**) |
| 06-testbook-validate | done | real script execution — structural **CONCERNS** (78/100, below
  the 80 threshold — driven by 4 deliberately P3-deferred ACs contributing zero completeness),
  checklist **PASS** (15/16) → **overall gate: CONCERNS** (stricter of the two wins); no Gherkin
  defect found, no file modified |

**Skill defects found and fixed in this run**: none — all six skills run in this journey
(`us-ingest`, `us-review`, `need-understanding`, `istqb-design`, `prioritize`,
`testbook-generate`, `testbook-validate`) evaluated **CONFORME** by an independently-briefed
evaluator agent with no visibility into this journey's own reasoning, per the campaign prompt's
protocol — see each checkpoint's own "## Skill evaluation" section for the citation-backed
verdict.

**Genuinely different flavor from prior campaign runs**: unlike `US-EVAL-006` (all three
`need-understanding` questions classified `[assumption]`, an honest-zero `[req-neg]` design), this
run produced real classification **diversity** (2 `[assumption]`, 1 genuine `[open]` on `AC8-C3`/
Q3 — whether guest checkout is intended policy) and a real, **non-zero but deliberately capped**
`[req-neg]` set (`AC3-C1` explicitly excluded from `[req-neg]` despite being adjacent to error
handling, because this capture's read-only discipline cannot force the live error condition it
would need to assert a refusal). The overall gate (structural CONCERNS, checklist PASS →
CONCERNS) matches `US-EVAL-006`'s pattern, for a structurally different reason each time (there:
risk concentrated in one AC; here: 4/9 ACs entirely P3-deferred by design, plus a 3-way redundancy
false-flag on the decision-table cluster instead of a 2-way one).

**Target-specific note (per this run's own brief)**: DemoBlaze's catalog row
(`docs/DEMO-TARGETS.md`) forbids `perf-check`/`security-surface` on this shared public demo — no
such skill was invoked anywhere in this journey. A real, source-grounded security-surface
candidate *was* found (`03-design.md`'s 3c pass: the guest cart identifier is a raw,
client-readable `document.cookie` GUID, not a server-issued token — a plausible IDOR shape) and
explicitly **not** exercised, flagged instead as a gap for a `security-surface` run against a
self-hosted target.

**⚠ ARRÊT — next step is the human Go/No-Go gate before any automation (step 8 of the campaign
prompt), per `docs/SKILL-EVAL-CAMPAIGN-PROMPT.md`. Not simulated. Awaiting the user. No
automation (`automate`, `a11y-audit`, `perf-check`, `security-surface`, `contract-probe`) has been
run or scheduled by this session.**
