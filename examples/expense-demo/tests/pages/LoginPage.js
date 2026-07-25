// Page Object — sign-in screen. Selectors only, no assertions (assertions live in tests).
exports.LoginPage = class LoginPage {
  constructor(page) {
    this.page = page;
    this.email = page.getByTestId('email');
    this.password = page.getByTestId('password');
    this.submit = page.getByTestId('login-btn');
    this.error = page.locator('#login-section #message');
  }
  async goto() { await this.page.goto('/'); }
  async signIn(email, password) {
    await this.email.fill(email);
    await this.password.fill(password);
    await this.submit.click();
  }
};
