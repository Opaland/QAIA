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

- **Authorized, self-hosted targets only** (D35 + D26). An **allow-list of hosts is required in config; any target not on it is refused by default.** Never scan a third party you do not own or are not explicitly authorized to test.
- No active exploitation beyond the passive surface above without explicit user authorization and a named scope.
- Publish and honor an acceptable-use note; refuse any framing that targets a competitor or a production system without authorization (mirrors the ingestion abuse gate).
- Tag `@QAIA-SEC-<NNN>`; report real results, findings by severity.
