# 00-source — US-EVAL-001

- **Source type**: live application behavior (bring-your-own target, per
  `docs/SKILL-EVAL-CAMPAIGN-PROMPT.md`), not a written ticket. Captured via `WebFetch` on the
  designated URL (`https://www.saucedemo.com/` — a JS-rendered SPA, so `WebFetch` returned only
  the page shell) supplemented by `WebSearch` for the documented, stable persona behaviors that
  the SPA shell alone did not expose. Sources cited inline below; nothing asserted beyond what
  a source confirms.
- **Capture date**: 2026-07-29.
- **Captured text (faithful, not paraphrased)**:

  > SauceDemo is a small storefront built for practice: log in, browse products, add to cart,
  > complete a checkout. `standard_user` / `secret_sauce` logs in successfully. `locked_out_user`
  > / `secret_sauce` is rejected at login with the message "Sorry, this user has been locked
  > out." `problem_user` and `performance_glitch_user` are valid accounts whose defects surface
  > *after* login (wrong images/broken sorting; artificial slowness) — not login-gating.
  > (Source: WebSearch aggregation of `test-lab.ai/blog/practice-sites-for-test-automation` and
  > multiple SauceDemo test-case writeups, 2026-07-29 — no single primary SauceLabs doc page was
  > found; treated as a reasonably corroborated secondary source, not verified against an
  > official spec page, since SauceDemo publishes no formal requirements document.)

- **Not confirmed by any source found**: the exact behavior/message for an **unknown username**
  or a **wrong password against a known username** (invalid-credentials case). No source
  consulted stated this explicitly. **Not fabricated here — carried forward as an open point.**
- **Redaction**: none needed (test-account credentials for a public practice app, not real PII).
- **Dependencies** (out-of-slice): the UI-level defects of `problem_user`/`performance_glitch_user`
  (broken images/sorting, artificial latency) belong to other, separate concerns (a UI-rendering
  US and a performance US respectively) — noted, not designed here.

## Journey

| Step | Status |
|---|---|
| 00-ingest | done — gates checked (not empty, is a testable capability, no abuse/illegality, no PII to redact) |
