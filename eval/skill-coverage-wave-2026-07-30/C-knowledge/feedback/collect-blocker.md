# feedback step 1 (Collect) — BLOCKER, with proof

`feedback/SKILL.md` step 1 offers exactly two ways to collect corrections:

> "Ask what the user changed or rejected in the test book (**or** diff the edited `.feature` files
> against the generated version if both exist)."

Both are blocked in this run. Neither was worked around by inventing corrections (D38).

## Path A — ask the user: BLOCKED (no human)

This is a non-interactive skill-coverage run. Per `skills/README.md` rule 3, the recorded status
is `simulated: <default applied>`; the default applied here is **"no human corrections exist"**.
Fabricating tester corrections to have something to classify would be the exact defect D38 forbids.

## Path B — diff edited vs. generated: BLOCKED (baseline not reproducible)

The prerequisite artifact exists — `testbook-generate/SKILL.md` line 38 writes
`state/<US-ID>/generated.snapshot.md` with "scenario IDs + content hash per scenario" — and
US-EVAL-009 has one, with 8 IDs matching the 8 scenarios in the book exactly.

But the hash convention is never specified (no algorithm, no block boundaries, no normalization).
`evidence/diff_vs_snapshot.py` tried five plausible definitions of a "scenario block" against
sha256[:12]; **all five produced 0/8 matches**. Verbatim output in
`evidence/diff_vs_snapshot.out.txt`:

```
scenarios in feature: 8 | ids in snapshot: 8
id sets equal: True

variant raw block (\n, trailing blanks kept)     -> 0/8 ids match
variant block rstripped of blank lines           -> 0/8 ids match
variant block, comments+tags stripped            -> 0/8 ids match
variant block, whitespace-normalized             -> 0/8 ids match
variant raw block + trailing newline             -> 0/8 ids match
```

Consequence: an independent agent cannot tell "the book is unedited" from "the hashes were
computed a different way". The diff path is therefore unusable here, and the same gap disables
`testbook-generate`'s own regeneration mode (line 46: "compare the current book against
`state/<US-ID>/generated.snapshot.md` (hashes) — scenarios differing from the snapshot are
human-edited").

## What was done instead (declared, not disguised)

The only real, non-fabricated correction material available is the **machine audit** of the book:
the deterministic `structural_score.py` findings and the `testbook-validate` checklist, both from
a real prior run. Two examples were stored from it, each explicitly tagged
`Machine-audit provenance, NOT a human tester correction`, and neither is treated as eligible for
promotion. Status: **pending-validation**.
