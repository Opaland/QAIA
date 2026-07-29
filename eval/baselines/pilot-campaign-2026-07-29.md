# Multi-domain pilot validation campaign — 2026-07-29

## What this is

Three fresh, previously-unused business tickets (fintech, civic-tech, education), each derived
from a real open-source product's own test suite, run end-to-end through QAIA's full 11-step
journey (`us-ingest` → `us-review` → `need-understanding` → `rag-build` → `istqb-design` →
`oracle-generate` → `prioritize` → `testbook-generate` → `report` → `testbook-export` →
`testbook-validate`, non-interactively). The generated test books are then compared against the
real product's own held-out Gherkin scenarios (the "oracle") — a scenario QAIA never saw — to
measure recall (did QAIA reinvent the same business rules a real team already tested?) and to
surface any reproducible defects in QAIA's own tooling. Full methodology and provenance in
`eval/gold-set/oracle-2026-07-29/README.md`.

Tickets and oracles:

| US | Domain | Oracle | Generated |
|---|---|---|---|
| US-005 | Fintech loan servicing | `apache/fineract` LoanProduct.feature (Scenario1-10) | `eval/gold-set/pilot-2026-07-29/US-005/` — 36 scenarios |
| US-006 | Civic-tech ACL | `ushahidi/platform` acl.feature | `eval/gold-set/pilot-2026-07-29/US-006/` — 23 scenarios |
| US-007 | Education fee enrolment | `moodle/moodle` fee.feature | `eval/gold-set/pilot-2026-07-29/US-007/` — 31 scenarios |

