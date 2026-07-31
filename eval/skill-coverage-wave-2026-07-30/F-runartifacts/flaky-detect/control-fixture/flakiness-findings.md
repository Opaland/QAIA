# flaky-detect findings — 5 runs analyzed

Runs:
1. `plugins/qaia-playwright/skills/flaky-detect/fixture/runs/results-run1.xml`
2. `plugins/qaia-playwright/skills/flaky-detect/fixture/runs/results-run2.xml`
3. `plugins/qaia-playwright/skills/flaky-detect/fixture/runs/results-run3.xml`
4. `plugins/qaia-playwright/skills/flaky-detect/fixture/runs/results-run4.xml`
5. `plugins/qaia-playwright/skills/flaky-detect/fixture/runs/results-run5.xml`

| Test ID | Verdict sequence | Pass rate | Failing runs | Classification |
| --- | --- | --- | --- | --- |
| `@QAIA-FLAKY-DEMO-001` | fail, fail, pass, pass, fail | 2/5 | [1, 2, 5] | **flaky** |
| `@QAIA-FLAKY-DEMO-002` | pass, fail, fail, pass, fail | 2/5 | [2, 3, 5] | **flaky** |
| `@QAIA-FLAKY-DEMO-003` | fail, pass, fail, pass, pass | 3/5 | [1, 3] | **flaky** |
| `@QAIA-FLAKY-DEMO-005` | fail, fail, fail, fail, fail | 0/5 | all | consistent failure (real bug, NOT flaky) |
| `@QAIA-FLAKY-DEMO-004` | pass, pass, pass, pass, pass | 5/5 | - | no flakiness observed in 5 runs |

**3 flaky test(s) flagged.** Tests listed as "no flakiness observed in 5 runs" are NOT declared stable — absence of evidence is not evidence of absence (flaky-detect Guardrails, D38).
