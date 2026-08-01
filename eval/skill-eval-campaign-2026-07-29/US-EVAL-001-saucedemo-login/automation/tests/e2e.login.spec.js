// Generated from testbooks/login-gate.feature (US-EVAL-001). Every test title carries
// its source scenario ID + AC tag (traceability, automate SKILL.md rule "Traceability").
// One spec block per Gherkin scenario; QAIA-US-EVAL-001-005 is a Scenario Outline with
// 2 examples -> 2 test() blocks here, same scenario ID, counted as 1 traceability row (D20).
const { test, expect } = require('./fixtures');

test.describe('SauceDemo login gate (US-EVAL-001)', () => {

  test('QAIA-US-EVAL-001-001 @AC1 - valid non-locked account reaches the product catalog', async ({ page, loginPage, inventoryPage }) => {
    await loginPage.goto();
    await loginPage.login('standard_user', 'secret_sauce');
    await expect(page).toHaveURL(/inventory\.html/);
    await expect(inventoryPage.container).toBeVisible();
  });

  test('QAIA-US-EVAL-001-002 @AC2 - locked-out account is refused with the locked-out message', async ({ page, loginPage, inventoryPage }) => {
    await loginPage.goto();
    await loginPage.login('locked_out_user', 'secret_sauce');
    await expect(page).not.toHaveURL(/inventory\.html/);
    await expect(loginPage.error).toHaveText('Epic sadface: Sorry, this user has been locked out.');
    await expect(inventoryPage.container).not.toBeVisible();
  });

  test('QAIA-US-EVAL-001-003 @AC3 - unknown username is refused with a generic message', async ({ page, loginPage, inventoryPage }) => {
    await loginPage.goto();
    // "an unrecognized username" (Gherkin) -- concrete value picked for automation,
    // any string not present in SauceDemo's fixed user list is equivalent here.
    await loginPage.login('not_a_real_user', 'secret_sauce');
    await expect(page).not.toHaveURL(/inventory\.html/);
    await expect(loginPage.error).toBeVisible();
    await expect(inventoryPage.container).not.toBeVisible();
  });

  test('QAIA-US-EVAL-001-004 @AC3 - known username with wrong password is refused with a generic message', async ({ page, loginPage, inventoryPage }) => {
    await loginPage.goto();
    await loginPage.login('standard_user', 'not_the_real_password');
    await expect(page).not.toHaveURL(/inventory\.html/);
    await expect(loginPage.error).toBeVisible();
    await expect(inventoryPage.container).not.toBeVisible();
  });

  // Scenario Outline QAIA-US-EVAL-001-005: Q2 was an [assumption] that empty fields fall through
  // to the generic refusal path. Disconfirmed against the live app on 2026-08-01 -- each empty
  // field has its own required-field message. The test book now commits to those messages, so
  // the assertions below assert them instead of mere visibility (D132).
  test('QAIA-US-EVAL-001-005 @AC3 - empty username is refused [example 1: empty username]', async ({ page, loginPage, inventoryPage }) => {
    await loginPage.goto();
    await loginPage.login('', 'secret_sauce');
    await expect(page).not.toHaveURL(/inventory\.html/);
    await expect(loginPage.error).toHaveText('Epic sadface: Username is required');
    await expect(inventoryPage.container).not.toBeVisible();
  });

  test('QAIA-US-EVAL-001-005 @AC3 - empty password is refused [example 2: empty password]', async ({ page, loginPage, inventoryPage }) => {
    await loginPage.goto();
    await loginPage.login('standard_user', '');
    await expect(page).not.toHaveURL(/inventory\.html/);
    await expect(loginPage.error).toHaveText('Epic sadface: Password is required');
    await expect(inventoryPage.container).not.toBeVisible();
  });

  // QAIA-US-EVAL-001-006: Q3 asked whether a locked account with a wrong password shows the
  // locked-out message or the generic one. The test book's *proposed default* (locked-out wins)
  // was encoded literally and failed on the 2026-07-30 run -- and that failure was the answer,
  // exactly as the spec comment then predicted. Resolved 2026-08-01: credentials are validated
  // before lock state, so the generic message wins here and the locked-out message appears only
  // with a correct password (test 002 above). Corrected against the live oracle, not softened --
  // the assertion is still an exact-text match, only the expected value changed (D132).
  test('QAIA-US-EVAL-001-006 @AC2 - locked-out account with wrong password is refused with the generic message', async ({ page, loginPage, inventoryPage }) => {
    await loginPage.goto();
    await loginPage.login('locked_out_user', 'not_the_real_password');
    await expect(page).not.toHaveURL(/inventory\.html/);
    await expect(loginPage.error).toHaveText('Epic sadface: Username and password do not match any user in this service');
    await expect(inventoryPage.container).not.toBeVisible();
  });

});
