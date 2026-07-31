# US-EVAL-003 — Step 8 automation attempt (real HTTP, no simulation)

**Date/time of calls**: 2026-07-30, ~14:03-14:05 UTC (see `Date:` headers in raw captures below).
**Method**: `curl` (Bash tool), real network calls, no Docker available in this environment.
**Target**: the only live public instance of Restful-Booker-Platform found -
`https://automationintesting.online` (confirmed via `WebSearch` +
`github.com/mwinteringham/restful-booker-platform` README references to a hosted demo; the
`aw1.automationintesting.online` alternate hostname mentioned in some search results does not
resolve - `curl` exit code 6, DNS failure).

## Golden rule check

- Self-host via Docker: not available in this environment (no Docker) - **security-surface /
  perf-check are out of scope here**, per the golden rule (self-host-only), and are **not
  attempted**.
- This step targets only `contract-probe`/`automate`-style functional HTTP calls against the
  public demo, which `DEMO-TARGETS.md` marks "self-host Docker" for that use, but the platform
  also exposes a live public instance - explored here, not scanned/load-tested.

## What was actually run (raw, unedited)

### 1. `GET https://automationintesting.online/` - baseline reachability

```
HTTP/1.1 200 OK
Date: Thu, 30 Jul 2026 14:04:52 GMT
Content-Type: text/html; charset=utf-8
Server: cloudflare
x-powered-by: Next.js
x-railway-edge: cdg1
```
The host is reachable. **But** the response is served by **Next.js** (`x-powered-by: Next.js`,
`x-nextjs-cache`, `x-nextjs-prerender` headers) on Railway infra (`x-railway-edge`), not the
Spring Boot / nginx-gateway stack described in the repo's `booking` microservice source that
`00-source.md` grounded this testbook in.

### 2. `GET https://automationintesting.online/booking/` (trailing slash, as the testbook literally specifies: `POST /booking/`)

```
HTTP/1.1 308 Permanent Redirect
location: /booking
refresh: 0;url=/booking
```

### 3. `GET https://automationintesting.online/booking` (redirect target, `-L` followed)

```
HTTP/1.1 404 Not Found
Content-Type: text/html; charset=utf-8
x-powered-by: Next.js
```
Body: a Next.js-rendered `404: This page could not be found` HTML page (client-side router
404, not a JSON API error).

### 4. `POST https://automationintesting.online/booking/` - scenario `QAIA-US-EVAL-003-001` payload

Request body:
```json
{"roomid":1,"firstname":"Leo","lastname":"Doe","depositpaid":true,"bookingdates":{"checkin":"2027-03-10","checkout":"2027-03-11"}}
```

```
HTTP/1.1 308 Permanent Redirect
location: /booking
refresh: 0;url=/booking
```
Body: `/booking` (redirect stub, no JSON).

### 5. `POST https://automationintesting.online/booking` (no trailing slash) - same payload

```
HTTP/1.1 404 Not Found
Content-Type: text/html; charset=utf-8
x-powered-by: Next.js
```
Body: same Next.js 404 HTML page as request 3 - **no `bookingid`, no `booking` object, no JSON
at all**.

### 6. Additional path probes (each a one-shot `curl -o /dev/null -w "%{http_code}"`)

| Path | HTTP status |
|---|---|
| `/room/` | 308 (redirects to `/room`, same Next.js router pattern) |
| `/auth/login` | 404 |
| `/message/` | 308 |
| `/report/` | 308 |
| `/api/booking/` | 308 |
| `/booking/1` | 404 |
| `/apidoc/` | 308 |
| `/swagger-ui/index.html` | 404 |

No path returned JSON or any API-shaped response; every probed path is either a Next.js
client-side route (308 redirect to a bare path, then 404 on resolution) or a flat 404.

## Verdict: BLOCKER - no functioning JSON API surface reachable

`https://automationintesting.online` is reachable (200 on `/`), so this is **not** a "no live
instance" situation in the blunt sense. But the live instance currently serves a **Next.js
front-end only**; the `POST /booking/` (and `GET/POST /room/`, `/auth/`, `/message/`, `/report/`)
paths that `00-source.md` grounded this testbook in (the Spring Boot `BookingController` /
`booking` microservice, `github.com/mwinteringham/restful-booker-platform`, `booking/src/main/...`)
are **not exposed as a callable REST/JSON API at this hostname** - every request against them
returns either a 308 redirect to a bare path or a Next.js-rendered HTML 404, never a JSON body,
never a `201`/`400`/`409` matching the testbook's expected contract.

Two honest readings, both leading to the same conclusion (no real assertion possible):
1. The publicly hosted demo has been re-architected (or is mid-migration) since the source the
   testbook was grounded on was read, and the booking microservice's REST API is no longer
   exposed at this public hostname (it may now live behind a path/port not proxied by the public
   Next.js front-end, or the front-end may call it server-side/same-origin in a way `curl` cannot
   reach without discovering the actual internal route).
2. The API may still exist but at an undiscovered path/subdomain not surfaced by `WebSearch`,
   the repo README excerpts fetched, or the 8 probed candidate paths above.

Either way: **no genuine `POST /booking/` HTTP round-trip against the behavior described in
`00-source.md` could be executed.** Fabricating a `201`/`400`/`409` response body at this point
would violate the explicit instruction not to simulate. Self-hosting via Docker - the documented
reliable path in `docs/DEMO-TARGETS.md` (`Restful-Booker-Platform` row, self-host column: Docker) -
is not available in this environment (no Docker).

## What was NOT done, and why

- **No scenario from `booking-create.feature` was executed against real expected/actual pairs.**
  Every one of the 9 scenario blocks requires a JSON response body (`bookingid`, `fieldErrors`,
  echoed `booking` object) that the live host never returned.
- **No security-surface / perf-check** - self-host-only per the golden rule, and self-hosting is
  unavailable here (no Docker). Not attempted, not simulated.
- **No fabricated response bodies** - every HTTP response quoted above is the literal, unedited
  output of a real `curl` call made in this session; nothing was invented or back-filled from the
  Java source read during `00-source.md`.

## Raw header captures (full, unedited, saved alongside this file)

`h1.txt` (GET /), `h2.txt` (GET /booking/), `h3.txt` (POST /booking/), `h4.txt` (POST /booking,
404 headers), `b3.json` (POST /booking/ body = `/booking`), `b4.json` (POST /booking body =
Next.js 404 HTML page).
