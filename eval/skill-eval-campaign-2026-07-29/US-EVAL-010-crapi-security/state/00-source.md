# 00-source — US-EVAL-010

- **Source type**: public GitHub repository documentation, **primary source** for the vulnerability
  class and challenge text (the project's own `docs/` files, fetched directly — not a blog
  paraphrase). Target: **crAPI** (`OWASP/crAPI` — "**c**ompletely **r**idiculous **API**"), picked
  as a deliberate diversification pick from `docs/DEMO-TARGETS.md`'s "GitHub lists that catalog
  targets" section, row `OWASP/www-project-vulnerable-web-applications-directory` (VWAD), which
  names crAPI explicitly among its `offline`-tagged (self-hostable) entries. This fills a real gap:
  no prior campaign run (`US-EVAL-001`..`009`) has exercised a pure API-security-focused target —
  `US-EVAL-003` was API-shaped but not security-flawed by design, and Juice Shop (`US-EVAL-004`)
  is security-adjacent but a web UI, not an API.
- **Capture method**: direct unauthenticated `GET` (via `WebFetch`, one request per file, no
  scan/load pattern — golden rule respected: *explore* only, no `security-surface` run against any
  shared instance) of three files in the `OWASP/crAPI` repo's `main` branch:
  - `GET https://raw.githubusercontent.com/OWASP/crAPI/main/README.md` (project description,
    architecture summary, Docker Compose self-hosting instructions)
  - `GET https://raw.githubusercontent.com/OWASP/crAPI/main/docs/overview.md` (microservices:
    identity, community, workshop)
  - `GET https://raw.githubusercontent.com/OWASP/crAPI/main/docs/challenges.md` (the project's own
    numbered vulnerability-challenge catalog)
- **Capture date**: 2026-07-30.

- **Captured facts (primary source, `docs/challenges.md` and `README.md`)**:

  > README: crAPI "stands for '**c**ompletely **r**idiculous **API**' and is designed as an
  > intentionally vulnerable educational platform" that "will help you to understand the ten most
  > critical API security risks." The system is "built on top of a microservices architecture,"
  > simulating a car-buying/vehicle-ownership service.
  >
  > README: self-hosting via **Docker Compose (v1.27.0+)** is the documented quickstart, for both
  > Linux and Windows; after `docker compose up -d` the app is served at `http://localhost:8888`,
  > with a mail-catcher UI at `http://localhost:8025`. A Vagrant/VM option also exists. This
  > confirms the target is genuinely self-hostable per `docs/DEMO-TARGETS.md`'s golden rule.
  >
  > `docs/overview.md`: the platform has three named microservices — **Identity** (user/auth
  > endpoints), **Community** (blogs/comments), **Workshop** (vehicle-workshop endpoints, mechanic
  > reports). "For more details on the vulnerabilities see the challenges.md."
  >
  > `docs/challenges.md`, **Challenge 1 (BOLA — Broken Object Level Authorization), quoted
  > verbatim**: "Access details of another user's vehicle. Since vehicle IDs are not sequential
  > numbers, but GUIDs, you need to find a way to expose the vehicle ID of another user. Find an
  > API endpoint that receives a vehicle ID and returns information about it." — this is the
  > project's own, most-cited, canonical challenge (OWASP API Security Top 10 #1, BOLA), and the
  > one this US-slice is scoped to.
  >
  > `docs/challenges.md` also documents (read but **out of scope for this slice**, listed for
  > completeness, not designed here): Challenge 2 (mechanic reports of other users, same BOLA
  > class, different endpoint), Challenge 3 (password reset for a different user), Challenge 14
  > (an endpoint missing authentication checks entirely), Challenge 15 (JWT forgery), Challenges
  > 4-13/16-18 (data exposure, BFLA, mass assignment, SSRF, injection, LLM prompt injection).

- **Captured facts (secondary, corroborating, explicitly flagged as such — not OWASP's own docs
  text)**: several independent third-party security write-ups (`p4p2.github.io` IDOR walkthrough,
  `hackingblogs.com` "Finding Anyone's Location In crAPI Using EDE & BOLA Bugs`) consistently name
  the **concrete endpoint** that Challenge 1's abstract description ("an API endpoint that receives
  a vehicle ID and returns information about it") maps to at implementation level:
  `GET /identity/api/v2/vehicle/{vehicleId}/location`, returning the vehicle's current
  latitude/longitude. **This exact path and response shape is NOT itself present in
  `challenges.md`'s or `overview.md`'s own text** — `challenges.md` deliberately keeps the
  challenge abstract (finding the endpoint is part of the challenge). It is carried forward as a
  `[secondary-source]`-flagged fact, lower confidence than the primary-sourced vulnerability class
  itself, and is the concrete instantiation this US-slice designs against (a BOLA on the
  vehicle-location endpoint specifically, not the whole open-ended Challenge 1 hunt).

- **Not confirmed by any source found**: the exact HTTP status code crAPI's own (deliberately
  vulnerable) implementation currently returns on a cross-owner request (200 with the other
  user's coordinates, per the vulnerability's whole premise, but not verified against a live
  instance in this capture — no Docker/network access in this sandboxed worktree, per this
  campaign's explicit instruction not to stand up containers here); the exact JWT claim structure;
  whether the location endpoint enforces authentication at all versus only ownership (Challenge 14
  is a separate, unrelated endpoint per the source — not assumed to also apply here).
- **Redaction**: none needed — no real personal data; this is public documentation about a
  deliberately-vulnerable teaching application's own catalogued defect class.
- **Dependencies (out-of-slice)**: Challenges 2-18 of the same catalog (mechanic-report BOLA,
  password reset, JWT forgery, injection, SSRF, LLM prompt injection, etc.) are separate,
  independently-challenging defects of the same target — not designed here; this US-slice is
  scoped to Challenge 1's BOLA class on the vehicle-location endpoint only.

## Triage gates (step 2 of `us-ingest`)

- **Empty/whitespace**: not applicable — three real documents captured.
- **Testable requirement**: yes — a concrete API endpoint (`GET .../vehicle/{vehicleId}/location`)
  with a statable authorization rule ("only the vehicle's owner may retrieve its location") is a
  real testable capability, not a recipe/design-doc/RFC-template.
- **Abuse/illegality gate**: does **not** fire. OWASP's own README frames crAPI as "designed as an
  intentionally vulnerable educational platform" specifically so security testing can be practiced
  on it lawfully; this US-slice designs tests that assert the *secure* behavior (proper
  authorization enforcement) — the same shape as testing any access-control rule — not an attack
  against a third party, not a scraping/anti-abuse bypass, not credential theft. Running those
  scenarios for real is explicitly gated to a **self-hosted** instance only (`docs/DEMO-TARGETS.md`
  golden rule), which is exactly the constraint this campaign run respects by stopping before step
  8's live execution.

## Journey

| Step | Status |
|---|---|
| 00-ingest | done — gates checked, primary source captured directly from `OWASP/crAPI`'s own `docs/`, secondary corroboration explicitly flagged as such |

## Skill evaluation — `us-ingest` (`plugins/qaia-core/skills/us-ingest/SKILL.md`)

See separate evaluator pass (spawned after this checkpoint, evaluator has not seen this producer's
reasoning — only this file's content as "output," the campaign brief as "input," and the skill's
own `SKILL.md`).
