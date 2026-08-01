# The six protocols, executable

Every check states: **fixtures needed**, **requests to send**, **expected result**, and **the way
this check is usually run wrong**. That last part is not commentary — five of these six have a
standard mis-run that produces a green result while testing nothing, and a check that passes
vacuously is worse than a missing one, because it is counted as coverage.

All checks are **passive**: they send well-formed or malformed requests and observe responses.
None attempts exploitation, privilege escalation, or persistence.

---

## S1 — Auth boundaries {#s1}

**Fixtures.** One valid token for user A. One list of endpoints that are *supposed* to be
protected — taken from the US, the API contract or the route table, never guessed.

**Requests.** For each protected endpoint, four separate cases:

| Case | Token sent | Expected |
|---|---|---|
| S1-a | none | 401 |
| S1-b | malformed (`Bearer xxx`, truncated JWT) | 401 |
| S1-c | expired but otherwise valid | 401 |
| S1-d | well-formed, signed with the wrong key | 401 |

**Expected.** 401 in all four. Not 403 (that means authenticated-but-forbidden, a different
answer to a different question), not 500 (a crash on a bad token is itself the finding), not 200.

**The usual mis-run.** Testing only S1-a. A missing token is rejected by any framework's default
middleware; S1-c and S1-d are what tell you the signature and expiry are actually verified rather
than the token merely being *present*. An API that accepts any well-formed JWT passes S1-a
perfectly.

**Also check** that a 401 body carries no detail about *why* — "signature invalid" versus "token
expired" hands an attacker a working oracle.

---

## S2 — IDOR / cross-tenant {#s2}

The most frequently mis-run check in this list, and the one with the highest hit rate on real
applications.

**Fixtures — mandatory, the check is void without them.**

- **Two real accounts**, A and B, both valid, both authenticated, ideally in different tenants.
- **A resource created by A** during the run (so its id is known and its ownership is certain).
- **B's genuine, valid token** — not an absent token, not an invalid one.

**Requests.** With **B's valid token**, against A's resource id:

| Case | Method | Expected |
|---|---|---|
| S2-a | `GET /resource/{A_id}` | 404 (or 403) |
| S2-b | `PUT`/`PATCH /resource/{A_id}` | 404 (or 403), **and A's resource unchanged** |
| S2-c | `DELETE /resource/{A_id}` | 404 (or 403), **and A's resource still exists** |
| S2-d | `GET /resources` (list) | A's resource absent from B's list |

Then, as a control, repeat S2-a with **A's own token** and expect 200. Without this control a
misconfigured id or a resource that never existed makes every 404 look like a pass — the check
would "succeed" against a completely broken endpoint.

**Expected.** 404 preferred over 403 where the *existence* of the resource is itself sensitive
(a 403 confirms "this id exists, you just can't have it"). Whichever is chosen, it must be
**consistent** across existing-but-foreign and never-existed ids — an app returning 403 for one
and 404 for the other has rebuilt the enumeration oracle it was trying to close.

**The usual mis-run — the one to name explicitly.** Testing with a **missing or invalid token**
instead of B's valid one. That is S1, tests authentication, and passes trivially. IDOR is an
**authorization** failure: the caller is perfectly authenticated and simply asks for something
that is not theirs. If the test has no second account, it is not an IDOR test — report it as
**blocked for want of a second account**, never as passed.

**Second mis-run.** Checking read only. Write paths are frequently authorized separately from
read paths, and `DELETE` is regularly the one left unguarded. S2-b and S2-c must verify the side
effect (re-read as A), not just the status code: an API can return 403 and still have applied
the change.

---

## S3 — Robust error handling {#s3}

"Malformed" is meaningless as an instruction. Six named shapes, per endpoint that accepts a body:

| Case | Payload |
|---|---|
| S3-a | Truncated JSON — `{"name": "abc` |
| S3-b | Inverted type — a string where a number is expected, an array where an object is |
| S3-c | Missing required field |
| S3-d | Oversized payload — a ~10 MB string in a text field |
| S3-e | Unicode and control characters — emoji, RTL marks, an escaped NUL, a 4-byte UTF-8 sequence |
| S3-f | Wrong `Content-Type` — form-encoded body labelled `application/json` |

**Expected.** A clean 4xx (400 or 422; 413 for S3-d). Never 5xx. The body carries no stack trace,
no SQL fragment, no file path, no framework version, no internal host name.

