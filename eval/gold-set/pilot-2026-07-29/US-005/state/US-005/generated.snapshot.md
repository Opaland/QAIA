---
stepsCompleted: [05-testbook-generate]
lastStep: 05-testbook-generate
lastSaved: 2026-07-29
---

# Regeneration baseline snapshot — US-005

Used by `testbook-generate`'s regeneration mode (D17) to detect human edits made to the
`.feature` files after this initial generation. Hashes are SHA-256, computed per file (this
initial-generation run has one functional area per file with no pre-existing human edits to
diff against, so a file-level fingerprint is sufficient for this baseline; a future
regeneration comparing individual scenario blocks should hash at scenario granularity if the
tooling available at that time supports it).

| File | Scenario IDs | SHA-256 |
|---|---|---|
| `disbursement.feature` | 001–006 | `13ba3e15235c4de4ae32b5dbd435af760a3e5eb79c00942bd6a7f4a9a76d520d` |
| `repayment.feature` | 007–012 | `a7d9334e2401619b381d05ba234ecdc46d52f3ec0a7837f09689eaed9172ad7c` |
| `repayment-reversal.feature` | 013–017 | `bd949d2fdc89b277022840071b20ef4a879638d151049c810be72d4733891fbf` |
| `nsf-fee.feature` | 018–022 | `9c77b187ef3895c43a8fb8c926f3948562b9f5d106db4f687c1515a92fd8eac3` |
| `refund.feature` | 023–028 | `6892a25c108e777684554ea2b8d00ce5d2dd5d9f4f5b06a10178fabf6d24696b` |
| `net-effect-invariant.feature` | 029–032 | `32178249f86eccc883389984c23ab82a99c105104f6353a407e8287452cfca9b` |
| `authorization.feature` | 033–035 | `97fc733a05d159868db90f41da9bf569fc2912d2a2e30e1f5d1ff46a3b744f1e` |
| `journey.feature` | 036 | `9115b3ef33bb024b0033e6387fec5e6ed7daf664090ef61cc1ff8719c493f976` |

No prior book existed in this output directory — this is the initial generation, not a
regeneration. ID continuity: 001→036, no gaps, no `# retired:` lines.

**Note**: `nsf-fee.feature`, `refund.feature`, `repayment-reversal.feature` and
`authorization.feature` were revised once, in-run, before this snapshot was taken —
`testbook-validate`'s structural pass (run as part of this same generation cycle, see
`reports/US-005/testbook-validate-report.md`) found four refusal scenarios per file lacked a
concrete state assertion (a refusal reason alone, no verifiable balance check). Each was
strengthened with an explicit "balance remains unchanged" `Then` line before this snapshot was
written — the hashes above are of the final, strengthened content, not an intermediate draft.
