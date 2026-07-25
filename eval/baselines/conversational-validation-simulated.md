# Conversational validation — simulated persona run (US-004, issue #5)

- Date: 2026-07-25. Gold set item: `eval/gold-set/US-004-expense-approval.md` (finance/HR,
  state-machine + decision-table heavy — not used in any prior baseline in `eval/baselines/`).
- Model: this session's Claude agent, playing **two roles**: (1) the QAIA skills, run
  faithfully step by step from their `SKILL.md` (`us-ingest` → `us-review` →
  `need-understanding` → `istqb-design` → `prioritize` → `testbook-generate`); (2) a
  **simulated QA-tester persona** arbitrating every ⚠ VALIDATION point in that journey.
- Gherkin lint: **pass**, `gherkin-lint@4.2.4`, repo config (`.gherkin-lintrc`), on all 5
  `.feature` files in `conversational-validation-simulated-testbook/`.

## Why this run exists

Every existing QAIA baseline (`0.1.0-US-001.md`, `0.1.2-goldset.md`, `multi-judge-median.md`,
`corpus-24-depth.md`, …) runs the journey in **non-interactive mode**: every ⚠ VALIDATION point
gets `simulated: <default applied>`, i.e. the skill's own proposed default, auto-accepted.
That mode is explicitly flagged as a gap in `0.1.0-US-001.md`'s deviation log: *"the
conversational validation path is NOT covered by this baseline and must be exercised by the
pilots (gate G2)."* Gate G2 has since been lifted (D67) but no human pilot tester has been
available. Issue #5 (P1) asks for the next-best thing: a **simulated but honest** exercise of
the real path, where a human-like tester actually pushes back — not a second non-interactive
run wearing a costume.

**What "simulated but honest" means here, concretely:** at each ⚠ VALIDATION point, I first
worked out what the skill's own proposed default would be (the exact thing a non-interactive
run would auto-accept — this is the counterfactual baseline), *then* switched into the
tester persona and decided independently whether to accept it, correct it, or answer a
genuinely open question the skill had no default for. The persona's reactions were decided
before I let myself "look ahead" at how the rest of the pipeline would consume the answer, to
avoid retrofitting agreeable answers that happen to make the downstream design simpler.

## The persona

**Explicitly simulated — not a real, independent human tester.** A composite of traits a real
QAIA pilot would plausibly have on a finance/HR expense-approval feature: familiar with
approval-workflow patterns (segregation of duties, audit trails), skeptical of vague
"skip to the next level" language, and reflexively checks whether an answer she gave earlier
actually made it into the delivered book. She is not a rubber stamp: across the six steps she
raised **8 explicit objections/corrections** and independently **answered 3 genuinely open
questions** the skill had no proposed default for (see below). She also accepted a majority of
proposals as-is — a persona who contests everything is just as unrealistic, and useless as a
retention-rate signal, as one who contests nothing.

**Honest limitation stated up front:** this is one agent role-playing a tester's reactions in
a single pass, not an independent human with real domain stakes, fatigue, or the tendency to
miss things a machine-generated proposal doesn't. Treat everything below as an **informative
signal about whether the pipeline can absorb real disagreement without breaking**, not as
proof that a real tester would raise the same objections, or any objections at all.

## Walkthrough

### 1. `us-ingest`

Source: the "User story" + "Acceptance criteria" sections of the gold-set file only — the
"Judge reference — planted ambiguities" section was **not** read into the ingestion pass (used
afterward, only to compare what the process found on its own against the gold-set's ground
truth, same convention as every other gold-set baseline). No PII, no abuse framing, single
story — no triage gate fires. US-ID proposed: `US-004`.

- ⚠ VALIDATION (US-ID): persona confirms `US-004` — no objection, unremarkable.
- ⚠ VALIDATION (right document/version): persona confirms — no objection.

### 2. `us-review`

Extraction: story + AC1–AC8 as numbered in the source, no business rules found outside the AC
list, no unclassified content, no referenced-but-unanalyzed attachments.

