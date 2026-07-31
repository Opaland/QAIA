# feedback — run report (US-EVAL-009)

Skill: `plugins/qaia-core/skills/feedback/SKILL.md`
Run: 2026-07-30, skill-coverage wave, non-interactive (no human in session).
Target test book: `eval/skill-eval-campaign-2026-07-29/US-EVAL-009-octoperf-petstore/testbooks/`
(output root re-based per shared contract rule 9; `.qaia/` does not exist in this repo).

## Prerequisite — SATISFIED

SKILL.md L12 requires "a generated test book to compare against ... If none exists ... say so and
offer `us-ingest`". A test book exists: `octoperf-petstore-cart.feature` (8 scenarios),
`coverage-matrix.md`, `synthesis.md`. The `us-ingest` fallback branch is therefore **not** taken.

## Step 1 — Collect: both branches attempted, both blocked

SKILL.md L16 gives two ways in. Both were tried for real.

**Branch A — "Ask what the user changed or rejected in the test book".**
BLOCKED: non-interactive run, no human in session. Nothing was invented in place of an answer.
This branch is a plain question to the user, not a `⚠ VALIDATION` gate, so the shared contract's
`simulated: <default applied>` convention (README rule 3) does not formally cover it — see the
skill-defect note below.

**Branch B — "diff the edited `.feature` files against the generated version if both exist".**
ATTEMPTED FOR REAL, BLOCKED with evidence. There is no second copy of the `.feature` on disk; the
only machine-readable record of "the generated version" is
`state/generated.snapshot.md`, which stores "sha256, first 12 hex chars, per scenario block" for
the 8 scenarios. To use it, the hash definition must be reproducible. It is not:

```
$ python eval/skill-coverage-wave-2026-07-30/C-knowledge/evidence/snapshot_hash_probe.py
scenarios in snapshot: 8 | blocks parsed from feature: 8
...
ANY VARIANT REPRODUCED A RECORDED DIGEST: False
```

8 scenarios × 7 plausible content definitions (full block, block+trailing newline, CRLF, tags
stripped, comments stripped, body only, all-lines-stripped) = **56 digests computed, 0 matches**.
Full output: `evidence/snapshot_hash_probe.out.txt`.

Cross-check that the book is genuinely unedited (so a match *should* have been possible):

```
$ git status --porcelain eval/skill-eval-campaign-2026-07-29/US-EVAL-009-octoperf-petstore/
(no output — working tree clean)
$ git log --oneline -1 -- .../testbooks/octoperf-petstore-cart.feature
9555153 Campagne d'evaluation continue des skills, suite 3 (D122-D124) ...
```

Evidence: `evidence/feedback-git-status.txt`. The feature file has not been touched since the
commit that generated it, yet no reconstruction of the snapshot's own digests succeeds.

Two explanations are consistent with this evidence and **this run does not claim to know which**:
either the producing run used a hash definition outside the 7 tried (unknowable — none is
documented), or the digests were written without actually being computed. Either way the
operational consequence for `feedback` is identical and real: **branch B cannot classify a
scenario as unchanged vs. human-edited**, so it yields no corrections.

## Steps 2-6 — carried out on an empty correction set

| Step | Outcome |
|---|---|
| 2. Classify | nothing to classify — 0 corrections collected |
| 3. Store examples | `feedback/examples/` created and left **empty**. Writing a placeholder example would be a fabricated correction (D38). |
| 4. Propose promotions | none. The `≥ 2 occurrences` threshold (SKILL.md L22) is trivially unmet at 0; the "user explicitly asks" shortcut is unavailable (no user). No `⚠ VALIDATION` gate was reached, so none was simulated. |
| 5. Prune | nothing to prune (0 stored examples, none older than ~6 months) |
| 6. Close the loop | **no promoted rule will affect future generations from this run.** Stated plainly rather than dressed up: this run added nothing to the learning loop. |

`feedback/rules.md` was deliberately **not** created: SKILL.md L22 writes to it only on approval
of a promotion, and creating it empty would put a `BR-KB-nnn` counter on disk that no promotion
justifies.

## Honest verdict on this run

`feedback` executed correctly *as written* down to a null result. The null result is not a
failure of the skill's logic — it is the correct output when there are no corrections. What the
run exposes is that the skill has **no non-interactive path at all**: its entire value depends on
step 1, and step 1's only automatable branch depends on an artifact (`generated.snapshot.md`)
whose format is not specified well enough to be re-read by a different session.
