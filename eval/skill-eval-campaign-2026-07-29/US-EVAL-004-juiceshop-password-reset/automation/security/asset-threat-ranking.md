# security-surface — Step 0: Asset & threat identification (CT-SEC)

US-EVAL-004 scope: OWASP Juice Shop password-reset-via-security-question flow
(`https://demo.owasp-juice.shop/#/forgot-password`), public shared demo, real run
(explicitly permitted per `docs/DEMO-TARGETS.md`'s coverage matrix).

## 1. Sensitive assets actually held (from the US / test book, not invented)

- **Authentication credentials** — the account's password itself; this US's entire
  surface *is* the credential-recovery path, so this is the top asset by construction.
- **The security question/answer pair** — a second-factor-shaped secret; if it can be
  read, guessed, or overwritten by someone other than the account owner, the password
  becomes recoverable by an attacker regardless of its own strength.
- **Account-existence data** (does an email belong to a registered account) — lower
  sensitivity than the above two, but a known enabler for targeted attacks and already
  flagged as an explicit open question (Q1) in `testbooks/synthesis.md`.
- No payment/financial or health data is in scope for this specific US (Juice Shop as a
  whole holds e-commerce/payment data elsewhere in the app, out of this slice).

## 2. Threat ranking (impact × probability, same spirit as `prioritize`)

| Rank | Asset | Threat | Check category raised to top |
|---|---|---|---|
| 1 | Password (via security-answer secret) | An attacker sets/overwrites *another* account's security answer, then resets that account's password — full account takeover | **IDOR / mass-assignment** on the security-answer-setting endpoint |
| 2 | Account-existence data | Unauthenticated enumeration of which emails are registered accounts, via the password-reset entry point | **User enumeration** |
| 3 | Password (via the reset endpoint itself) | The reset/lookup endpoints are reachable without auth by design (that is the feature) — the risk shifts to whether they are *robust* against malformed/adversarial input rather than to an auth-boundary failure per se | **Robust error handling** |
| 4 | (general) | Standard auth-boundary check on an unrelated admin-listing endpoint, run as the v1 baseline even though it is not this US's own asset | **Auth boundaries** (baseline, not elevated) |
| 5 | (general) | Transport/header hygiene, baseline | **Headers/TLS** (baseline, not elevated) |

## 3. What changed vs. a flat checklist

The checklist items themselves are unchanged (still all 5 v1 categories run, per the
"never skip an item for looking low-risk" guardrail) — only the **order and depth**
changed: IDOR on the security-answer endpoint and user enumeration on the lookup
endpoint were investigated first and in the most depth (including confirming real
exploit impact with two throwaway accounts owned by this test run), because this US's
own asset ranking (row 1, row 2 above) puts them there — not because of a generic
severity guess.