**Objection 1 (structural).** The skill's first extraction kept AC8 as one item ("every state
transition records who/when, and rejections/changes-requested need a ≥10-char comment"). The
persona pushed back: *"That's two testable rules bundled under one AC number — an always-on
audit-log requirement and a conditional comment-validation requirement. If you keep them as one
AC, every downstream `@AC8` tag conflates a pass on the log with a pass on the comment rule,
and I won't be able to tell from the coverage matrix which one a failing scenario is about.
Split it."* The skill re-split the extraction into **AC8a** (audit fields on every transition)
and **AC8b** (mandatory comment on rejection/changes-requested) before writing the checkpoint —
i.e. before the "never renumber after validation" rule locks in, per `us-review`'s own
guardrail. All 8 source AC are still covered; nothing was merged away or dropped.

- ⚠ VALIDATION (extraction confirm/correct): **corrected** (the AC8 split above).

### 3. `need-understanding`

The ambiguity hunt (undefined terms, cross-AC pass, triple-AC pass, state-machine re-entrance
check) surfaced 11 questions across two passes (8 first pass, 3 lower-impact second pass, per
the skill's own "max ~10 per pass" guardrail). Full log in
`conversational-validation-simulated-testbook/synthesis.md`. Three are worth walking through
in detail because they show different kinds of real tester behavior — correcting a wrong
guess, clarifying instead of flatly rejecting, and partially agreeing:

**Objection 2 — Q1 (threshold inclusivity, AC2/AC6).** Per the classification tree, a
money-policy point with the source silent should be `[open]`, not silently defaulted. The
skill proposed leaving it open and generating the boundary scenarios `@low-confidence` on an
unstated guess. The persona didn't leave it hanging: *"I can answer this one — it's not a
judgment call, it's just how our tier notation is normally read: '€500–€5000' is inclusive of
both ends. A report of exactly €500.00 needs finance; exactly €5000.00 needs a director."*
This converts Q1 from `[open]` to **answered**, and firms up the confidence of every scenario
built on it (AC2-C2/C4, `@QAIA-US004-011`).

**Objection 3 — Q2 ("skip to the next level up", AC3).** The gold set's planted ambiguity.
The skill's first pass read "next level up" as skipping the *entire* remaining chain up to the
top (manager submits >€5000 own report → only director approval, finance skipped too) — a
plausible but wrong literal reading. The persona objected directly: *"No. 'Next level up'
means skip the self-approval step only — finance approval is a separate, amount-driven control,
unrelated to who submitted the report. A manager's own €7,300 report still needs finance AND
director; it just doesn't need the manager."* This is the clearest case of the skill's proposed
default being **substantively wrong**, not merely underspecified — Q2 answered, and it directly
rewrites `@QAIA-US004-012`.

**Objection 4 (partial) — Q4 (FX rate on non-trading days, AC6).** The skill proposed:
previous-business-day's closing rate as the fallback (safe, standard accounting practice) —
persona **accepted that part**. But she didn't stop there: *"Fine on the fallback logic. But
you haven't said whose rate — ECB reference, our bank's own rate, an API? That's a real
operational question, not a formality — flag it open for Finance, don't just assume."* Result:
Q4 (fallback mechanism) → assumption, accepted as-is; **Q4b (rate source) stays `[open]`**,
newly split out at her request rather than swallowed into Q4's assumption.

**Genuine open-item arbitration — Q3 (AC1 × AC7 interaction).** Per the classification tree
this is a genuine product decision with no safe default, so the skill correctly left it
`[open]` with *no* proposed default at all (not a wrong-guess case — the skill did the right
thing by not guessing). The persona supplied the real answer from her own domain read: *"A
changes-requested report going back to draft isn't a protected state — it's just draft with
history. Once it's re-submitted, the normal chain applies, and yes, any approver in that chain
can still reject it."* This is exactly the "human answers what only a human can answer" case
the skill is designed to defer to.

The remaining 7 questions (Q5–Q11: 90-day clock reference, receipt format, re-submission
restarting approval, comment-per-action, approved-terminality, partial-block-on-invalid-line,
receipt threshold on converted amount) were reviewed and **accepted as proposed** — the
persona judged the defaults reasonable and not worth contesting, which is itself part of a
realistic tester's behavior (not every default is worth a fight).

- ⚠ VALIDATION (per question, ×11): 3 **answered by correction/objection** (Q1, Q2, Q3-answer),
  1 **split** (Q4/Q4b), 7 **accepted as proposed**.

### 4. `istqb-design`

The skill's first technique map treated AC2 (boundary value analysis), AC3 (decision table)
and AC6 (equivalence partitioning) as **three independent items**.

**Objection 5.** The persona objected to the map itself, not a value inside it: *"You just
told me in the understanding phase that AC2, AC3 and AC6 interact — a converted amount from
AC6 decides the AC2 tier, and AC3 changes who's in the chain. If you design these as three
separate techniques, you'll design three separate condition sets and miss exactly the
interaction cases you already flagged (Q1, Q2, Q4). Merge them into one cross-cutting decision
table: amount tier × currency conversion × self-approval."* The skill agreed and produced the
unified table now in `approval-routing.feature` — this is what directly produced the **added**
conditions AC2-C8 (currency crossing a tier boundary) and AC3-C2 (finance-role self-approval,
an extension the persona later let stand as `[assumption]`/low-confidence rather than pushing
for a full answer).

- ⚠ VALIDATION (technique map amend/approve): **amended** (AC2/AC3/AC6 merged).

### 5. `prioritize`

Two direct score overrides, in opposite directions — deliberately not a one-way "always
escalate" pattern, which would itself be a form of rubber-stamping:

**Objection 6 (upgrade).** Skill proposed AC5-C2/C3 (missing receipt on a ≥€25 line) as
impact 2 / probability 2 = **P2**. Persona: *"That's not degraded service, that's a
reimbursement-fraud control. The story's own 'so that ... the company keeps an auditable
trail' line is exactly what this rule protects. Impact 3, not 2 — P1."*

**Objection 7 (downgrade).** Skill proposed AC2-C9 (no FX rate on a weekend/holiday) as
impact 3 / probability 2 = **P1**, treating it as money-policy-critical. Persona: *"Disagree in
the other direction here — the fallback always resolves to a valid rate, so the worst case is
a slightly-off conversion, not a blocked or mis-routed report. That's real but it's not in the
same risk class as the routing-correctness items. Impact 2, still P2 — don't dilute the P1
bucket with something that degrades gracefully."*

- ⚠ VALIDATION (score table adjust/approve): **adjusted** ×2 (AC5-C2/C3 up, AC2-C9 down); all
  other proposed scores approved as-is.

### 6. `testbook-generate`

Duplicate scan against `.qaia/testbooks/` and `eval/gold-set/`: no prior US-004 book exists,
nothing to reuse — trivial, no objection. Scenarios generated per AC (34 blocks, 33 atomic +
1 `@smoke`), self-checks run (negative-path gate, one-`When`-per-scenario, literal values
verified by computation, `Background` invariant check, ID continuity) — all pass.

**Objection 8 (final review).** At the synthesis ⚠ VALIDATION, the persona didn't just skim
counts — she checked her own earlier answer got implemented: *"I answered your Q3 question
back in `need-understanding` — that a changes-requested → draft → re-submitted report isn't
protected and can still be rejected. I don't see a scenario that actually proves that. You have
the first-cycle rejection tested, but not a second-cycle one. Add it — otherwise my answer is a
decision on paper, not something that's actually checked."* This produced
`@QAIA-US004-009`, added after the rest of the book was otherwise complete.

- ⚠ VALIDATION (duplicate-reuse list): approved, empty list, no objection.
- ⚠ VALIDATION (synthesis review): **corrected** — one scenario added (009).

## Retention measurement (issue #5 acceptance criterion)

Final book: **34 scenario blocks** (33 atomic + 1 `@smoke` journey). For each, I compared its
content against what the skill's own first proposal would have produced under non-interactive
defaults (the exact counterfactual a `simulated: <default applied>` run would have shipped),
using the classification recorded per-scenario in
`conversational-validation-simulated-testbook/coverage-matrix.md`:

| Status | Count | % of book |
|---|---|---|
| Kept, unchanged content **and** priority | 26 | 76.5 % |
| Kept content, priority corrected only | 2 | 5.9 % |
| Rewritten (Given/When/Then or expected outcome changed) | 3 | 8.8 % |
| Added (did not exist in the naive/auto-confirm draft at all) | 3 | 8.8 % |

**Headline retention rate (content-level, "sans réécriture majeure"): 28 / 34 = 82.4 %** of
the final book's scenario content shipped exactly as the skill first proposed it — the persona's
role was to approve, not to reinvent, most of the pipeline's own output. **6 / 34 = 17.6 %**
required a content change or a net-new scenario directly traceable to one of the 8 objections
above. Separately, 2 more scenarios (5.9 %) kept their content but had their priority tag
corrected — a real intervention, but not a "rewrite" in the strict sense the issue's acceptance
criterion asks about, so reported as its own line rather than folded into either bucket.

**Reading this number:** 82 % retention is not evidence the conversational path is
low-value — the 18 % that changed are concentrated exactly where the gold set planted its
ambiguities (AC2/AC3/AC6 threshold and self-approval interactions: objections 2, 3, 5 account
for 5 of the 6 rewritten/added scenarios) and where a compliance-relevant priority call was
genuinely debatable (objection 6). A retention rate near 100 % would be the concerning result —
it would mean the human-in-the-loop step wasn't doing anything a non-interactive run couldn't.
A rate this far below 100 %, concentrated on the AC that the gold set deliberately made
ambiguous, is closer to the signal issue #5 is actually asking for.

## Honest reservation (mandatory, not decorative)

**This is a simulation by a single agent playing a tester role, in one pass, in the same
session that ran the skills being tested. It is not a substitute for a real, independent human
pilot exercising the conversational path.** Specific ways this differs from — and likely
flatters — a real conversational validation:

- **No adversarial distance.** The same agent that generated the skill's proposals decided
  whether to object to them. A real tester's objections come from independent domain
  experience and often from *not* having read the skill's own reasoning first; I designed the
  "naive default" and the "persona reaction" in the same continuous pass, which risks the
  persona's objections being shaped by knowing what the skill was about to propose next,
  even though I deliberately front-loaded the naive-default decision before switching roles.
- **No fatigue, distraction, or impatience.** A real tester reviewing 11 questions and a
  34-scenario coverage matrix in one sitting skims, misses things, or approves something they'd
  object to on a second look. This run has none of that noise — it is a best-case interaction,
  not an average one.
- **No conflicting stakeholder pressure.** Real approval-workflow requirements often surface
  disagreement *between* humans (finance vs. engineering vs. compliance), not just between a
  tester and a proposed default. This run only exercises one voice.
- **The objections were designed to be plausible, not sampled from a real person.** They are
  grounded in the domain (segregation of duties, audit-trail rationale, FX-fallback reasoning)
  and deliberately include both upgrades and downgrades to avoid a one-directional bias, but
  they remain authored, not elicited.
- **Retention rate is not directly comparable across US or across runs** without controlling
  for how deliberately ambiguous the source is — US-004's gold-set notes explicitly plant
  boundary and self-approval ambiguities, so a lower retention rate here is partly a function
  of the fixture, not purely of the persona's rigor.

**Bottom line:** this run demonstrates that the QAIA pipeline *can* absorb genuine human
disagreement at every ⚠ VALIDATION point — corrections propagate (Q2 → AC2-C6 routing, `[open]`
stays `[open]` when warranted, priorities move in both directions, a missed regression scenario
gets caught and added) — without the journey breaking or silently discarding the correction.
It is informative evidence that the mechanism works. **It does not close gate G2's underlying
need for a real, independent human pilot**, and should not be cited as if it did.

## Artifacts

- `conversational-validation-simulated-testbook/lifecycle.feature` — AC1/AC7, 9 blocks + `@smoke`
- `conversational-validation-simulated-testbook/approval-routing.feature` — AC2/AC3/AC6, 7 blocks
- `conversational-validation-simulated-testbook/line-items.feature` — AC4, 6 blocks
- `conversational-validation-simulated-testbook/receipts.feature` — AC5/AC6, 6 blocks
- `conversational-validation-simulated-testbook/audit.feature` — AC8a/AC8b, 5 blocks
- `conversational-validation-simulated-testbook/coverage-matrix.md` — full AC → condition →
  scenario → priority → confidence → retention-status table
- `conversational-validation-simulated-testbook/synthesis.md` — counts, full Q&A log, ratio,
  by-technique table
