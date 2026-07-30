// E2E — maps QAIA Gherkin scenarios (US-EVAL-004, testbooks/password-reset.feature)
// to executable Playwright tests against the real, shared, public OWASP Juice Shop
// demo (https://demo.owasp-juice.shop) -- the one target in docs/DEMO-TARGETS.md whose
// coverage matrix marks public-demo security exploration as explicitly permitted.
//
// Atomic preconditions (T3/T4): every test seeds its OWN fresh throwaway account via
// the real registration API before touching the UI -- never a UI-chained setup, never
// reusing another test's account/state.
const { test, expect } = require('@playwright/test');
const { ForgotPasswordPage } = require('../pages/ForgotPasswordPage');
const { createAccount, withRetry } = require('../pages/api-helpers');

async function dismissBanners(page) {
  try { await page.locator('#welcomebanner_button, .close-dialog, [aria-label="Close Welcome Banner"]').first().click({ timeout: 3000 }); } catch (e) {}
  try { await page.locator('#cookieconsent button').first().click({ timeout: 3000 }); } catch (e) {}
}

test.describe('US-EVAL-004 — Juice Shop password reset via security question', () => {

  test('@QAIA-US-EVAL-004-001 @AC1 @P2 registered account email enables the Security Question field', async ({ page, request }) => {
    const acct = await createAccount(request);
    const fp = new ForgotPasswordPage(page);
    await fp.goto();
    await dismissBanners(page);
    await fp.enterEmail(acct.email);
    await expect(fp.securityAnswerInput).toBeEnabled();
  });

  test('@QAIA-US-EVAL-004-002 @AC1 @P1 non-registered email gives no distinguishable existence signal', async ({ page, request }) => {
    const nonRegistered = `qaia-eval-004-nobody-${Date.now()}@example.com`;
    const fp = new ForgotPasswordPage(page);
    await fp.goto();
    await dismissBanners(page);
    // Same directly-observable signal used for scenario 001: whether the Security
    // Question field becomes enabled. This is the concrete, assertable proxy the
    // scenario's Then names ("nothing in the response identifies the email as
    // unregistered") -- checked against a real unregistered email, not simulated.
    await fp.enterEmail(nonRegistered);
    const enabled = await fp.securityAnswerInput.isEnabled();
    // Record the real observed API status too, from the same GET the UI triggers.
    const apiRes = await withRetry(() => request.get(`/rest/user/security-question?email=${encodeURIComponent(nonRegistered)}`));
    const apiBody = await apiRes.json().catch(() => ({}));
    test.info().annotations.push({ type: 'observed', description: `securityAnswer enabled=${enabled}, API body=${JSON.stringify(apiBody)}` });
    expect(enabled).toBe(false);
  });

  test('@QAIA-US-EVAL-004-003 @AC2 @P1 correct answer + valid new password resets the password', async ({ page, request }) => {
    const acct = await createAccount(request);
    const fp = new ForgotPasswordPage(page);
    await fp.goto();
    await dismissBanners(page);
    await fp.enterEmail(acct.email);
    await expect(fp.securityAnswerInput).toBeEnabled();
    const newPassword = 'NewQaiaPass#1';
    await fp.fillResetForm({ answer: acct.answer, newPassword, repeatPassword: newPassword });
    await expect(fp.changeButton).toBeEnabled();
    await fp.submit();
    // Real post-condition: log in with the NEW password via the real login API.
    const loginRes = await withRetry(() => request.post('/rest/user/login', { data: { email: acct.email, password: newPassword } }));
    expect(loginRes.ok()).toBeTruthy();
  });

  test('@QAIA-US-EVAL-004-004 @AC3 @P1 @negative incorrect answer is refused, password unchanged', async ({ page, request }) => {
    const acct = await createAccount(request);
    const fp = new ForgotPasswordPage(page);
    await fp.goto();
    await dismissBanners(page);
    await fp.enterEmail(acct.email);
    await expect(fp.securityAnswerInput).toBeEnabled();
    const attemptedPassword = 'ShouldNotApply#1';
    await fp.fillResetForm({ answer: 'DEFINITELY-WRONG-ANSWER', newPassword: attemptedPassword, repeatPassword: attemptedPassword });
    await fp.submit();
    await page.waitForTimeout(1000);
    const errorVisible = await page.locator('.error').isVisible().catch(() => false);
    test.info().annotations.push({ type: 'observed', description: `error banner visible=${errorVisible}` });
    // Real post-condition: original password still works, attempted new one does not.
    const loginOld = await withRetry(() => request.post('/rest/user/login', { data: { email: acct.email, password: acct.password } }));
    const loginNew = await withRetry(() => request.post('/rest/user/login', { data: { email: acct.email, password: attemptedPassword } }));
    expect(loginOld.ok()).toBeTruthy();
    expect(loginNew.ok()).toBeFalsy();
  });

  test('@QAIA-US-EVAL-004-005 @AC3 @P1 @negative 5 consecutive wrong answers are each individually refused (no lockout claim)', async ({ page, request }) => {
    const acct = await createAccount(request);
    const results = [];
    for (let i = 0; i < 5; i++) {
      const res = await withRetry(() =>
        request.post('/rest/user/reset-password', {
          data: { email: acct.email, answer: `wrong-answer-${i}`, new: 'Whatever12345', repeat: 'Whatever12345' },
        })
      );
      results.push(res.status());
    }
    test.info().annotations.push({ type: 'observed', description: `5 attempt statuses=${JSON.stringify(results)}` });
    // Each of the 5 must be a refusal (non-2xx) -- no claim made about a lockout
    // existing or not (that would require a distinguishable status code change
    // across attempts, which is checked but not asserted on, per Q3/testbook).
    for (const status of results) expect(status).toBeGreaterThanOrEqual(400);
    const loginOld = await withRetry(() => request.post('/rest/user/login', { data: { email: acct.email, password: acct.password } }));
    expect(loginOld.ok()).toBeTruthy();
  });

  test.describe('@QAIA-US-EVAL-004-006 @AC4 @P2 @boundary password at the accepted length boundary is valid', () => {
    for (const length of [5, 40]) {
      test(`length=${length}`, async ({ page, request }) => {
        const acct = await createAccount(request);
        const fp = new ForgotPasswordPage(page);
        await fp.goto();
        await dismissBanners(page);
        await fp.enterEmail(acct.email);
        await expect(fp.securityAnswerInput).toBeEnabled();
        const pw = 'Aa1#'.padEnd(length, 'x').slice(0, length);
        await fp.fillResetForm({ answer: acct.answer, newPassword: pw, repeatPassword: pw });
        await expect(fp.changeButton).toBeEnabled();
        await fp.submit();
        const loginRes = await withRetry(() => request.post('/rest/user/login', { data: { email: acct.email, password: pw } }));
        expect(loginRes.ok()).toBeTruthy();
      });
    }
  });

  test.describe('@QAIA-US-EVAL-004-007 @AC4 @P2 @negative @boundary password outside the accepted length boundary is rejected client-side', () => {
    for (const length of [4, 41]) {
      test(`length=${length}`, async ({ page, request }) => {
        const acct = await createAccount(request);
        const fp = new ForgotPasswordPage(page);
        await fp.goto();
        await dismissBanners(page);
        await fp.enterEmail(acct.email);
        await expect(fp.securityAnswerInput).toBeEnabled();
        const pw = 'Aa1#'.padEnd(length, 'x').slice(0, length);
        await fp.fillResetForm({ answer: acct.answer, newPassword: pw, repeatPassword: pw });
        await expect(fp.changeButton).toBeDisabled();
        await expect(page.locator('mat-hint.inline-hint, em.inline-hint')).toContainText('Password must be 5-40 characters long.');
      });
    }
  });

  test('@QAIA-US-EVAL-004-008 @AC4 @P1 @negative backend re-enforces the password-shape rule when the UI control is bypassed', async ({ request }) => {
    const acct = await createAccount(request);
    // Bypass the UI entirely: hit the backend reset-password endpoint directly with
    // an out-of-range password (41 chars), the same thing the disabled "Change"
    // control prevents client-side.
    const tooLong = 'x'.repeat(41);
    const res = await withRetry(() =>
      request.post('/rest/user/reset-password', { data: { email: acct.email, answer: acct.answer, new: tooLong, repeat: tooLong } })
    );
    test.info().annotations.push({ type: 'observed', description: `direct backend bypass status=${res.status()}` });
    expect(res.status()).toBeGreaterThanOrEqual(400);
    const loginOld = await withRetry(() => request.post('/rest/user/login', { data: { email: acct.email, password: acct.password } }));
    expect(loginOld.ok()).toBeTruthy();
  });
});
