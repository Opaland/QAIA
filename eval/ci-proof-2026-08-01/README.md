# Real-CI proof for a QAIA-generated suite — issue #60 (2026-08-01)

Raw evidence kept per rule 4bis: every number quoted as measured elsewhere in the project about
this run points here.

## What #60 asked

> Aucun test généré par QAIA n'a jamais tourné dans une vraie CI.

The automation layer's central promise is that generated tests **survive QAIA** — they run in
the user's CI with no dependency on QAIA or a Claude session. Until today no machine other than
the session that wrote the tests had ever executed them. That made the promise an assertion, and
this project has measured that roughly a third of its unverified assertions turn out false.

## Files here

| File | What it is |
|---|---|
| `oracle-probe-saucedemo.txt` | Live error-banner text for 7 credential combinations against `saucedemo.com`, captured 2026-08-01. The oracle that resolved Q2 and Q3. |
| `local-run-after-correction.txt` | The generated suite run locally after the Q2/Q3 corrections: 8 passed. |
| `github-actions-run.md` | The GitHub Actions run of the same suite — the actual answer to #60. |

The pre-correction local run (7 passed / 1 failed) is not duplicated here: it is the campaign's
own preserved artifact, `../skill-eval-campaign-2026-07-29/US-EVAL-001-saucedemo-login/automation/tests/results.json`,
left untouched.

## What the failure turned out to be

The single failing test was **not** a CI defect. `QAIA-US-EVAL-001-006` encoded a *proposed
default* that the test book itself had marked `[open]`/`@low-confidence`, and the spec carried a
comment predicting that a failure there would be the answer to the open question. It was:

```
Q3  locked_out_user + wrong password  -> "Epic sadface: Username and password do not match any user in this service"
Q3b locked_out_user + right password  -> "Epic sadface: Sorry, this user has been locked out."
```

**Credentials are validated before lock state.** The locked-out message appears only with a
correct password. The proposed default (locked-out wins) was wrong.

The same probe disconfirmed Q2 as well: empty fields do **not** fall through to the generic
refusal path, they each get a distinct required-field message. That assumption had escaped
detection only because scenario `005`'s `Then` asserted no wording at all — a scenario too weak
to be wrong.

Both corrections **strengthened** the assertions (exact-text matches where there had been a
visibility check) rather than relaxing them. No threshold was lowered to obtain green; the
expected values were corrected against a live oracle, which is the one legitimate reason to
change an expected value.

## Honest limits of this proof

- It proves the **GitHub Actions** template. The `gitlab-ci.yml` and `Jenkinsfile` templates
  remain **unexecuted** — a real version-drift defect was found in both by reading (they pinned
  the Playwright Docker image to `v1.48.0-noble` while `automate` generates a suite on
  `@playwright/test` 1.62, which cannot find the browsers baked into that image) and fixed, but
  fixed-by-reading is not proven-by-running. Do not describe them as verified.
- It proves **one** generated suite, against a **public demo**, not a pilot application. The
  T17 exit criterion (≥ 80 % of P1 scenarios executable without manual rework on a real pilot)
  is untouched by this run and remains unmeasured.
- `saucedemo.com` is a third party. A future red run here may mean their outage, not a
  regression; check the run log before concluding.
