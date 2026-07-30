// Real OAuth2 dynamic-client-registration + authorization_code flow against the live
// public OpenEMR demo (one.openemr.io/openemr). Not a mock: every request below is a real
// network call. Writes auth-state.json consumed by the API specs. If the flow cannot obtain
// a bearer token, auth-state.json records the exact HTTP status/body of the failure instead
// of a token, so authenticated specs report BLOCKED with real evidence rather than a fake pass.
const { chromium, request } = require('@playwright/test');
const fs = require('fs');
const path = require('path');

const BASE = 'https://one.openemr.io/openemr';
const REDIRECT = 'https://localhost';
const SCOPE = 'openid api:oemr user/patient.read user/facility.read user/appointment.write user/appointment.read';
const OUT = path.join(__dirname, 'reports', 'auth-state.json');

module.exports = async () => {
  const state = { generatedAt: new Date().toISOString(), steps: [] };

  // Step 1: dynamic client registration (RFC 7591) - real POST
  const req = await request.newContext();
  const regResp = await req.post(`${BASE}/oauth2/default/registration`, {
    data: {
      application_type: 'private',
      redirect_uris: [REDIRECT],
      client_name: 'qaia-eval-005-automation',
      token_endpoint_auth_method: 'client_secret_post',
      contacts: ['qaia-eval@example.com'],
      grant_types: ['authorization_code', 'password', 'refresh_token'],
      scope: SCOPE,
    },
  });
  const regStatus = regResp.status();
  const regBody = await regResp.json().catch(() => ({}));
  state.steps.push({ step: 'dynamic_client_registration', status: regStatus });
  if (regStatus !== 200 || !regBody.client_id) {
    state.token = null;
    state.blockedReason = `client registration failed: HTTP ${regStatus}`;
    fs.writeFileSync(OUT, JSON.stringify(state, null, 2));
    await req.dispose();
    return;
  }
  const client_id = regBody.client_id;
  const client_secret = regBody.client_secret;

  // Step 2: real browser-driven authorization_code flow (login as documented demo admin,
  // grant consent on the real consent screen, capture the real redirect with ?code=).
  const browser = await chromium.launch();
  const page = await browser.newPage();
  let code = null;
  try {
    const authUrl = `${BASE}/oauth2/default/authorize?response_type=code&client_id=${client_id}` +
      `&redirect_uri=${encodeURIComponent(REDIRECT)}&scope=${encodeURIComponent(SCOPE)}&state=qaia005`;
    await page.goto(authUrl, { waitUntil: 'networkidle' });

    await page.fill('input[name="username"]', 'admin');
    await page.fill('input[name="password"]', 'pass');
    await Promise.all([
      page.waitForNavigation({ waitUntil: 'networkidle' }).catch(() => {}),
      page.click('button[name="user_role"][value="api"]'),
    ]);
    state.steps.push({ step: 'oauth_provider_login', url: page.url() });

    let capturedRedirect = null;
    page.on('request', req => { if (req.url().startsWith(REDIRECT)) capturedRedirect = req.url(); });
    page.on('framenavigated', fr => { if (fr.url().startsWith(REDIRECT)) capturedRedirect = fr.url(); });
    await Promise.all([
      page.waitForResponse(() => true, { timeout: 15000 }).catch(() => null),
      page.click('button[name="proceed"][value="1"]'),
    ]);
    await page.waitForTimeout(1500);
    const finalTarget = capturedRedirect || page.url();
    state.steps.push({ step: 'consent_authorize', finalUrl: finalTarget !== 'chrome-error://chromewebdata/' ? finalTarget : capturedRedirect });

    const raw = capturedRedirect || finalTarget;
    const qs = raw.includes('?') ? raw.split('?')[1] : '';
    code = new URLSearchParams(qs).get('code');
  } finally {
    await browser.close();
  }

  if (!code) {
    state.token = null;
    state.blockedReason = 'authorization_code flow did not yield a code (see steps)';
    fs.writeFileSync(OUT, JSON.stringify(state, null, 2));
    await req.dispose();
    return;
  }

  // Step 3: real token exchange
  const tokenResp = await req.post(`${BASE}/oauth2/default/token`, {
    form: {
      grant_type: 'authorization_code',
      code,
      client_id,
      client_secret,
      redirect_uri: REDIRECT,
    },
  });
  const tokenStatus = tokenResp.status();
  const tokenBody = await tokenResp.json().catch(() => ({}));
  state.steps.push({ step: 'token_exchange', status: tokenStatus, body: tokenBody });

  if (tokenStatus === 200 && tokenBody.access_token) {
    state.token = tokenBody.access_token;
  } else {
    state.token = null;
    state.blockedReason = `token exchange failed: HTTP ${tokenStatus} ${JSON.stringify(tokenBody)}`;
  }

  fs.writeFileSync(OUT, JSON.stringify(state, null, 2));
  await req.dispose();
};
