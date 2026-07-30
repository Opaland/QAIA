// API seeding helpers (T3/T4: atomic preconditions via API, never UI-chained setup).
// The shared public demo (Heroku-hosted) is intermittently unavailable (HTTP 503 /
// "Application Error", observed repeatedly this session and already documented in
// state/00-source.md from the ingest phase) -- a bounded retry absorbs that known
// transient flakiness without masking a real failure (retries: 0 in playwright.config.js
// governs *test* retries; this is seeding-layer resilience against a documented shared-
// infra flap, a different concern).
async function withRetry(fn, { attempts = 30, delayMs = 6000 } = {}) {
  let lastErr;
  for (let i = 0; i < attempts; i++) {
    try {
      const res = await fn();
      if (res && res.status && res.status() === 503) {
        lastErr = new Error('503 Application Error (shared demo backend down)');
        await new Promise((r) => setTimeout(r, delayMs));
        continue;
      }
      return res;
    } catch (e) {
      lastErr = e;
      await new Promise((r) => setTimeout(r, delayMs));
    }
  }
  throw lastErr;
}

// Registers a fresh throwaway account and correctly links its security answer
// (POST /api/Users/ alone leaves SecurityAnswers.UserId null on this app version --
// a real finding, see automation/NOTES.md -- so the answer is created as a second,
// explicit, authenticated call with UserId set, mirroring what the real registration
// UI does under the hood).
async function createAccount(request, { question = 2, answer = 'Testanswer42', password = 'QaiaEval#2026' } = {}) {
  const email = `qaia-eval-004-${Date.now()}-${Math.floor(Math.random() * 1e6)}@example.com`;

  const regRes = await withRetry(() =>
    request.post('/api/Users/', {
      data: { email, password, passwordRepeat: password, securityQuestion: { id: question }, securityAnswer: answer },
    })
  );
  if (!regRes.ok()) throw new Error(`registration failed: ${regRes.status()} ${await regRes.text()}`);
  const regBody = await regRes.json();
  const userId = regBody.data.id;

  const loginRes = await withRetry(() =>
    request.post('/rest/user/login', { data: { email, password } })
  );
  if (!loginRes.ok()) throw new Error(`login failed: ${loginRes.status()}`);
  const loginBody = await loginRes.json();
  const token = loginBody.authentication.token;

  const answerRes = await withRetry(() =>
    request.post('/api/SecurityAnswers/', {
      headers: { Authorization: `Bearer ${token}` },
      data: { SecurityQuestionId: question, answer, UserId: userId },
    })
  );
  if (!answerRes.ok()) throw new Error(`security answer link failed: ${answerRes.status()}`);

  return { email, password, answer, userId, token };
}

module.exports = { createAccount, withRetry };