Each run happened in an isolated git worktree, blind to its oracle (agents were instructed never
to open the oracle file and to stop if they accidentally saw it — none did, and none needed to:
each ticket's input file was self-sufficient).

## Recall: did QAIA find the same business rules a real team already tests?

**US-005 (fintech).** The oracle's 10 core scenarios (C52-C62) are single-thread narratives
(disburse → repay → maybe reverse → maybe NSF fee → maybe refund → maybe un-reverse, chained).
QAIA doesn't reproduce them as narratives — it decomposes them into the same underlying rules as
atomic scenarios: single/multi-tranche disbursement (oracle Scenario1-4 ↔ QAIA `disbursement.feature`),
repayment reversal + NSF fee (Scenario5-7 ↔ `repayment-reversal.feature` + `nsf-fee.feature`), refund
and refund-reversal (Scenario8-10 ↔ `refund.feature`), and the multi-order interleaving the oracle's
Scenario9-10 exercise (↔ `net-effect-invariant.feature`, including a metamorphic "reverse in the
opposite order" case the oracle never states explicitly). Every business rule in the 10 core oracle
scenarios has a QAIA counterpart. The oracle's remaining scenarios (charge-off reason enumeration,
`interestRecognitionOnDisbursementDate` flag, buy-down fees, tranche-config table) are Fineract
configuration surface, correctly out of scope per the ticket's own stated exclusion.

**US-006 (civic-tech).** The oracle file covers far more surface than this ticket's 6 AC (forms,
stages, tags, data providers, collections, CSV import — all out of scope by design). Restricted to
the AC's actual scope (field-locking, author-identity locking, post-status visibility, private-mode
deployment, media-deletion ownership), QAIA's 23 scenarios recall essentially all of it: locked-field
hiding vs. visible fields (oracle's `test_field_locking_hidden_3`/`visible_4` ↔ QAIA-006/007-008),
author-field locking for anon/basic vs. manager/admin (oracle's author_realname/email checks ↔
QAIA-009/010), private-mode anonymous lockout (oracle's `@private` tag scenarios ↔ QAIA-012-015),
registration-disabled (oracle's `@disableRegistration` ↔ QAIA-017-018), and media deletion by owner
vs. non-owner vs. admin (oracle's Media scenarios ↔ QAIA-019-021).

**US-007 (education).** The oracle is a small, focused 3-scenario Behat suite. All 3 are recalled:
the fee prompt with exact amount + PayPal-style method selection + cancel (↔
`fee-prompt-visibility.feature` + `payment-flow.feature`), the guest login-prompt-not-payment-prompt
behavior (↔ same files), and the custom-instance-name rename (↔ `enrolment-method-naming.feature`).
QAIA additionally covers configuration validation, declined payments, and a full anonymous→enrolled
journey that the oracle's narrow Behat sample doesn't test.

**Bottom line:** across all three, zero core business rules present in the oracle were missed by
QAIA's generation. This is the headline result of the campaign.

## One honest discrepancy worth flagging (not a QAIA defect)

US-007's own gold-set ticket (AC5) states the manager's management view "can still see it was
built from the default method" after a custom rename. QAIA generated `QAIA-US-007-029` exactly to
that wording. Re-reading the real Moodle oracle scenario after the fact, its actual assertion is
narrower ("I should not see 'Enrolment on payment' in the 'Lifetime access' table_row") — it
doesn't clearly establish that the manager's list view retains a separate origin indicator; it's
ambiguous from that one Behat check alone. This is a possible over-statement introduced when *I*
paraphrased the oracle into the ticket's AC, not a QAIA generation defect — QAIA correctly tested
the AC exactly as written. Recorded here rather than quietly corrected, per the project's
anti-fabrication discipline (D38): the ticket wording stands as originally written since it's a
defensible reading, not proven wrong, but the ambiguity is real and worth a human's eyes if this
ticket is ever reused.

## Real defects found and fixed (dogfooding the new MCP-bridge tools)

Every generated `.feature` and `manifest.json` was scored with the new `mcp-bridge` tools
(`score_feature` / `validate_manifest`, wrapping `eval/tools/structural_score.py` and
`validate_manifest.py` — the same scorer/validator QAIA itself uses), per the instruction to use
"les tools mis à disposition sur la plateforme." Three genuine, reproducible defects surfaced:

1. **`structural_score.py`'s marker detector false-positived on legitimate test data.** ISO 4217's
   reserved "no currency" code is literally `"XXX"`; the ambiguity/placeholder detector (built to
   catch `TODO`/`FIXME`/unresolved-marker prose) flagged it as an unresolved placeholder, dropping
   `US-007/fee-enrolment-configuration.feature` to a FAIL gate. Fixed: quoted `"XXX"`/`"TBD"`
   occurrences (business data) are now excluded before marker detection; unquoted ones (genuine
   prose placeholders) are still caught.
2. **`structural_score.py`'s `TECHNIQUE_TAGS` constant was stale against the current
   `istqb-design` technique palette** (D109's reorganization added `@crud`, `@metamorphic`,
   `@domain-analysis`, and CT-AI's `@ai-feature`, none of which the scorer recognized — it flagged
   correctly-tagged scenarios as having the wrong tag count). Independently caught by two of the
   three pilot agents. Fixed: the constant now matches the actual palette in use across the repo.
3. **The output-contract schema had no `artifacts[].kind` value for `testbook-validate`'s own
   report**, and one pilot run wrote `"gate": null` instead of omitting the key (the contract
   treats absence, not `null`, as "not yet scored"). Fixed: added `"validation"` to the schema's
   and `validate_manifest.py`'s enum (+ an example in `docs/OUTPUT-CONTRACT.md`), tightened the
   `report` skill's wording to say "omit `gate` entirely," and corrected the one non-conformant
   manifest in place.

After these three fixes, all three pilots' manifests validate cleanly (were 1 FAIL, 2 PASS → now
3 PASS) and no `.feature` file gates FAIL (was 1 FAIL, 2 CONCERNS, 5 PASS → now 0 FAIL, 3 CONCERNS,
9 PASS). The remaining CONCERNS (redundancy near-duplicate groups on US-006 and US-007) are real
structural findings, not scorer bugs — left as-is, they're accurate signal, not something to
paper over.

## What this campaign does NOT prove

- Only 3 tickets, one each per domain — not a statistically powered sample.
- The oracles themselves are narrow Behat/Gherkin excerpts (Ushahidi's especially), not the full
  acceptance-test suite of each product — recall against a broader oracle could differ.
- No execution/gate scoring by `qaia-score` (out of this pilot's scope — these are freshly
  generated books, never run against a live SUT).
- The one AC5 wording discrepancy above means at least one ticket's own fidelity to its source is
  imperfect — a reminder that gold-set derivation is itself a step that can introduce drift.