**The usual mis-run.** Sending one malformed body, getting a 400, and marking the row green.
S3-d and S3-e are the two that find real defects — size limits are often absent, and control
characters routinely reach a logger or a template unescaped. S3-f catches parsers that trust the
header over the content.

**Note.** A 5xx here is a genuine finding (unhandled exception, availability risk, and usually an
information leak in the error body) — report it with its severity rather than as a flaky test.

---

## S4 — User enumeration {#s4}

**Fixtures.** One valid username. One username certain not to exist.

**Requests.** Three login attempts: valid user + wrong password; non-existent user + any
password; and, if applicable, a locked or disabled user + wrong password.

**Expected.** Identical on all three of:

- **Body** — same message, byte for byte.
- **Status** — same code.
- **Timing** — no systematic difference. Send each case ~20 times and compare medians; a
  consistent gap (often ~100 ms, because a real user's password gets hashed and a non-existent
  one short-circuits) is a working oracle even when the messages match.

Check the same on **password reset** and **registration** endpoints — reset flows are the usual
place enumeration survives after the login form has been fixed ("no account with that email").

**The usual mis-run.** Comparing only the message string. Timing and status are the channels that
stay open after someone has unified the copy.

**Note on QAIA's own example.** SauceDemo returns a distinct locked-out message versus the
generic one (see US-EVAL-001, D132). That is enumeration by design in a teaching app — a useful
reference for what the finding looks like, not a target to file a report against.

---

## S5 — Headers and cookies {#s5}

**Requests.** One `GET` on the main document, one on an API endpoint (they are frequently served
by different middleware, and the API one is usually the bare one).

**Expected — presence and a usable value:**

| Header | Minimum acceptable |
|---|---|
| `Strict-Transport-Security` | `max-age` ≥ 15552000 |
| `X-Content-Type-Options` | `nosniff` |
| `Content-Security-Policy` | present, and **without** `unsafe-inline` / `unsafe-eval` in `script-src` |
| `X-Frame-Options` or CSP `frame-ancestors` | denies framing |
| `Referrer-Policy` | `no-referrer` or `strict-origin-when-cross-origin` |

**Cookies** (session cookies especially): `HttpOnly`, `Secure`, `SameSite=Lax` or `Strict`.

**Also report, as an information leak rather than a missing control:** `Server`, `X-Powered-By`
and framework version headers.

**The usual mis-run.** Asserting the header *exists*. `Content-Security-Policy:
script-src 'unsafe-inline' *` is present and worthless. Assert the value, not the key.

---

## S6 — OWASP ZAP baseline (opt-in) {#s6}

**Opt-in only**, and it stays passive: the baseline scan spiders and observes, it does not attack.
Never enable ZAP's active scan under this skill — that is exploitation, out of scope, and out of
the authorization the guardrail describes.

```bash
docker run --rm -v "$(pwd)":/zap/wrk/:rw ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py -t "$TARGET_URL" -r zap-report.html -w zap-report.md
```

Exit codes: `0` clean, `1` warnings present, `2` failures, `3` internal error. Do not treat `1`
as a pass without reading it.

**Triage before reporting.** A baseline scan produces alerts by *rule*, many of them
informational and several duplicating S5. Map each alert to the S1-S5 item it corresponds to,
report the genuinely new ones, and never paste the raw ZAP output as the finding list — an
unreviewed scanner dump is the artifact that makes a security report ignored.

---

## Recording the results

One row per check per endpoint, in `report.md` in the run's output dir. `blocked` is a first-class
result and must be used rather than silently omitting a check.

| ID | Check | Endpoint | Result | Severity | Evidence |
|---|---|---|---|---|---|
| S1-d | foreign-signed token | `GET /api/bookings` | PASS | — | `evidence/s1d.http` |
| S2-b | cross-tenant update | `PATCH /api/bookings/{id}` | **FAIL** | High | `evidence/s2b.http` |
| S2-c | cross-tenant delete | `DELETE /api/bookings/{id}` | **BLOCKED** | — | no second account available |
| S4 | timing oracle | `POST /api/login` | PASS | — | medians 212/208 ms, n=20 |

Severity is stated for every finding, and a finding is never softened because it is inconvenient.
The report also carries the step-0 asset ranking and the authorization basis, per the guardrails.
