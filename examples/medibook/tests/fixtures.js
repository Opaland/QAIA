// POM-as-fixtures (modern Playwright pattern). Each test gets fresh page objects,
// and every test starts from a reset SUT so scenarios are atomic (declarative preconditions).
const base = require('@playwright/test');
const { LoginPage } = require('./pages/LoginPage');
const { BookingPage } = require('./pages/BookingPage');

exports.test = base.test.extend({
  resetDb: [async ({ request, baseURL }, use) => {
    await request.post(baseURL + '/api/reset');
    await use();
  }, { auto: true }],
  loginPage: async ({ page }, use) => { await use(new LoginPage(page)); },
  bookingPage: async ({ page }, use) => { await use(new BookingPage(page)); },
  patient: async ({ loginPage, bookingPage, page }, use) => {
    await loginPage.goto();
    await loginPage.signIn('patient@demo', 'demo1234');
    await base.expect(bookingPage.whoami).toHaveText('patient@demo');
    await use({ loginPage, bookingPage, page });
  },
});
exports.expect = base.expect;
