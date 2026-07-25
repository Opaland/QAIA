---
name: security-surface
description: Generate and run passive security-surface checks (auth boundaries, IDOR, error handling, user enumeration) against an authorized self-hosted app, plus optional OWASP ZAP baseline. Use for security coverage. Authorized self-hosted targets only.
---

# security-surface — passive security checks

Reference: `examples/medibook/tests/security.booking.spec.js` (401/IDOR/malformed-input/user-enumeration). Decision D26 — v1 passive; ZAP baseline opt-in.

## Scope (v1, passive)

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
