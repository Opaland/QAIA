// Page Object — SauceDemo login screen. Selectors only, no assertions (assertions live in tests).
// Selectors confirmed by live exploration against https://www.saucedemo.com/ (automate SKILL.md
// step 3): all three interactive elements expose data-test attributes (T2 compliant).
exports.LoginPage = class LoginPage {
  constructor(page) {
    this.page = page;
    this.username = page.getByTestId('username');
    this.password = page.getByTestId('password');
    this.submit = page.getByTestId('login-button');
    this.error = page.getByTestId('error');
  }
  async goto() { await this.page.goto('/'); }
  async login(username, password) {
    // Atomic precondition: goto() is called by each test itself, no UI-chained
    // multi-step setup — fill() with '' is a no-op-safe way to represent the
    // "empty field" scenarios (QAIA-US-EVAL-001-005) without branching logic here.
    await this.username.fill(username);
    await this.password.fill(password);
    await this.submit.click();
  }
};
