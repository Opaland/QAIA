// POM-as-fixtures (modern Playwright pattern, D34). Each test gets fresh page objects,
// and every test starts from a reset SUT so scenarios are atomic (declarative preconditions).
const base = require('@playwright/test');
const { LoginPage } = require('./pages/LoginPage');
const { ReportsPage } = require('./pages/ReportsPage');

function actorFixture(email, expectedName) {
  return async ({ loginPage, reportsPage, page }, use) => {
    await loginPage.goto();
    await loginPage.signIn(email, 'demo1234');
    await base.expect(reportsPage.whoami).toHaveText(expectedName);
    await use({ loginPage, reportsPage, page });
  };
}

exports.test = base.test.extend({
  resetDb: [async ({ request, baseURL }, use) => {
    await request.post(baseURL + '/api/reset');
    await use();
  }, { auto: true }],
  loginPage: async ({ page }, use) => { await use(new LoginPage(page)); },
  reportsPage: async ({ page }, use) => { await use(new ReportsPage(page)); },
  employee: actorFixture('employee@demo', 'Elie Employee'),
  manager: actorFixture('manager@demo', 'Mona Manager'),
  finance: actorFixture('finance@demo', 'Fio Finance'),
  director: actorFixture('director@demo', 'Dara Director'),
  // A genuine second UI actor (own browser context) — for scenarios needing two real
  // signed-in users interacting through the UI in the same test (e.g. the smoke journey).
  openActor: async ({ browser }, use) => {
    const opened = [];
    await use(async (email, expectedName, password = 'demo1234') => {
      const context = await browser.newContext();
      const page = await context.newPage();
      const loginPage = new LoginPage(page);
      const reportsPage = new ReportsPage(page);
      await loginPage.goto();
      await loginPage.signIn(email, password);
      await base.expect(reportsPage.whoami).toHaveText(expectedName);
      opened.push(context);
      return { page, loginPage, reportsPage };
    });
    for (const c of opened) await c.close();
  },
});
exports.expect = base.expect;
