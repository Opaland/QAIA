# QAIA evaluation harness

Built **before** any generation skill (decision T10). No skill change ships without running this harness.

## Why it exists

Skills are LLM prompts: their behavior is non-deterministic and drifts with every model release. CI validates form only (manifests, Gherkin syntax); this harness is the only thing that measures **quality** — and quality regressions are otherwise silent.

## Contents

| Path | Content |
|---|---|
| `gold-set/` | Original, synthetic user stories (clean-room, MIT-licensed) used as fixed inputs |
| `RUBRIC.md` | The scoring rubric an LLM-judge applies to a generated test book |
| `baselines/` | Scored reference runs per release (created from M1 onward) |

## Release ritual (runs in the maintainer's Claude session — decision D6)

1. For each gold set US, run the generation journey end-to-end with the candidate skills — **3 independent runs per US** (non-determinism: we score the median, and flag any dimension with a spread > 1 point).
2. Score each generated test book with `RUBRIC.md` using an LLM-judge in a **fresh session** (no context from the generation session).
3. Compare medians to the previous baseline in `baselines/`. Any dimension dropping ≥ 1 point blocks the release.
4. Commit the new scores to `baselines/` with the plugin versions and model used.

## Contributing to the gold set

New gold set US are very welcome (easier to review than skills — see `CONTRIBUTING.md`). Requirements: original content (no material from an employer or a copyrighted spec), realistic acceptance criteria (6+), at least one deliberately ambiguous point (to exercise `need-understanding`), and domain variety — regulated-health flavored stories are especially valuable (project niche).
