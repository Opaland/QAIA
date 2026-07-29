---
stepsCompleted: [00-ingest, 01-review, 02-understanding, rag-build, 03-design, prioritize]
lastStep: prioritize
lastSaved: 2026-07-29
---

# 04-priorities — US-007 (risk-based, arbitrated)

Prerequisite `03-design.md` present. No target-repo path was named for this session, so the optional git-history signal is **not used** (skipped, no placeholder score — per guardrail). No project niche was declared as "regulated"; impact 3 is applied to conditions where a miss directly causes a security leak (unpaid content exposure) or an incorrect charge/enrolment — the two risks named in the `need-understanding` reformulation.

| Condition | Impact | Probability | Priority | Rationale |
|---|---|---|---|---|
| AC1-C1 | 2 | 1 | P3 (2) | Straightforward happy-path config; low complexity. |
| AC1-C2 | 3 | 2 | **P1 (6)** | Zero-fee bypasses the paid-content guarantee if unenforced — boundary logic. |
| AC1-C3 | 3 | 2 | **P1 (6)** | Negative fee is the same guarantee, mirrored boundary. |
| AC1-C4 | 3 | 2 | **P1 (6)** | Invalid currency reaching billing is a financial-correctness risk. |
| AC1-C5 | 2 | 2 | P2 (4) | Minor-unit rounding is a real but narrower correctness risk than accept/reject. |
| AC1-C6 | 3 | 1 | P2 (3) | Required-field validation, simple to implement correctly. |
| AC1-C7 | 1 | 2 | P3 (2) | `@low-confidence` assumption (Q4); no stated cardinality limit, low consequence either way. |
| AC1-C8 | 3 | 2 | **P1 (6)** | Authorization gap on a money-configuring action is a classic high-severity miss. |
| AC1-C9 | 1 | 2 | P3 (2) | `@low-confidence` assumption; edit mechanism unspecified, low blast radius if deferred. |
| AC1-C10 | 2 | 2 | P2 (4) | `@low-confidence` assumption; removal affecting existing paying students has moderate consequence. |
| AC2-C1 | 3 | 2 | **P1 (6)** | Core content-gating guarantee — the headline risk of the whole US. |
| AC2-C2 | 2 | 1 | P2 (2)→P3 | Amount-exactness display bug is real but lower severity than a full leak; rounds to P3. |
| AC2-C3 | 2 | 1 | P2 (2)→P3 | `[answered]` from AC2's own wording; simple state check, low complexity. |
| AC2-C4 | 3 | 3 | **P1 (9)** | Server-side bypass of a paid-content gate is the single highest-severity miss in this US. |
| AC3-C1 | 2 | 1 | P3 (2) | Simple selection UI over a given list. |
| AC3-C2 | 2 | 2 | P2 (4) | Filtering to enabled-only methods is a real but contained correctness risk. |
| AC3-C3 | 3 | 1 | P2 (3) | Explicit AC guarantee, but cancel-path logic is usually simple to get right. |
| AC3-C4 | 3 | 3 | **P1 (9)** | `[assumption: Q2]`; a mis-handled decline that still enrols/charges is the worst-case trust failure. |
| AC3-C5 | 1 | 2 | P3 (2) | Re-entrance of an already-covered path; low incremental risk. |
| AC3-C6 | 2 | 3 | **P1 (6)** | `[assumption: Q9]` `@low-confidence`; degenerate misconfiguration, higher probability of an unhandled edge. |
| AC3-C7 | 3 | 2 | **P1 (6)** | The core paid conversion path — must charge and enrol correctly together. |
| AC4-C1 | 2 | 1 | P3 (2) | Mirrors AC2-C1's messaging with lower marginal complexity (reuses the same prompt). |
| AC4-C2 | 3 | 2 | **P1 (6)** | Explicit AC guarantee against showing guests a direct pay path — a security-relevant miss. |
| AC4-C3 | 3 | 3 | **P1 (9)** | Same server-side-bypass severity as AC2-C4, applied to the unauthenticated actor — highest risk class. |
| AC4-C4 | 1 | 2 | P3 (2) | `[assumption: Q6]` `@low-confidence`; UX continuity, no security/money consequence if imperfect. |
| AC5-C1 | 1 | 1 | P3 (1) | Simple config acceptance. |
| AC5-C2 | 2 | 2 | P2 (4) | A leaked default name is a confidentiality-of-branding concern, not a payment-safety one. |
| AC5-C3 | 2 | 2 | P2 (4) | Same as AC5-C2, extended to the guest view (triple-AC resolution, Q8). |
| AC5-C4 | 1 | 1 | P3 (1) | Manager-only cosmetic distinction. |
| AC5-C5 | 2 | 2 | P2 (4) | `[assumption: Q7]`; a stale name after rename is a moderate but non-blocking correctness bug. |

⚠ VALIDATION (non-interactive run): `simulated: accepted-as-is` — all scores above accepted as proposed; no human override recorded in this run (flagged as an open arbitration point in the manifest).

## Scope for generation

Per default scope (`testbook-generate` step 1): **P1 + P2 in full**, P3 left as the tester's call (quota trade-off) — this run generates P1+P2, and additionally includes P3 conditions that are cheap, single-line scenarios reusing an already-built `Background` (P3 items are folded in where atomic and low-cost; none are skipped silently — the coverage matrix marks every condition's status either way).
