---
stepsCompleted: [00-ingest, 01-review, 02-understanding, rag-build, 03-design, prioritize, testbook-generate]
lastStep: testbook-generate
lastSaved: 2026-07-29
---

# generated.snapshot — US-007

Baseline for regeneration-mode human-edit detection (D17/C3 fix). This is the **initial generation** — no prior book existed, so every scenario below is "generated", none is "human-edited" yet.

## File-level hashes (SHA-256, initial generation)

| File | SHA-256 |
|---|---|
| `fee-enrolment-configuration.feature` | `56f16adcc9f4efe905edfba4dd60a6213cb139600a6494b6e54278acdb4beeff` |
| `fee-prompt-visibility.feature` | `0a681ae250121773f97340bda320f6b22a670725c9a5fb49eefd563870e4b144` |
| `payment-flow.feature` | `021213bce6d78ccc620913b2cc6baed0e388f5fa101fce127132b94d59b42604` |
| `enrolment-method-naming.feature` | `f4d6170e6234a9c6c3a6e43bd075b5b5bbc75e8fb132014b727e24b9b60af5ec` |

(Hashes recomputed after the emission-lint pass added a missing mandatory technique tag to scenarios 004, 013, 015, 016, 018, 021, 022, 023 — content-changing, still part of the same initial-generation pass, before any human review.)

## Scenario ID inventory (for a future scenario-level diff)

`@QAIA-US-007-001` … `@QAIA-US-007-010` (`fee-enrolment-configuration.feature`, includes one Scenario Outline at 005), `011`–`018` (`fee-prompt-visibility.feature`), `019`–`025` + `031` (`payment-flow.feature`, `031` is the `@smoke` journey), `026`–`030` (`enrolment-method-naming.feature`). No gaps in `001`–`031`; no retired IDs.
