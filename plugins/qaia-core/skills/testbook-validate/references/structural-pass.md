# The deterministic structural pass

## Why it runs first, and why its number never merges into the judged one

An LLM reading prose and scoring it swings by whole grades between two runs on the same file —
and swings **generously** on prose it could have written itself. A mechanical pass over structure
does not move at all.

That is the whole argument. This skill audits *any* book, including ones QAIA never generated, so
it must not skip the one pass that is immune to LLM self-indulgence — and it must not let that
pass be averaged into a judgement that is not.

## How to run it

**In Claude Code**: materialize a throwaway script implementing the algorithm below and **run
it**, for true determinism. The script is never shipped — QAIA stays 100 % skill, the same model
as Playwright generation. The maintainer's reference implementation and the proof it
discriminates are [`eval/tools/structural_score.py`](https://github.com/QAIA-Project/QAIA/blob/main/eval/tools/structural_score.py) and [`eval/baselines/structural-score.md`](https://github.com/QAIA-Project/QAIA/blob/main/eval/baselines/structural-score.md),
which **live in the QAIA source repository, not in the installed plugin**.

**Without code execution**: execute the algorithm step by step and **say so** — reproducible by
construction of the prompt, and weaker than running the code.

Run it on **every** `.feature` file collected in step 1.

## Budget /100

| Component | Points | Measured as |
|---|---:|---|
| Readability | 25 | |
| Completeness | 30 | % of ACs covered by a scenario that *really* asserts, when a source or AC list is available — otherwise % of scenarios with a real assertion |
| Coherence | 20 | no truncated step |
| Traceability | 25 | stable ID + AC link |

Bands: **PASS ≥ 80**, **CONCERNS ≥ 60**, **FAIL < 60** — or FAIL outright on a forced stop,
whatever the score.

## Detectors that force a structural FAIL regardless of score

### C1 — hollow AC

A `Then` whose only evidence is an image, table or screenshot reference. **Not counted covered.**

### C2 — no expected result

A `Then` that is empty, or that only restates success — "works", "responds correctly" — with no
verifiable value, state or status. That is a question, not a test.

### Fabrication sniffer

Technical literals (URL, host, port, id, amount) untraceable to the source or oracle when one is
provided, plus `[À DÉFINIR]` / `TODO` / placeholder markers (−5 each). **≥ 3 hits → forced STOP.**

**Feed it the source when one is available.** Pass `--source` / `--acs` explicitly, and record
the command in the report.

**If a source or matrix exists in the inputs but was not passed, the report must say the sniffer
and the completeness score ran blind.** Never print `sniffer 0` or a completeness figure as if
they had been source-checked.

Run blind, `sniffer 0` means *"nothing was compared"*, not *"nothing was fabricated"*. Printed
without that caveat it is a false negative wearing the costume of a clean result — and the books
that have a source available are exactly the ones that most deserve the check.

### Redundancy (pesticide paradox)

Near-duplicate scenarios — same `Given`/`When` shape, only a literal changed, no new assertable
behavior — reported as a finding.

**A real per-value behavioral difference is not a duplicate**: a distinct validation rule or a
distinct boundary must not be flagged as one. Flagging genuine boundary coverage as redundancy is
how this detector, applied carelessly, argues for deleting the most valuable scenarios in a book.

## Relationship to the checklist

Two numbers, reported side by side, **never averaged**.

A forced structural STOP caps the eventual gate at **FAIL** no matter how the 8-dimension
checklist scores. The structural pass can override *toward* FAIL; it never upgrades a checklist
verdict. Two gates, the stricter wins.
