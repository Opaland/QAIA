---
name: security-surface
description: Generate and run risk-based passive security-surface checks (CT-SEC - assets and threats identified first, then auth boundaries, IDOR, error handling, user enumeration prioritized by risk) against an authorized self-hosted app, plus optional OWASP ZAP baseline. Use for security coverage. Authorized self-hosted targets only.
---

# security-surface — risk-based passive security checks (CT-SEC)

Reference: `examples/medibook/tests/security.booking.spec.js` (401/IDOR/malformed-input/user-enumeration). Decision D26 — v1 passive; ZAP baseline opt-in. Decision D95 — front-ended with a CT-SEC risk assessment: the fixed v1 checklist alone treated every app the same regardless of what it actually protects; identical checklist, but now run in the order and depth the app's own assets/threats justify, not uniformly.

## Step 0 — Asset & threat identification (CT-SEC, run before the checklist)

1. **Name the sensitive assets** the app actually holds, from the US/test book/knowledge base — never invented: authentication credentials, other users' personal data, payment/financial data, admin/privileged functions, any data a breach would make notably worse than "generic CRUD record" (health data, financial totals, access tokens).
2. **Rank threats per asset** with the same impact × probability spirit as `prioritize` (T16 — human arbitrates, never a silent auto-verdict): which asset, if compromised via which check category below, causes the most damage? A payment-data asset raises IDOR/enumeration to the top; an admin-function asset raises auth-boundary privilege checks; an app with no sensitive asset beyond its own generic records still runs the full v1 checklist, just without an elevated priority on any one category.
3. **Record the ranking** alongside the report (asset → top-priority check category → why) — this is what changed from a flat checklist to a risk-based one; the checklist items themselves (below) are unchanged, only their **order and depth of attention** are asset-driven.
4. **Never skip a v1 checklist item because an asset ranking looks low-risk** — risk-based means *prioritized*, not *reduced coverage*. A quiet asset still gets the full passive pass, just not the first or deepest one.

## Scope (v1, passive — run for every target, ordered/weighted by step 0)

- **Auth boundaries**: protected endpoints reject missing/forged/expired tokens (401).
- **IDOR / cross-tenant**: one user cannot read or mutate another user's resource (expect 404/403, indistinguishable where privacy requires).
- **Robust error handling**: malformed body/params never 5xx; clean 4xx.
- **User enumeration**: login failures return an identical message regardless of which factor failed.
- **Headers/TLS**: security headers present, cookies `HttpOnly`/`Secure`/`SameSite`.
- Optional: **OWASP ZAP baseline** scan (opt-in).

## Guardrails (blocking)

- **Authorized, self-hosted targets only** (D35 + D26). Before running anything, state in the report which authorization applies, in this order: (a) an in-repo app under `examples/` — self-hosted and owned by definition, no catalog row needed; (b) a target listed in `docs/DEMO-TARGETS.md` — cite its golden rule and its per-target security column; (c) a target explicitly authorized by the human founder this session — cite that authorization verbatim. If none of the three applies, do not scan. This is a **narrative check the agent performs each time, not a config-enforced allow-list gate** (found 2026-07-30 skill-eval campaign: no allow-list mechanism actually exists in the repo despite an earlier version of this guardrail implying one; corrected here to describe reality rather than an unbuilt control). Never scan a third party you do not own or are not explicitly authorized to test — when the human founder has explicitly named an exception in this session (e.g. a target's own docs authorize public small-scale testing), cite that authorization explicitly in the report rather than silently treating it as a standing rule.
- No active exploitation beyond the passive surface above without explicit user authorization and a named scope.
- Publish and honor an acceptable-use note; refuse any framing that targets a competitor or a production system without authorization (mirrors the ingestion abuse gate).
- Produce a report file next to the evidence (`report.md` in the run's output dir, not only in the session transcript). It MUST contain: the `@QAIA-SEC-<NNN>` tag, the step-0 asset ranking (asset → top-priority check category → why), the authorization basis used above, and every finding with an explicit severity. Evidence files alone do not satisfy this bullet.
