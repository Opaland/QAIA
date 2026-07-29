---
stepsCompleted: [testbook-generate]
lastStep: testbook-generate
lastSaved: 2026-07-29
---

# Coverage matrix — US-007

AC → condition → scenario ID → priority → rationale → confidence.

| AC | Condition | Scenario ID | Priority | Rationale (from `prioritize`) | Confidence |
|---|---|---|---|---|---|
| AC1 | AC1-C1 valid create | 001 | P3 | Straightforward happy-path config; low complexity | full |
| AC1 | AC1-C2 fee = 0 rejected `[req-neg]` | 002 | P1 | Zero-fee bypasses the paid-content guarantee if unenforced | full |
| AC1 | AC1-C3 fee negative rejected `[req-neg]` | 003 | P1 | Negative fee is the same guarantee, mirrored boundary | full |
| AC1 | AC1-C4 invalid currency rejected `[req-neg]` | 004 | P1 | Invalid currency reaching billing is a financial-correctness risk | full |
| AC1 | AC1-C5 minor-unit rounding | 005 | P2 | Rounding is a real but narrower correctness risk | full |
| AC1 | AC1-C6 missing account rejected `[req-neg]` | 006 | P2 | Required-field validation, simple to implement correctly | full |
| AC1 | AC1-C7 second independent method | 007 | P3 | No stated cardinality limit; low consequence | @low-confidence (Q4) |
| AC1 | AC1-C8 non-manager denied `[req-neg]` | 008 | P1 | Authorization gap on a money-configuring action is high-severity | full |
| AC1 | AC1-C9 edit existing fee | 009 | P3 | Edit mechanism unspecified; low blast radius | @low-confidence |
| AC1 | AC1-C10 remove method | 010 | P2 | Removal affecting paying students has moderate consequence | @low-confidence |
| AC2 | AC2-C1 fee prompt before content | 011 | P1 | Core content-gating guarantee — the headline risk | full |
| AC2 | AC2-C2 exact amount displayed | 012 | P3 | Display bug is real but lower severity than a full leak | full |
| AC2 | AC2-C3 already-enrolled sees content | 013 | P3 | Answered from AC2's own wording; simple state check | full |
| AC2 | AC2-C4 direct-URL bypass blocked `[req-neg]` | 014 | P1 | Server-side bypass of a paid-content gate — highest severity | full |
| AC3 | AC3-C1 select enabled method | 019 | P3 | Simple selection UI over a given list | full |
| AC3 | AC3-C2 only enabled methods offered | 020 | P2 | Filtering correctness, contained risk | full |
| AC3 | AC3-C3 cancel → not enrolled/charged `[req-neg]` | 021 | P2 | Explicit AC guarantee; cancel logic usually simple | full |
| AC3 | AC3-C4 decline → not enrolled/charged `[req-neg]` | 022 | P1 | Worst-case trust failure if mis-handled | @low-confidence (Q2) |
| AC3 | AC3-C5 repeated cancel/retry | 023 | P3 | Re-entrance of an already-covered path; low incremental risk | full |
| AC3 | AC3-C6 zero enabled methods `[req-neg]` | 024 | P1 | Degenerate misconfiguration, higher probability of a miss | @low-confidence (Q9) |
| AC3 | AC3-C7 success → enrol + charge exact fee | 025 | P1 | Core paid conversion path | full |
| AC4 | AC4-C1 guest sees same messaging | 015 | P3 | Mirrors AC2-C1 with lower marginal complexity | full |
| AC4 | AC4-C2 guest prompted to log in, no pay path `[req-neg]` | 016 | P1 | Explicit AC guarantee, security-relevant | full |
| AC4 | AC4-C3 unauth direct request rejected `[req-neg]` | 017 | P1 | Same bypass severity as AC2-C4, highest risk class | full |
| AC4 | AC4-C4 resume after login | 018 | P3 | UX continuity; no security/money consequence if imperfect | @low-confidence (Q6) |
| AC5 | AC5-C1 set custom name/description | 026 | P3 | Simple config acceptance | full |
| AC5 | AC5-C2 student sees only custom name | 027 | P2 | Confidentiality-of-branding concern, not payment-safety | full |
| AC5 | AC5-C3 guest sees only custom name (triple-AC, Q8) | 028 | P2 | Same as AC5-C2, extended to guest view | full |
| AC5 | AC5-C4 manager view shows default origin | 029 | P3 | Manager-only cosmetic distinction | full |
| AC5 | AC5-C5 rename is a live property | 030 | P2 | Stale name after rename is moderate, non-blocking | @low-confidence (Q7) |
| journey | end-to-end AC1-AC4 | 031 `@smoke` | — | Use-case technique; excluded from priority/atomicity/negative-ratio accounting | full |

## AC coverage summary

- **AC total: 5, AC covered: 5** (every AC has ≥1 scenario).
- **Required-negative conditions (ADR 0001 gate): 11 total, 11 covered** — `AC1-C2, AC1-C3, AC1-C4, AC1-C6, AC1-C8, AC2-C4, AC3-C3, AC3-C4, AC3-C6, AC4-C2, AC4-C3`.
- **Negative ratio (D20 signal, reported not gated): 11 `@negative` blocks / 30 atomic blocks (smoke excluded) = 36.7 %** — see the ratio explainer in `synthesis.md`.
