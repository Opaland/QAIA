// Page Object — Swag Labs sign-in screen. Selectors only, NO assertions (automate SKILL.md line 19).
// Selectors: getByTestId (SauceDemo publishes `data-test`; the config maps testIdAttribute to it)
// and getByRole. No positional XPath, no nth-child chains.
exports.LoginPage = class LoginPage {
  constructor(page) {
    this.page = page;
    this.username = page.getByTestId('username');
    this.password = page.getByTestId('password');
    this.loginButton = page.getByTestId('login-button');
    this.error = page.getByTestId('error');
  }

  async goto() {
    await this.page.goto('/');
  }

  async signIn(user, pass) {
    await this.username.fill(user);
    await this.password.fill(pass);
    await this.loginButton.click();
  }
};
