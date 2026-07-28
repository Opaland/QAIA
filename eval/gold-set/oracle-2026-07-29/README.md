# Real-world oracles — 2026-07-29 pilot campaign

Raw `.feature` files fetched verbatim from real open-source products, kept here **only** as a
held-out evaluator oracle for recall comparison against QAIA-generated test books — never fed
to any generation skill. Same provenance-and-fair-use posture as the GitLab CE/Diaspora
real-case fixtures used in the earlier corpus-24 campaign (`eval/goldset-hardened/`).

| File | Source | License | Fetched |
|---|---|---|---|
| `fineract-loanproduct-raw.feature` | [`apache/fineract`](https://github.com/apache/fineract), `fineract-e2e-tests-runner/src/test/resources/features/LoanProduct.feature` | Apache-2.0 | 2026-07-29 |
| `ushahidi-acl-raw.feature` | [`ushahidi/platform`](https://github.com/ushahidi/platform), `tests/Integration/acl.feature` | GPL-3.0 | 2026-07-29 |
| `moodle-fee-raw.feature` | [`moodle/moodle`](https://github.com/moodle/moodle), `public/enrol/fee/tests/behat/fee.feature` | GPL-3.0 | 2026-07-29 |

Each file's license is preserved as-is with its original source; these excerpts are reproduced
for non-commercial software-testing research/evaluation purposes only (comparing generated
test coverage against real human-authored acceptance tests), not redistributed as part of the
QAIA product itself (QAIA's own code remains MIT-licensed, unaffected).

The corresponding derived tickets (`eval/gold-set/US-005-loan-servicing.md`,
`US-006-post-visibility-acl.md`, `US-007-course-fee-enrolment.md`) are QAIA's own
business-language paraphrase of what these scenarios test — not copies of their Gherkin steps
or test data — written to be fed to QAIA's generation skills without ever exposing the literal
oracle content.
