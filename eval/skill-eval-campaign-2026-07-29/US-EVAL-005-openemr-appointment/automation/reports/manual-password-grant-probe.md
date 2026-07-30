# Manual supplementary probe — password grant (not part of the automated Playwright suite)

This check was run by hand via `curl`/node during exploration, **outside** `global-setup.js`
and the `npx playwright test` run — it is not represented in `reports/auth-state.json` or
`reports/junit.xml`. Recorded here as a separate, explicitly-labelled artifact so the claim in
`traceability.md` has real backing instead of being an unsubstantiated narrative addition (gap
flagged by the independent evaluator pass).

Client used: a second dynamically-registered client (`client_id` ending `...oj58`, registered
with `"grant_types":["password","refresh_token"]`), registered via a real
`POST /openemr/oauth2/default/registration` call that returned HTTP 200.

Request:
```
POST https://one.openemr.io/openemr/oauth2/default/token
Content-Type: application/x-www-form-urlencoded

grant_type=password&client_id=<redacted>&client_secret=<redacted>
&scope=openid+api:oemr+user/patient.read+user/facility.read+user/appointment.write+user/appointment.read
&user_role=users&username=admin&password=pass
```

Real response observed:
```
HTTP 401
{"error":"invalid_client","error_description":"Client authentication failed","message":"Client authentication failed"}
```

This is a real HTTP exchange against the live demo, but it is a **manual, one-off probe**, not
an automated/repeatable test in this suite — it should be read as corroborating context for the
`authorization_code` blocker in `reports/auth-state.json`, not as equivalent machine evidence.
If this is re-verified, it should be re-run as part of `global-setup.js` for a reproducible
trace.
