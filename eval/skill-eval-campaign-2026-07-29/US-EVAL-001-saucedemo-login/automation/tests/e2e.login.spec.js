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

  // Scenario Outline QAIA-US-EVAL-001-005 (@low-confidence, Q2 assumption): the Gherkin's
  // Then only asserts "refused" + "catalog not displayed", no specific message text --
  // so the assertions below stay faithful to the Then and don't assert a wording the
  // test book itself never committed to.
  test('QAIA-US-EVAL-001-005 @AC3 - empty username is refused [example 1: empty username]', async ({ page, loginPage, inventoryPage }) => {
    await loginPage.goto();
    await loginPage.login('', 'secret_sauce');
    await expect(page).not.toHaveURL(/inventory\.html/);
    await expect(loginPage.error).toBeVisible();
    await expect(inventoryPage.container).not.toBeVisible();
  });

  test('QAIA-US-EVAL-001-005 @AC3 - empty password is refused [example 2: empty password]', async ({ page, loginPage, inventoryPage }) => {
    await loginPage.goto();
    await loginPage.login('standard_user', '');
    await expect(page).not.toHaveURL(/inventory\.html/);
    await expect(loginPage.error).toBeVisible();
    await expect(inventoryPage.container).not.toBeVisible();
  });

  // QAIA-US-EVAL-001-006 (@low-confidence, Q3 open question, "proposed default,
  // unconfirmed" per synthesis.md): this asserts the Gherkin's Then literally
  // (locked-out message wins over wrong-password). Left as authored -- automate's
  // job is to encode the test book's stated expectation, not silently correct it.
  // If this fails against the real app, that failure IS the answer to Q3 and must
  // be reported honestly, not treated as an automation defect.
  test('QAIA-US-EVAL-001-006 @AC2 - locked-out account with wrong password still shows locked-out message (proposed default, unconfirmed)', async ({ page, loginPage, inventoryPage }) => {
    await loginPage.goto();
    await loginPage.login('locked_out_user', 'not_the_real_password');
    await expect(page).not.toHaveURL(/inventory\.html/);
    await expect(loginPage.error).toHaveText('Epic sadface: Sorry, this user has been locked out.');
    await expect(inventoryPage.container).not.toBeVisible();
  });

});
